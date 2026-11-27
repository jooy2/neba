import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MockupWallpaper extends StatelessWidget {
  const MockupWallpaper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        // oklch(62% 0.19 262) to oklch(48% 0.16 318), at 160 degrees.
        NebaMockup(
          device: NebaMockupDevice.mobile,
          width: 128,
          wallpaper: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.34, -0.94),
              end: Alignment(0.34, 0.94),
              colors: <Color>[Color(0xFF427FF7), Color(0xFF813897)],
            ),
          ),
        ),
        NebaMockup(
          device: NebaMockupDevice.mobile,
          width: 128,
          wallpaper: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/samples/photos/lighthouse-cliff-wildflowers.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        NebaMockup(
          device: NebaMockupDevice.desktop,
          hardware: NebaMockupHardware.laptop,
          width: 300,
          wallpaper: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/samples/photos/alpine-lake-dawn.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
