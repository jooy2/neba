---
title: Approval
order: 2
---

# Approval

<p class="neba-lede">에이전트가 권한을 묻고, 무엇으로 답했는지를 그대로 남기는 카드입니다. 한 번만 허용, 항상 허용, 거부 — 실행하려는 명령을 아래에 펼쳐 두고, 제목 옆에 위험 수준을 붙입니다.</p>

<Demo src="approval/hero" />

```tsx
import { Approval } from 'neba';

<Approval
  risk="high"
  title="Run a shell command?"
  details="rm -rf ./dist"
  options={[
    { value: 'once', label: 'Allow once' },
    { value: 'always', label: 'Always allow' },
    { value: 'deny', label: 'Deny', color: 'danger' }
  ]}
/>;
```

## Props

<PropsTable name="Approval" />

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`와 `title`만 제외됩니다.

묻는 방법은 [Confirm](../feedback/confirm)과 [Popconfirm](../feedback/popconfirm)도 있습니다. 둘은 독자가 열고, 답이 둘이고, 하나를 고르는 순간 사라집니다. 이쪽은 에이전트가 열고, 에이전트가 가진 만큼의 답을 내놓고, 그대로 **남습니다**. 답하고 나면 질문이 사라지는 transcript는 무엇에 동의했는지 되짚어 읽을 수 없습니다.

### ApprovalOption

<PropsTable name="ApprovalOption" />

## 예시

### risk

`low`, `medium`, `high`. 제목 옆 칩에 단어로 쓰이며 색만으로 말하지 않습니다. 각각 카드의 색 계열도 가져갑니다. `info`, `warning`, `danger`이며, 라이브러리의 다른 곳에서도 이미 그런 뜻인 셋입니다.

`risk`를 주지 않으면 칩을 그리지 않고 `color`만 남습니다. 기본값은 `warning`입니다.

<Demo src="approval/risk">

<<< @/.vitepress/demos/approval/risk.tsx

</Demo>

### 어떤 답도 강조하지 않습니다

모든 버튼은 카드의 색 계열을 쓰는 `outline`이고, 하나를 두드러지게 하려면 그 option의 `variant`를 씁니다. 가장 눈에 띄는 버튼이 "허용"인 권한 요청은 독자가 아니라 버튼 배치가 답한 요청입니다. 묻는 이유는 답이 독자의 것이어야 하기 때문입니다.

option의 `description`은 버튼 안이 아니라 줄 아래에 나열됩니다. 버튼은 짧은 단어의 줄로 남고, "항상 허용"이 무엇까지 포함하는지는 눌러 보지 않고도 알 수 있습니다.

### decision · onDecide

`onDecide`는 option의 `value`를 받습니다. 제어하지 않으면 카드가 눌린 버튼을 기억해 두었다가 버튼 줄을 답을 적은 한 줄로 바꿉니다. 서버에서 다시 그리지 않는 transcript에는 이것으로 충분합니다.

`decision`을 넘기면 카드는 들은 것만 보여 줍니다. `null`은 아직 기다리는 중이고, `value`는 답한 상태입니다. 어느 쪽이든 루트에 `data-decided`가 붙습니다.

<Demo src="approval/decision">

<<< @/.vitepress/demos/approval/decision.tsx

</Demo>

### details

문자열은 줄바꿈을 그대로 둔 서식 있는 텍스트로 그립니다. 명령이나 payload가 원하는 형태입니다. 노드는 손대지 않고 그리므로, 인자를 고칠 수 있는 폼이 들어가는 자리가 됩니다. 보내기에 동의하기 전에 수신자를 고치는 경우가 그렇습니다.

<Demo src="approval/details">

<<< @/.vitepress/demos/approval/details.tsx

</Demo>

## 접근성

- 카드는 제목이 이름이 되는 `role="group"`입니다. 스크린 리더의 요소 목록에서 어떤 권한을 묻는 카드인지 알 수 있습니다.
- 답은 모두 진짜 [Button](../inputs/button)이고 탭 순서 안에 있습니다.
- 위험 수준은 색이 아니라 단어입니다.
