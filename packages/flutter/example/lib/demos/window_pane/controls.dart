import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class WindowPaneControls extends StatefulWidget {
  const WindowPaneControls({super.key});

  @override
  State<WindowPaneControls> createState() => _WindowPaneControlsState();
}

class _WindowPaneControlsState extends State<WindowPaneControls> {
  bool _open = true;
  bool _minimized = false;
  bool _maximized = false;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        // The stage a maximized window fills: any Stack will do.
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
          child: Container(
            height: 256,
            color: tokens.roles(NebaColor.primary).soft,
            child: Stack(
              children: <Widget>[
                NebaWindowPane(
                  os: NebaWindowOs.windows11,
                  title: const Text('Terminal'),
                  position: NebaWindowPanePosition.absolute,
                  width: 280,
                  height: 180,
                  offset: const Offset(24, 24),
                  open: _open,
                  onOpenChange: (bool next) => setState(() => _open = next),
                  minimized: _minimized,
                  onMinimizedChange: (bool next) => setState(() => _minimized = next),
                  maximized: _maximized,
                  onMaximizedChange: (bool next) => setState(() => _maximized = next),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontFamily: NebaScale.monoFonts.first,
                      fontFamilyFallback: NebaScale.monoFonts.sublist(1),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(r'$ npm install neba'),
                          NebaTypography('added 1 package in 1.2s', color: NebaColor.secondary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            NebaButton(
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              onPressed: _open ? null : () => setState(() => _open = true),
              child: const Text('Reopen'),
            ),
            NebaButton(
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              onPressed: _minimized ? () => setState(() => _minimized = false) : null,
              child: const Text('Unroll'),
            ),
          ],
        ),
      ],
    );
  }
}
