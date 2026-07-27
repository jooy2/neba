---
title: Icon
order: 7
---

# Icon

<p class="neba-lede">정해진 크기와 정해진 색으로 그려지는 글리프. Neba는 아이콘 세트를 제공하지 않습니다 — 대신 당신이 고른 세트에 라이브러리의 나머지가 쓰는 두 축을 붙여 줍니다.</p>

<Demo src="icon/hero" />

```tsx
import { Icon } from 'neba';

<Icon icon={<BoltIcon />} size="lg" color="warning" label="Fast" />;
```

아이콘 세트는 애플리케이션의 생김새에 대한 결정이고, 컴포넌트 라이브러리가 대신 내려도 되는 결정이 아닙니다. 세트가 없어서 아쉬운 것은 그보다 작고 시시한 쪽입니다 — 아이콘마다 그린 사람이 정한 크기로 도착하고, 받아 온 색을 그대로 달고 오며, 둘 다 쓰는 자리에서 하나씩 되돌려야 합니다.

**글리프는 children이 아니라 prop입니다.** 이 컴포넌트의 설계는 그게 전부입니다. 아이콘 세트가 건네주는 것은 당신이 그리지 않은 요소이고, 그것에 대해 늘 바꾸고 싶은 두 가지 — 크기와 색 — 는 그것이 무언가의 자식으로 들어간 뒤에는 손이 닿지 않는 두 가지입니다. prop이면 Icon이 _크기를 정해 주는_ 콘텐츠가 되고, 그냥 감싸기만 하는 콘텐츠가 아니게 됩니다.

## Props

<PropsTable name="Icon" />

`<span>`의 네이티브 속성은 그대로 전달됩니다.

## 예시

### 크기

컨트롤 높이가 아니라 자체 사다리입니다: 14, 16, 20, 24, 28px. 아이콘은 컨트롤이 아니고, `md` 버튼과 같은 32px짜리 `md` 글리프는 자기가 들어앉을 버튼만 해집니다. 여기 있는 단계들은 아이콘 세트들이 실제로 그려지는 크기라서, 글리프가 자기 격자 위에 정확히 떨어지고 리샘플링될 일이 없습니다.

<Demo src="icon/sizes">

<<< @/.vitepress/demos/icon/sizes.tsx

</Demo>

### 색, 그리고 물려받기

`color`는 라이브러리에서 기본값이 `primary`가 아닌 유일한 색 prop입니다. 아이콘은 콘텐츠이고, 압도적으로 흔한 경우는 자기 콘텐츠의 색을 이미 정해 놓은 무언가 안에 아이콘이 들어가는 것입니다 — 버튼의 라벨 안, 흐린 캡션 안, Alert 자신의 색 계열 안. 파랗게 물들어서 도착하는 Icon이라면 그 모든 자리에서 다시 꺼야 합니다.

<Demo src="icon/colors">

<<< @/.vitepress/demos/icon/colors.tsx

</Demo>

### 말을 하거나, 하지 않거나

`label`이 없으면 아이콘은 접근성 트리에서 완전히 숨습니다. 그게 옳은 기본값입니다 — 대부분의 아이콘 옆에는 같은 말을 하는 단어가 이미 있고, 둘 다 소리 내어 읽는 것은 하나만 읽는 것보다 나쁩니다. 글리프가 혼자서 뜻을 지고 있을 때만 `label`을 주세요.

```tsx
// 옆의 단어가 이미 "삭제"라고 말하고 있습니다.
<Button startIcon={<Icon icon={<TrashIcon />} />}>삭제</Button>

// 다른 무엇도 말해 주지 않으므로, 아이콘이 말해야 합니다.
<Icon icon={<TrashIcon />} label="삭제" />
```

글리프가 컨트롤 *전체*인 경우에는 [IconButton](../inputs/icon-button)을 쓰세요 — 그쪽은 이름을 선택이 아니라 필수로 만듭니다.

## Material UI에서 옮겨올 때

| MUI | Neba |
| --- | --- |
| `<Icon>star</Icon>` | 없습니다. Neba는 폰트 기반 아이콘 세트를 싣지 않으므로 요소를 넘기세요 |
| `<SvgIcon>…</SvgIcon>` | `icon={<svg …/>}` |
| `fontSize="small"` | `size="sm"` — 나머지 전부와 같은 다섯 단계 사다리 |
| `color="error"` | `color="danger"`, 그리고 기본값은 색 계열이 아니라 `inherit` |
| <code v-pre>sx={{ fontSize: 34 }}</code> | 없습니다. 크기는 사다리 위의 값이지 임의의 숫자가 아닙니다 |
