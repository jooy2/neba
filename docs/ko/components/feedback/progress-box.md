---
title: ProgressBox
order: 7
---

# ProgressBox

<p class="neba-lede">차례로 불이 들어오는 아크릴 판의 줄.</p>

<Demo src="progress-box/hero" align="center" />

```tsx
import { ProgressBox } from 'neba';

<ProgressBox />
<ProgressBox value={62} label="마이그레이션 중" showValue />
```

## Props

<PropsTable name="ProgressBox" />

## 예시

### 판의 개수

<Demo src="progress-box/counts">

<<< @/.vitepress/demos/progress-box/counts.tsx

</Demo>

### 정말로 단계가 있을 때

`count`에 단계 수를 주면 판은 장식이기를 그만둡니다. 판 하나가 단계 하나가 되고, 진행 중인 단계가 앞머리 판을 채웁니다.

<Demo src="progress-box/steps">

<<< @/.vitepress/demos/progress-box/steps.tsx

</Demo>

## 세 번째 모양이 왜 필요한가

막대와 고리는 둘 다 "이만큼 끝났다"고 말합니다. 양에 대한 이야기입니다. 판의 줄은 이 라이브러리 자신의 어휘로 "지금 동작 중"이라고 말합니다 — 같은 잘린 시트, 같은 하이라인, 같은 채움. Neba 표면 안의 로딩 상태에서, 남의 회색 스피너가 빌려온 물건처럼 보이는 자리에 이것이 맞는 이유입니다.

값이 있으면 값에도 답합니다. 판은 왼쪽부터 차오르고 앞머리 판은 부분적으로 채워집니다. 판이 전부 아니면 전무라면 네 개로는 0·25·50·75·100밖에 말할 수 없고, 30%는 4분의 1로 반올림되어 사라질 테니까요.

## 움직임이 아니라 색

판은 움직이지 않습니다. 파도는 채움과 빛 가장자리만 애니메이션하고, 각 판은 자기 인덱스만큼 늦게 시작합니다. 그래서 한 줄이 튀어 오르는 무언가가 아니라 무언가가 쓰이고 있는 표면으로 읽힙니다. `prefers-reduced-motion`에서는 주기가 움직임으로 읽히지 않을 만큼 느려질 뿐입니다.

## 접근성

나머지 둘과 같습니다. `role="progressbar"`와 값 속성은 Base UI의 Progress가 가지고, `label`이 접근성 이름이 되며, 미정인 줄은 0이 아니라 미정이라고 스스로 밝힙니다.
