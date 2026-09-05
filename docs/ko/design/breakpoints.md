---
title: Breakpoints
order: 4
---

# Breakpoints

너비는 다섯 개이고, 값이 그 사이를 어떻게 옮겨 가는지 정하는 규칙이 하나 있습니다. 라이브러리의 모든 반응형 prop이 이 다섯을 같은 방식으로 읽으며, stylesheet가 쓰는 media query도 마찬가지입니다.

## 사다리

```ts
type NebaBreakpoint = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
```

| 이름 | 바닥    | 대개 무엇인지                    |
| ---- | ------- | -------------------------------- |
| `xs` | `0rem`  | 폰. media query가 감싸지 않는 값 |
| `sm` | `40rem` | 큰 폰, 또는 가로로 돌린 폰       |
| `md` | `48rem` | 태블릿                           |
| `lg` | `64rem` | 노트북                           |
| `xl` | `80rem` | 데스크톱                         |

Tailwind의 기본값을 그대로 씁니다. 그래서 Neba의 레이아웃과 `md:` utility가 같은 픽셀에서 바뀌고, 맞춰 두어야 할 숫자 표를 하나 더 두지 않고도 한 페이지에서 둘을 섞어 쓸 수 있습니다.

다섯 이름은 `NebaSize`가 쓰는 다섯과 철자가 같지만 뜻은 다릅니다. `size`의 `md`는 컨트롤이 얼마나 큰지이고, breakpoint의 `md`는 창이 얼마나 넓은지입니다. 철자를 맞춘 것은 사다리 하나를 익힌 사람이 다른 하나를 위해 새 단어를 또 익히지 않도록 하기 위해서입니다.

## 모든 항목은 바닥입니다

반응형 prop은 값 하나 또는 부분 map을 받고, **각 항목은 자기 breakpoint부터 위로** 적용됩니다.

```tsx
<Grid span={{ xs: 12, md: 6 }} />
```

48rem까지는 전체 너비이고 그 위로는 절반이며, map이 언급하지 않은 `lg`와 `xl`에서도 절반입니다. "이 너비에서만"을 뜻하는 값은 없습니다. 그래서 항목 두 개면 대개의 레이아웃을 다 설명할 수 있습니다.

규칙의 나머지 절반은 map이 prop을 **좁힐 뿐 대체하지는 않는다**는 것입니다. `spacing`에 `{ md: 4 }`를 주면 48rem 아래에서는 문서에 적힌 기본값 `2`를 그대로 씁니다. breakpoint 하나를 적었다고 나머지 너비에서 값이 사라지지 않습니다. prop 두 개가 겹칠 때도 같아서, `columnSpacing`은 `spacing` 위에 덮이며 자기가 처음 지정한 breakpoint부터 위로 적용됩니다.

## 반응형 prop과 그렇지 않은 prop

> 값이 inline custom property에 들어가면 반응형이 되고, 값이 class name이면 되지 않습니다.

Tailwind는 소스에 문자 그대로 적힌 class name만 봅니다. 그래서 breakpoint별 class map은 그 컴포넌트를 그리는 모든 페이지의 번들에 사다리 다섯 벌을 통째로 넣는 일이 됩니다. `--n-*` 슬롯은 inline 선언 하나와 stylesheet의 cascade 하나면 되고, 그 cascade는 페이지의 모든 인스턴스가 함께 씁니다.

| 반응형 | 반응형 아님 |
| --- | --- |
| [Grid](../components/layout/grid)의 `span`, `offset` | `size` |
| [GridContainer](../components/layout/grid)와 [Flex](../components/layout/flex)의 `columns`, `spacing`, `rowSpacing`, `columnSpacing` | `variant` |
| [Flex](../components/layout/flex)의 `direction` | `color` |
| [Container](../components/layout/container)·[Header](../components/layout/header)·[Footer](../components/layout/footer)의 `maxWidth` | `elevation` |

왼쪽 목록이 짧은 것은 의도한 것입니다. 슬롯 하나마다 손으로 쓴 media block이 네 개 필요하고, 그 네 개는 모든 페이지가 함께 내려받습니다. 그래서 축을 하나 더하는 일은 가볍게 정하지 않습니다.

## CSS에서 정할지, JavaScript에서 정할지

둘 다 있고, 서로 바꿔 쓸 수 있는 것이 아닙니다.

**[Show](../components/layout/show)**는 CSS에서 정합니다. children은 언제나 렌더되고 바뀌는 것은 `display`이므로, 브라우저가 그리는 첫 프레임부터 답이 맞고, 서버에서도 같은 답이 나오며, 크기가 바뀌면 React를 다시 렌더하는 대신 다시 그리기만 합니다.

```tsx
<Show above="md">
  <Sidebar />
</Show>
```

**`useBreakpoint`와 `useBreakpointValue`**는 JavaScript에서 정하고, CSS가 할 수 없는 한 가지를 할 수 있습니다 — 아예 렌더하지 않기. 서버에서도 클라이언트의 첫 렌더에서도 `false`와 `xs`를 답하므로, 이들이 제어하는 것은 hydration 이후에 도착합니다. 레이아웃을 이 값으로 정하면 화면이 한 번 깜빡이지만, 애초에 실행되면 안 되는 컴포넌트를 거르는 용도라면 이 동작이 맞습니다.

```tsx
const columns = useBreakpointValue({ xs: 1, md: 3 }) ?? 1;

return useBreakpoint('md') ? <Map /> : <StaticImage />;
```

`useBreakpointValue`는 map을 cascade와 같은 방식으로 읽습니다. 위의 바닥 규칙이 CSS와 JavaScript 양쪽에서 똑같이 적용됩니다.

## 너비 바꾸기

breakpoint는 **빌드 시점의** 결정입니다. `@media`는 custom property를 읽을 수 없으므로, provider prop이든 context든 런타임 설정으로는 breakpoint를 옮길 수 없습니다. 옮기는 것처럼 보이는 무엇이 있다면 그것은 JavaScript만 옮기고 CSS는 그대로 두는 것입니다.

대신 그 결정에 함께 참여할 수는 있습니다. 라이브러리의 media query는 `theme(--breakpoint-*)`로 적혀 있고, 이 값은 stylesheet를 컴파일하는 Tailwind 빌드에서 정해집니다. 그래서 프로젝트의 theme에서 다시 선언하면 세 가지가 한 번에 따라옵니다. 라이브러리 자신의 규칙, 컴포넌트가 적어 둔 `md:` variant, 그리고 그 너비를 문서에서 다시 읽어 오는 JavaScript입니다.

```css
@import 'tailwindcss';
@import 'neba/tailwind.css';

@theme {
  --breakpoint-md: 50rem;
}
```

이 방법은 Tailwind 경로에서만 동작합니다. `neba/styles.css`를 쓰는 프로젝트는 이미 컴파일된 stylesheet를 받으므로 다섯 너비가 고정되어 있습니다. 이름은 그대로 쓸 수 있지만 숫자는 위 표의 값입니다. 너비를 옮겨야 한다면 Tailwind를 직접 돌리세요. [시작하기](../guide/getting-started)에 두 설정이 모두 있습니다.

**이름**을 바꾸는 것은 어느 경로에서도 지원하지 않습니다. 다섯 이름은 타입에 적혀 있고, class 표에 문자 그대로 들어가 있으며, stylesheet의 cascade가 그 이름으로 값을 찾기 때문입니다.
