---
title: Landing page
order: 2
aside: false
---

# Landing page

<p class="neba-lede">A marketing page for Kestrel, a product analytics tool that does not exist. It is the case a component library is least obviously for — mostly type, space and one call to action repeated — which makes it the best test of whether the parts compose.</p>

<Demo src="concepts/landing" min-height="640px" />

The source is one file: `docs/.vitepress/demos/concepts/landing.tsx`. Everything on the page is a Neba component; nothing is a bare `div` dressed up as one.

## What it is made of

| Block | Components used | Worth noticing |
| --- | --- | --- |
| Announcement bar | `Pill` | A `Pill` with `onClick` is a button, so the banner is reachable by keyboard without any extra markup |
| Header | `Toolbar` `Icon` `Button` `IconButton` `Tooltip` | `render={<header />}` makes the bar a real landmark; the nav links are `variant="text"` buttons on one baseline |
| Hero | `Typography` `Chip` `Button` `Avatar` `Highlight` | `Typography` sets both the type scale and the element, so `level="h1"` is an actual `<h1>` |
| Trust strip | `Divider` `Typography` | A `Divider` with children carries the section label, so the rule and the heading are one element |
| Numbers | `GridContainer` `Grid` `Statistic` | `unit`, `prefix` and `previousValue` cover every shape of figure on the row |
| Features | `Card` `Icon` | The icon sits in `headerAction`, which keeps it on the title's baseline at every size |
| Product tour | `Tabs` `ProgressLinear` `List` `Chip` | Three views of the same data; the funnel is `ProgressLinear` with `showValue` rather than a chart |
| Quote | `Blockquote` | `author` and `source` are separate slots, so the attribution wraps as two lines on a phone |
| Pricing | `SegmentedButton` `Card` `List` `Table` | The billing toggle is a segmented control; the comparison table is rendered from a column list |
| FAQ | `Accordion` | One `AccordionItem` per question, all closed on arrival |
| Closing CTA | `Card` `TextField` `Button` | The only field on the page, inside a real `<form>` with its own submit |
| Footer | `Divider` `Grid` `List` `Button` | Link columns are `List` with `href` on each row, which renders anchors |

## Notes

- The page is bounded by a single `Container maxWidth="xl"` on a `<main>`. Nothing inside it sets a page width of its own.
- Colour carries meaning, not emphasis: the featured plan is `color="primary"` with `elevation={2}`, and the other two stay `secondary` and flat.
- The email field validates on change and shows `error` only once something has been typed, so an empty form is never red.
