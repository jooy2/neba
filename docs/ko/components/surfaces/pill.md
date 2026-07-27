---
title: Pill
order: 6
---

# Pill

<p class="neba-lede">살아 있는 정보 한 줌을 담고 떠 있는 로젠지 — 녹음 타이머, 탑승 게이트, 아직 돌고 있는 빌드.</p>

<Demo src="pill/hero" />

```tsx
import { Pill } from 'neba';

<Pill startIcon={<DotIcon />} color="danger">
  녹음 중
</Pill>;
```

자리는 셋입니다: 앞의 글리프, 가운데, 뒤의 글리프. `onClick`을 주면 가운데가 진짜 버튼이 되고, `details`를 주면 아래로 자라 두 번째 절반이 생깁니다.

## Props

<PropsTable name="Pill" />

`<div>`의 네이티브 속성은 그대로 전달됩니다.

## 예시

### 접힘과 펼침

이 짝이 여기서 빌려 온 아이디어 전부입니다. 알약은 측정된 높이를 애니메이션해서 두 번째 절반으로 자랍니다 — [Accordion](./accordion)의 패널과 똑같은 방식이고, 이유도 같습니다: 아무것도 변형되지 않으므로 그 과정에서 글자가 리샘플링되는 일이 없습니다.

<Demo src="pill/expandable">

<<< @/.vitepress/demos/pill/expandable.tsx

</Demo>

닫혀 있는 동안 상세 영역은 단순히 `aria-hidden`이 아니라 `inert`입니다. 높이가 0인 상자는 그 안의 내용에 여전히 완벽하게 포커스가 가는 상자이고, `aria-hidden`만 걸어 두면 키보드 독자가 자기 스크린 리더로부터 "그런 것은 없다"고 들은 곳으로 탭해 들어가게 됩니다.

### 무게와 크기

색에 관한 한 Pill은 컨테이너가 아니라 *컨트롤*입니다. 색이 칠해지는 대상이 표면 자신이라는 뜻이고, [Button](../inputs/button)이나 [Chip](../display/chip)과 똑같습니다. 여기서 `color`의 기본값이 `primary`가 아니라 `secondary`인 것은, 이 모양이 흉내 내는 물건이 거의 중립인 검정이기 때문입니다.

<Demo src="pill/variants">

<<< @/.vitepress/demos/pill/variants.tsx

</Demo>

### 고정

`position`과 `side`는 [Toolbar](./toolbar)가 쓰는 것과 같은 어휘입니다. `fixed`는 뷰포트에 고정하고 가로로 가운데에 두는데, 이 모양이 존재하는 이유가 그 배치입니다 — 그리고 자기 폭의 절반만큼 밀어서가 아니라 auto 마진으로 가운데에 두므로 RTL에서도 가운데에 있습니다.

```tsx
<Pill position="fixed" side="top" startIcon={<BuildIcon />} color="info">
  빌드 중 — 7개 중 2개
</Pill>
```

## 둥근 모양에 대하여

라이브러리의 다른 모든 컨트롤은 알약이 되는 50% 반지름 바로 앞에서 붙잡혀 있습니다. 위아래 가장자리를 따라 남는 평평한 구간이야말로 모서리를 잘라 낸 시트로 읽히게 하는 것이기 때문입니다. 이것은 그 규칙이 겨냥해서 그어진 예외이고, 규칙이 성립하는 이유와 같은 이유로 성립합니다 — Pill은 페이지 위에 놓인 시트가 아닙니다. 페이지 위에 떠 있는 물건이고, 페이지 위에 떠 있는 물건은 페이지와 같은 재료에서 잘려 나온 것처럼 보이면 안 됩니다.

`elevation`의 기본값이 다른 모든 것의 `0`이 아니라 `2`인 것도 같은 이유입니다. 일관성이 깨진 것이 아닙니다 — 자기가 떠 있는 내용 위에 납작하게 붙은 로젠지는 실수처럼 보입니다.

## 다른 것을 써야 할 때

- 내용의 흐름 _안에_ 있는 토큰 — 태그, 필터, 상태 — 은 [Chip](../display/chip)입니다.
- 페이지 위쪽을 가로지르는 컨트롤 줄은 [Toolbar](./toolbar)입니다.
- 페이지가 기다리는 중이고 독자가 치울 수 없는 것은 [Overlay](../feedback/overlay), 치울 수 있는 것은 [Toast](../feedback/toast)입니다.
