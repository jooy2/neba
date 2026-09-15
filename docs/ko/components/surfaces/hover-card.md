---
title: HoverCard
order: 16
---

# HoverCard

<p class="neba-lede">포인터가 어떤 대상 위에 머무를 때 열려, 그 너머에 있는 것을 미리 보여주는 카드입니다. 멘션 뒤의 사람, 링크 뒤의 저장소, id 뒤의 배포 같은 것입니다.</p>

<Demo src="hover-card/hero" />

```tsx
import { HoverCard, TextLink } from 'neba';

<HoverCard trigger={<TextLink href="/people/nadiarowan">@nadiarowan</TextLink>} title="Nadia Rowan">
  Maintainer · 214 commits
</HoverCard>;
```

## Props

<PropsTable name="HoverCard" />

`<div>`의 기본 속성은 popup으로 전달됩니다. 컴포넌트가 직접 소유하는 `color`, `title`, `children`만 예외입니다. `variant`와 `elevation`은 없습니다.

## 예시

### trigger

`trigger`는 children이 아니라 요소 하나를 받고, 카드는 감싸는 요소 없이 그 요소에 병합됩니다. 그래서 레이아웃은 그대로이고 링크는 링크로 남습니다. 보통 [TextLink](../display/text-link)나 [Avatar](../display/avatar)를 넘깁니다.

### delay · closeDelay

`delay`는 카드가 열리기까지 포인터가 머물러야 하는 시간이고, `closeDelay`는 포인터가 떠난 뒤 카드가 남아 있는 시간입니다. `closeDelay` 덕분에 포인터가 trigger와 카드 사이의 빈틈을 건널 수 있습니다.

<Demo src="hover-card/delay">

<<< @/.vitepress/demos/hover-card/delay.tsx

</Demo>

### side · align · arrow

`side`는 카드가 나타나는 trigger의 모서리이고 공간이 없으면 반대편으로 뒤집힙니다. `align`은 그 모서리 위에서의 위치입니다. `arrow`는 꼭지를 그리며 기본값은 꺼짐입니다.

<Demo src="hover-card/placement">

<<< @/.vitepress/demos/hover-card/placement.tsx

</Demo>

### size

`size`는 타입 스케일과 안쪽 여백, 그리고 카드가 넓어질 수 있는 한계를 정합니다. `width`는 마지막 항목만 따로 덮어씁니다.

<Demo src="hover-card/sizes">

<<< @/.vitepress/demos/hover-card/sizes.tsx

</Demo>

## 접근성

- 카드 안의 내용은 trigger가 향하는 페이지에도 반드시 존재해야 합니다. hover가 없는 키보드, 포인터가 없는 터치스크린, 스크린 리더는 모두 그 경로로 도달하므로 이 카드가 유일한 통로가 되어서는 안 됩니다.
- 포인터로 카드 안까지 들어갈 수 있어 안의 링크를 따라갈 수 있고, 포인터가 안에 있는 동안에는 열린 채로 유지됩니다.
- Escape로 닫힙니다.
