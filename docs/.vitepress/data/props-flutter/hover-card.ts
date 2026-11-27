import { densityRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  HoverCard: [
    from('HoverCard', 'trigger', {
      type: WIDGET,
      description: {
        ko: '카드가 매달리는 위젯. 어떤 위젯이든 되며, 카드는 이것을 감쌀 뿐 레이아웃에는 아무것도 더하지 않습니다',
        en: 'What the card hangs off: any widget, which the card wraps without adding anything to the layout'
      }
    }),
    from('HoverCard', 'title', { type: `${WIDGET}?` }),
    from('HoverCard', 'description', { type: `${WIDGET}?` }),
    renamed('HoverCard', 'children', 'child', { type: `${WIDGET}?` }),
    sizeRow('HoverCard'),
    from('HoverCard', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('HoverCard'),
    from('HoverCard', 'side', { type: 'NebaSide', default: 'NebaSide.bottom' }),
    from('HoverCard', 'align', { type: 'NebaAlign', default: 'NebaAlign.center' }),
    from('HoverCard', 'sideOffset', {
      type: 'double',
      description: {
        ko: 'trigger와의 거리(논리 픽셀)',
        en: 'Distance from the trigger, in logical pixels'
      }
    }),
    from('HoverCard', 'alignOffset', {
      type: 'double',
      description: {
        ko: '그 모서리를 따라 미는 양(논리 픽셀)',
        en: 'Shift along that edge, in logical pixels'
      }
    }),
    from('HoverCard', 'arrow', { type: 'bool' }),
    from('HoverCard', 'open', { type: 'bool?' }),
    from('HoverCard', 'defaultOpen', { type: 'bool' }),
    from('HoverCard', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('HoverCard', 'delay', {
      type: 'Duration',
      default: 'Duration(milliseconds: 600)',
      description: {
        ko: '카드가 열리기까지 포인터나 키보드 focus가 trigger에 머물러야 하는 시간',
        en: 'How long the pointer, or the keyboard focus, has to rest on the trigger before the card opens'
      }
    }),
    from('HoverCard', 'closeDelay', {
      type: 'Duration',
      default: 'Duration(milliseconds: 300)',
      description: {
        ko: '포인터가 떠난 뒤 카드가 남아 있는 시간. trigger와 카드 사이의 빈틈을 건널 수 있게 합니다',
        en: 'How long the card stays after the pointer has left. This is what makes the gap crossable'
      }
    }),
    from('HoverCard', 'width', {
      type: 'double?',
      description: {
        ko: 'size가 정한 최대 너비를 덮어씁니다(논리 픽셀)',
        en: 'A hard cap on the width, overriding the one size implies, in logical pixels'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
