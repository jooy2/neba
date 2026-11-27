import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSelectOption<String>> _statuses = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'all', label: Text('Any status')),
  NebaSelectOption<String>(value: 'ready', label: Text('Ready')),
  NebaSelectOption<String>(value: 'building', label: Text('Building')),
  NebaSelectOption<String>(value: 'failed', label: Text('Failed')),
];

class PopoverForm extends StatefulWidget {
  const PopoverForm({super.key});

  @override
  State<PopoverForm> createState() => _PopoverFormState();
}

class _PopoverFormState extends State<PopoverForm> {
  String _status = 'failed';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaPopover(
          width: 300,
          trigger: NebaButton(
            onPressed: () {},
            variant: NebaVariant.outline,
            child: const Text('Filter deploys'),
          ),
          title: const Text('Filter'),
          description: const Text('Applied to the table behind this popup.'),
          child: NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 3,
            children: <Widget>[
              NebaTextField(
                size: NebaSize.sm,
                label: const Text('Commit'),
                placeholder: '8f2c1a',
                initialValue: _query,
                fullWidth: true,
                onChanged: (String value) => setState(() => _query = value),
              ),
              NebaSelect<String>(
                size: NebaSize.sm,
                label: const Text('Status'),
                value: _status,
                onValueChange: (String value) => setState(() => _status = value),
                items: _statuses,
                fullWidth: true,
              ),
              NebaFlex(
                spacing: 2,
                justifyContent: NebaJustifyContent.end,
                children: <Widget>[
                  NebaPopoverClose(
                    builder: (BuildContext context, VoidCallback close) => NebaButton(
                      size: NebaSize.sm,
                      variant: NebaVariant.text,
                      color: NebaColor.secondary,
                      onPressed: close,
                      child: const Text('Cancel'),
                    ),
                  ),
                  NebaPopoverClose(
                    builder: (BuildContext context, VoidCallback close) =>
                        NebaButton(size: NebaSize.sm, onPressed: close, child: const Text('Apply')),
                  ),
                ],
              ),
            ],
          ),
        ),
        NebaChip(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          color: NebaColor.secondary,
          child: Text('status: $_status'),
        ),
      ],
    );
  }
}
