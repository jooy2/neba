---
title: Rating
order: 21
flutter: true
---

# Rating

<p class="neba-lede">별 한 줄로 점수를 매기는 컨트롤입니다. 고를 수 있게 두면 라디오 그룹이고, <code>readOnly</code>로 두면 평균 별점을 보여 주는 그림 하나가 됩니다.</p>

<Demo src="rating/hero" />

::: fw react

```tsx
import { Rating } from 'neba';

<Rating defaultValue={4} locale="ko" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaRating(defaultValue: 4);
```

:::

## Props

<PropsTable name="Rating" />

::: fw react

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 예외는 `onChange`로, 여기서 들을 만한 변화는 `onValueChange`입니다.

:::

::: fw flutter

Rating은 `defaultValue`에서 시작해 자기 점수를 들고 있거나, `value`를 보여 주고 고른 값을 `onValueChange`로 알립니다.

:::

공통 축(`size` `color`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### count, precision

`count`는 별의 개수이자 만점이고, `precision`은 고를 수 있는 최소 단위입니다. `0.5`면 별 하나가 두 개의 hit area로 나뉘어 반 개씩 고를 수 있습니다. 반쪽은 손가락에 필요한 24픽셀보다 좁으므로, 터치 화면에서 누르는 Rating이라면 별을 통째로 고르게 두세요.

`precision`은 **고르는** 범위만 정합니다. `value`가 `4.3`이면 어떤 `precision`에서도 별 네 개와 3분의 1로 그려집니다.

<Demo src="rating/precision">

::: fw react

<<< @/.vitepress/demos/rating/precision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/precision.dart

:::

</Demo>

### readOnly

::: fw react

`readOnly`는 컨트롤이 아니라 그림입니다. input이 하나도 렌더링되지 않고 `role="img"` 하나가 점수를 문장으로 들고 있으므로, 별이 tab 정지점을 하나도 차지하지 않습니다. 채도도 낮추지 않고 별의 색을 그대로 둡니다.

:::

::: fw flutter

`readOnly`는 컨트롤이 아니라 그림입니다. 이미지 노드 하나가 점수를 문장으로 들고 있고, 별은 focus를 받지 않습니다. 채도도 낮추지 않고 별의 색을 그대로 둡니다.

:::

<Demo src="rating/readonly">

::: fw react

<<< @/.vitepress/demos/rating/readonly.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/readonly.dart

:::

</Demo>

### size, color

`size`는 별 하나의 높이를 독립 글리프 사다리에서 가져옵니다. `color`의 기본값은 `warning`입니다.

<Demo src="rating/appearance">

::: fw react

<<< @/.vitepress/demos/rating/appearance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/appearance.dart

:::

</Demo>

### icon, emptyIcon

두 글리프를 직접 넘길 수 있습니다. 채워진 쪽은 빈 쪽 위에 겹쳐 폭으로 잘리므로, **같은 모양**이어야 반 개가 아래 윤곽선에 정확히 맞습니다.

<Demo src="rating/icons">

::: fw react

<<< @/.vitepress/demos/rating/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/icons.dart

:::

</Demo>

### clearable, disabled

이미 고른 별을 다시 누르면 점수가 `0`으로 지워집니다. <Fw react='clearable={false}' flutter='clearable: false' code />면 지워지지 않습니다.

<Demo src="rating/states">

::: fw react

<<< @/.vitepress/demos/rating/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/states.dart

:::

</Demo>

### locale, <Fw react="label" flutter="semanticLabel" />, valueLabel

::: fw react

이 컴포넌트가 스스로 지어내는 말은 접근성 이름뿐이고, `locale`이 그 언어를 정합니다. `ko`, `pt-BR`, `zh-Hant` 같은 BCP 47 태그를 받으며 번역이 없는 태그는 영어로 돌아갑니다. `label`은 그룹의 이름을, `valueLabel`은 별 하나와 `readOnly`일 때의 문장을 직접 씁니다.

```tsx
<Rating locale="ko" />
<Rating label="이번 주문은 어떠셨나요?" valueLabel={(value, count) => `${count}개 중 ${value}개`} />
```

:::

::: fw flutter

이 컴포넌트가 스스로 지어내는 말은 screen reader가 듣는 내용뿐이고, `locale`이 그 언어를 정합니다. `semanticLabel`은 묶음의 이름을, `valueLabel`은 별 하나와 `readOnly`일 때의 문장을 직접 씁니다.

```dart
const NebaRating(locale: Locale('ko'));
NebaRating(
  semanticLabel: '이번 주문은 어떠셨나요?',
  valueLabel: (double value, int count) => '$count개 중 $value개',
);
```

:::

### 폼에 넣기

::: fw react

`name`을 주면 라디오들이 그 이름으로 제출됩니다. `required`는 별을 고르기 전까지 폼을 막습니다.

```tsx
<form>
  <Rating name="score" required locale="ko" />
</form>
```

:::

::: fw flutter

Flutter에는 폼 제출이 없으므로 `name`과 `required`도 없습니다. 점수는 `value`와 `onValueChange`로 호출자가 다룹니다.

:::

## 접근성

::: fw react

- 고를 수 있는 Rating은 진짜 `<input type="radio">`로 만들어진 `role="radiogroup"`입니다. 줄 전체가 tab 정지점 하나이고, 그 안에서 방향키가 움직이며, 고른 것에 `aria-checked`가 붙고, 폼 전송에 값이 실립니다.
- 별 하나하나가 "5점 만점에 3점"처럼 읽힙니다.
- `readOnly`는 input을 모두 없애고 `role="img"` 하나만 남깁니다.
- 독자가 값을 고르는 Rating에서 빈 별은 두 테마 모두에서 페이지와 3:1 이상의 대비를 가집니다. `readOnly` Rating은 빈 별을 옆 별의 흐릿한 자국처럼 더 옅게 그립니다.
- 페이지의 언어로 읽히도록 `locale`을 지정하거나, `label`과 `valueLabel`에 직접 쓰세요.

:::

::: fw flutter

- 고를 수 있는 Rating은 이름이 붙은 라디오 묶음입니다. 줄 전체가 focus 대상 하나이고, 그 안에서 방향키가 움직이며 고르고 양 끝에서 돌아가며, 고른 것이 checked 상태가 됩니다.
- 별 하나하나가 "5점 만점에 3점"처럼 읽힙니다.
- `readOnly`는 점수를 문장으로 가진 이미지 노드 하나만 남깁니다.
- 독자가 값을 고르는 Rating에서 빈 별은 두 테마 모두에서 페이지와 3:1 이상의 대비를 가집니다. `readOnly` Rating은 빈 별을 옆 별의 흐릿한 자국처럼 더 옅게 그립니다.
- 앱의 언어로 읽히도록 `locale`을 지정하거나, `semanticLabel`과 `valueLabel`에 직접 쓰세요.

:::
