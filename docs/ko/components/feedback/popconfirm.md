---
title: Popconfirm
order: 12
---

# Popconfirm

<p class="neba-lede">그 질문을 띄운 컨트롤 옆에서 묻습니다. Confirm의 작은 형제로, 결과가 페이지 전체가 아니라 그 줄에 머무는 행동을 위한 것입니다.</p>

<Demo src="popconfirm/hero" />

```tsx
import { IconButton, Popconfirm } from 'neba';

<Popconfirm
  title="이 도메인을 제거할까요?"
  description="즉시 응답을 멈춥니다."
  onConfirm={() => remove(id)}
  trigger={<IconButton label="제거" icon={<TrashIcon />} />}
/>;
```

## Props

<PropsTable name="Popconfirm" />

### 어느 쪽을 쓸까

[Confirm](./confirm)과의 차이는 위험도나 크기가 아니라 **범위**입니다.

|                                         | 쓸 것                |
| --------------------------------------- | -------------------- |
| 결과가 이 줄, 이 파일, 이 태그에 머문다 | Popconfirm           |
| 결과가 화면에 보이는 것 너머까지 미친다 | [Confirm](./confirm) |

Popconfirm은 자기를 띄운 것에 붙어 있으므로 독자가 지우려는 대상을 계속 볼 수 있습니다. 작은 행동에 모달이 무겁게 느껴지는 이유의 대부분이 바로 그 맥락을 잃는 것입니다. Confirm은 페이지를 가져가는데, 일어날 일이 그 페이지보다 클 때 그것이 맞습니다.

## 예시

### onConfirm과 비동기 작업

버블은 클릭할 때가 아니라 `onConfirm`이 **settle될 때** 닫힙니다. promise를 반환하면 작업이 끝날 때까지 확인 버튼이 busy 상태로 남은 채 버블이 떠 있습니다.

```tsx
<Popconfirm title="키를 폐기할까요?" onConfirm={() => api.revoke(id)} trigger={…} />
```

답이 도착하기도 전에 사라진 질문은, 독자가 그 답이 전달됐는지 알 방법이 없는 질문입니다.

### onCancel과 dismiss

`onCancel`은 취소 버튼에서만 호출되고 `Escape`나 바깥 클릭에서는 호출되지 **않습니다**. 질문에서 그냥 물러나는 것과 아니오라고 답하는 것은 다른 행동이고, `onCancel`에서 무언가를 되돌리는 호출자가 `Escape`를 누를 때마다 그것을 되돌려서는 안 됩니다.

### color와 icon

`color`의 기본값은 `danger`입니다. Popconfirm은 보통 그런 용도이기 때문입니다. `icon`은 그 계열의 severity 마크를 질문 옆에 그립니다.

이 마크는 기본으로 켜져 있고 장식이 아닙니다. "이것은 파괴적입니다"를 빨간색으로만 말하는 질문은 일부 독자에게만 말하는 것이므로, 모양이 의미를 함께 지녀야 합니다. 직접 만든 노드를 넘기거나 `false`로 끌 수 있습니다.

### side와 align

버블이 trigger에 대해 어디에 앉을지를, [Popover](../surfaces/popover) · [Tooltip](./tooltip)과 같은 어휘로 정합니다. 기본값은 `top` — 어떤 줄에 대한 질문은 아래 줄들을 덮는 것보다 그 위에 있는 편이 읽기 쉽습니다.

## 접근성

- [Popover](../surfaces/popover)를 그리므로 focus가 버블 안으로 들어갔다가 닫힐 때 trigger로 돌아옵니다.
- `Escape`와 바깥 클릭은 답하지 않고 닫습니다.
- trigger에는 자기 accessible name이 필요합니다. 아이콘만 있는 trigger는 맨 글리프가 아니라 `label`을 가진 [IconButton](../inputs/icon-button)이어야 합니다.
- severity 마크에는 `aria-hidden`이 붙습니다. 이미 글이 말한 것을 되풀이할 뿐이고, 그것이 온 색 계열은 스크린 리더가 쓸 수 있는 정보가 아니기 때문입니다.
