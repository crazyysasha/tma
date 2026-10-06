@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// JavaScript may call a Dart callback with fewer arguments than it
/// declares, and a function made with `.toJS` then throws silently (see
/// `jsFn1` and friends in lib/src/web/js_utils.dart). Only js_utils.dart may
/// convert function literals; everything else must use its helpers.
void main() {
  test('no function literal is converted with .toJS outside js_utils', () {
    // `.toJS` right after `)` or `}`, possibly on the next line, converts a
    // parenthesised function literal or a block-bodied closure.
    final rawClosure = RegExp(r'[)}]\s*\.toJS\b');
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.endsWith('js_utils.dart')) continue;
      final source = file.readAsStringSync();
      for (final match in rawClosure.allMatches(source)) {
        final line = '\n'.allMatches(source.substring(0, match.start)).length;
        offenders.add('${file.path}:${line + 1}');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'Use jsFn0/jsFn1/jsFn2/jsFn3 from js_utils.dart instead.',
    );
  });
}
