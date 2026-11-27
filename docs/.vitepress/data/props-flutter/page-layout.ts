import { from, renamed, WIDGET, type PropRow } from './shared';

export default {
  PageLayout: [
    from('PageLayout', 'header', {
      type: `${WIDGET}?`,
      description: {
        ko: '위를 가로지르는 바. 보통 NebaHeader이며, 레이아웃은 그 position을 읽어 위에 붙잡아 둘지 정합니다. 다른 위젯은 sticky header처럼 붙잡습니다',
        en: 'The bar across the top, usually a NebaHeader, whose position the layout reads to decide whether it holds it at the top. Anything else is held there as a sticky header is'
      }
    }),
    from('PageLayout', 'footer', {
      type: `${WIDGET}?`,
      description: {
        ko: '끝의 시트. 보통 NebaFooter이며, 레이아웃은 그 position을 읽습니다. 다른 위젯은 static footer처럼 페이지와 함께 스크롤됩니다',
        en: 'The sheet at the end, usually a NebaFooter, whose position the layout reads. Anything else scrolls with the page as a static footer does'
      }
    }),
    from('PageLayout', 'sidebar', { type: `${WIDGET}?` }),
    from('PageLayout', 'endSidebar', { type: `${WIDGET}?` }),
    from('PageLayout', 'headerSpan', {
      type: 'NebaPageLayoutSpan',
      default: 'NebaPageLayoutSpan.full'
    }),
    from('PageLayout', 'footerSpan', {
      type: 'NebaPageLayoutSpan',
      default: 'NebaPageLayoutSpan.full'
    }),
    from('PageLayout', 'scroll', {
      type: 'NebaPageLayoutScroll',
      default: 'NebaPageLayoutScroll.page',
      description: {
        ko: '무엇이 스크롤되는지. page는 페이지 전체가 스크롤되며 sticky header와 사이드바가 제자리를 지킵니다. content는 바 사이의 영역만 스크롤됩니다',
        en: 'What scrolls. page scrolls the whole page while a sticky header and the sidebars hold their places; content scrolls only the region between the bars'
      }
    }),
    from('PageLayout', 'height', {
      type: 'NebaPageLayoutHeight',
      default: 'NebaPageLayoutHeight.viewport',
      description: {
        ko: '레이아웃의 높이. viewport는 창 높이, auto는 부모가 정한 높이(미리보기나 큰 도구의 한 칸용), NebaPageLayoutHeight.pixels(320)은 그 논리 픽셀입니다',
        en: "How tall the layout is. viewport is the window's, auto is the one its parent bounds it to (a preview, a pane of a larger tool), and NebaPageLayoutHeight.pixels(320) is that many logical pixels"
      }
    }),
    from('PageLayout', 'collapseBelow', {
      type: 'NebaBreakpoint',
      default: 'NebaBreakpoint.md',
      description: {
        ko: '이 너비보다 좁아지면 사이드바가 열이 아니라 drawer가 되고, NebaSidebarTrigger가 그것을 여는 버튼이 됩니다. 어떤 너비도 그보다 좁지 않은 NebaBreakpoint.xs가 React의 none입니다',
        en: "The width below which the sidebars stop being columns and become drawers, with a NebaSidebarTrigger as the way to open them. NebaBreakpoint.xs, which no width is below, is React's none"
      }
    }),
    from('PageLayout', 'sidebarOpen', { type: 'bool?' }),
    from('PageLayout', 'defaultSidebarOpen', { type: 'bool' }),
    from('PageLayout', 'onSidebarOpenChange', { type: 'ValueChanged<bool>?' }),
    from('PageLayout', 'endSidebarOpen', { type: 'bool?' }),
    from('PageLayout', 'defaultEndSidebarOpen', { type: 'bool' }),
    from('PageLayout', 'onEndSidebarOpenChange', { type: 'ValueChanged<bool>?' }),
    from('PageLayout', 'skipLink', {
      type: 'bool',
      description: {
        ko: '포커스 순서의 맨 앞에 “본문으로 건너뛰기” 링크를 둡니다. focus를 받은 동안만 그려지고, 누르면 focus가 main 영역으로 갑니다',
        en: 'Puts a "Skip to content" link first in the focus order, drawn only while it holds the focus, which moves the focus to the main region'
      }
    }),
    from('PageLayout', 'skipLabel', { type: 'String?' }),
    from('PageLayout', 'main', {
      type: 'bool?',
      default: 'true',
      description: {
        ko: 'child를 main 영역에 넣고 앞에 skip link를 둘지. 다른 레이아웃의 본문 안에 있는 레이아웃은 따로 주지 않으면 꺼집니다. 화면의 main 영역은 하나여야 하기 때문입니다',
        en: "Whether the child is the main region with the skip link in front of it. Off by default for a layout inside another's content, since a screen has one main region"
      }
    }),
    from('PageLayout', 'locale', {
      type: 'Locale?',
      description: {
        ko: '레이아웃이 스스로 쓰는 단어의 언어. 안의 모든 NebaSidebar와 NebaSidebarTrigger가 물려받습니다. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language of the layout's own words, inherited by every NebaSidebar and NebaSidebarTrigger inside it. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('PageLayout', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    {
      name: 'controller',
      type: 'ScrollController?',
      description: {
        ko: '스크롤되는 것, 곧 페이지나 본문의 controller',
        en: 'The controller of what scrolls: the page, or the content'
      }
    },
    renamed('PageLayout', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
