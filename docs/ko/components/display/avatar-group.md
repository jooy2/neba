---
title: AvatarGroup
order: 19
---

# AvatarGroup

<p class="neba-lede">겹쳐 쌓인 아바타 더미이고, 자리에 들어가지 못한 나머지는 숫자가 됩니다. 이 스레드에 누가 있는지, 이 방에 누가 있는지, 이 저장소가 누구의 것인지.</p>

<Demo src="avatar-group/hero" />

```tsx
import { Avatar, AvatarGroup } from 'neba';

<AvatarGroup max={3} total={24}>
  <Avatar name="Jane Doe" />
  <Avatar name="Kim Minji" />
  <Avatar name="Alex Park" />
  <Avatar name="Sam Lee" />
</AvatarGroup>;
```

## Props

<PropsTable name="AvatarGroup" />

`<div>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다. `size`, `shape`, `variant`, `color`, `elevation`은 그룹 안의 모든 [Avatar](./avatar)에 전달되며, 아바타 자신의 prop이 우선합니다. 그래야 그중 하나만 따로 구분해 표시할 수 있습니다.

첫 번째 아바타가 맨 위에 옵니다. 왼쪽에서 오른쪽으로 읽는 더미는 앞에서 뒤로 읽히므로, 그룹이 _말하고자 하는_ 사람이 마지막이 아니라 처음에 옵니다.

## 예시

### max · total

`max`는 나머지가 숫자가 되기 전까지 그려지는 개수입니다. `total`은 전체 인원 수로, 앞의 몇 명만 전달받은 그룹을 위한 것입니다. 지정하지 않으면 children의 개수로 계산하는데, 이는 전부 전달했을 때만 맞습니다.

<Demo src="avatar-group/max">

<<< @/.vitepress/demos/avatar-group/max.tsx

</Demo>

### size

<Demo src="avatar-group/sizes">

<<< @/.vitepress/demos/avatar-group/sizes.tsx

</Demo>

### overlap

각 아바타가 앞선 아바타 아래로 얼마나 들어가는지입니다. px 숫자나 임의의 CSS 길이를 받습니다. 지정하지 않으면 `size`의 일정 비율이므로 어느 단계에서든 같은 모양으로 보입니다. `0`이면 나란히 놓입니다.

<Demo src="avatar-group/overlap">

<<< @/.vitepress/demos/avatar-group/overlap.tsx

</Demo>

## 접근성

- 각 아바타는 자기 접근 가능한 이름을 그대로 가집니다. 스크린 리더는 그림이 아니라 사람을 읽습니다.
- 숫자는 `+3`으로 읽힙니다. 그룹이 독자가 조작할 수 있는 무언가를 대신한다면 이름을 나열하는 [Tooltip](../feedback/tooltip)이나 [HoverCard](../surfaces/hover-card)로 감싸세요.
