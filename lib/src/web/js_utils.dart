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

/// `null` for `undefined`, `null` and any non-string value (the SDK uses
/// `false` as "unset" for some string properties).
String? jsStringOrNull(JSAny? value) =>
    value.isUndefinedOrNull || !value.isA<JSString>()
    ? null
    : (value as JSString).toDart;

/// `true` only for a JS `true`; `false` for anything else, including a
/// missing argument.
bool jsBool(JSAny? value) =>
    value.isA<JSBoolean>() && (value as JSBoolean).toDart;

// -----------------------------------------------------------------------------
// Dart functions handed to JavaScript.
//
// A function made with `.toJS` throws when JavaScript calls it with fewer
// arguments than it has required parameters (dart2js, DDC and dart2wasm
// alike), and the SDK swallows that exception: event handlers are invoked
// with no arguments when an event has no payload, storage callbacks with
// two arguments instead of three, `CloudStorage.getItem` errors with one.
//
// Every JS-facing callback in this package is therefore built with these
// helpers, whose parameters are all optional. Extra arguments are ignored.
// A test enforces that no other file converts a function literal with
// `.toJS`.

/// A JS function that takes no arguments.
JSFunction jsFn0(void Function() body) => (() => body()).toJS;

/// A JS function reading up to one argument.
JSFunction jsFn1(void Function(JSAny? a) body) =>
    (([JSAny? a]) => body(a)).toJS;

/// A JS function reading up to two arguments.
JSFunction jsFn2(void Function(JSAny? a, JSAny? b) body) =>
    (([JSAny? a, JSAny? b]) => body(a, b)).toJS;

/// A JS function reading up to three arguments.
JSFunction jsFn3(void Function(JSAny? a, JSAny? b, JSAny? c) body) =>
    (([JSAny? a, JSAny? b, JSAny? c]) => body(a, b, c)).toJS;

/// [jsFn1] whose return value is handed back to JavaScript.
JSFunction jsFn1Returning(JSAny? Function(JSAny? a) body) =>
    (([JSAny? a]) => body(a)).toJS;

// -----------------------------------------------------------------------------
// Errors and futures

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
  // JS values surface in Dart as interop values: read a thrown `Error`'s
  // `.message`, or a string error code such as `KEY_INVALID` as is.
  // ignore: invalid_runtime_check_with_js_interop_types
  if (e is JSAny) {
    if (e.isA<JSString>()) return (e as JSString).toDart;
    if (e.isA<JSObject>()) {
      final msg = (e as JSObject)['message'];
      if (msg.isA<JSString>()) return (msg as JSString).toDart;
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

/// Adapts `complete` into the SDK's `(boolean) => void` callback.
JSFunction jsBoolCallback(void Function(bool value) complete) =>
    jsFn1((value) => complete(jsBool(value)));

/// Adapts `complete` into a no-argument SDK callback.
JSFunction jsDoneCallback(void Function(void value) complete) =>
    jsFn0(() => complete(null));

/// Node-style `(error, result[, extra])` callback used by the storage APIs.
/// The SDK passes one, two or three arguments depending on storage and
/// outcome.
Future<T> jsStorageCallback<T>(
  void Function(JSFunction callback) invoke,
  T Function(JSAny? result, JSAny? extra) decode,
) {
  final completer = Completer<T>();
  final callback = jsFn3((error, result, extra) {
    if (completer.isCompleted) return;
    if (!error.isUndefinedOrNull) {
      completer.completeError(TmaJsException(_jsErrorMessage(error!)));
    } else {
      completer.complete(decode(result, extra));
    }
  });
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
      // as the only argument, or with no argument when there is none.
      handler = jsFn1((payload) => controller.add(decode(payload)));
      on(eventType, handler!);
    },
    onCancel: () {
      if (handler != null) off(eventType, handler!);
      handler = null;
    },
  );
  return controller.stream;
}
