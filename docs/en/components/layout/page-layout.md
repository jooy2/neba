---
title: PageLayout
order: 1
flutter: true
---

# PageLayout

<p class="neba-lede">The skeleton a page is hung on: a header, a footer, one sidebar or two, and the content between them. It arranges the regions and draws no surface of its own.</p>

<Demo src="page-layout/hero" minHeight="420" />

::: fw react

```tsx
import { Footer, Header, PageLayout, Sidebar } from 'neba';

<PageLayout header={<Header />} sidebar={<Sidebar>Navigation</Sidebar>} footer={<Footer />}>
  Page
</PageLayout>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaPageLayout(
  header: const NebaHeader(brand: <Widget>[NebaSidebarTrigger(), Text('Neba')]),
  sidebar: const NebaSidebar(child: Text('Navigation')),
  footer: const NebaFooter(child: Text('© 2026 Neba')),
  child: page,
);
```

:::

## Props

<PropsTable name="PageLayout" />

::: fw react

Every native `<div>` attribute passes through. The shared axes are described under [prop conventions](../../design/prop-conventions).

Only the `header` and the `footer` handed to it are measured as its bars. A [Header](./header) or a [Footer](./footer) anywhere else in the page, such as an article's own, is a header or footer of that part and leaves the layout alone.

A `fixed` Header handed to it as `header` has its room reserved from the first render, at the bar's minimum height for its `size`, so a server-rendered page does not drop by the header's height when it loads. The measured height takes over once the page has loaded. A header wrapped in a component of your own has its room reserved only once it has been measured.

The children go inside a real `<main>`, which is what `mainId` names and what the skip link jumps to. A layout that is not the page, such as an app shell previewed inside the page's own layout, passes `main={false}` to put them in a plain `<div>` with no `id` and no skip link. On a [Mockup](../surfaces/mockup)'s screen that is the default.

:::

::: fw flutter

The shared axes are described under [prop conventions](../../design/prop-conventions).

The layout owns the scroll view, so `child` is laid out at its natural height inside it, as content in a page is: put the page's widgets in, not a scroll view of their own. `controller` reaches what scrolls.

Only the `header` and the `footer` handed to it are its bars. It reads the `position` of a [Header](./header) or a [Footer](./footer) it was handed directly; a header wrapped in a widget of your own is held at the top as a sticky one is, and a footer wrapped in one scrolls with the page as a static one does. A Header or a Footer anywhere else, such as an article's own, is a bar of that part and leaves the layout alone.

The child is the main region, and the skip link moves the focus to it. Flutter has no ids, so there is no `mainId` and no `mainProps`. A layout inside another layout's content is not a second main region unless `main` says so, and a layout that is not the page, such as a preview, passes `main: false`.

:::

It draws no gutter and no measure: put a [Container](./container) inside, where a page can hold a wide dashboard on one route and a narrow article on the next.

::: fw flutter

### Safe areas

On a phone, each region is handed the system insets of the screen edges it touches and none of the others, the way a Flutter `Scaffold` hands them out: the header the top and the two sides, the footer the bottom and the two sides, a sidebar column its own side and the top or the bottom where no bar spans, and the content whatever is left. A [Header](./header), a [Footer](./footer) and a [Sidebar](./sidebar) keep what is on them clear of their share with their sheet still running to the edge, which each one's `safeArea` turns off. The content's share is in its `MediaQuery`, for a `SafeArea` or a padded list inside it to keep clear of. The React package has nothing to match this: a browser page meets the insets only under `viewport-fit=cover`.

:::

## Examples

### headerSpan

Which of the header and the sidebars takes the top corner. `full` (the default) spans the bar across the whole width with the sidebars beginning underneath it; `content` runs the sidebars the full height of the window and puts the bar between them. `footerSpan` answers the same question separately.

<Demo src="page-layout/span" minHeight="380">

::: fw react

<<< @/.vitepress/demos/page-layout/span.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/page_layout/span.dart

:::

</Demo>

### collapseBelow

Below this width both sidebars stop being columns and become drawers. A [SidebarTrigger](./sidebar#sidebartrigger) is what opens them, and it appears at exactly the same width. <Fw react="`none`" flutter="`NebaBreakpoint.xs`, the breakpoint no width is below," /> keeps the columns at every width.

<Demo src="page-layout/collapse" minHeight="360">

::: fw react

<<< @/.vitepress/demos/page-layout/collapse.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/page_layout/collapse.dart

:::

</Demo>

### Two sidebars

`sidebar` is the leading column and `endSidebar` the trailing one. Each is a [Sidebar](./sidebar) with its own width, its own drawer and its own trigger, and neither needs a `side` prop: the slot decides. Give both a `label`, or a screen reader offers two regions called "complementary".

<Demo src="page-layout/two-sidebars" minHeight="320">

::: fw react

<<< @/.vitepress/demos/page-layout/two-sidebars.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/page_layout/two_sidebars.dart

:::

</Demo>

### scroll

::: fw react

`page`, the default, lets the document scroll: the browser's own address bar hides on a phone, the scroll position is restored on a back navigation, and a [Header](./header) holds its place with `position: sticky`. `content` pins the layout to the height of the window and scrolls only the region between the bars.

```tsx
<PageLayout scroll="content" header={<Header />} sidebar={<Sidebar>Files</Sidebar>}>
  Workspace
</PageLayout>
```

:::

::: fw flutter

`page`, the default, scrolls the whole page in one scroll view: a sticky [Header](./header) holds its place at the top with the content passing under its sheet, the sidebars hold theirs beside the content and give way at its end, and the footer is reached by scrolling to it. `content` keeps the bars and the sidebars where they are and scrolls only the region between them.

```dart
NebaPageLayout(
  scroll: NebaPageLayoutScroll.content,
  header: const NebaHeader(),
  sidebar: const NebaSidebar(child: Text('Files')),
  child: workspace,
);
```

:::

### height

::: fw react

`viewport` is the window's height, so a short page still pushes its footer to the bottom of the screen. `auto` is the parent's, for a layout that is not the page: an app shell inside a [Mockup](../surfaces/mockup)'s screen, a preview. A number or a CSS length is exactly that.

```tsx
<div className="h-96">
  <PageLayout height="auto" scroll="content" header={<Header />}>
    Preview
  </PageLayout>
</div>
```

:::

::: fw flutter

`NebaPageLayoutHeight.viewport` is the window's height, so a short page still pushes its footer to the bottom of the screen. `NebaPageLayoutHeight.auto` is the height the parent bounds it to, for a layout that is not the page: a preview, a pane of a larger tool. `NebaPageLayoutHeight.pixels(320)` is exactly that.

```dart
SizedBox(
  height: 384,
  child: NebaPageLayout(
    height: NebaPageLayoutHeight.auto,
    scroll: NebaPageLayoutScroll.content,
    header: const NebaHeader(),
    child: preview,
  ),
);
```

:::

### Controlling the drawers

`sidebarOpen` and `onSidebarOpenChange` control the leading drawer, `endSidebarOpen` and `onEndSidebarOpenChange` the trailing one. Reach for them when a route change should close the drawer behind it.

::: fw react

```tsx
const [open, setOpen] = useState(false);

<PageLayout sidebarOpen={open} onSidebarOpenChange={setOpen} sidebar={<Sidebar>Nav</Sidebar>}>
  Page
</PageLayout>;
```

:::

::: fw flutter

```dart
NebaPageLayout(
  sidebarOpen: open,
  onSidebarOpenChange: (bool next) => setState(() => open = next),
  sidebar: const NebaSidebar(child: Text('Nav')),
  child: page,
);
```

:::

## Accessibility

::: fw react

- The children are wrapped in a `<main>`, and the header, the footer and the sidebars carry `<header>`, `<footer>` and `<aside>`: the `banner`, `contentinfo` and `complementary` landmarks.
- A "Skip to content" link is the first thing in the document, drawn only while it holds the focus. Turn it off with `skipLink={false}` only if the page already has one.
- The `<main>` is `tabIndex={-1}`, so following the skip link moves the focus there and the next Tab starts inside the page. With `scroll="content"` it is also what the arrow keys scroll once it holds the focus. A `tabIndex` in `mainProps` wins.
- `locale` sets the language of the skip link and of every Sidebar and SidebarTrigger inside the layout. Unsupported tags fall back to English; `skipLabel` writes the word out instead.
- A page with two sidebars must give each one a `label`.

:::

::: fw flutter

- The child is the main region, the footer the `contentInfo` region and each sidebar column a `complementary` region, as Flutter's semantics roles name them. Flutter has no banner role: the header is a group read in order, and a named region when it has a `label`.
- A "Skip to content" link is first in the focus order whatever the page's geometry, drawn only while it holds the focus. Turn it off with `skipLink: false` only if the screen already has one.
- The main region takes the focus without being a Tab stop of its own, so following the skip link moves the focus there, with a ring inside its edge, and the next Tab starts inside it. Tab then goes through the header, the leading sidebar, the content, the trailing sidebar and the footer, each region in reading order.
- `locale` sets the language of the skip link and of every Sidebar and SidebarTrigger inside the layout. A language nobody registered falls back to English; `skipLabel` writes the word out instead.
- A screen with two sidebars must give each one a `label`.

:::
