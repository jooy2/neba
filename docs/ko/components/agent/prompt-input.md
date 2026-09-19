---
title: PromptInput
order: 9
---

# PromptInput

<p class="neba-lede">프롬프트가 나가는 길 전부입니다. 입력란, 첨부와 모델 컨트롤, 그리고 보내고 나면 멈추는 버튼 하나. 입력란은 쓰는 만큼 자라다가 어느 지점에서 멈춥니다.</p>

<Demo src="prompt-input/hero" />

```tsx
import { PromptInput } from 'neba';

<PromptInput
  label="Message"
  placeholder="Ask about the design language…"
  value={value}
  onValueChange={setValue}
  onSubmit={ask}
/>;
```

## Props

<PropsTable name="PromptInput" />

`<textarea>`의 기본 속성은 컨트롤로 전달됩니다. 위 표에서 다르게 정의한 `color`, `size`, `value`, `defaultValue`, `onChange`, `onSubmit`, `children`만 제외됩니다. `className`과 `style`은 루트의 것이고, 루트는 진짜 `<form>`입니다.

`multiline`인 [TextField](../inputs/text-field)에 [Toolbar](../surfaces/toolbar)를 더하면 껍데기는 나옵니다. 나오지 않는 것은 호출할 때마다 다시 쓰게 되는 세 가지입니다. 자라다 멈추는 입력란, 자리를 옮기지 않고 정지 버튼이 되는 전송 버튼, 그리고 Enter가 *전송*이라는 규칙입니다.

## 예시

### submitting · onStop

버튼은 하나이고 절대 둘이 아닙니다. `submitting`인 동안 전송 버튼은 정지 버튼이 되고 계속 누를 수 있습니다. 답을 멈추려고 손이 가는 자리는 방금 시작하려고 누른 그 자리이며, 옆에 두 번째 버튼이 생기면 첫 번째가 밀려납니다.

답을 쓰는 동안에는 아무것도 전송되지 않습니다. 키도 마찬가지입니다.

<Demo src="prompt-input/submitting">

<<< @/.vitepress/demos/prompt-input/submitting.tsx

</Demo>

### submitKey

`Enter`가 보내고 `Shift+Enter`가 줄을 바꿉니다. `Mod+Enter`는 그 반대이며, 문단을 쓰는 입력란에 맞습니다. 조합은 [Shortcut](../display/shortcut)이 그리는 방식으로 씁니다. 입력란 옆의 키 캡과 실제로 작동하는 키가 같은 문자열입니다.

**입력기가 조합 중일 때는 어느 쪽도 작동하지 않습니다.** 한국어나 일본어 사용자가 후보를 확정하려고 Enter를 누르는 것은 단어를 끝내는 일이지 메시지를 보내는 일이 아닙니다. 그것을 전송으로 읽는 입력란은 그 언어를 쓸 수 없게 만듭니다.

<Demo src="prompt-input/submit-key">

<<< @/.vitepress/demos/prompt-input/submit-key.tsx

</Demo>

### minRows · maxRows

입력란은 가장 짧을 때 `minRows` 높이이고, 글에 따라 `maxRows`까지 자란 다음 스크롤이 생깁니다. 천장 없이 자라는 프롬프트 입력란은 자기가 속한 대화를 화면 밖으로 밀어냅니다.

높이는 선언이 아니라 측정으로 정합니다. 이것을 한 줄로 해 주는 CSS인 `field-sizing: content`는 라이브러리가 지원하는 브라우저보다 몇 년 앞서 있습니다.

<Demo src="prompt-input/rows">

<<< @/.vitepress/demos/prompt-input/rows.tsx

</Demo>

### onSubmit은 입력란을 비우지 않습니다

쓴 글을 어떻게 할지는 애플리케이션의 몫입니다. 전송에 실패한 메시지는 그대로 남아 있어야 하므로, 입력란을 비우는 일은 호출하는 쪽 핸들러의 한 줄입니다.

빈 입력란은 절대 전송되지 않습니다. 버튼은 비활성이고 키도 작동하지 않습니다.

### start · end · children

`start`는 입력란 아래 툴바의 앞쪽이며, 첨부 버튼과 모델 [Select](../inputs/select)가 들어가는 자리입니다. `end`는 그 반대쪽, 전송 버튼 앞이며 토큰 수나 모드 토글이 들어갑니다. `children`은 입력란 **위**의 띠로, 이미 추가한 첨부나 무엇에 답하는 중인지 알리는 줄이 들어갑니다.

### onFiles

이 prop을 주면 껍데기가 드롭 대상이 됩니다. 떨어진 파일들과 함께 호출되고, 그 파일을 어떻게 할지는 애플리케이션의 몫입니다. 드래그가 위에 있는 동안 껍데기가 받을 준비가 됐다고 말합니다.

## 접근성

- 루트는 진짜 `<form>`입니다. 그래서 휴대폰 키보드가 자체 전송 키를 내놓고, 버튼은 클릭 핸들러가 흉내 낸 것이 아니라 `type="submit"`입니다.
- `label`은 입력란의 접근 가능한 이름이며 스크린 리더에만 그려집니다. 이것이나 `aria-label`을 주세요. placeholder는 최후의 수단이고, 뭐라도 입력하면 사라집니다.
- 전송 버튼은 [IconButton](../inputs/icon-button)이라 `label`이 필수이고 상태에 따라 바뀝니다. "Send"가 "Stop"이 됩니다.
- 포커스 링은 `<textarea>`가 아니라 껍데기의 것입니다. 안쪽에 떠 있는 사각형이 아니라 아크릴의 테두리를 따라갑니다.
