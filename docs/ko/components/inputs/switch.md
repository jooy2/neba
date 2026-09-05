---
title: Switch
order: 7
---

# Switch

<p class="neba-lede">설정을 즉시 켜고 끄는 컨트롤입니다. 조작하는 순간 효력이 생기는 항목에 씁니다.</p>

<Demo src="switch/hero" />

```tsx
import { Switch } from 'neba';

<Switch label="이메일 알림" defaultChecked />;
```

## Props

<PropsTable name="Switch" />

아래에 저장 버튼이 있어서 값이 폼과 함께 제출된다면 [Checkbox](./checkbox)를 쓰세요. 그것이 두 컴포넌트를 가르는 기준입니다.

## 예시

### checked와 onCheckedChange

`checked`와 `onCheckedChange`로 controlled, `defaultChecked`로 uncontrolled 컴포넌트가 됩니다.

### disabled · readOnly

<Demo src="switch/states">

<<< @/.vitepress/demos/switch/states.tsx

</Demo>

### labelPlacement

`end`(기본)는 컨트롤 뒤에 라벨을 두어 설명처럼 읽히게 합니다. `start`는 라벨이 왼쪽 열을 이루고 스위치가 오른쪽에 정렬되는 설정 목록에 적합합니다.

<Demo src="switch/placement">

<<< @/.vitepress/demos/switch/placement.tsx

</Demo>

### size

<Demo src="switch/sizes">

<<< @/.vitepress/demos/switch/sizes.tsx

</Demo>

### classNames

`className`은 track이 아니라 감싸는 field wrapper에 붙습니다. track과 thumb은 `classNames`로 갑니다.

```tsx
<Switch label="Email alerts" classNames={{ control: 'w-14', thumb: 'rounded-sm' }} />
```

slot은 `label`, `control`, `thumb`, `description`, `error`입니다. `control`은 track(켜지면 채워지는 알약)이고 `thumb`은 그 위를 오가는 원입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

## 접근성

- `role="switch"`와 함께 숨은 `<input>`이 렌더링됩니다.
- 라벨이 컨트롤과 연결되어 있어 글자를 눌러도 전환됩니다.
- `label`을 쓰지 않는다면 `aria-label`을 주세요.
- thumb의 이동은 `prefers-reduced-motion`에서 즉시 전환됩니다.
