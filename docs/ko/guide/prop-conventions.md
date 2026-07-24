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

`NebaStyleProps`는 이 중 대부분의 컴포넌트가 공유하는 네 가지를 묶은 것입니다.

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

| Prop        | 규칙                                                                        |
| ----------- | --------------------------------------------------------------------------- |
| `variant`   | 표면의 무게. `solid`는 화면당 하나(주 액션), `outline`은 보조, `text`는 3차 |
| `size`      | 컨트롤의 높이와 타입 스케일. [디자인 언어](./design-language) 참고          |
| `color`     | 의미론적 역할. 임의 색상값을 받지 않습니다                                  |
| `density`   | **여백만** 바꿉니다. 높이도 글자 크기도 건드리지 않습니다                   |
| `elevation` | 그림자 깊이. 기본 0(그림자 없음)                                            |

## 상태 prop

| Prop       | 의미                                                         |
| ---------- | ------------------------------------------------------------ |
| `disabled` | 사용 불가. 네이티브 `disabled` 속성을 씁니다                 |
| `loading`  | 진행 중. 겉모습은 그대로, `aria-busy`, 포커스 유지           |
| `readOnly` | 존재하지만 여기서는 쓸 수 없음. `aria-disabled`, 포커스 유지 |

`loading`과 `readOnly`는 네이티브 `disabled`를 쓰지 않습니다. 포커스 순서에서 사라지면 키보드 사용자가 페이지 구조를 잃기 때문입니다. 활성화는 핸들러에서 막습니다.

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
6. `test/components/{이름}/{Name}.test.tsx` — **같은 커밋에** 포함
7. `examples/src/App.tsx`에 추가
8. `docs/ko/components/{이름}.md` 작성
9. `npm run typecheck && npm test && npm run lint` 통과
