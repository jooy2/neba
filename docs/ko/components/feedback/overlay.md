---
title: Overlay
order: 8
---

# Overlay

<p class="neba-lede">페이지 전체를 덮어 쓰지 못하게 만드는 한 겹입니다. 스크림 그 자체이고, 그 위에 무엇을 올릴지는 부르는 쪽이 정합니다.</p>

<Demo src="overlay/hero" />

```tsx
import { Overlay, ProgressCircular } from 'neba';

<Overlay open={saving} tone="blur" label="저장 중">
  <ProgressCircular size="lg" />
</Overlay>;
```

## Props

<PropsTable name="Overlay" />

### Overlay인가 Dialog인가

차이는 여기에 _없는_ 것들입니다. Overlay에는 표면도, 테두리도, 제목도, 액션도 없습니다 — [Dialog](./dialog)는 질문을 던지는 한 장의 시트이고, Overlay는 그 시트가 떠 있었을 평면입니다.

페이지가 멈춰야 하는데 대답할 것이 없을 때 Overlay를 쓰세요. 저장되는 중이거나, 불러오는 중이거나, 통째로 바뀌는 중일 때입니다. 결정할 것이 생기는 순간 Dialog를 쓰세요.

### 기본값은 닫히지 않음입니다

두 번 읽을 가치가 있는 유일한 prop이고, Dialog와는 반대입니다.

dialog는 질문을 하고 Escape는 보편적인 _아니오_입니다. overlay는 아무것도 묻지 않습니다 — _기다려_라고 말할 뿐입니다 — 그리고 빗나간 클릭 한 번으로 사라질 수 있는 저장은 사용자가 끝났다고 믿어 버릴 저장입니다. 그래서 `dismissible`은 꺼진 채로 시작하고, 켜기 전까지 Escape도 스크림 클릭도 거절됩니다.

무언가의 바깥 클릭을 받아 내는 것이 존재 이유인 오버레이라면 켜세요.

<Demo src="overlay/dismissible">

<<< @/.vitepress/demos/overlay/dismissible.tsx

</Demo>

## 예시

### Tone

하나의 축 위의 네 단계입니다. 뒤에 있는 것이 얼마나 읽히는가.

각 단계는 알파만큼이나 블러 반경으로 조율되어 있습니다. 대략 16px을 넘기면 배경이 납작한 색으로 뭉개져서, 알파를 아무리 낮춰도 스크림이 불투명하게 읽히기 때문입니다.

| Tone | 뒤 페이지가 하는 일 |
| --- | --- |
| `scrim` | 여전히 읽힙니다. 닿을 수 없게 되었을 뿐입니다. Dialog의 배경막과 같은 것이라, 둘 사이에 이음매가 보이지 않습니다. |
| `blur` | 형태와 색으로는 남고 글자로는 사라집니다. "지금 이게 교체되는 중"일 때. |
| `solid` | 사라집니다. 페이지 표면 색으로 불투명하게. |
| `clear` | 아무것도 그리지 않습니다. 그래도 포인터는 막습니다 — 클릭을 받아 내는 보이지 않는 한 겹입니다. |

<Demo src="overlay/tones">

<<< @/.vitepress/demos/overlay/tones.tsx

</Demo>

## 접근성

- 포털, 스크롤 잠금, 안쪽에 붙잡히는 포커스, 뒤 페이지가 inert가 되는 것, 오버레이가 닫힐 때 포커스가 원래 자리로 돌아가는 것은 모두 Base UI가 담당합니다.
- 오버레이는 `dialog`이고 `label`이 그 접근성 이름입니다. 선택이 아니라 기본값을 갖습니다 — 읽을 것이 아무것도 없는 오버레이, 즉 스피너 하나뿐이거나 `clear`인 한 겹도 자기가 무엇인지는 말해야 하기 때문입니다.
- `modal="trap-focus"`는 페이지를 스크롤·클릭할 수 있게 두면서 포커스만 안쪽에 붙잡아 둡니다. `clear` 오버레이가 대개 원하는 것이 이쪽입니다.
- 페이드는 불투명도뿐입니다. 확대되거나 미끄러져 들어오는 오버레이는 그 위에 쓰인 것을 화면 위로 끌고 다니게 되는데, [디자인 언어](../../guide/design-language)가 가장 반대하는 것이 바로 그것입니다.
