---
title: 시작하기
order: 1
---

# 시작하기

Neba는 React 컴포넌트 라이브러리입니다. 동작과 접근성은 [Base UI](https://base-ui.com) 프리미티브가, 스타일은 [Tailwind CSS](https://tailwindcss.com) v4가 담당합니다. Tailwind는 이 패키지를 빌드할 때만 쓰이므로 프로젝트에 따로 설치할 필요는 없습니다.

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

### 함께 들어 있는 reset

`neba/styles.css`에는 컴포넌트가 전제하는 전역 reset이 들어 있습니다. Tailwind의 Preflight를 컴포넌트에 실제로 필요한 만큼으로 줄인 것으로, `box-sizing`, 폼 요소의 폰트 상속, 리스트 마커 제거 같은 항목들입니다. 문단·제목·링크의 타이포그래피는 건드리지 않습니다.

모든 규칙은 `:where()`로 감싸 **명시도가 0**입니다. 따라서 직접 쓴 `p { margin: 1rem }` 같은 타입 선택자 하나가 import 순서와 무관하게 언제나 우선합니다. reset은 컴포넌트가 전제하는 최소한의 바탕일 뿐이며, 페이지 전체의 스타일을 정하지 않습니다.

### 이미 Tailwind를 쓰고 있다면

프로젝트에 Tailwind v4가 이미 있다면 컴파일된 쪽 대신 토큰 시트를 가져오세요. 유틸리티가 두 번 생성되지 않고, 컴포넌트에 넘긴 `className`이 컴포넌트 자신의 클래스와 같은 pass에서 생성되므로 둘이 서로 순서를 가릴 수 있습니다. 다만 그것만으로 넘긴 쪽이 우선하지는 않습니다. 같은 속성을 다투는 두 utility 중 무엇이 적용될지는 Tailwind가 정한 순서에 달려 있으므로, 넘긴 값이 반드시 적용되어야 하면 important modifier(`h-8!`)를 쓰세요. [prop 규약](../design/prop-conventions)을 보세요.

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

## Next.js와 React Server Components

**Neba의 모든 컴포넌트에는 `'use client'`가 붙어 있습니다.** Server Component에서 그대로 import해 쓸 수 있고, 따로 감싸는 wrapper도 `transpilePackages` 설정도 필요하지 않습니다.

```tsx
// app/page.tsx — Server Component
import { Button, Card } from 'neba';

export default function Page() {
  return (
    <Card>
      <Button>Save</Button>
    </Card>
  );
}
```

directive가 표시하는 것은 경계이지 페이지가 아닙니다. 위 페이지는 그대로 Server Component로 남고, 브라우저로 내려가는 것은 거기서 render한 컴포넌트뿐입니다.

그 경계에 걸리는 일반적인 규칙은 그대로 적용됩니다. **prop은 경계를 넘지만 함수는 넘지 못합니다.** Server Component 안에서 정의한 handler는 Neba 컴포넌트에 넘길 수 없습니다.

```tsx
// ✗ Event handlers cannot be passed to Client Component props
<Button onClick={() => save()}>Save</Button>
```

다른 컴포넌트를 쓸 때와 마찬가지로, 상호작용하는 부분은 `'use client'`로 시작하는 자신의 module에 두면 됩니다.

stylesheet는 root layout에서 한 번만 import합니다.

```tsx
// app/layout.tsx
import 'neba/styles.css';
```

의도적으로 client module이 **아닌** 것이 둘 있습니다. `neba` barrel과 `neba/locales`입니다. barrel은 re-export만 하므로 Server Component가 import하면 별도의 경계가 생기는 대신 뒤에 있는 컴포넌트에 그대로 닿고, `registerMessages`는 어디서든 호출할 수 있는 평범한 함수로 남습니다. 다만 컴포넌트는 render하는 시점에 등록된 언어를 읽고 그 render는 서버에서 한 번, 브라우저에서 한 번 일어나므로, 등록은 client graph에 속한 module에서 하십시오.

```tsx
// app/neba-locale.tsx
'use client';

import { registerMessages, ko } from 'neba/locales';

registerMessages('ko', ko);

export function NebaLocale({ children }: { children: React.ReactNode }) {
  return children;
}
```

이 컴포넌트로 `app/layout.tsx`에서 앱을 감싸면 됩니다.

### 그 밖의 환경

`'use client'`는 파일 맨 위에 있는 문자열입니다. Server Components를 구현하지 않는 bundler — Vite, webpack, Remix, Astro, Parcel, 순수 React — 는 이를 무시하므로, 위 내용이 그런 프로젝트에서의 동작을 바꾸지는 않습니다.

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
