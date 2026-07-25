---
title: Badge
order: 6
---

# Badge

<p class="neba-lede">다른 것의 모서리에 걸리는 작은 표식입니다. 받은 편지함 아이콘 위의 읽지 않은 메일, 아바타 위의 상태 점, 탭 위의 개수.</p>

<Demo src="badge/hero" />

```tsx
import { Badge, Button } from 'neba';

<Badge content={4} label="읽지 않은 알림 4개">
  <Button startIcon={<BellIcon />} />
</Badge>

<Badge dot color="success" overlap="circle">
  <Avatar />
</Badge>;
```

## Props

<PropsTable name="Badge" />

## 예시

### Variant와 색

<Demo src="badge/variants">

<<< @/.vitepress/demos/badge/variants.tsx

</Demo>

### 무엇을 말하는가

`max`를 넘긴 숫자는 커지는 대신 `99+`가 됩니다. 단어는 자르지 않습니다 — 배지는 단어를 어떻게 줄여야 할지 알 수 없기 때문입니다.

`content`가 `0`이면 기본적으로 아무것도 그리지 않습니다. 읽지 않은 메시지 0개는 소식이 아니고, 사라지지 않는 배지는 곧 아무 뜻도 없는 배지가 됩니다. 셀 것은 없지만 알릴 것은 있을 때가 `dot`입니다.

<Demo src="badge/content">

<<< @/.vitepress/demos/badge/content.tsx

</Demo>

### 어느 모서리에, 얼마나 파고들지

`placement`는 `top`/`bottom`과 `start`/`end`를 합친 한 단어입니다. 모서리는 하나의 결정이고, 두 개의 prop으로 쪼개면 `{ vertical: 'left' }` 같은 표기가 가능해집니다. `start`/`end`이므로 쓰기 방향을 따라 뒤집힙니다.

`overlap`은 아래 있는 것의 모양입니다. 원의 모서리는 사각형의 모서리보다 중심에서 멀기 때문에, 아이콘 버튼에서 맞던 배지가 아바타에서는 떠 보입니다.

<Demo src="badge/placement">

<<< @/.vitepress/demos/badge/placement.tsx

</Demo>

### 크기

<Demo src="badge/sizes">

<<< @/.vitepress/demos/badge/sizes.tsx

</Demo>

## 배지는 알약이어도 되는 유일한 것입니다

18px 높이에서 `--neba-radius-xs`(10px)는 이미 알약이 되는 절반 지점을 넘습니다. 그래서 Badge는 라이브러리에서 유일하게 `rounded-full`을 씁니다.

이것은 [디자인 언어](../../guide/design-language)의 구멍이 아니라 그 언어가 스스로 지정한 예외입니다. 시트 위아래 가장자리의 평평한 구간은 "이것은 잘린 표면이다"라고 말하기 위한 것입니다. 배지는 표면이 아닙니다. 표면 **위에** 놓인 자국이고, 자국에는 자를 가장자리가 없습니다 — 옆 사람의 영역을 침범하는 유일한 컴포넌트인 것도 같은 이유입니다.

## transform은 쓰지 않습니다

다른 라이브러리는 모서리 배치에 `translate(50%, -50%)`를 씁니다. 여기서는 자기 높이의 절반만큼 음수 마진을 줍니다. 두 줄이 더 들지만 [transform 금지 규칙](../../guide/design-language)은 절대적이고, 그 두 줄보다 값어치가 있습니다.

부수 효과도 나쁘지 않습니다. 세로로는 정확히 절반이 걸치고, 가로로는 폭이 아닌 높이의 절반만큼 당겨지므로 `99+` 같은 넓은 배지가 조금 덜 튀어나옵니다 — 어차피 그쪽이 보기 좋습니다.

## 접근성

`content={3}`이 종 아이콘 옆에 있으면 스크린 리더에는 그저 "3"입니다. `label`은 그 자리를 문장으로 바꿉니다.

```tsx
<Badge content={3} label="읽지 않은 알림 3개">
  <Button startIcon={<BellIcon />} aria-label="알림" />
</Badge>
```

`dot`일 때도 숫자는 DOM에 남습니다 — 잘려서 보이지 않을 뿐입니다. 조용한 모서리가 침묵하는 모서리는 아니어야 하기 때문입니다. 반대로 `invisible`이거나 `content`가 비어 표식이 없을 때는 아무것도 남기지 않습니다: 없는 표식은 할 말도 없고, 잘린 상자에 남은 글자는 페이지 내 검색이 여전히 찾아냅니다.
