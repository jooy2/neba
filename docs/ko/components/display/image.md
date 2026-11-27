---
title: Image
order: 23
flutter: true
---

# Image

<p class="neba-lede">불러오는 동안 자리를 지키고, 불러오는 중임을 표시하며, 실패하면 대체 내용을 보여 주는 이미지입니다. 맨 <code>&lt;img&gt;</code>를 쓰면 이 셋을 직접 처리해야 합니다.</p>

<Demo src="image/hero" />

::: fw react

```tsx
import { Image } from 'neba';

<Image src={src} alt="아침 안개가 내린 차밭" ratio="16 / 9" rounded />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaImage(
  image: AssetImage('assets/tea.jpg'),
  alt: '아침 안개가 내린 차밭',
  ratio: 16 / 9,
  rounded: NebaSize.md,
);
```

:::

## Props

<PropsTable name="Image" />

::: fw react

`<img>`의 native 속성은 그림 자체로 전달됩니다. `loading`, `decoding`, `srcSet`, `sizes`, `referrerPolicy`는 물론 `width`와 `height`도 그대로 넘어갑니다.

:::

::: fw flutter

React가 URL을 받는 자리에서 파일은 `image`이며, 어떤 `ImageProvider`든 받습니다. 에셋, 네트워크나 기기의 파일, 이미 메모리에 있는 그림이 모두 하나의 매개변수이고, 어떻게 가져오고 캐시하고 화면의 픽셀 밀도에 맞는 파일을 고를지는 provider가 정합니다. 그래서 `srcSet`, `sizes`, `referrerPolicy`가 없습니다. 옵션 타입은 `NebaImageFilter`, `NebaImageFlip`, `NebaImageLetterbox`, `NebaImagePlaceholder`, `NebaImageFrame`, `NebaImageWatermark`입니다.

:::

### `alt`는 필수입니다

::: fw react

타입 수준에서 그렇고, 이것이 감싸는 태그보다 이 컴포넌트가 엄격한 유일한 지점입니다.

`alt`가 없는 것은 "아무도 쓰지 않았다"는 뜻이고, 빈 것은 "이 그림은 독자가 알아야 할 것을 말하지 않는다"는 뜻입니다. 옳은 쪽은 두 번째뿐입니다. `alt=""`을 직접 쓰게 하는 것은 둘 중 어느 쪽인지 말하게 하는 것입니다.

:::

::: fw flutter

생성자 수준에서 그렇고, `semanticLabel`을 생략해도 되는 Flutter의 `Image`보다 이 위젯이 엄격한 유일한 지점입니다.

이름이 없는 것은 "아무도 쓰지 않았다"는 뜻이고, 빈 것은 "이 그림은 독자가 알아야 할 것을 말하지 않는다"는 뜻입니다. 옳은 쪽은 두 번째뿐입니다. `alt: ''`을 직접 쓰게 하는 것은 둘 중 어느 쪽인지 말하게 하는 것입니다.

:::

## 예시

### ratio

파일이 도착하는 동안 지킬 비율이고, <Fw react="`&lt;img&gt;` 대신 이것을" flutter="`Image` 대신 이것을" /> 쓰는 주된 이유입니다. 자리를 잡아 두지 않은 그림은 도착하는 순간 페이지를 아래로 밀어내며, 대부분의 사이트에서 레이아웃 이동의 가장 큰 원인입니다.

::: fw react

```tsx
<Image src={src} alt="…" ratio="16 / 9" />
<Image src={src} alt="…" ratio={1} />
```

기본값 `'auto'`는 파일이 정하게 두며, 그것만으로는 자리를 잡지 않습니다.

:::

::: fw flutter

```dart
NebaImage(image: image, alt: '…', ratio: 16 / 9)
NebaImage(image: image, alt: '…', ratio: 1)
```

`ratio`는 너비를 높이로 나눈 `double`입니다. 생략하면 파일이 도착한 뒤 파일이 정하며, 그것만으로는 자리를 잡지 않습니다.

:::

### width와 height

::: fw react

파일 자체의 픽셀 크기입니다. 어느 쪽이든 그림에 전달되며, 둘 다 주면 `'auto'` 비율이 그 둘의 비율이 됩니다. 1200×800이 3/2라는 것을 직접 계산하지 않아도 상자가 잡힙니다. 둘을 함께 주면 크기가 아니라 비율만 정합니다. 상자는 `width: 100%`인 `<img>`처럼 컨테이너가 준 너비만큼 퍼집니다. 320픽셀 너비로 두려면 Image의 `className`이나 `style`에 그 너비를 주세요.

```tsx
<Image src={src} alt="…" width={1200} height={800} />
```

`ratio`는 레이아웃의 비율이고 이 둘은 그림의 비율이라, `ratio`를 직접 주면 그쪽이 이깁니다.

하나만 주면 비율이 되지 않으므로 그 축의 상자 크기가 됩니다. `height={200}`은 주어진 너비만큼 퍼지는 높이 200픽셀 상자이고, `width={320}`은 컨테이너보다 넓어지지 않는 너비 320픽셀 상자이며 높이는 그림을 따릅니다. 숫자는 픽셀이고 문자열은 CSS 길이입니다. `ratio`를 함께 주면 `height` 하나만 준 상자는 너비를 비율에서 가져옵니다.

```tsx
<Image src={src} alt="…" height={200} fit="contain" />
<Image src={src} alt="…" width={320} />
```

:::

::: fw flutter

파일 자체의 픽셀 크기입니다. 둘 다 주면 그 둘이 상자의 비율이 되어, 1200×800이 3/2라는 것을 직접 계산하지 않아도 상자가 잡힙니다. 둘을 함께 주면 크기가 아니라 비율만 정합니다. `Image`의 `width`, `height`와 달리 상자는 주어진 너비만큼 퍼집니다. 320픽셀 너비로 두려면 `SizedBox(width: 320)` 안에 넣으세요.

```dart
NebaImage(image: image, alt: '…', width: 1200, height: 800)
```

`ratio`는 레이아웃의 비율이고 이 둘은 그림의 비율이라, `ratio`를 직접 주면 그쪽이 이깁니다.

하나만 주면 비율이 되지 않으므로 그 축의 상자 크기가 되며, 단위는 논리 픽셀입니다. `height: 200`은 주어진 너비만큼 퍼지는 높이 200픽셀 상자이고, `width: 320`은 주어진 너비보다 넓어지지 않고 시작 쪽에 붙는 너비 320픽셀 상자이며 높이는 그림을 따릅니다. `ratio`를 함께 주면 `height` 하나만 준 상자는 너비를 비율에서 가져옵니다. `Row` 안처럼 채울 너비가 없으면 상자는 알고 있는 파일의 너비가 됩니다.

```dart
NebaImage(image: image, alt: '…', height: 200, fit: BoxFit.contain)
NebaImage(image: image, alt: '…', width: 320)
```

`IntrinsicHeight`처럼 배치하기 전에 크기를 재는 부모에게도 상자는 실제로 차지할 크기를 답합니다.

:::

### fit과 rounded

::: fw react

`fit`은 `object-fit`이며 `cover`(기본값), `contain`, `fill`, `none`, `scale-down` 중 하나를 받습니다. `ratio`든 `width`나 `height` 하나든 `className`이든, 그림과 모양이 다른 상자 안에서 그림을 어떻게 둘지 정합니다. `rounded`는 radius 사다리의 한 단계를 받고, `true`면 `md`입니다.

:::

::: fw flutter

`fit`은 `BoxFit`이며 `cover`(기본값), `contain`, `fill`, `none`, `scaleDown`에 더해 `fitWidth`와 `fitHeight`도 받습니다. `ratio`든 `width`나 `height` 하나든, 그림과 모양이 다른 상자 안에서 그림을 어떻게 둘지 정합니다. `rounded`는 radius 사다리의 한 단계를 받고, 기본값 `null`은 모서리를 각지게 둡니다.

:::

<Demo src="image/fit">

::: fw react

<<< @/.vitepress/demos/image/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/fit.dart

:::

</Demo>

### position

::: fw react

상자 안에서 그림이 놓이는 자리이며, `object-position`이 쓰는 방식 그대로 받습니다. `center`(기본값), `top`, `right`, `bottom`, `left`, `top left` 같은 모서리, `'30% 20%'` 같은 퍼센트 두 개 중 하나입니다. `cover`에서는 잘라낸 뒤 그림의 어느 부분이 남을지 정하고, `contain`, `none`, `scale-down`에서는 빈 영역이 어느 쪽에 생길지 정합니다.

:::

::: fw flutter

상자 안에서 그림이 놓이는 자리이며 `Alignment`로 받습니다. `Alignment.center`(기본값), `Alignment.topCenter` 같은 변, `Alignment.topLeft` 같은 모서리, 또는 직접 정한 점입니다. `Alignment`는 `-1`에서 `1`까지이므로 React의 `'30% 20%'`는 `Alignment(-0.4, -0.6)`입니다. `cover`에서는 잘라낸 뒤 그림의 어느 부분이 남을지 정하고, 다른 fit에서는 빈 영역이 어느 쪽에 생길지 정합니다.

:::

화면에 보이는 그림을 기준으로 읽기 때문에 `rotate`와 `flip`을 거쳐도 유지됩니다. <Fw react="`position=&quot;top&quot;`은" flutter="`Alignment.topCenter`는" /> 독자에게 보이는 그림의 위쪽을 남깁니다. 또한 논리 방향이 아니라 물리 방향이라, 오른쪽에서 왼쪽으로 쓰는 페이지에서도 좌우가 바뀌지 않습니다.

<Demo src="image/position">

::: fw react

<<< @/.vitepress/demos/image/position.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/position.dart

:::

</Demo>

### letterbox

::: fw react

`contain`, `none`, `scale-down`에서 그림이 채우지 못한 상자 영역을 무엇으로 채울지 정합니다. `blur`는 같은 그림을 상자에 꽉 차게 흐리게 깔아, 동영상 플레이어가 세로 영상의 양옆을 채우는 방식과 같게 만듭니다. 그 밖의 문자열은 색, 토큰, 그러데이션 같은 CSS `background`입니다. 기본값 `none`은 상자를 투명하게 둡니다.

흐린 사본은 같은 파일이라 다시 내려받지 않으며, 그림과 같은 `loading`과 fetch priority로 요청합니다. `position`, `rotate`, `flip`, `filter`를 그대로 따르며, 빈 영역이 생길 수 있는 `fit`에서만 그립니다.

:::

::: fw flutter

`contain`, `none`, `scaleDown`에서 그림이 채우지 못한 상자 영역을 무엇으로 채울지 정합니다. `NebaImageLetterbox.blur`는 같은 그림을 상자에 꽉 차게 흐리게 깔아, 동영상 플레이어가 세로 영상의 양옆을 채우는 방식과 같게 만듭니다. `NebaImageLetterbox.color`는 색을, `NebaImageLetterbox.decoration`은 그러데이션을 포함한 어떤 `Decoration`이든 받습니다. 기본값 `NebaImageLetterbox.none`은 상자를 투명하게 둡니다.

흐린 사본은 그림이 디코딩한 파일 그대로에서 그리므로 다시 내려받지 않습니다. `position`, `rotate`, `flip`, `filter`를 그대로 따르며, 빈 영역이 생길 수 있는 `fit`에서만 그립니다.

:::

<Demo src="image/letterbox">

::: fw react

<<< @/.vitepress/demos/image/letterbox.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/letterbox.dart

:::

</Demo>

### rotate와 flip

`rotate`는 그림을 시계 방향으로 `0`, `90`, `180`, `270`도 돌립니다. `flip`은 그림을 뒤집으며 `horizontal`, `vertical`, `both`, 그리고 기본값 `none`을 받습니다. 뒤집는 축은 화면에 보이는 그림을 기준으로 하므로, 돌렸든 아니든 <Fw react="`flip=&quot;horizontal&quot;`은" flutter="`NebaImageFlip.horizontal`은" /> 좌우를 바꿉니다.

옆으로 누운 그림은 누운 모양으로 배치됩니다. `width`와 `height`는 여전히 파일의 크기라서 <Fw react="`width={560} height={373} rotate={90}`은" flutter="`width: 560, height: 373, rotate: 90`은" /> 세로로 긴 상자를 잡고, 둘 다 없으면 파일이 도착한 뒤 돌린 모양의 상자가 됩니다. `ratio`를 직접 주면 그 비율은 그대로 두고, 돌린 그림이 상자를 채우는 방식은 `fit`이 정합니다. preview도 같은 방향으로 돌리고 뒤집어서 엽니다.

::: fw flutter

그 밖의 각도는 가장 가까운 90도 단위로 읽습니다. 돌리기는 그림을 감싼 `RotatedBox`이고 뒤집기는 그 바깥의 `Transform.flip`입니다. 둘 다 움직이지 않는 상자 안에서 사진에만 걸리는 변환이며, 디자인 언어는 다시 샘플링할 글자가 없는 사진에는 이를 허용하고 컨트롤에는 허용하지 않습니다.

:::

<Demo src="image/rotate">

::: fw react

<<< @/.vitepress/demos/image/rotate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/rotate.dart

:::

</Demo>

### placeholder와 fallback

::: fw react

파일이 도착하는 동안 같은 모양의 [Skeleton](../feedback/skeleton)이 자리를 지킵니다. 직접 만든 노드를 넘기거나 `false`로 끌 수 있습니다.

`{ src }`를 넘기면 대신 그림이 자리를 지킵니다. URL, data URI, `Blob`을 받으며, Blob은 object URL로 보여 주고 필요 없어지면 해제합니다. 최종 그림과 같은 `fit`, `position`, `rotate`, `flip`으로 그리므로 같은 파일의 작은 사본을 넣는 용도입니다. 몇 픽셀짜리를 늘린 사본은 `blur`로 부드럽게 만들 수 있고, `true`면 20픽셀, 숫자를 주면 그만큼 흐립니다. 그림은 이 사본 위로 서서히 나타나고, 사본은 그 전환이 끝난 뒤 사라집니다. Skeleton처럼 상자를 채우므로 `ratio`나 `width`와 `height`가 있어야 보입니다. 그림의 `loading`을 따르므로 `loading="lazy"`면 이 사본도 독자가 가까이 스크롤할 때까지 불러오지 않습니다.

:::

::: fw flutter

파일이 도착하는 동안 같은 모양의 [Skeleton](../feedback/skeleton)이 자리를 지킵니다. Flutter의 `Image`가 첫 프레임 전에 그릴 것을 `frameBuilder`로 받는 자리에서, 여기서는 `placeholder`가 그것을 정합니다. 직접 만든 위젯은 `NebaImagePlaceholder.widget`으로, 아무것도 두지 않으려면 `NebaImagePlaceholder.none`으로 줍니다. `image`가 `null`이면 아직 파일을 기다리는 그림이고, 그동안 placeholder가 계속 자리를 지킵니다.

`NebaImagePlaceholder.image`는 대신 그림이 자리를 지키게 하며, 어떤 `ImageProvider`든 받습니다. 최종 그림과 같은 `fit`, `position`, `rotate`, `flip`으로 그리므로 같은 파일의 작은 사본을 넣는 용도입니다. 몇 픽셀짜리를 늘린 사본은 `blur`로 부드럽게 만들 수 있고, 값은 논리 픽셀 단위의 표준 편차입니다. React의 `blur: true`는 `20`입니다. 그림은 이 사본 위로 서서히 나타나고, 사본은 그 전환이 끝난 뒤 사라집니다. Skeleton처럼 상자를 채우므로 `ratio`나 `width`와 `height`가 있어야 보입니다.

:::

<Demo src="image/placeholder">

::: fw react

<<< @/.vitepress/demos/image/placeholder.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/placeholder.dart

:::

</Demo>

::: fw react

서버에서 렌더한 페이지에서는 그림을 숨기지 않고, 그 위를 아무것도 덮지 않습니다. placeholder는 `<img>` 아래에 깔리고, 그림은 브라우저가 파일을 받는 대로 보입니다. hydration 전에도, JavaScript가 꺼져 있어도 마찬가지이므로 Largest Contentful Paint가 스크립트를 기다리지 않습니다. hydration 전까지는 그림이 비워 둔 부분, 예를 들어 `contain`이 남긴 양옆이나 PNG의 투명한 부분으로 placeholder가 비쳐 보입니다. 페이지를 불러온 뒤에 추가된 그림처럼 브라우저에서 처음 마운트된 그림은 placeholder 위로 서서히 나타납니다.

도착하지 못하면 `fallback`이 대신 그려지고, 기본값은 `alt` 텍스트를 담은 상자입니다. 아무것도 없는 것보다 나은 이유는, 브라우저 자신의 찢어진 종이 글리프가 독자에게 파일 하나가 없다는 게 아니라 **사이트가** 고장 났다고 말하기 때문입니다.

`src`가 바뀌면 둘 다 처음부터 다시 시작합니다. 그러지 않으면 두 번째 파일이 첫 번째의 성공을 물려받아 placeholder를 아예 보여 주지 않고, 실패한 두 번째 파일도 마찬가지로 성공을 물려받습니다.

:::

::: fw flutter

이미 이미지 캐시에 있는 그림은 페이드도 placeholder도 없이 바로 그립니다. 그 그림 없이 그려진 프레임이 한 번도 없었기 때문입니다. 그 밖의 그림은 placeholder 위로 서서히 나타납니다.

도착하지 못하면 `Image`라면 `errorBuilder`를 부를 자리에서 `fallback`이 대신 그려지고, 기본값은 `alt` 텍스트를 담은 상자입니다. 아무것도 없는 것보다 나은 이유는, 빈 구멍이 독자에게 파일 하나가 없다는 게 아니라 **앱이** 고장 났다고 말하기 때문입니다. 실패한 파일은 `FlutterError`로 보고하지 않습니다. fallback이 바로 그 경우를 위한 것이기 때문입니다.

`image`가 바뀌면 둘 다 처음부터 다시 시작합니다. 그러지 않으면 두 번째 파일이 첫 번째의 성공을 물려받아 placeholder를 아예 보여 주지 않고, 실패한 두 번째 파일도 마찬가지로 성공을 물려받습니다. 이름이 같은 `AssetImage`처럼 이전 것과 같은 provider는 같은 그림입니다.

:::

### priority와 loading

::: fw react

그림을 언제 불러올지는 `<img>`의 속성이 정하고, 그 속성은 그대로 전달됩니다. `loading="lazy"`는 화면 아래쪽 그림을 독자가 가까이 스크롤할 때까지 미루고, `decoding="async"`는 디코딩을 메인 스레드 밖으로 빼며, `fetchPriority`는 네트워크 대기열에서 요청의 순서를 올리거나 내립니다.

`priority`는 페이지의 평가 기준이 되는 그림, 보통 첫 화면에서 가장 큰 그림에 씁니다. Largest Contentful Paint가 재는 것이 바로 그 그림입니다. `loading="eager"`와 높은 fetch priority를 함께 설정하며, 속성을 직접 쓰면 그쪽이 이깁니다. 브라우저에서 처음 마운트된 Image라도 그림을 페이드나 Skeleton 없이 그립니다. `placeholder` 그림은 여전히 그 아래에 깔립니다. lazy로 불러오는 그림도 자리를 잡아야 하므로 `ratio`나 `width`와 `height`를 함께 주세요.

```tsx
<Image src={hero} alt="…" ratio="16 / 9" priority />
<Image src={thumbnail} alt="…" ratio={1} loading="lazy" />
```

:::

::: fw flutter

Flutter에는 `loading`, `decoding`, `fetchPriority`가 없습니다. 그림은 그 위젯이 빌드될 때 요청됩니다. 화면 아래쪽 그림은 `ListView.builder`나 sliver로 늦게 빌드해서 미루고, 처음부터 있어야 하는 그림은 `precacheImage`로 미리 가져옵니다.

남는 것은 `priority`이며, 화면의 평가 기준이 되는 그림을 페이드나 Skeleton 없이 그립니다. `placeholder` 그림은 도착하는 동안 여전히 그 아래에 깔립니다.

```dart
NebaImage(image: hero, alt: '…', ratio: 16 / 9, priority: true)
```

:::

### preview

::: fw react

클릭하면 [Dialog](../feedback/dialog)에서 원본을 엽니다.

그림이 `alt`를 이름으로 갖는 `<button>`이 되므로 `Tab`으로 닿고 `Enter`로 열립니다. 포인터로만 확대할 수 있는 그림은 독자의 절반이 확대할 수 없는 그림입니다.

`preview`가 켜지면 `className`과 `style`은 버튼에 붙습니다. 그래서 그림의 크기를 정하는 값이 누를 수 있는 영역의 크기도 정합니다.

Dialog의 코드는 pointer나 focus, 손가락이 그림에 처음 닿을 때 내려받기 시작하므로 누를 때쯤이면 대개 도착해 있고, Dialog는 누르는 순간 마운트됩니다. 아무도 그림에 다가가지 않는 페이지는 그 코드를 받지 않고, 서버 렌더링도 기다릴 것이 없습니다.

:::

::: fw flutter

누르면 Dialog가 그리는 시트에 원본을 띄웁니다. 시트는 `alt`를 제목으로, 모서리의 ×와 함께 scrim 위에 서서히 나타납니다. 그림은 파일 자체의 크기이며 확대하지 않고, 시트의 너비와 창 높이의 70%에 맞춰 줄어듭니다. 위에 `Overlay`가 있어야 하며, navigator가 있는 `WidgetsApp`에는 이미 있고 그 밖에는 `Overlay.wrap`으로 둘 수 있습니다.

그림이 `alt`를 이름으로 갖는 버튼이 되므로 `Tab`으로 닿고 `Enter`나 `Space`로 열립니다. 포인터로만 확대할 수 있는 그림은 독자의 절반이 확대할 수 없는 그림입니다. Escape, ×, scrim을 누르면 닫히고 focus는 그림으로 돌아갑니다. 시트는 열리기 전까지 아무것도 빌드하지 않습니다.

:::

<Demo src="image/preview" frameMinHeight="560">

::: fw react

<<< @/.vitepress/demos/image/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/preview.dart

:::

</Demo>

### filter

::: fw react

그림의 색조입니다. 이름 붙은 일곱 가지(`grayscale` · `sepia` · `invert` · `saturate` · `mute` · `contrast`, 그리고 기본값인 `none`) 또는 그 너머의 것을 위한 CSS `filter` 체인입니다.

색조는 그림 자체의 fade와 같은 시계 위에서 움직입니다. 그래서 pointer 아래에서 `className`으로 값을 바꾸면 썸네일이 툭 튀는 대신 살아납니다.

:::

::: fw flutter

그림의 색조입니다. 이름 붙은 일곱 가지(`NebaImageFilter.grayscale` · `sepia` · `invert` · `saturate` · `mute` · `contrast`, 그리고 기본값인 `none`) 또는 그 너머의 것을 위해 `ColorFilter.matrix`가 받는 숫자 스무 개를 넘기는 `NebaImageFilter.matrix`입니다. 각 이름은 React의 이름이 가리키는 CSS 함수 `grayscale(1)`, `sepia(0.72)`, `invert(1)`, `saturate(1.5)`, `saturate(0.45)`, `contrast(1.25)`에 대해 Filter Effects 명세가 적어 둔 행렬이라, 두 패키지에서 같은 색조로 보입니다.

아무 `ColorFilter`가 아니라 행렬인 이유는 행렬은 보간할 수 있기 때문입니다. `filter`가 바뀌면 그림 자체의 fade와 같은 시계 위에서 새 색조로 옮겨 가므로, pointer 아래에서 살아나는 썸네일이 툭 튀지 않습니다.

:::

<Demo src="image/filter">

::: fw react

<<< @/.vitepress/demos/image/filter.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/filter.dart

:::

</Demo>

### frame

::: fw react

그림이 놓이는 방식입니다. 실루엣 하나만 주거나(`frame="circle"`) 전체를 적어 줍니다: `shape` · `corner` · `border` · `borderColor` · `mat` · `background` · `elevation` · `feather`.

선은 `border`가 아니라 inset shadow로 그립니다. 둥근 모서리나 원을 따라갈 수 있는 것도, 레이아웃에서 자리를 차지하지 않는 것도 그 때문입니다. 잘린 모서리의 대각선에는 선이 그려지지 않습니다. 자리를 차지하는 것은 `mat` 하나뿐이며, 선과 그림 사이의 여백입니다.

:::

::: fw flutter

그림이 놓이는 방식이며 `NebaImageFrame`으로 받습니다. 실루엣 하나만 주거나(`NebaImageFrame(shape: NebaImageFrameShape.circle)`) 전체를 적어 줍니다. `corner`는 radius 사다리의 한 단계이고 `cornerRadius`는 픽셀 수입니다. `border`는 선의 두께이며 `1`이 React의 `true`입니다. `feather`는 가장자리를 픽셀 수만큼, `featherFraction`은 그림 너비와 높이의 비율만큼 흐리게 하며 뒤쪽이 React의 `'10%'`입니다. `borderColor`, `mat`, `background`, `elevation`은 React와 같습니다.

선은 mount의 바깥 가장자리를 따라 그림 위에 그리므로 레이아웃에서 자리를 차지하지 않고, 잘린 모서리의 대각선까지 실루엣의 모든 변을 따라갑니다. 자리를 차지하는 것은 `mat` 하나뿐이며, 선과 그림 사이의 여백입니다.

:::

<Demo src="image/frame">

::: fw react

<<< @/.vitepress/demos/image/frame.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/frame.dart

:::

</Demo>

### watermark

::: fw react

그림 위에 그리는 표식입니다. 문자열은 아래 모서리에 하나 놓이고, 객체 형태는 `content` · `position` · `repeat` · `opacity` · `rotate` · `size` · `color`를 받습니다.

`repeat`은 표식을 그림 전체에 타일로 깝니다. 화면 캡처를 실제로 망설이게 하는 쪽은 이쪽입니다. 텍스트여야 하며, 노드는 타일로 그릴 수 없어 한 번만 놓입니다. `color`는 어느 배치에서든 `var(--neba-…)` 토큰을 포함한 CSS 색을 받습니다.

:::

::: fw flutter

그림 위에 그리는 표식이며 `NebaImageWatermark`로 받습니다. `NebaImageWatermark('© Neba')`는 끝쪽 아래 모서리에 하나 놓입니다. `position`은 `AlignmentDirectional`이며 그 상수 `topStart`, `topEnd`, `bottomStart`, `bottomEnd`, `center`가 React의 다섯 자리입니다. 그 밖에 `repeat`, `opacity`, `rotate`, meta 사다리의 한 단계인 `size` 또는 `fontSize`, `color`를 받습니다.

`repeat`은 표식을 그림 전체에 타일로 깝니다. 화면 캡처를 실제로 망설이게 하는 쪽은 이쪽입니다. 위젯은 타일로 그릴 수 없으므로, 로고 같은 위젯은 `NebaImageWatermark.widget`으로 한 번만 놓습니다.

:::

<Demo src="image/watermark">

::: fw react

<<< @/.vitepress/demos/image/watermark.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/watermark.dart

:::

</Demo>

### protect

::: fw react

무심코 가져가는 경로를 막습니다. 우클릭 메뉴, 다른 창으로 끌어놓기, iOS의 길게 누르기, Ctrl-A가 쓸어 담는 선택입니다. `protect` 하나면 넷 다 켜지고, 객체 형태는 `contextMenu` · `drag` · `select`를 따로 받습니다.

완전한 차단이 아니라 억제 수단입니다. 원본 파일은 network 탭에서 그대로 받을 수 있으므로, 접근 제어 용도로는 쓸 수 없습니다. 이 prop이 막는 것은 생각 없이 이루어지는 복사뿐입니다.

:::

::: fw flutter

Flutter가 그리는 그림은 canvas 위의 픽셀이라, 휴대폰이나 데스크톱에서는 그림을 저장하거나 복사하거나 끌어낼 수단이 없고, 선택에도 그림이 담기지 않습니다. React가 막는 네 경로 중 셋은 처음부터 없는 셈입니다. 웹에서는 canvas 위의 브라우저 메뉴가 여전히 pointer 아래의 것을 저장하라고 권하므로, `protect`는 pointer가 그림 위에 있는 동안 `BrowserContextMenu`로 그 메뉴를 끄고, pointer가 떠나면 원래 켜져 있었을 때만 다시 켭니다. 하는 일이 이것뿐이라 `protect`는 `bool`이고 객체 형태가 없습니다. 표식은 protect와 상관없이 늘 선택에서 빠집니다.

완전한 차단이 아니라 억제 수단입니다. 원본 파일은 앱 번들 안에, 혹은 요청 하나 거리에 그대로 있으므로 접근 제어 용도로는 쓸 수 없습니다. 이 prop이 막는 것은 생각 없이 이루어지는 복사뿐입니다.

:::

<Demo src="image/protect">

::: fw react

<<< @/.vitepress/demos/image/protect.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/protect.dart

:::

</Demo>

### onLoadingStatusChange

::: fw react

`'loading'` · `'loaded'` · `'failed'` 중 하나로 호출됩니다. 직접 관리하는 `src`로 바꿔치기하거나, 도착하지 못한 것을 세는 데 쓸 수 있습니다.

:::

::: fw flutter

상태가 바뀐 프레임이 끝난 뒤 `NebaImageLoadingStatus.loading` · `loaded` · `failed` 중 하나로 호출됩니다. 이미 캐시에 있는 그림은 `loaded` 하나만 알립니다. 직접 관리하는 `image`로 바꿔치기하거나, 도착하지 못한 것을 세는 데 쓸 수 있습니다.

:::

## 접근성

::: fw react

- `alt`가 그림의 accessible name입니다. 무엇을 찍은 사진인지가 아니라 그 그림이 **무엇을 말하는지**를 쓰고, 주변 글이 이미 말하는 것뿐이라면 `alt=""`을 쓰세요.
- `preview`가 켜지면 버튼은 `alt`에서만 이름을 가져옵니다. 한 사물에 이름이 둘이면 스크린 리더가 같은 문장을 두 번 읽기 때문입니다. `alt=""`인 그림은 빌려줄 이름이 없으므로, 버튼과 미리보기에 `locale`의 언어로 "이미지 확대"라는 이름이 붙습니다.
- placeholder와 fallback은 따로 읽히지 않습니다. 그림은 그동안에도 자기 이름을 유지합니다.
- `alt`가 빈 그림이 실패하면 대신 놓을 이름이 없으므로, 상자가 페이지의 언어로 그 사실을 말합니다. `locale`을 주거나 `unavailableLabel`로 문장을 직접 쓰세요.
- watermark는 `aria-hidden`이고 pointer 이벤트를 받지 않습니다. 표식이 말하는 내용은 그림 주변의 글이나 `alt`에 두세요. 표식을 볼 수 없는 독자도 거기서는 만납니다.
- `protect`는 무언가를 더하는 것이 아니라 브라우저가 주던 것을 뺍니다. 여기서 꺼지는 것 중 키보드 경로나 스크린 리더 경로는 없지만, "새 탭에서 이미지 열기"는 우클릭 메뉴와 함께 사라집니다. 그림 위의 표식이 요점인 곳에서만 켜고, 기본으로 켜지는 마세요.

:::

::: fw flutter

- `alt`가 그림의 이름이며, 스크린 리더는 그 이름의 이미지로 듣습니다. 무엇을 찍은 사진인지가 아니라 그 그림이 **무엇을 말하는지**를 쓰고, 주변 글이 이미 말하는 것뿐이라면 `alt: ''`을 쓰세요. 그러면 그림은 semantics 트리에서 빠집니다.
- `preview`가 켜지면 버튼은 `alt`에서만 이름을 가져옵니다. 한 사물에 이름이 둘이면 스크린 리더가 같은 문장을 두 번 읽기 때문입니다. `alt: ''`인 그림은 빌려줄 이름이 없으므로, 버튼과 미리보기에 `locale`의 언어로 "이미지 확대"라는 이름이 붙습니다.
- placeholder와 fallback은 따로 읽히지 않습니다. 그림은 그동안에도 자기 이름을 유지합니다.
- `alt`가 빈 그림이 실패하면 대신 놓을 이름이 없으므로, 상자가 앱의 언어로 그 사실을 말합니다. `locale`을 주거나 `unavailableLabel`로 문장을 직접 쓰세요.
- watermark는 semantics 트리에서도, pointer가 닿는 범위에서도, 선택에서도 빠집니다. 표식이 말하는 내용은 그림 주변의 글이나 `alt`에 두세요. 표식을 볼 수 없는 독자도 거기서는 만납니다.
- `protect`는 무언가를 더하는 것이 아니라 브라우저가 주던 것을 뺍니다. 여기서 꺼지는 것 중 키보드 경로나 스크린 리더 경로는 없지만, "새 탭에서 이미지 열기"는 브라우저 메뉴와 함께 사라집니다. 그림 위의 표식이 요점인 곳에서만 켜고, 기본으로 켜지는 마세요.

:::
