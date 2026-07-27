---
title: IconButton
order: 14
---

# IconButton

<p class="neba-lede">글리프 하나만 들어 있는 동그란 버튼. 그리고 잊어버릴 수 없게 만든 이름.</p>

<Demo src="icon-button/hero" />

```tsx
import { IconButton } from 'neba';

<IconButton icon={<PlusIcon />} label="항목 추가" />;
```

아이콘만 있고 children이 없는 [Button](./button)은 이미 정사각형이 됩니다 — 같은 높이, 같은 너비, 모서리가 잘린 아크릴. 이것은 다른 쪽 모양, 원반입니다.

나머지는 전부 Button의 것이고 그대로 둔 것이 의도입니다: variant, elevation 사다리, 포인터 빛, `loading`, `readOnly`, 그리고 감싸고 있는 [ButtonGroup](./button-group)이 정한 값들. 같은 표면을 같은 표의 복사본 두 개로 그리는 컴포넌트 둘은 언젠가 서로 어긋납니다.

## Props

<PropsTable name="IconButton" />

`<button>`의 네이티브 속성은 그대로 전달됩니다.

## 예시

### 크기

나머지 전부와 같은 컨트롤 높이라서, 원반 하나가 버튼 줄에 끼어도 그 줄의 기준선이 흐트러지지 않습니다.

<Demo src="icon-button/sizes">

<<< @/.vitepress/demos/icon-button/sizes.tsx

</Demo>

### 상태

<Demo src="icon-button/states">

<<< @/.vitepress/demos/icon-button/states.tsx

</Demo>

## `label`이 필수인 이유

라벨이 그림뿐인 버튼은 접근 가능한 이름이 아예 없습니다. "`aria-label` 없는 아이콘 버튼"은 컴포넌트 라이브러리가 내보내는 가장 흔한 접근성 결함 하나이고, 리뷰를 넘겨도 살아남는 유일한 해법은 이름을 빠뜨릴 수 없게 만드는 것입니다 — 그래서 선택이 아니라 필수 prop입니다.

```tsx
// 컴파일되지 않습니다.
<IconButton icon={<TrashIcon />} />

// 됩니다.
<IconButton icon={<TrashIcon />} label="파일 삭제" />
```

글리프는 보이지만 무슨 뜻인지는 짐작이 안 되는 독자에게 이름을 보여 주고 싶다면 [Tooltip](../feedback/tooltip)과 함께 쓰세요.

## 둥근 모서리에 대하여

이 라이브러리의 반지름 규칙은 모든 모서리를 컨트롤이 알약이 되는 50% 바로 앞에서 붙잡습니다. 위아래 가장자리를 따라 남는 평평한 구간이야말로 모서리를 잘라 낸 시트로 읽히게 하는 것이기 때문입니다. 원반은 그것을 의도적으로 깨뜨립니다.

그 규칙은 _라벨이 있는_ 컨트롤에 대한 것입니다. 평평한 구간은 한 줄의 글자가 앉을 자리로 있는 것이고, 글리프에는 앉을 글자 줄이 없습니다. 표식 하나를 가운데 둔 원은 찍어 낸 키가 아니라 뚫어 낸 토큰이므로, 규칙이 지키려던 것을 다른 경로로 지킵니다. 레이아웃이 정사각형 아이콘 컨트롤을 원한다면 — ButtonGroup 안이나 빽빽한 테이블 행에서 — children 없는 Button이 이미 그것입니다.

## Material UI에서 옮겨올 때

| MUI                                | Neba                                                      |
| ---------------------------------- | --------------------------------------------------------- |
| `<IconButton><Add /></IconButton>` | `icon={<Add />}`, 그리고 `label`은 필수                   |
| `size="small"`                     | `size="sm"` — 다섯 단계 사다리이고, 컨트롤 높이입니다     |
| `edge="start"`                     | 없습니다. 바깥 레이아웃으로 하세요                        |
| `color="error"`                    | `color="danger"`                                          |
| `disabled`                         | 같습니다. Button에서 온 `loading`과 `readOnly`도 있습니다 |
