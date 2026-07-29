---
title: Box
order: 1
---

# Box

<p class="neba-lede">콘텐츠를 올려 두는 기본 표면입니다. 라이브러리에서 가장 단순한 sheet로, 내용을 묶어 배경에서 분리하는 일만 합니다.</p>

<Demo src="box/hero" />

```tsx
import { Box } from 'neba';

<Box>내용</Box>;
```

## Props

<PropsTable name="Box" />

`color`를 제외한 `<div>`의 native 속성이 그대로 전달됩니다.

제목이나 푸터, 구분선처럼 구조가 필요하면 [Card](./card)를 쓰세요. Card는 그 섹션들이 배치된 Box입니다.

## 예시

### variant

세 무게 모두 sheet를 색으로 채우지 않습니다. Box가 담는 것은 본문과 링크, 버튼처럼 저마다 색을 가진 콘텐츠이기 때문입니다. `solid`와 `outline`을 가르는 것은 색이 아니라 sheet의 불투명도와 테두리 유무입니다. 자세한 내용은 [색](../../guide/color#컨테이너-표면은-염색하지-않습니다)에 있습니다.

`text`는 표면이 없으므로 `elevation`도 무시됩니다.

<Demo src="box/variants">

<<< @/.vitepress/demos/box/variants.tsx

</Demo>

### color

표면이 흰색이므로 `color`는 **테두리에만** 나타납니다. 아래 예시가 `outline`인 것은 그 때문입니다 — 테두리가 없는 `solid` Box에서는 `color`가 보이는 변화를 만들지 않습니다.

<Demo src="box/colors">

<<< @/.vitepress/demos/box/colors.tsx

</Demo>

### size

Box의 `size`는 높이나 타입 스케일이 아니라 **sheet의 크기**, 즉 모서리 반경과 여백을 정합니다. Box의 높이는 담긴 내용이 정하고, 타이포그래피도 담긴 내용이 가져옵니다.

<Demo src="box/sizes">

<<< @/.vitepress/demos/box/sizes.tsx

</Demo>

### elevation

<Demo src="box/elevation">

<<< @/.vitepress/demos/box/elevation.tsx

</Demo>

### padded와 render

`padded={false}`는 이미지나 표처럼 가장자리까지 채우는 콘텐츠를 위한 것입니다. `render`로 `<div>` 대신 다른 요소로 렌더링할 수 있습니다.

<Demo src="box/unpadded">

<<< @/.vitepress/demos/box/unpadded.tsx

</Demo>
