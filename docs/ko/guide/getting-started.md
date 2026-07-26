---
title: 시작하기
order: 1
---

# 시작하기

Neba는 React 컴포넌트 라이브러리입니다. 동작과 접근성은 [Base UI](https://base-ui.com) 프리미티브가, 스타일은 [Tailwind CSS](https://tailwindcss.com) v4가 담당합니다.

## 설치

```bash
npm install neba
```

`react`와 `react-dom`은 프로젝트에 이미 있어야 합니다.

## Tailwind 연결

Neba는 CSS 파일을 하나만 배포합니다. 앱의 CSS 진입점에 두 줄을 추가하세요.

```css
@import 'tailwindcss';
@import 'neba/styles.css';
```

| 줄 | 하는 일 |
| --- | --- |
| `@import 'tailwindcss'` | Tailwind 본체 |
| `@import 'neba/styles.css'` | 디자인 토큰(색·반경·입체·모션), `.neba-glow` 레이어, 그리고 패키지를 등록하는 `@source` |

이게 전부입니다 — `@source`를 직접 쓸 필요가 없습니다.

컴포넌트가 쓰는 클래스는 Tailwind 유틸리티이므로 Tailwind가 패키지의 컴파일된 파일을 읽기는 해야 합니다. 그 일은 `neba/styles.css`가 자기 안에 `@source '.'`를 선언해서 처리합니다. `@source`는 **그 줄이 쓰인 파일** 기준으로 경로를 해석하는데, 그 파일이 바로 대상 파일들 옆에 있는 `node_modules/neba/dist/`이기 때문입니다. 명시적으로 등록된 소스는 자동 탐지가 건너뛰는 `node_modules` 안에서도 스캔됩니다.

덕분에 **여러분의 CSS 파일이 어디에 있든 상관없습니다.** 예전 문서에서 `@source '../node_modules/neba'`를 보셨다면 지워도 됩니다 — 그 경로는 CSS 파일이 정확히 한 단계 깊이에 있을 때만 맞았습니다.

`neba/styles.css`는 그 외에는 순수 CSS 커스텀 프로퍼티라서, 토큰만 필요하면 Tailwind 없이 단독으로 import 해도 됩니다. `@source`는 브라우저가 무시하는 at-rule일 뿐입니다.

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
- [예제](../examples/) — 한 화면 안에서 함께 쓰인 모습
- [Prop 규약](./prop-conventions) — 모든 컴포넌트가 공유하는 prop의 의미

## 브라우저 요구사항

토큰은 `oklch()`, `color-mix()`, `backdrop-filter`를 사용합니다. 2023년 이후의 Chrome, Safari, Firefox에서 동작합니다. `backdrop-filter`가 없는 환경에서는 흐림 효과만 빠지고 나머지는 정상 동작합니다.
