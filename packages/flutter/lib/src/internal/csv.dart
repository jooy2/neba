/// A table as CSV: the React package's `src/internal/csv.ts` in Dart.
///
/// The escaping is the whole job, and getting it wrong is silent: a comma
/// inside a cell shifts every column after it by one, and nobody notices
/// until a spreadsheet somewhere is a column off. RFC 4180 is four rules, and
/// all four are below. A DataTable writes its rows with it, and a chart's
/// export is meant to.
///
/// The package starts no download, so the text is all there is: a widget
/// hands it to its caller.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:convert';

/// What starts a text a spreadsheet would run as a formula.
final RegExp _formula = RegExp(r'^[=+\-@\t\r]');

/// What makes a field need its quotes, besides the separator.
final RegExp _quoted = RegExp(r'["\r\n]');

/// One field, quoted only when it has to be.
///
/// A field is quoted if it holds the separator, a quote or a line break, and
/// a quote inside a quoted field is written twice. `null` is empty rather
/// than the word `null`. A [DateTime] is written as an ISO 8601 instant in
/// UTC, as `Date.prototype.toISOString` writes it, and a map or a list as its
/// JSON.
///
/// A text that starts with `=`, `+`, `-`, `@`, a tab or a carriage return gets
/// a `'` in front unless [escapeFormulas] is off: a spreadsheet would read it
/// as a formula, and a name somebody typed as `=HYPERLINK(...)` would run on
/// the machine of whoever opened the file. Only text is touched; a negative
/// number stays a number.
String nebaCsvField(Object? value, {String separator = ',', bool escapeFormulas = true}) {
  if (value == null) {
    return '';
  }

  final String raw = switch (value) {
    final DateTime date => date.toUtc().toIso8601String(),
    Map<Object?, Object?>() || List<Object?>() => _json(value),
    _ => '$value',
  };
  final String text = escapeFormulas && value is String && _formula.hasMatch(raw) ? "'$raw" : raw;

  return _quoted.hasMatch(text) || text.contains(separator)
      ? '"${text.replaceAll('"', '""')}"'
      : text;
}

String _json(Object value) {
  try {
    return jsonEncode(value);
  } on JsonUnsupportedObjectError {
    return '$value';
  }
}

/// [rows] as one CSV document, each field through [nebaCsvField].
///
/// Lines end in CRLF, as RFC 4180 says. [bom] writes a byte-order mark in
/// front, on by default because Excel reads a UTF-8 file without one in the
/// local code page and every non-ASCII name in it arrives as mojibake; every
/// other reader ignores the mark. [separator] is `;` for the locales whose
/// spreadsheets expect it.
String nebaToCsv(
  List<List<Object?>> rows, {
  String separator = ',',
  bool bom = true,
  bool escapeFormulas = true,
}) {
  final String body = rows
      .map(
        (List<Object?> row) => row
            .map(
              (Object? field) =>
                  nebaCsvField(field, separator: separator, escapeFormulas: escapeFormulas),
            )
            .join(separator),
      )
      .join('\r\n');

  // Written as an escape rather than as the character: a lone zero-width
  // no-break space in a source file is invisible to every reviewer.
  return bom ? '\uFEFF$body' : body;
}
