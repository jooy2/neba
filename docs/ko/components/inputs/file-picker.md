---
title: FilePicker
order: 10
---

# FilePicker

<p class="neba-lede">파일을 끌어다 놓거나 눌러서 파일 창을 여는 dropzone입니다. 크기와 형식, 개수 제한을 검사하고 거부된 파일을 따로 알려 줍니다.</p>

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

`<div>`의 native 속성은 root로 전달됩니다. `color` · `defaultValue` · `title`만 위 표와 이름이 겹쳐 제외됩니다.

## 예시

### variant

세 가지 무게 모두 점선 테두리를 공유합니다.

<Demo src="file-picker/variants">

<<< @/.vitepress/demos/file-picker/variants.tsx

</Demo>

### accept · maxSize · maxFiles

브라우저의 `accept` 속성은 파일 창에만 적용되고 드래그로 도착한 파일에는 적용되지 않으므로, 이 컴포넌트가 같은 문자열을 직접 검사합니다. `.확장자` · `type/subtype` · `type/*` 세 형태를 모두 지원합니다.

`maxFiles`는 한 번에 놓을 수 있는 개수가 아니라 **보유할 수 있는 총 개수**입니다. 이미 두 개를 들고 있는 `maxFiles={3}` 픽커에 세 개를 놓으면 하나만 받아들입니다.

### onReject

제한에 걸려 거부된 파일과 그 이유를 전달합니다. 이 핸들러가 없으면 거부된 파일이 아무 표시 없이 사라지므로 반드시 붙이세요.

<Demo src="file-picker/rejection">

<<< @/.vitepress/demos/file-picker/rejection.tsx

</Demo>

### disabled · readOnly · error

<Demo src="file-picker/states">

<<< @/.vitepress/demos/file-picker/states.tsx

</Demo>

### title · hint · icon · showList

`title`과 `hint`는 dropzone 안의 안내 문구, `icon`은 그 위의 글리프입니다. `showList`는 선택된 파일 목록을 dropzone 아래에 표시합니다. `removeLabel`로 개별 제거 버튼의 이름을 지정합니다.

## 접근성

- 상자는 `<div>`이고 그 안의 누를 수 있는 영역이 실제 `<button>`입니다. 파일 목록은 그 버튼 바깥에 있으므로 제거 버튼들이 열기 버튼 안에 중첩되지 않습니다.
- 버튼의 이름은 `label` 뒤에 상자에 적힌 문구를 이은 것이라, 한 폼에 피커가 둘 있어도 무엇을 위한 것인지로 구별됩니다.
- `<input type="file">`은 `required` 검증에 그대로 참여하고, 목록에 있는 파일만 들고 있습니다. 그래서 폼은 끌어다 놓은 파일을 제출하고 목록에서 뺀 파일은 제출하지 않습니다. `readOnly` 픽커도 들고 있는 파일을 제출하며, 폼에서 빠지는 것은 `disabled`뿐입니다.
