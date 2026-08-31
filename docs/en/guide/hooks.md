---
title: Hooks
order: 2
---

# Hooks

<p class="neba-lede">The hooks the components already run on, offered so an application can use the same ones. They are imported from <code>neba/hooks</code>, or from the package root along with everything else.</p>

```tsx
import { useDisclosure, useMediaQuery, useShortcut } from 'neba/hooks';
```

Every one of these is machinery the library needed for itself. That is the whole selection rule: there is no general-purpose hook collection here, and there is not going to be one — a debounce or a `localStorage` wrapper is not a component library's job.

## useDisclosure

The caller's half of the `open` / `onOpenChange` pair that [Dialog](../components/feedback/dialog), [Drawer](../components/surfaces/card), [Popover](../components/surfaces/popover), [Tour](../components/feedback/tour), [Menu](../components/inputs/menu) and all four pickers take.

```tsx
const { open, onOpen, onClose, onToggle, setOpen } = useDisclosure();

<Button onClick={onOpen}>Edit</Button>
<Dialog open={open} onOpenChange={setOpen} title="Edit">…</Dialog>
```

`useDisclosure(true)` starts open. All four functions are stable for the life of the component, so passing `onClose` to a memoised child does not re-render it every time the panel opens.

## useMediaQuery · useBreakpoint

```tsx
const wide = useMediaQuery('(width >= 60rem)');
const desktop = useBreakpoint('lg');
```

`useBreakpoint('lg')` is `lg:` in a class name, asked in JavaScript — the widths are one table, so a component that branches here and a utility that branches in CSS change at the same pixel. `xs` is `0rem`, so it is always true.

There is one live `MediaQueryList` per query string for the whole page, however many components ask. Both hooks answer `false` on a server, where there is no window: **a layout that must not flash belongs in CSS**, and these are for the decisions CSS cannot make — which component to render at all.

## usePrefersReducedMotion

```tsx
const still = usePrefersReducedMotion();
```

The CSS half of this is already handled: every keyframe in the stylesheet is switched off at once when a reader asks for less motion. This is for motion written in JavaScript, where there is no rule to switch off — a timer that advances a carousel, a count that animates, a scroll you drive yourself.

## useElementSize

```tsx
const [ref, { width, height }] = useElementSize<HTMLDivElement>();

<div ref={ref} />;
```

One shared `ResizeObserver` for the page rather than one per subscriber. It measures once as soon as the element is there rather than waiting to be told, so the first render already has a size — a `ResizeObserver` reports its first entry a task later, and a component that renders at `0 × 0` until then lays out twice.

## useOnScreen

```tsx
const [ref, seen] = useOnScreen<HTMLDivElement>({ threshold: 0.2 });
```

`once` defaults to `true`: it stops watching after the first sighting, which is what the usual job — mount it, start it, load it — actually needs. Pass `once: false` to keep following.

Where the browser has no `IntersectionObserver` it answers `true`, not `false`. A caller cannot know without one, and showing the thing is the only fallback that cannot hide it forever.

## useShortcut

```tsx
useShortcut('Mod+K', () => setOpen(true));
useShortcut('?', () => setHelpOpen(true));
```

A key combination bound on the window, spelled the way [Shortcut](../components/display/shortcut) draws it — so the key cap on the screen and the key that fires are one string. `Mod` is Command on a Mac and Control everywhere else, and the modifiers are matched exactly.

| Option | Default | What it does |
| --- | --- | --- |
| `enabled` | `true` | Stop listening without unmounting |
| `ignoreWhileTyping` | `true` | Skip while the focus is in an input, a textarea or a `contenteditable` |
| `preventDefault` | `true` | Call `preventDefault` on a match |

`ignoreWhileTyping` is what makes a bare `/` or `?` bindable at all — a single-letter shortcut that fires inside a search box eats what somebody was writing. Turn it off for a combination with a modifier, which is usually meant to work everywhere.

The handler is held in a ref, so the listener is bound once per combination rather than re-bound on every render that closes over new state — and it still sees the newest one.

For a key inside a field rather than on the window, use the `shortcuts` prop on [TextField](../components/inputs/text-field), [NumberField](../components/inputs/number-field) or [Combobox](../components/inputs/combobox). Same spelling, bound to the control.
