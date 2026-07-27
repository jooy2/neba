---
title: Examples
order: 3
aside: false
---

# Examples

<p class="neba-lede">Every component in the library on a single screen. Acrylic only means something over real content, so instead of a grid of specimens this is laid out the way a product screen would be.</p>

<Demo src="showcase/app" />

## What to look at

| Block | Components used | Worth noticing |
| --- | --- | --- |
| Header | `Toolbar` `Icon` `IconButton` `Pill` | A real `<header>` landmark, with the one live readout on the screen sitting in the shape that exists for live readouts |
| Controls | `Button` `ButtonGroup` `TextField` `Select` | At the same `size` a button, a field and a select are the same height, so the row keeps its baseline |
| Stats | `Statistic` `Grid` | `betterWhen` is what makes a figure that fell come out green — fewer failing builds is good news |
| What's new | `Carousel` | A scroll-snap strip: it swipes on a phone and runs the other way under RTL, and nothing is transformed |
| Deploys | `Table` `Chip` | The table is rendered from a column list, so the headings and the cells cannot drift apart |
| Profile form | `Card` `TextField` `Divider` `Chip` `Checkbox` `Button` | Save turns on `loading`; a bad address puts an `error` on the field |
| Sidebar | `Card` `RadioGroup` `Switch` `Slider` | A settings list puts its labels in a column and lines the switches up on the right |
| Cards in a box | `Box` `Card` | The box groups, the cards structure |

Per-component props and examples are under [Components](../components/).
