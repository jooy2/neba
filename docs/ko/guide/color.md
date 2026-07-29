---
title: 색
order: 3
---

# 색

Neba는 임의의 색상값을 받지 않습니다. `color`는 `#4072cd`가 아니라 **여섯 개의 의미론적 계열** 중 하나이고, 계열 하나는 `styles.css`에 정의된 토큰 묶음입니다.

```tsx
<Button color="danger">삭제</Button>
```

계열마다 손으로 정하는 값은 **다섯 개**뿐이고, 나머지는 전부 그 다섯에서 `color-mix()`로 파생됩니다. 색을 바꾸고 싶다면 손댈 곳도 그 다섯 개입니다.

## 팔레트

아래 값은 브라우저가 실제로 계산한 값을 그대로 읽어 온 것입니다. 오른쪽 위 테마 토글을 누르면 다크 테마 값으로 바뀝니다.

<Demo src="color/palette" plain />

## 토큰 구조

계열 하나는 `--neba-{계열}-{역할}` 형태의 토큰으로 이루어집니다.

### 직접 지정하는 다섯 개

```css
--neba-{color}-solid          /* 채움 기준색 */
--neba-{color}-solid-hover    /* −4.5 명도 */
--neba-{color}-solid-active   /* −12 명도 */
--neba-{color}-on-solid       /* 채움 위 글자색 */
--neba-{color}-accent         /* 표면 위에서 읽히는 색 (text/outline 변형용) */
```

`solid`와 `accent`는 역할이 다릅니다. `solid`는 **글자를 얹을 배경**이고, `accent`는 **배경 위에 얹을 글자**입니다. 그래서 같은 계열이라도 `accent`가 더 밝고 채도가 높습니다 — 흰 배경 위에서 대비를 확보해야 하는 쪽은 `accent`이기 때문입니다.

### 파생되는 나머지

```css
--neba-{color}-fill           /* solid을 --neba-fill-alpha(88%)만큼 불투명하게 */
--neba-{color}-fill-hover
--neba-{color}-fill-active
--neba-{color}-panel          /* accent 8%  + --neba-glass-bg — outline 컨트롤의 표면 */
--neba-{color}-panel-hover    /* accent 16% */
--neba-{color}-panel-press    /* accent 24% */
--neba-{color}-soft           /* accent 10% — text 변형의 hover 워시 */
--neba-{color}-soft-hover     /* accent 17% */
--neba-{color}-soft-press     /* accent 25% */
--neba-{color}-line           /* accent 22% — 하이라인 */
--neba-{color}-line-hover     /* accent 40% */
--neba-{color}-ring           /* accent 55% — 포커스 링 */
```

> **파생 블록은 테마 루트마다 반복됩니다.** 커스텀 프로퍼티는 선언된 요소에서 `var()`를 해석하므로, 파생 토큰을 `:root`에만 두면 `.dark` 하위 트리에서도 라이트 값으로 굳습니다. 자세한 이유는 [디자인 언어](./design-language)에 있습니다.

## 컨테이너 표면은 염색하지 않습니다

계열이 표면을 채우는 것은 **컨트롤**뿐입니다. Box·Card·TextField는 계열별 `--neba-{color}-panel`이 아니라 색이 전혀 없는 중립 세 단계를 씁니다.

```css
--neba-panel        /* 흰색 66% (다크 7%) */
--neba-panel-hover  /* 흰색 82% (다크 10%) */
--neba-panel-press  /* 흰색 92% (다크 13%) */
```

컨테이너가 담는 것은 다른 곳에서 온 콘텐츠이고, 본문·링크·버튼·필드는 이미 자기 색을 가지고 도착합니다. 그 아래 시트를 물들이면 그 전부가 아무도 검토하지 않은 배경 위에 놓이게 되고, 대비를 다시 확인해야 하는 조합만 늘어납니다. 그래서 **계열은 하이라인·포커스 링·캐럿에서 멈추고 시트는 흰색으로 남습니다.** 반대로 Button의 표면은 *색칠되는 대상 자체*이므로 계열 색을 그대로 씁니다.

<Demo src="color/surfaces">

<<< @/.vitepress/demos/color/surfaces.tsx

</Demo>

세 단계가 명도가 아니라 **불투명도**로 올라가는 것도 같은 이유입니다. 상태가 올라갈수록 시트가 빛을 더 머금을 뿐 회색으로 가지 않습니다.

> **부작용 하나.** 테두리가 없는 `solid` Box/Card에서는 `color`가 닿을 곳이 없어 보이는 변화가 없습니다. 컨테이너에서 `color`는 사실상 가장자리 색을 고르는 prop입니다.

## 대비

색은 전부 `oklch()`로 정의합니다. 명도 축이 지각과 일치해서 여섯 계열의 밝기를 같은 숫자로 맞출 수 있기 때문입니다.

- **채움 위 글자는 4.5:1을 지킵니다.** `solid`/`hover`/`active` 세 단계 전부, 흰 페이지 위에서 88% 불투명한 채움을 기준으로 검증합니다.
- **`accent`는 흰 배경에서 5:1 이상**입니다. 살짝 물든 `panel` 위에서도 4.5:1이 남도록 여유를 둔 값입니다.
- **채도는 sRGB gamut 상한의 90% 근처**입니다. 상한을 한참 밑돌면 같은 밝기에서도 회색에 가깝게 읽히고, 넘기면 브라우저가 clip합니다.

여기서 명도는 생각만큼 자유롭지 않습니다. `on-solid`가 흰 글자이고 채움이 88%라면, 4.5:1을 지킬 수 있는 채움 명도는 50% 안팎의 좁은 구간으로 묶입니다. **채움을 더 밝히려면 글자를 어둡게 바꾸는 수밖에 없고**, `warning`이 실제로 그렇게 하는 유일한 계열입니다.

## 색 바꾸기

다섯 개만 다시 선언하면 계열 전체가 따라옵니다. 다크 테마 값을 따로 주려면 `.dark`에도 같은 다섯 줄을 선언하세요.

```css
:root {
  --neba-primary-solid: oklch(50% 0.24 300);
  --neba-primary-solid-hover: oklch(45.5% 0.232 300);
  --neba-primary-solid-active: oklch(38% 0.204 300);
  --neba-primary-on-solid: oklch(99% 0.004 300);
  --neba-primary-accent: oklch(54% 0.26 300);
}
```

Neba의 다크 테마는 `prefers-color-scheme`을 따르고, `.dark` / `[data-theme='dark'|'light']`로 강제할 수 있습니다.

### 일부 트리에만 적용하려면 테마 루트로 만드세요

앱 전체가 아니라 특정 영역에만 다른 계열 색을 쓰고 싶다면, 그 요소가 **테마 루트여야** 합니다 — 즉 `.dark` / `.light` / `[data-theme='…']` 중 하나를 달아야 합니다.

```html
<!-- 동작하지 않습니다: 버튼 색이 그대로입니다 -->
<div style="--neba-primary-solid: oklch(50% 0.24 300)">…</div>

<!-- 동작합니다 -->
<div data-theme="light" style="--neba-primary-solid: oklch(50% 0.24 300)">…</div>
```

파생 블록이 선언된 곳이 테마 루트이기 때문입니다. 커스텀 프로퍼티는 선언된 요소에서 `var()`를 해석하므로, 평범한 `<div>`에 다섯 개를 얹으면 그 값 자체는 상속되지만 `--neba-primary-fill`은 여전히 `:root`가 **예전** `solid`로 계산해 둔 값입니다. 요소를 테마 루트로 만들면 파생 블록이 거기서 다시 계산됩니다.

아래 두 패널은 마크업이 완전히 같고, 오른쪽만 그렇게 감싼 것입니다.

<Demo src="color/override">

<<< @/.vitepress/demos/color/override.tsx

</Demo>

> **파생 토큰은 건드리지 마세요.** `--neba-primary-panel`처럼 파생된 토큰을 직접 덮어쓰면 그 하나만 바뀌고 나머지 열두 개는 원래 계열 색으로 남습니다. 항상 다섯 개의 기준값 쪽을 고치세요.

## 계열 추가하기

라이브러리에 새 계열을 넣는 것은 두 군데를 고치는 일입니다 — [`src/types.ts`](https://github.com/jooy2/neba/blob/main/src/types.ts)의 `NebaColor` 유니언과 `styles.css`의 다섯 줄(테마마다). 나머지는 파생 블록이 계산합니다.

소비자 쪽에서는 `NebaColor`가 닫힌 유니언이라 새 이름을 넘길 수 없습니다. 계열이 하나 더 필요하다면 이슈로 올려 주세요.

## 색이 아닌 토큰

계열과 무관한 중립 토큰도 같은 파일에 있습니다.

```css
--neba-surface        /* 페이지 배경 */
--neba-fg             /* 본문 글자색 */
--neba-muted-fg       /* 보조 글자색 */
--neba-border         /* 중립 경계선 */
--neba-disabled-bg    /* 비활성 컨트롤 — 계열 색을 버리고 중립 회색으로 */
--neba-disabled-fg
--neba-disabled-border
--neba-glass-bg       /* 염료 없는 아크릴 — 계열 panel이 섞여 들어가는 바탕 */
```

비활성 상태가 계열 색을 흐리는 대신 **버리는** 이유는 [디자인 언어](./design-language)에 있습니다. 흐린 강조색은 "이건 주요 액션입니다"를 흐릿하게 말할 뿐입니다.
