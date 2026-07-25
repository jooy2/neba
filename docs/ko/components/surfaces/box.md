---
title: Box
order: 1
---

# Box

<p class="neba-lede">콘텐츠를 올려 두는 아크릴 시트. 라이브러리에서 가장 단순한 표면이며, 하는 일은 묶는 것뿐입니다.</p>

<Demo src="box/hero" />

```tsx
import { Box } from 'neba';

<Box>내용</Box>;
```

제목·푸터·구분선처럼 구조가 있는 것은 [Card](./card)의 몫입니다. Card는 그 섹션들이 배치된 Box입니다.

## Props

<PropsTable name="Box" />

`<div>`의 네이티브 속성은 그대로 전달됩니다(`color` 제외).

## 예시

### 변형

`solid`가 색으로 채우지 않는 것은 TextField와 같은 이유입니다. 박스가 담는 것은 본문, 링크, 버튼, 필드 — 저마다 색을 가진 남의 콘텐츠입니다. 강조색으로 채우면 그 전부에 채움 위 대비 처리가 필요해지는데, 그건 컨테이너가 할 일의 반대입니다.

시트는 아예 염색하지 않습니다. `solid`와 `outline`을 가르는 것은 색이 아니라 **시트가 머금은 빛의 양**(불투명도)과 하이라인의 유무입니다. 자세한 것은 [색](../../guide/color#컨테이너-표면은-염색하지-않습니다)을 보세요.

<Demo src="box/variants">

<<< @/.vitepress/demos/box/variants.tsx

</Demo>

`text`는 표면이 없으므로 `elevation`도 무시됩니다. 보이지 않는 사각형 둘레에 그림자를 그리는 대신입니다.

### 색

표면이 흰색이므로 색 계열은 **하이라인에만** 나타납니다. 그래서 아래 예시는 `outline`입니다 — 테두리가 없는 `solid` Box에서는 `color`가 보이는 변화를 만들지 않습니다.

<Demo src="box/colors">

<<< @/.vitepress/demos/box/colors.tsx

</Demo>

### 크기

다른 컴포넌트와 달리 Box의 `size`는 높이도 타입 스케일도 정하지 않습니다. 박스의 높이는 담긴 것이 정하고, 타이포그래피는 담긴 것이 가져옵니다 — 감싸는 것만으로 같은 문단이 두 크기로 렌더링된다면 곤란합니다. 그래서 여기서 `size`는 *시트*의 크기, 즉 모서리 반경과 여백입니다.

<Demo src="box/sizes">

<<< @/.vitepress/demos/box/sizes.tsx

</Demo>

### Elevation

<Demo src="box/elevation">

<<< @/.vitepress/demos/box/elevation.tsx

</Demo>

### 여백 없이, 다른 요소로

`padded={false}`는 이미지나 표처럼 가장자리까지 채우는 콘텐츠를 위한 것입니다. `render`는 Base UI의 render prop 그대로라서, `<div>` 대신 어떤 요소로든 렌더링할 수 있습니다.

<Demo src="box/unpadded">

<<< @/.vitepress/demos/box/unpadded.tsx

</Demo>
