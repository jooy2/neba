import {
  colorRow,
  densityRow,
  elevationRow,
  from,
  renamed,
  semanticLabelRow,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  SegmentedButton: [
    variantRow('SegmentedButton', 'NebaVariant.outline'),
    sizeRow('SegmentedButton'),
    colorRow('SegmentedButton'),
    densityRow('SegmentedButton'),
    elevationRow('SegmentedButton'),
    from('SegmentedButton', 'value', {
      type: 'T?',
      description: {
        ko: '선택된 세그먼트의 값. controlled 세트에 씁니다. null이면 세트가 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: "The chosen segment's value, for a controlled set. Left null, the set keeps its own state, starting from defaultValue"
      }
    }),
    from('SegmentedButton', 'defaultValue', { type: 'T?' }),
    from('SegmentedButton', 'onValueChange', { type: 'ValueChanged<T?>?' }),
    from('SegmentedButton', 'disabled', { type: 'bool' }),
    from('SegmentedButton', 'readOnly', { type: 'bool' }),
    from('SegmentedButton', 'fullWidth', { type: 'bool' }),
    from('SegmentedButton', 'children', { type: 'List<NebaSegment<T>>' }),
    {
      ...semanticLabelRow,
      description: {
        ko: '화면 낭독기가 세트를 부르는 이름. React의 aria-label에 해당합니다',
        en: "What a screen reader calls the set: React's aria-label"
      }
    }
  ],

  Segment: [
    from('Segment', 'value', { type: 'T' }),
    from('Segment', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨 앞에 놓이는 아이콘. 세그먼트가 내려주는 IconTheme으로 라벨 크기의 1.2배가 됩니다',
        en: 'An icon before the label, drawn at 1.2 times its size through the IconTheme the segment hands down'
      }
    }),
    from('Segment', 'endIcon', { type: `${WIDGET}?` }),
    from('Segment', 'disabled', { type: 'bool' }),
    renamed('Segment', 'children', 'child', { type: `${WIDGET}?` }),
    semanticLabelRow
  ]
} satisfies Record<string, PropRow[]>;
