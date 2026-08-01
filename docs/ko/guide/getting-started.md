---
title: 시작하기
order: 1
---

# 시작하기

Neba는 React 컴포넌트 라이브러리입니다. 동작과 접근성은 [Base UI](https://base-ui.com) 프리미티브가, 스타일은 [Tailwind CSS](https://tailwindcss.com) v4가 담당합니다. Tailwind는 이 패키지를 빌드할 때만 쓰이므로 여러분의 프로젝트에 설치할 필요는 없습니다.

## 설치

```bash
npm install neba
```

`react`와 `react-dom`은 peer dependency입니다 — **React 18 또는 19**. 프로젝트에 이미 있다면 그 사본을 그대로 쓰고, 없다면 npm 7 이상이 알아서 함께 설치합니다. 그 외의 의존성은 패키지가 직접 가져옵니다.

## 스타일시트 연결

CSS 진입점에 한 줄을 추가하면 끝입니다.

```css
@import 'neba/styles.css';
```

번들러가 CSS를 처리한다면 진입 모듈에서 그냥 import 해도 됩니다.

```ts
import 'neba/styles.css';
```

`neba/styles.css`는 **완성된 CSS**입니다 — 디자인 토큰(색·반경·입체·모션), `.neba-glow` 레이어, 컴포넌트가 쓰는 유틸리티 클래스의 실제 규칙, 그리고 최소한의 reset이 모두 들어 있습니다. 빌드 설정도, PostCSS 플러그인도, `@source`도 필요 없습니다.

### reset에 대해

`neba/styles.css`에는 컴포넌트가 전제하는 전역 reset이 들어 있습니다. Tailwind의 Preflight를 컴포넌트에 실제로 필요한 만큼으로 줄인 것으로, `box-sizing`, 폼 요소의 폰트 상속, 리스트 마커 제거 같은 항목들입니다. 문단·제목·링크의 타이포그래피는 건드리지 않습니다.

모든 규칙은 `:where()`로 감싸 **명시도가 0**입니다. 따라서 여러분이 쓴 `p { margin: 1rem }` 같은 한 개짜리 타입 선택자가 import 순서와 무관하게 언제나 이깁니다. reset은 컴포넌트 아래에 깔리는 바닥이지, 페이지에 대한 권리 주장이 아닙니다.

### 이미 Tailwind를 쓰고 있다면

프로젝트에 Tailwind v4가 이미 있다면 컴파일된 쪽 대신 토큰 시트를 가져오세요. 유틸리티가 두 번 생성되지 않고, 컴포넌트에 넘긴 `className`이 컴포넌트 자신의 클래스와 올바른 순서로 정렬됩니다.

```css
@import 'tailwindcss';
@import 'neba/tailwind.css';
```

| 줄 | 하는 일 |
| --- | --- |
| `@import 'tailwindcss'` | Tailwind 본체 |
| `@import 'neba/tailwind.css'` | 디자인 토큰, `.neba-glow` 레이어, 그리고 패키지를 등록하는 `@source` |

이 경로에서도 `@source`를 직접 쓸 필요는 없습니다. 컴포넌트가 쓰는 클래스는 Tailwind 유틸리티이므로 Tailwind가 패키지의 컴파일된 파일까지 읽어야 하는데, 그 일은 `neba/tailwind.css`가 자기 안에 `@source '.'`를 선언해서 처리합니다. `@source`는 **그 줄이 쓰인 파일**을 기준으로 경로를 해석하고, 그 파일이 대상 파일들과 같은 `node_modules/neba/dist/`에 있기 때문입니다. 명시적으로 등록된 소스는 자동 탐지가 건너뛰는 `node_modules` 안에서도 스캔됩니다.

덕분에 **CSS 파일을 프로젝트 어디에 두어도 됩니다.** 직접 쓴 `@source '../node_modules/neba'`가 남아 있다면 지우세요. 그 경로는 CSS 파일이 정확히 한 단계 깊이에 있을 때만 맞습니다.

이 경로에는 reset이 포함되지 않습니다. Tailwind의 Preflight가 이미 그 역할을 하기 때문입니다.

## 사용

```tsx
import { Button } from 'neba';

export default function App() {
  return <Button onClick={() => console.log('clicked')}>저장</Button>;
}
```

## 다크 모드

기본값은 `prefers-color-scheme`을 따릅니다. 강제로 고정하려면 아무 조상 요소에 클래스나 `data-theme`을 주면 됩니다.

```text
<html data-theme="dark">   <!-- 또는 --> <html class="dark">
```

라이트로 고정하려면 `data-theme="light"` 또는 `class="light"`을 씁니다. `.dark`는 Tailwind의 관례를 따르기 위해 함께 지원합니다.

## 다음으로

- [모든 컴포넌트](../components/) — 배포된 컴포넌트를 한 페이지에서
- [예제](../examples/overview) — 한 화면 안에서 함께 쓰인 모습
- [Prop 규약](../design/prop-conventions) — 모든 컴포넌트가 공유하는 prop의 의미
- [디자인 언어](../design/design-language) — 표면·색·모션이 왜 이렇게 생겼는지

## 브라우저 요구사항

토큰은 `oklch()`, `color-mix()`, `backdrop-filter`를 사용합니다. 2023년 이후의 Chrome, Safari, Firefox에서 동작합니다. `backdrop-filter`가 없는 환경에서는 흐림 효과만 빠지고 나머지는 정상 동작합니다.
