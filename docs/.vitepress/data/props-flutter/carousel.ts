import { densityRow, from, renamed, sizeRow, variantRow, WIDGET, type PropRow } from './shared';

export default {
  Carousel: [
    from('Carousel', 'locale', { type: 'Locale?', default: undefined }),
    variantRow('Carousel', 'NebaVariant.outline'),
    sizeRow('Carousel'),
    from('Carousel', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Carousel'),
    from('Carousel', 'elevation', { type: 'NebaElevation', default: '0' }),
    from('Carousel', 'value', { type: 'int?' }),
    from('Carousel', 'defaultValue', { type: 'int' }),
    from('Carousel', 'onValueChange', { type: 'ValueChanged<int>?' }),
    from('Carousel', 'loop', { type: 'bool' }),
    from('Carousel', 'autoPlay', { type: 'bool' }),
    from('Carousel', 'interval', {
      type: 'Duration',
      default: 'Duration(seconds: 5)',
      description: {
        ko: 'autoPlay일 때 슬라이드 하나가 머무는 시간',
        en: 'How long a slide shows before the next, with autoPlay'
      }
    }),
    from('Carousel', 'arrows', { type: 'bool' }),
    from('Carousel', 'indicators', { type: 'bool' }),
    renamed('Carousel', 'label', 'semanticLabel', { type: 'String?' }),
    from('Carousel', 'previousLabel', { type: 'String?' }),
    from('Carousel', 'nextLabel', { type: 'String?' }),
    {
      name: 'pauseLabel · playLabel',
      type: 'String?',
      description: {
        ko: '정지와 재생 버튼의 이름. 생략하면 locale의 언어로 씁니다',
        en: 'The stop and the start button’s names. Left out, they are in the locale’s words'
      }
    },
    from('Carousel', 'slideLabel', { type: 'String Function(int index, int count)?' }),
    renamed('Carousel', 'children', 'children', {
      type: `List<${WIDGET}>`,
      description: {
        ko: '슬라이드. 위젯 하나가 슬라이드 하나이고, 가장 높은 슬라이드의 높이를 모두 함께 씁니다',
        en: 'The slides, one widget each, all as tall as the tallest of them'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
