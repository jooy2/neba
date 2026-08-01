---
title: Admin dashboard
order: 3
aside: false
---

# Admin dashboard

<p class="neba-lede">The back office of Grange, a shop that does not exist. A nav rail, a filter row, four figures, a table with an action on every row and a drawer of settings — all on one screen and all at the same size, which is the arrangement that shows whether a size ladder actually holds.</p>

<Demo src="concepts/dashboard" min-height="736px" />

The source is one file: `docs/.vitepress/demos/concepts/dashboard.tsx`. The table is live — search, filter by channel, select rows, and the bulk actions appear.

## What it is made of

| Block | Components used | Worth noticing |
| --- | --- | --- |
| Shell | `Panes` `Pane` | The split is the layout: a rail that keeps its width and a work area that takes what is left, draggable between them |
| Nav rail | `List` `ListItem` `Icon` `Chip` | `render={<nav />}` on the list, `selected` on the current row, and the unread count in the `action` slot |
| Rail footer | `Pill` `Card` `ProgressLinear` | The sync readout is a `Pill` with `title` and `description`; the quota is a bar inside a small `Card` |
| App bar | `Toolbar` `Breadcrumb` `Badge` `Avatar` `Tooltip` | `position="sticky"` keeps the actions reachable while the table scrolls under it |
| Alert | `Alert` | One thing needs attention, said once, at the top, with its own `action` |
| Figures | `GridContainer` `Grid` `Statistic` | `betterWhen="down"` is what makes a falling refund rate come out green |
| Filters | `TextField` `Select` `DateRangePicker` | At the same `size` the three are the same height, so the row keeps one baseline |
| Bulk actions | `Button` `Dialog` `Toast` | They appear only with a selection; the destructive one confirms in a `Dialog` first |
| Table | `Tabs` `Table` `Checkbox` `Chip` `Menu` `ContextMenu` `Pagination` | Select-all is an `indeterminate` checkbox in the header cell; every row carries a `Menu`, and the whole table a `ContextMenu` |
| Bottom row | `Card` `ProgressLinear` `Timeline` `Switch` `ProgressCircular` | Three cards on the same grid: what is low, what happened, what is set |

## Notes

- `stickyHeader` on the table keeps the column headings visible inside the scrolling pane.
- The row menu's trigger is an `IconButton` with a `label`, so every row action has an accessible name that says which row it belongs to.
- Filtering is ordinary React state. The table renders whatever it is given and shows `empty` when that is nothing.
