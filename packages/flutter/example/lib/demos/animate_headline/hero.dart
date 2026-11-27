import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _claims = <String>['faster', 'quieter', 'accessible', 'yours'];

class AnimateHeadlineHero extends StatelessWidget {
  const AnimateHeadlineHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaTypeStep h3 = NebaTypography.scale[NebaTypographyLevel.h3]!;

    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: h3.size,
        height: h3.leading,
        fontWeight: h3.weight,
        letterSpacing: h3.tracking * h3.size,
        color: tokens.fg,
      ),
      child: NebaFlex(
        wrap: true,
        spacing: 2,
        children: <Widget>[
          const Text('Interfaces that are'),
          NebaAnimateHeadline(
            interval: const Duration(milliseconds: 2000),
            children: <Widget>[
              for (final String claim in _claims)
                Text(claim, style: TextStyle(color: tokens.roles(NebaColor.primary).accent)),
            ],
          ),
        ],
      ),
    );
  }
}
