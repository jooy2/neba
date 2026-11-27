import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

/// The least width the bar is laid out at.
const double _width = 600;

class HeaderHero extends StatelessWidget {
  const HeaderHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    final Widget header = ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      child: NebaHeader(
        position: NebaPosition.static,
        brand: const <Widget>[
          NebaAppLogo(name: 'Neba', image: AssetImage('assets/128x128.png'), showName: true),
        ],
        actions: <Widget>[
          NebaButton(
            onPressed: _open,
            variant: NebaVariant.text,
            size: NebaSize.sm,
            child: const Text('Sign in'),
          ),
          NebaButton(
            onPressed: _open,
            variant: NebaVariant.solid,
            size: NebaSize.sm,
            child: const Text('Get started'),
          ),
        ],
        children: <Widget>[
          // The links wrap onto a second line rather than run into the
          // actions.
          Flexible(
            child: Semantics(
              container: true,
              role: SemanticsRole.navigation,
              label: 'Site',
              explicitChildNodes: true,
              child: Wrap(
                spacing: 16,
                runSpacing: 4,
                children: <Widget>[
                  for (final String page in <String>['Docs', 'Components', 'Changelog'])
                    NebaTextLink(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      underline: NebaTextLinkUnderline.hover,
                      child: Text(page),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // The logo and the two buttons alone are wider than a phone, so there the
    // bar keeps a width of its own and scrolls sideways.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return constraints.maxWidth >= _width
            ? header
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: _width, child: header),
              );
      },
    );
  }
}
