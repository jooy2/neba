---
title: Avatar
order: 15
---

# Avatar

<p class="neba-lede">사람이나 사물의 그림을 정해진 크기로 그립니다. 그림이 있으면 그림을, 없으면 이니셜이나 글리프, 실루엣을 대신 그리기 때문에 빈 상자가 되는 일이 없습니다.</p>

<Demo src="avatar/hero" />

```tsx
import { Avatar } from 'neba';

<Avatar src="/people/jane.jpg" name="홍길동" />
<Avatar name="홍길동" />
<Avatar shape="square" variant="solid" color="info">N</Avatar>;
```

## Props

<PropsTable name="Avatar" />

나머지 `<span>` 속성은 모두 루트로 전달됩니다. `<img>`는 `src`, `srcSet`, `alt`를 직접 받고, 그 밖에 필요한 속성은 `imageProps`에 넣습니다.

공통 축(`variant` `size` `color` `elevation`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다. `density`는 없습니다. 아바타에는 바꿀 여백이 없기 때문입니다.

## 예시

### variant와 color

`solid`는 채운 원, `outline`은 테두리와 옅은 panel, 기본값인 `text`는 가장자리 없이 배경만 얇게 깔린 형태입니다. `color`는 여섯 가지 역할 색 중 하나를 고릅니다. 그림이 로딩되면 셋 다 가장자리만 남기고 보이지 않습니다.

<Demo src="avatar/variants">

<<< @/.vitepress/demos/avatar/variants.tsx

</Demo>

### size

컨트롤 높이 사다리를 그대로 씁니다. 22, 26, 32, 40, 48px이며, 그래서 같은 줄의 [Button](../inputs/button)과 높이가 맞습니다. 이니셜은 줄이 아니라 상자를 기준으로 잡혀서 지름의 약 40%가 됩니다.

<Demo src="avatar/sizes">

<<< @/.vitepress/demos/avatar/sizes.tsx

</Demo>

### shape

기본 크롭은 `circle`입니다. `square`는 대신 모서리를 상자의 약 28%만큼 잘라 냅니다. 사각형 가장자리까지 그려진 로고나 저장소 아이콘은 원형으로 자르면 그 가장자리를 잃기 때문에, 이런 것에는 `square`가 맞습니다.

<Demo src="avatar/shape">

<<< @/.vitepress/demos/avatar/shape.tsx

</Demo>

### name과 initials

`name`은 세 가지 일을 합니다. 그림의 `alt`가 되고, 이니셜이 여기서 파생되며, screen reader는 이니셜 대신 이 문장을 읽습니다.

규칙은 첫 단어의 첫 글자와 마지막 단어의 첫 글자입니다. `Jane Doe`는 `JD`, `jane miriam van doe`도 `JD`, `홍길동`은 `홍`이 됩니다. 분해된 악센트는 먼저 결합하므로 `Ängela`는 `A`가 아니라 `Ä`입니다. 규칙이 엉뚱한 글자를 고른다면 `initials`에 직접 씁니다.

<Demo src="avatar/initials">

<<< @/.vitepress/demos/avatar/initials.tsx

</Demo>

### children

`children`은 이니셜 대신 그릴 fallback입니다. 아이콘, 로고, 이모지 하나가 여기에 들어갑니다. 안에 있는 `<svg>`는 상자의 55% 크기로 맞춰집니다. `children`도 `initials`도 `name`도 없으면 실루엣을 그립니다.

셋 중 무엇이 보이는지는 그림의 로딩 상태가 정합니다. `delay`를 주면 fallback을 잠시 미룰 수 있어서 캐시된 그림 앞에서 이니셜이 번쩍이지 않고, 상태 자체는 `onLoadingStatusChange`로 읽습니다.

<Demo src="avatar/fallback">

<<< @/.vitepress/demos/avatar/fallback.tsx

</Demo>

### 상태 표시

Avatar에는 상태 점이 없습니다. `overlap="circle"`을 준 [Badge](./badge)로 감싸면 됩니다. 원의 모서리가 bounding box보다 안쪽에 있는 만큼 표식을 더 당겨 줍니다.

<Demo src="avatar/status">

<<< @/.vitepress/demos/avatar/status.tsx

</Demo>

## 접근성

- `JD`는 소리 내어 읽으면 사람이 아니라 글자 두 개입니다. `name`을 주면 이니셜은 accessibility tree에서 빠지고 그 이름이 fallback의 accessible name이 됩니다.
- `name`도 `alt`도 없으면 `<img>`의 `alt`는 빈 문자열이 되어 파일 이름이 읽히는 대신 건너뛰어집니다. 사람 이름 옆에 놓인 아바타에는 이쪽이 맞습니다. 그림이 그 사람을 가리키는 유일한 단서일 때만 `alt`를 넘기세요.
- `name` 없이 `children` 글리프만 있으면 아무 말도 하지 않습니다. 글리프가 혼자 뜻을 지고 있다면 `name`을 주거나 감싼 요소에 `aria-label`을 붙이세요.
