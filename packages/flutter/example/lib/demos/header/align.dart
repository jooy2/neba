import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

/// The least width the bar is laid out at.
const double _width = 480;

class HeaderAlign extends StatefulWidget {
  const HeaderAlign({super.key});

  @override
  State<HeaderAlign> createState() => _HeaderAlignState();
}

class _HeaderAlignState extends State<HeaderAlign> {
  NebaAlign _align = NebaAlign.center;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    final Widget header = ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      child: NebaHeader(
        align: _align,
        position: NebaPosition.static,
        brand: const <Widget>[
          NebaAppLogo(
            name: 'Neba',
            image: AssetImage('assets/128x128.png'),
            showName: true,
            size: NebaSize.sm,
          ),
        ],
        actions: <Widget>[
          NebaButton(
            onPressed: _open,
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            child: const Text('Sign in'),
          ),
        ],
        children: <Widget>[
          Semantics(
            container: true,
            role: SemanticsRole.navigation,
            label: 'Site',
            explicitChildNodes: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: <Widget>[
                for (final String page in <String>['Docs', 'Pricing'])
                  NebaTextLink(
                    onPressed: _open,
                    href: Uri.parse('#'),
                    underline: NebaTextLinkUnderline.hover,
                    child: Text(page),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        NebaSegmentedButton<NebaAlign>(
          size: NebaSize.sm,
          value: _align,
          onValueChange: (NebaAlign? next) {
            if (next != null) {
              setState(() => _align = next);
            }
          },
          children: <NebaSegment<NebaAlign>>[
            for (final NebaAlign align in NebaAlign.values)
              NebaSegment<NebaAlign>(value: align, child: Text(align.name)),
          ],
        ),
        // Centred, the middle needs room on both sides of it for the wider
        // end, which a phone does not have, so there the bar keeps a width of
        // its own and scrolls sideways.
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return constraints.maxWidth >= _width
                ? header
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(width: _width, child: header),
                  );
          },
        ),
      ],
    );
  }
}
