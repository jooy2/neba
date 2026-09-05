---
title: PageLayout
order: 1
---

# PageLayout

<p class="neba-lede">페이지의 뼈대를 잡는 컴포넌트입니다. header와 footer, 사이드바 하나 또는 둘, 그리고 그 사이의 내용을 배치하며 자기 표면은 그리지 않습니다.</p>

<Demo src="page-layout/hero" minHeight="420" />

```tsx
import { Footer, Header, PageLayout, Sidebar } from 'neba';

<PageLayout header={<Header />} sidebar={<Sidebar>탐색</Sidebar>} footer={<Footer />}>
  페이지
</PageLayout>;
```

## Props

<PropsTable name="PageLayout" />

`<div>`의 native 속성은 그대로 전달됩니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

children은 실제 `<main>` 안에 놓입니다. `mainId`가 그 요소의 id이며 skip link가 향하는 곳입니다.

거터나 최대 너비는 정하지 않습니다. 그것은 [Container](./container)의 일이고, 안에 넣어 두면 한 경로에서는 넓은 대시보드를, 다음 경로에서는 좁은 본문을 담을 수 있습니다.

## 예시

### headerSpan

header와 사이드바 중 어느 쪽이 위쪽 모서리를 차지하는지 정합니다. 기본값 `full`은 바가 전체 너비를 가로지르고 사이드바가 그 아래에서 시작하며, `content`는 사이드바가 창 높이를 다 쓰고 바가 그 사이에 놓입니다. `footerSpan`이 footer에 대해 같은 질문에 따로 답합니다.

<Demo src="page-layout/span" minHeight="380">

<<< @/.vitepress/demos/page-layout/span.tsx

</Demo>

### collapseBelow

이 너비보다 좁아지면 두 사이드바가 열이 아니라 drawer가 됩니다. [SidebarTrigger](./sidebar#sidebartrigger)가 그것을 여는 버튼이며, 정확히 같은 너비에서 나타납니다. `none`이면 어느 너비에서도 열로 남습니다.

<Demo src="page-layout/collapse" minHeight="360">

<<< @/.vitepress/demos/page-layout/collapse.tsx

</Demo>

### 사이드바 두 개

`sidebar`가 앞쪽 열, `endSidebar`가 뒤쪽 열입니다. 각각 자기 너비와 자기 drawer, 자기 trigger를 가진 [Sidebar](./sidebar)이며 `side`를 쓸 필요가 없습니다. 어느 자리에 넣었는지가 정해 줍니다. 둘 다에 `label`을 주세요. 그러지 않으면 스크린 리더가 “complementary”라는 영역 두 개를 내놓습니다.

<Demo src="page-layout/two-sidebars" minHeight="320">

<<< @/.vitepress/demos/page-layout/two-sidebars.tsx

</Demo>

### scroll

기본값 `page`는 문서 자체가 스크롤됩니다. 휴대폰에서 브라우저 주소창이 숨고, 뒤로 가기에서 스크롤 위치가 복원되며, [Header](./header)는 `position: sticky`로 자리를 지킵니다. `content`는 레이아웃을 창 높이에 고정하고 바 사이의 영역만 스크롤합니다.

```tsx
<PageLayout scroll="content" header={<Header />} sidebar={<Sidebar>파일</Sidebar>}>
  작업 공간
</PageLayout>
```

### height

`viewport`는 창 높이라, 내용이 짧아도 footer가 화면 아래에 붙습니다. `auto`는 부모의 높이로, 페이지가 아닌 레이아웃([Mockup](../surfaces/mockup) 화면 안의 앱 셸이나 미리보기)을 위한 값입니다. 숫자나 CSS 길이를 주면 그 값이 됩니다.

```tsx
<div className="h-96">
  <PageLayout height="auto" scroll="content" header={<Header />}>
    미리보기
  </PageLayout>
</div>
```

### drawer를 직접 다루기

`sidebarOpen`과 `onSidebarOpenChange`가 앞쪽 drawer를, `endSidebarOpen`과 `onEndSidebarOpenChange`가 뒤쪽 drawer를 controlled로 만듭니다. 경로가 바뀔 때 drawer를 닫아야 하는 경우에 씁니다.

```tsx
const [open, setOpen] = useState(false);

<PageLayout sidebarOpen={open} onSidebarOpenChange={setOpen} sidebar={<Sidebar>탐색</Sidebar>}>
  페이지
</PageLayout>;
```

## 접근성

- children은 `<main>`으로 감싸이고, header와 footer, 사이드바는 각각 `<header>`, `<footer>`, `<aside>`로 그려져 `banner`, `contentinfo`, `complementary` 랜드마크가 됩니다.
- “본문으로 건너뛰기” 링크가 문서 맨 앞에 놓이며 focus를 받을 때만 그려집니다. 페이지에 이미 같은 링크가 있을 때만 `skipLink={false}`로 끄세요.
- `locale`은 skip link와 레이아웃 안 모든 Sidebar·SidebarTrigger의 언어를 정합니다. 지원하지 않는 tag는 영어로 돌아가며, `skipLabel`로 문구를 직접 쓸 수도 있습니다.
- 사이드바가 둘인 페이지는 각각에 `label`을 반드시 주어야 합니다.
