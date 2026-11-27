import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class OtpFieldHero extends StatefulWidget {
  const OtpFieldHero({super.key});

  @override
  State<OtpFieldHero> createState() => _OtpFieldHeroState();
}

class _OtpFieldHeroState extends State<OtpFieldHero> {
  String _code = '';
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          NebaOtpField(
            label: const Text('Verification code'),
            description: const Text('We texted a six digit code to •••• 4417.'),
            groupSize: 3,
            value: _code,
            onValueChange: (String next) => setState(() {
              _code = next;
              _done = false;
            }),
            onComplete: (String code) => setState(() => _done = true),
          ),
          if (_done)
            NebaAlert(
              color: NebaColor.success,
              title: const Text('Code accepted'),
              child: Text('$_code checked out.'),
            ),
        ],
      ),
    );
  }
}
