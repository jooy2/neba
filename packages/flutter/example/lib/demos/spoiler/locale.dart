import 'package:flutter/widgets.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';

const List<(String, Locale)> _locales = <(String, Locale)>[
  ('en', Locale('en')),
  ('ko', Locale('ko')),
  ('ja', Locale('ja')),
  ('zh-Hant', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
  ('fr', Locale('fr')),
  ('ar', Locale('ar')),
];

class SpoilerLocale extends StatefulWidget {
  const SpoilerLocale({super.key});

  @override
  State<SpoilerLocale> createState() => _SpoilerLocaleState();
}

class _SpoilerLocaleState extends State<SpoilerLocale> {
  @override
  void initState() {
    super.initState();

    // An app registers the languages it speaks once, before it runs.
    registerNebaMessages('ko', ko);
    registerNebaMessages('ja', ja);
    registerNebaMessages('zh-hant', zhHant);
    registerNebaMessages('fr', fr);
    registerNebaMessages('ar', ar);
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 3,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          for (final (String tag, Locale locale) in _locales)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 6 : 12),
              child: NebaSpoiler(
                locale: locale,
                size: NebaSize.sm,
                child: NebaTypography(tag, level: NebaTypographyLevel.caption),
              ),
            ),
        ],
      ),
    );
  }
}
