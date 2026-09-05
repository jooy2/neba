---
title: Divider
order: 2
---

# Divider

<p class="neba-lede">콘텐츠를 시각적으로 나누는 얇은 선입니다. 라벨을 넣어 구간의 이름을 붙일 수도 있습니다.</p>

<Demo src="divider/hero" />

```tsx
import { Divider } from 'neba';

<Divider />
<Divider>또는</Divider>
<Divider orientation="vertical" />;
```

## Props

<PropsTable name="Divider" />

`variant`와 `elevation`은 없습니다. 선은 border 한 변으로만 그려지므로 선 두께 외에 레이아웃을 차지하지 않습니다.

## 예시

### length와 thickness

`length`는 선이 뻗는 길이입니다. 가로 divider에서는 너비, 세로 divider에서는 높이입니다. `thickness`는 선의 두께입니다. 둘 다 숫자(px) 또는 임의의 CSS 길이 문자열을 받습니다. 생략하면 가로 선은 컨테이너를 가득 채우고, 세로 선은 자신이 놓인 flex 행의 높이에 맞춰 늘어납니다.

<Demo src="divider/size">

<<< @/.vitepress/demos/divider/size.tsx

</Demo>

### textAlign

`children`으로 라벨을 넣으면 선이 라벨을 비켜 갑니다. `center`는 선을 절반으로 나누고, `start`와 `end`는 가까운 쪽에 짧은 선만 남겨 라벨이 선 안에 놓인 것처럼 보이게 합니다.

<Demo src="divider/labels">

<<< @/.vitepress/demos/divider/labels.tsx

</Demo>

### orientation

`vertical`은 자기 높이를 갖지 않고 flex 부모의 높이에 맞춰 늘어납니다. 툴바에서 컨트롤 그룹을 나눌 때 쓰는 형태입니다. 세로 라벨은 선 방향에 맞춰 회전합니다.

<Demo src="divider/vertical">

<<< @/.vitepress/demos/divider/vertical.tsx

</Demo>

### color

`color`는 선에만 적용되고, 아주 옅게 들어갑니다.

<Demo src="divider/colors">

<<< @/.vitepress/demos/divider/colors.tsx

</Demo>

## 접근성

- `role="separator"`로 렌더링됩니다.
- `separator`는 내용에서 accessible name을 가져오는 role이 아니므로, **문자열** 라벨은 `aria-label`로도 함께 전달됩니다. node를 넘긴 경우에는 그중 무엇이 이름인지 알 수 없으므로 그대로 둡니다. 필요하면 `aria-label`을 직접 지정하세요.
