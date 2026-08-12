---
title: Overlay
order: 8
---

# Overlay

<p class="neba-lede">페이지 전체를 덮어 조작을 막는 한 겹입니다. 저장이나 로딩처럼 사용자가 답할 것 없이 기다려야 하는 동안 씁니다.</p>

<Demo src="overlay/hero" />

```tsx
import { Overlay, ProgressCircular } from 'neba';

<Overlay open={saving} tone="blur" label="저장 중">
  <ProgressCircular size="lg" />
</Overlay>;
```

## Props

<PropsTable name="Overlay" />

`<div>`의 native 속성은 sheet로 전달됩니다. `color`와 `children`만 위 표와 이름이 겹쳐 제외됩니다.

Overlay에는 표면도, 테두리도, 제목도, 액션도 없습니다. 사용자가 결정할 것이 있다면 [Dialog](./dialog)를 쓰세요.

## 예시

### tone

뒤 페이지가 얼마나 읽히는지를 정하는 네 단계입니다.

| tone | 뒤 페이지 |
| --- | --- |
| `scrim` | 읽을 수는 있고 조작만 막힙니다. [Dialog](./dialog)의 backdrop과 같은 값이라 두 컴포넌트가 겹쳐도 이음매가 보이지 않습니다. |
| `blur` | 형태와 색은 남고 글자는 읽히지 않습니다. 내용이 교체되는 중일 때 씁니다. |
| `solid` | 완전히 가립니다. 페이지 표면 색으로 불투명하게 덮습니다. |
| `clear` | 아무것도 그리지 않고 포인터만 막습니다. |

<Demo src="overlay/tones">

<<< @/.vitepress/demos/overlay/tones.tsx

</Demo>

### dismissible

기본값이 꺼짐이라는 점이 [Dialog](./dialog)와 반대입니다. Overlay는 답을 요구하지 않고 기다리라고 말하는 것이므로, Esc와 scrim 클릭이 모두 거절됩니다. 무언가의 바깥 클릭을 받아 내는 것이 목적인 Overlay라면 켜세요.

<Demo src="overlay/dismissible">

<<< @/.vitepress/demos/overlay/dismissible.tsx

</Demo>

### modal

`modal="trap-focus"`는 페이지 스크롤과 클릭을 허용하면서 focus만 Overlay 안에 붙잡아 둡니다. `clear` tone과 함께 쓰기에 적합합니다.

## 접근성

- `role="dialog"`로 렌더링되고 `label`이 accessible name이 됩니다. 내용이 스피너뿐이거나 `clear`여도 이름은 필요하므로 `label`에는 기본값이 있습니다.
- portal, scroll lock, focus 유지, 뒤 페이지 inert 처리, 닫을 때 focus 복귀가 모두 적용됩니다.
- 등장 효과는 opacity만 사용합니다.
- overlay의 접근성 이름은 `locale`이 정합니다. `label`로 직접 쓸 수도 있습니다.
