---
title: AnimateFade
order: 9
---

# AnimateFade

<p class="neba-lede">불투명도만으로 나타나거나 사라지는 효과입니다. 이 묶음에서 가장 단순하고 가장 먼저 손이 가야 할 효과로, 아무것도 움직이지 않으므로 레이아웃이 다시 계산되지 않고 글자가 다시 그려지지도 않습니다.</p>

<Demo src="animate-fade/hero" />

```tsx
import { AnimateFade } from 'neba';

<AnimateFade>
  <Card title="배포 완료">서비스 두 개가 재시작되었고 오류는 없습니다.</Card>
</AnimateFade>;
```

## Props

<PropsTable name="AnimateFade" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다.

모든 `Animate*`가 공유하는 설정 — `duration`, `delay`, `easing`, `repeat`, `alternate`, `trigger`, `play`, `once`, `threshold`, `paused` — 은 어디서나 같은 뜻이며 [Prop 규약](../../design/prop-conventions)에 정리되어 있습니다.

## 예시

### duration과 delay

둘 다 밀리초입니다. delay는 여러 개의 fade를 하나의 순서로 만드는 것이고, 그 대상이 목록일 때 대신 해 주는 것이 `AnimateAppear`입니다.

<Demo src="animate-fade/timing">

<<< @/.vitepress/demos/animate-fade/timing.tsx

</Demo>

### trigger

`mount`가 기본값이고 아무것도 요구하지 않습니다. `visible`은 화면에 들어올 때까지 기다립니다 — `once`를 끄지 않는 한 한 번만이고, `threshold`가 얼마나 들어와야 하는지를 정합니다. `hover`는 포인터가 올라가 있는 동안 재생하며 들어올 때마다 처음부터 다시 시작하고, 키보드 focus도 포인터로 셉니다. `manual`은 `play`가 말하기 전까지 아무것도 하지 않으며, `false` → `true`가 될 때마다 다시 시작합니다.

<Demo src="animate-fade/triggers">

<<< @/.vitepress/demos/animate-fade/triggers.tsx

</Demo>

### mode

`out`은 같은 애니메이션을 거꾸로 재생하고 그 자리에 붙들어 둡니다. 사라진 요소는 애니메이션이 끝났다고 해서 다시 튀어나오지 않습니다. `alternate`와 함께 쓰면 처음으로 튀는 대신 되돌아오므로, 반복되는 fade가 맥동이 됩니다.

<Demo src="animate-fade/mode">

<<< @/.vitepress/demos/animate-fade/mode.tsx

</Demo>

### from

fade가 시작하는 불투명도로, `0`에서 `1` 사이입니다. 완전히 사라지면 안 되는 것은 이 값을 올려서 사라짐이 아니라 흐려짐으로 만듭니다.

```tsx
<AnimateFade from={0.4}>
  <Chip>초안</Chip>
</AnimateFade>
```

### stagger, durationStep, reverse

`stagger`는 한 자식 뒤에 다음 자식이 시작하기까지의 간격(ms)입니다. 기본값 `0`에서는 상자 자체가 페이드하고 자식은 건드리지 않습니다. 그보다 크면 효과가 자식 하나하나에게 넘어가고 상자에는 아무것도 남지 않으므로, 다섯 줄짜리 목록이 한 줄씩 도착합니다.

`durationStep`은 뒤에 오는 자식일수록 `duration`에 그만큼(ms)씩 더합니다. 음수를 주면 뒤로 갈수록 빨라지며, 재생 시간이 0 아래로 내려가지는 않습니다. `reverse`는 마지막 자식부터 실행합니다. 순서만 뒤집힐 뿐 각 자식은 그대로 앞으로 재생됩니다.

간격은 _자식_ 단위입니다. 그래서 무엇을 넘기는지가 중요합니다. 자식 다섯이면 다섯 걸음이고, 다섯 개를 담은 자식 하나는 한 걸음입니다. 목록 일부를 빼고 싶으면 묶으면 됩니다.

<Demo src="animate-fade/stagger" minHeight="360">

<<< @/.vitepress/demos/animate-fade/stagger.tsx

</Demo>

## 접근성

- 축소된 모션 설정에서는 애니메이션이 통째로 꺼지고 내용은 그냥 거기 있습니다. 보이지 않는 상태로 남는 일은 없습니다.
- 래퍼는 role도 이름도 더하지 않습니다. 안에 든 것이 자기 것을 그대로 지킵니다.
