import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The two sample screens the demos put on their devices, each on its own
/// device. In an app this would be your own page, or a picture of one.
class MockupScreen extends StatelessWidget {
  const MockupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        NebaMockup(device: NebaMockupDevice.mobile, width: 140, child: MockupPhoneScreen()),
        NebaMockup(device: NebaMockupDevice.desktop, width: 300, child: MockupDesktopScreen()),
      ],
    );
  }
}

/// A row of mockups that wraps, each with a muted name over it.
class MockupLabels extends StatelessWidget {
  const MockupLabels(this.items, {super.key});

  final List<(String, Widget)> items;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 20,
      runSpacing: 20,
      children: <Widget>[
        for (final (String label, Widget mockup) in items)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              Text(label, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
              mockup,
            ],
          ),
      ],
    );
  }
}

/// The phone's screen, written at the 390 pixels a phone gives it.
class MockupPhoneScreen extends StatelessWidget {
  const MockupPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          const Row(
            spacing: 12,
            children: <Widget>[
              NebaAvatar(name: 'Ada Park'),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    NebaTypography('Good morning', weight: FontWeight.w600),
                    NebaTypography(
                      'Three deploys waiting',
                      level: NebaTypographyLevel.caption,
                      color: NebaColor.secondary,
                    ),
                  ],
                ),
              ),
              NebaChip(size: NebaSize.xs, color: NebaColor.success, child: Text('On track')),
            ],
          ),
          const NebaCard(
            size: NebaSize.sm,
            title: Text('Build minutes'),
            subtitle: Text('Resets in 6 days'),
            child: NebaProgressLinear(
              size: NebaSize.sm,
              value: 72,
              label: Text('Used this month'),
              showValue: true,
            ),
          ),
          const NebaCard(
            size: NebaSize.sm,
            dividers: true,
            child: Column(
              spacing: 8,
              children: <Widget>[
                _Service('api-gateway', 'Live', NebaColor.success),
                _Service('web-storefront', 'Building', NebaColor.info),
              ],
            ),
          ),
          const Spacer(),
          NebaButton(onPressed: () {}, fullWidth: true, child: const Text('Start a deploy')),
        ],
      ),
    );
  }
}

class _Service extends StatelessWidget {
  const _Service(this.name, this.status, this.color);

  final String name;
  final String status;
  final NebaColor color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        NebaTypography(name, level: NebaTypographyLevel.caption),
        NebaChip(size: NebaSize.xs, variant: NebaVariant.text, color: color, child: Text(status)),
      ],
    );
  }
}

/// The desktop's screen, written at the 1440 pixels a desktop gives it.
class MockupDesktopScreen extends StatelessWidget {
  const MockupDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          Row(
            spacing: 16,
            children: <Widget>[
              const NebaTypography('Overview', level: NebaTypographyLevel.h4),
              const NebaChip(
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                color: NebaColor.secondary,
                child: Text('Production'),
              ),
              const Spacer(),
              NebaButton(variant: NebaVariant.text, onPressed: () {}, child: const Text('Logs')),
              NebaButton(onPressed: () {}, child: const Text('Deploy')),
            ],
          ),
          const NebaDivider(),
          const Row(
            spacing: 16,
            children: <Widget>[
              Expanded(
                child: NebaCard(
                  child: NebaStatistic(
                    label: Text('Requests'),
                    value: 1284000,
                    previousValue: 1120000,
                  ),
                ),
              ),
              Expanded(
                child: NebaCard(
                  child: NebaStatistic(
                    label: Text('Error rate'),
                    value: 0.42,
                    previousValue: 0.71,
                    betterWhen: NebaStatisticBetterWhen.down,
                  ),
                ),
              ),
              Expanded(
                child: NebaCard(
                  child: NebaStatistic(
                    label: Text('p95 latency'),
                    value: 186,
                    unit: Text('ms'),
                    previousValue: 204,
                    betterWhen: NebaStatisticBetterWhen.down,
                  ),
                ),
              ),
            ],
          ),
          const Expanded(
            child: NebaCard(
              title: Text('Rollout'),
              subtitle: Text('web-storefront · 4 of 6 regions'),
              child: NebaProgressLinear(value: 66, label: Text('Regions updated'), showValue: true),
            ),
          ),
        ],
      ),
    );
  }
}
