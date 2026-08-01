---
title: TextLink
order: 16
---

# TextLink

<p class="neba-lede">문장 안에서든 혼자서든, 링크를 텍스트로 표현합니다. 표면도 고유한 높이도 없습니다. 가진 것은 아래에 그어지는 선과, 창을 가져가는 링크에 붙는 표식뿐입니다.</p>

<Demo src="text-link/hero" />

```tsx
import { TextLink } from 'neba';

<TextLink href="/components/">컴포넌트</TextLink>
<TextLink href="https://neba.cdget.com/components/" newTab>모든 컴포넌트</TextLink>
<TextLink href="/guide/getting-started" underline="hover" color="primary">시작하기</TextLink>;
```

## Props

<PropsTable name="TextLink" />

나머지 `<a>` 속성은 모두 전달됩니다. `target`과 `rel`도 마찬가지로, `newTab`은 그 둘이 비어 있을 때만 채웁니다.

공통 축 가운데 `color`와 `size`에는 기본값이 없습니다. 문단 안의 링크는 그 문단의 색이자 그 문단의 크기이기 때문입니다. 나머지 어휘는 [Prop 규약](../../design/prop-conventions)에 있습니다.

루트에는 `neba-link` 클래스가 붙습니다. `a`를 태그 이름으로 스타일링하는 스타일시트 — `.prose a`를 비롯한 대부분의 CSS 프레임워크 — 가 예외로 빼낼 수 있는 후크입니다. `.prose a:not(.neba-link) { … }`처럼 씁니다.

## 예시

### underline

기본값은 `always`입니다. `hover`는 포인터가 올라갔을 때만 선을 긋고, `none`은 아예 긋지 않습니다. `none`은 링크임을 이미 다른 것이 말해 주고 있을 때 — nav 바, footer, 제목 아래 나란히 놓인 줄 — 씁니다.

<Demo src="text-link/underline">

<<< @/.vitepress/demos/text-link/underline.tsx

</Demo>

hover는 선만 바꾸고 글자 색은 건드리지 않습니다. 포인터 아래에서 색이 바뀌는 단어는 읽고 있던 줄에서 시선을 떼어 놓습니다.

### color

`color`가 없으면 링크는 주위 텍스트의 색을 그대로 씁니다. 여섯 가지 역할 색 중 하나를 주면 라벨과 선이 함께 물듭니다.

<Demo src="text-link/colors">

<<< @/.vitepress/demos/text-link/colors.tsx

</Demo>

### size

이것도 기본값이 없습니다. 문장 속 링크는 그 문장의 크기입니다. 혼자 서 있는 링크에는 `size`를 주면 되고, 줄바꿈이 일어나는 텍스트에 맞는 행간까지 함께 따라옵니다.

<Demo src="text-link/sizes">

<<< @/.vitepress/demos/text-link/sizes.tsx

</Demo>

### newTab과 icon

`newTab`은 `target="_blank"`와, 새 페이지가 `window.opener`로 되돌아오지 못하게 하는 `rel`을 함께 붙입니다. 동시에 `icon`을 켭니다. 독자 아래에서 창이 바뀌는 것은 링크에서 유일하게 벌어지고 난 뒤에야 알 수 있는 일이기 때문입니다.

`icon`은 양쪽 모두를 덮어씁니다. 새 탭 링크에 표식을 없애려면 `false`, 같은 탭 링크에 표식을 붙이려면 `true`, 글리프 자체를 바꾸려면 노드를 넘깁니다.

<Demo src="text-link/external">

<<< @/.vitepress/demos/text-link/external.tsx

</Demo>

### locale

`newTab`은 그려지지 않고 읽히기만 하는 문장 — "(새 창에서 열림)" — 을 덧붙입니다. `locale`은 그 문장을 어느 언어로 쓸지를 정하며, `ko`, `pt-BR`, `zh-Hant` 같은 BCP 47 태그를 받습니다. 번역이 없는 태그는 영어로 돌아갑니다.

```tsx
<TextLink href="https://neba.cdget.com/components/" newTab locale="ko">
  모든 컴포넌트
</TextLink>
```

### render

`render`는 다른 것은 그대로 둔 채 요소만 바꿉니다. 대개는 router가 주는 `Link`입니다. `href`는 TextLink에 그대로 두면 되므로 한 번만 씁니다.

```tsx
import Link from 'next/link';

<TextLink href="/components/" render={<Link href="/components/" />}>
  컴포넌트
</TextLink>;
```

## 접근성

- 새 탭에서 열리는 링크는 그 사실을 accessible name에 담습니다. 페이지의 언어로 읽히도록 `locale`을 지정하세요.
- `underline="none"`은 색만을 링크의 단서로 남깁니다. 색만으로는 모든 독자에게 전달되지 않으므로, 주변 레이아웃이 이미 링크임을 말하고 있는 자리에만 쓰세요.
- focus ring은 `color`가 없어도 그려집니다. 사라지는 대신 primary ring으로 돌아갑니다.
