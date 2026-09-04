---
title: Gallery
order: 24
---

# Gallery

<p class="neba-lede">여러 장의 사진을 배치합니다. 네 가지 layout — 컨택트 시트, masonry, 정렬된 사진첩, 퀼트 — 이 하나의 이미지 목록과 함께 딸려 온 메타데이터 위에서 동작하고, 클릭 한 번에 크게 보는 화면이 열립니다.</p>

<Demo src="gallery/hero" />

```tsx
import { Gallery } from 'neba';

<Gallery
  items={[{ src, alt: '동틀 녘의 잔잔한 산정 호수', title: '산정 호수', ratio: '3 / 2' }]}
  layout="justified"
  caption="hover"
  preview
/>;
```

## Props

<PropsTable name="Gallery" />

나머지 `<ul>` 속성은 그대로 목록으로 전달됩니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

### 항목

<PropsTable name="NebaGalleryItem" />

`ratio`는 없어도 될 것 같아 보여도 적어 두는 편이 좋습니다. `masonry`와 `justified`는 이 값으로 배치를 계산하고, 그 계산은 파일이 한 장도 도착하기 전에 끝납니다. 브라우저가 처음 그리는 프레임부터 배치가 맞고, 사진 마흔 장이 도착하면서 마흔 번 다시 흐르는 일이 없는 이유입니다. 측정하는 것은 아무것도 없습니다.

## 예시

### layout

`grid`는 파일이 어떤 모양이든 모든 타일을 같은 모양으로 맞춥니다. `masonry`는 사진마다의 비율을 지키면서 열에 쌓되, 가장 짧은 열부터 채우므로 첫 줄이 1열의 첫 세 장이 아니라 처음 받은 세 장이 됩니다. `justified`는 비율을 지키면서 각 줄을 가장자리까지 채우고 한 줄을 같은 높이로 맞춥니다. 잘리는 것도 남는 공간도 없는 배치입니다. `quilted`는 타일이 여러 칸을 차지할 수 있는 grid입니다.

<Demo src="gallery/layouts">

<<< @/.vitepress/demos/gallery/layouts.tsx

</Demo>

### columns와 gap

`columns`는 한 줄에 몇 장을 놓을지이며 breakpoint 맵을 받습니다. 기본값은 `{ xs: 2, sm: 3, lg: 4 }`입니다. `grid` · `masonry` · `quilted`가 이 값을 읽고, `justified`는 `rowHeight`를 기준으로 줄마다 스스로 정합니다.

`gap`은 타일 사이의 간격입니다. 간격 사다리의 한 단계, 픽셀 수, 또는 CSS 길이를 받습니다.

<Demo src="gallery/columns">

<<< @/.vitepress/demos/gallery/columns.tsx

</Demo>

### caption

`below`는 항목의 `title`과 `description`을 사진 아래에 두고, `overlay`는 사진 아래쪽에 그러데이션을 깔고 그 위에 씁니다. `hover`는 pointer가 올라올 때 나타나는 `overlay`입니다. 기본값 `none`은 둘 다 그리지 않습니다. 그래도 그 내용은 사진의 `alt`와 크게 보기 화면에 남아 있습니다.

`justified`에서는 `overlay`나 `hover`를 쓰세요. 사진 아래에 캡션이 붙으면 타일이 계산된 줄 높이보다 커지고, 줄이 맞지 않습니다.

<Demo src="gallery/captions">

<<< @/.vitepress/demos/gallery/captions.tsx

</Demo>

### hover

pointer가 올라왔을 때, 그리고 키보드 focus가 왔을 때 타일이 하는 일입니다. 둘 다 항상 함께 걸리므로 마우스로만 닿을 수 있는 상태는 없습니다.

`lift`는 그림자 사다리에서 타일을 한 단 올리고 `dim`은 사진을 어둡게 합니다. 라이브러리의 다른 컴포넌트가 pointer에 답하는 방식 그대로입니다. `zoom`은 크기를 바꾸는 유일한 경우이고, 여기서만 허용됩니다. 움직이는 것은 액자 안의 사진이며 액자 자체는 제자리에 있고, 사진에는 다시 그려질 글자가 없기 때문입니다.

`filter` · `frame` · `watermark` · `protect`는 각 타일의 [Image](./image)로 그대로 전달됩니다. 흑백 썸네일로 채운 갤러리나 표식을 박은 시안 묶음이 prop 하나입니다.

<Demo src="gallery/hover">

<<< @/.vitepress/demos/gallery/hover.tsx

</Demo>

### preview

사진을 원래 크기로 열고, 나머지는 방향키 하나 거리에 둡니다. `←`와 `→`로 이동하고 `Esc`로 닫으며, 사진 아래의 숫자는 바뀔 때마다 읽힙니다.

항목에 `full`이 있으면 그 파일을 씁니다. 썸네일 격자가 자기가 썸네일인 원본을 열 수 있습니다. `watermark`와 `protect`도 사진을 따라 들어갑니다. 크게 여는 순간 벗겨지는 표식은 표식이 아니기 때문입니다.

크게 보기 화면은 필요할 때 내려받습니다. 이 기능을 쓰지 않는 Gallery는 그 무게를 지지 않습니다.

<Demo src="gallery/preview">

<<< @/.vitepress/demos/gallery/preview.tsx

</Demo>

### onItemSelect

타일이 선택되면 항목과 그 index로 호출됩니다. 크게 보기 화면이 있든 없든 마찬가지입니다. 타일을 조작 가능한 것으로 만드는 것이 이 prop이며, `preview`도 이것도 없는 Gallery는 누를 것이 없는 사진을 그립니다.

## 접근성

- 목록은 `label`로, 없으면 `locale`의 "갤러리"에 해당하는 낱말로 이름이 붙은 `role="list"`입니다. 그 묶음이 **무엇인지**를 이름으로 쓰세요. 갤러리가 둘인데 이름이 하나면 이름이 없는 것과 같습니다.
- 타일 버튼의 이름은 사진의 `alt`와 묶음 안에서의 위치입니다. 썸네일을 tab으로 지나가는 독자에게 전체 몇 장 중 몇 번째인지 알려 줍니다.
- 모든 hover 효과는 focus 효과이기도 합니다. pointer에만 답하는 타일은 독자의 절반에게만 답하는 타일입니다.
- 크게 보기 화면의 숫자는 live region입니다. 방향키를 눌렀을 때 어디로 갔는지를, 그 사진을 볼 수 없는 독자에게도 말해 줍니다.
