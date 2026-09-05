---
title: Rating
order: 21
---

# Rating

<p class="neba-lede">별 한 줄로 점수를 매기는 컨트롤입니다. 고를 수 있게 두면 라디오 그룹이고, <code>readOnly</code>로 두면 평균 별점을 보여 주는 그림 하나가 됩니다.</p>

<Demo src="rating/hero" />

```tsx
import { Rating } from 'neba';

<Rating defaultValue={4} locale="ko" />;
```

## Props

<PropsTable name="Rating" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 예외는 `onChange`로, 여기서 들을 만한 변화는 `onValueChange`입니다.

공통 축(`size` `color`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### count, precision

`count`는 별의 개수이자 만점이고, `precision`은 고를 수 있는 최소 단위입니다. `0.5`면 별 하나가 두 개의 hit area로 나뉘어 반 개씩 고를 수 있습니다.

`precision`은 **고르는** 범위만 정합니다. `value`가 `4.3`이면 어떤 `precision`에서도 별 네 개와 3분의 1로 그려집니다. 평균은 선택이 아니고, 그것을 반올림하는 것은 받은 것과 다른 수를 보고하는 일이기 때문입니다.

<Demo src="rating/precision">

<<< @/.vitepress/demos/rating/precision.tsx

</Demo>

### readOnly

`readOnly`는 컨트롤이 아니라 그림입니다. input이 하나도 남지 않고 `role="img"` 하나가 점수를 문장으로 들고 있으므로, 스무 개의 tab 정지점이 숫자 하나를 보고하는 일이 생기지 않습니다.

라이브러리에서 채도를 빼지 않는 유일한 `readOnly`이기도 합니다. 붙잡아 둔 컨트롤이 아니라 값 자체를 그린 것이고, 회색 별은 점수를 쓸 수 없다는 말이 되기 때문입니다.

<Demo src="rating/readonly">

<<< @/.vitepress/demos/rating/readonly.tsx

</Demo>

### size, color

`size`는 별 하나의 높이를 독립 글리프 사다리에서 가져옵니다. `color`는 라이브러리에서 유일하게 `warning`이 기본값인 자리입니다. 별에 기대되는 호박색이기 때문입니다.

<Demo src="rating/appearance">

<<< @/.vitepress/demos/rating/appearance.tsx

</Demo>

### icon, emptyIcon

두 글리프를 직접 넘길 수 있습니다. 채워진 쪽은 빈 쪽 위에 겹쳐 폭으로 잘리므로, **같은 모양**이어야 반 개가 아래 윤곽선에 정확히 맞습니다.

<Demo src="rating/icons">

<<< @/.vitepress/demos/rating/icons.tsx

</Demo>

### clearable, disabled

이미 고른 별을 다시 누르면 점수가 `0`으로 지워집니다. `clearable={false}`면 지워지지 않습니다.

<Demo src="rating/states">

<<< @/.vitepress/demos/rating/states.tsx

</Demo>

### locale, label, valueLabel

이 컴포넌트가 스스로 지어내는 말은 접근성 이름뿐이고, `locale`이 그 언어를 정합니다. `ko`, `pt-BR`, `zh-Hant` 같은 BCP 47 태그를 받으며 번역이 없는 태그는 영어로 돌아갑니다. `label`은 그룹의 이름을, `valueLabel`은 별 하나와 `readOnly`일 때의 문장을 직접 씁니다.

```tsx
<Rating locale="ko" />
<Rating label="이번 주문은 어떠셨나요?" valueLabel={(value, count) => `${count}개 중 ${value}개`} />
```

### 폼에 넣기

`name`을 주면 라디오들이 그 이름으로 제출됩니다. `required`는 별을 고르기 전까지 폼을 막습니다.

```tsx
<form>
  <Rating name="score" required locale="ko" />
</form>
```

## 접근성

- 고를 수 있는 Rating은 진짜 `<input type="radio">`로 만들어진 `role="radiogroup"`입니다. 줄 전체가 tab 정지점 하나이고, 그 안에서 방향키가 움직이며, 고른 것에 `aria-checked`가 붙고, 폼 전송에 값이 실립니다.
- 별 하나하나가 "5점 만점에 3점"처럼 읽힙니다. 개수가 아니라 분수로 말하는 이유는 별의 개수가 대부분의 언어에서 복수형이기 때문입니다.
- `readOnly`는 input을 모두 없애고 `role="img"` 하나만 남깁니다.
- 페이지의 언어로 읽히도록 `locale`을 지정하거나, `label`과 `valueLabel`에 직접 쓰세요.
