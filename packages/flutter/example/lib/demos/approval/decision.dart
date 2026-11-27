import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaApprovalOption> _options = <NebaApprovalOption>[
  NebaApprovalOption(value: 'once', label: Text('Allow once')),
  NebaApprovalOption(value: 'always', label: Text('Always allow')),
  NebaApprovalOption(value: 'deny', label: Text('Deny'), color: NebaColor.danger),
];

class ApprovalDecision extends StatefulWidget {
  const ApprovalDecision({super.key});

  @override
  State<ApprovalDecision> createState() => _ApprovalDecisionState();
}

class _ApprovalDecisionState extends State<ApprovalDecision> {
  String? _decision;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final String? decision = _decision;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          NebaApproval(
            risk: NebaApprovalRisk.medium,
            title: const Text('Send an email?'),
            details: const Text('to: team@example.com\nsubject: Weekly summary'),
            options: _options,
            controlled: true,
            decision: decision,
            onDecide: (String value) => setState(() => _decision = value),
          ),
          Row(
            spacing: 8,
            children: <Widget>[
              NebaButton(
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                onPressed: () => setState(() => _decision = null),
                child: const Text('Ask again'),
              ),
              Flexible(
                child: Text(
                  decision == null ? 'Waiting for an answer' : 'Sent back: $decision',
                  style: TextStyle(fontSize: 13, color: tokens.mutedFg),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
