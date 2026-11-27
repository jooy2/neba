import { from, renamed, variantRow, type PropRow } from './shared';

export default {
  Highlight: [
    from('Highlight', 'query', {
      type: 'String | List<String> | RegExp',
      description: {
        ko: '무엇을 찾을지. 생성자가 타입을 정합니다. NebaHighlight는 문자열 하나, NebaHighlight.terms는 여러 개를 긴 것부터 시도하고, NebaHighlight.pattern은 RegExp를 그대로 씁니다. 문자열은 라틴·그리스·키릴 문자의 악센트를 무시하므로 jose가 José를 표시합니다',
        en: 'What to find, typed by the constructor: NebaHighlight takes one string, NebaHighlight.terms several tried longest first, and NebaHighlight.pattern a RegExp used as written. A string ignores the accents of Latin, Greek and Cyrillic letters, so jose marks José'
      }
    }),
    variantRow('Highlight', 'NebaVariant.solid'),
    from('Highlight', 'color', { type: 'NebaColor', default: 'NebaColor.warning' }),
    from('Highlight', 'caseSensitive', {
      type: 'bool',
      description: {
        ko: 'a와 A를 다른 글자로 볼지. NebaHighlight.pattern에는 없습니다',
        en: 'Whether `a` and `A` are different letters. NebaHighlight.pattern has none'
      }
    }),
    from('Highlight', 'wholeWord', {
      type: 'bool',
      description: {
        ko: '단어 전체일 때만 잡을지. cat이 "cat"은 잡고 "concatenate"는 잡지 않습니다. 단어는 글자·숫자·밑줄의 연속이므로 띄어쓰기로 단어를 나누지 않는 글에서는 효과가 거의 없습니다. NebaHighlight.pattern에는 없습니다',
        en: 'Whether a term has to be a word on its own: `cat` marking "cat" but not "concatenate". A word is a run of letters, digits and underscores in any script, which means very little for text that is not delimited by spaces. NebaHighlight.pattern has none'
      }
    }),
    from('Highlight', 'underline', { type: 'bool' }),
    from('Highlight', 'weight', { type: 'FontWeight?' }),
    renamed('Highlight', 'children', 'child', {
      type: 'Text | NebaTypography',
      description: {
        ko: '검색 대상 텍스트. Text, Text.rich, NebaTypography를 받습니다. span 안까지 들어가므로 굵은 span 안의 일치도 표시되고 굵기도 그대로 남습니다. 텍스트 안의 위젯은 건드리지 않습니다',
        en: 'The text to search: a Text, a Text.rich or a NebaTypography. Its spans are walked into, so a match inside a bold span is marked and stays bold; a widget inside the text is left alone'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
