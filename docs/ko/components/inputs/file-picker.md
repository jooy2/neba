---
title: FilePicker
order: 10
---

# FilePicker

<p class="neba-lede">파일을 끌어다 놓거나, 눌러서 파일 창을 여는 점선 상자입니다.</p>

<Demo src="file-picker/hero" />

```tsx
import { FilePicker } from 'neba';

<FilePicker
  multiple
  label="첨부"
  accept="image/*,.pdf"
  maxSize={5_000_000}
  maxFiles={4}
  onFilesChange={setFiles}
  onReject={setRejected}
/>;
```

## Props

<PropsTable name="FilePicker" />

## 예시

### Variant

셋 다 점선 테두리를 공유합니다. 라이브러리에서 실선이 아닌 선을 긋는 유일한 곳이고, 장식이 아닙니다 — 점선 사각형은 "이 영역은 드롭을 받는다"는 굳어진 표시이고, 카드처럼 생긴 드롭존은 아무도 드롭해 보지 않는 카드입니다.

<Demo src="file-picker/variants">

<<< @/.vitepress/demos/file-picker/variants.tsx

</Demo>

### 되돌려 보낸 파일

<Demo src="file-picker/rejection">

<<< @/.vitepress/demos/file-picker/rejection.tsx

</Demo>

### 상태

<Demo src="file-picker/states">

<<< @/.vitepress/demos/file-picker/states.tsx

</Demo>

## 브라우저는 드롭된 파일에 `accept`를 적용하지 않습니다

`accept` 속성은 브라우저 **자기 파일 창**에만 걸립니다. 드래그로 도착한 파일은 그 문자열을 한 번도 통과한 적이 없습니다. 속성만 걸어 둔 드롭존은 드롭 앞에서는 무엇이든 받습니다.

이 컴포넌트는 같은 문자열을 직접 검사합니다 — 속성이 취하는 세 가지 형태 그대로: `.확장자`, `type/subtype`, `type/*`.

## 깜박이지 않는 드래그 상태

`dragenter`와 `dragleave`는 포인터가 존의 **자식**을 지날 때마다 발생합니다. 그래서 불리언 하나를 토글하는 드롭존은 파일이 자기 내용 위를 지나는 내내 깜박입니다. 세는 것이 그 해법이고, 내용이 든 존에서 살아남는 유일한 방법입니다.

## `maxFiles`는 "이만큼 놓을 수 있다"가 아닙니다

"이만큼 갖고 있을 수 있다"입니다. 이미 든 파일과 합쳐서 세므로, 두 개를 들고 있는 `maxFiles={3}` 픽커에 세 개를 놓으면 하나만 받아들입니다.

## 왜 Base UI 프리미티브가 없는가

드롭존은 드래그 이벤트 네 개를 듣는 `<div>`와, 대신 눌러 주는 `<input type="file">`입니다. 위치를 잡을 팝업도, 가둘 포커스도, 돌아다닐 roving focus도 없습니다. [디자인 언어](../../guide/design-language)가 허용하는 폴백 — 평범한 React와 DOM — 이 여기서는 옳은 선택입니다.

남는 것은 손으로 만든 드롭존들이 대개 틀리는 부분들이고, 위의 세 절이 그것들입니다.

## 접근성

상자는 `<div>`이고 그 안의 누를 수 있는 영역이 진짜 `<button>`입니다. 파일 목록은 그 버튼 **바깥**에 있습니다 — 삭제 버튼들을 열기 버튼 안에 넣을 수 없기 때문이고, [Chip](../display/chip)과 [ListItem](../display/list)이 쓰는 것과 같은 구조입니다.

진짜 `<input type="file">`은 숨기지 않고 화면 밖으로 보냅니다. `display: none`과 `visibility: hidden`은 일부 브라우저에서 input을 포커스 불가로 만드는데, 이 input은 폼과 `required` 유효성 메시지에 여전히 닿을 수 있어야 합니다.

`onReject`를 붙이세요. 없으면 되돌려 보낸 파일이 아무 말 없이 사라집니다.
