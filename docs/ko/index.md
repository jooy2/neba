---
layout: home

title: Neba
titleTemplate: React 컴포넌트 라이브러리
description: 50여 개의 React 컴포넌트를 담은 UI 라이브러리. 접근성과 다크 모드, TypeScript 타입, 그리고 하나의 공용 prop 어휘가 설치 한 줄에 함께 들어옵니다.

hero:
  name: Neba
  text: 웹과 앱 어디에도 어울리는 React 컴포넌트 라이브러리
  tagline: 설치 한 줄로 시작하는 50여 개의 컴포넌트. 다크 모드도, 접근성도, 타입도 이미 들어 있습니다.
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
  - title: 50여 개의 컴포넌트
    details: 버튼과 입력부터 Dialog, Table, DatePicker, Toast까지. 화면 하나를 끝까지 만들 수 있는 만큼 들어 있습니다.
    link: /ko/components/
    linkText: 훑어보기
  - title: TypeScript 우선
    details: 타입 선언이 패키지에 함께 배포됩니다. prop 이름도, 받을 수 있는 값도 에디터가 먼저 알려 줍니다.
  - title: 다크 모드 기본
    details: 상위 요소의 class 하나면 모든 컴포넌트가 함께 넘어갑니다. 테마를 따로 만들 필요도, 색을 다시 지정할 일도 없습니다.
  - title: 하나의 공용 어휘
    details: size, color, variant, density, elevation. md는 어느 컴포넌트에서든 같은 것을 뜻합니다.
    link: /ko/design/prop-conventions
    linkText: Prop 규약
---

## Neba를 사용해야 하는 이유

<div class="neba-why">
  <div class="neba-why-card">
    <h3>검증된 안정성</h3>
    <p>모든 컴포넌트가 자기 테스트를 함께 가지고 갑니다. 실제 브라우저에서, 세 가지 OS와 세 가지 엔진 조합으로 변경마다 확인합니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>접근성이 기본값</h3>
    <p>role과 label, 키보드 조작, focus 관리가 컴포넌트 안에 들어 있습니다. 나중에 얹는 작업이 아닙니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>SEO에 유리한 마크업</h3>
    <p>시맨틱 태그로 렌더링되고 SSR에서도 같은 결과를 냅니다. 크롤러가 보는 것과 사용자가 보는 것이 같습니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>플랫폼을 가리지 않습니다</h3>
    <p>웹, 하이브리드 앱, Electron. 어떤 React 환경에서도 같은 코드가 같은 화면을 그립니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>모던한 프론트엔드에 맞춰</h3>
    <p>ESM으로 배포되고 tree shaking이 되므로, import한 것만 번들에 들어갑니다.</p>
  </div>
  <div class="neba-why-card">
    <h3>에이전틱 코딩에 적합</h3>
    <p>prop 이름이 컴포넌트마다 일관되고 문서가 구조적으로 정리되어 있어, AI 에이전트가 추측할 일이 적습니다.</p>
  </div>
</div>

## 컴포넌트 미리보기

아래는 문서 페이지 안에서 실제로 돌아가고 있는 컴포넌트입니다. 입력해 보고, 저장을 눌러 보세요.

<Demo src="showcase/app" />

컴포넌트별 prop과 예시는 [컴포넌트](./components/) 문서에, 같은 화면의 전체 설명은 [예제](./examples/overview)에 있습니다. 설치와 설정은 [시작하기](./guide/getting-started)에서 한 페이지로 끝납니다.
