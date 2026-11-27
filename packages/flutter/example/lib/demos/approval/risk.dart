import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(NebaApprovalRisk, String, String)> _requests = <(NebaApprovalRisk, String, String)>[
  (NebaApprovalRisk.low, 'Read a file?', 'read src/index.ts'),
  (NebaApprovalRisk.medium, 'Open a pull request?', 'gh pr create --fill'),
  (NebaApprovalRisk.high, 'Delete a branch?', 'git push origin --delete release/1.3'),
];

class ApprovalRisk extends StatelessWidget {
  const ApprovalRisk({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final (NebaApprovalRisk risk, String title, String details) in _requests)
            NebaApproval(
              size: NebaSize.sm,
              risk: risk,
              title: Text(title),
              details: Text(details),
              options: const <NebaApprovalOption>[
                NebaApprovalOption(value: 'allow', label: Text('Allow')),
                NebaApprovalOption(value: 'deny', label: Text('Deny')),
              ],
            ),
        ],
      ),
    );
  }
}
