---
title: Button
order: 1
---

# Button

액션을 실행하는 버튼입니다. Base UI의 `Button` 프리미티브를 감쌉니다.

```tsx
import { Button } from 'neba';

<Button onClick={save}>저장</Button>;
```

## Props

`<button>`의 모든 네이티브 속성을 그대로 받습니다(`color` 제외 — 아래 표의 `color`와 이름이 겹칩니다).

| Prop        | 타입                                   | 기본값      | 설명                      |
| ----------- | -------------------------------------- | ----------- | ------------------------- |
| `variant`   | `'solid' \| 'outline' \| 'text'`       | `'solid'`   | 표면의 무게               |
| `size`      | `'xs' \| 'sm' \| 'md' \| 'lg' \| 'xl'` | `'md'`      | 높이와 타입 스케일        |
| `color`     | `NebaColor`                            | `'primary'` | 의미론적 색 역할          |
| `density`   | `'default' \| 'compact'`               | `'default'` | 좌우 여백                 |
| `elevation` | `0 \| 1 \| 2 \| 3`                     | `0`         | 그림자 깊이               |
| `startIcon` | `ReactNode`                            | —           | 라벨 앞 아이콘            |
| `endIcon`   | `ReactNode`                            | —           | 라벨 뒤 아이콘            |
| `loading`   | `boolean`                              | `false`     | 스피너 표시 + 활성화 차단 |
| `readOnly`  | `boolean`                              | `false`     | 비활성이되 흐려지지 않음  |
| `fullWidth` | `boolean`                              | `false`     | 컨테이너 너비만큼 확장    |
| `disabled`  | `boolean`                              | `false`     | 사용 불가                 |

## 변형

```tsx
<Button variant="solid">저장</Button>
<Button variant="outline">취소</Button>
<Button variant="text">자세히</Button>
```

화면당 `solid`는 하나로 유지하세요. 주 액션이 둘이면 어느 쪽도 주 액션이 아닙니다.

## 색

```tsx
<Button color="primary">저장</Button>
<Button color="danger">삭제</Button>
<Button color="warning">되돌리기</Button>
```

`primary` `secondary` `success` `warning` `danger` `info` 여섯 가지입니다. 임의의 색상값은 받지 않습니다 — 색은 역할이지 값이 아닙니다.

## 크기와 밀도

```tsx
<Button size="sm">작게</Button>
<Button size="xl">크게</Button>
<Button density="compact">촘촘하게</Button>
```

`density`는 좌우 여백만 바꿉니다. 같은 `size`라면 밀도가 달라도 높이가 같아서, 툴바처럼 섞어 쓰는 곳에서도 기준선이 맞습니다.

## 아이콘

```tsx
<Button startIcon={<PlusIcon />}>새 프로젝트</Button>
<Button endIcon={<ChevronIcon />}>계속</Button>
```

아이콘은 `1.2em`으로 그려져 라벨 크기를 따라갑니다. 별도 크기 지정이 필요 없습니다.

라벨 없이 아이콘만 주면 정사각형이 됩니다. 이때는 `aria-label`이 필요합니다.

```tsx
<Button aria-label="추가" startIcon={<PlusIcon />} />
```

## 상태

```tsx
<Button loading>저장 중</Button>
<Button disabled>저장</Button>
<Button readOnly>저장</Button>
```

**`loading`** — 스피너가 `startIcon` 자리를 대신합니다. 라벨 폭이 변하지 않도록 하기 위해서입니다. `aria-busy`가 붙고, 포커스는 유지된 채 활성화만 막힙니다.

**`disabled`** — 색 계열을 완전히 버리고 중립 회색이 됩니다. 네이티브 `disabled` 속성이 붙어 포커스 순서에서 빠집니다.

**`readOnly`** — 색은 유지한 채 평평해지고 채도가 빠집니다. "액션은 존재하지만 여기서는 쓸 수 없다"를 뜻합니다. 포커스는 유지됩니다.

세 상태 모두 클릭 이벤트가 부모로 전파되지 않습니다.

## Elevation

```tsx
<Button>기본 — 그림자 없음</Button>
<Button elevation={2}>떠 있는 버튼</Button>
```

기본값 0은 그림자가 전혀 없다는 뜻입니다. 표면을 배경에서 분리하는 것은 아크릴 가장자리입니다. 호버하면 한 단계 오르고 누르면 한 단계 내려갑니다.

## 폼

`type`은 그대로 전달됩니다.

```tsx
<form onSubmit={handleSubmit}>
  <Button type="submit">보내기</Button>
  <Button type="button" variant="text" onClick={reset}>
    초기화
  </Button>
</form>
```

## 접근성

- 항상 네이티브 `<button>`으로 렌더링됩니다.
- 아이콘 전용 버튼에는 `aria-label`을 주세요.
- 포커스 링은 `:focus-visible`에서만 나타나므로 마우스 클릭에는 표시되지 않습니다.
- `loading`/`readOnly`는 포커스를 유지합니다. 키보드 사용자가 페이지 구조를 잃지 않게 하기 위해서입니다.
- 모든 색 조합이 채움 위 글자 4.5:1을 만족합니다.
