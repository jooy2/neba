import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/concepts/data/glyph.dart';

// The back office of a shop that does not exist: a resizable rail beside a
// work area holding the day's orders, the numbers they add up to and what the
// warehouse is doing, built out of Neba widgets alone. The Flutter twin of the
// documentation's dashboard concept; the copy stays in English, as the React
// screen's does.

const String _logo =
    'M6 2.5h4a3.5 3.5 0 0 1 3.5 3.5v4a3.5 3.5 0 0 1-3.5 3.5H6A3.5 3.5 0 0 1 2.5 10V6A3.5 3.5 0 0 1 '
    '6 2.5Z M5.5 8h5M8 5.5v5';
const String _search = 'M11.25 7A4.25 4.25 0 1 1 2.75 7 4.25 4.25 0 0 1 11.25 7Z M10.5 10.5l3 3';
const String _bell = 'M4 6.5a4 4 0 0 1 8 0c0 3 1 4 1 4H3s1-1 1-4Z M6.5 13a1.5 1.5 0 0 0 3 0';
const String _home = 'M2.5 7 8 2.5 13.5 7v6.5h-11V7Z';
const String _bag = 'M3 5h10l-.8 8.5H3.8L3 5Z M5.75 5V3.75a2.25 2.25 0 0 1 4.5 0V5';
const String _box = 'M8 2 13.5 5v6L8 14 2.5 11V5L8 2Z M2.5 5 8 8l5.5-3M8 8v6';
const String _people =
    'M8.5 5.5A2.5 2.5 0 1 1 3.5 5.5 2.5 2.5 0 0 1 8.5 5.5Z '
    'M1.75 13c.4-2.2 2.2-3.5 4.25-3.5S9.85 10.8 10.25 13 '
    'M10.75 3.5a2.5 2.5 0 0 1 0 5M11.5 9.75c1.6.35 2.5 1.6 2.75 3.25';
const String _chart = 'M2.5 13.5h11 M4.5 11V7M8 11V3.5M11.5 11V8.5';
const String _gear =
    'M10.25 8A2.25 2.25 0 1 1 5.75 8 2.25 2.25 0 0 1 10.25 8Z '
    'M8 1.75v1.5M8 12.75v1.5M14.25 8h-1.5M3.25 8h-1.5M12.4 3.6l-1 1M4.6 11.4l-1 1M12.4 12.4l-1-1'
    'M4.6 4.6l-1-1';
const String _dot = 'M12 8A4 4 0 1 1 4 8 4 4 0 0 1 12 8Z';

typedef _Section = ({String id, String label, String icon, int? badge});

const List<_Section> _nav = <_Section>[
  (id: 'overview', label: 'Overview', icon: _home, badge: null),
  (id: 'orders', label: 'Orders', icon: _bag, badge: 12),
  (id: 'products', label: 'Products', icon: _box, badge: null),
  (id: 'customers', label: 'Customers', icon: _people, badge: null),
  (id: 'reports', label: 'Reports', icon: _chart, badge: null),
  (id: 'settings', label: 'Settings', icon: _gear, badge: null),
];

const List<NebaSelectOption<String>> _channels = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'all', label: Text('All channels')),
  NebaSelectOption<String>(value: 'web', label: Text('Online store')),
  NebaSelectOption<String>(value: 'pos', label: Text('Point of sale')),
  NebaSelectOption<String>(value: 'market', label: Text('Marketplaces')),
];

const Map<String, String> _channelNames = <String, String>{
  'web': 'Online store',
  'pos': 'Point of sale',
  'market': 'Marketplaces',
};

typedef _Stat = ({
  String label,
  Object value,
  String? prefix,
  String? unit,
  num? previousValue,
  NebaStatisticBetterWhen betterWhen,
  String caption,
});

const List<_Stat> _stats = <_Stat>[
  (
    label: 'Revenue',
    value: 48219,
    prefix: r'$',
    unit: null,
    previousValue: 41880,
    betterWhen: NebaStatisticBetterWhen.up,
    caption: 'vs. previous period',
  ),
  (
    label: 'Orders',
    value: 1284,
    prefix: null,
    unit: null,
    previousValue: 1190,
    betterWhen: NebaStatisticBetterWhen.up,
    caption: 'vs. previous period',
  ),
  (
    label: 'Refund rate',
    value: 1.8,
    prefix: null,
    unit: '%',
    previousValue: 2.6,
    betterWhen: NebaStatisticBetterWhen.down,
    caption: 'vs. previous period',
  ),
  (
    label: 'Avg. fulfilment',
    value: '9h 12m',
    prefix: null,
    unit: null,
    previousValue: null,
    betterWhen: NebaStatisticBetterWhen.up,
    caption: 'Order paid to parcel collected',
  ),
];

typedef _Order = ({
  String id,
  String reference,
  String customer,
  String channel,
  String status,
  String total,
});

const List<_Order> _orders = <_Order>[
  (
    id: '1',
    reference: '#10482',
    customer: 'Ada Bell',
    channel: 'Online store',
    status: 'Paid',
    total: r'$248.00',
  ),
  (
    id: '2',
    reference: '#10481',
    customer: '김서연',
    channel: 'Marketplaces',
    status: 'Packing',
    total: r'$92.50',
  ),
  (
    id: '3',
    reference: '#10480',
    customer: 'Tom Vale',
    channel: 'Online store',
    status: 'Shipped',
    total: r'$1,120.00',
  ),
  (
    id: '4',
    reference: '#10479',
    customer: 'Mira Osei',
    channel: 'Point of sale',
    status: 'Paid',
    total: r'$36.00',
  ),
  (
    id: '5',
    reference: '#10478',
    customer: 'Jun Park',
    channel: 'Online store',
    status: 'Refunded',
    total: r'$74.90',
  ),
];

const Map<String, NebaColor> _statusColor = <String, NebaColor>{
  'Paid': NebaColor.success,
  'Packing': NebaColor.info,
  'Shipped': NebaColor.primary,
  'Refunded': NebaColor.danger,
};

/// "1 order", "3 orders": a count in a sentence still has to read as one.
String _ordersOf(int count) => '$count ${count == 1 ? 'order' : 'orders'}';

const List<(String, int, int)> _lowStock = <(String, int, int)>[
  ('Field Notebook, A5', 4, 60),
  ('Enamel Mug, 350ml', 9, 120),
  ('Canvas Tote, Natural', 12, 80),
];

/// Midnight today, so a preset never carries the time the page happened to
/// load.
DateTime _today() {
  final DateTime now = DateTime.now();

  return DateTime(now.year, now.month, now.day);
}

NebaDateRange _lastDays(int count) {
  final DateTime end = _today();

  return NebaDateRange(start: DateTime(end.year, end.month, end.day - (count - 1)), end: end);
}

/// The narrowest the shell lays out at; a screen narrower than it scrolls
/// sideways, as the React screen's fixed panes would.
const double _shellWidth = 960;

class ConceptsDashboard extends StatelessWidget {
  const ConceptsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaToastProvider(position: NebaToastPosition.bottomEnd, child: _Dashboard());
  }
}

class _Dashboard extends StatefulWidget {
  const _Dashboard();

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  String _section = 'orders';
  String _channel = 'all';
  String _query = '';
  NebaDateRange _range = _lastDays(30);
  int _page = 1;
  List<String> _selected = <String>[];
  bool _autoFulfil = true;

  List<_Order> get _rows {
    final String needle = _query.trim().toLowerCase();

    return <_Order>[
      for (final _Order order in _orders)
        if ((_channel == 'all' || _channelNames[_channel] == order.channel) &&
            (needle.isEmpty ||
                order.reference.toLowerCase().contains(needle) ||
                order.customer.toLowerCase().contains(needle)))
          order,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    // The shell is a split, and the split is the layout: a rail that keeps
    // its width and a work area that takes what is left.
    Widget shell = SizedBox(
      height: 736,
      child: NebaPanes(
        children: <NebaPane>[
          NebaPane(
            defaultSize: const NebaPaneSize.pixels(232),
            minSize: const NebaPaneSize.pixels(72),
            maxSize: const NebaPaneSize.percent(40),
            child: _rail(),
          ),
          NebaPane(child: _work()),
        ],
      ),
    );

    if (width < _shellWidth) {
      shell = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: _shellWidth, child: shell),
      );
    }

    return shell;
  }

  Widget _rail() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 8,
              children: <Widget>[
                NebaIcon(
                  icon: ConceptGlyph(_logo),
                  size: NebaSize.lg,
                  color: NebaColor.primary,
                  semanticLabel: 'Grange',
                ),
                Flexible(child: NebaTypography('Grange', level: NebaTypographyLevel.h6, lines: 1)),
              ],
            ),
          ),
          Semantics(
            role: SemanticsRole.navigation,
            label: 'Sections',
            child: NebaList(
              variant: NebaVariant.text,
              size: NebaSize.sm,
              density: NebaDensity.compact,
              children: <Widget>[
                for (final _Section item in _nav)
                  NebaListItem(
                    startIcon: NebaIcon(icon: ConceptGlyph(item.icon), size: NebaSize.sm),
                    selected: _section == item.id,
                    onPressed: () => setState(() => _section = item.id),
                    action: item.badge == null
                        ? null
                        : NebaChip(
                            size: NebaSize.xs,
                            variant: NebaVariant.text,
                            color: NebaColor.info,
                            child: Text('${item.badge}'),
                          ),
                    child: Text(item.label),
                  ),
              ],
            ),
          ),
          const Spacer(),
          // The one live readout in the shell, in the shape made for it.
          const NebaPill(
            size: NebaSize.sm,
            color: NebaColor.info,
            variant: NebaVariant.text,
            startIcon: ConceptGlyph(_dot, filled: true),
            title: Text('Syncing inventory'),
            description: Text('2 of 3 warehouses'),
          ),
          NebaCard(
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            color: NebaColor.secondary,
            title: const Text('Plan'),
            subtitle: const Text('Standard · 8 seats'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: <Widget>[
                const NebaProgressLinear(
                  value: 72,
                  size: NebaSize.sm,
                  label: Text('Order quota'),
                  showValue: true,
                ),
                NebaButton(
                  onPressed: () {},
                  size: NebaSize.xs,
                  fullWidth: true,
                  variant: NebaVariant.outline,
                  color: NebaColor.secondary,
                  child: const Text('Upgrade'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _work() {
    // The application bar is held at the top, so the actions stay in reach
    // while the table under it scrolls.
    return CustomScrollView(
      slivers: <Widget>[
        PinnedHeaderSliver(child: _bar()),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: <Widget>[
                _heading(),
                // One thing needs attention, so it is said once, at the top.
                NebaAlert(
                  color: NebaColor.warning,
                  title: const Text('Three products are below their reorder point'),
                  action: NebaButton(
                    onPressed: () {},
                    size: NebaSize.xs,
                    variant: NebaVariant.outline,
                    color: NebaColor.warning,
                    child: const Text('Reorder'),
                  ),
                  onClose: () {},
                  child: const Text('Stock levels were last synced 14 minutes ago.'),
                ),
                _numbers(),
                _filters(),
                _orderTabs(),
                const NebaDivider(),
                _bottomRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar() {
    return NebaToolbar(
      variant: NebaVariant.solid,
      density: NebaDensity.compact,
      position: NebaPosition.sticky,
      divider: true,
      start: <Widget>[
        NebaBreadcrumb(
          size: NebaSize.sm,
          children: <NebaBreadcrumbItem>[
            NebaBreadcrumbItem(onPressed: () {}, child: const Text('Grange')),
            NebaBreadcrumbItem(onPressed: () {}, child: const Text('Northwind Supply')),
            const NebaBreadcrumbItem(child: Text('Orders')),
          ],
        ),
      ],
      end: <Widget>[
        NebaTooltip(
          content: const Text('What changed in the last hour'),
          child: NebaBadge(
            content: const Text('3'),
            color: NebaColor.danger,
            semanticLabel: '3 new notifications',
            child: NebaIconButton(
              onPressed: () {},
              icon: const ConceptGlyph(_bell),
              label: 'Notifications',
              size: NebaSize.sm,
              variant: NebaVariant.text,
              color: NebaColor.secondary,
            ),
          ),
        ),
        const NebaBadge(
          dot: true,
          color: NebaColor.success,
          overlap: NebaBadgeOverlap.circle,
          semanticLabel: 'Online',
          child: NebaAvatar(
            size: NebaSize.sm,
            image: AssetImage('assets/samples/people/helen-voss.jpg'),
            name: 'Helen Voss',
          ),
        ),
      ],
    );
  }

  Widget _heading() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: <Widget>[
            NebaTypography('Orders', level: NebaTypographyLevel.h3),
            NebaTypography(
              'Everything placed in the selected range, across every channel.',
              level: NebaTypographyLevel.caption,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            NebaButton(
              onPressed: () {},
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              color: NebaColor.secondary,
              child: const Text('Export CSV'),
            ),
            NebaButton(onPressed: () {}, size: NebaSize.sm, child: const Text('Create order')),
          ],
        ),
      ],
    );
  }

  Widget _numbers() {
    // Two per row at every width, because the work area is narrower than the
    // window the breakpoints are measured against.
    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        for (final _Stat stat in _stats)
          NebaGrid(
            span: const NebaGridSpan.columns(6),
            child: NebaStatistic(
              label: Text(stat.label),
              value: stat.value,
              prefix: stat.prefix == null ? null : Text(stat.prefix!),
              unit: stat.unit == null ? null : Text(stat.unit!),
              previousValue: stat.previousValue,
              betterWhen: stat.betterWhen,
              caption: Text(stat.caption),
            ),
          ),
      ],
    );
  }

  Widget _filters() {
    final int count = _selected.length;

    // Every control on the row is the same size, which keeps one baseline
    // across four different widgets.
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        NebaTextField(
          size: NebaSize.sm,
          startIcon: const ConceptGlyph(_search),
          placeholder: 'Search order or customer',
          semanticLabel: 'Search orders',
          onChanged: (String value) => setState(() => _query = value),
        ),
        NebaSelect<String>(
          size: NebaSize.sm,
          items: _channels,
          value: _channel,
          onValueChange: (String value) => setState(() => _channel = value),
          semanticLabel: 'Channel',
        ),
        NebaDateRangePicker(
          size: NebaSize.sm,
          value: _range,
          onValueChange: (NebaDateRange? value) {
            if (value != null) {
              setState(() => _range = value);
            }
          },
          startPlaceholder: const Text('From'),
          endPlaceholder: const Text('To'),
          semanticLabel: 'Date range',
          presets: <NebaDateRangePreset>[
            NebaDateRangePreset.computed(
              label: const Text('Last 7 days'),
              value: () => _lastDays(7),
            ),
            NebaDateRangePreset.computed(
              label: const Text('Last 30 days'),
              value: () => _lastDays(30),
            ),
            NebaDateRangePreset.computed(
              label: const Text('Last 90 days'),
              value: () => _lastDays(90),
            ),
          ],
        ),
        if (count > 0) ...<Widget>[
          NebaTypography('$count selected', level: NebaTypographyLevel.caption),
          Builder(
            builder: (BuildContext context) {
              return NebaButton(
                onPressed: () {
                  NebaToastProvider.of(context).add(
                    NebaToastOptions(
                      color: NebaColor.success,
                      title: const Text('Marked as fulfilled'),
                      description: Text(_ordersOf(count)),
                    ),
                  );
                  setState(() => _selected = <String>[]);
                },
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                color: NebaColor.secondary,
                child: const Text('Fulfil'),
              );
            },
          ),
          NebaDialog(
            size: NebaSize.sm,
            color: NebaColor.danger,
            triggerBuilder: (BuildContext context, VoidCallback open) => NebaButton(
              onPressed: open,
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              color: NebaColor.danger,
              child: const Text('Cancel orders'),
            ),
            title: Text('Cancel ${_ordersOf(count)}?'),
            description: const Text('Payment is released back to the customer straight away.'),
            actions: <Widget>[
              NebaDialogClose(
                builder: (BuildContext context, VoidCallback close) => NebaButton(
                  onPressed: close,
                  size: NebaSize.sm,
                  variant: NebaVariant.text,
                  color: NebaColor.secondary,
                  child: const Text('Keep them'),
                ),
              ),
              NebaDialogClose(
                builder: (BuildContext context, VoidCallback close) => NebaButton(
                  onPressed: () {
                    setState(() => _selected = <String>[]);
                    close();
                  },
                  size: NebaSize.sm,
                  color: NebaColor.danger,
                  child: const Text('Cancel orders'),
                ),
              ),
            ],
            child: const Text('This cannot be undone.'),
          ),
        ],
      ],
    );
  }

  Widget _orderTabs() {
    final List<_Order> rows = _rows;
    final bool all = rows.isNotEmpty && _selected.length == rows.length;

    final List<NebaTableColumn<_Order>> columns = <NebaTableColumn<_Order>>[
      NebaTableColumn<_Order>(
        key: 'select',
        label: NebaCheckbox(
          size: NebaSize.sm,
          semanticLabel: 'Select every order',
          checked: all,
          indeterminate: _selected.isNotEmpty && !all,
          onCheckedChange: (bool checked) => setState(() {
            _selected = checked ? <String>[for (final _Order row in rows) row.id] : <String>[];
          }),
        ),
        width: 44,
        builder: (BuildContext context, _Order row, int index) => NebaCheckbox(
          size: NebaSize.sm,
          semanticLabel: 'Select ${row.reference}',
          checked: _selected.contains(row.id),
          onCheckedChange: (bool checked) => setState(() {
            _selected = checked
                ? <String>[..._selected, row.id]
                : <String>[
                    for (final String id in _selected)
                      if (id != row.id) id,
                  ];
          }),
        ),
      ),
      NebaTableColumn<_Order>(
        key: 'reference',
        label: const Text('Order'),
        width: 96,
        builder: (BuildContext context, _Order row, int index) => Text(row.reference),
      ),
      NebaTableColumn<_Order>(
        key: 'customer',
        label: const Text('Customer'),
        width: 160,
        builder: (BuildContext context, _Order row, int index) => Row(
          spacing: 8,
          children: <Widget>[
            NebaAvatar(size: NebaSize.xs, name: row.customer, color: NebaColor.secondary),
            Flexible(child: Text(row.customer, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      NebaTableColumn<_Order>(
        key: 'channel',
        label: const Text('Channel'),
        width: 130,
        builder: (BuildContext context, _Order row, int index) => Text(row.channel),
      ),
      NebaTableColumn<_Order>(
        key: 'status',
        label: const Text('Status'),
        width: 120,
        builder: (BuildContext context, _Order row, int index) => NebaChip(
          size: NebaSize.xs,
          variant: NebaVariant.text,
          color: _statusColor[row.status],
          child: Text(row.status),
        ),
      ),
      NebaTableColumn<_Order>(
        key: 'total',
        label: const Text('Total'),
        align: NebaAlign.end,
        width: 96,
        builder: (BuildContext context, _Order row, int index) => Text(row.total),
      ),
      NebaTableColumn<_Order>(
        key: 'actions',
        label: const SizedBox.shrink(),
        align: NebaAlign.end,
        width: 48,
        builder: (BuildContext context, _Order row, int index) => NebaMenu(
          size: NebaSize.sm,
          trigger: NebaIconButton(
            onPressed: () {},
            icon: const ConceptGlyph(_dot, filled: true),
            label: 'Actions for ${row.reference}',
            size: NebaSize.xs,
            variant: NebaVariant.text,
            color: NebaColor.secondary,
          ),
          children: const <Widget>[
            NebaMenuItem(child: Text('Open order')),
            NebaMenuItem(child: Text('Print packing slip')),
            NebaMenuSeparator(),
            NebaMenuItem(color: NebaColor.danger, child: Text('Refund')),
          ],
        ),
      ),
    ];

    return NebaTabs<String>(
      defaultValue: 'open',
      size: NebaSize.sm,
      children: <Widget>[
        NebaTab<String>(
          value: 'open',
          endIcon: NebaBadge(content: Text('${rows.length}'), size: NebaSize.xs),
          child: const Text('Open'),
        ),
        const NebaTab<String>(value: 'fulfilled', child: Text('Fulfilled')),
        const NebaTab<String>(value: 'cancelled', child: Text('Cancelled')),
        NebaTabPanel<String>(
          value: 'open',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: <Widget>[
              // The row actions on a context menu as well as the row menu.
              NebaContextMenu(
                size: NebaSize.sm,
                content: const <Widget>[
                  NebaMenuItem(shortcut: Text('⌘P'), child: Text('Print packing slips')),
                  NebaMenuItem(child: Text('Copy order numbers')),
                  NebaMenuSeparator(),
                  NebaMenuItem(color: NebaColor.danger, child: Text('Cancel selected')),
                ],
                child: NebaTable<_Order>(
                  headers: columns,
                  items: rows,
                  rowKey: (_Order row, int index) => ValueKey<String>(row.id),
                  size: NebaSize.sm,
                  hoverable: true,
                  stickyHeader: true,
                  empty: const Text('No orders match those filters.'),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  NebaTypography(
                    'Showing ${rows.length} of 1,284',
                    level: NebaTypographyLevel.caption,
                  ),
                  NebaPagination(
                    size: NebaSize.sm,
                    count: 26,
                    page: _page,
                    onPageChange: (int page) => setState(() => _page = page),
                  ),
                ],
              ),
            ],
          ),
        ),
        const NebaTabPanel<String>(
          value: 'fulfilled',
          child: NebaTypography(
            'Nothing fulfilled in this range yet.',
            level: NebaTypographyLevel.caption,
          ),
        ),
        const NebaTabPanel<String>(
          value: 'cancelled',
          child: NebaTypography(
            'Two orders were cancelled this week.',
            level: NebaTypographyLevel.caption,
          ),
        ),
      ],
    );
  }

  Widget _bottomRow() {
    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: const NebaGridSpan.columns(4),
          child: NebaCard(
            size: NebaSize.sm,
            title: const Text('Low stock'),
            subtitle: const Text('Below the reorder point'),
            dividers: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: <Widget>[
                for (final (String name, int left, int of) in _lowStock)
                  NebaProgressLinear(
                    size: NebaSize.sm,
                    color: left < 6 ? NebaColor.danger : NebaColor.warning,
                    value: left.toDouble(),
                    max: of.toDouble(),
                    label: Text('$name · $left of $of left'),
                  ),
              ],
            ),
          ),
        ),
        const NebaGrid(
          span: NebaGridSpan.columns(4),
          child: NebaCard(
            size: NebaSize.sm,
            title: Text('Today'),
            subtitle: Text('Warehouse activity'),
            child: NebaTimeline(
              size: NebaSize.sm,
              density: NebaDensity.compact,
              active: 2,
              color: NebaColor.primary,
              children: <NebaTimelineItem>[
                NebaTimelineItem(
                  title: Text('Picking started'),
                  meta: Text('08:10'),
                  child: Text('14 orders in the wave'),
                ),
                NebaTimelineItem(
                  title: Text('Carrier collected'),
                  meta: Text('11:45'),
                  child: Text('DHL · 9 parcels'),
                ),
                NebaTimelineItem(
                  title: Text('Restock arriving'),
                  meta: Text('16:00'),
                  child: Text('3 SKUs'),
                ),
              ],
            ),
          ),
        ),
        NebaGrid(
          span: const NebaGridSpan.columns(4),
          child: NebaCard(
            size: NebaSize.sm,
            title: const Text('Automation'),
            subtitle: const Text('Applies to the whole store'),
            footer: const Row(
              spacing: 8,
              children: <Widget>[
                NebaProgressCircular(size: NebaSize.xs),
                NebaTypography('Rules running', level: NebaTypographyLevel.caption),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: <Widget>[
                NebaSwitch(
                  size: NebaSize.sm,
                  labelSide: NebaSwitchLabelSide.start,
                  label: const Text('Auto-fulfil paid orders'),
                  checked: _autoFulfil,
                  onCheckedChange: (bool value) => setState(() => _autoFulfil = value),
                ),
                const NebaSwitch(
                  size: NebaSize.sm,
                  labelSide: NebaSwitchLabelSide.start,
                  label: Text('Email the customer on dispatch'),
                  defaultChecked: true,
                ),
                const NebaSwitch(
                  size: NebaSize.sm,
                  labelSide: NebaSwitchLabelSide.start,
                  label: Text('Hold orders flagged as risky'),
                  defaultChecked: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
