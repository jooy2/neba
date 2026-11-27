import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ApprovalHero extends StatelessWidget {
  const ApprovalHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaApproval(
        risk: NebaApprovalRisk.high,
        title: Text('Run a shell command?'),
        description: Text('The assistant wants to remove the build output before rebuilding.'),
        details: Text('rm -rf ./dist\nnpm run build'),
        options: <NebaApprovalOption>[
          NebaApprovalOption(
            value: 'once',
            label: Text('Allow once'),
            description: Text('Just this command'),
          ),
          NebaApprovalOption(
            value: 'always',
            label: Text('Always allow'),
            description: Text('Every shell command in this session'),
          ),
          NebaApprovalOption(value: 'deny', label: Text('Deny'), color: NebaColor.danger),
        ],
      ),
    );
  }
}
