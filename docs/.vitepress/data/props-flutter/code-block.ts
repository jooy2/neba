import { colorRow, densityRow, elevationRow, from, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  CodeBlock: [
    from('CodeBlock', 'code', {
      type: 'String',
      description: {
        ko: '코드 자체. 줄바꿈은 \\n으로 맞추고 끝의 빈 줄만 잘라냅니다. 들여쓰기가 의미를 갖는 언어가 많아 앞쪽은 건드리지 않습니다',
        en: 'The code itself. Line endings are normalised and only trailing blank lines trimmed; nothing is taken off the front, where indentation means something'
      }
    }),
    from('CodeBlock', 'language', {
      type: 'String?',
      description: {
        ko: '무엇으로 쓰였는지, ts, bash, yml. 흔한 표기와 파일 확장자를 알아듣습니다. 색을 입히는 언어는 패키지의 lexer가 아는 것뿐이고, 모르는 이름은 바에 적되 하이라이팅 없이 그립니다. registerNebaCodeLanguage로 더할 수 있습니다',
        en: 'What it is written in: ts, bash, yml. Common spellings and file extensions are understood. Only the languages the package’s lexers know are coloured; any other name is named on the bar and drawn plain, and registerNebaCodeLanguage adds one'
      }
    }),
    from('CodeBlock', 'theme', {
      type: 'NebaCodeTheme?',
      default: 'NebaCodeTheme.dark',
      description: {
        ko: '블록의 팔레트. 라이브러리가 직접 만든 넷(dark, light, auto, mono)과 공개된 값을 그대로 옮겨 온 여덟(oneDark, dracula, monokai, nord, nightOwl, gruvbox, github, solarizedLight)입니다. auto를 뺀 나머지는 페이지의 light·dark와 무관합니다. NebaCodePalette로 NebaCodeTheme을 만들면 그것이 곧 테마가 됩니다',
        en: "The palette it wears. Four of the library's own (dark, light, auto, mono) and eight ports kept at their published values: oneDark, dracula, monokai, nord, nightOwl, gruvbox, github, solarizedLight. Independent of the page's light and dark except on auto. A NebaCodeTheme made from a NebaCodePalette is a theme of your own"
      }
    }),
    sizeRow('CodeBlock'),
    colorRow('CodeBlock'),
    densityRow('CodeBlock'),
    elevationRow('CodeBlock'),
    from('CodeBlock', 'highlight', {
      type: 'bool',
      description: {
        ko: '코드에 색을 입힙니다. lexer가 패키지 안에 있으므로 첫 프레임부터 색이 입혀집니다',
        en: 'Colours the code. The lexers are part of the package, so the block is coloured on its first frame'
      }
    }),
    from('CodeBlock', 'toolbar', { type: 'bool' }),
    from('CodeBlock', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '바 맨 앞의 이름. 대개 파일 경로입니다. Text이면 스크롤 영역의 이름이 되기도 합니다',
        en: "A name at the start of the bar: a file path, usually. A Text also becomes the scrollable region's name"
      }
    }),
    from('CodeBlock', 'showLanguage', { type: 'bool' }),
    from('CodeBlock', 'copyable', {
      type: 'bool',
      description: {
        ko: '코드를 클립보드에 넣는 버튼. 클립보드가 거부하면 그렇게 말합니다',
        en: 'The button that puts the code on the clipboard. It says so when the clipboard refuses'
      }
    }),
    from('CodeBlock', 'rawToggle', { type: 'bool' }),
    from('CodeBlock', 'highlightLines', {
      type: 'String?',
      description: {
        ko: "표시할 줄. 한 줄이나 범위, 또는 그 목록을 문자열로 씁니다('4', '4-9', '1,4-9,12'). 거터가 세는 방식 그대로 세므로 startLine을 따릅니다. 틴트는 그 테마 자신의 잉크에서 섞여 나옵니다",
        en: "Lines to mark, as a string: a line or a range, or a list of them ('4', '4-9', '1,4-9,12'). Counted the way the gutter counts, so it follows startLine. The tint is mixed from the theme's own ink"
      }
    }),
    from('CodeBlock', 'lineNumbers', { type: 'bool' }),
    from('CodeBlock', 'startLine', { type: 'int' }),
    from('CodeBlock', 'prompt', {
      type: 'String?',
      description: {
        ko: '내용이 있는 줄 앞의 셸 기호, $, #, C:\\>, >>>. 그려지되 선택에도, 복사에도, 화면 낭독기에도 들어가지 않습니다',
        en: 'A shell symbol in front of every line that has something on it: $, #, C:\\>, >>>. Drawn, but never selected, copied or read out'
      }
    }),
    from('CodeBlock', 'wrap', { type: 'bool' }),
    from('CodeBlock', 'maxHeight', { type: 'double?' }),
    from('CodeBlock', 'fontFamily', { type: 'String?', default: 'NebaScale.monoFonts' }),
    from('CodeBlock', 'fontSize', {
      type: 'double?',
      description: {
        ko: 'size가 고른 코드의 크기를 덮어씁니다. 픽셀',
        en: "Overrides the code's size the size ladder chose, in pixels"
      }
    }),
    from('CodeBlock', 'lineHeight', {
      type: 'double?',
      description: {
        ko: '코드의 행간. 글자 크기의 배수입니다',
        en: "The code's leading, as a multiple of its size"
      }
    }),
    from('CodeBlock', 'letterSpacing', {
      type: 'double?',
      description: {
        ko: '코드의 자간. 픽셀이며, em은 픽셀로 바꿔 씁니다',
        en: "The code's tracking, in pixels; an em is written out as pixels"
      }
    }),
    from('CodeBlock', 'locale', {
      type: 'Locale?',
      default: 'NebaProvider',
      description: {
        ko: '복사 버튼과 raw 토글, region 이름이 쓰이는 언어. 생략하면 NebaProvider의 것, 그다음 앱의 것을 따릅니다. 지원하지 않는 언어는 영어로 돌아갑니다',
        en: "Which language the copy button, the raw toggle and the region's name are in. Left out, NebaProvider's and then the app's. Unsupported languages fall back to English"
      }
    }),
    from('CodeBlock', 'copyLabel · copiedLabel · rawLabel', { type: 'String?' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '스크롤되는 블록을 화면 낭독기가 부르는 이름. title이 Text가 아닐 때 이것으로 이름을 줍니다. 생략하면 Text인 title, language, 코드를 뜻하는 단어 순입니다',
        en: 'The name a screen reader announces for a block that scrolls, which is how a title that is not a Text names it. Left out, a Text title, then the language, then the word for code'
      }
    },
    from('CodeBlock', 'onCopy', { type: 'ValueChanged<String>?' })
  ]
} satisfies Record<string, PropRow[]>;
