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
  Drawer: [
    from('Drawer', 'locale', {
      type: 'Locale?',
      description: {
        ko: '×의 접근성 이름을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language the × is named in. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Drawer', 'side', { type: 'NebaSide', default: 'NebaSide.left' }),
    from('Drawer', 'mode', { type: 'NebaDrawerMode', default: 'NebaDrawerMode.overlay' }),
    sizeRow('Drawer'),
    from('Drawer', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Drawer'),
    from('Drawer', 'open', { type: 'bool?' }),
    from('Drawer', 'defaultOpen', { type: 'bool?' }),
    from('Drawer', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    renamed('Drawer', 'trigger', 'triggerBuilder', {
      type: 'NebaDrawerTriggerBuilder?',
      description: {
        ko: 'drawer를 여는 위젯을 만드는 builder. drawer를 여는 callback을 받으며, 만든 위젯은 drawer를 쓴 자리에 남습니다. overlay 전용입니다',
        en: 'Builds what opens the drawer, handed the callback that opens it; what it builds stays where the drawer was written. overlay only'
      }
    }),
    from('Drawer', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목. 보통 Text이며, headingLevel의 heading이자 overlay drawer의 이름이 됩니다',
        en: 'The heading, usually a Text: a heading at headingLevel, and the name of an overlay drawer'
      }
    }),
    from('Drawer', 'headingLevel', {
      type: 'int',
      description: {
        ko: '화면 낭독기가 듣는 제목의 heading 레벨(1–6). inline drawer는 화면의 일부이므로 레벨 2 heading 옆이라면 2, 그 섹션 안이라면 3입니다',
        en: 'Which heading level, 1 to 6, a screen reader hears the title at. An inline drawer is part of the screen: 2 beside a level-2 heading, 3 inside its section'
      }
    }),
    from('Drawer', 'description', { type: `${WIDGET}?` }),
    from('Drawer', 'actions', {
      type: 'List<Widget>?',
      description: {
        ko: '패널 바닥에 고정되는 버튼 줄. 끝 정렬되고 자리가 모자라면 다음 줄로 넘어갑니다. NebaDrawerClose가 그중 하나를 닫기 버튼으로 만듭니다',
        en: 'The bottom row, held against the foot of the panel, end-aligned and wrapping when it runs out of room. NebaDrawerClose makes one of them close the drawer'
      }
    }),
    from('Drawer', 'dividers', { type: 'bool' }),
    from('Drawer', 'showClose', { type: 'bool?' }),
    from('Drawer', 'closeLabel', {
      type: 'String?',
      description: {
        ko: '×의 접근성 이름. 기본값은 locale의 “닫기”입니다',
        en: 'Accessible name of the ×. Defaults to the locale\'s "Close"'
      }
    }),
    from('Drawer', 'extent', {
      type: 'double?',
      description: {
        ko: '패널이 자기 변에서 얼마나 들어오는지를 논리 픽셀로 줍니다. left/right에서는 너비, top/bottom에서는 높이입니다',
        en: 'How far the panel reaches in from its edge, in logical pixels: a width for left and right, a height for top and bottom'
      }
    }),
    from('Drawer', 'rounded', { type: 'bool' }),
    from('Drawer', 'modal', {
      type: 'NebaModal',
      default: 'NebaModal.on',
      description: {
        ko: '뒤 페이지를 얼마나 가져갈지. NebaModal.trapFocus는 페이지를 쓸 수 있게 둔 채 focus만 가두고, NebaModal.off은 Tab이 밖으로 나가는 것도 허용합니다. overlay 전용',
        en: 'How much of the page is taken away. NebaModal.trapFocus keeps the page usable while holding the focus inside; NebaModal.off lets Tab leave as well. overlay only'
      }
    }),
    from('Drawer', 'dismissible', {
      type: 'bool',
      description: {
        ko: 'Esc나 스크림 누름, 화면 낭독기의 닫기 동작으로 닫히는지. overlay 전용',
        en: "Whether Escape, a press on the scrim or a screen reader's dismiss gesture closes it. overlay only"
      }
    }),
    from('Drawer', 'safeArea', {
      type: 'bool',
      description: {
        ko: '패널이 닿는 세 변의 시스템 inset(상태 표시줄, 노치, 홈 인디케이터)만큼 내용을 안쪽으로 둡니다. inset은 패널이 열리는 root overlay에서 읽습니다. overlay 전용',
        en: 'Keeps the contents clear of the system insets on the three edges the panel runs to: the status bar, a notch, the home indicator. Read from the root overlay the panel opens into. overlay only'
      }
    }),
    from('Drawer', 'keepMounted', {
      type: 'bool',
      description: {
        ko: '닫힌 drawer를 offstage로, focus 순서와 semantics 트리 밖에서 빌드된 채 남겨, 안의 state를 다음에 열 때까지 유지합니다',
        en: 'Keeps a closed drawer built, offstage and out of the focus order and the semantics tree, so what is in it keeps its state until the next opening'
      }
    }),
    semanticLabelRow,
    renamed('Drawer', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
