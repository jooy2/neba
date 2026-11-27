import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, String?)> _people = <(String, String?)>[
  ('Jane Doe', null),
  ('jane miriam van doe', null),
  ('홍길동', null),
  ('Ada', null),
  ('Jane Doe', 'vD'),
];

class AvatarInitials extends StatelessWidget {
  const AvatarInitials({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final (String name, String? initials) in _people)
          NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 2,
            alignItems: NebaAlignItems.center,
            children: <Widget>[
              NebaAvatar(size: NebaSize.xl, color: NebaColor.info, name: name, initials: initials),
              Text(
                initials == null ? '"$name"' : "initials: '$initials'",
                style: TextStyle(fontSize: 12, color: tokens.mutedFg),
              ),
            ],
          ),
      ],
    );
  }
}
