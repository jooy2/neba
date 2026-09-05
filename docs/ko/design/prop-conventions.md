---
title: Prop 규약
order: 3
---

# Prop 규약

`size="md"`는 Button에서든 TextField에서든 Dialog에서든 같은 것을 뜻해야 합니다. 공용 어휘는 [`src/types.ts`](https://github.com/jooy2/neba/blob/main/src/types.ts)에 모여 있고, 각 컴포넌트는 필요한 것만 가져다 씁니다. **같은 개념에 다른 이름을 새로 만들지 마세요.**

## 공용 타입

```ts
type NebaSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
type NebaColor = 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info';
type NebaDensity = 'default' | 'compact';
type NebaVariant = 'solid' | 'outline' | 'text';
type NebaElevation = 0 | 1 | 2 | 3;
```

`NebaStyleProps`는 그중 대부분의 컴포넌트가 함께 쓰는 네 가지를 묶어 둔 것입니다.

```ts
interface NebaStyleProps {
  variant?: NebaVariant; // 기본 'solid'
  size?: NebaSize; // 기본 'md'
  color?: NebaColor; // 기본 'primary'
  density?: NebaDensity; // 기본 'default'
}
```

컴포넌트는 이렇게 확장합니다.

```ts
export interface ButtonProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'button'>, 'color'> {
  // 이 컴포넌트에만 있는 prop
}
```

`Omit<…, 'color'>`가 필요한 이유는 네이티브 `color` 속성과 이름이 겹치기 때문입니다.

## 각 축의 의미

| Prop | 규칙 |
| --- | --- |
| `variant` | 표면의 무게. `solid`는 화면당 하나(주 액션), `outline`은 보조 액션, `text`는 가장 낮은 무게 |
| `size` | 컨트롤의 높이와 타입 스케일. [디자인 언어](./design-language) 참고 |
| `color` | 의미론적 역할. 임의 색상값을 받지 않습니다 |
| `density` | **여백만** 바꿉니다. 높이도 글자 크기도 건드리지 않습니다 |
| `elevation` | 그림자 깊이. 기본 0(그림자 없음) |

레이아웃 prop 몇 개는 값 하나 대신 `span`에 주는 `{ xs: 12, md: 6 }` 같은 breakpoint별 map도 받습니다. 어떤 prop이 그렇고 위의 다섯 축이 왜 거기에 들지 않는지는 [breakpoints](./breakpoints)에 있습니다.

## 모션

어휘가 둘이고, 어느 쪽이 필요한지는 그 움직임에 trigger가 필요한지로 갈립니다.

`transition`은 mount 시 한 번 실행되는 등장 효과이며, 무언가를 **표시하는** 컴포넌트들이 받습니다. Box, Card, Statistic, Alert, Chip, Avatar, Icon, Typography, Blockquote입니다. 대부분은 효과 이름 하나면 충분하고, 객체 형태는 나머지를 위한 것입니다.

```ts
type NebaAnimation =
  'fade' | 'grow' | 'slide' | 'zoom' | 'rotate' | 'blink' | 'reveal' | 'float' | 'shake';
type NebaTransition = NebaAnimation | NebaTransitionOptions;
```

```tsx
<Card transition="fade" />
<Alert transition={{ type: 'slide', from: 'left', duration: 500, delay: 100 }} />
```

눌리는 컴포넌트에는 제공하지 않습니다. [디자인 언어](./design-language)가 포인터 아래에서 컨트롤이 움직이는 것을 금지하는데, Button의 `transition`이 정확히 그 동작이 되기 때문입니다.

[HowToSteps](../components/surfaces/how-to-steps)는 같은 prop을 받으면서 mount가 아닌 순간에 실행하는 유일한 컴포넌트이며, 움직이는 것은 새로 도착한 단계입니다. 효과는 패널 위에서 실행되고, 그것을 바꾼 버튼과 행은 그대로 있으므로 위 규칙에 어긋나지 않습니다. union에 `'none'`이 들어 있는 것도 이 컴포넌트뿐인데, 기본값이 "없음"이 아니라 효과인 유일한 경우이기 때문입니다.

다시 재생, 스크롤 trigger, hover, 직접 제어처럼 mount 이후의 움직임은 [`Animate*` 컴포넌트](../components/transitions/animate-fade)가 맡으며, 어떤 컴포넌트든 그것으로 감쌀 수 있습니다. 아래 설정은 전부 같은 뜻으로 공유합니다.

| Prop | 규칙 |
| --- | --- |
| `duration` / `delay` | 언제나 밀리초입니다. CSS 문자열이 아닙니다 |
| `easing` | CSS 이징 곡선. 기본값은 라이브러리의 곡선 |
| `repeat` | 횟수 또는 CSS가 쓰는 단어 그대로 `'infinite'` |
| `alternate` | 한 번 걸러 거꾸로 재생해, 반복이 처음으로 튀지 않고 되돌아옵니다 |
| `mode` | `'in'` 또는 `'out'`. `out`은 같은 애니메이션을 거꾸로 재생하고 끝에서 멈춥니다 |
| `trigger` | `'mount'`(기본값), `'visible'`, `'hover'`, `'manual'` |
| `play` | `manual`을 재생합니다. `false` → `true`마다 처음부터 다시 |
| `once` / `threshold` | `'visible'`용: 처음 한 번만인지, 얼마나 화면에 들어와야 하는지 |
| `paused` | 애니메이션을 있는 자리에 붙들어 둡니다 |

움직임이 요소 자신에게 걸린 `@keyframes` 하나인 아홉 개는 두 가지를 더 받습니다. AnimateAppear의 자체 stagger와 AnimateTyping, AnimateScramble, AnimateCounter, AnimateMarquee, AnimateHeadline, AnimateLighting은 움직임이 다른 곳에 쓰여 있어 해당되지 않습니다.

| Prop           | 규칙                                                                |
| -------------- | ------------------------------------------------------------------- |
| `stagger`      | 자식마다 지연에 더해지는 값(ms). `0`이면 상자 자체가 재생됩니다     |
| `durationStep` | 자식마다 재생 시간에 더해지는 값(ms). 음수면 뒤로 갈수록 빨라집니다 |
| `reverse`      | 마지막 자식부터 실행합니다. 순서만 뒤집힙니다                       |
| `timeline`     | `'time'`(기본) 또는 `'view'`. view는 시계 대신 스크롤이 재생합니다  |
| `range`        | `'view'` 타임라인이 매핑될 `animation-range`                        |

`timeline="view"`를 쓰면 `duration`, `delay`, `repeat`, 그리고 모든 `trigger`가 무시됩니다. 스크롤이 재생하는 애니메이션에는 시간이 들어 있지 않고, 시작시키는 것은 스크롤 위치이기 때문입니다. `animation-timeline`이 없는 브라우저에서는 mount에서 한 번 재생되는 것으로 되돌아갑니다.

라이브러리의 모든 효과는 축소된 모션 설정에서 통째로 꺼집니다. 어느 효과도 그것만으로 정보를 전달하지 않기 때문입니다.

## 상태 prop

| Prop       | 의미                                                         |
| ---------- | ------------------------------------------------------------ |
| `disabled` | 사용 불가. 네이티브 `disabled` 속성을 씁니다                 |
| `loading`  | 진행 중. 겉모습은 그대로, `aria-busy`, 포커스 유지           |
| `readOnly` | 존재하지만 여기서는 쓸 수 없음. `aria-disabled`, 포커스 유지 |

`loading`과 `readOnly`는 네이티브 `disabled`를 쓰지 않습니다. 포커스 순서에서 사라지면 키보드 사용자가 페이지 구조를 잃기 때문입니다. 활성화는 핸들러에서 막습니다.

## 스타일 덮어쓰기

세 가지 통로가 있고, 무엇을 바꾸려는지에 따라 고르면 됩니다.

### `className`: 루트

모든 컴포넌트가 받고, 컴포넌트 자신이 쓴 class를 **대체하지 않고 합칩니다**. 붙는 곳은 컴포넌트의 **루트**입니다. field라면 라벨과 control, 그 아래 두 줄을 담는 열이고, Dialog·Tour·CommandPalette라면 시트입니다.

```tsx
<Button className="w-full" />
```

[ToastProvider](../components/feedback/toast) 하나만 받지 않습니다. 자기 요소를 그리지 않으므로 루트 class가 붙을 곳이 없기 때문입니다.

### `classNames`: 그 뒤의 파트들

요소 하나를 그리는 컴포넌트에는 더 필요한 것이 없습니다. 라벨과 shell, control, 그리고 글 두 줄로 이루어진 field처럼 여러 요소를 그리는 컴포넌트에는, 눈에 보이지만 가리킬 이름이 없는 파트가 생깁니다. `classNames`가 그 파트마다 이름을 하나씩 줍니다.

```tsx
<TextField classNames={{ label: 'uppercase', control: 'font-mono' }} />
```

**`root` 키는 절대 없습니다.** 모든 컴포넌트에서 루트는 `className`이며, 같은 대상에 두 번째 이름을 붙이는 것이 이 문서가 막으려는 일입니다.

파트가 공유되는 곳에서는 slot 이름도 공유됩니다. `label`, `control`, `description`, `error`는 TextField·Select·Checkbox·RadioGroup에서 모두 같은 넷을 뜻합니다. 그 밖에 컴포넌트마다 더 있는 것은 각자의 페이지에 있습니다.

달리 닿을 방법이 없는 slot은 특히 알아 두세요. Select의 `popup`, Dialog의 `backdrop`, Tour의 `mask`, CommandPalette의 `viewport`는 모두 `className`이 닿는 요소 바깥, `<body>` 끝에 그려집니다. 루트를 기준으로 쓴 선택자로는 찾을 수 없습니다.

### `style`과 `--n-*` slot

컴포넌트가 그리는 색 값은 전부 자기 자신에게 설정한 custom property에서 읽어 옵니다. `--n-fill`, `--n-accent`, `--n-line`, `--n-ring`, `--n-panel`, `--n-elev` 등 백여 개입니다. 넘긴 `style`은 컴포넌트 자신의 것 **뒤에** 합쳐지므로, 이 방법으로 덮어쓴 값은 언제나 적용됩니다.

```tsx
<Button style={{ '--n-fill': 'rebeccapurple' }} />
```

inline custom property는 경쟁할 cascade가 없으므로, 색이나 깊이를 바꿀 때는 class보다 안정적입니다. 한 단계 위에는 `:root`의 `--neba-*` 토큰이 있어 같은 값을 페이지 전체에 적용합니다. [색](./color)을 참고하세요.

### utility 둘이 부딪힐 때

넘긴 class와 컴포넌트가 쓴 class는 둘 다 class 하나짜리 utility입니다. 어느 쪽도 더 구체적이지 않으므로 무엇이 적용될지는 **생성된 stylesheet 안의 순서**가 정하며, 그 순서는 작성한 순서가 아니라 Tailwind가 정한 순서입니다.

그래서 결과는 누가 썼는지가 아니라 어떤 값인지에 달립니다. `h-8`이 `h-10`보다 먼저 생성되므로 컴포넌트의 `h-10`이 적용됩니다. `rounded-full`이 `rounded-lg`보다 먼저이므로 컴포넌트의 `rounded-lg`가 적용됩니다. `bg-red-500`은 `bg-(--n-fill)` 뒤에 오므로 이때는 직접 쓴 값이 적용됩니다.

직접 쓴 값이 반드시 적용되어야 한다면 Tailwind의 important modifier를 쓰세요.

```tsx
<Button size="lg" className="h-8!" />
```

이 표기는 inline style보다도 우선합니다. utility로 표현할 수 없어 inline으로 쓴 값이 몇 개 있는데, [IconButton](../components/inputs/icon-button)의 `border-radius`가 그렇습니다.

### 두 개의 stylesheet

class로 덮어쓰는 것은 `neba/tailwind.css` 경로에서만 의미가 있습니다. 그 경로에서만 직접 쓴 class와 컴포넌트의 class가 한 번의 Tailwind pass에서 생성되어 서로 순서를 가릴 수 있기 때문입니다. `neba/styles.css`는 이미 완성된 CSS라 프로젝트의 빌드에 참여하지 않습니다. 그 경로에서는 직접 쓴 CSS나 위의 `--n-*` slot으로 덮어쓰세요. [시작하기](../guide/getting-started)를 보세요.

## 이름 규칙

- 아이콘 슬롯은 `startIcon` / `endIcon`. `leftIcon`/`rightIcon`은 RTL에서 뜻이 뒤집힙니다.
- 불리언은 긍정형. `disabled`(O), `notDisabled`(X).
- 너비를 채우는 것은 `fullWidth`.
- 이벤트 핸들러는 네이티브 이름 그대로 받아서 그대로 전달합니다.

## 새 컴포넌트 체크리스트

1. `src/components/{소문자-이름}/` 폴더, `{PascalCase}.tsx` + `index.ts` 배럴
2. named export만 사용 (`export default` 금지)
3. `src/index.ts`에서 배럴을 re-export
4. 동작·접근성은 Base UI 프리미티브에 위임
5. 공용 어휘에서 필요한 축을 가져오고, 없는 개념만 새로 정의
6. `test/components/{이름}/{Name}.test.tsx`: **같은 커밋에** 포함
7. `docs/{로케일}/components/{그룹}/{이름}.md` 작성: 제목 · lede · 미리보기 · Props · 예시 순서. **로케일마다** 한 장씩
8. `docs/.vitepress/data/props.ts`에 props 테이블(로케일별 설명), `docs/.vitepress/demos/{이름}/`에 예시 데모 추가
9. `docs/.vitepress/demos/catalog/all.tsx`(모든 컴포넌트)와 `showcase/app.tsx`(예제)에 한 자리씩
10. `npm run typecheck && npm test && npm run lint` 통과
