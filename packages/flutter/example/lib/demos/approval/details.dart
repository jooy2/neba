import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ApprovalDetails extends StatefulWidget {
  const ApprovalDetails({super.key});

  @override
  State<ApprovalDetails> createState() => _ApprovalDetailsState();
}

class _ApprovalDetailsState extends State<ApprovalDetails> {
  double? _limit = 50;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaApproval(
        risk: NebaApprovalRisk.medium,
        title: const Text('Send the digest?'),
        description: const Text('Check the recipient before this goes out.'),
        options: const <NebaApprovalOption>[
          NebaApprovalOption(value: 'send', label: Text('Send'), variant: NebaVariant.solid),
          NebaApprovalOption(value: 'deny', label: Text('Not now')),
        ],
        details: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            const NebaTextField(
              size: NebaSize.sm,
              fullWidth: true,
              label: Text('To'),
              initialValue: 'team@example.com',
            ),
            NebaNumberField(
              size: NebaSize.sm,
              label: const Text('Rows'),
              value: _limit,
              onValueChange: (double? value) => setState(() => _limit = value),
              min: 1,
            ),
          ],
        ),
      ),
    );
  }
}
