---
title: Breadcrumb
order: 14
---

# Breadcrumb

<p class="neba-lede">지금 보고 있는 페이지 위쪽의 경로입니다. 화면이 계층 안에 놓여 있고 읽는 사람이 다시 위로 올라갈 수 있어야 할 때 씁니다.</p>

<Demo src="breadcrumb/hero" />

```tsx
import { Breadcrumb, BreadcrumbItem } from 'neba';

<Breadcrumb>
  <BreadcrumbItem href="/">Home</BreadcrumbItem>
  <BreadcrumbItem href="/projects">Projects</BreadcrumbItem>
  <BreadcrumbItem>Settings</BreadcrumbItem>
</Breadcrumb>;
```

## Props

### Breadcrumb

<PropsTable name="Breadcrumb" />

나머지 `<nav>` 속성은 그대로 전달됩니다. 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

### BreadcrumbItem

<PropsTable name="BreadcrumbItem" />

나머지 `<li>` 속성은 그대로 각 단계에 전달됩니다.

## 예시

### separator

`separator`는 네 가지 이름 — `chevron`·`arrow`·`slash`·`dot` — 중 하나이거나 아무 노드나 받습니다. 방향을 가리키는 둘은 RTL에서 반대로 돌아갑니다.

<Demo src="breadcrumb/separators">

<<< @/.vitepress/demos/breadcrumb/separators.tsx

</Demo>

### maxItems

`maxItems`를 넘는 트레일은 가운데를 `…` 뒤로 접고, 그것을 누르면 다시 펼칩니다. 양 끝에 몇 개를 남길지는 `itemsBeforeCollapse`와 `itemsAfterCollapse`가 정하며 둘 다 기본값은 `1`입니다. `expandable={false}`는 접힘을 표시로만 남깁니다.

접기는 두 단계 이상을 걷어낼 때만 일어납니다. 한 단계를 대신 서는 것은 트레일을 짧게 하는 대신 길게 만들기 때문입니다.

<Demo src="breadcrumb/collapse">

<<< @/.vitepress/demos/breadcrumb/collapse.tsx

</Demo>

### 현재 단계

마지막 단계는 지금 보고 있는 페이지이므로, `href`를 주더라도 링크가 되지 않습니다. 앞쪽 단계에 `current`를 붙이면 그 표시가 옮겨 가고, 마지막 단계에서는 걷힙니다.

### startIcon

<Demo src="breadcrumb/icons">

<<< @/.vitepress/demos/breadcrumb/icons.tsx

</Demo>

### size

<Demo src="breadcrumb/sizes">

<<< @/.vitepress/demos/breadcrumb/sizes.tsx

</Demo>

## 접근성

- 트레일은 `label`이 이름을 주는 `nav`이며(기본값 `Breadcrumb`), 그 안에 순서 있는 리스트가 들어갑니다.
- 현재 단계에는 `aria-current="page"`가 붙고, 한 트레일에서 이것을 가지는 단계는 언제나 하나뿐입니다.
- 구분자는 `aria-hidden`이므로 screen reader는 단계만 읽고 사이의 기호는 읽지 않습니다.
- `…`는 `expandLabel`이 이름을 주는 실제 버튼입니다. `expandable={false}`이면 표시일 뿐이며 reader에게는 감춰집니다.
- nav 이름과 `…` 버튼의 이름을 `locale`이 정합니다. `label`과 `expandLabel`로 직접 쓸 수도 있습니다.
