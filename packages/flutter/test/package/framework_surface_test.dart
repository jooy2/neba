// That the package is built on `package:flutter/widgets.dart` alone.
//
// A Neba widget has to sit inside a Material app, a Cupertino app or a bare
// `WidgetsApp` without bringing a second design system in behind it, and
// Material and Cupertino are moving out of the framework. One import of
// either, anywhere under `lib/`, would undo both.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<File> sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'))
      .toList();

  test('reads the files it is about', () {
    expect(sources, isNotEmpty);
  });

  test('imports neither Material nor Cupertino, and no mirrors', () {
    final RegExp banned = RegExp(
      r'''^\s*(import|export)\s+['"](package:flutter/(material|cupertino)\.dart|dart:mirrors)['"]''',
      multiLine: true,
    );
    final List<String> offenders = <String>[
      for (final File file in sources)
        if (banned.hasMatch(file.readAsStringSync())) file.path,
    ];

    expect(offenders, isEmpty);
  });

  test('declares no dependency but the Flutter SDK', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final String dependencies = RegExp(
      r'^dependencies:\n((?:  .*\n|\n)*)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1)!;

    expect(dependencies.trim(), 'flutter:\n    sdk: flutter');
  });
}
