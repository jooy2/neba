---
title: 회원 가입 페이지
order: 4
aside: false
---

# 회원 가입 페이지

<p class="neba-lede">세 단계로 나뉜 Kestrel의 가입 화면입니다. 라이브러리의 필드만 남기고 나머지를 걷어낸 화면으로, 폼이 물을 수 있는 모든 종류의 답과 그 주변 상태가 들어 있습니다. <code>label</code>, <code>description</code>, <code>error</code>는 어느 필드에서나 같은 세 슬롯입니다.</p>

<Demo src="concepts/signup" min-height="620px" />

소스는 `docs/.vitepress/demos/concepts/signup.tsx` 한 파일입니다. 실제로 동작하니 첫 단계를 채우면 계속하기 버튼이 켜집니다.

## 어떤 필드가 무엇을 묻는지

| 질문 | 컴포넌트 | 볼 만한 것 |
| --- | --- | --- |
| 개인인지 팀인지 | `SegmentedButton` | 눈에 보이는 작은 집합에서 하나: 열어야 할 popup이 없습니다 |
| 이름·이메일·비밀번호 | `TextField` | `type="password"`, `autoComplete`, `startIcon` 모두 native control로 그대로 전달됩니다 |
| 비밀번호 강도 | `ProgressLinear` | `max={4}`에 구간별 색을 주었고, 무언가 입력된 뒤에만 나타납니다 |
| 생년월일 | `DatePicker` | `maxDate={new Date()}`로 미래 날짜를 고를 수 없게 하므로, 고른 뒤에 틀렸다고 말하지 않습니다 |
| 국가 | `Select` | 고정된 목록이라 값은 고르는 것이지 입력하는 것이 아닙니다 |
| 워크스페이스 URL | `TextField` | `startIcon`과 `endIcon`이 접두사와 도메인을 맡아서, 필드 자체는 slug만 남습니다 |
| 좌석 수 | `NumberField` | `min`과 `max`로 범위가 잡히고, 답의 종류에 맞는 stepper가 붙습니다 |
| 담당 분야 | `Combobox` | `multiple`이고, 목록에 없는 값은 마지막 행으로 제안됩니다 |
| 플랜 | `RadioGroup` `Radio` | 각각 `description`을 가진 두 선택지: 설명이 선택지 바로 옆에 있어야 하는 경우입니다 |
| 로고 | `FilePicker` | `accept`, `maxSize`, `maxFiles`가 값을 돌려주기 전에 적용됩니다 |
| 인증 코드 | `OtpField` | `length={6}`에 `groupSize={3}`. 붙여넣으면 칸이 한 번에 채워집니다 |
| 약관·소식 수신 | `Checkbox` `Switch` | 체크박스는 제출과 함께 하는 동의이고, 스위치는 켜는 순간 적용되는 설정입니다 |

## 참고

- 오류는 키를 누를 때마다가 아니라 focus를 잃을 때 나타나므로, 아직 떠나지 않은 필드가 빨갛게 되지 않습니다.
- 단계 버튼은 그 단계의 필드만 보고 판단합니다. 계속하기는 해당 단계가 유효해질 때까지 disabled이고, 마지막 단계는 코드와 약관 동의까지 필요합니다.
- 오른쪽 열은 `Card`, `List`, `Timeline`, `Blockquote`로, 체험판에 무엇이 들어 있는지와 다음에 무슨 일이 일어나는지를 보여 주고 인용 하나로 마무리합니다.
- 레이아웃은 `md` 기준의 `GridContainer`와 `Grid`라서, 모바일에서는 따로 설정하지 않아도 두 열이 한 열이 됩니다.
