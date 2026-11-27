---
title: Card
order: 2
flutter: true
---

# Card

<p class="neba-lede">제목과 부제목, 본문, 푸터 자리가 배치된 Box입니다. 같은 형태의 내용을 반복해서 보여 줄 때 씁니다.</p>

<Demo src="card/hero" />

::: fw react

```tsx
import { Button, Card } from 'neba';

<Card title="Starter" subtitle="프로젝트 하나" footer={<Button>선택</Button>}>
  본문
</Card>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCard(
  title: const Text('Starter'),
  subtitle: const Text('프로젝트 하나'),
  footer: NebaButton(onPressed: choose, child: const Text('선택')),
  child: const Text('본문'),
);
```

:::

## Props

<PropsTable name="Card" />

[Box](./box)의 prop을 모두 받습니다. `padded`만 예외로, Card가 섹션별로 여백을 다시 배분하기 때문에 제외됩니다.

::: fw flutter

모든 slot은 widget입니다. `footer`는 본문의 타입으로 그려지지만 행으로 배치되지는 않습니다. 버튼 두 개는 `Row`나 `NebaFlex`로 묶고, `Spacer`로 하나를 끝으로 밀면 됩니다. Card는 주어진 너비를 그대로 차지하므로, 행 안에 놓을 때는 너비를 따로 정해 주세요.

:::

## 예시

### title · subtitle · headerAction · footer

섹션은 서브컴포넌트가 아니라 prop입니다. 넘기지 않은 slot은 <Fw react="렌더링되지" flutter="빌드되지" /> 않습니다. `headerAction`은 제목 줄 오른쪽 끝의 컨트롤 자리입니다.

<Demo src="card/sections">

::: fw react

<<< @/.vitepress/demos/card/sections.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/sections.dart

:::

</Demo>

### dividers

섹션 사이를 공백 대신 선으로 나눕니다. 선이 sheet 양끝까지 닿아야 하므로 여백이 Card에서 각 섹션으로 옮겨 갑니다.

<Demo src="card/dividers">

::: fw react

<<< @/.vitepress/demos/card/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/dividers.dart

:::

</Demo>

### size

sheet의 반경과 여백, 그리고 헤더와 본문의 타입 스케일을 함께 정합니다. 제목은 본문보다 한 단계 위, 부제목은 한 단계 아래입니다.

<Demo src="card/sizes">

::: fw react

<<< @/.vitepress/demos/card/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/card/sizes.dart

:::

</Demo>

### 컨트롤 담기

Card는 글만큼 폼도 잘 담으며, 폼의 액션은 `footer`에 둡니다.

::: fw react

`title`에 `title={<h2>…</h2>}`처럼 실제 heading을 넘기면 문서 개요에 들어갑니다. 넘긴 heading은 `h2`를 스타일링하는 본문 안에서도 브라우저 기본 크기 대신 Card의 타입 스케일을 물려받습니다. heading에 class를 붙이면 그 class가 스케일보다 우선합니다(`title={<h2 className="text-xl">…</h2>}`). 다만 class가 붙은 heading은 그 class에 맡기므로, 그런 본문 안에서는 class가 정하지 않은 속성에 본문 규칙이 적용됩니다.

:::

::: fw flutter

`title`을 `Semantics(header: true, child: …)`로 감싸면 화면 개요에 들어갑니다. 제목의 타입은 그대로 유지되고, `Text`에 준 `style`이 그보다 우선합니다.

:::

<Demo src="card/form">

::: fw react

<<< @/.vitepress/demos/card/form.tsx

:::

</Demo>
