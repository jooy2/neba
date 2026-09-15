---
title: Flex
order: 12
---

# Flex

<p class="neba-lede">행이거나 열이며, 어느 너비에서 하나가 다른 하나로 바뀌는지를 정합니다. 표면도 여백도 그리지 않고, 거터도 요청해야 그립니다.</p>

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

`horizontal`은 row, `vertical`은 column입니다. breakpoint별 map을 받으므로, 자리가 나면 나란히 놓이고 나기 전에는 위아래로 쌓이는 컨트롤 한 쌍을 만들 수 있습니다.

<Demo src="flex/direction">

<<< @/.vitepress/demos/flex/direction.tsx

</Demo>

### spacing

`spacing`은 Tailwind의 spacing 스케일 위의 거터입니다. `spacing={4}`는 `1rem`으로 `gap-4`와 같은 길이입니다. [GridContainer](./grid)와 같은 스케일이고, breakpoint별 map도 받습니다. `rowSpacing`은 세로 간격, `columnSpacing`은 가로 간격이며 `direction`과 상관없이 그렇습니다. 각각 `spacing`을 대체하는 것이 아니라 그 _위에_ 덮이므로 한 breakpoint만 적어도 나머지에서 거터가 사라지지 않습니다.

<Demo src="flex/spacing">

<<< @/.vitepress/demos/flex/spacing.tsx

</Demo>

### justifyContent · alignItems

`justifyContent`는 줄에서 남은 공간을 나누고, `alignItems`는 children이 줄을 가로질러 어디에 서는지를 정합니다. 둘 다 breakpoint별 map은 받지 않습니다.

<Demo src="flex/alignment">

<<< @/.vitepress/demos/flex/alignment.tsx

</Demo>

### wrap

기본은 꺼짐이라 row는 한 줄에 머물고 children이 줄어듭니다. 너비가 모자랄 때 다음 줄로 이어지게 하려면 켜세요. chip을 늘어놓은 줄이 그런 경우입니다.

```tsx
<Flex wrap spacing={2}>
  {tags.map((tag) => (
    <Chip key={tag}>{tag}</Chip>
  ))}
</Flex>
```

### reverse

`direction`이 고른 축을 따라 children을 반대로 흐르게 하며, 모든 breakpoint에 한 번에 적용됩니다. 시각적 순서만 바꾸므로 screen reader가 읽는 순서와 tab 순서는 여전히 DOM 순서입니다. 순서 자체가 의미를 지닌 줄을 뒤집으면 둘이 어긋납니다.

```tsx
<Flex direction="vertical" reverse>
  <Newest />
  <Oldest />
</Flex>
```

## 접근성

- 이 상자는 role도 이름도 더하지 않습니다. `<nav>`나 `<ul>`이어야 한다면 `render`를 쓰세요. 의미를 지니는 것은 태그입니다.
- `reverse`와, children을 옮기는 `justifyContent` 값들은 보이는 것을 바꿀 뿐 읽히는 것을 바꾸지 않습니다. 순서가 중요하다면 읽혀야 하는 순서대로 children을 두세요.
