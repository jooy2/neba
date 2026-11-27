import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CardForm extends StatelessWidget {
  const CardForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaCard(
        size: NebaSize.lg,
        dividers: true,
        title: Semantics(header: true, child: const Text('Invite a teammate')),
        subtitle: const Text('They will get an email with a link.'),
        footer: Row(
          children: <Widget>[
            NebaButton(
              onPressed: () {},
              variant: NebaVariant.text,
              color: NebaColor.secondary,
              child: const Text('Cancel'),
            ),
            const Spacer(),
            NebaButton(onPressed: () {}, child: const Text('Send invite')),
          ],
        ),
        child: const NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 3,
          children: <Widget>[
            NebaTextField(label: Text('Email'), placeholder: 'jane@example.com', fullWidth: true),
            NebaTextField(
              label: Text('Note'),
              multiline: true,
              rows: 2,
              placeholder: 'Optional',
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
