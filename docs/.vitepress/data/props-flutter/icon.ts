import { from, renamed, transitionRow, WIDGET, type PropRow } from './shared';

export default {
  Icon: [
    from('Icon', 'icon', {
      type: WIDGET,
      description: {
        ko: '글리프. 아이콘 폰트의 Icon, 그림, 사진 무엇이든 됩니다. IconTheme과 DefaultTextStyle로 크기와 색을 받습니다',
        en: 'The glyph: an Icon of an icon font, a drawing, a picture. It is handed the size and the colour through IconTheme and DefaultTextStyle'
      }
    }),
    from('Icon', 'size', { type: 'NebaSize', default: 'NebaSize.md' }),
    from('Icon', 'color', {
      type: 'NebaColor?',
      default: undefined,
      description: {
        ko: '글리프의 색 계열. 생략하면 주변 텍스트의 색을 물려받습니다',
        en: 'The family the glyph is drawn in. Left out, it takes the colour of the text around it'
      }
    }),
    renamed('Icon', 'label', 'semanticLabel', { type: 'String?' }),
    transitionRow('Icon')
  ]
} satisfies Record<string, PropRow[]>;
