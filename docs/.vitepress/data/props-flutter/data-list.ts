import { densityRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  DataList: [
    from('DataList', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('DataList', 'labelWidth', {
      type: 'double?',
      description: {
        ko: 'horizontal일 때 라벨 열의 너비. 논리 픽셀입니다. 지정하지 않으면 가장 긴 라벨만큼이되 목록 너비의 절반까지입니다',
        en: 'How wide the label column is when horizontal, in logical pixels. Left out, it is as wide as the widest label, up to half the list'
      }
    }),
    from('DataList', 'dividers', { type: 'bool' }),
    sizeRow('DataList'),
    densityRow('DataList'),
    from('DataList', 'children', {
      type: `List<${WIDGET}>`,
      required: true,
      description: {
        ko: '쌍. 보통 NebaDataListItem입니다',
        en: 'The pairs, usually NebaDataListItems'
      }
    })
  ],

  DataListItem: [
    from('DataListItem', 'label', {
      type: WIDGET,
      description: {
        ko: '값의 이름. 보통 Text이며, 한 단계 작고 흐린 글자로 그려집니다',
        en: 'What the value is called, usually a Text, muted and one step down the type scale'
      }
    }),
    renamed('DataListItem', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '값. Text뿐 아니라 Chip, 링크, 아바타 같은 widget도 들어가며, 자기 너비를 유지합니다',
        en: 'The value. A Text, or any widget, a Chip, a link or an avatar, which keeps its own width'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
