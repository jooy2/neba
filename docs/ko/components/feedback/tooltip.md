---
title: Tooltip
order: 4
---

# Tooltip

<p class="neba-lede">포인터가 잠시 머물면 나타나는 짧은 설명.</p>

<Demo src="tooltip/hero" align="center" />

```tsx
import { Button, Tooltip } from 'neba';

<Tooltip content="배포 URL 복사">
  <Button variant="outline" startIcon={<LinkIcon />} />
</Tooltip>;
```

## Props

<PropsTable name="Tooltip" />

## 예시

### 방향

자리가 없으면 반대쪽으로 넘어갑니다. Base UI가 하는 일이고, 옳은 동작입니다 — 창 가장자리에 잘린 툴팁은 반대편에 뜬 툴팁보다 나쁩니다.

<Demo src="tooltip/sides">

<<< @/.vitepress/demos/tooltip/sides.tsx

</Demo>

### 툴바 하나에 지연 하나

`TooltipProvider`는 지연을 그룹이 함께 씁니다. 하나가 열리고 나면 이웃들은 즉시 열리고, 잠시 쉬면 다시 기다림이 돌아옵니다. 이것이 없으면 아이콘 버튼 줄을 훑을 때마다 매번 전체 지연을 기다려야 하고, 툴팁이 포인터와 싸우는 것처럼 느껴지는 이유가 바로 그것입니다.

<Demo src="tooltip/grouped">

<<< @/.vitepress/demos/tooltip/grouped.tsx

</Demo>

## 감쌀 뿐, 더하지 않습니다

Base UI의 트리거는 자기 박스를 그리는 대신 자식에 병합됩니다. 그래서 툴팁은 레이아웃에 아무 비용도 들이지 않고, 자식은 원래 그것이었던 것 그대로 남습니다 — 버튼이든, 칩이든, 잘린 표 셀이든. 자식은 ref를 받고 props를 펼쳐 주는 요소 하나여야 하는데, Neba 컴포넌트는 모두 그렇습니다.

## 짧게 쓰세요

툴팁은 그릇이 아닙니다. 터치 화면에서는 포인터로 닿을 수 없고, 주의가 옮겨가는 순간 사라지며, 안에 누를 수 있는 무언가를 넣어도 누를 수 없습니다. 둘 중 하나가 필요한 내용이라면 그것은 popover의 일입니다.

판이 서리 유리가 아니라 채워진 면인 이유도 같습니다. 이 라이브러리에서 떠 있는 다른 모든 것은 반투명 아크릴이지만, 툴팁은 떠 있는 0.5초 동안 하필 그 뒤에 있는 무엇 위에서 읽혀야 하고, 반투명한 시트는 대비를 약속할 수 없는 유일한 표면입니다.

## 접근성

지연과 그룹 타임아웃, 키보드 포커스에서는 열리되 클릭에서 온 포커스에서는 열리지 않는 처리, Esc로 닫기, 창 가장자리를 피하는 위치 계산은 Base UI가 합니다.

Base UI가 일부러 열어 둔 부분 — 팝업은 여러 가지일 수 있고 어떤 것인지는 호출자만 압니다 — 은 여기서 연결합니다. 판에 `role="tooltip"`이 붙고, 열려 있는 동안에만 트리거에 그 판을 가리키는 `aria-describedby`가 붙습니다.

툴팁은 **설명**이지 이름이 아닙니다. 컨트롤에 이름이 필요하면 이름을 주세요. 아이콘만 있는 버튼에는 `aria-label`이 필요하고, 그 옆의 툴팁은 덧붙이는 한 문장이지 라벨이 아닙니다.
