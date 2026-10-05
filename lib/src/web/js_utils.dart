import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../errors.dart';
import '../models/json.dart';

/// Converts a Dart map into a real JS object (NOT `toJSBox`, which produces
/// an opaque handle JavaScript cannot read).
JSObject jsObject(Map<String, Object?> map) => map.jsify()! as JSObject;

JSArray<JSString> jsStringArray(Iterable<String> items) =>
    [for (final s in items) s.toJS].toJS;

/// Converts a JS object into a Dart map; `{}` for `null`/`undefined`.
Map<String, Object?> dartMap(JSAny? value) {
  if (value.isUndefinedOrNull) return const {};
  return jsonMap(value.dartify()) ?? const {};
}

double jsDouble(JSNumber? value, [double fallback = 0]) =>
    value.isUndefinedOrNull ? fallback : value!.toDartDouble;

String? jsStringOrNull(JSAny? value) =>
    value.isUndefinedOrNull ? null : (value as JSString).toDart;

/// Runs a synchronous SDK call and rethrows JavaScript errors as
/// [TmaJsException]. Dart exceptions pass through untouched.
T guardJs<T>(T Function() body) {
  try {
    return body();
  } on TmaException {
    rethrow;
  } catch (e) {
    throw TmaJsException(_jsErrorMessage(e), e);
  }
}

String _jsErrorMessage(Object e) {
  // JS `Error` objects surface in Dart as JS interop values; read `.message`
  // when present so callers see `WebAppPopupOpened` instead of `[object]`.
  // ignore: invalid_runtime_check_with_js_interop_types
  if (e is JSAny && e.isA<JSObject>()) {
    final msg = (e as JSObject)['message'];
    if (!msg.isUndefinedOrNull && msg.isA<JSString>()) {
      return (msg as JSString).toDart;
    }
  }
  return e.toString();
}

/// Bridges a callback-style SDK method into a [Future].
///
/// [invoke] receives a `complete` function and must call the SDK with a
/// callback that eventually invokes it. Synchronous JS errors (for example
/// `WebAppPopupOpened`) reject the future instead of escaping.
Future<T> jsCallback<T>(void Function(void Function(T value) complete) invoke) {
  final completer = Completer<T>();
  void complete(T value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  try {
    invoke(complete);
  } on TmaException catch (e, s) {
    completer.completeError(e, s);
  } catch (e, s) {
    completer.completeError(TmaJsException(_jsErrorMessage(e), e), s);
  }
  return completer.future;
}

/// Node-style `(error, result)` callback used by the storage APIs.
Future<T> jsStorageCallback<T>(
  void Function(JSFunction callback) invoke,
  T Function(JSAny? result, JSAny? extra) decode,
) {
  final completer = Completer<T>();
  final callback = (JSAny? error, JSAny? result, JSAny? extra) {
    if (completer.isCompleted) return;
    if (!error.isUndefinedOrNull) {
      completer.completeError(TmaJsException(_jsErrorMessage(error!)));
    } else {
      completer.complete(decode(result, extra));
    }
  }.toJS;
  try {
    invoke(callback);
  } catch (e, s) {
    if (!completer.isCompleted) {
      completer.completeError(TmaJsException(_jsErrorMessage(e), e), s);
    }
  }
  return completer.future;
}

/// A broadcast stream backed by `onEvent`/`offEvent`. The JS listener is
/// attached on first subscription and removed when the last one cancels.
Stream<T> jsEventStream<T>({
  required String eventType,
  required void Function(String type, JSFunction cb) on,
  required void Function(String type, JSFunction cb) off,
  required T Function(JSAny? payload) decode,
}) {
  late StreamController<T> controller;
  JSFunction? handler;
  controller = StreamController<T>.broadcast(
    onListen: () {
      // Telegram calls listeners with `this` bound to WebApp and the payload
      // (if any) as the single argument.
      handler = ((JSAny? payload) => controller.add(decode(payload))).toJS;
      on(eventType, handler!);
    },
    onCancel: () {
      if (handler != null) off(eventType, handler!);
      handler = null;
    },
  );
  return controller.stream;
}
