import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `NebaPosition.sticky` draws the bar as it looks held against the edge; the
/// `PinnedHeaderSliver` is what holds it there. The box below scrolls, and
/// the bar does not.
class ToolbarSticky extends StatelessWidget {
  const ToolbarSticky({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.md]!);

    return Container(
      height: 256,
      decoration: BoxDecoration(
        border: Border.all(color: tokens.border),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomScrollView(
          slivers: <Widget>[
            PinnedHeaderSliver(
              child: NebaToolbar(
                position: NebaPosition.sticky,
                divider: true,
                variant: NebaVariant.solid,
                density: NebaDensity.compact,
                start: const <Widget>[NebaTypography('Changelog', level: NebaTypographyLevel.h6)],
                end: <Widget>[
                  NebaButton(
                    onPressed: () {},
                    size: NebaSize.sm,
                    variant: NebaVariant.text,
                    child: const Text('Subscribe'),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemCount: 12,
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) => NebaTypography(
                  '1.0.${12 - index} — a release note long enough to make the page scroll '
                  'under the bar.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
