import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToastAction extends StatelessWidget {
  const ToastAction({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaToastProvider(position: NebaToastPosition.bottomCenter, child: _Raise());
  }
}

class _Raise extends StatelessWidget {
  const _Raise();

  @override
  Widget build(BuildContext context) {
    final NebaToastActions toast = NebaToastProvider.of(context);

    void remove() {
      late final String id;
      id = toast.add(
        NebaToastOptions(
          color: NebaColor.secondary,
          title: const Text('Deleted “Q3 forecast”'),
          timeout: Duration.zero,
          actionLabel: const Text('Undo'),
          onAction: () => toast.close(id),
        ),
      );
    }

    void upload() {
      unawaited(
        toast.promise<void>(
          Future<void>.delayed(const Duration(milliseconds: 1600)),
          loading: const NebaToastOptions(title: Text('Uploading…'), showIcon: false),
          success: (void _) =>
              const NebaToastOptions(color: NebaColor.success, title: Text('Uploaded')),
          error: (Object _) =>
              const NebaToastOptions(color: NebaColor.danger, title: Text('Upload failed')),
        ),
      );
    }

    return NebaFlex(
      wrap: true,
      spacing: 2,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          color: NebaColor.secondary,
          onPressed: remove,
          child: const Text('Delete something'),
        ),
        NebaButton(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          onPressed: upload,
          child: const Text('Upload a file'),
        ),
      ],
    );
  }
}
