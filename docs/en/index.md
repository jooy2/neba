---
layout: home

title: Neba
titleTemplate: The React component library

hero:
  name: Neba
  text: A React component library at home on the web and in your app
  tagline: Fifty-odd components, one line to install. Dark mode, accessibility and types are already in the box.
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
  - title: Fifty-odd components
    details: Buttons and inputs through Dialog, Table, DatePicker and Toast. Enough to build a whole screen without leaving.
    link: /components/
    linkText: Browse
  - title: TypeScript first
    details: Declarations ship with the package. Your editor knows the prop names and the values they take before you do.
  - title: Dark mode built in
    details: One class on an ancestor and every component follows. No second theme to write, no colours to redeclare.
  - title: One shared vocabulary
    details: size, color, variant, density, elevation. An md means the same thing on every component.
    link: /design/prop-conventions
    linkText: Prop conventions
---

## Why Neba

<div class="neba-why">
  <div class="neba-why-card">
    <h3>Tested, not asserted</h3>
    <p>Every component carries its own tests, run in a real browser across three operating systems and three engines on every change.</p>
  </div>
  <div class="neba-why-card">
    <h3>Accessible by default</h3>
    <p>Roles, labels, keyboard operation and focus management live inside the components rather than being bolted on later.</p>
  </div>
  <div class="neba-why-card">
    <h3>Markup crawlers can read</h3>
    <p>Semantic elements, and the same output under SSR. What the crawler sees is what the user sees.</p>
  </div>
  <div class="neba-why-card">
    <h3>Platform agnostic</h3>
    <p>Web, hybrid apps, Electron. The same code draws the same screen in any React environment.</p>
  </div>
  <div class="neba-why-card">
    <h3>Built for a modern front end</h3>
    <p>Published as ESM and tree-shakeable, so only what you import ends up in the bundle.</p>
  </div>
  <div class="neba-why-card">
    <h3>Ready for coding agents</h3>
    <p>Prop names are consistent across components and the documentation is structured, so an agent has little left to guess.</p>
  </div>
</div>

## Component preview

What follows is running inside this page. Type into it, and press save.

<Demo src="showcase/app" />

Per-component props and examples are under [Components](./components/); the same screen is explained block by block under [Examples](./examples/). Installing and wiring it up is one page: [Getting started](./guide/getting-started).
