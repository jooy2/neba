import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

// A marketing page for a product that does not exist, built out of Neba
// widgets and nothing else: the Flutter twin of the documentation's landing
// concept. The copy stays in English, as the React page's does.

const String _logo = 'M8 1.5 14 5v6l-6 3.5L2 11V5l6-3.5Z M8 8v6.5M8 8l6-3M8 8 2 5';
const String _bolt = 'M9 1.5 3.5 9H8l-1 5.5L12.5 7H8l1-5.5Z';
const String _shield =
    'M8 1.75 13 3.5v4.25c0 3-2.1 5.2-5 6.5-2.9-1.3-5-3.5-5-6.5V3.5L8 1.75Z '
    'm5.75 7.75 1.75 1.75L10.5 6.5';
const String _graph = 'M2.5 13.5h11 M3.5 10.5 6.5 7l2.5 2.5 4-5.5';
const String _plug =
    'M6 1.5v3.5M10 1.5v3.5 M4 5h8v2.5A4 4 0 0 1 8 11.5 4 4 0 0 1 4 7.5V5Z M8 11.5v3';
const String _check = 'm3.5 8.5 3 3 6-7';
const String _arrow = 'M3.5 8h9m-3.5-4 4 4-4 4';
const String _github =
    'M8 .5a7.5 7.5 0 0 0-2.37 14.62c.37.07.5-.16.5-.36v-1.3c-2.09.46-2.53-1-2.53-1-.34-.87-.83'
    '-1.1-.83-1.1-.68-.47.05-.46.05-.46.75.05 1.15.78 1.15.78.67 1.15 1.76.82 2.19.63.07-.49.26'
    '-.82.48-1.01-1.67-.19-3.42-.84-3.42-3.72 0-.82.29-1.5.77-2.02-.08-.19-.34-.95.07-1.98 0 0 .63'
    '-.2 2.06.77a7.1 7.1 0 0 1 3.75 0c1.43-.97 2.06-.77 2.06-.77.41 1.03.15 1.79.08 1.98.48.52.77'
    ' 1.2.77 2.02 0 2.89-1.76 3.53-3.43 3.71.27.24.51.69.51 1.39v2.06c0 .2.13.44.51.36A7.5 7.5 0 0'
    ' 0 8 .5Z';

const List<String> _nav = <String>['Product', 'Integrations', 'Docs', 'Pricing'];

const List<(String, String)> _trustedBy = <(String, String)>[
  ('Northwind', 'compass'),
  ('Acme Rail', 'bridge'),
  ('Kite & Co', 'kite'),
  ('Belltower', 'bell'),
  ('Ordinary Coffee', 'seed-pod'),
];

const List<(String, String)> _team = <(String, String)>[
  ('Anya Sol', 'anya-sol'),
  ('Theo Quinn', 'theo-quinn'),
  ('Lucas Adebayo', 'lucas-adebayo'),
  ('Nadia Rowan', 'nadia-rowan'),
];

typedef _Feature = ({String icon, NebaColor color, String title, String body});

const List<_Feature> _features = <_Feature>[
  (
    icon: _bolt,
    color: NebaColor.primary,
    title: 'Answers in one second',
    body:
        'Queries run against a columnar store built for the shape of product data, so a funnel '
        'over a year of events comes back before you look away.',
  ),
  (
    icon: _graph,
    color: NebaColor.info,
    title: 'Funnels without SQL',
    body:
        'Pick the steps, set the window, read the drop-off. Every chart keeps the query that made '
        'it, so anyone can open it up and change one step.',
  ),
  (
    icon: _shield,
    color: NebaColor.success,
    title: 'Yours, and only yours',
    body:
        'SOC 2 Type II, per-region storage and a retention window you set. No third-party pixels, '
        'no reselling, no exceptions.',
  ),
  (
    icon: _plug,
    color: NebaColor.secondary,
    title: 'Wired up in an afternoon',
    body:
        'SDKs for the six runtimes you actually ship, a warehouse sync both ways, and an HTTP '
        'endpoint for everything else.',
  ),
];

typedef _Stat = ({
  String label,
  Object value,
  String? unit,
  num? previousValue,
  NebaStatisticBetterWhen betterWhen,
  String caption,
});

const List<_Stat> _stats = <_Stat>[
  (
    label: 'Events ingested daily',
    value: 4.2,
    unit: 'B',
    previousValue: 3.1,
    betterWhen: NebaStatisticBetterWhen.up,
    caption: 'vs. last year',
  ),
  (
    label: 'Median query time',
    value: 240,
    unit: 'ms',
    previousValue: 410,
    betterWhen: NebaStatisticBetterWhen.down,
    caption: 'vs. last year',
  ),
  (
    label: 'Teams on board',
    value: 12400,
    unit: null,
    previousValue: 9800,
    betterWhen: NebaStatisticBetterWhen.up,
    caption: 'vs. last year',
  ),
  (
    label: 'Uptime, trailing year',
    value: '99.98%',
    unit: null,
    previousValue: null,
    betterWhen: NebaStatisticBetterWhen.up,
    caption: 'Measured externally',
  ),
];

/// A cell of the comparison table: words, or included or not.
typedef _Cell = Object;

const Object _yes = true;
const Object _no = false;

typedef _PlanRow = ({String id, String feature, _Cell free, _Cell team, _Cell scale});

const List<_PlanRow> _planRows = <_PlanRow>[
  (id: 'events', feature: 'Monthly events', free: '50k', team: '5M', scale: 'Unlimited'),
  (id: 'retention', feature: 'Retention', free: '30 days', team: '2 years', scale: 'Custom'),
  (id: 'seats', feature: 'Seats', free: '3', team: 'Unlimited', scale: 'Unlimited'),
  (id: 'warehouse', feature: 'Warehouse sync', free: _no, team: _yes, scale: _yes),
  (id: 'sso', feature: 'SAML SSO', free: _no, team: _no, scale: _yes),
  (id: 'sla', feature: 'Support SLA', free: _no, team: 'Next business day', scale: '1 hour'),
];

typedef _Plan = ({
  String id,
  String name,
  int monthly,
  String tagline,
  List<String> features,
  bool featured,
});

const List<_Plan> _plans = <_Plan>[
  (
    id: 'free',
    name: 'Free',
    monthly: 0,
    tagline: 'For the first prototype.',
    features: <String>['50k events a month', '3 seats', '30-day retention', 'Community support'],
    featured: false,
  ),
  (
    id: 'team',
    name: 'Team',
    monthly: 49,
    tagline: 'For a product with users.',
    features: <String>[
      '5M events a month',
      'Unlimited seats',
      '2-year retention',
      'Warehouse sync both ways',
    ],
    featured: true,
  ),
  (
    id: 'scale',
    name: 'Scale',
    monthly: 199,
    tagline: 'For a product with customers.',
    features: <String>[
      'Unlimited events',
      'SAML SSO and SCIM',
      'Custom retention',
      '1-hour support SLA',
    ],
    featured: false,
  ),
];

const List<(String, String, String)> _faq = <(String, String, String)>[
  (
    'migrate',
    'Can we bring our existing events with us?',
    'Yes. Point the importer at an S3 prefix or a warehouse table and it backfills in the '
        'background; the workspace stays usable while it runs.',
  ),
  (
    'sampling',
    'Do you sample?',
    'Never on ingest. Every event you send is stored and queryable. Sampling is something you '
        'can turn on per query when you want a faster answer to a rough question.',
  ),
  (
    'self-host',
    'Is there a self-hosted option?',
    'On the Scale plan. It runs on your own Kubernetes cluster and object storage, and updates '
        'on the same weekly train as the hosted build.',
  ),
  (
    'leaving',
    'What happens to our data if we leave?',
    'A full export in Parquet, on demand, at any point, including after the account is closed. '
        'There is no lock-in worth having.',
  ),
];

const List<(String, List<String>)> _footer = <(String, List<String>)>[
  ('Product', <String>['Overview', 'Funnels', 'Cohorts', 'Warehouse sync', 'Changelog']),
  ('Developers', <String>['Documentation', 'SDKs', 'HTTP API', 'Status']),
  ('Company', <String>['About', 'Careers', 'Blog', 'Security', 'Contact']),
];

class ConceptsLanding extends StatefulWidget {
  const ConceptsLanding({super.key});

  @override
  State<ConceptsLanding> createState() => _ConceptsLandingState();
}

class _ConceptsLandingState extends State<ConceptsLanding> {
  bool _yearly = true;
  String _email = '';
  bool _signedUp = false;

  static final RegExp _address = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool get _emailValid => _address.hasMatch(_email);

  int _price(int monthly) => _yearly ? (monthly * 0.8).round() : monthly;

  void _submit() {
    if (_emailValid) {
      setState(() => _signedUp = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // From the `md` breakpoint up, the page lays out as it does on a desktop.
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // The announcement bar: the one live-ish readout above the fold.
        Center(
          child: NebaPill(
            color: NebaColor.primary,
            variant: NebaVariant.text,
            size: NebaSize.sm,
            startIcon: const _Glyph(_bolt),
            title: const Text('Kestrel 2.0: funnels, retention and paths in one query'),
            endIcon: const _Glyph(_arrow),
            onPressed: () {},
          ),
        ),
        NebaContainer(
          maxWidth: const NebaMeasure.size(NebaSize.xl),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 64,
              children: <Widget>[
                _header(wide),
                _hero(wide),
                _trust(),
                _numbers(wide),
                _featureCards(wide),
                _tour(),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: const NebaBlockquote(
                      variant: NebaVariant.outline,
                      size: NebaSize.lg,
                      author: Text('Mira Osei'),
                      source: Text('Head of Product, Belltower'),
                      child: Text(
                        'We replaced two dashboards and a weekly export with one saved query. '
                        'The part nobody expected is that support now answers their own '
                        'questions.',
                      ),
                    ),
                  ),
                ),
                _pricing(wide),
                _questions(),
                _closing(),
                _pageFooter(wide),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(bool wide) {
    return NebaToolbar(
      variant: NebaVariant.text,
      density: NebaDensity.compact,
      start: const <Widget>[
        NebaIcon(
          icon: _Glyph(_logo),
          size: NebaSize.lg,
          color: NebaColor.primary,
          semanticLabel: 'Kestrel',
        ),
      ],
      end: <Widget>[
        if (wide) ...<Widget>[
          NebaTooltip(
            content: const Text('Star us on GitHub'),
            child: NebaIconButton(
              onPressed: () {},
              icon: const _Glyph(_github, filled: true),
              label: 'GitHub',
              size: NebaSize.sm,
              variant: NebaVariant.text,
              color: NebaColor.secondary,
            ),
          ),
          NebaButton(
            onPressed: () {},
            size: NebaSize.sm,
            variant: NebaVariant.text,
            color: NebaColor.secondary,
            child: const Text('Sign in'),
          ),
        ],
        NebaButton(
          onPressed: () {},
          size: NebaSize.sm,
          endIcon: wide ? const _Glyph(_arrow) : null,
          child: const Text('Start free'),
        ),
      ],
      // The name and the links share what the actions leave, the links
      // scrolling sideways rather than running under them.
      children: <Widget>[
        const NebaTypography('Kestrel', level: NebaTypographyLevel.h6),
        if (wide)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: Row(
                  spacing: 4,
                  children: <Widget>[
                    for (final String item in _nav)
                      NebaButton(
                        onPressed: () {},
                        size: NebaSize.sm,
                        variant: NebaVariant.text,
                        color: NebaColor.secondary,
                        child: Text(item),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _hero(bool wide) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        spacing: 20,
        children: <Widget>[
          const NebaChip(
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            color: NebaColor.primary,
            startIcon: _Glyph(_bolt),
            child: Text('Now with warehouse sync'),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: const NebaTypography(
              'Product analytics that answer back',
              level: NebaTypographyLevel.h1,
              align: TextAlign.center,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: NebaHighlight.terms(
              query: const <String>['one second', 'without SQL'],
              child: NebaTypography(
                'Kestrel keeps every event you send and answers questions about them in one '
                'second, without SQL and without a data team standing between you and the '
                'number.',
                level: NebaTypographyLevel.lead,
                align: TextAlign.center,
                style: TextStyle(color: tokens.mutedFg),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              NebaButton(
                onPressed: () {},
                size: wide ? NebaSize.lg : NebaSize.md,
                endIcon: const _Glyph(_arrow),
                child: const Text('Start free'),
              ),
              NebaButton(
                onPressed: () {},
                size: wide ? NebaSize.lg : NebaSize.md,
                variant: NebaVariant.outline,
                color: NebaColor.secondary,
                child: const Text('Book a walkthrough'),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              _Faces(ring: tokens.surface),
              const NebaTypography(
                '12,400 teams, no credit card',
                level: NebaTypographyLevel.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trust() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: <Widget>[
        const NebaDivider(
          size: NebaSize.sm,
          child: NebaTypography('Trusted by', level: NebaTypographyLevel.overline),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 32,
          runSpacing: 12,
          children: <Widget>[
            for (final (String name, String file) in _trustedBy)
              NebaAppLogo(
                name: name,
                image: AssetImage('assets/samples/logos/$file.png'),
                showName: true,
                color: NebaColor.secondary,
              ),
          ],
        ),
      ],
    );
  }

  Widget _numbers(bool wide) {
    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        for (final _Stat stat in _stats)
          NebaGrid(
            span: NebaGridSpan.columns(wide ? 3 : 6),
            child: NebaStatistic(
              label: Text(stat.label),
              value: stat.value,
              unit: stat.unit == null ? null : Text(stat.unit!),
              previousValue: stat.previousValue,
              betterWhen: stat.betterWhen,
              caption: Text(stat.caption),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeading(String overline, String heading) {
    return Column(
      spacing: 8,
      children: <Widget>[
        NebaTypography(overline, level: NebaTypographyLevel.overline, color: NebaColor.primary),
        NebaTypography(heading, level: NebaTypographyLevel.h2, align: TextAlign.center),
      ],
    );
  }

  Widget _featureCards(bool wide) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: <Widget>[
        _sectionHeading('Why Kestrel', 'Everything the question needs, nothing it does not'),
        NebaGridContainer(
          spacing: 3,
          padded: false,
          children: <Widget>[
            for (final _Feature feature in _features)
              NebaGrid(
                span: NebaGridSpan.columns(wide ? 6 : 12),
                child: NebaCard(
                  variant: NebaVariant.outline,
                  title: Text(feature.title),
                  headerAction: NebaIcon(
                    icon: _Glyph(feature.icon),
                    size: NebaSize.lg,
                    color: feature.color,
                  ),
                  child: NebaTypography(feature.body, style: TextStyle(color: tokens.mutedFg)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tour() {
    Widget steps(List<(String, double)> rows, NebaColor color) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final (String label, double value) in rows)
            NebaProgressLinear(value: value, label: Text(label), showValue: true, color: color),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: <Widget>[
        _sectionHeading('A look inside', 'The same events, asked three ways'),
        NebaTabs<String>(
          defaultValue: 'funnels',
          size: NebaSize.sm,
          children: <Widget>[
            const NebaTab<String>(value: 'funnels', child: Text('Funnels')),
            const NebaTab<String>(value: 'retention', child: Text('Retention')),
            const NebaTab<String>(value: 'paths', child: Text('Paths')),
            NebaTabPanel<String>(
              value: 'funnels',
              child: NebaCard(
                variant: NebaVariant.solid,
                title: const Text('Signup to first query'),
                subtitle: const Text('Last 30 days'),
                child: steps(const <(String, double)>[
                  ('Visited pricing · 38,204', 100),
                  ('Created account · 15,663', 41),
                  ('Sent first event · 9,932', 26),
                  ('Ran first query · 7,258', 19),
                ], NebaColor.primary),
              ),
            ),
            NebaTabPanel<String>(
              value: 'retention',
              child: NebaCard(
                variant: NebaVariant.solid,
                title: const Text('Weekly retention'),
                subtitle: const Text('Cohorts by signup week'),
                child: steps(const <(String, double)>[
                  ('Week 1', 100),
                  ('Week 2', 62),
                  ('Week 4', 48),
                  ('Week 8', 44),
                ], NebaColor.success),
              ),
            ),
            const NebaTabPanel<String>(
              value: 'paths',
              child: NebaCard(
                variant: NebaVariant.solid,
                title: Text('Where people go next'),
                subtitle: Text('After the first query'),
                child: NebaList(
                  variant: NebaVariant.text,
                  size: NebaSize.sm,
                  dividers: true,
                  children: <Widget>[
                    NebaListItem(
                      description: Text('34% of sessions'),
                      action: NebaChip(
                        size: NebaSize.xs,
                        variant: NebaVariant.text,
                        color: NebaColor.success,
                        child: Text('Saved'),
                      ),
                      child: Text('Saved the query to a dashboard'),
                    ),
                    NebaListItem(
                      description: Text('28% of sessions'),
                      action: NebaChip(
                        size: NebaSize.xs,
                        variant: NebaVariant.text,
                        color: NebaColor.info,
                        child: Text('Shared'),
                      ),
                      child: Text('Invited a teammate'),
                    ),
                    NebaListItem(
                      description: Text('19% of sessions'),
                      action: NebaChip(
                        size: NebaSize.xs,
                        variant: NebaVariant.text,
                        color: NebaColor.warning,
                        child: Text('Dropped'),
                      ),
                      child: Text('Left without saving'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pricing(bool wide) {
    final NebaTokens tokens = NebaTheme.of(context);

    Widget cell(_Cell value) {
      return switch (value) {
        true => const NebaIcon(
          icon: _Glyph(_check, width: 1.75),
          size: NebaSize.sm,
          color: NebaColor.success,
          semanticLabel: 'Included',
        ),
        false => const NebaTypography('—', level: NebaTypographyLevel.caption),
        _ => Text('$value'),
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: <Widget>[
        Column(
          spacing: 12,
          children: <Widget>[
            _sectionHeading('Pricing', 'Priced by events, not by seats'),
            NebaSegmentedButton<String>(
              size: NebaSize.sm,
              semanticLabel: 'Billing period',
              value: _yearly ? 'yearly' : 'monthly',
              onValueChange: (String? value) => setState(() => _yearly = value == 'yearly'),
              children: const <NebaSegment<String>>[
                NebaSegment<String>(value: 'monthly', child: Text('Monthly')),
                NebaSegment<String>(value: 'yearly', child: Text('Yearly · save 20%')),
              ],
            ),
          ],
        ),
        NebaGridContainer(
          spacing: 3,
          padded: false,
          children: <Widget>[
            for (final _Plan plan in _plans)
              NebaGrid(
                span: NebaGridSpan.columns(wide ? 4 : 12),
                child: NebaCard(
                  variant: plan.featured ? NebaVariant.solid : NebaVariant.outline,
                  color: plan.featured ? NebaColor.primary : NebaColor.secondary,
                  elevation: plan.featured ? 2 : 0,
                  title: Text(plan.name),
                  subtitle: Text(plan.tagline),
                  headerAction: plan.featured
                      ? const NebaChip(
                          size: NebaSize.xs,
                          variant: NebaVariant.solid,
                          color: NebaColor.primary,
                          child: Text('Most picked'),
                        )
                      : null,
                  footer: NebaButton(
                    onPressed: () {},
                    fullWidth: true,
                    color: plan.featured ? NebaColor.primary : NebaColor.secondary,
                    variant: plan.featured ? NebaVariant.solid : NebaVariant.outline,
                    child: Text(plan.monthly == 0 ? 'Start free' : 'Choose ${plan.name}'),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 4,
                        children: <Widget>[
                          NebaTypography(
                            '\$${_price(plan.monthly)}',
                            level: NebaTypographyLevel.h2,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: NebaTypography(
                              '/ month',
                              level: NebaTypographyLevel.caption,
                              style: TextStyle(color: tokens.mutedFg),
                            ),
                          ),
                        ],
                      ),
                      NebaList(
                        variant: NebaVariant.text,
                        size: NebaSize.sm,
                        density: NebaDensity.compact,
                        children: <Widget>[
                          for (final String feature in plan.features)
                            NebaListItem(
                              startIcon: NebaIcon(
                                icon: const _Glyph(_check, width: 1.75),
                                size: NebaSize.sm,
                                color: plan.featured ? NebaColor.primary : NebaColor.success,
                              ),
                              child: Text(feature),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        // The comparison table, drawn from one column list so the headings
        // and the cells cannot drift apart. A phone scrolls it sideways.
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth < 660 ? 660 : constraints.maxWidth,
                child: NebaTable<_PlanRow>(
                  size: NebaSize.sm,
                  hoverable: true,
                  rowKey: (_PlanRow row, int index) => ValueKey<String>(row.id),
                  items: _planRows,
                  headers: <NebaTableColumn<_PlanRow>>[
                    NebaTableColumn<_PlanRow>(
                      key: 'feature',
                      label: const SizedBox.shrink(),
                      width: 220,
                      builder: (BuildContext context, _PlanRow row, int index) => Text(row.feature),
                    ),
                    NebaTableColumn<_PlanRow>(
                      key: 'free',
                      label: const Text('Free'),
                      align: NebaAlign.center,
                      width: 120,
                      builder: (BuildContext context, _PlanRow row, int index) => cell(row.free),
                    ),
                    NebaTableColumn<_PlanRow>(
                      key: 'team',
                      label: const Text('Team'),
                      align: NebaAlign.center,
                      width: 160,
                      builder: (BuildContext context, _PlanRow row, int index) => cell(row.team),
                    ),
                    NebaTableColumn<_PlanRow>(
                      key: 'scale',
                      label: const Text('Scale'),
                      align: NebaAlign.center,
                      width: 160,
                      builder: (BuildContext context, _PlanRow row, int index) => cell(row.scale),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _questions() {
    return Column(
      spacing: 24,
      children: <Widget>[
        const NebaTypography(
          'Questions people ask first',
          level: NebaTypographyLevel.h2,
          align: TextAlign.center,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: NebaAccordion<String>(
            variant: NebaVariant.outline,
            children: <NebaAccordionItem<String>>[
              for (final (String value, String title, String body) in _faq)
                NebaAccordionItem<String>(value: value, title: Text(title), child: Text(body)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _closing() {
    final NebaTokens tokens = NebaTheme.of(context);
    final String? error = _email.isEmpty || _emailValid ? null : 'Enter a valid address.';

    return NebaCard(
      variant: NebaVariant.solid,
      color: NebaColor.primary,
      elevation: 2,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 704),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              spacing: 16,
              children: <Widget>[
                const NebaTypography(
                  'Send your first event today',
                  level: NebaTypographyLevel.h2,
                  align: TextAlign.center,
                ),
                NebaTypography(
                  'The free plan does not expire and does not ask for a card. Most teams have a '
                  'funnel on screen inside an hour.',
                  align: TextAlign.center,
                  style: TextStyle(color: tokens.mutedFg),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 280,
                        child: NebaTextField(
                          placeholder: 'you@company.com',
                          semanticLabel: 'Work email',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
                          textInputAction: TextInputAction.send,
                          fullWidth: true,
                          error: error == null ? null : Text(error),
                          onChanged: (String value) => setState(() => _email = value),
                          onSubmitted: (String _) => _submit(),
                        ),
                      ),
                      NebaButton(
                        onPressed: _submit,
                        endIcon: const _Glyph(_arrow),
                        child: Text(_signedUp ? 'Check your inbox' : 'Start free'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageFooter(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: <Widget>[
        const NebaDivider(),
        NebaGridContainer(
          spacing: 3,
          padded: false,
          children: <Widget>[
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 3 : 12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  Row(
                    spacing: 8,
                    children: <Widget>[
                      NebaIcon(
                        icon: _Glyph(_logo),
                        color: NebaColor.primary,
                        semanticLabel: 'Kestrel',
                      ),
                      NebaTypography('Kestrel', level: NebaTypographyLevel.h6),
                    ],
                  ),
                  NebaTypography(
                    'Product analytics for teams who would rather read the answer than write '
                    'the query.',
                    level: NebaTypographyLevel.caption,
                  ),
                ],
              ),
            ),
            for (final (String heading, List<String> links) in _footer)
              NebaGrid(
                span: NebaGridSpan.columns(wide ? 3 : 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: <Widget>[
                    NebaTypography(heading, level: NebaTypographyLevel.overline),
                    NebaList(
                      variant: NebaVariant.text,
                      size: NebaSize.sm,
                      density: NebaDensity.compact,
                      children: <Widget>[
                        for (final String link in links)
                          NebaListItem(onPressed: () {}, child: Text(link)),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        const NebaDivider(),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            const NebaTypography(
              '© 2026 Kestrel Analytics. A fictional product, built out of Neba components.',
              level: NebaTypographyLevel.caption,
            ),
            Wrap(
              spacing: 4,
              children: <Widget>[
                for (final String link in const <String>['Privacy', 'Terms', 'Status'])
                  NebaButton(
                    onPressed: () {},
                    size: NebaSize.xs,
                    variant: NebaVariant.text,
                    color: NebaColor.secondary,
                    child: Text(link),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The team's faces, each overlapping the one before it by a quarter and
/// ringed in the page's own colour.
class _Faces extends StatelessWidget {
  const _Faces({required this.ring});

  final Color ring;

  @override
  Widget build(BuildContext context) {
    const double face = 32;
    const double step = face - 8;

    return SizedBox(
      width: step * (_team.length - 1) + face + 4,
      height: face + 4,
      child: Stack(
        children: <Widget>[
          for (int index = 0; index < _team.length; index++)
            PositionedDirectional(
              start: step * index,
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ring),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: NebaAvatar(
                    size: NebaSize.sm,
                    name: _team[index].$1,
                    image: AssetImage('assets/samples/people/${_team[index].$2}.jpg'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A 16-unit glyph from SVG path data, stroked or filled in the icon colour
/// at the icon size the widget around it hands down.
class _Glyph extends StatelessWidget {
  const _Glyph(this.data, {this.filled = false, this.width = 1.5});

  final String data;
  final bool filled;
  final double width;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(
        painter: _GlyphPainter(
          path: _parse(data),
          color: icon.color ?? const Color(0xFF000000),
          filled: filled,
          width: width,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter({
    required this.path,
    required this.color,
    required this.filled,
    required this.width,
  });

  final Path path;
  final Color color;
  final bool filled;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.shortestSide / 16)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.path != path;
  }
}

final Map<String, Path> _parsed = <String, Path>{};

/// The SVG path commands the glyphs above use, absolute and relative: move,
/// line, horizontal, vertical, cubic, smooth cubic, arc and close.
Path _parse(String data) {
  return _parsed.putIfAbsent(data, () {
    final Path path = Path();
    final Iterable<RegExpMatch> tokens = RegExp(
      r'[MmLlHhVvCcSsAaZz]|-?(?:\d*\.\d+|\d+\.?)(?:e-?\d+)?',
    ).allMatches(data);
    final List<String> parts = <String>[for (final RegExpMatch token in tokens) token[0]!];
    int at = 0;
    String command = 'M';
    Offset point = Offset.zero;
    Offset start = Offset.zero;
    Offset? control;

    bool isCommand(String part) => RegExp(r'^[A-Za-z]$').hasMatch(part);
    double next() => double.parse(parts[at++]);
    // An arc's flags may be written run together, as `0 0 1` or `001`.
    bool flag() {
      final String part = parts[at];

      if (part.length > 1 && (part.startsWith('0') || part.startsWith('1'))) {
        parts[at] = part.substring(1);
        return part.startsWith('1');
      }

      at++;
      return part == '1';
    }

    while (at < parts.length) {
      if (isCommand(parts[at])) {
        command = parts[at++];
      }

      final bool relative = command == command.toLowerCase();
      final Offset base = relative ? point : Offset.zero;

      switch (command.toUpperCase()) {
        case 'M':
          point = base + Offset(next(), next());
          start = point;
          path.moveTo(point.dx, point.dy);
          // Further pairs after a move are lines.
          command = relative ? 'l' : 'L';
          control = null;
        case 'L':
          point = base + Offset(next(), next());
          path.lineTo(point.dx, point.dy);
          control = null;
        case 'H':
          point = Offset((relative ? point.dx : 0) + next(), point.dy);
          path.lineTo(point.dx, point.dy);
          control = null;
        case 'V':
          point = Offset(point.dx, (relative ? point.dy : 0) + next());
          path.lineTo(point.dx, point.dy);
          control = null;
        case 'C':
          final Offset first = base + Offset(next(), next());
          final Offset second = base + Offset(next(), next());
          point = base + Offset(next(), next());
          path.cubicTo(first.dx, first.dy, second.dx, second.dy, point.dx, point.dy);
          control = second;
        case 'S':
          final Offset reflected = control == null ? point : point * 2 - control;
          final Offset second = base + Offset(next(), next());
          point = base + Offset(next(), next());
          path.cubicTo(reflected.dx, reflected.dy, second.dx, second.dy, point.dx, point.dy);
          control = second;
        case 'A':
          final double rx = next();
          final double ry = next();
          final double rotation = next();
          final bool large = flag();
          final bool sweep = flag();
          point = base + Offset(next(), next());
          path.arcToPoint(
            point,
            radius: Radius.elliptical(rx, ry),
            rotation: rotation,
            largeArc: large,
            clockwise: sweep,
          );
          control = null;
        case 'Z':
          path.close();
          point = start;
          control = null;
        default:
          at++;
      }
    }

    return path;
  });
}
