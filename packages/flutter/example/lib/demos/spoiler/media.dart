import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SpoilerMedia extends StatelessWidget {
  const SpoilerMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaSpoiler(
        padded: false,
        label: const Text('Show the still'),
        description: const Text('The last shot'),
        child: Image.asset(
          'assets/samples/photos/misty-tea-terraces-sunrise.jpg',
          semanticLabel: 'Terraced tea fields under morning mist',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
