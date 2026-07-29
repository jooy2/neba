---
title: Prop conventions
order: 4
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

## State props

| Prop       | Meaning                                                     |
| ---------- | ----------------------------------------------------------- |
| `disabled` | Unavailable. Uses the native `disabled` attribute           |
| `loading`  | In progress. Looks unchanged, gets `aria-busy`, keeps focus |
| `readOnly` | It exists, but not here. Gets `aria-disabled`, keeps focus  |

`loading` and `readOnly` deliberately do not use native `disabled`: dropping out of the focus order costs keyboard users their sense of the page. Activation is stopped in the handler instead.

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
