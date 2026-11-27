---
title: Popconfirm
order: 12
flutter: true
---

# Popconfirm

<p class="neba-lede">그 질문을 띄운 컨트롤 옆에서 묻습니다. Confirm의 작은 형제로, 결과가 페이지 전체가 아니라 그 줄에 머무는 행동을 위한 것입니다.</p>

<Demo src="popconfirm/hero" frameMinHeight="300" />

::: fw react

```tsx
import { IconButton, Popconfirm } from 'neba';

<Popconfirm
  title="이 도메인을 제거할까요?"
  description="즉시 응답을 멈춥니다."
  onConfirm={() => remove(id)}
  trigger={<IconButton label="제거" icon={<TrashIcon />} />}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaPopconfirm(
  title: const Text('이 도메인을 제거할까요?'),
  description: const Text('즉시 응답을 멈춥니다.'),
  onConfirm: () => remove(id),
  trigger: NebaIconButton(onPressed: () {}, label: '제거', icon: const TrashIcon()),
);
```

:::

## Props

<PropsTable name="Popconfirm" />

::: fw flutter

trigger는 [Dialog](./dialog)처럼 builder가 아니라 [Popover](../surfaces/popover)처럼 위젯입니다. 버블이 trigger에 매달려 그 옆에 놓이므로, trigger는 popconfirm이 누름을 들을 수 있는 Neba 컨트롤이어야 합니다. trigger 역할만 하는 버튼에는 `onPressed: () {}`를 주세요. `onPressed`가 없는 버튼은 비활성입니다. `onConfirm`은 `Future`를 돌려줄 수 있고, `icon: false`는 `showIcon: false`이며, `classNames`는 없습니다.

:::

## 예시

### onConfirm과 비동기 작업

버블은 <Fw react="클릭할" flutter="누를" /> 때가 아니라 `onConfirm`이 **<Fw react="resolve될" flutter="완료될" /> 때** 닫힙니다. <Fw react="promise를" flutter="`Future`를" /> 반환하면 작업이 끝날 때까지 확인 버튼이 busy 상태로 남은 채 버블이 떠 있습니다. <Fw react="promise가 reject되면" flutter="`Future`가 오류로 완료되면" /> 버블은 열린 채 버튼이 다시 누를 수 있는 상태로 돌아가고, 에러는 잡지 않으므로 <Fw react="페이지의 에러 보고로" flutter="그 오류가 난 zone을 거쳐 앱의 에러 보고로" /> 그대로 전달됩니다.

::: fw react

```tsx
<Popconfirm title="키를 폐기할까요?" onConfirm={() => api.revoke(id)} trigger={…} />
```

:::

::: fw flutter

```dart
NebaPopconfirm(title: const Text('키를 폐기할까요?'), onConfirm: () => api.revoke(id), trigger: …);
```

:::

### onCancel과 dismiss

`onCancel`은 취소 버튼에서만 호출되고 `Escape`나 바깥 <Fw react="클릭에서는" flutter="누름에서는" /> 호출되지 **않습니다**.

### color와 icon

`color`의 기본값은 `danger`입니다. <Fw react="`icon`은" flutter="`showIcon`은" /> 그 계열의 severity 마크를 질문 옆에 그리며, 기본으로 켜져 있습니다. <Fw react="직접 만든 노드를 넘기거나 `false`로 끌 수 있습니다." flutter="`icon`에 직접 만든 위젯을 넘기면 둘레의 `IconTheme`이 넘기는 크기와 색으로 그려지고, `showIcon: false`로 끌 수 있습니다." />

### side와 align

`side`와 `align`은 trigger에 대해 버블이 놓일 자리를 정하며, [Popover](../surfaces/popover) · [Tooltip](./tooltip)과 같은 값을 받습니다. `side`의 기본값은 `top`입니다.

## 접근성

- [Popover](../surfaces/popover)를 그리므로 focus가 버블 안으로 들어갔다가 닫힐 때 trigger로 돌아옵니다.
- `Escape`와 바깥 <Fw react="클릭은" flutter="누름은" /> 답하지 않고 닫습니다.
- trigger에는 자기 accessible name이 필요합니다. 아이콘만 있는 trigger는 맨 글리프가 아니라 `label`을 가진 [IconButton](../inputs/icon-button)이어야 합니다.
- severity 마크는 <Fw react="`aria-hidden`이 붙으므로" flutter="semantics 트리에서 빠지므로" />, 마크와 색이 보여 주는 내용은 제목과 설명이 글로 말해야 합니다.
