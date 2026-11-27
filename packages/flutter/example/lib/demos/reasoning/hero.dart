import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _thought = <String>[
  'The request is about a colour that changes at a breakpoint.',
  'Neither a class map nor a media query alone covers that, because Tailwind only sees literal '
      'class names.',
  'So the value has to reach CSS through an inline custom property, and the cascade has to be '
      'written once per slot.',
];

class ReasoningHero extends StatefulWidget {
  const ReasoningHero({super.key});

  @override
  State<ReasoningHero> createState() => _ReasoningHeroState();
}

class _ReasoningHeroState extends State<ReasoningHero> {
  int _lines = 1;
  Timer? _timer;

  bool get _streaming => _lines < _thought.length;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    if (!_streaming) {
      return;
    }

    _timer = Timer(const Duration(milliseconds: 1600), () {
      setState(() => _lines += 1);
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
      child: NebaReasoning(
        streaming: _streaming,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[for (final String line in _thought.take(_lines)) Text(line)],
        ),
      ),
    );
  }
}
