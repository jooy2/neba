---
title: Tour
order: 12
---

# Tour

<p class="neba-lede">A guided walk over a page that already exists — the three things a new reader has to be shown once, pointed at where they actually are.</p>

<Demo src="tour/hero" />

```tsx
import { Tour } from 'neba';

<Tour
  open={open}
  onOpenChange={setOpen}
  steps={[
    { target: '#search', title: 'Find anything', content: 'Everything is behind this field.' },
    { target: '#deploy', title: 'Ship it', content: 'Builds the current branch.', side: 'left' }
  ]}
/>;
```

## Props

<PropsTable name="Tour" />

### TourStep

<PropsTable name="TourStep" />

It is [HowToSteps](../surfaces/how-to-steps) turned inside out. That component puts the instructions _in_ the page and the reader follows them; this one leaves the page as it is and stands over it. The steps are therefore given by selector: what a tour is about is already on screen, and describing it a second time inside the card would be two copies to keep in step.

## Examples

### steps · target

Each step names its target with a CSS selector, read against the page as it is at that moment. A step with no `target` is centred with nothing cut out — which is what a welcome step and a closing step are.

<Demo src="tour/centred">

<<< @/.vitepress/demos/tour/centred.tsx

</Demo>

### open · step

`open` runs the tour and `step` is which stop it is on; both have uncontrolled counterparts and both report their changes. `onFinish` is called when the last step's button is pressed, before the tour closes.

### mask

Dims the page and cuts the target out of the dimming. The dimming never takes the pointer, so the control being pointed at can still be used — which is the difference between a tour and a sequence of dialogs.

<Demo src="tour/mask">

<<< @/.vitepress/demos/tour/mask.tsx

</Demo>

### locale and the labels

The buttons and the counter come from `locale`. `previousLabel`, `nextLabel`, `doneLabel` and `skipLabel` write any of them out instead.

### className · classNames

`className` lands on the card — the popup each step is written on. The dimming behind it is a sibling of that popup rather than a descendant, so it is reached through `classNames.mask` and no other way.

```tsx
<Tour
  steps={steps}
  className="max-w-sm"
  classNames={{ mask: 'bg-black/70', footer: 'justify-between' }}
/>
```

The slots are `mask`, `title`, `description`, `close` and `footer`. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

## Accessibility

- The card is a dialog named by its title and described by its content, and focus moves into it as each step opens.
- Escape ends the tour unless `dismissible` is off. A press outside it does not: using the page is what the tour is for.
- A tour is never the only way to something. Whatever it points at has to be findable without it — a reader who dismissed it, or never saw it, gets no second showing.
