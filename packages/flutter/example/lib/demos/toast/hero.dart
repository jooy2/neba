import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToastHero extends StatelessWidget {
  const ToastHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaToastProvider(child: _Raise());
  }
}

class _Raise extends StatelessWidget {
  const _Raise();

  @override
  Widget build(BuildContext context) {
    final NebaToastActions toast = NebaToastProvider.of(context);

    return NebaFlex(
      wrap: true,
      spacing: 2,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(
          size: NebaSize.sm,
          onPressed: () => toast.add(
            const NebaToastOptions(
              color: NebaColor.success,
              title: Text('Deployed'),
              description: Text('production · 4m 02s'),
            ),
          ),
          child: const Text('Deploy'),
        ),
        NebaButton(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          color: NebaColor.danger,
          onPressed: () => toast.add(
            const NebaToastOptions(
              color: NebaColor.danger,
              title: Text('Deploy failed'),
              description: Text('The build exited with code 1.'),
              timeout: Duration.zero,
              actionLabel: Text('Retry'),
            ),
          ),
          child: const Text('Fail a deploy'),
        ),
      ],
    );
  }
}
