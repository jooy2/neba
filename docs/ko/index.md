---
layout: home

title: Neba
titleTemplate: React 컴포넌트 라이브러리

hero:
  name: Neba
  text: 잘라낸 아크릴 한 장
  tagline: 동작과 접근성은 Base UI, 스타일은 Tailwind CSS v4. 컨트롤은 절대 움직이지 않고, 색과 깊이로만 답합니다.
  actions:
    - theme: brand
      text: 시작하기
      link: /ko/guide/getting-started
    - theme: alt
      text: 모든 컴포넌트
      link: /ko/components/
    - theme: alt
      text: 예제
      link: /ko/examples/
  image:
    src: /logo-32.png
    alt: Neba

features:
  - title: 모든 컴포넌트
    details: 배포된 컴포넌트를 한 페이지에서. 문서의 미리보기는 그림이 아니라 전부 실제로 동작하는 컴포넌트입니다.
    link: /ko/components/
    linkText: 훑어보기
  - title: 아크릴 표면
    details: 반투명한 채움, 흐려진 배경, 빛을 받는 하이라인 가장자리. 그림자는 기본값이 아니라 선택입니다.
    link: /ko/design/design-language
    linkText: 디자인 언어
  - title: 하나의 공용 어휘
    details: size, color, variant, density, elevation. md는 어느 컴포넌트에서든 같은 것을 뜻합니다.
    link: /ko/design/prop-conventions
    linkText: Prop 규약
  - title: ESM · 타입 포함
    details: 의존성은 @base-ui/react 하나. 번들러 없이 tsc로 컴파일해 폴더 구조 그대로 배포합니다.
---

## 설치

```bash
npm install neba
```

앱의 CSS 진입점에 두 줄을 더하면 끝입니다. `@source`는 패키지가 스스로 등록하므로 직접 쓸 필요가 없습니다.

```css
@import 'tailwindcss';
@import 'neba/styles.css';
```

```tsx
import { Button } from 'neba';

<Button onClick={save}>저장</Button>;
```

## 한 화면에서

아래는 문서 페이지 안에서 실제로 돌아가고 있는 컴포넌트입니다. 입력해 보고, 저장을 눌러 보세요.

<Demo src="showcase/app" />

컴포넌트별 prop과 예시는 [컴포넌트](./components/) 문서에, 같은 화면의 전체 설명은 [예제](./examples/)에 있습니다.
