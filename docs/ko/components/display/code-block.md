---
title: CodeBlock
order: 21
---

# CodeBlock

<p class="neba-lede">한 줄짜리 코드부터 수천 줄까지 보여주는 뷰어입니다. 문법 하이라이팅, 복사 버튼, 줄 번호, 셸 프롬프트를 갖추고 있으며 화면에 그려지는 요소는 모두 prop 하나씩으로 켜고 끕니다. 문장 안에 끼워 넣는 짧은 조각도, README 맨 위의 전체 기록도 같은 컴포넌트입니다.</p>

<Demo src="code-block/hero" minHeight="260" />

```tsx
import { CodeBlock } from 'neba';

<CodeBlock code="npm install neba" language="bash" />;
```

## Props

<PropsTable name="CodeBlock" />

`color`, `title`, `prefix`, `children`, `onCopy`를 뺀 모든 네이티브 `<div>` 속성이 그대로 전달됩니다. 이 다섯은 컴포넌트가 직접 씁니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

코드를 `children`이 아니라 `code` prop으로 받는 이유는 그것이 마크업이 아니라 문자열이기 때문입니다. 템플릿 리터럴은 자기 들여쓰기를 그대로 유지하지만 JSX는 그것을 뭉갭니다.

## Examples

### language

문법의 이름이며 `ts`, `bash`, `yml`, `dockerfile`처럼 씁니다. 흔히 쓰는 표기와 파일 확장자를 알아듣기 때문에 fenced code block에서 그대로 복사한 값이 바로 동작합니다. `jsx`와 `mjs`는 JavaScript, `yml`은 YAML, `html`과 `vue`는 XML로 해석됩니다. 모르는 이름은 거부하지 않고 하이라이팅 없이 그립니다.

<Demo src="code-block/language" minHeight="320">

<<< @/.vitepress/demos/code-block/language.tsx

</Demo>

컴포넌트에는 34개 언어가 함께 들어 있습니다. 그 밖의 언어는 highlight.js의 정의를 module scope에서 한 번 등록하면 됩니다.

```ts
import { registerLanguage } from 'neba';
import elixir from 'highlight.js/lib/languages/elixir';

registerLanguage('elixir', elixir);
```

### theme

블록이 입는 팔레트이며, 페이지의 light·dark와는 별개입니다.

넷은 라이브러리 자신의 것입니다. `dark`가 기본이고 `light`가 그 짝, `auto`는 페이지를 따라가며, `mono`는 색을 전부 버리고 굵기와 흐림 정도로만 구조를 나타냅니다. 여기에 공개된 값을 그대로 옮겨 온 여덟 개가 더 있습니다. `one-dark`, `dracula`, `monokai`, `nord`, `night-owl`, `gruvbox`, `github`, `solarized-light`입니다.

<Demo src="code-block/theme" minHeight="480">

<<< @/.vitepress/demos/code-block/theme.tsx

</Demo>

테마는 `[data-code-theme]` selector 아래의 `--n-code-*` custom property 묶음일 뿐이므로, `theme`은 아무 문자열이나 받고 프로젝트는 자기 테마를 직접 쓸 수 있습니다.

```css
[data-code-theme='ours'] {
  --n-code-bg: #101418;
  --n-code-fg: #d7dce2;
  --n-code-comment: #59626e;
  --n-code-keyword: #ff8ab3;
  --n-code-string: #9ad48f;
  /* number, function, type, variable, tag, attr, meta, add, del */
}
```

채워야 하는 slot은 열한 개입니다. 흐린 글자, 얇은 선, hover 틴트, 그리고 `highlightLines`가 쓰는 둘은 모두 `--n-code-bg`와 `--n-code-fg`에서 섞여 나오므로 따로 적지 않아도 따라옵니다.

### highlightLines

특정 줄을 배경색과 시작 모서리의 선으로 표시합니다. 숫자는 한 줄이고, 문자열은 `'4'`, `'4-9'`, `'1,4-9,12'`처럼 줄과 범위의 목록이며, 배열은 둘을 섞은 것입니다. 번호는 거터가 세는 방식 그대로이므로, `startLine={286}`일 때 거터가 288이라고 부르는 줄은 `highlightLines={288}`입니다.

틴트는 페이지의 색 계열이 아니라 그 테마 자신의 잉크에서 섞여 나오므로 열두 팔레트 어디에서나 읽힙니다.

<Demo src="code-block/marks" minHeight="520">

<<< @/.vitepress/demos/code-block/marks.tsx

</Demo>

### toolbar · showLanguage · copyable · rawToggle

코드 위의 바와 거기 놓이는 세 가지입니다. `toolbar={false}`는 나머지 셋이 무엇이라고 하든 바와 그 위의 모든 것을 없앱니다. `rawToggle`은 기본이 꺼짐입니다. 하이라이팅을 걷어내고 문자를 있는 그대로 보여주는데, 보통 버튼 하나면 충분한 바에 붙는 두 번째 버튼이기 때문입니다.

<Demo src="code-block/chrome" minHeight="300">

<<< @/.vitepress/demos/code-block/chrome.tsx

</Demo>

### lineNumbers · startLine

옆에 붙는 줄 번호이며, 발췌한 코드가 실제로 시작하는 번호부터 매길 수 있습니다. 거터 너비는 마지막 번호에 맞춰지므로 블록을 스크롤해도 번호가 밀리지 않습니다.

<Demo src="code-block/numbers" minHeight="220">

<<< @/.vitepress/demos/code-block/numbers.tsx

</Demo>

### prompt

내용이 있는 줄 앞에 붙는 셸 기호로, `$`, `#`, `C:\>`, `>>>` 같은 값을 받습니다. 그려지기는 하지만 실제로 거기 있지는 않습니다. 기호가 생성된 콘텐츠라서 블록을 드래그해도 선택되지 않고, 페이지 내 찾기에도 걸리지 않으며, 복사 버튼으로도 직접 복사해도 클립보드에 들어가지 않습니다.

<Demo src="code-block/prompt" minHeight="360">

<<< @/.vitepress/demos/code-block/prompt.tsx

</Demo>

### maxHeight · wrap

`maxHeight`는 블록이 코드를 안에서 스크롤시키기 전까지 커질 수 있는 높이입니다. 숫자는 픽셀입니다. `wrap`은 긴 줄을 가로로 스크롤하는 대신 접습니다.

<Demo src="code-block/scroll" minHeight="320">

<<< @/.vitepress/demos/code-block/scroll.tsx

</Demo>

### fontFamily · fontSize · lineHeight · letterSpacing

`size`는 다른 곳에서와 마찬가지로 타입 스케일과 여백을 함께 옮깁니다. 네 개의 override는 `size`가 닿지 못하는 경우를 위한 것입니다. 라이선스를 산 서체, 스크린샷과 맞춰야 하는 고정 픽셀 크기, 소리 내어 읽기 위해 넉넉하게 벌린 행간 같은 것들입니다.

<Demo src="code-block/typography" minHeight="320">

<<< @/.vitepress/demos/code-block/typography.tsx

</Demo>

### highlight

`highlight={false}`는 색을 전혀 입히지 않고 코드를 그리며, 이때는 아무것도 내려받지 않습니다. 문법 엔진이 dynamic import 뒤에 있기 때문에, 하이라이팅하지 않는 블록은 그 안의 텍스트 이상의 비용이 들지 않습니다. 켜져 있으면 첫 프레임에는 색 없이 그려지고 문법이 도착하면 스스로 색을 입힙니다.

## Accessibility

- 코드는 `tabIndex={0}`과 이름을 가진 스크롤 가능한 region이라, 드래그할 포인터가 없는 독자도 스크롤할 수 있습니다. 이름은 `title`이 있으면 그것, 없으면 language입니다.
- 프롬프트와 줄 번호는 생성된 콘텐츠이므로 클립보드뿐 아니라 accessibility tree에서도 빠집니다.
- 복사 버튼은 결과를 polite live region으로 알립니다. 그 외의 유일한 신호인 버튼 자신의 label 변화는 페이지를 읽고 있는 screen reader가 듣지 못하기 때문입니다.
- 블록에 focus가 있는 상태의 <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd>는 그 코드만 선택합니다. 코드 블록까지 tab으로 이동해 온 독자가 어느 편집기에나 있는 그 단축키를 눌렀다면 뜻한 것은 주변의 글이 아니라 이 코드입니다. 프롬프트와 줄 번호는 클립보드에서 빠지는 것과 같은 이유로 선택에서도 빠집니다.
- `theme`은 라이브러리에서 페이지를 따라가지 않는 유일한 색 결정입니다. `dark`로 둔 블록은 시스템이 light여도 어두운 채로 남으며, 이것은 의도된 것입니다. `auto`가 그 예외입니다.
