---
title: AnimateCounter
order: 9
---

# AnimateCounter

<p class="neba-lede">숫자를 목표값까지 세어 올립니다. 라이브러리에서 유일하게 상자가 아니라 내용 자체가 주제인 애니메이션입니다. 매 프레임 값을 보간하고 형식을 입히는 일은 keyframe이 할 수 있는 것이 아닙니다.</p>

<Demo src="animate-counter/hero" minHeight="140" />

```tsx
import { AnimateCounter, Statistic } from 'neba';

<Statistic label="Monthly active" value={<AnimateCounter value={128400} />} />;
```

## Props

<PropsTable name="AnimateCounter" />

나머지 `<span>` 속성은 루트로 그대로 전달됩니다. `easing`, `repeat`, `alternate`는 없습니다. 숫자는 한쪽에서만 값에 다가갈 수 있으므로 곡선은 고정된 ease-out이고, 반복되는 카운트라는 것은 존재하지 않습니다.

[Statistic](../charts/statistic)과 짝을 이룹니다. Statistic의 `value`가 노드를 받는 것이 이 조합을 위해서입니다. 숫자는 즉시 그리면서 그 주변만 애니메이션하는 대시보드는 강조를 정확히 반대로 둔 것입니다.

## 예시

### format과 locale

`Intl.NumberFormat` 옵션입니다. 통화, 백분율, `1.2M` 같은 compact 표기가 `format` 콜백이 아니라 prop입니다. [Statistic](../charts/statistic)과 진행 표시기들이 받는 것과 같은 prop입니다. 세는 동안에는 `value`와 `from` 중 소수 자릿수가 많은 쪽에 맞춰 반올림하므로, 정수까지 세는 동안에는 정수만 보입니다. 숫자는 모두 같은 폭으로 그려집니다. 상자의 폭은 첫 프레임부터 `value`와 `from` 중 넓은 쪽에 맞춰지므로, 자릿수가 늘어나는 동안에도 뒤에 오는 글자가 밀리지 않습니다. `locale`이 없는 카운터는 렌더링되는 곳의 언어로 숫자를 쓰므로, 서버에서 렌더링하는 페이지라면 `locale`을 넘기세요. 그러지 않으면 서버의 `1,234.5`와 독자의 `1.234,5`가 하이드레이션할 때 어긋날 수 있습니다.

<Demo src="animate-counter/formats" minHeight="240">

<<< @/.vitepress/demos/animate-counter/formats.tsx

</Demo>

### trigger

화면 아래쪽 대시보드에서 손이 가는 것은 `trigger="visible"`입니다. 스크롤해서 닿았을 때 이미 끝나 있는 카운트는 본 적이 없는 것과 같습니다. 시작 전에는 정답이 아니라 `from`에 머뭅니다. 한 번 센 뒤에 `value`가 바뀌면 화면에 보이는 숫자에서부터 이어서 셉니다. `trigger="manual"`이면 `play`가 세기를 시작하고, `play` 값이 올라가면 `from`부터 다시 셉니다. 위 예시의 버튼이 그렇게 합니다.

```tsx
<AnimateCounter value={128400} trigger="visible" />
```

## 접근성

- 완성된 숫자는 첫 프레임부터 스크린 리더를 위해 잘린 상자 안에 들어 있고, 세는 것은 `aria-hidden`인 사본입니다. 볼 수 없는 독자는 중간값 백 개가 아니라 답을 듣습니다.
- 세는 숫자는 문서에 글자로 들어가지 않고 그려지기만 합니다. 그래서 검색 엔진이 읽는 내용, 복사되는 내용, `textContent`가 돌려주는 값 모두 답 한 번뿐이고, 서버에서 렌더링한 페이지에서도 다 센 뒤에도 마찬가지입니다.
- 모션 감소 설정에서는 `trigger`가 일어나기 전에도 곧바로 답을 보여 줍니다.
