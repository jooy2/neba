import { from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Overlay: [
    from('Overlay', 'locale', {
      type: 'Locale?',
      description: {
        ko: 'overlay의 이름을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language the overlay is named in. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Overlay', 'open', { type: 'bool?' }),
    from('Overlay', 'defaultOpen', { type: 'bool' }),
    from('Overlay', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Overlay', 'tone', { type: 'NebaOverlayTone', default: 'NebaOverlayTone.scrim' }),
    from('Overlay', 'dismissible', {
      type: 'bool',
      description: {
        ko: 'Esc, 올려 둔 것 바깥 누름, 화면 낭독기의 닫기 동작으로 닫히는지. Dialog와 반대로 꺼져 있습니다. 오버레이는 묻지 않고 기다리라고 말하며, 빗나간 누름으로 사라지는 저장은 끝났다고 믿게 되는 저장입니다',
        en: "Whether Escape, a press outside what is on it or a screen reader's dismiss gesture closes it. Off, the other way round from Dialog: an overlay is not asking anything, and a save dismissed by a stray press is a save the user will believe finished"
      }
    }),
    from('Overlay', 'modal', {
      type: 'NebaModal',
      default: 'NebaModal.on',
      description: {
        ko: '뒤 페이지를 얼마나 가져갈지. NebaModal.trapFocus는 페이지를 누를 수 있게 둔 채 focus만 붙잡으므로 clear tone은 아무것도 막지 못합니다. NebaModal.off은 Tab이 밖으로 나가는 것도 허용합니다',
        en: 'How much of the page is taken away. NebaModal.trapFocus leaves the page pressable while holding the focus inside, so the clear tone blocks nothing; NebaModal.off lets Tab leave as well'
      }
    }),
    from('Overlay', 'align', { type: 'NebaAlign', default: 'NebaAlign.center' }),
    sizeRow('Overlay'),
    from('Overlay', 'label', { type: 'String?' }),
    renamed('Overlay', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
