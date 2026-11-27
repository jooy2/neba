---
title: Breadcrumb
order: 14
flutter: true
---

# Breadcrumb

<p class="neba-lede">지금 보고 있는 페이지 위쪽의 경로입니다. 화면이 계층 안에 놓여 있고 읽는 사람이 다시 위로 올라갈 수 있어야 할 때 씁니다.</p>

<Demo src="breadcrumb/hero" />

::: fw react

```tsx
import { Breadcrumb, BreadcrumbItem } from 'neba';

<Breadcrumb>
  <BreadcrumbItem href="/">Home</BreadcrumbItem>
  <BreadcrumbItem href="/projects">Projects</BreadcrumbItem>
  <BreadcrumbItem>Settings</BreadcrumbItem>
</Breadcrumb>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaBreadcrumb(
  children: <NebaBreadcrumbItem>[
    NebaBreadcrumbItem(onPressed: openHome, href: Uri.parse('/'), child: const Text('Home')),
    NebaBreadcrumbItem(
      onPressed: openProjects,
      href: Uri.parse('/projects'),
      child: const Text('Projects'),
    ),
    const NebaBreadcrumbItem(child: Text('Settings')),
  ],
);
```

:::

## Props

### Breadcrumb

<PropsTable name="Breadcrumb" />

<Fw react="나머지 `<nav>` 속성은 그대로 전달됩니다." flutter="줄이 모자라면 단계가 다음 줄로 넘어갑니다." /> 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

### BreadcrumbItem

<PropsTable name="BreadcrumbItem" />

::: fw react

나머지 `<li>` 속성은 그대로 각 단계에 전달됩니다.

:::

::: fw flutter

패키지는 아무것도 직접 열지 않으므로 어딘가로 이동하는 단계도 콜백입니다. `onPressed`에서 router를 부르고, `href`는 screen reader와, 웹에서는 브라우저에 단계가 가는 곳을 알립니다. `onPressed` 없이 `href`만 있는 단계는 텍스트입니다. Enter는 모든 단계를 누르고, Space는 버튼인 단계만 누릅니다.

:::

## 예시

### separator

`separator`는 네 가지 이름(`chevron`·`arrow`·`slash`·`dot`) 중 하나이거나 <Fw react="아무 노드나" flutter="`NebaBreadcrumbSeparator.widget(…)`으로 아무 widget이나" /> 받습니다. 방향을 가리키는 둘은 RTL에서 반대로 돌아갑니다.

<Demo src="breadcrumb/separators">

::: fw react

<<< @/.vitepress/demos/breadcrumb/separators.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/separators.dart

:::

</Demo>

### maxItems

`maxItems`를 넘는 트레일은 가운데를 `…` 뒤로 접고, 그것을 누르면 다시 펼칩니다. 양 끝에 몇 개를 남길지는 `itemsBeforeCollapse`와 `itemsAfterCollapse`가 정하며 둘 다 기본값은 `1`입니다. <Fw react="`expandable={false}`는" flutter="`expandable: false`는" /> 접힘을 표시로만 남깁니다.

접기는 두 단계 이상을 걷어낼 때만 일어납니다.

<Demo src="breadcrumb/collapse">

::: fw react

<<< @/.vitepress/demos/breadcrumb/collapse.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/collapse.dart

:::

</Demo>

### keepMounted

::: fw react

기본적으로 접힌 단계는 DOM에 없으므로, 서버 렌더를 읽는 크롤러는 그 링크를 보지 못합니다. `keepMounted`를 주면 접힌 단계가 숨겨진 채 DOM에 남고, `…`를 누르면 이미 있던 자리에서 드러납니다. 전체 경로는 어느 쪽이든 `structuredData`가 설명하고, 이 prop은 링크 자체를 마크업에 넣습니다.

```tsx
<Breadcrumb maxItems={3} keepMounted>
  …
</Breadcrumb>
```

:::

::: fw flutter

Flutter의 트레일에는 크롤러가 읽을 서버 렌더가 없으므로 `keepMounted`도 없습니다. 접힌 단계는 `…`를 누르기 전까지 빌드되지 않습니다.

:::

### 현재 단계

마지막 단계는 지금 보고 있는 페이지이므로, <Fw react="`href`를 주더라도 링크가 되지 않습니다" flutter="`onPressed`를 주더라도 눌리지 않습니다" />. 앞쪽 단계에 `current`를 붙이면 그 표시가 옮겨 가고, 마지막 단계에서는 걷힙니다.

### <Fw react="target · rel" flutter="newTab" />

::: fw react

`target`은 단계의 링크가 열릴 곳을 정하며, 이 탭이 아닌 곳이면 `rel="noopener noreferrer"`가 붙습니다. `rel`도 링크에 그대로 쓰이므로 `nofollow`나 `sponsored`를 줄 수 있습니다. 새 탭에 필요한 두 토큰은 이 값을 덮어쓰지 않고 합쳐집니다.

```tsx
<BreadcrumbItem href="https://example.com/partners" target="_blank" rel="sponsored">
  Partners
</BreadcrumbItem>
```

:::

::: fw flutter

`newTab`은 단계의 링크가 앱 밖으로 나간다는 뜻이며, screen reader는 라벨 뒤에 "(새 창에서 열림)"을 트레일의 `locale`로 읽습니다. 탭을 여는 일은 앱이 쓰는 launcher를 거쳐 `onPressed`가 맡고, `rel`은 없습니다.

```dart
NebaBreadcrumbItem(
  onPressed: openPartners,
  href: Uri.parse('https://example.com/partners'),
  newTab: true,
  child: const Text('Partners'),
);
```

:::

### startIcon

<Demo src="breadcrumb/icons">

::: fw react

<<< @/.vitepress/demos/breadcrumb/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/icons.dart

:::

</Demo>

### render

::: fw react

`href`가 있는 단계는 `<a>`이므로 페이지를 다시 불러옵니다. 라우터의 `Link`를 `render`로 넘기면 다시 불러오지 않고 이동합니다. 단계에도 `href`를 그대로 두세요. `Link`로 전달되고, `structuredData`가 쓰는 주소도 이것입니다. 경로가 바뀌어도 마운트된 채 남는 트레일은 단계가 바뀌면 다시 접힙니다.

```tsx
<BreadcrumbItem href="/projects" render={<Link to="/projects" />}>
  Projects
</BreadcrumbItem>
```

:::

::: fw flutter

Flutter의 단계에는 바꿔 끼울 요소가 없습니다. router의 이동은 `onPressed`에 둡니다. 페이지가 바뀌어도 그 자리에 남는 트레일은 단계가 바뀌면 다시 접힙니다.

:::

### size

<Demo src="breadcrumb/sizes">

::: fw react

<<< @/.vitepress/demos/breadcrumb/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/sizes.dart

:::

</Demo>

### structuredData

::: fw react

`structuredData`를 켜면 검색엔진이 읽는 schema.org `BreadcrumbList`가 `<script type="application/ld+json">`으로 트레일 옆에 함께 나갑니다. 화면에는 아무것도 그리지 않습니다. `baseUrl`은 상대 `href`를 절대 URL로 만드는 기준입니다. 검색엔진은 절대 URL을 원합니다.

`maxItems`로 접힌 단계도 모두 들어갑니다. `href`가 없는 단계는 `item` 없이 나가는데, 마지막 단계가 대개 그렇습니다.

기본값은 꺼짐입니다. 앱의 SEO 레이어가 이미 그 페이지의 `BreadcrumbList`를 내보낸다면 꺼 두세요.

:::

::: fw flutter

`structuredData`와 `baseUrl`은 없습니다. Flutter 화면에는 검색엔진이 읽을 마크업이 없습니다.

:::

::: fw react

<Demo src="breadcrumb/structured-data">

<<< @/.vitepress/demos/breadcrumb/structured-data.tsx

</Demo>

:::

## 접근성

::: fw react

- 트레일은 `label`이 이름을 주는 `nav`이며(기본값 `Breadcrumb`), 그 안에 순서 있는 리스트가 들어갑니다.
- 현재 단계에는 `aria-current="page"`가 붙고, 한 트레일에서 이것을 가지는 단계는 언제나 하나뿐입니다.
- 구분자는 `aria-hidden`이므로 screen reader는 단계만 읽고 사이의 기호는 읽지 않습니다.
- `…`는 `expandLabel`이 이름을 주는 실제 버튼입니다. `expandable={false}`이면 표시일 뿐이며 reader에게는 감춰집니다.
- `keepMounted`로 DOM에 남은 접힌 단계는 숨겨져 있으므로, 트레일이 펼쳐지기 전까지 tab 순서에도 accessibility tree에도 없습니다.
- nav 이름과 `…` 버튼의 이름을 `locale`이 정합니다. `label`과 `expandLabel`로 직접 쓸 수도 있습니다.

:::

::: fw flutter

- 트레일은 `label`이 이름을 주는 내비게이션 영역이며(기본값 `Breadcrumb`), 그 안에 단계의 목록이 들어갑니다. 웹에서는 `role="navigation"`, `role="list"`, `role="listitem"`으로 읽힙니다.
- 현재 단계는 선택된 것으로 표시되며 웹에서는 `aria-current="true"`가 됩니다. 한 트레일에서 이렇게 표시되는 단계는 언제나 하나뿐입니다.
- 구분자는 semantics 트리에서 빠지므로 screen reader는 단계만 읽고 사이의 기호는 읽지 않습니다.
- `…`는 `expandLabel`이 이름을 주는 버튼입니다. 키보드로 누르면 숨겨 두었던 첫 단계로 focus를 넘깁니다. `expandable: false`이면 표시일 뿐이며 reader에게는 감춰집니다.
- 내비게이션 영역과 `…` 버튼의 이름을 `locale`이 정합니다. `label`과 `expandLabel`로 직접 쓸 수도 있습니다.

:::
