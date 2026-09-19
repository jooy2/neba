---
title: Overview
order: 1
aside: false
---

# Overview

<p class="neba-lede">Most of the library's components, arranged on one screen. Rather than a grid of specimens it is laid out like a real product screen, so you can check how the sizes and baselines line up together.</p>

<Demo src="showcase/app" />

## What to look at

The screen has twenty-six blocks, and the table picks out ten of them.

| Block | Components used | Worth noticing |
| --- | --- | --- |
| Header | `Toolbar` `Icon` `IconButton` `Pill` | `render={<header />}` makes it a real landmark, and the build status that keeps updating sits in the `Pill` built for exactly that |
| Controls | `Button` `ButtonGroup` `SegmentedButton` `TextField` `Select` | At the same `size` a button, a field, a select and a segment are the same height, so the row keeps its baseline |
| Stats | `Statistic` `Grid` | `betterWhen` is what makes a figure that fell come out green: fewer failing builds is good news |
| What's new | `Carousel` | Built on scroll snap, so it swipes on mobile and reverses direction under RTL |
| Deploys | `Tabs` `Table` `Badge` `Pagination` | The table is rendered from a column list, so the headings and the cells cannot drift apart |
| Profile form | `Card` `TextField` `Divider` `Chip` `Checkbox` `Button` | Save turns on `loading`; a bad address puts an `error` on the field |
| Sidebar | `Card` `RadioGroup` `Switch` `Slider` | A settings list puts its labels in a column and lines the switches up on the right |
| Release | `Timeline` `Blockquote` `Highlight` `Shortcut` | The timeline is an `<ol>` because the order is the content; `Mod` in the shortcuts resolves per platform |
| Assistant | `AgentSteps` `ToolCall` `Reasoning` `Approval` `StreamingText` `Sources` `PromptInput` `ContextWindow` | The one block that is a transcript rather than a page: the plan grew while it ran, the thinking folded itself away, and the permission that was asked is still there with the answer beside it |
| Cards in a box | `Box` `Card` | `Box` only groups; `Card` takes over wherever structure is needed |

## Next

- Three whole screens built out of these parts: [Landing page](./concept-landing), [Admin dashboard](./concept-dashboard), [Sign-up page](./concept-signup).
- Per-component props and examples are under [Components](../components/).
