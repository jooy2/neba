import {
  colorRow,
  densityRow,
  elevationRow,
  focusRows,
  from,
  renamed,
  semanticLabelRow,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  BottomNavigation: [
    variantRow('BottomNavigation', 'NebaVariant.outline'),
    sizeRow('BottomNavigation'),
    colorRow('BottomNavigation'),
    densityRow('BottomNavigation'),
    elevationRow('BottomNavigation'),
    from('BottomNavigation', 'value', {
      type: 'T?',
      description: {
        ko: '지금 있는 목적지의 값. controlled 바에 씁니다. null이면 바가 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: 'The value of the destination the reader is on, for a controlled bar. Left null, the bar keeps its own state, starting from defaultValue'
      }
    }),
    from('BottomNavigation', 'defaultValue', { type: 'T?' }),
    from('BottomNavigation', 'onValueChange', {
      type: 'ValueChanged<T>?',
      description: {
        ko: '눌린 목적지의 값과 함께 호출됩니다. 지금 있는 목적지를 다시 눌러도 호출됩니다',
        en: 'Called with the value of the destination that was pressed, the current one included'
      }
    }),
    from('BottomNavigation', 'position', {
      type: 'NebaPosition',
      default: 'NebaPosition.fixed',
      description: {
        ko: '바를 어떻게 그리는지. fixed와 sticky는 아래 가장자리에 붙은 각진 시트로, 내용을 마주 보는 헤어라인만 긋고 시스템 inset을 피합니다. static은 모서리가 둥근 흐름 속의 시트입니다. 바를 어디에 둘지는 부모가 정하며, NebaPageLayout의 footer로 받은 바는 static이 아니면 페이지 아래에 붙잡힙니다',
        en: 'How the bar is drawn: fixed and sticky as a square sheet against the bottom edge that draws only the hairline facing the content and keeps clear of the system insets, static as a sheet with corners in the flow. Where the bar goes is its parent’s; a NebaPageLayout holds one it was handed as its footer at the bottom of the page unless it is static'
      }
    }),
    from('BottomNavigation', 'labels', {
      type: 'NebaBottomNavigationLabels',
      default: 'NebaBottomNavigationLabels.all'
    }),
    from('BottomNavigation', 'divider', { type: 'bool' }),
    from('BottomNavigation', 'safeArea', {
      type: 'bool',
      description: {
        ko: '아래와 양옆의 시스템 inset(홈 인디케이터, 노치)만큼 목적지를 안쪽으로 둡니다. 시트는 그 아래까지 그대로 닿습니다. static인 바에는 적용하지 않습니다',
        en: 'Keeps the destinations clear of the system insets on the bottom and the two sides: the home indicator, a notch. The sheet still runs under them. A static bar is left alone'
      }
    }),
    from('BottomNavigation', 'disabled', { type: 'bool' }),
    from('BottomNavigation', 'label', { type: 'String?' }),
    from('BottomNavigation', 'children', {
      type: 'List<NebaBottomNavigationItem<T>>',
      description: {
        ko: '목적지들. 각각 value로 이름이 붙습니다',
        en: 'The destinations, each named by its value'
      }
    })
  ],

  BottomNavigationItem: [
    from('BottomNavigationItem', 'value', { type: 'T' }),
    from('BottomNavigationItem', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: '이름 위의 글리프. 항목이 내려주는 IconTheme으로 아이콘 사다리의 크기가 됩니다',
        en: 'The glyph above the name, sized on the icon ladder through the IconTheme the item hands down'
      }
    }),
    from('BottomNavigationItem', 'href', {
      type: 'Uri?',
      description: {
        ko: '목적지가 가는 곳. screen reader와, 웹에서는 브라우저에 알리며 항목을 링크로 만듭니다. 이동은 onPressed나 바의 onValueChange의 몫입니다. scheme이 http, https, mailto, tel이 아니면 쓰지 않습니다',
        en: 'Where the destination leads, for a screen reader and, on the web, the browser. It makes the item a link; following it is onPressed’s or the bar’s onValueChange’s. A scheme other than http, https, mailto or tel is not written'
      }
    }),
    {
      name: 'newTab',
      type: 'bool',
      default: 'false',
      description: {
        ko: '링크가 앱 밖으로 나가는지. screen reader가 이름 뒤에 "(새 창에서 열림)"을 읽으며, 새 탭을 여는 일은 onPressed의 몫입니다. React의 target에 해당합니다',
        en: 'Whether the link leaves the app. A screen reader hears "(opens in a new tab)" after the name; opening the tab is onPressed’s. React’s target'
      }
    },
    from('BottomNavigationItem', 'disabled', { type: 'bool' }),
    renamed('BottomNavigationItem', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '목적지의 이름. 보통 Text이며, labels가 그리지 않을 때에도 그 글자가 읽힙니다. 다른 위젯이면 semanticLabel이 필요합니다',
        en: 'The destination’s name, usually a Text, whose words are read even when labels keeps it undrawn. Any other widget needs a semanticLabel for that'
      }
    }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '목적지를 눌렀을 때, 바가 그 목적지를 현재로 만든 다음에 호출됩니다. React의 onClick에 해당합니다',
        en: 'Called when the destination is pressed, after the bar has made it current. React’s onClick'
      }
    },
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
