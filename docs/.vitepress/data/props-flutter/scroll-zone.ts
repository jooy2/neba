import {
  colorRow,
  densityRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  ScrollZone: [
    from('ScrollZone', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('ScrollZone', 'lines', { type: 'int' }),
    from('ScrollZone', 'spacing', {
      type: 'double',
      description: {
        ko: '자식 사이의 간격. 스페이싱 스케일이며 2는 8 논리 픽셀로, GridContainer의 spacing과 같은 사다리입니다',
        en: "The gap between children, on the spacing scale: 2 is 8 logical pixels, the same ladder GridContainer's spacing is on"
      }
    }),
    from('ScrollZone', 'buttons', {
      type: 'NebaScrollZoneButtons',
      default: 'NebaScrollZoneButtons.auto',
      description: {
        ko: '스크롤 버튼을 언제 그릴지. auto는 전부 들어맞으면 둘 다 그리지 않고, 끝에서는 overlay 버튼을 지우되 자리를 지키는 inline 버튼은 disabled로 남깁니다. always는 첫 프레임부터 늘 둘 다, none은 아예 그리지 않습니다',
        en: 'When the scroll buttons are drawn. auto draws neither while everything fits and, at an end, removes an overlay button but disables an inline one, whose lane is held open either way. always is both from the first frame, none is neither'
      }
    }),
    from('ScrollZone', 'buttonPlacement', {
      type: 'NebaScrollZoneButtonPlacement',
      default: 'NebaScrollZoneButtonPlacement.inline'
    }),
    from('ScrollZone', 'mode', { type: 'NebaScrollZoneMode', default: 'NebaScrollZoneMode.item' }),
    from('ScrollZone', 'step', { type: 'int' }),
    from('ScrollZone', 'speed', {
      type: 'double',
      description: {
        ko: 'hold 모드에서 초당 스크롤되는 논리 픽셀',
        en: 'How fast a held button scrolls, in logical pixels a second'
      }
    }),
    from('ScrollZone', 'snap', { type: 'bool' }),
    from('ScrollZone', 'drag', {
      type: 'bool',
      description: {
        ko: '마우스로도 끌어서 스크롤합니다. 손가락, 스타일러스, 트랙패드는 이미 스크롤 뷰 자신의 제스처로 끌 수 있습니다',
        en: "Lets a mouse drag the strip along, the way a finger, a stylus and a trackpad already do through the scroll view's own gesture"
      }
    }),
    from('ScrollZone', 'wheel', { type: 'bool' }),
    from('ScrollZone', 'scrollbar', {
      type: 'bool',
      description: {
        ko: '앱의 ScrollBehavior가 그리는 플랫폼 스크롤바를 보입니다. 기본 ScrollBehavior는 데스크톱에서만 그립니다',
        en: "Shows the platform's scrollbar, as the app's ScrollBehavior draws it. The default behavior draws one on desktop platforms only"
      }
    }),
    variantRow('ScrollZone'),
    sizeRow('ScrollZone'),
    colorRow('ScrollZone'),
    densityRow('ScrollZone'),
    from('ScrollZone', 'locale', {
      type: 'Locale?',
      default: "NebaProvider's, then the app's",
      description: {
        ko: '버튼과 영역이 자기 이름을 말하는 언어. 등록하지 않은 언어는 영어로 돌아갑니다',
        en: 'Which language the buttons and the region name themselves in. A language nobody registered falls back to English'
      }
    }),
    from('ScrollZone', 'label', {
      type: 'String?',
      description: {
        ko: '스크롤 영역의 이름, "Categories", "Recent files". 없으면 화면 낭독기는 locale의 일반적인 말로 읽습니다',
        en: 'What the scrollable region is called: "Categories", "Recent files". Without it, a screen reader hears the locale\'s generic word'
      }
    }),
    from('ScrollZone', 'previousLabel', { type: 'String?' }),
    from('ScrollZone', 'nextLabel', { type: 'String?' }),
    renamed('ScrollZone', 'scrollerRef', 'controller', {
      type: 'ScrollController?',
      description: {
        ko: '띠의 스크롤 controller. 스크롤 위치를 읽거나 되돌릴 때 씁니다',
        en: "The strip's scroll controller, to read or restore its position through"
      }
    }),
    from('ScrollZone', 'onScroll', {
      type: 'ValueChanged<ScrollMetrics>?',
      description: {
        ko: '띠가 스크롤될 때마다 그 위치를 담은 ScrollMetrics와 함께 호출됩니다',
        en: 'Called whenever the strip scrolls, with its ScrollMetrics'
      }
    }),
    from('ScrollZone', 'children', {
      type: `List<${WIDGET}>`,
      description: {
        ko: '배치할 것들. 자식 하나가 스트립의 칸 하나입니다',
        en: "What is being laid out. Each child is one cell of the strip's grid"
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
