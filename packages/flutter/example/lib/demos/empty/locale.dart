import 'package:flutter/widgets.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';

const List<Locale> _locales = <Locale>[
  Locale('en'),
  Locale('ko'),
  Locale('ja'),
  Locale('fr'),
  Locale('ar'),
];

class EmptyLocale extends StatefulWidget {
  const EmptyLocale({super.key});

  @override
  State<EmptyLocale> createState() => _EmptyLocaleState();
}

class _EmptyLocaleState extends State<EmptyLocale> {
  @override
  void initState() {
    super.initState();

    // An app registers the languages it speaks once, before it runs.
    registerNebaMessages('ko', ko);
    registerNebaMessages('ja', ja);
    registerNebaMessages('fr', fr);
    registerNebaMessages('ar', ar);
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      children: <Widget>[
        for (final Locale locale in _locales)
          NebaGrid(
            span: NebaGridSpan.columns(wide ? 4 : 12),
            child: NebaEmpty(variant: NebaVariant.outline, size: NebaSize.sm, locale: locale),
          ),
      ],
    );
  }
}
