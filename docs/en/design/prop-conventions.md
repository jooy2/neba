---
title: Prop conventions
order: 3
---

# Prop conventions

`size="md"` has to mean the same thing on a Button, a TextField and a Dialog. The shared vocabulary lives in [`src/types.ts`](https://github.com/jooy2/neba/blob/main/src/types.ts), and each component takes only the axes it needs. **Do not invent a second spelling for an idea that already has one.**

## The shared types

```ts
type NebaSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
type NebaColor = 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info';
type NebaDensity = 'default' | 'compact';
type NebaVariant = 'solid' | 'outline' | 'text';
type NebaElevation = 0 | 1 | 2 | 3;
```

`NebaStyleProps` bundles the four that most components share.

```ts
interface NebaStyleProps {
  variant?: NebaVariant; // default 'solid'
  size?: NebaSize; // default 'md'
  color?: NebaColor; // default 'primary'
  density?: NebaDensity; // default 'default'
}
```

A component extends it like this.

```ts
export interface ButtonProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'button'>, 'color'> {
  // props that only this component has
}
```

The `Omit<…, 'color'>` is there because the native `color` attribute collides with the name.

## What each axis means

| Prop | The rule |
| --- | --- |
| `variant` | Weight of the surface. One `solid` per screen (the primary action), `outline` for secondary actions, `text` for the lowest weight |
| `size` | The control's height and type scale. See the [design language](./design-language) |
| `color` | A semantic role. Arbitrary colour values are not accepted |
| `density` | **Padding only.** Never the height, never the type scale |
| `elevation` | Drop shadow depth. `0` by default, meaning no shadow at all |

A handful of layout props take a per-breakpoint map on top of their own value — a `span` of `{ xs: 12, md: 6 }`. Which ones, and why the five axes above are deliberately not among them, is [breakpoints](./breakpoints).

## Motion

Two vocabularies, and which one you want depends on whether the motion needs a trigger.

`transition` is an entrance, run once on mount, on the components that **display** something: Box, Card, Statistic, Alert, Chip, Avatar, Icon, Typography and Blockquote. A bare effect name is the whole of what most callers want, and the object form is there for the rest.

```ts
type NebaAnimation =
  'fade' | 'grow' | 'slide' | 'zoom' | 'rotate' | 'blink' | 'reveal' | 'float' | 'shake';
type NebaTransition = NebaAnimation | NebaTransitionOptions;
```

```tsx
<Card transition="fade" />
<Alert transition={{ type: 'slide', from: 'left', duration: 500, delay: 100 }} />
```

It is offered on no component that is pressed. A control that moves under the pointer aiming at it is the one thing the [design language](./design-language) rules out, and a `transition` on a Button would be exactly that.

[HowToSteps](../components/surfaces/how-to-steps) is the one component that takes the same prop and runs it on something other than a mount — a step arriving is what it animates — and it stays inside the rule for the same reason: the effect is on the panel, and the buttons and rows that changed it hold still. It is also the only one with a `'none'` in the union, because it is the only one whose default is an effect rather than nothing.

Anything past a mount — a replay, a scroll trigger, a hover, your own control — is an [`Animate*` component](../components/transitions/animate-fade), and any component can be wrapped in one. They share these settings, which mean the same thing on all of them:

| Prop                 | The rule                                                                 |
| -------------------- | ------------------------------------------------------------------------ |
| `duration` / `delay` | Milliseconds, always. Never a CSS string                                 |
| `easing`             | A CSS easing curve. Defaults to the house one                            |
| `repeat`             | A count, or `'infinite'` — the word CSS uses                             |
| `alternate`          | Every other pass runs backwards, so a repeat returns instead of jumping  |
| `mode`               | `'in'` or `'out'`. `out` is the same animation reversed, held at the end |
| `trigger`            | `'mount'` (default), `'visible'`, `'hover'` or `'manual'`                |
| `play`               | Runs a `manual` one. Each `false` → `true` starts it over                |
| `once` / `threshold` | For `'visible'`: only the first time, and how much has to be on screen   |
| `paused`             | Holds the animation where it is                                          |

Two more go on the nine whose motion is one `@keyframes` on the element itself — everything but AnimateAppear's own stagger, AnimateTyping, AnimateScramble, AnimateCounter, AnimateMarquee, AnimateHeadline and AnimateLighting, whose motion is written elsewhere:

| Prop           | The rule                                                                        |
| -------------- | ------------------------------------------------------------------------------- |
| `stagger`      | Milliseconds added to each child's delay in turn. `0` animates the box itself   |
| `durationStep` | Milliseconds added to each child's duration in turn. Negative speeds them up    |
| `reverse`      | Runs the children last-to-first. Only the order reverses                        |
| `timeline`     | `'time'` (default) or `'view'`, which drives the effect from the scroll instead |
| `range`        | The `animation-range` a `'view'` timeline is mapped over                        |

`timeline="view"` costs `duration`, `delay`, `repeat` and every `trigger`: a scroll-driven animation has no time in it, and the scroll position is what starts it. Where the browser has no `animation-timeline` the effect falls back to running once on mount.

Every effect in the library is switched off entirely by a reduced-motion preference, and none of them is ever the only thing carrying a message.

## State props

| Prop       | Meaning                                                     |
| ---------- | ----------------------------------------------------------- |
| `disabled` | Unavailable. Uses the native `disabled` attribute           |
| `loading`  | In progress. Looks unchanged, gets `aria-busy`, keeps focus |
| `readOnly` | It exists, but not here. Gets `aria-disabled`, keeps focus  |

`loading` and `readOnly` deliberately do not use native `disabled`: dropping out of the focus order costs keyboard users their sense of the page. Activation is stopped in the handler instead.

## Overriding the styling

Three channels, and which one you want depends on what you are changing.

### `className` — the root

Every component takes one, and it is **merged** with the classes the component wrote rather than replacing them. It lands on the component's **root**: for a field that is the column holding the label, the control and the two lines under it; for a Dialog, a Tour or a CommandPalette it is the sheet, which is the element a caller means by the component's name.

```tsx
<Button className="w-full" />
```

[ToastProvider](../components/feedback/toast) is the one component that takes none, and that is the answer rather than an omission — it renders no element of its own, so there is nothing for a root class name to land on.

### `classNames` — the parts behind it

A component that draws one element needs nothing else. A component that draws six — a field with a label, a shell, a control and two lines of text — has parts a caller can see, can want to change, and cannot name. `classNames` names them, one class per part.

```tsx
<TextField classNames={{ label: 'uppercase', control: 'font-mono' }} />
```

**There is never a `root` key.** `className` is the root, on every component, and a second spelling of it is exactly what this page exists to prevent.

The slot names are shared where the parts are shared: `label`, `control`, `description` and `error` mean the same four things on a TextField, a Select, a Checkbox and a RadioGroup. What each component adds beyond them is on its own page.

The slots worth knowing about are the ones with no other way in. A Select's `popup`, a Dialog's `backdrop`, a Tour's `mask` and a CommandPalette's `viewport` all render at the end of `<body>`, outside the element `className` reaches — no selector written against the root will ever find them.

### `style` and the `--n-*` slots

Every per-colour value a component draws is read out of a custom property it sets on itself — `--n-fill`, `--n-accent`, `--n-line`, `--n-ring`, `--n-panel`, `--n-elev` and about a hundred more. The `style` you pass is merged **after** the component's own, so writing one of those is the one override in the library that cannot lose:

```tsx
<Button style={{ '--n-fill': 'rebeccapurple' }} />
```

An inline custom property has no cascade to compete in, which makes this steadier than a class for anything about colour or depth. One rung up, the `--neba-*` tokens on `:root` change the same things for the whole page — see [colour](./color).

### When two utilities disagree

A class you pass and a class the component wrote are both utilities of one class. Neither is more specific, so which one applies is decided by their **order in the generated stylesheet** — and that order is Tailwind's own, not the order you wrote them in.

That means the winner depends on the value rather than on who wrote it. `h-8` is generated before `h-10`, so a component's `h-10` wins. `rounded-full` is generated before `rounded-lg`, so a component's `rounded-lg` wins. `bg-red-500` comes after `bg-(--n-fill)`, so yours wins there.

Tailwind's important modifier is the form that wins every time, and it is what to reach for when the answer has to be yours:

```tsx
<Button size="lg" className="h-8!" />
```

It also beats an inline style, which is what the handful of components that could not rely on a utility use — [IconButton](../components/inputs/icon-button) writes its `border-radius` that way.

### The two stylesheets

Overriding with a class is only meaningful on the `neba/tailwind.css` path, where your classes and the component's are generated in one Tailwind pass and can be ordered against each other at all. `neba/styles.css` is finished CSS and cannot take part in a build you run — on that path, override with your own CSS or with the `--n-*` slots above. See [getting started](../guide/getting-started).

## Naming

- Icon slots are `startIcon` / `endIcon`. `leftIcon`/`rightIcon` invert their meaning under RTL.
- Booleans are positive. `disabled` yes, `notDisabled` no.
- Filling the container is `fullWidth`.
- Event handlers keep their native names and are passed straight through.

## Checklist for a new component

1. A `src/components/{lowercase-name}/` folder with `{PascalCase}.tsx` and an `index.ts` barrel
2. Named exports only (never `export default`)
3. Re-export the barrel from `src/index.ts`
4. Delegate behaviour and accessibility to a Base UI primitive
5. Take the axes you need from the shared vocabulary; define only what genuinely has no name yet
6. `test/components/{name}/{Name}.test.tsx` — **in the same commit**
7. Write `docs/{locale}/components/{group}/{name}.md` — title, lede, preview, props, examples. One page **per locale**
8. Add its rows to `docs/.vitepress/data/props.ts` and its demos to `docs/.vitepress/demos/{name}/`
9. Give it a card in `demos/gallery/all.tsx` and a place on `demos/showcase/app.tsx`
10. `npm run typecheck && npm test && npm run lint` all pass
