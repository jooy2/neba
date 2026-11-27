import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class FooterHero extends StatelessWidget {
  const FooterHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      child: NebaFooter(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 32,
          runSpacing: 32,
          children: <Widget>[
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: <Widget>[
                NebaAppLogo(
                  name: 'Neba',
                  image: AssetImage('assets/128x128.png'),
                  showName: true,
                  size: NebaSize.sm,
                ),
                NebaTypography(
                  '© 2026 Neba. All rights reserved.',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
              ],
            ),
            Semantics(
              container: true,
              role: SemanticsRole.navigation,
              label: 'Footer',
              explicitChildNodes: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 40,
                children: const <Widget>[
                  _Links(title: 'Product', pages: <String>['Components', 'Changelog']),
                  _Links(title: 'Company', pages: <String>['About', 'Privacy']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A column of links under its heading.
class _Links extends StatelessWidget {
  const _Links({required this.title, required this.pages});

  final String title;
  final List<String> pages;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: <Widget>[
        NebaTypography(title, level: NebaTypographyLevel.overline),
        for (final String page in pages)
          NebaTextLink(onPressed: _open, href: Uri.parse('#'), child: Text(page)),
      ],
    );
  }
}
