---
title: Sparkline
order: 1
---

# Sparkline

<p class="neba-lede">축도 격자도 범례도 없는, 단어 크기의 추세 그림입니다. 숫자 옆, 문장 안, 표의 한 칸에 들어가 무언가가 어느 쪽으로 가고 있는지를 말합니다.</p>

<Demo src="sparkline/hero" />

```tsx
import { Sparkline } from 'neba';

<Sparkline data={[18, 22, 19, 27, 24, 31, 29, 36]} label="최근 8주 가입" endDot />;
```

작은 차트가 아닙니다. 이것이 붙일 수 있는 숫자는 이미 주변 텍스트가 갖고 있고, 그래서 아무것도 붙이지 않습니다. `series` 배열이 아니라 `data`를 직접 받는 이유도 같습니다.

`data`는 모든 차트가 공유하는 `NebaChartDatum`의 배열입니다. 숫자이거나, 결측을 뜻하는 `null`이거나, 점입니다. 전체 정의는 [LineChart](./line-chart#데이터-형식)에 있습니다.

## Props

<PropsTable name="Sparkline" />

`<div>`의 native 속성이 그대로 전달됩니다. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

## 예시

### shape · curve · endDot · baseline

`shape`가 마크를 정합니다. 추세에는 선, 양에는 area, 세는 것에는 막대입니다. `endDot`은 마지막 점에 dot을 찍습니다. 이만한 크기의 그림이 담을 수 있는 유일한 직접 라벨입니다. `baseline`은 목표나 예산 위치에 가로선을 긋습니다.

<Demo src="sparkline/variants">

<<< @/.vitepress/demos/sparkline/variants.tsx

</Demo>

### nulls

값이 없는 자리를 어떻게 할지 정합니다. `gap`은 끊고, `connect`는 잇고, `zero`는 0으로 읽습니다. [LineChart](./line-chart#nulls)와 같은 세 가지입니다.

여기서 더 중요합니다. 큰 차트에는 구멍을 알아챌 tooltip과 축이 있지만 이 그림에는 둘 다 없어서, 빠진 3주를 조용히 메운 선은 보간된 것인지 아무도 알 수 없습니다. `zero`는 값 자체를 고쳐 쓰므로 그림이 스스로를 맞추는 범위에도 0이 들어가고, 화면 낭독기가 읽는 숫자도 `0`이 됩니다.

<Demo src="sparkline/gaps">

<<< @/.vitepress/demos/sparkline/gaps.tsx

</Demo>

### min · max

Sparkline은 자기 데이터의 범위로 스스로를 채웁니다. 20px 높이에서도 읽히는 이유가 그것이고, 동시에 함정도 그것입니다. `min`과 `max`를 같게 주지 않으면 나란히 놓인 두 Sparkline은 서로 다른 축 위에 그려집니다. 같게 주면 한 열의 Sparkline이 small multiples 차트가 됩니다.

<Demo src="sparkline/shapes">

<<< @/.vitepress/demos/sparkline/shapes.tsx

</Demo>

### size · color · width

`size`는 높이를 정합니다. 페이지가 아니라 옆에 놓인 한 줄의 글자를 기준으로 만든 사다리입니다. `width`는 기본적으로 컨테이너를 채우고, 숫자를 주면 고정됩니다.

`color`는 `NebaColor` 이름이나 임의의 CSS 색을 받습니다. 전체 차트와 달리 이것은 색을 직접 받는데, Sparkline에는 series가 하나뿐이고 팔레트가 나눠 줄 범례도 없기 때문입니다.

```tsx
<Sparkline data={data} size="xs" color="success" width={72} />
```

## 접근성

- `label`이 있는 Sparkline은 값들을 화면에 보이지 않는 텍스트로 렌더링하고, 그 이름을 가진 이미지로 노출됩니다. `label`이 없으면 보조 기술에서 완전히 감춰집니다. 이미 숫자를 말하고 있는 [Statistic](./statistic) 옆에 놓일 때는 맞는 동작이고, 그 밖의 자리에서는 틀린 동작입니다.
- 상호작용하는 요소가 없고, 포인터로만 닿을 수 있는 것도 없습니다.
