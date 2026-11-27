---
title: CodeBlock
order: 21
flutter: true
---

# CodeBlock

<p class="neba-lede">한 줄짜리 코드부터 수천 줄까지 보여주는 뷰어입니다. 문법 하이라이팅, 복사 버튼, 줄 번호, 셸 프롬프트를 갖추고 있으며 화면에 그려지는 요소는 모두 prop 하나씩으로 켜고 끕니다. 문장 안에 끼워 넣는 짧은 조각도, README 맨 위의 전체 기록도 같은 컴포넌트입니다.</p>

<Demo src="code-block/hero" minHeight="260" />

::: fw react

```tsx
import { CodeBlock } from 'neba';

<CodeBlock code="npm install neba" language="bash" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaCodeBlock(code: 'npm install neba', language: 'bash');
```

:::

## Props

<PropsTable name="CodeBlock" />

::: fw react

`color`, `title`, `prefix`, `children`, `onCopy`를 뺀 모든 네이티브 `<div>` 속성이 그대로 전달됩니다. 이 다섯은 컴포넌트가 직접 씁니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

::: fw flutter

블록은 문단처럼 주어진 너비를 그대로 차지하므로, 너비가 정해진 부모 안에 두어야 합니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

## 예시

### language

문법의 이름이며 `ts`, `bash`, `yml`, `dockerfile`처럼 씁니다. 흔히 쓰는 표기와 파일 확장자를 알아듣기 때문에 fenced code block에서 그대로 복사한 값이 바로 동작합니다. `jsx`와 `mjs`는 JavaScript, `yml`은 YAML, `html`과 `vue`는 XML로 해석됩니다. 모르는 이름은 거부하지 않고 하이라이팅 없이 그립니다.

<Demo src="code-block/language" minHeight="320">

::: fw react

<<< @/.vitepress/demos/code-block/language.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/language.dart

:::

</Demo>

::: fw react

컴포넌트에는 34개 언어가 함께 들어 있습니다. 그 밖의 언어는 highlight.js의 정의를 module scope에서 한 번 등록하면 됩니다.

```ts
import { registerLanguage } from 'neba';
import elixir from 'highlight.js/lib/languages/elixir';

registerLanguage('elixir', elixir);
```

:::

::: fw flutter

Flutter 패키지에는 highlight.js가 없습니다. 패키지에 들어 있는 lexer가 JSX를 포함한 TypeScript와 JavaScript, JSON, HTML과 XML, CSS, Bash, PowerShell, Python, YAML, SQL, Rust, diff에 색을 입히고, 그 밖의 이름은 알아듣고 바에 적되 하이라이팅 없이 그립니다. 다른 언어는 블록을 빌드하기 전에 한 번, 소스를 run 목록으로 바꾸는 함수로 등록합니다.

```dart
registerNebaCodeLanguage('ini', (String source) => <NebaCodeSpan>[
  for (final String line in source.split('\n'))
    NebaCodeSpan('$line\n', line.startsWith(';') ? NebaCodeKind.comment : NebaCodeKind.plain),
]);
```

:::

### theme

블록이 입는 팔레트이며, 페이지의 light·dark와는 별개입니다.

넷은 라이브러리 자신의 것입니다. <Fw react="`dark`가" flutter="`NebaCodeTheme.dark`가" /> 기본이고 `light`가 그 짝, <Fw react="`auto`는 가장 가까운 `.dark` · `.light` · `data-theme` 루트를, 루트가 없으면 시스템 설정을 따라가며" flutter="`auto`는 블록이 놓인 테마를 따라가며" />, `mono`는 색을 전부 버리고 굵기와 흐림 정도로만 구조를 나타냅니다. 여기에 공개된 값을 그대로 옮겨 온 여덟 개가 더 있습니다. <Fw react="`one-dark`, `dracula`, `monokai`, `nord`, `night-owl`, `gruvbox`, `github`, `solarized-light`입니다" flutter="`oneDark`, `dracula`, `monokai`, `nord`, `nightOwl`, `gruvbox`, `github`, `solarizedLight`입니다" />.

<Demo src="code-block/theme" minHeight="480">

::: fw react

<<< @/.vitepress/demos/code-block/theme.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/theme.dart

:::

</Demo>

::: fw react

테마는 `.neba-code[data-code-theme]` selector 아래의 `--n-code-*` custom property 묶음일 뿐이므로, `theme`은 아무 문자열이나 받고 프로젝트는 자기 테마를 직접 쓸 수 있습니다.

```css
.neba-code[data-code-theme='ours'] {
  --n-code-bg: #101418;
  --n-code-fg: #d7dce2;
  --n-code-comment: #59626e;
  --n-code-keyword: #ff8ab3;
  --n-code-string: #9ad48f;
  /* number, function, type, variable, tag, attr, meta, add, del */
}
```

채워야 하는 slot은 열네 개입니다. 선택자에 `.neba-code`를 붙여야 stylesheet를 불러오는 순서와 상관없이 기본 테마보다 우선합니다. 흐린 글자, 얇은 선, hover 틴트, 그리고 `highlightLines`가 쓰는 둘은 모두 `--n-code-bg`와 `--n-code-fg`에서 섞여 나오므로 따로 적지 않아도 따라옵니다.

:::

::: fw flutter

직접 만드는 테마는 테마가 채우는 열네 색을 담은 `NebaCodePalette`로 만든 `NebaCodeTheme`입니다.

```dart
const NebaCodeTheme ours = NebaCodeTheme(
  NebaCodePalette(
    background: Color(0xFF101418),
    foreground: Color(0xFFD7DCE2),
    comment: Color(0xFF59626E),
    keyword: Color(0xFFFF8AB3),
    string: Color(0xFF9AD48F),
    // number, function, type, variable, tag, attribute, meta, addition, deletion
  ),
  name: 'ours',
);
```

흐린 글자, 얇은 선, hover 틴트, 그리고 `highlightLines`가 쓰는 둘은 모두 `background`와 `foreground`에서 섞여 나오므로 따로 적지 않아도 따라옵니다.

:::

### highlightLines

특정 줄을 배경색과 시작 모서리의 선으로 표시합니다. <Fw react="숫자는 한 줄이고, 문자열은 `'4'`, `'4-9'`, `'1,4-9,12'`처럼 줄과 범위의 목록이며, 배열은 둘을 섞은 것입니다." flutter="값은 문자열이며 `'4'`, `'4-9'`, `'1,4-9,12'`처럼 한 줄이나 범위, 또는 그 목록입니다." /> 번호는 거터가 세는 방식 그대로이므로, <Fw react="`startLine={286}`일" flutter="`startLine: 286`일" /> 때 거터가 288이라고 부르는 줄은 <Fw react="`highlightLines={288}`입니다" flutter="`highlightLines: '288'`입니다" />.

틴트는 페이지의 색 계열이 아니라 그 테마 자신의 잉크에서 섞여 나오므로 열두 팔레트 어디에서나 읽힙니다.

<Demo src="code-block/marks" minHeight="520">

::: fw react

<<< @/.vitepress/demos/code-block/marks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/marks.dart

:::

</Demo>

### toolbar · showLanguage · copyable · rawToggle

코드 위의 바와 거기 놓이는 세 가지입니다. <Fw react="`toolbar={false}`는" flutter="`toolbar: false`는" /> 나머지 셋이 무엇이라고 하든 바와 그 위의 모든 것을 없앱니다. `rawToggle`은 기본이 꺼짐입니다. 켜면 하이라이팅을 걷어내고 문자를 있는 그대로 보여주는 토글이 바에 붙습니다.

<Demo src="code-block/chrome" minHeight="300">

::: fw react

<<< @/.vitepress/demos/code-block/chrome.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/chrome.dart

:::

</Demo>

### lineNumbers · startLine

옆에 붙는 줄 번호이며, 발췌한 코드가 실제로 시작하는 번호부터 매길 수 있습니다. 거터 너비는 마지막 번호에 맞춰지므로 블록을 스크롤해도 번호가 밀리지 않습니다.

<Demo src="code-block/numbers" minHeight="220">

::: fw react

<<< @/.vitepress/demos/code-block/numbers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/numbers.dart

:::

</Demo>

### prompt

내용이 있는 줄 앞에 붙는 셸 기호로, `$`, `#`, `C:\>`, `>>>` 같은 값을 받습니다. 그려지기는 하지만 실제로 거기 있지는 않습니다. <Fw react="기호가 생성된 콘텐츠라서 블록을 드래그해도 선택되지 않고, 페이지 내 찾기에도 걸리지 않으며, 복사 버튼으로도 직접 복사해도 클립보드에 들어가지 않습니다." flutter="기호가 선택 범위 밖에 있어서 블록을 드래그해도 선택되지 않고, 복사 버튼으로도 선택한 텍스트를 복사해도 클립보드에 들어가지 않습니다." />

<Demo src="code-block/prompt" minHeight="360">

::: fw react

<<< @/.vitepress/demos/code-block/prompt.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/prompt.dart

:::

</Demo>

### maxHeight · wrap

`maxHeight`는 블록이 코드를 안에서 스크롤시키기 전까지 커질 수 있는 높이입니다. 숫자는 픽셀입니다. `wrap`은 긴 줄을 가로로 스크롤하는 대신 접습니다.

<Demo src="code-block/scroll" minHeight="320">

::: fw react

<<< @/.vitepress/demos/code-block/scroll.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/scroll.dart

:::

</Demo>

### fontFamily · fontSize · lineHeight · letterSpacing

`size`는 다른 곳에서와 마찬가지로 타입 스케일과 여백을 함께 옮깁니다. 네 개의 override는 `size`가 닿지 못하는 경우를 위한 것입니다. 라이선스를 산 서체, 스크린샷과 맞춰야 하는 고정 픽셀 크기, 소리 내어 읽기 위해 넉넉하게 벌린 행간 같은 것들입니다.

::: fw flutter

`fontSize`와 `letterSpacing`은 픽셀이고 `lineHeight`는 글자 크기의 배수입니다. `em`은 픽셀로 바꿔 적으므로, 15픽셀에서 `0.04em`은 `0.6`입니다.

:::

<Demo src="code-block/typography" minHeight="320">

::: fw react

<<< @/.vitepress/demos/code-block/typography.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/code_block/typography.dart

:::

</Demo>

### highlight

::: fw react

`highlight={false}`는 색을 전혀 입히지 않고 코드를 그리며, 문법도 내려받지 않습니다. 켜져 있으면 첫 프레임에는 색 없이 그려지고 문법이 도착하면 스스로 색을 입힙니다. 화면 밖에 있는 블록은 문법을 바로 내려받지만, 색은 화면 한 높이 안으로 다가왔을 때 입힙니다. 복사와 선택은 어느 쪽이든 똑같이 동작합니다.

:::

::: fw flutter

`highlight: false`는 색을 전혀 입히지 않고 코드를 그립니다. 켜져 있으면 첫 프레임부터 색이 입혀집니다. lexer가 패키지 안에 있어서 내려받을 것이 없기 때문입니다. 복사와 선택은 어느 쪽이든 똑같이 동작합니다.

:::

## 접근성

::: fw react

- 상자보다 넓거나 긴 코드는 `tabIndex={0}`과 이름을 가진 스크롤 가능한 region이라, 드래그할 포인터가 없는 독자도 스크롤할 수 있습니다. 이름은 `title`이 있으면 그것, 없으면 language입니다. 스크롤할 것이 없는 블록은 region도 tab 정지점도 아니므로, 짧은 스니펫이 많은 페이지가 landmark와 tab 정지점으로 가득 차지 않습니다.
- 프롬프트와 줄 번호는 대체 텍스트가 빈 생성 콘텐츠라 클립보드에서 빠지고 읽히지도 않습니다. 대체 텍스트 문법이 없는 브라우저(Firefox 128 미만, Safari 17.4 미만)에서는 여전히 읽힙니다.
- 복사 버튼은 결과를 polite live region으로 알립니다.
- 블록에 focus가 있는 상태의 <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd>는 그 코드만 선택합니다. 프롬프트와 줄 번호는 클립보드에서 빠지듯 선택에서도 빠집니다.

:::

::: fw flutter

- 상자보다 넓거나 긴 코드는 focus 순서에 들어가는 이름 있는 region이고, 화살표 키와 Page Up, Page Down, Home, End로 스크롤됩니다. 이름은 `semanticLabel`, 그다음 `Text`인 `title`, 그다음 language, 마지막으로 코드를 뜻하는 단어 순입니다. 스크롤할 것이 없는 블록은 region도 tab 정지점도 아니므로, 짧은 스니펫이 많은 페이지가 region과 tab 정지점으로 가득 차지 않습니다.
- 프롬프트와 줄 번호는 semantics 트리에서 빠지므로 화면 낭독기가 읽지 않고, 선택과 클립보드에서도 빠집니다.
- 복사 버튼은 결과를 status live region으로 알립니다.
- 코드는 포인터로 선택할 수 있고, 블록에 focus가 있는 상태의 <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd>는 그 코드만 선택합니다. 필드와 마찬가지로 터치 화면에는 아직 선택 핸들이 나오지 않습니다.

:::
