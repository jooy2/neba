import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DialogControlled extends StatefulWidget {
  const DialogControlled({super.key});

  @override
  State<DialogControlled> createState() => _DialogControlledState();
}

class _DialogControlledState extends State<DialogControlled> {
  bool _open = false;
  String _name = '';

  @override
  Widget build(BuildContext context) {
    final bool confirmed = _name == 'neba';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _open = true),
          color: NebaColor.danger,
          child: const Text('Delete project'),
        ),
        // Not dismissible: no Escape, no press outside. A dialog that has to
        // be answered needs actions that answer it, and this one has both.
        NebaDialog(
          open: _open,
          onOpenChange: (bool open) => setState(() => _open = open),
          dismissible: false,
          showClose: false,
          size: NebaSize.sm,
          color: NebaColor.danger,
          title: const Text('Type the project name'),
          description: const Text('This is the last step before it is gone.'),
          actions: <Widget>[
            NebaButton(
              onPressed: () => setState(() => _open = false),
              variant: NebaVariant.text,
              color: NebaColor.secondary,
              child: const Text('Cancel'),
            ),
            NebaButton(
              onPressed: confirmed ? () => setState(() => _open = false) : null,
              color: NebaColor.danger,
              child: const Text('Delete'),
            ),
          ],
          child: NebaTextField(
            fullWidth: true,
            label: const Text('Project name'),
            placeholder: 'neba',
            onChanged: (String value) => setState(() => _name = value),
          ),
        ),
      ],
    );
  }
}
