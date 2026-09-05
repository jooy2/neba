---
layout: home

title: Neba
titleTemplate: React 컴포넌트 라이브러리
description: 서로 어울리는 React 컴포넌트 130여 개. 접근성과 다크 모드, 타입까지 설치 한 번과 CSS 한 줄로 갖춥니다.

hero:
  name: Neba
  text: React 화면에 필요한 것이 전부 들어 있습니다
  tagline: 생김새와 동작이 이미 맞춰진 컴포넌트 130여 개. 설치 한 번, CSS 한 줄이면 되고 테마를 따로 짤 필요가 없습니다.
  actions:
    - theme: brand
      text: 시작하기
      link: /ko/guide/getting-started
    - theme: alt
      text: 모든 컴포넌트
      link: /ko/components/
    - theme: alt
      text: 예제
      link: /ko/examples/overview
  image:
    src: /logo-32.png
    alt: Neba

features:
  - title: 컴포넌트 130여 개
    details: 버튼과 입력부터 Dialog, Table, DatePicker, Toast와 차트까지. 화면 하나를 끝까지 만들 수 있습니다.
    link: /ko/components/
    linkText: 훑어보기
  - title: TypeScript 우선
    details: 타입 선언이 패키지에 함께 들어 있어, 에디터가 prop 이름과 받을 수 있는 값을 먼저 알려 줍니다.
  - title: 다크 모드 기본
    details: 상위 요소에 class 하나면 라이브러리 전체가 따라옵니다. 색을 다시 지정할 일이 없습니다.
  - title: 하나의 공용 어휘
    details: size, color, variant, density, elevation. md는 어느 컴포넌트에서든 같은 md입니다.
    link: /ko/design/prop-conventions
    linkText: Prop 규약
---

## Neba를 쓰는 이유

<div class="neba-why">
  <div class="neba-why-card">
    <h3>실제 브라우저에서 검증</h3>
    <p>모든 컴포넌트에 테스트가 함께 들어 있고, 변경마다 세 가지 OS와 세 가지 엔진에서 실행합니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>접근성이 기본값</h3>
    <p>role과 label, 키보드 조작, focus 관리가 컴포넌트 안에 들어 있습니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>크롤러가 읽는 마크업</h3>
    <p>시맨틱 태그로 그려지고 서버에서도 같은 결과를 냅니다. 크롤러가 보는 것과 독자가 보는 것이 같습니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>React가 도는 곳이면 어디서나</h3>
    <p>웹, 하이브리드 앱, Electron. 같은 코드가 같은 화면을 그립니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>import한 것만 번들에</h3>
    <p>ESM으로 배포되고 tree shaking이 되므로, 다섯 개를 쓰는 페이지는 다섯 개만 싣습니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>에이전틱 코딩에 적합</h3>
    <p>prop 이름이 일관되고 컴포넌트마다 같은 형식의 문서가 있어, AI 에이전트가 추측할 일이 적습니다.</p>
  </div>
</div>

## 직접 만져 보기

스크린샷이 아닙니다. 입력해 보고, 저장을 눌러 보세요.

<Demo src="showcase/app" />

[시작하기](./guide/getting-started)에서 설치가 한 페이지로 끝납니다. 컴포넌트별 prop과 예시는 [컴포넌트](./components/)에, 위 화면의 블록별 설명은 [예제](./examples/overview)에 있습니다.
