---
title: NebaProvider
order: 3
---

# NebaProvider

<p class="neba-lede">아래의 모든 컴포넌트가 무엇에서 출발할지를 한곳에서 정합니다. 제품이 정한 prop 기본값, 사용자가 고른 색 스킴, 문서가 흐르는 방향을 함께 다룹니다. 선택 사항이며, 없어도 모든 컴포넌트가 동작합니다.</p>

```tsx
import { NebaProvider } from 'neba';

<NebaProvider defaults={{ size: 'sm', density: 'compact', locale: 'ko' }}>
  <App />
</NebaProvider>;
```

자기 element는 그리지 않습니다. 세 가지를 한곳에 둔 것은 셋 다 개별 컨트롤이 아니라 **애플리케이션**의 속성이기 때문입니다.

## defaults

`size`, `density`, `variant`, `locale`의 네 축입니다. 호출 지점마다 `size="sm"`을 반복해서 쓰지 않아도 됩니다.

<Demo src="provider/defaults">

<<< @/.vitepress/demos/provider/defaults.tsx

</Demo>

호출 지점이 여전히 이깁니다. 순서는 **호출자 → provider → 컴포넌트 자신의 기본값**이므로, `size="xs"` provider 안의 `<Button size="xl">`은 `xl`이고, `size` prop이 없는 컴포넌트는 손대지 않습니다.

### defaults가 받는 네 축

|  |  |
| --- | --- |
| `size` `density` `variant` `locale` | 옳은 값이 제품의 속성입니다. 조밀한 애플리케이션은 어디서나 조밀하고, 한국어 제품은 어디서나 한국어입니다. |
| `color` | **기본값으로 줄 수 없습니다.** 컴포넌트의 색 기본값이 의미를 나타내는 경우가 많습니다. [Alert](../components/feedback/alert)는 `info`, [Popconfirm](../components/feedback/popconfirm)은 `danger`이며, 전역으로 한 번 덮으면 이 뜻이 모두 바뀝니다. |
| `elevation` | **기본값으로 줄 수 없습니다.** [디자인 언어](../design/design-language)가 그림자를 표면마다 opt-in으로 정하고 있으며, 전역 그림자는 그 규칙과 어긋납니다. |

각 컴포넌트는 **자기가 실제로 선언한 축만** 채웁니다. 받지 않는 키까지 채우면 props spread를 타고 DOM 노드로 넘어가는데, `<input>`의 `size`는 실제로 존재하는 속성이라 필드 너비가 바뀌어 버립니다.

## 색 스킴

```tsx
<NebaProvider defaultColorScheme="system">
```

provider가 `<html>`에 `data-theme`과 `color-scheme`을 쓰고, `localStorage`에 선택을 기억하고, 상태를 `useColorScheme()`으로 넘깁니다.

`color-scheme`은 `data-theme`만큼 중요합니다. 스크롤바, 브라우저가 아직 직접 그리는 폼 컨트롤, 오버스크롤 뒤의 캔버스처럼 브라우저가 그리는 요소를 함께 넘기기 때문입니다. 자기 색만 바꾼 페이지는 어두운 화면 옆에 흰 스크롤바를 그대로 답니다.

<Demo src="provider/color-scheme">

<<< @/.vitepress/demos/provider/color-scheme.tsx

</Demo>

### useColorScheme

```tsx
const { colorScheme, resolvedColorScheme, setColorScheme, toggleColorScheme } = useColorScheme();
```

`colorScheme`은 **요청된 값**이며 `system`을 포함합니다. `resolvedColorScheme`은 그 값이 지금 무엇으로 풀리는지이며 절대 `system`이 아닙니다. 3단 스위치에는 이 구분이 필요합니다. `system`은 지금 어느 쪽으로 풀리는지가 아니라 자기 자리에 표시되어야 하기 때문입니다.

### 깜빡임

React는 문서가 한 번 그려진 다음에 실행되므로, 다크 모드를 기억한 페이지도 들어올 때 흰 화면이 한 번 번쩍입니다. 이것만은 provider가 대신 고칠 수 없어서 `colorSchemeScript()`를 따로 둡니다.

```tsx
<script dangerouslySetInnerHTML={{ __html: colorSchemeScript() }} />
```

`<head>`의 가장 위에 인라인하세요. provider와 같은 키를 읽고 같은 속성을 씁니다. 스니펫을 문서에 적어 두는 대신 함수로 둔 것은, 복사해 붙인 코드가 라이브러리와 함께 갱신되지 않기 때문입니다.

### storageKey

기본값은 `'neba-color-scheme'`입니다. 직접 정하거나, `false`로 두면 이번 방문에만 적용하고 잊습니다. 저장이 예외를 던지는 일은 없습니다. 쓰기를 거부하는 시크릿 창에서도 스킴은 적용되고, 기억만 안 될 뿐입니다.

## direction

```tsx
<NebaProvider direction="rtl">
```

`<html>`에 `dir`을 쓰고 트리를 Base UI의 `DirectionProvider`로 감쌉니다. Base UI primitive들이 키보드 처리와 위치 계산을 페이지와 함께 뒤집습니다.

주지 않으면 **손대지 않습니다.** 현지화된 애플리케이션은 대개 서버가 그린 HTML에서 이미 `dir`을 정하는데, 그 값과 충돌하지 않기 위해서입니다.

컴포넌트들은 물리 속성이 아니라 논리 속성(`margin-inline-start` 등)으로 지어져 있어 레이아웃은 알아서 따라갑니다. `dir`이 필요한 곳은 글리프가 돌아야 하는 몇 군데뿐입니다. 달력의 stepper, Breadcrumb의 구분자, Carousel의 화살표, TreeView의 펼침 표시가 그렇습니다.

## 중첩

provider는 중첩되고, 가장 가까운 것이 이깁니다. 스킴을 미리 보여 주는 설정 패널이나, 여유 있는 페이지 안의 조밀한 툴바는 그 subtree를 감싸는 두 번째 provider입니다.

색 스킴과 방향 두 가지는 **범위가 좁혀지지 않습니다.** `<html>`의 속성이기 때문입니다. 자기 subtree만 다시 칠하려는 중첩 provider는 `colorSchemeElement`로 대상 element를 지정하면 됩니다. 위 미리보기가 그렇게 동작하며, 그래서 이 prop은 element가 아니라 함수를 받습니다.
