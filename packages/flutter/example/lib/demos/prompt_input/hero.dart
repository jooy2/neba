import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PromptInputHero extends StatefulWidget {
  const PromptInputHero({super.key});

  @override
  State<PromptInputHero> createState() => _PromptInputHeroState();
}

class _PromptInputHeroState extends State<PromptInputHero> {
  final TextEditingController _controller = TextEditingController();
  String? _sent;
  bool _submitting = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _submit(String text) {
    _controller.clear();
    setState(() {
      _sent = text;
      _submitting = true;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2400), _stop);
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final String? sent = _sent;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          if (sent != null)
            Text('Sent: $sent', style: TextStyle(fontSize: 13, color: tokens.mutedFg)),
          NebaPromptInput(
            label: const Text('Message'),
            placeholder: 'Ask about the design language…',
            controller: _controller,
            submitting: _submitting,
            onStop: _stop,
            onSubmit: _submit,
            start: <Widget>[
              NebaIconButton(
                icon: const _ClipIcon(),
                label: 'Attach a file',
                size: NebaSize.sm,
                variant: NebaVariant.text,
                color: NebaColor.secondary,
                onPressed: () {},
              ),
              const Flexible(
                child: NebaSelect<String>(
                  size: NebaSize.sm,
                  variant: NebaVariant.text,
                  defaultValue: 'opus',
                  semanticLabel: 'Model',
                  items: <NebaSelectOption<String>>[
                    NebaSelectOption<String>(value: 'opus', label: Text('Opus')),
                    NebaSelectOption<String>(value: 'sonnet', label: Text('Sonnet')),
                  ],
                ),
              ),
            ],
            end: const <Widget>[
              NebaContextWindow(size: NebaSize.xs, max: 200000, used: 48000, breakdown: false),
            ],
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                NebaChip(
                  size: NebaSize.sm,
                  onDelete: () {},
                  child: const Text('design-language.md'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A paper clip, the attach control's glyph.
class _ClipIcon extends StatelessWidget {
  const _ClipIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return CustomPaint(
      size: Size.square(icon.size ?? 16),
      painter: _ClipPainter(icon.color ?? const Color(0xFF000000)),
    );
  }
}

class _ClipPainter extends CustomPainter {
  const _ClipPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 16, size.height / 16);

    final Path path = Path()
      ..moveTo(10.5, 5.5)
      ..lineTo(6.2, 9.8)
      ..arcToPoint(const Offset(8.9, 12.5), radius: const Radius.circular(1.9), clockwise: false)
      ..lineTo(13.5, 7.9)
      ..arcToPoint(const Offset(8.7, 3.1), radius: const Radius.circular(3.4), clockwise: false)
      ..lineTo(3.6, 8.2)
      ..arcToPoint(const Offset(10.6, 15.2), radius: const Radius.circular(4.9), clockwise: false)
      ..lineTo(13.8, 12);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ClipPainter oldDelegate) => oldDelegate.color != color;
}
