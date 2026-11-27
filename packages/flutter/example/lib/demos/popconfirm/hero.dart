import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PopconfirmHero extends StatefulWidget {
  const PopconfirmHero({super.key});

  @override
  State<PopconfirmHero> createState() => _PopconfirmHeroState();
}

class _PopconfirmHeroState extends State<PopconfirmHero> {
  List<String> _rows = const <String>['staging.neba.dev', 'preview.neba.dev', 'docs.neba.dev'];

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          NebaList(
            variant: NebaVariant.outline,
            children: <Widget>[
              for (final String row in _rows)
                NebaListItem(
                  key: ValueKey<String>(row),
                  action: NebaPopconfirm(
                    title: Text('Remove $row?'),
                    description: const Text('The domain stops resolving immediately.'),
                    confirmLabel: const Text('Remove'),
                    onConfirm: () {
                      setState(() {
                        _rows = <String>[
                          for (final String entry in _rows)
                            if (entry != row) entry,
                        ];
                      });
                    },
                    trigger: NebaIconButton(
                      onPressed: () {},
                      size: NebaSize.sm,
                      variant: NebaVariant.text,
                      label: 'Remove',
                      icon: const _Trash(),
                    ),
                  ),
                  child: Text(row),
                ),
            ],
          ),
          if (_rows.isEmpty)
            NebaButton(
              onPressed: () => setState(() => _rows = const <String>['staging.neba.dev']),
              variant: NebaVariant.outline,
              child: const Text('Put one back'),
            )
          else
            NebaTypography(
              'The question stays beside the row it is about.',
              level: NebaTypographyLevel.caption,
              style: TextStyle(color: tokens.mutedFg),
            ),
        ],
      ),
    );
  }
}

/// A bin, the React demo's 16-unit path, in the colour and at the size the
/// button hands down.
class _Trash extends StatelessWidget {
  const _Trash();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _TrashPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _TrashPainter extends CustomPainter {
  _TrashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final Path path = Path()
      ..moveTo(3, 4.5)
      ..lineTo(13, 4.5)
      ..moveTo(6.5, 4.5)
      ..lineTo(6.5, 3)
      ..lineTo(9.5, 3)
      ..lineTo(9.5, 4.5)
      ..moveTo(4.5, 4.5)
      ..lineTo(5, 12.5)
      ..lineTo(11, 12.5)
      ..lineTo(11.5, 4.5);

    canvas
      ..scale(size.width / 16)
      ..drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_TrashPainter oldDelegate) => oldDelegate.color != color;
}
