import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Thousands grouped with [separator], as a locale with no compact notation
/// for thousands writes a count.
String _grouped(double value, String separator) {
  final String digits = value.round().toString();
  final StringBuffer out = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      out.write(separator);
    }

    out.write(digits[i]);
  }

  return out.toString();
}

// The widgets layer has no `Intl`, so each language's numbers are a function
// of the caller's; the React demo leaves them to the browser. Latin scripts
// only here, since the gallery's web build ships Inter alone.
final List<(String, String Function(double), String)> _locales =
    <(String, String Function(double), String)>[
      ('en-US', (double value) => '${(value / 1000).round()}K', r'$0.42'),
      ('de-DE', (double value) => _grouped(value, '.'), r'0,42 $'),
      ('fr-FR', (double value) => '${(value / 1000).round()}\u202Fk', '0,42\u00A0\$US'),
      ('es-ES', (double value) => '${(value / 1000).round()}\u00A0mil', '0,42\u00A0US\$'),
    ];

class ContextWindowLocale extends StatelessWidget {
  const ContextWindowLocale({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          for (final (String tag, String Function(double) count, String money) in _locales)
            NebaContextWindow(
              size: NebaSize.sm,
              label: Text(tag),
              max: 200000,
              used: 124000,
              cost: 0.42,
              breakdown: false,
              format: count,
              formatCost: (double _) => money,
            ),
        ],
      ),
    );
  }
}
