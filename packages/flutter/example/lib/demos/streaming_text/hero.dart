import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const String _answer =
    'A Neba surface is a sheet of cut acrylic rather than a moulded plastic key. Nothing scales '
    'under the pointer, because scaling a control resamples its label — state changes are '
    'expressed in colour and depth instead.';

final List<String> _words = _answer.split(' ');

class StreamingTextHero extends StatefulWidget {
  const StreamingTextHero({super.key});

  @override
  State<StreamingTextHero> createState() => _StreamingTextHeroState();
}

class _StreamingTextHeroState extends State<StreamingTextHero> {
  int _count = 0;
  Timer? _timer;

  bool get _streaming => _count < _words.length;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _timer = Timer(Duration(milliseconds: _streaming ? 110 : 2400), () {
      setState(() => _count = _streaming ? _count + 1 : 0);
      _next();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaStreamingText(
        streaming: _streaming,
        lines: 4,
        child: Text(
          _words.take(_count).join(' '),
          style: const TextStyle(fontSize: 15, height: 1.7),
        ),
      ),
    );
  }
}
