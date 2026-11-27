import {
  densityRow,
  from,
  renamed,
  semanticLabelRow,
  sizeRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Popover: [
    from('Popover', 'locale', {
      type: 'Locale?',
      description: {
        ko: '× 버튼의 접근성 이름을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language the × is named in. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Popover', 'trigger', {
      type: `${WIDGET}?`,
      description: {
        ko: 'popup이 매달리고 popup을 여는 위젯. NebaButton 같은 Neba 컨트롤이어야 하며, 누르면 자기 일을 하고 popover도 열고 닫습니다. 없으면 popover를 쓴 자리에 매달립니다',
        en: 'What the popup hangs off and what opens it: a Neba control such as a NebaButton, whose press does its own work and opens and closes the popover too. Without one it hangs off the point where it is written'
      }
    }),
    sizeRow('Popover'),
    from('Popover', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Popover'),
    from('Popover', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목. 보통 Text이며, 그 글이 화면 낭독기에게 popup의 이름이 됩니다',
        en: 'The heading, usually a Text, whose words also name the popup for a screen reader'
      }
    }),
    from('Popover', 'description', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목 아래 흐린 한 줄. 그려진 자리에서 읽힙니다',
        en: 'A muted line under the title, read where it is drawn'
      }
    }),
    renamed('Popover', 'children', 'child', { type: `${WIDGET}?` }),
    from('Popover', 'side', { type: 'NebaSide', default: 'NebaSide.bottom' }),
    from('Popover', 'align', { type: 'NebaAlign', default: 'NebaAlign.center' }),
    from('Popover', 'sideOffset', {
      type: 'double',
      description: {
        ko: '트리거와의 거리(논리 픽셀)',
        en: 'Distance from the trigger, in logical pixels'
      }
    }),
    from('Popover', 'alignOffset', {
      type: 'double',
      description: {
        ko: '그 변을 따라 밀어내는 거리(논리 픽셀)',
        en: 'Shift along that edge, in logical pixels'
      }
    }),
    from('Popover', 'arrow', { type: 'bool' }),
    from('Popover', 'open', { type: 'bool?' }),
    from('Popover', 'defaultOpen', { type: 'bool' }),
    from('Popover', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Popover', 'modal', {
      type: 'NebaModal',
      default: 'NebaModal.off',
      description: {
        ko: '뒤 페이지를 얼마나 가져갈지. on은 페이지 위에 모든 누름을 받는 막을 깔고 Tab을 popup 안에 가둡니다. trapFocus는 Tab만 가두고 페이지는 누를 수 있게 둡니다',
        en: 'How much of the page behind is taken away. on lays a barrier over it that takes every press and keeps Tab inside; trapFocus keeps Tab inside and leaves the page pressable'
      }
    }),
    from('Popover', 'dismissible', {
      type: 'bool',
      description: {
        ko: 'Escape, 바깥 누름, 바깥으로 나간 focus로 닫히는지. 꺼도 ×와 NebaPopoverClose는 통과하므로 갇히지 않습니다',
        en: 'Whether Escape, a press outside and the focus leaving close it. The × and a NebaPopoverClose still get through, so it is never a trap'
      }
    }),
    from('Popover', 'showClose', { type: 'bool' }),
    from('Popover', 'closeLabel', { type: 'String?' }),
    from('Popover', 'width', {
      type: 'double?',
      description: {
        ko: 'size가 정한 최대 너비를 대신할 값(논리 픽셀)',
        en: 'A cap overriding the one size implies, in logical pixels'
      }
    }),
    semanticLabelRow
  ]
} satisfies Record<string, PropRow[]>;
