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
  Dialog: [
    from('Dialog', 'locale', {
      type: 'Locale?',
      description: {
        ko: '×의 접근성 이름을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language the × is named in. Defaults to NebaProvider's, then the app's"
      }
    }),
    sizeRow('Dialog'),
    from('Dialog', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Dialog'),
    from('Dialog', 'open', { type: 'bool?' }),
    from('Dialog', 'defaultOpen', { type: 'bool' }),
    from('Dialog', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    renamed('Dialog', 'trigger', 'triggerBuilder', {
      type: 'NebaDialogTriggerBuilder?',
      description: {
        ko: 'dialog를 여는 위젯을 만드는 builder. dialog를 여는 callback을 받으며, 만든 위젯은 dialog를 쓴 자리에 남습니다. 다른 곳에서 여는 제어 dialog에는 필요 없습니다',
        en: 'Builds what opens the dialog, handed the callback that opens it; what it builds stays where the dialog was written. A controlled dialog opened elsewhere needs none'
      }
    }),
    from('Dialog', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목. 보통 Text이며, 레벨 2 heading이자 dialog의 이름이 됩니다',
        en: 'The heading, usually a Text: a level-2 heading, and the name of the dialog'
      }
    }),
    from('Dialog', 'description', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목 아래 흐린 한 줄. 제목 다음에 읽힙니다',
        en: 'A muted line under the title, read after it'
      }
    }),
    from('Dialog', 'actions', {
      type: 'List<Widget>?',
      description: {
        ko: '아래쪽 버튼 줄. 끝 정렬되고 자리가 모자라면 다음 줄로 넘어갑니다. NebaDialogClose가 그중 하나를 닫기 버튼으로 만듭니다',
        en: 'The bottom row, end-aligned and wrapping when it runs out of room. NebaDialogClose makes one of them close the dialog'
      }
    }),
    from('Dialog', 'dividers', { type: 'bool' }),
    from('Dialog', 'showClose', { type: 'bool' }),
    from('Dialog', 'closeLabel', {
      type: 'String?',
      description: {
        ko: '×의 접근성 이름. 기본값은 locale의 “닫기”입니다',
        en: 'Accessible name of the ×. Defaults to the locale\'s "Close"'
      }
    }),
    from('Dialog', 'width', {
      type: 'double?',
      description: {
        ko: 'size가 정한 최대 너비를 대신할 값(논리 픽셀)',
        en: 'A cap overriding the one size implies, in logical pixels'
      }
    }),
    from('Dialog', 'fullWidth', { type: 'bool' }),
    from('Dialog', 'fullScreen', {
      type: 'bool',
      description: {
        ko: '창을 가장자리까지 채우고 모서리를 각지게 합니다. 시트 위의 내용은 시스템 inset만큼 안쪽에 둡니다',
        en: 'Fills the window edge to edge with square corners, and keeps what is on the sheet clear of the system insets'
      }
    }),
    from('Dialog', 'modal', {
      type: 'NebaModal',
      default: 'NebaModal.on',
      description: {
        ko: '뒤 페이지를 얼마나 가져갈지. NebaModal.trapFocus는 페이지를 누를 수 있게 둔 채 focus만 가두고, 페이지를 누르면 닫힙니다. NebaModal.off은 Tab이 밖으로 나가는 것도 허용합니다',
        en: 'How much of the page is taken away. NebaModal.trapFocus keeps the page pressable while holding the focus inside, and a press on it closes the dialog; NebaModal.off lets Tab leave as well'
      }
    }),
    from('Dialog', 'dismissible', {
      type: 'bool',
      description: {
        ko: 'Esc, 시트 바깥 누름, 화면 낭독기의 닫기 동작으로 닫히는지. 끄려면 답할 수 있는 actions를 반드시 함께 주세요',
        en: "Whether Escape, a press outside the sheet or a screen reader's dismiss gesture closes it. Turn it off only with actions that answer it"
      }
    }),
    from('Dialog', 'initialFocus', {
      type: 'FocusNode?',
      description: {
        ko: '열릴 때 focus를 받을 노드. 기본값은 안에서 처음 focus를 받을 수 있는 것, ×가 보이면 ×입니다',
        en: 'What takes the focus when it opens. By default the first thing inside that takes it, which is the × when it is shown'
      }
    }),
    from('Dialog', 'finalFocus', {
      type: 'FocusNode?',
      description: {
        ko: '닫힐 때 focus가 돌아갈 노드. 기본값은 열리기 전에 focus를 쥐고 있던 것입니다',
        en: 'Where the focus goes when it closes. By default what held it before it opened'
      }
    }),
    {
      name: 'role',
      type: 'SemanticsRole',
      default: 'SemanticsRole.dialog',
      description: {
        ko: '화면 낭독기가 듣는 역할. 다른 무엇보다 먼저 답해야 하는 질문이라면 SemanticsRole.alertDialog, React의 role 속성에 해당합니다',
        en: "The role a screen reader hears. SemanticsRole.alertDialog for a question that has to be answered before anything else: React's role attribute"
      }
    },
    semanticLabelRow,
    renamed('Dialog', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
