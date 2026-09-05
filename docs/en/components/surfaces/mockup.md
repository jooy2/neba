---
title: Mockup
order: 12
---

# Mockup

<p class="neba-lede">A device with a screen you can put anything on: a phone, a tablet, a monitor or a laptop, with the system's own status bar, dock or taskbar drawn on it. The screen is a viewport at the device's real resolution, so the content inside is laid out against a phone rather than against the page.</p>

<Demo src="mockup/hero" align="center" minHeight="440" />

```tsx
import { Mockup } from 'neba';

<Mockup device="mobile" os="ios" width={260}>
  <YourScreen />
</Mockup>;
```

## Props

<PropsTable name="Mockup" />

Native `<div>` attributes pass through, and `render` swaps the element. The shared axes are described in [prop conventions](../../design/prop-conventions).

Three props belong to one device and are ignored on the others: `hardware` is a desktop's, `orientation` is a handheld's, and an `os` a device does not run falls back to that device's default.

## Examples

### device

`device` is the only prop with no default. It picks the shape, the resolution ladder and which systems are on offer: a desktop runs `macos`, `windows` or `linux`, a tablet `ipados` or `android`, a phone `ios` or `android`.

<Demo src="mockup/devices" minHeight="320">

<<< @/.vitepress/demos/mockup/devices.tsx

</Demo>

### Sizing the mockup

`width` and `height` set how big the device is drawn on the page: a number in pixels, or any CSS length. Given one, the other follows the device's proportion; given neither, it fills the width it is in. Whatever it comes to, the screen inside stays at its own resolution and the whole device is scaled to fit.

```tsx
<Mockup device="mobile" width={260} />
<Mockup device="desktop" height={320} />
<Mockup device="tablet" width="100%" />
```

### size and resolution

`size` is a five-step ladder of real resolutions per device: a phone from 320 to 430 CSS pixels wide, a desktop from 1024 to 1920. `resolution` takes a `{ width, height }` pair and overrides it.

Because the screen is a container named `neba-screen`, content inside can answer to the device with a container query rather than to the window. Both mockups below are 300 pixels wide on the page; only the screens behind them differ.

<Demo src="mockup/resolution" minHeight="280">

<<< @/.vitepress/demos/mockup/resolution.tsx

</Demo>

### os

`os` decides which bars are drawn and where: a menu bar and a floating dock, a centred taskbar, a top bar with a dock down the leading edge. The chrome is an impression rather than a copy: abstract shapes in Neba's own tokens, with the clock as the only text.

<Demo src="mockup/os" minHeight="300">

<<< @/.vitepress/demos/mockup/os.tsx

</Demo>

On a handheld the pair is a status bar and the bar at the bottom: a home indicator on `ios` and `ipados`, three navigation glyphs on `android`.

<Demo src="mockup/handhelds" minHeight="360">

<<< @/.vitepress/demos/mockup/handhelds.tsx

</Demo>

### hardware

On a desktop, `hardware` is what holds the screen up: a stand under it, or a keyboard in front of it. It is ignored on a tablet and a phone.

<Demo src="mockup/hardware" minHeight="340">

<<< @/.vitepress/demos/mockup/hardware.tsx

</Demo>

### bezel

`bezel` is how much hardware there is around the screen. `none` is not a thinner frame but no hardware at all: the screen on its own with its corners cut. `thick` is an older device: narrow sides with a forehead and a chin.

<Demo src="mockup/bezel" minHeight="300">

<<< @/.vitepress/demos/mockup/bezel.tsx

</Demo>

### finish

`finish` is what the hardware is made of. The three are fixed colours rather than theme tokens, so a graphite phone stays graphite on a page switched to dark.

<Demo src="mockup/finish" minHeight="300">

<<< @/.vitepress/demos/mockup/finish.tsx

</Demo>

### notch

`notch` is the camera cut-out: a `dynamic-island`, a `notch`, a round `punch-hole`, or `none`. It defaults to what the device would have: an island on an iOS phone, a punch hole on an Android one, nothing on a tablet or a desktop.

It is hardware rather than chrome, so it is drawn whether or not `systemUi` is on, and it moves to the leading edge in landscape.

<Demo src="mockup/notch" minHeight="300">

<<< @/.vitepress/demos/mockup/notch.tsx

</Demo>

### orientation

`orientation` turns a handheld. The screen, the bezel and the cut-out all turn with it. A desktop ignores it, because its stand does not turn.

<Demo src="mockup/orientation" minHeight="280">

<<< @/.vitepress/demos/mockup/orientation.tsx

</Demo>

### systemUi

Every bar takes its own space rather than covering the content, so `systemUi={false}` gives the screen back to `children` rather than uncovering anything that was hidden.

<Demo src="mockup/system-ui" minHeight="360">

<<< @/.vitepress/demos/mockup/system-ui.tsx

</Demo>

### scroll

Content taller than the screen is clipped by default, which is what a still picture of a device wants. `scroll` makes the screen scroll instead.

<Demo src="mockup/scroll" align="center" minHeight="340">

<<< @/.vitepress/demos/mockup/scroll.tsx

</Demo>

### wallpaper

`wallpaper` is what sits behind the content: any CSS `background` value. A colour, a gradient, a `url()`. It defaults to the page's own surface colour.

<Demo src="mockup/wallpaper" minHeight="300">

<<< @/.vitepress/demos/mockup/wallpaper.tsx

</Demo>

### elevation

`elevation` raises the device off the page. The shadow is drawn as a silhouette, so it follows a lid on a neck on a foot rather than the box around them, and it does not shrink when the device is scaled down.

```tsx
<Mockup device="mobile" elevation={2} width={240} />
```

## Accessibility

- Every part of the device is `aria-hidden`: the frame, the bars and the cut-out. What a screen reader reaches is `children` and nothing else, which is what a mockup is: a picture around real content.
- The clock is decoration and is not read out. It is the only text the chrome draws.
- The mockup adds no role and no name of its own. Give it one (`aria-label`, or a `<figure>` with a caption through `render`) when the picture itself carries meaning on the page.
- Content inside stays interactive and focusable. A device scaled to a quarter of its size has controls a quarter of the size, which is worth knowing before putting a form in one.
