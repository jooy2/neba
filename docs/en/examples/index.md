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
| Toolbar | `Button` `ButtonGroup` `TextField` `Select` | At the same `size` a button, a field and a select are the same height, so the row keeps its baseline |
| Stats | `Box` `Typography` | Even `solid` is not flooded with colour — the text on it stays readable |
| Deploys | `Table` `Chip` | The table is rendered from a column list, so the headings and the cells cannot drift apart |
| Profile form | `Card` `TextField` `Divider` `Chip` `Checkbox` `Button` | Save turns on `loading`; a bad address puts an `error` on the field |
| Sidebar | `Card` `RadioGroup` `Switch` `Slider` | A settings list puts its labels in a column and lines the switches up on the right |
| Cards in a box | `Box` `Card` | The box groups, the cards structure |

Per-component props and examples are under [Components](../components/).
