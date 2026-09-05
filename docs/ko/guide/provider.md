---
title: NebaProvider
order: 3
---

# NebaProvider

<p class="neba-lede">아래의 모든 컴포넌트가 무엇에서 출발할지를 한곳에서 정합니다 — 제품이 정한 prop 값들, 사용자가 고른 색 스킴, 문서가 흐르는 방향. 선택 사항이고, 없어도 모든 컴포넌트가 동작합니다.</p>

```tsx
import { NebaProvider } from 'neba';

<NebaProvider defaults={{ size: 'sm', density: 'compact', locale: 'ko' }}>
  <App />
</NebaProvider>;
```

자기 element는 그리지 않습니다. 세 가지 일이 함께 있는 이유는, 셋 다 어떤 컨트롤이 아니라 **애플리케이션**의 속성이기 때문입니다.

## defaults

네 개의 축입니다 — `size` · `density` · `variant` · `locale`. 호출 지점 400곳에 `size="sm"`을 쓰는 일을 끝내려고 있는 것입니다.

<Demo src="provider/defaults">

<<< @/.vitepress/demos/provider/defaults.tsx

</Demo>

호출 지점이 여전히 이깁니다. 순서는 **호출자 → provider → 컴포넌트 자신의 기본값**이므로, `size="xs"` provider 안의 `<Button size="xl">`은 `xl`이고, `size` prop이 없는 컴포넌트는 손대지 않습니다.

### 왜 네 개뿐인가

|  |  |
| --- | --- |
| `size` `density` `variant` `locale` | 옳은 값이 제품의 속성입니다. 조밀한 애플리케이션은 어디서나 조밀하고, 한국어 제품은 어디서나 한국어입니다. |
| `color` | **기본값으로 못 줍니다.** 컴포넌트의 색 기본값은 의미인 경우가 많습니다 — [Alert](../components/feedback/alert)는 `info`, [Popconfirm](../components/feedback/popconfirm)은 `danger`, severity는 뜻을 지닙니다 — 하나의 전역 override가 그것들을 아무 말 없이 다른 뜻으로 칠해 버립니다. |
| `elevation` | **기본값으로 못 줍니다.** 그림자는 표면마다 opt-in이라고 [디자인 언어](../design/design-language)가 명시합니다. 애플리케이션 전역의 그림자는 이 라이브러리 전체가 반대하는 사출 플라스틱의 모습입니다. |

각 컴포넌트는 **자기가 실제로 선언한 축만** 채워집니다. 받지 않는 키는 props spread를 타고 DOM 노드로 흘러갔을 것이고, `<input>`의 `size`는 실제로 존재하는 속성이라 필드 너비를 조용히 바꿔 놓았을 것입니다.

## 색 스킴

```tsx
<NebaProvider defaultColorScheme="system">
```

provider가 `<html>`에 `data-theme`과 `color-scheme`을 쓰고, `localStorage`에 선택을 기억하고, 상태를 `useColorScheme()`으로 넘깁니다.

`color-scheme`은 속성만큼 중요합니다. 브라우저가 직접 그리는 요소, 즉 스크롤바와 아직 브라우저가 그리는 폼 컨트롤, 오버스크롤 뒤의 캔버스까지 함께 넘기는 것이 `color-scheme`입니다. 자기 색만 바꾸는 페이지는 어두운 화면 옆에 흰 스크롤바를 그대로 답니다.

<Demo src="provider/color-scheme">

<<< @/.vitepress/demos/provider/color-scheme.tsx

</Demo>

### useColorScheme

```tsx
const { colorScheme, resolvedColorScheme, setColorScheme, toggleColorScheme } = useColorScheme();
```

`colorScheme`은 **요청된 것**이고 `system`도 포함합니다. `resolvedColorScheme`은 그것이 지금 무엇으로 풀리는지이고 절대 `system`이 아닙니다. 3단 스위치가 필요로 하는 것이 이 구분입니다 — `system`은 지금 어느 쪽으로 풀리는지가 아니라 **자기 자리**로 보여야 합니다.

### 깜빡임

React는 문서가 한 번 그려진 다음에 돌기 때문에, 어두움을 기억한 페이지는 들어올 때 흰색으로 한 번 번쩍입니다. 그것만은 provider가 대신 고칠 수 없고, `colorSchemeScript()`가 그 해결책입니다.

```tsx
<script dangerouslySetInnerHTML={{ __html: colorSchemeScript() }} />
```

`<head>`의 가장 위에 인라인하세요. provider와 같은 키를 읽고 같은 속성을 씁니다. 이 페이지에 적어 두면 한 번 복사되고 다시는 갱신되지 않을 스니펫 대신 함수로 둔 이유가 그것입니다.

### storageKey

기본값은 `'neba-color-scheme'`입니다. 직접 정하거나, `false`로 두면 이번 방문에만 적용하고 잊습니다. 저장이 예외를 던지는 일은 없습니다 — 쓰기를 거부하는 시크릿 창에서도 스킴은 적용되고, 기억만 안 될 뿐입니다.

## direction

```tsx
<NebaProvider direction="rtl">
```

`<html>`에 `dir`을 쓰고 트리를 Base UI의 `DirectionProvider`로 감쌉니다. Base UI primitive들이 키보드 처리와 위치 계산을 페이지와 함께 뒤집습니다.

주지 않으면 **손대지 않습니다.** 서버가 그린 HTML에서 이미 `dir`을 직접 정하는 문서 — 현지화된 애플리케이션은 대개 그렇습니다 — 와 다투지 않기 위해서입니다.

컴포넌트들은 물리 속성이 아니라 논리 속성(`margin-inline-start` 등)으로 지어져 있어 레이아웃은 알아서 따라갑니다. `dir`이 필요한 것은 글리프가 돌아야 하는 몇 군데뿐입니다 — 달력의 stepper, Breadcrumb의 구분자, Carousel의 화살표, TreeView의 펼침 표시.

## 중첩

provider는 중첩되고, 가장 가까운 것이 이깁니다. 스킴을 미리 보여 주는 설정 패널이나, 여유 있는 페이지 안의 조밀한 툴바는 그 subtree를 감싸는 두 번째 provider입니다.

두 가지는 **범위가 좁혀지지 않습니다.** `<html>`의 속성이기 때문입니다 — 색 스킴과 방향. 자기 subtree만 다시 칠하고 싶은 중첩 provider는 `colorSchemeElement`를 자기 element로 겨눕니다. 위 미리보기가 하는 일이 정확히 그것이고, 그 prop이 element가 아니라 함수인 이유입니다.
