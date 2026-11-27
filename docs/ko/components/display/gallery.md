---
title: Gallery
order: 24
flutter: true
---

# Gallery

<p class="neba-lede">여러 장의 사진을 배치합니다. 네 가지 layout(컨택트 시트, masonry, 정렬된 사진첩, 퀼트)이 하나의 이미지 목록과 거기에 딸려 온 메타데이터 위에서 동작하며, 클릭 한 번에 크게 보는 화면이 열립니다.</p>

<Demo src="gallery/hero" />

::: fw react

```tsx
import { Gallery } from 'neba';

<Gallery
  items={[{ src, alt: '동틀 녘의 잔잔한 산정 호수', title: '산정 호수', ratio: '3 / 2' }]}
  layout="justified"
  caption="hover"
  preview
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaGallery(
  items: <NebaGalleryItem>[
    NebaGalleryItem(
      image: AssetImage('assets/lake.jpg'),
      alt: '동틀 녘의 잔잔한 산정 호수',
      title: '산정 호수',
      ratio: 3 / 2,
    ),
  ],
  layout: NebaGalleryLayout.justified,
  caption: NebaGalleryCaption.hover,
  preview: true,
);
```

:::

## Props

<PropsTable name="Gallery" />

::: fw react

나머지 `<ul>` 속성은 그대로 목록으로 전달됩니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

::: fw flutter

`columns`는 breakpoint 맵이 아니라 개수이고, `gap`은 픽셀 수이며 사다리의 단계는 `NebaGallery.gaps`에 있습니다. `rounded`는 한 단계를 받고, `null`이면 타일이 각집니다. `loading`은 없습니다. 그림은 타일이 빌드될 때 요청되므로, 한 번에 불러오기에 너무 긴 묶음은 늦게 빌드되는 목록에 나눠 담으세요. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

### 항목

<PropsTable name="NebaGalleryItem" />

`masonry`와 `justified`는 파일이 한 장도 도착하기 전에 각 항목의 `ratio`로 배치를 계산합니다. 그래서 처음 그리는 프레임부터 배치가 맞고, 사진이 도착하면서 다시 흐르지 않습니다. 사진을 측정하는 일은 없습니다. `ratio`가 없는 항목은 Gallery 자체의 `ratio`를 씁니다.

항목에는 `rotate`, `flip`, `position`, `placeholder`도 줄 수 있고, [Image](./image)에서와 똑같이 그 사진에 전달됩니다. `rotate`와 `flip`은 크게 보기 화면까지 따라갑니다. `ratio`는 저장된 파일의 비율 그대로 두면 되고, 옆으로 돌린 항목은 누운 모양으로 배치됩니다.

::: fw react

`srcSet`과 `sizes`는 타일의 `<img>`에 그대로 전달됩니다. 그래서 300픽셀로 그려지는 타일은 원본 대신 그 크기에 가까운 파일을 받습니다. `full`이 없는 항목은 `srcSet`을 크게 보기 화면에도 넘기고, 화면은 자기 크기에 맞는 후보를 고릅니다.

:::

::: fw flutter

그림은 `image`, 크게 보기 화면의 큰 파일은 `full`이며 둘 다 어떤 `ImageProvider`든 받습니다. 보이는 크기로 디코딩한 파일로 타일을 그리려면 `ResizeImage`를 쓰세요. `title`과 `description`은 문자열입니다. 스크린 리더가 타일의 이름과 크게 보기 화면의 숫자 안에서 이 둘을 읽기 때문입니다. `id`는 두 항목을 구별할 수 있는 값이면 무엇이든 됩니다.

:::

## 예시

### layout

`grid`는 파일이 어떤 모양이든 모든 타일을 같은 모양으로 맞춥니다. `masonry`는 사진마다의 비율을 지키면서 열에 쌓되, 가장 짧은 열부터 채우므로 첫 줄이 1열의 첫 세 장이 아니라 처음 받은 세 장이 됩니다. `justified`는 비율을 지키면서 각 줄을 가장자리까지 채우고 한 줄을 같은 높이로 맞춥니다. 잘리는 것도 남는 공간도 없는 배치입니다. `quilted`는 타일이 여러 칸을 차지할 수 있는 grid입니다.

::: fw react

`masonry`는 몇 열에 나눠 담을지 정하려고 JavaScript에서 breakpoint를 읽습니다. 서버에서 렌더한 페이지는 `columns`가 바뀌는 폭마다 나눈 결과를 하나씩 그리고 읽는 사람의 폭에 맞는 것만 보여 주므로, hydration될 때 아무것도 움직이지 않습니다. 나머지는 숨겨져 있다가 페이지가 실행되면 사라집니다. 그 뒤 breakpoint를 넘으면 다시 나누며, 이때 모든 타일이 새 열에서 다시 마운트됩니다. `grid`, `quilted`, `justified`는 열을 CSS에서 가져오므로 타일이 옮겨지지 않습니다.

:::

::: fw flutter

네 가지 모두 주어진 너비를 읽는 render object 하나가 배치합니다. 그래서 타일은 처음 나타나는 프레임부터 제자리에 놓이고, 너비나 열 수가 바뀌면 나눈 결과를 다시 계산합니다. 타일은 다른 열로 옮겨 가도 자기 상태를 유지합니다.

:::

<Demo src="gallery/layouts">

::: fw react

<<< @/.vitepress/demos/gallery/layouts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/layouts.dart

:::

</Demo>

### columns와 gap

::: fw react

`columns`는 한 줄에 몇 장을 놓을지이며 breakpoint 맵을 받습니다. 기본값은 `{ xs: 2, sm: 3, lg: 4 }`입니다. `grid` · `masonry` · `quilted`가 이 값을 읽고, `justified`는 `rowHeight`를 기준으로 줄마다 스스로 정합니다.

`gap`은 타일 사이의 간격입니다. 간격 사다리의 한 단계, 픽셀 수, 또는 CSS 길이를 받습니다.

:::

::: fw flutter

`columns`는 한 줄에 몇 장을 놓을지입니다. 생략하면 React의 기본 맵처럼 창의 너비를 읽어 `sm`보다 좁으면 둘, `sm`부터 셋, `lg`부터 넷입니다. 창에 따라 바뀌는 개수를 직접 정하려면 아래 첫 번째 갤러리처럼 `MediaQuery`에서 읽으세요. `grid` · `masonry` · `quilted`가 이 값을 읽고, `justified`는 `rowHeight`를 기준으로 줄마다 스스로 정합니다.

`gap`은 타일 사이의 간격이며 단위는 논리 픽셀이고 기본값은 `8`입니다. 사다리의 단계는 `NebaGallery.gaps`에 있으므로 React의 `gap="xs"`는 `NebaGallery.gaps[NebaSize.xs]`입니다.

:::

<Demo src="gallery/columns">

::: fw react

<<< @/.vitepress/demos/gallery/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/columns.dart

:::

</Demo>

### <Fw react="fit, letterbox, loading" flutter="fit과 letterbox" />

::: fw react

`fit`은 Image에서처럼 각 사진이 타일을 채우는 방식입니다. 기본값 `cover`는 타일에 맞춰 잘라내고, `contain`과 `scale-down`은 사진 전체를 남깁니다. `letterbox`는 그때 생기는 빈 영역을 CSS background로 채우거나, `blur`면 같은 사진을 흐리게 깔아 채웁니다. `loading`의 기본값은 `lazy`라서 타일이 화면 가까이 올 때까지 파일 요청을 미룹니다. 갤러리가 첫 화면에서 가장 큰 요소라면 lazy로 불러온 첫 줄이 늦게 나타나므로 `loading="eager"`를 주세요.

:::

::: fw flutter

`fit`은 Image에서처럼 각 사진이 타일을 채우는 방식입니다. 기본값 `BoxFit.cover`는 타일에 맞춰 잘라내고, `contain`과 `scaleDown`은 사진 전체를 남깁니다. `letterbox`는 그때 생기는 빈 영역을 색이나 `Decoration`으로 채우거나, `NebaImageLetterbox.blur`면 같은 사진을 흐리게 깔아 채웁니다.

:::

<Demo src="gallery/fit">

::: fw react

<<< @/.vitepress/demos/gallery/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/fit.dart

:::

</Demo>

### priority

::: fw react

첫 항목부터 몇 장이 페이지의 평가 기준이 되는 그림인지 정합니다. 그 타일들은 `loading`과 상관없이 일찍 불러오고, `priority`를 켠 [Image](./image)처럼 페이드나 Skeleton 없이 첫 페인트부터 그립니다. 갤러리가 첫 화면에서 가장 큰 요소라면 첫 줄의 장수를 주고 나머지는 lazy로 두세요.

```tsx
<Gallery items={photos} columns={3} priority={3} />
```

:::

::: fw flutter

첫 항목부터 몇 장이 화면의 평가 기준이 되는 그림인지 정합니다. 그 타일들은 `priority`를 켠 [Image](./image)처럼 페이드나 Skeleton 없이 그립니다. 갤러리가 화면에서 가장 먼저 보이는 것이라면 첫 줄의 장수를 주세요.

```dart
NebaGallery(items: photos, columns: 3, priority: 3)
```

:::

### caption

`below`는 항목의 `title`과 `description`을 사진 아래에 두고, `overlay`는 사진 아래쪽에 그러데이션을 깔고 그 위에 씁니다. `hover`는 pointer가 올라오거나 focus가 들어올 때 나타나는 `overlay`이며, <Fw react="hover할 수 없는 화면에서는" flutter="마우스가 연결되지 않았을 때는" /> 늘 보입니다. 기본값 `none`은 둘 다 그리지 않습니다. 그래도 그 내용은 사진의 `alt`와 크게 보기 화면에 남아 있습니다.

`justified`에서는 `overlay`나 `hover`를 쓰세요. 사진 아래에 캡션이 붙으면 타일이 계산된 줄 높이보다 커지고, 줄이 맞지 않습니다.

<Demo src="gallery/captions">

::: fw react

<<< @/.vitepress/demos/gallery/captions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/captions.dart

:::

</Demo>

### hover

`hover`는 pointer가 올라왔을 때 타일이 하는 일을 정하며, 버튼에 키보드 focus가 있는 타일도 똑같이 반응합니다.

`lift`는 그림자 사다리에서 타일을 한 단 올리고 `dim`은 사진을 어둡게 합니다. `zoom`은 움직이지 않는 액자 안에서 사진만 키우므로, 타일의 가장자리는 제자리에 그대로 있습니다.

::: fw flutter

zoom은 잘라 내는 액자 안에서 사진에만 거는 확대입니다. 디자인 언어가 허용하는 유일한 확대이며, 움직이는 것은 다시 샘플링할 글자가 없는 사진이고 컨트롤인 타일은 움직이지 않기 때문입니다. `filter` 위의 `dim`은 둘을 차례로 거는 것으로, filter 다음에 어둡게 합니다.

:::

`filter` · `frame` · `watermark` · `protect`는 각 타일의 [Image](./image)로 그대로 전달됩니다. 흑백 썸네일로 채운 갤러리나 표식을 박은 시안 묶음이 <Fw react="prop" flutter="인자" /> 하나입니다.

<Demo src="gallery/hover">

::: fw react

<<< @/.vitepress/demos/gallery/hover.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/hover.dart

:::

</Demo>

### preview

사진을 원래 크기로 열고, 나머지는 방향키 하나 거리에 둡니다. `←`와 `→`는 화살표가 가리키는 쪽으로 이동하므로 RTL에서는 `←`가 다음 사진이고, `Esc`로 닫으며, 사진 아래의 숫자는 바뀔 때마다 읽힙니다.

::: fw react

항목에 `full`이 있으면 그 파일을 씁니다. 썸네일 격자가 자기가 썸네일인 원본을 열 수 있습니다. `watermark`와 `protect`도 사진을 따라 크게 보기 화면에 들어갑니다. 크게 보기 화면의 코드는 pointer나 focus, 손가락이 갤러리에 처음 닿을 때 내려받고 화면은 누르는 순간 마운트되므로, 서버 렌더링이 기다릴 것이 없습니다.

:::

::: fw flutter

항목에 `full`이 있으면 그 파일을 씁니다. 썸네일 격자가 자기가 썸네일인 원본을 열 수 있습니다. `watermark`와 `protect`도 사진을 따라 크게 보기 화면에 들어갑니다. 크게 보기 화면은 Image의 preview가 여는 것과 같은 시트이며 앱의 루트 `Overlay`에서 scrim 위에 뜨므로, 갤러리 위에 `Overlay`가 있어야 합니다. 타일을 누르기 전까지는 아무것도 빌드하지 않습니다.

:::

<Demo src="gallery/preview" frameMinHeight="560">

::: fw react

<<< @/.vitepress/demos/gallery/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/preview.dart

:::

</Demo>

### onItemSelect

타일이 선택되면 항목과 그 index로 호출됩니다. 크게 보기 화면이 있든 없든 마찬가지입니다. 타일을 조작 가능한 것으로 만드는 것이 이 prop이며, `preview`도 이것도 없는 Gallery는 누를 것이 없는 사진을 그립니다.

## 접근성

::: fw react

- 목록은 `label`로, 없으면 `locale`의 "갤러리"에 해당하는 낱말로 이름이 붙은 `role="list"`입니다. 그 묶음이 **무엇인지**를 이름으로 쓰고, 한 페이지의 두 갤러리에는 서로 다른 이름을 주세요.
- 타일 버튼의 이름은 캡션과 묶음 안에서의 위치입니다. 썸네일을 tab으로 지나가는 독자에게 전체 몇 장 중 몇 번째인지 알려 주고, 음성 제어 사용자는 타일에 적힌 말을 불러 누를 수 있습니다. 캡션을 그리지 않은 타일은 사진의 `alt`가 이름이 됩니다.
- `masonry`는 열 단위로 읽힙니다. `Tab`과 스크린 리더가 첫 열을 끝까지 내려간 뒤 둘째 열로 가므로, 3열이면 1, 4, 7 다음에 2, 5, 8 순서가 되어 항목을 넘긴 순서와 다릅니다. 단계나 순위처럼 순서가 중요한 곳에서는 줄 단위로 순서를 지키는 `justified`를 쓰세요.
- 모든 `hover` 효과는 focus 효과이기도 합니다.
- 크게 보기 화면의 숫자는 live region입니다. 방향키를 눌렀을 때 어디로 갔는지를, 그 사진을 볼 수 없는 독자에게도 말해 줍니다.

:::

::: fw flutter

- 목록은 semantics 트리의 list이며 `label`로, 없으면 `locale`의 "갤러리"에 해당하는 낱말로 이름이 붙습니다. 그 묶음이 **무엇인지**를 이름으로 쓰고, 한 페이지의 두 갤러리에는 서로 다른 이름을 주세요.
- 타일 버튼의 이름은 캡션과 묶음 안에서의 위치이고, description은 그 뒤에 읽힙니다. 썸네일을 tab으로 지나가는 독자에게 전체 몇 장 중 몇 번째인지 알려 주고, 음성 제어 사용자는 타일에 적힌 말을 불러 누를 수 있습니다. 캡션을 그리지 않은 타일은 사진의 `alt`가 이름이 됩니다.
- `Tab`과 스크린 리더는 `masonry`를 포함한 모든 layout에서, 타일이 어느 열에 담겼든 `items`의 순서대로 타일을 지나갑니다.
- 모든 `hover` 효과는 focus 효과이기도 합니다.
- 크게 보기 화면의 숫자는 그 사진이 무엇이고 묶음의 몇 번째인지 말하는 live region입니다. 방향키를 눌렀을 때 어디로 갔는지를, 그 사진을 볼 수 없는 독자에게도 말해 줍니다.

:::
