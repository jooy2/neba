# neba_example

The gallery of Neba UI for Flutter. It shows every demo under `lib/demos/`, and built for the web it is what the documentation site embeds for each Flutter preview: `?demo=<component>/<case>` shows one demo alone, and `?theme=light` or `?theme=dark` pins the colour scheme.

```bash
flutter run -d chrome
```

`lib/demos/registry.dart` is generated. After adding a demo, run `dart run tool/generate.dart` in `packages/flutter`.
