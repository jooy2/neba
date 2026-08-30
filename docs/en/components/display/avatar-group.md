---
title: AvatarGroup
order: 19
---

# AvatarGroup

<p class="neba-lede">A stack of avatars, overlapping, with the ones that did not fit as a count. Who is on a thread, who is in a room, who owns a repository.</p>

<Demo src="avatar-group/hero" />

```tsx
import { Avatar, AvatarGroup } from 'neba';

<AvatarGroup max={3} total={24}>
  <Avatar name="Jane Doe" />
  <Avatar name="Kim Minji" />
  <Avatar name="Alex Park" />
  <Avatar name="Sam Lee" />
</AvatarGroup>;
```

## Props

<PropsTable name="AvatarGroup" />

Every native `<div>` attribute passes through, apart from `color`. `size`, `shape`, `variant`, `color` and `elevation` are passed to every [Avatar](./avatar) in the group; an avatar's own prop still wins, which is what lets one of them be marked out from the rest.

The first avatar is on top. A stack read left to right is read front to back, so the one the group is about comes first rather than last.

## Examples

### max · total

`max` is how many are drawn before the rest become a count. `total` is how many there are altogether, for a group that was handed only the first few — without it the count comes from the children, which is right only when all of them were passed.

<Demo src="avatar-group/max">

<<< @/.vitepress/demos/avatar-group/max.tsx

</Demo>

### size

<Demo src="avatar-group/sizes">

<<< @/.vitepress/demos/avatar-group/sizes.tsx

</Demo>

### overlap

How far each avatar sits under the one before it — a number of pixels or any CSS length. Left out it is a fraction of `size`, so the stack looks the same at every step. `0` sets them side by side.

<Demo src="avatar-group/overlap">

<<< @/.vitepress/demos/avatar-group/overlap.tsx

</Demo>

## Accessibility

- Each avatar keeps its own accessible name, so a screen reader reads the people rather than the picture.
- The count is read as `+3`. Where the group stands for something a reader can act on, wrap it in a [Tooltip](../feedback/tooltip) or a [HoverCard](../surfaces/hover-card) that lists the names.
