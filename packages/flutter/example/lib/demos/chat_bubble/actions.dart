import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChatBubbleActions extends StatelessWidget {
  const ChatBubbleActions({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          NebaChatBubble(
            avatar: NebaAvatar(
              image: AssetImage('assets/samples/people/farah-wells.jpg'),
              name: 'Farah Wells',
              size: NebaSize.sm,
            ),
            name: Text('Farah'),
            actions: _MessageMenu(),
            child: Text('Hover this row, or tab into it.'),
          ),
          NebaChatBubble(
            side: NebaChatBubbleSide.end,
            variant: NebaVariant.solid,
            status: NebaChatBubbleStatus.read,
            actions: _MessageMenu(),
            child: Text('The handle sits on the other side here.'),
          ),
        ],
      ),
    );
  }
}

class _MessageMenu extends StatelessWidget {
  const _MessageMenu();

  @override
  Widget build(BuildContext context) {
    return NebaMenu(
      trigger: NebaIconButton(
        onPressed: () {},
        icon: const _MoreIcon(),
        label: 'Message options',
        variant: NebaVariant.text,
        size: NebaSize.sm,
      ),
      children: const <Widget>[
        NebaMenuItem(child: Text('Reply')),
        NebaMenuItem(child: Text('Forward')),
        NebaMenuItem(child: Text('Copy')),
        NebaMenuSeparator(),
        NebaMenuItem(color: NebaColor.danger, child: Text('Delete')),
      ],
    );
  }
}

/// Three dots in a column.
class _MoreIcon extends StatelessWidget {
  const _MoreIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MorePainter(IconTheme.of(context).color ?? const Color(0xFF000000)),
      size: Size.square(IconTheme.of(context).size ?? 16),
    );
  }
}

class _MorePainter extends CustomPainter {
  _MorePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.shortestSide / 16;
    final Paint paint = Paint()..color = color;

    for (final double y in <double>[3.5, 8, 12.5]) {
      canvas.drawCircle(Offset(8 * unit, y * unit), 1.15 * unit, paint);
    }
  }

  @override
  bool shouldRepaint(_MorePainter oldDelegate) => oldDelegate.color != color;
}
