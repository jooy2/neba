---
title: Spoiler
order: 9
---

# Spoiler

<p class="neba-lede">누군가 요청하기 전까지 내용을 덮어 두는 상자입니다. 덮개는 숨겨진 박스가 아니라 blur이므로, 독자는 거기에 무언가가 있다는 것과 그 분량을 알 수 있으면서도 실수로 읽게 되지는 않습니다.</p>

<Demo src="spoiler/hero" />

```tsx
import { Spoiler } from 'neba';

<Spoiler locale="ko">
  <p>로즈버드는 썰매의 이름이었습니다.</p>
</Spoiler>;
```

## Props

<PropsTable name="Spoiler" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 예외는 `onChange` 하나로, 여기서 들을 만한 변화는 `onRevealedChange`입니다.

공통 축(`variant` `size` `color` `density` `elevation`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### maxHeight

지정하지 않으면 상자는 담고 있는 것의 높이 그대로입니다. 문단이나 사진에는 그쪽이 맞습니다. 덮개는 내용이 드러난 뒤에도 자리를 지키므로, 덮고 있던 줄보다 안내문과 버튼이 더 높더라도 누르는 순간 상자가 줄어들지 않고 아래 내용도 밀리지 않습니다.

높이를 바꾸는 것은 `maxHeight` 하나뿐입니다. 덮여 있는 동안의 높이를 제한하고, 열면 그 제한이 풀려 내용이 필요한 높이를 그대로 차지합니다. 제한이 남아 있으면 읽는 사람에게는 스크롤바만 남습니다. CSS 길이 또는 픽셀 수를 받습니다.

`reversible`은 열고 난 뒤 다시 덮을 수 있게 내용 아래에 닫기 버튼을 둡니다. 그 줄은 아직 덮여 있는 동안에도 자리를 지키므로 돌아가는 길 역시 상자 높이를 늘리지 않습니다.

<Demo src="spoiler/clamped">

<<< @/.vitepress/demos/spoiler/clamped.tsx

</Demo>

### locale

이 컴포넌트가 스스로 지어내는 말은 버튼과 그 위의 한 줄뿐이고, `locale`은 그 말들의 언어를 정합니다. `ko`, `pt-BR`, `zh-Hant` 같은 BCP 47 태그를 받습니다. 번역이 없는 태그는 영어로 돌아가고, 지역 태그는 언어로 해석됩니다 — `ko-KR`은 `ko`, `zh-TW`는 번체입니다.

<Demo src="spoiler/locale">

<<< @/.vitepress/demos/spoiler/locale.tsx

</Demo>

### label, description, action

`label`은 버튼의 말을, `description`은 그 위의 줄을 바꿉니다. `description={false}`면 덮개에 아무것도 쓰지 않습니다. `blur`는 흐림의 세기를 픽셀로 정합니다.

`action`은 버튼을 통째로 갈아 끼웁니다. 이때 버튼의 동작은 직접 연결해야 하며, `revealed`와 `onRevealedChange`를 씁니다.

<Demo src="spoiler/words">

<<< @/.vitepress/demos/spoiler/words.tsx

</Demo>

### padded

상자는 Box와 같은 스케일로 내용에 여백을 둡니다. 가장자리까지 채워야 하는 것에는 이것을 끄면 됩니다. 그러면 다른 시트에서와 마찬가지로 모서리가 그림을 잘라 냅니다.

<Demo src="spoiler/media">

<<< @/.vitepress/demos/spoiler/media.tsx

</Demo>

### variant

`text`는 상자를 아예 그리지 않습니다. 글 한가운데 놓이는 spoiler가 대개 원하는 모습입니다. `solid`는 채워진 시트로, 독자를 멈춰 세워야 할 때 씁니다.

<Demo src="spoiler/inline">

<<< @/.vitepress/demos/spoiler/inline.tsx

</Demo>

### 제어하기

`revealed`를 넘기면 Spoiler는 자체 상태를 갖지 않습니다. 여러 개를 한 번에 열거나, 독자가 이미 연 것을 기억하거나, 컨트롤을 페이지의 다른 자리에 두고 싶을 때 씁니다.

```tsx
const [revealed, setRevealed] = useState(false);

<Spoiler revealed={revealed} onRevealedChange={setRevealed}>
  <p>범인은 집사였습니다.</p>
</Spoiler>;
```

## 접근성

- 덮여 있는 동안 내용은 `inert`입니다. tab 순서에서 빠지고, 접근성 트리에서 사라지며, 전체 선택에도 걸리지 않습니다. 전체 선택으로 뚫리는 spoiler는 spoiler가 아닙니다.
- 열기 버튼은 자신이 여는 내용을 가리키는 `aria-expanded`와 `aria-controls`를 갖습니다.
- 버튼과 안내 문구가 페이지의 언어로 읽히도록 `locale`을 지정하거나, `label`과 `description`에 직접 쓰세요.
