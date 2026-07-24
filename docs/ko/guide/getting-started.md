---
title: 시작하기
order: 1
---

# 시작하기

Neba는 React 컴포넌트 라이브러리입니다. 동작과 접근성은 [Base UI](https://base-ui.com) 프리미티브가, 스타일은 [Tailwind CSS](https://tailwindcss.com) v4가 담당합니다.

> **주의** — 현재 1.0 이전이며 프로덕션 사용을 권장하지 않습니다.

## 설치

```bash
npm install neba
```

`react`와 `react-dom`은 프로젝트에 이미 있어야 합니다.

## Tailwind 연결

Neba는 CSS 파일을 하나만 배포합니다. 컴포넌트가 쓰는 클래스는 Tailwind 유틸리티이므로, **소비하는 앱의 Tailwind가 `node_modules/neba`를 스캔해야** 합니다.

앱의 CSS 진입점에 세 줄을 추가하세요.

```css
@import 'tailwindcss';
@import 'neba/styles.css';
@source '../node_modules/neba';
```

| 줄                               | 하는 일                                              |
| -------------------------------- | ---------------------------------------------------- |
| `@import 'tailwindcss'`          | Tailwind 본체                                        |
| `@import 'neba/styles.css'`      | 디자인 토큰(색·반경·입체·모션)과 `.neba-glow` 레이어 |
| `@source '../node_modules/neba'` | Neba가 쓰는 클래스 이름을 Tailwind가 찾도록          |

`@source` 경로는 CSS 파일 기준 상대 경로입니다. 이 줄이 없으면 컴포넌트가 스타일 없이 렌더링됩니다.

`neba/styles.css`는 Tailwind 지시자를 쓰지 않는 순수 CSS 커스텀 프로퍼티라서, 토큰만 필요한 경우 단독으로 import 해도 됩니다.

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

## 브라우저 요구사항

토큰은 `oklch()`, `color-mix()`, `backdrop-filter`를 사용합니다. 2023년 이후의 Chrome, Safari, Firefox에서 동작합니다. `backdrop-filter`가 없는 환경에서는 흐림 효과만 빠지고 나머지는 정상 동작합니다.
