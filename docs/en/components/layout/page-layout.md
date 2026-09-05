---
title: PageLayout
order: 1
---

# PageLayout

<p class="neba-lede">The skeleton a page is hung on: a header, a footer, one sidebar or two, and the content between them. It arranges the regions and draws no surface of its own.</p>

<Demo src="page-layout/hero" minHeight="420" />

```tsx
import { Footer, Header, PageLayout, Sidebar } from 'neba';

<PageLayout header={<Header />} sidebar={<Sidebar>Navigation</Sidebar>} footer={<Footer />}>
  Page
</PageLayout>;
```

## Props

<PropsTable name="PageLayout" />

Every native `<div>` attribute passes through. The shared axes are described under [prop conventions](../../design/prop-conventions).

The children go inside a real `<main>`, which is what `mainId` names and what the skip link jumps to.

It draws no gutter and no measure: put a [Container](./container) inside, where a page can hold a wide dashboard on one route and a narrow article on the next.

## Examples

### headerSpan

Which of the header and the sidebars takes the top corner. `full` (the default) spans the bar across the whole width with the sidebars beginning underneath it; `content` runs the sidebars the full height of the window and puts the bar between them. `footerSpan` answers the same question separately.

<Demo src="page-layout/span" minHeight="380">

<<< @/.vitepress/demos/page-layout/span.tsx

</Demo>

### collapseBelow

Below this width both sidebars stop being columns and become drawers. A [SidebarTrigger](./sidebar#sidebartrigger) is what opens them, and it appears at exactly the same width. `none` keeps the columns at every width.

<Demo src="page-layout/collapse" minHeight="360">

<<< @/.vitepress/demos/page-layout/collapse.tsx

</Demo>

### Two sidebars

`sidebar` is the leading column and `endSidebar` the trailing one. Each is a [Sidebar](./sidebar) with its own width, its own drawer and its own trigger, and neither needs a `side` prop: the slot decides. Give both a `label`, or a screen reader offers two regions called "complementary".

<Demo src="page-layout/two-sidebars" minHeight="320">

<<< @/.vitepress/demos/page-layout/two-sidebars.tsx

</Demo>

### scroll

`page`, the default, lets the document scroll: the browser's own address bar hides on a phone, the scroll position is restored on a back navigation, and a [Header](./header) holds its place with `position: sticky`. `content` pins the layout to the height of the window and scrolls only the region between the bars.

```tsx
<PageLayout scroll="content" header={<Header />} sidebar={<Sidebar>Files</Sidebar>}>
  Workspace
</PageLayout>
```

### height

`viewport` is the window's height, so a short page still pushes its footer to the bottom of the screen. `auto` is the parent's, for a layout that is not the page: an app shell inside a [Mockup](../surfaces/mockup)'s screen, a preview. A number or a CSS length is exactly that.

```tsx
<div className="h-96">
  <PageLayout height="auto" scroll="content" header={<Header />}>
    Preview
  </PageLayout>
</div>
```

### Controlling the drawers

`sidebarOpen` and `onSidebarOpenChange` control the leading drawer, `endSidebarOpen` and `onEndSidebarOpenChange` the trailing one. Reach for them when a route change should close the drawer behind it.

```tsx
const [open, setOpen] = useState(false);

<PageLayout sidebarOpen={open} onSidebarOpenChange={setOpen} sidebar={<Sidebar>Nav</Sidebar>}>
  Page
</PageLayout>;
```

## Accessibility

- The children are wrapped in a `<main>`, and the header, the footer and the sidebars carry `<header>`, `<footer>` and `<aside>`: the `banner`, `contentinfo` and `complementary` landmarks.
- A "Skip to content" link is the first thing in the document, drawn only while it holds the focus. Turn it off with `skipLink={false}` only if the page already has one.
- `locale` sets the language of the skip link and of every Sidebar and SidebarTrigger inside the layout. Unsupported tags fall back to English; `skipLabel` writes the word out instead.
- A page with two sidebars must give each one a `label`.
