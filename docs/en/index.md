---
layout: home

title: Neba
titleTemplate: The React component library

hero:
  name: Neba
  text: A sheet of cut acrylic
  tagline: Behaviour and accessibility from Base UI, styling from Tailwind CSS v4. Controls never move — they answer in colour and depth.
  actions:
    - theme: brand
      text: Get started
      link: /guide/getting-started
    - theme: alt
      text: All components
      link: /components/
    - theme: alt
      text: Examples
      link: /examples/
  image:
    src: /logo-32.png
    alt: Neba

features:
  - title: All components
    details: Every released component on one page. The previews in these docs are not pictures — they are the components, running.
    link: /components/
    linkText: Browse
  - title: An acrylic surface
    details: A translucent fill, a blurred backdrop, and a hairline edge catching the light. A drop shadow is opt-in, not a default.
    link: /design/design-language
    linkText: Design language
  - title: One shared vocabulary
    details: size, color, variant, density, elevation. An md means the same thing on every component.
    link: /design/prop-conventions
    linkText: Prop conventions
  - title: ESM, types included
    details: One dependency, @base-ui/react. Compiled with plain tsc and published mirroring the source tree.
---

## Install

```bash
npm install neba
```

Two lines in your app's CSS entry point are the whole setup — the package registers itself as a Tailwind source, so there is no `@source` for you to write.

```css
@import 'tailwindcss';
@import 'neba/styles.css';
```

```tsx
import { Button } from 'neba';

<Button onClick={save}>Save</Button>;
```

## On one screen

What follows is running inside this page. Type into it, and press save.

<Demo src="showcase/app" />

Per-component props and examples are under [Components](./components/); the same screen is explained block by block under [Examples](./examples/).
