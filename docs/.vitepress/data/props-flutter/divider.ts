import { from, renamed, WIDGET, type PropRow } from './shared';

export default {
  Divider: [
    from('Divider', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('Divider', 'color', { type: 'NebaColor?', default: 'NebaColor.primary' }),
    from('Divider', 'size', { type: 'NebaSize?', default: 'NebaSize.md' }),
    from('Divider', 'length', {
      type: 'double?',
      description: {
        ko: '선이 뻗는 길이(논리 픽셀). 가로 divider는 너비, 세로 divider는 높이입니다. 남은 공간의 일부만큼 그리려면 FractionallySizedBox로 감싸세요',
        en: 'How far the rule runs, in logical pixels: the width of a horizontal divider, the height of a vertical one. A fraction of the room is a FractionallySizedBox around it'
      }
    }),
    from('Divider', 'thickness', {
      type: 'double',
      default: '1',
      description: { ko: '선의 두께(논리 픽셀)', en: 'How thick the rule is, in logical pixels' }
    }),
    renamed('Divider', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '선 안에 들어가는 라벨. Text이면 화면 낭독기가 이 글을 읽습니다',
        en: 'A label set into the line. A Text is also what a screen reader hears'
      }
    }),
    from('Divider', 'textAlign', { type: 'NebaAlign', default: 'NebaAlign.center' })
  ]
} satisfies Record<string, PropRow[]>;
