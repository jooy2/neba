---
title: Image
order: 23
---

# Image

<p class="neba-lede">불러오는 동안 자리를 지키고, 불러오는 중이라고 말하고, 실패하면 쓸모 있는 것을 말하는 그림입니다. 맨 <code>&lt;img&gt;</code>가 쓰는 사람에게 떠넘기는 세 가지입니다.</p>

<Demo src="image/hero" />

```tsx
import { Image } from 'neba';

<Image src={src} alt="아침 안개가 내린 차밭" ratio="16 / 9" rounded />;
```

## Props

<PropsTable name="Image" />

`<img>`의 native 속성은 그림 자체로 전달됩니다 — `loading` · `decoding` · `srcSet` · `sizes` · `referrerPolicy`. `width`와 `height`만 제외되며, 자리를 잡는 일은 `ratio`와 상자에 맡깁니다.

### `alt`은 필수입니다

타입 수준에서 그렇고, 이것이 감싸는 태그보다 이 컴포넌트가 엄격한 유일한 지점입니다.

`alt`이 없는 것과 빈 것은 서로 다른 뜻입니다 — "아무도 쓰지 않았다"와 "이 그림은 독자가 알아야 할 것을 말하지 않는다" — 그리고 옳은 쪽은 두 번째뿐입니다. `alt=""`을 직접 쓰게 하는 것은 둘 중 어느 쪽인지 말하게 하는 것입니다.

## 예시

### ratio

파일이 도착하는 동안 지킬 비율이고, `<img>` 대신 이것을 쓰는 주된 이유입니다. 자리를 잡아 두지 않은 그림은 도착하는 순간 페이지를 아래로 밀어내며, 대부분의 사이트에서 레이아웃 이동의 가장 큰 원인입니다.

```tsx
<Image src={src} alt="…" ratio="16 / 9" />
<Image src={src} alt="…" ratio={1} />
```

기본값 `'auto'`는 이것을 포기합니다. 주변 공간이 그 튐을 흡수할 수 있을 때만 맞습니다.

### fit과 rounded

`fit`은 `object-fit`입니다 — `cover`(기본값) · `contain` · `fill` · `none`. `rounded`는 radius 사다리의 한 단계를 받고, `true`면 `md`입니다.

### placeholder와 fallback

파일이 도착하는 동안 같은 모양의 [Skeleton](../feedback/skeleton)이 자리를 지킵니다. 직접 만든 노드를 넘기거나 `false`로 끌 수 있습니다.

도착하지 못하면 `fallback`이 대신 그려지고, 기본값은 `alt` 텍스트를 담은 상자입니다. 아무것도 없는 것보다 나은 이유는, 브라우저 자신의 찢어진 종이 글리프가 독자에게 파일 하나가 없다는 게 아니라 **사이트가** 고장 났다고 말하기 때문입니다.

`src`가 바뀌면 둘 다 처음부터 다시 시작합니다. 그러지 않으면 두 번째 파일이 첫 번째의 성공을 물려받아 placeholder를 아예 보여 주지 않고, 실패한 두 번째 파일도 마찬가지로 성공을 물려받습니다.

### preview

클릭하면 [Dialog](../feedback/dialog)에서 원본을 엽니다.

그림이 `alt`을 이름으로 갖는 `<button>`이 되므로 `Tab`으로 닿고 `Enter`로 열립니다. 포인터로만 확대할 수 있는 그림은 독자의 절반이 확대할 수 없는 그림입니다.

<Demo src="image/preview">

<<< @/.vitepress/demos/image/preview.tsx

</Demo>

### filter

그림의 색조입니다. 이름 붙은 일곱 가지 — `grayscale` · `sepia` · `invert` · `saturate` · `mute` · `contrast`, 그리고 기본값인 `none` — 또는 그 너머의 것을 위한 CSS `filter` 체인입니다.

색조는 그림 자체의 fade와 같은 시계 위에서 움직입니다. 그래서 pointer 아래에서 `className`으로 값을 바꾸면 썸네일이 툭 튀는 대신 살아납니다.

<Demo src="image/filter">

<<< @/.vitepress/demos/image/filter.tsx

</Demo>

### frame

그림이 놓이는 방식입니다. 실루엣 하나만 주거나 — `frame="circle"` — 전체를 적어 줍니다: `shape` · `corner` · `border` · `borderColor` · `mat` · `background` · `elevation` · `feather`.

선은 `border`가 아니라 inset shadow로 그립니다. 잘린 모서리나 원을 따라갈 수 있는 것도, 레이아웃에서 자리를 차지하지 않는 것도 그 때문입니다. 자리를 차지하는 것은 `mat` 하나뿐이며, 선과 그림 사이의 여백입니다.

<Demo src="image/frame">

<<< @/.vitepress/demos/image/frame.tsx

</Demo>

### watermark

그림 위에 그리는 표식입니다. 문자열은 아래 모서리에 하나 놓이고, 객체 형태는 `content` · `position` · `repeat` · `opacity` · `rotate` · `size` · `color`를 받습니다.

`repeat`은 표식을 그림 전체에 타일로 깝니다. 화면 캡처를 실제로 망설이게 하는 쪽은 이쪽입니다. 텍스트여야 하며, 노드는 타일로 그릴 수 없어 한 번만 놓입니다.

<Demo src="image/watermark">

<<< @/.vitepress/demos/image/watermark.tsx

</Demo>

### protect

무심코 가져가는 경로를 막습니다. 우클릭 메뉴, 다른 창으로 끌어놓기, iOS의 길게 누르기, Ctrl-A가 쓸어 담는 선택입니다. `protect` 하나면 넷 다 켜지고, 객체 형태는 `contextMenu` · `drag` · `select`를 따로 받습니다.

자물쇠가 아니라 억지책입니다. 파일은 network 탭에서 요청 하나 거리에 그대로 있고, 가져가려는 사람은 결국 가져갑니다. 이것이 막는 것은 생각 없이 이루어지는 복사입니다. 비밀을 지키려고 켜는 것이라면 이유가 틀렸습니다.

<Demo src="image/protect">

<<< @/.vitepress/demos/image/protect.tsx

</Demo>

### onLoadingStatusChange

`'loading'` · `'loaded'` · `'failed'` 중 하나로 호출됩니다. 직접 관리하는 `src`로 바꿔치기하거나, 도착하지 못한 것을 세는 데 쓸 수 있습니다.

## 접근성

- `alt`이 그림의 accessible name입니다. 무엇을 찍은 사진인지가 아니라 그 그림이 **무엇을 말하는지**를 쓰고, 주변 글이 이미 말하는 것뿐이라면 `alt=""`을 쓰세요.
- `preview`가 켜지면 버튼은 `alt`에서만 이름을 가져옵니다. 한 사물에 이름이 둘이면 스크린 리더가 같은 문장을 두 번 읽습니다.
- placeholder와 fallback은 따로 읽히지 않습니다. 그림은 그동안에도 자기 이름을 유지합니다.
- watermark는 `aria-hidden`이고 pointer 이벤트를 받지 않습니다. 표식이 말하는 내용은 그림 주변의 글이나 `alt`에 두세요. 표식을 볼 수 없는 독자도 거기서는 만납니다.
- `protect`는 무언가를 더하는 것이 아니라 브라우저가 주던 것을 뺍니다. 여기서 꺼지는 것 중 키보드 경로나 스크린 리더 경로는 없지만, "새 탭에서 이미지 열기"는 우클릭 메뉴와 함께 사라집니다. 그림 위의 표식이 요점인 곳에서만 켜고, 기본으로 켜지는 마세요.
