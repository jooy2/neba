---
title: Alert
order: 1
---

# Alert

<p class="neba-lede">무슨 일이 일어났는지 알리는 메시지. 그 일이 벌어진 페이지 안에 놓입니다.</p>

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

## 예시

### 세 가지 모양은 하나의 컴포넌트입니다

한 줄, 글리프가 붙은 한 줄, 그리고 제목과 그 아래 설명. 세 개의 컴포넌트가 아니라 같은 슬롯을 어디까지 채웠는지의 차이입니다. 표면은 전혀 달라지지 않고, 얼마나 쓰였는지만 달라집니다.

<Demo src="alert/shapes">

<<< @/.vitepress/demos/alert/shapes.tsx

</Demo>

### Variant

Alert는 색이 **입혀지는 대상**입니다 — 남의 콘텐츠를 담는 그릇이 아니라 심각도에 대한 알림이므로, [Box](../surfaces/box)와 달리 시트가 실제로 물듭니다. `text`는 폼 안에 놓을 때 쓰세요. 입력 필드들 사이에 테두리 사각형이 하나 더 생기는 것은 하나가 너무 많습니다.

<Demo src="alert/variants">

<<< @/.vitepress/demos/alert/variants.tsx

</Demo>

### 심각도

<Demo src="alert/colors">

<<< @/.vitepress/demos/alert/colors.tsx

</Demo>

### 액션과 닫기

`action`을 `children`에서 빼 둔 이유는, 메시지가 여러 줄로 줄바꿈되어도 액션은 첫 줄에 남아 있어야 하기 때문입니다. `onClose`를 넘기는 것이 ×를 만드는 방법입니다.

<Demo src="alert/dismissing">

<<< @/.vitepress/demos/alert/dismissing.tsx

</Demo>

## 글리프도 메시지의 일부입니다

느낌표 하나를 여섯 가지 색으로 칠하는 대신, 여섯 계열에 세 가지 그림을 씁니다. 색은 모든 독자가 가진 감각이 아니고, "이게 잘못됐다"를 빨강으로만 말하는 알림은 일부에게만 말하는 알림입니다. `primary`와 `secondary`는 그릴 심각도가 없으므로 정보 알림과 같은 그림을 씁니다.

주변 문장이 이미 어떤 종류의 메시지인지 말하고 있다면 `icon={false}`를, 더 나은 그림이 있다면 노드를 넘기세요.

## 접근성

심각도가 live region을 정합니다. `warning`과 `danger`는 스크린 리더가 하던 말을 끊는 `role="alert"`, 나머지는 말이 끊길 때까지 기다리는 `role="status"`입니다. "실패했다"는 끊을 만하고 "저장했다"는 그렇지 않습니다.

더 잘 아는 호출자가 이깁니다 — `role`은 그대로 통과해서 기본값 뒤에 놓입니다.

`color`의 기본값은 `primary`가 아니라 `info`입니다. 여기가 `primary`가 거짓말이 되는 유일한 자리입니다. Alert는 무엇의 "주된" 것도 아니고 그냥 알림이며, 팔레트에는 이미 그것을 가리키는 단어가 있습니다.
