import { from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  ScrollArea: [
    from('ScrollArea', 'orientation', {
      type: 'NebaScrollAreaOrientation',
      default: 'NebaScrollAreaOrientation.vertical'
    }),
    from('ScrollArea', 'height', {
      type: 'double?',
      description: {
        ko: '고정 높이(논리 픽셀). 세로 스크롤 영역은 무언가로 높이가 묶여야 스크롤할 것이 생깁니다',
        en: 'A fixed height, in logical pixels. A vertical scroll area has to be bounded by something or there is nothing to scroll'
      }
    }),
    from('ScrollArea', 'maxHeight', { type: 'double?' }),
    from('ScrollArea', 'fade', { type: 'bool' }),
    from('ScrollArea', 'label', {
      type: 'String?',
      description: {
        ko: '스크롤되는 내용이 무엇인지: "이용 약관", "활동". 없으면 화면 낭독기는 locale의 일반적인 말로 읽습니다',
        en: 'What the scrolling content is: "Terms of service", "Activity". Without it, a screen reader hears the locale\'s generic word'
      }
    }),
    from('ScrollArea', 'locale', {
      type: 'Locale?',
      default: "NebaProvider's, then the app's",
      description: {
        ko: '대체 이름의 언어. 등록하지 않은 언어는 영어로 돌아갑니다',
        en: 'Which language the fallback name is in. A language nobody registered falls back to English'
      }
    }),
    sizeRow('ScrollArea'),
    from('ScrollArea', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    {
      name: 'controller',
      type: 'ScrollController?',
      description: {
        ko: '세로 스크롤의 controller. horizontal 영역에서는 하나뿐인 스크롤의 것입니다',
        en: 'The controller of the vertical scroll, or of the only one in a horizontal area'
      }
    },
    {
      name: 'horizontalController',
      type: 'ScrollController?',
      description: {
        ko: 'both 영역에서 가로 스크롤의 controller',
        en: 'The controller of the horizontal scroll in a both area'
      }
    },
    renamed('ScrollArea', 'children', 'child', { type: WIDGET })
  ]
} satisfies Record<string, PropRow[]>;
