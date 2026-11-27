import { densityRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Tooltip: [
    from('Tooltip', 'content', {
      type: WIDGET,
      description: {
        ko: '툴팁이 하는 말. 보통 짧은 Text이며, 그 글을 화면 낭독기가 트리거의 이름 뒤에 읽습니다',
        en: "What it says, usually a short Text, whose words a screen reader hears after the trigger's name"
      }
    }),
    renamed('Tooltip', 'children', 'child', {
      type: WIDGET,
      description: {
        ko: '툴팁이 설명하는 위젯. 병합되지 않고 감싸지며, 레이아웃에는 아무것도 더하지 않습니다',
        en: 'The widget it describes. It is wrapped rather than merged onto, and the layout gains nothing'
      }
    }),
    sizeRow('Tooltip', 'NebaSize.sm'),
    from('Tooltip', 'color', { type: 'NebaColor', default: 'NebaColor.secondary' }),
    densityRow('Tooltip'),
    from('Tooltip', 'side', { type: 'NebaSide', default: 'NebaSide.top' }),
    from('Tooltip', 'align', { type: 'NebaAlign', default: 'NebaAlign.center' }),
    from('Tooltip', 'sideOffset', {
      type: 'double',
      description: {
        ko: '트리거와의 거리(논리 픽셀)',
        en: 'Distance from the trigger, in logical pixels'
      }
    }),
    from('Tooltip', 'delay', {
      type: 'Duration?',
      default: 'Duration(milliseconds: 600)',
      description: {
        ko: '열리기까지 포인터가 머물러야 하는 시간. 기본값은 NebaTooltipProvider의 것, 그다음 600밀리초입니다',
        en: "How long the pointer has to rest before it opens. Defaults to the NebaTooltipProvider's, then 600 milliseconds"
      }
    }),
    from('Tooltip', 'closeDelay', {
      type: 'Duration?',
      default: 'Duration.zero',
      description: {
        ko: '포인터가 떠난 뒤 닫히기까지의 시간. 기본값은 NebaTooltipProvider의 것, 그다음 0입니다',
        en: "How long it waits before closing. Defaults to the NebaTooltipProvider's, then none"
      }
    }),
    from('Tooltip', 'arrow', { type: 'bool' }),
    from('Tooltip', 'open', { type: 'bool?' }),
    from('Tooltip', 'defaultOpen', { type: 'bool' }),
    from('Tooltip', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Tooltip', 'disabled', { type: 'bool' })
  ]
} satisfies Record<string, PropRow[]>;
