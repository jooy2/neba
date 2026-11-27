import {
  densityRow,
  from,
  renamed,
  sizeRow,
  transitionRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Blockquote: [
    variantRow('Blockquote', 'NebaVariant.text'),
    sizeRow('Blockquote'),
    from('Blockquote', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Blockquote'),
    from('Blockquote', 'elevation', { type: 'NebaElevation', default: '0' }),
    from('Blockquote', 'author', {
      type: `${WIDGET}?`,
      description: {
        ko: '말한 사람. 앞에 붙는 줄표는 화면 낭독기가 읽지 않습니다',
        en: 'Who said it, set after an em dash a screen reader does not read out'
      }
    }),
    from('Blockquote', 'source', {
      type: `${WIDGET}?`,
      description: {
        ko: '어디서 나온 말인지, 책, 강연, 문서. author 뒤에 흐린 글자로 놓입니다',
        en: 'Where it is from: a book, a talk, a page. Set after the author in the muted colour'
      }
    }),
    from('Blockquote', 'icon', {
      type: `${WIDGET}?`,
      default: 'the quote mark',
      description: {
        ko: '인용문 앞의 표식. 글자 크기의 두 배, 색의 옅은 톤으로 그려집니다. 생략하면 기본 글리프, 위젯을 넘기면 교체, null이면 없앱니다',
        en: 'The mark before the quote, drawn at twice the text size in a pale wash of the colour. Omit for the house glyph, pass a widget to replace it, pass null to take it away'
      }
    }),
    renamed('Blockquote', 'children', 'child', { type: `${WIDGET}?` }),
    transitionRow('Blockquote')
  ]
} satisfies Record<string, PropRow[]>;
