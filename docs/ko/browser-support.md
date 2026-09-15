---
title: 브라우저 지원
---

# 브라우저 지원

Neba는 Chrome과 Edge 111, Firefox 113, Safari 16.4 이상을 데스크톱과 모바일에서 모두 지원합니다. 네 브라우저 모두 2023년 3월에서 5월 사이에 나온 버전입니다. 이보다 오래된 브라우저는 지원하지 않습니다. `color-mix()`가 없으면 색이 대부분 그려지지 않고, 더 오래된 브라우저에서는 컴포넌트가 아예 동작하지 않습니다.

## 최소 버전

| 브라우저                    | 최소 버전 | 출시       |
| --------------------------- | --------- | ---------- |
| Chrome, Android용 Chrome    | 111       | 2023년 3월 |
| Edge                        | 111       | 2023년 3월 |
| Firefox, Android용 Firefox  | 113       | 2023년 5월 |
| macOS, iOS, iPadOS의 Safari | 16.4      | 2023년 3월 |

- Opera, Samsung Internet 같은 다른 Chromium 기반 브라우저는 Chromium 111로 만든 릴리스부터 지원합니다.
- iOS와 iPadOS에서 시스템 WebKit 엔진을 쓰는 브라우저는 Safari 행을 따르므로, 기준은 기기의 OS 버전입니다. iOS 15나 iPadOS 15보다 높게 업데이트할 수 없는 iPhone과 iPad는 지원 범위 밖입니다.
- Firefox ESR은 115부터 모든 릴리스가 지원 범위 안에 있습니다.

테스트는 Chromium, Firefox, WebKit의 현재 릴리스에서 돌리므로, 최소 버전을 브라우저에서 직접 테스트하지는 않습니다. 이 값은 다음 섹션의 기능과 Neba가 의존하는 패키지가 선언한 지원 범위에서 끌어냈고, 변경이 있을 때마다 CI가 stylesheet와 소스에서 쓰는 기능을 [MDN 호환성 데이터](https://github.com/mdn/browser-compat-data)와 대조합니다.

Neba가 그려지지 않는 브라우저를 위해 빌드가 transpile하는 일이 없도록 build target도 같은 범위로 맞추십시오. [Browserslist](https://browsersl.ist) query로는 다음과 같습니다.

```text
chrome >= 111, edge >= 111, firefox >= 113, safari >= 16.4, ios_saf >= 16.4
```

## 최소 버전을 정하는 요소

| 요구사항 | Chrome, Edge | Firefox | Safari | 여기에 기대는 것 |
| --- | --- | --- | --- | --- |
| [`color-mix()`](https://developer.mozilla.org/docs/Web/CSS/Reference/Values/color_value/color-mix) | 111 | 113 | 16.2 | 파생 색 토큰 전부: 채움, hover와 press 상태, 틴트, 선, focus ring |
| [`oklch()`](https://developer.mozilla.org/docs/Web/CSS/Reference/Values/color_value/oklch) | 111 | 113 | 15.4 | 파생 토큰을 섞는 재료인 팔레트 |
| [Base UI](https://base-ui.com/react/overview/about) 1.x | 111 | 113 | 16.4 | 인터랙티브 컴포넌트의 동작과 접근성 |
| [Tailwind CSS](https://tailwindcss.com/docs/compatibility) v4 | 111 | 128 | 16.4 | `neba/styles.css`에 컴파일해 넣은 utility class |

브라우저마다 그 열에서 가장 높은 숫자가 최소 버전이며, 예외가 하나 있습니다. Tailwind CSS는 `@property` 때문에 Firefox 128을 적어 두었지만, v4.1부터 fallback을 함께 내보내므로 Firefox 113~127에서도 같은 utility가 그려집니다. `neba/tailwind.css`를 직접 운영하는 Tailwind 빌드에 import한다면, 이 fallback이 빠지지 않도록 Tailwind CSS v4.1 이상을 쓰십시오.

### 더 낮출 수 없는 이유

한계는 `color-mix()`입니다. 색 계열 하나는 토큰 다섯 개이고, 나머지 색조는 모두 브라우저가 그 다섯을 섞어 만듭니다. 프로젝트가 토큰 하나만 덮어써도 모든 상태가 따라 바뀌는 것도 이 구조 때문입니다. `color-mix()`가 없는 브라우저는 비슷한 색으로 대신 그리지 않습니다. 토큰은 정의된 채로 남지만, 그 토큰을 `var()`로 읽는 속성은 computed-value 시점에 무효가 되어 `unset`처럼 동작합니다. 그래서 채움형 Button에 채움이 없고, hover나 press에도 색이 바뀌지 않습니다. 색을 빌드 시점에 미리 계산해 두면 그려지기는 하지만, 프로젝트가 덮어쓴 토큰은 모두 무시됩니다.

Base UI도 같은 범위를 선언합니다. Base UI는 마지막 메이저 버전을 낼 때 Baseline Widely Available로 표시된 기능을 모두 구현한 브라우저를 지원하고, [Browserslist 파일](https://github.com/mui/base-ui/blob/master/.browserslistrc)에 그 범위를 Chrome과 Edge 111, Firefox 113, Safari 16.4로 적어 두었습니다. 최소 버전을 더 낮추면 인터랙티브 컴포넌트가 자신의 primitive가 지원하지 않는 브라우저에서 돌게 됩니다.

transpile이나 polyfill을 써도 이 한계는 그대로입니다. 한계를 정하는 것은 JavaScript가 아닙니다. Neba와 Base UI의 코드가 지원 여부를 먼저 확인하지 않고 쓰는 기능은 `inert` attribute까지 포함해 모두 Chrome 102, Firefox 112, Safari 16에 들어 있습니다. 이 기준은 transpiler와 polyfill로 낮출 수 있지만, 브라우저에 `color-mix()`를 더할 방법은 없습니다.

## 지원 범위 안에서 달라지는 점

범위 안의 모든 브라우저에서 모든 컴포넌트가 그려지고 동작합니다. 다만 몇 가지 세부 표현은 더 새로운 기능을 쓰고, 그 기능이 없는 브라우저에서는 그 표현만 빠집니다.

| 세부 표현 | 필요한 기능 | 범위 안의 이전 브라우저에서 |
| --- | --- | --- |
| [TextField](./components/inputs/text-field), [Select](./components/inputs/select), [Combobox](./components/inputs/combobox), [NumberField](./components/inputs/number-field), 날짜와 시간 picker, [Rating](./components/inputs/rating), 선택할 수 있는 [DataTable](./components/display/data-table)의 2px focus ring | [`:has()`](https://developer.mozilla.org/docs/Web/CSS/Reference/Selectors/:has): Firefox 121 | 필드는 ring 없이 테두리나 채움으로 focus를 보여 주고, DataTable은 활성 행으로 보여 줍니다. Rating은 ring을 그대로 그리지만, 키보드로 옮긴 별뿐 아니라 클릭한 별에도 그립니다 |
| [Checkbox](./components/inputs/checkbox), [RadioGroup](./components/inputs/radio-group), [Switch](./components/inputs/switch), [Alert](./components/feedback/alert)처럼 label이 붙은 행에서 label 옆에 놓인 상자나 아이콘 | `lh` 단위: Firefox 120 | label 첫 줄의 가운데가 아니라 위쪽에 맞춰집니다 |
| [AnimateSplit](./components/transitions/animate-split), [AnimateTyping](./components/transitions/animate-typing), [AnimateScramble](./components/transitions/animate-scramble)이 텍스트를 글자와 단어로 나누는 방식 | [`Intl.Segmenter`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Intl/Segmenter): Firefox 125 | code point와 공백을 기준으로 나눕니다. code point 여러 개로 이루어진 이모지는 조각으로 나뉘어 나타나고, 띄어쓰기 없이 쓰는 언어의 문장은 한 단어로 취급됩니다 |
| [AnimateLighting](./components/transitions/animate-lighting)의 움직이는 빛 | [`@property`](https://developer.mozilla.org/docs/Web/CSS/Reference/At-rules/@property): Firefox 128 | 빛이 한 자리에 머뭅니다 |
| [Calendar](./components/inputs/calendar)와 날짜 picker에서 한 주가 시작하는 요일 | [`Intl.Locale`의 주 정보](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Intl/Locale/getWeekInfo): Firefox 153 | `weekStartsOn`을 지정하지 않으면 일요일에 시작합니다 |
| RTL 레이아웃에서 [ScrollArea](./components/layout/scroll-area)와 [Tabs](./components/surfaces/tabs)의 가장자리 fade | [`:dir()`](https://developer.mozilla.org/docs/Web/CSS/Reference/Selectors/:dir): Chrome과 Edge 120 | 왼쪽과 오른쪽 fade가 서로 바뀌지 않습니다 |
| [AnimateFade](./components/transitions/animate-fade) 같은 Animate 컴포넌트의 `timeline="view"` | [`animation-timeline`](https://developer.mozilla.org/docs/Web/CSS/Reference/Properties/animation-timeline): Chrome과 Edge 115, Safari 26, Firefox는 아직 미지원 | scroll을 따라가지 않고 mount될 때 한 번 재생됩니다 |
