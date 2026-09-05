---
title: Flex
order: 12
---

# Flex

<p class="neba-lede">행이거나 열이며, 어느 너비에서 하나가 다른 하나로 바뀌는지를 정합니다. 아무것도 그리지 않습니다 — 표면도, 여백도, 요청하지 않는 한 거터조차도.</p>

<Demo src="flex/hero" />

```tsx
import { Flex } from 'neba';

<Flex direction={{ xs: 'vertical', md: 'horizontal' }} spacing={3}>
  <Card />
  <Card />
</Flex>;
```

## Props

<PropsTable name="Flex" />

`<div>`의 기본 속성은 그대로 전달되며, `render`로 요소를 바꿀 수 있습니다. breakpoint별 map은 [breakpoints](../../design/breakpoints)에서, 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

## 예시

### direction

`horizontal`은 row, `vertical`은 column입니다. CSS의 네 단어 대신 라이브러리 자신의 두 단어를 쓰므로 Flex와 [Stack](./stack)이 같은 것을 같은 말로 말합니다. 반응형이고, 이 컴포넌트가 존재하는 이유가 바로 이 prop입니다 — 자리가 나면 나란히, 나기 전에는 위아래로 놓이는 컨트롤 한 쌍.

<Demo src="flex/direction">

<<< @/.vitepress/demos/flex/direction.tsx

</Demo>

### spacing

거터이며 Tailwind의 spacing 스케일 위에 있습니다 — `spacing={4}`는 `1rem`으로 `gap-4`와 같은 길이입니다. [GridContainer](./grid)와 같은 prop, 같은 스케일이라 숫자 하나가 두 컴포넌트에서 같은 길이를 뜻하며, 다른 것들처럼 map도 받습니다. `rowSpacing`과 `columnSpacing`은 한 축만 정하는데, 각각 `spacing`을 대체하는 것이 아니라 그 _위에_ 덮이므로 한 breakpoint만 적어도 나머지에서 거터가 사라지지 않습니다.

<Demo src="flex/spacing">

<<< @/.vitepress/demos/flex/spacing.tsx

</Demo>

### justifyContent · alignItems

flexbox의 어휘를, 라이브러리의 나머지가 쓰는 철자로 씁니다. `justifyContent`는 줄에서 남은 공간을 나누고, `alignItems`는 children이 줄을 가로질러 어디에 서는지를 정합니다. 둘 다 반응형이 아닙니다 — 이들은 class name이고, breakpoint별 class map은 Flex를 그리는 모든 페이지의 번들에 사다리 다섯 벌을 넣게 됩니다.

<Demo src="flex/alignment">

<<< @/.vitepress/demos/flex/alignment.tsx

</Demo>

### wrap

기본이 꺼짐이며, 이는 [GridContainer](./grid)와 반대입니다. 그리드는 열이고 줄바꿈은 열이 하는 일이지만, Flex는 대개 한 줄에 머무르면서 children이 줄어들게 두어야 하는 툴바나 필드 줄입니다.

```tsx
<Flex wrap spacing={2}>
  {tags.map((tag) => (
    <Chip key={tag}>{tag}</Chip>
  ))}
</Flex>
```

### Flex와 Grid 중에서

Flex는 children이 무엇인지에 따라 크기를 정하고, [Grid](./grid)는 열 개수에 맞춰 정합니다. "이것들을 한 줄에"가 답이면 Flex입니다 — 툴바, 필드와 그 버튼, 카드의 footer. 너비가 페이지의 다른 것과 맞아떨어져야 한다면 Grid이고, 열이 존재하는 이유가 그것입니다.

### reverse

`direction`이 고른 축을 따라 children을 반대로 흐르게 하며, 모든 breakpoint에 한 번에 적용됩니다. 시각적 순서만 바꾸므로 screen reader가 읽는 순서와 tab 순서는 여전히 DOM 순서입니다. 순서 자체가 의미를 지닌 줄을 뒤집으면 둘이 어긋납니다.

```tsx
<Flex direction="vertical" reverse>
  <Newest />
  <Oldest />
</Flex>
```

## 접근성

- 이 상자는 role도 이름도 더하지 않습니다. `<nav>`나 `<ul>`이어야 한다면 `render`를 쓰세요 — 의미를 지니는 것은 태그입니다.
- `reverse`와, children을 옮기는 `justifyContent` 값들은 보이는 것을 바꿀 뿐 읽히는 것을 바꾸지 않습니다. 순서가 중요하다면 읽혀야 하는 순서대로 children을 두세요.
