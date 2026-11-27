/// The letters that stand in for a picture that is not there, the React
/// package's `src/internal/initials.ts` in Dart.
///
/// Here rather than in the avatar because an Avatar with no photograph and an
/// AppLogo with no artwork both draw it, and a library with two of these rules
/// would spell the same person's initials two ways on one screen.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

/// The first character of the first word, plus the first of the last.
///
/// A character is a grapheme cluster rather than a code unit, so a name that
/// starts with an emoji or with a letter whose accent arrived as a separate
/// mark is not cut apart. One word gives one character on purpose: Korean,
/// Japanese and Chinese names are a single token, and two of their characters
/// at 32 pixels is a smudge where one is a name.
String initialsOf(String name) {
  final List<String> words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) {
    return '';
  }

  final String first = words.first.characters.first;
  final String last = words.length > 1 ? words.last.characters.first : '';

  return (first + last).toUpperCase();
}
