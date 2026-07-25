---
title: Divider
order: 2
---

# Divider

<p class="neba-lede">두 가지 사이의 선입니다. 표면이 아닙니다 — 아크릴도, 빛도, 그림자도 없이 하이라인 하나뿐입니다.</p>

<Demo src="divider/hero" />

```tsx
import { Divider } from 'neba';

<Divider />
<Divider>또는</Divider>
<Divider orientation="vertical" />;
```

## Props

<PropsTable name="Divider" />

`variant`도 `elevation`도 없습니다. 선은 테두리 한 변으로 그려지므로 구분선이 선 자체를 넘어 레이아웃을 1픽셀도 더 차지하지 않습니다. 그리고 이것은 [Card](../surfaces/card)가 섹션을 나눌 때 쓰는 것과 문자 그대로 같은 선언입니다 — 카드 위의 표와 카드 자신의 구분선이 한 가족의 선인 이유입니다.

## 예시

### 라벨

`center`는 선을 반으로 나눕니다. `start`와 `end`는 가까운 쪽에 짧은 선을 남겨, 라벨이 선 위에 떠 있는 것이 아니라 선 **안에** 놓인 것으로 읽히게 합니다.

<Demo src="divider/labels">

<<< @/.vitepress/demos/divider/labels.tsx

</Demo>

### 세로

세로 구분선에는 자기 높이가 없습니다. 툴바 그룹 사이의 선이 그래야 하듯 flex 부모에 맞춰 늘어납니다. 세로 라벨은 선을 따라 돌아갑니다. 그러지 않으면 선이 단어 너비만큼 벌어지면서 하이라인이 아니게 됩니다.

<Demo src="divider/vertical">

<<< @/.vitepress/demos/divider/vertical.tsx

</Demo>

### 색

색이 입혀지는 것은 하이라인뿐이고, 그것도 아주 옅게입니다.

<Demo src="divider/colors">

<<< @/.vitepress/demos/divider/colors.tsx

</Demo>

## 접근성

`separator`는 내용에서 이름을 가져오는 role이 아니므로, 보이는 라벨이 저절로 접근성 이름이 되지는 않습니다 — 스크린 리더는 그냥 "구분선"이라고 읽고 그 단어는 따로 떠돌게 됩니다. 그래서 **문자열** 라벨은 `aria-label`로도 복사됩니다. 그보다 복잡한 내용은 건드리지 않습니다. 그중 무엇이 이름인지는 넘긴 쪽만 알기 때문입니다.
