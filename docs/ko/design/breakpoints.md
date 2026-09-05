---
title: Breakpoints
order: 4
---

# Breakpoints

너비 다섯 개, 그리고 값이 그 사이를 어떻게 옮겨 다니는지에 대한 규칙 하나. 라이브러리의 모든 반응형 prop이 이것을 같은 방식으로 읽고, stylesheet가 쓰는 모든 media query도 마찬가지입니다.

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

Tailwind의 기본값 그대로이며, 그것이 핵심입니다. Neba의 레이아웃과 `md:` utility가 같은 픽셀에서 바뀌므로, 맞춰 두어야 할 숫자 표를 하나 더 두지 않고도 한 페이지에서 둘을 섞어 쓸 수 있습니다.

다섯 이름은 `NebaSize`가 쓰는 다섯과 같고, 의도적으로 같은 개념이 아닙니다. `size`의 `md`는 컨트롤이 얼마나 큰지이고, breakpoint의 `md`는 창이 얼마나 넓은지입니다. 철자를 공유하는 이유는, 사다리 하나를 익힌 사람이 다른 하나를 위해 또 다른 단어 묶음을 익힐 필요가 없어야 하기 때문입니다.

## 모든 항목은 바닥입니다

반응형 prop은 값 하나 또는 부분 map을 받고, **각 항목은 자기 breakpoint부터 위로** 적용됩니다.

```tsx
<Grid span={{ xs: 12, md: 6 }} />
```

48rem까지는 전체 너비, 그 위로는 절반입니다 — map이 언급조차 하지 않은 `lg`와 `xl`에서도 그렇습니다. "이 너비에서만"을 뜻하는 값은 없으며, 그래서 항목 두 개면 대개의 레이아웃을 다 설명합니다.

규칙의 나머지 절반은, map이 prop을 **좁히는 것**이지 대체하는 것이 아니라는 점입니다. `spacing`에 `{ md: 4 }`를 주면 48rem 아래에서 문서에 적힌 기본값 `2`를 그대로 지키며, 아무것도 없는 상태로 떨어지지 않습니다. breakpoint 하나를 적었다고 나머지 전부에서 값이 조용히 사라지는 일은 없습니다. prop 두 개가 겹칠 때도 같습니다 — `columnSpacing`은 `spacing` 위에 덮이고, 처음 말한 지점부터 위로 이깁니다.

## 어떤 prop이 반응형이고, 나머지는 왜 아닌지

> 값이 inline custom property에 들어가면 반응형이 되고, 값이 class name이면 되지 않습니다.

Tailwind는 소스에 문자 그대로 적힌 class name만 봅니다. 그래서 breakpoint별 class map은 그 컴포넌트를 그리는 모든 페이지의 번들에 사다리 다섯 벌을 통째로 넣는 일이 됩니다. `--n-*` 슬롯은 inline 선언 하나와 stylesheet의 cascade 하나면 되고, 그 cascade는 페이지의 모든 인스턴스가 함께 씁니다.

| 반응형 | 반응형 아님 |
| --- | --- |
| [Grid](../components/layout/grid)의 `span`, `offset` | `size` |
| [GridContainer](../components/layout/grid)와 [Flex](../components/layout/flex)의 `columns`, `spacing`, `rowSpacing`, `columnSpacing` | `variant` |
| [Flex](../components/layout/flex)의 `direction` | `color` |
| [Container](../components/layout/container)·[Header](../components/layout/header)·[Footer](../components/layout/footer)의 `maxWidth` | `elevation` |

왼쪽 목록이 짧은 것은 의도된 것입니다. 슬롯 하나는 생성할 수 없는 media block 네 개이고, 그래서 하나를 더하는 일은 편의가 아니라 결정입니다.

## CSS에서 정할지, JavaScript에서 정할지

둘 다 있고, 서로 바꿔 쓸 수 있는 것이 아닙니다.

**[Show](../components/layout/show)**는 CSS에서 정합니다. children은 언제나 렌더되고 바뀌는 것은 `display`이므로, 브라우저가 그리는 첫 프레임부터 답이 맞고, 서버에서도 같은 답이 나오며, 크기가 바뀌면 React를 다시 렌더하는 대신 다시 그리기만 합니다.

```tsx
<Show above="md">
  <Sidebar />
</Show>
```

**`useBreakpoint`와 `useBreakpointValue`**는 JavaScript에서 정하고, CSS가 할 수 없는 한 가지를 할 수 있습니다 — 아예 렌더하지 않기. 서버에서도 클라이언트의 첫 렌더에서도 `false`와 `xs`를 답하므로, 이들이 제어하는 것은 hydration 이후에 도착합니다. 레이아웃이라면 그것은 깜빡임이고, 실행되면 안 되는 컴포넌트라면 그것이 옳습니다.

```tsx
const columns = useBreakpointValue({ xs: 1, md: 3 }) ?? 1;

return useBreakpoint('md') ? <Map /> : <StaticImage />;
```

`useBreakpointValue`는 map을 cascade와 정확히 같은 방식으로 읽습니다. 위의 바닥 규칙이 양쪽에서 같은 규칙이라는 뜻입니다.

## 너비 바꾸기

breakpoint는 **빌드 시점의** 결정입니다. `@media`는 custom property를 읽을 수 없으므로, provider prop이든 context든 런타임 설정으로는 breakpoint를 옮길 수 없습니다. 옮기는 것처럼 보이는 무엇이 있다면 그것은 JavaScript만 옮기고 CSS는 그대로 두는 것입니다.

대신 그 결정에 함께 참여할 수는 있습니다. 라이브러리의 media query는 `theme(--breakpoint-*)`로 적혀 있고, 이것은 stylesheet를 컴파일하는 그 Tailwind 빌드에서 풀립니다. 그래서 자신의 theme에서 다시 선언하면 전부가 한 번에 움직입니다 — 라이브러리 자신의 규칙, 컴포넌트들이 적어 둔 `md:` variant, 그리고 풀린 너비를 문서에서 다시 읽어 오는 JavaScript까지.

```css
@import 'tailwindcss';
@import 'neba/tailwind.css';

@theme {
  --breakpoint-md: 50rem;
}
```

이것은 Tailwind 경로에서만 됩니다. `neba/styles.css`를 쓰는 프로젝트는 여기서 컴파일된 stylesheet를 받으므로 다섯 너비가 이미 구워져 있습니다. 이름은 그대로 동작하지만 숫자는 위 표의 값입니다. 너비를 옮겨야 한다면 Tailwind를 돌리세요 — [시작하기](../guide/getting-started)에 두 설정이 모두 있습니다.

**이름**을 바꾸는 것은 어느 경로에서도 지원하지 않습니다. 다섯은 타입이 말하는 것이고, class 표들이 문자 그대로 적어 둔 것이며, stylesheet의 cascade들이 통과하며 푸는 것입니다.
