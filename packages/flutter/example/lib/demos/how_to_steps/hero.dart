import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class HowToStepsHero extends StatelessWidget {
  const HowToStepsHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaHowToSteps(
      title: Text('Schedule a job with cron'),
      steps: <NebaHowToStep>[
        NebaHowToStep(
          title: Text('Open your crontab'),
          icon: _Icon(_terminal),
          content: _Step(
            text:
                r'Every user has a crontab of their own. This opens yours in the editor $EDITOR points at.',
            code: NebaCodeBlock(
              size: NebaSize.sm,
              language: 'bash',
              prompt: r'$',
              code: 'crontab -e',
            ),
          ),
        ),
        NebaHowToStep(
          title: Text('Write the schedule'),
          icon: _Icon(_clock),
          content: _Step(
            text: 'Five fields, then the command: minute, hour, day of month, month, day of week.',
            code: NebaCodeBlock(
              size: NebaSize.sm,
              language: 'bash',
              code: '*/5 * * * * /usr/local/bin/backup.sh',
            ),
          ),
        ),
        NebaHowToStep(
          title: Text('Keep the output'),
          icon: _Icon(_file),
          content: _Step(
            text:
                'cron mails you anything a job prints. Redirect it to a file instead, so a failure is somewhere you will look.',
            code: NebaCodeBlock(
              size: NebaSize.sm,
              language: 'bash',
              wrap: true,
              code: '*/5 * * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1',
            ),
          ),
        ),
        NebaHowToStep(
          title: Text('Check it took'),
          icon: _Icon(_eye),
          content: _Step(
            text: 'Print the crontab back and read what is actually in it.',
            code: NebaCodeBlock(
              size: NebaSize.sm,
              language: 'bash',
              prompt: r'$',
              code: 'crontab -l',
            ),
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.text, required this.code});

  final String text;
  final Widget code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: <Widget>[NebaTypography(text), code],
    );
  }
}

/// A prompt and a cursor, on the 16-unit grid.
Path _terminal() {
  return Path()
    ..moveTo(3.5, 4.5)
    ..lineTo(6.5, 8)
    ..lineTo(3.5, 11.5)
    ..moveTo(8.5, 11.5)
    ..lineTo(12.5, 11.5);
}

/// A clock face with its hands at a quarter past.
Path _clock() {
  return Path()
    ..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 5.75))
    ..moveTo(8, 4.75)
    ..lineTo(8, 8)
    ..lineTo(10.25, 9.5);
}

/// A sheet with its corner folded.
Path _file() {
  return Path()
    ..moveTo(9, 2.25)
    ..lineTo(4.75, 2.25)
    ..arcToPoint(const Offset(3.25, 3.75), radius: const Radius.circular(1.5), clockwise: false)
    ..lineTo(3.25, 12.25)
    ..arcToPoint(const Offset(4.75, 13.75), radius: const Radius.circular(1.5), clockwise: false)
    ..lineTo(11.25, 13.75)
    ..arcToPoint(const Offset(12.75, 12.25), radius: const Radius.circular(1.5), clockwise: false)
    ..lineTo(12.75, 5.75)
    ..close()
    ..moveTo(8.75, 2.5)
    ..lineTo(8.75, 5.75)
    ..lineTo(12.25, 5.75);
}

/// An eye, open.
Path _eye() {
  return Path()
    ..moveTo(1.5, 8)
    ..quadraticBezierTo(8, 0, 14.5, 8)
    ..quadraticBezierTo(8, 16, 1.5, 8)
    ..close()
    ..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 1.75));
}

/// A stroked path in the icon colour at the icon size the step hands down.
class _Icon extends StatelessWidget {
  const _Icon(this.path);

  final Path Function() path;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _IconPainter(path, icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.path, this.color);

  final Path Function() path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        path(),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.color != color;
  }
}
