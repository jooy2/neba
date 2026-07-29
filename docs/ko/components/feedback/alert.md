---
title: Alert
order: 1
---

# Alert

<p class="neba-lede">방금 일어난 일을 페이지 안에서 알리는 메시지입니다. 저장 성공, 검증 오류, 주의가 필요한 설정처럼 화면에 남아 있어야 하는 알림에 씁니다.</p>

<Demo src="alert/hero" />

```tsx
import { Alert } from 'neba';

<Alert color="success">변경 사항을 저장했습니다.</Alert>
<Alert color="danger" title="배포 실패" onClose={dismiss}>
  빌드가 코드 1로 종료되었습니다.
</Alert>;
```

## Props

<PropsTable name="Alert" />

`color`의 기본값은 `primary`가 아니라 `info`입니다.

## 예시

### title과 children

`title` 없이 `children`만 주면 한 줄 알림, `title`을 함께 주면 제목과 본문이 있는 두 줄 알림이 됩니다. 같은 컴포넌트에서 채운 slot의 개수만 다릅니다.

<Demo src="alert/shapes">

<<< @/.vitepress/demos/alert/shapes.tsx

</Demo>

### variant

Alert는 색이 입혀지는 대상이므로 [Box](../surfaces/box)와 달리 sheet 자체가 물듭니다. 폼 안에 넣을 때는 `text`를 쓰세요 — 입력 필드 사이에 테두리 사각형이 하나 더 생기지 않습니다.

<Demo src="alert/variants">

<<< @/.vitepress/demos/alert/variants.tsx

</Demo>

### color

`color`가 심각도를 정하고, 심각도에 따라 글리프도 함께 바뀝니다. 여섯 계열에 세 가지 그림이 배정되어 있어 색을 구분하지 못해도 종류가 전달됩니다.

<Demo src="alert/colors">

<<< @/.vitepress/demos/alert/colors.tsx

</Demo>

### icon

기본 글리프 대신 다른 node를 넘길 수 있고, `icon={false}`면 글리프를 그리지 않습니다.

### action과 onClose

`action`은 `children` 바깥의 별도 slot이므로, 메시지가 여러 줄로 줄바꿈되어도 액션은 첫 줄에 남습니다. `onClose`를 넘기면 닫기 버튼(×)이 나타납니다.

<Demo src="alert/dismissing">

<<< @/.vitepress/demos/alert/dismissing.tsx

</Demo>

## 접근성

- 심각도가 live region을 정합니다. `warning`과 `danger`는 screen reader가 읽던 내용을 끊는 `role="alert"`, 나머지는 끊기지 않고 기다리는 `role="status"`입니다.
- `role`을 직접 넘기면 기본값을 덮어씁니다.
- 여러 Alert가 있는 화면에서는 `closeLabel`로 무엇을 닫는지 밝혀 주세요.
