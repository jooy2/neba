import {
  densityRow,
  elevationRow,
  focusRows,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

const locale = (component: string): PropRow =>
  from(component, 'locale', {
    type: 'Locale?',
    default: 'NebaPageLayout',
    description: {
      ko: '스스로 쓰는 단어의 언어. 기본값은 NebaPageLayout의 것, 그다음 NebaProvider의 것, 그다음 앱의 locale입니다',
      en: "The language of its own words. Defaults to the NebaPageLayout's, then NebaProvider's, then the app's"
    }
  });

export default {
  Sidebar: [
    renamed('Sidebar', 'children', 'child', { type: `${WIDGET}?` }),
    from('Sidebar', 'side', { type: 'NebaSidebarSide?', default: 'NebaSidebarSide.start' }),
    from('Sidebar', 'width', {
      type: 'double?',
      description: {
        ko: '열의 너비를 논리 픽셀로 줍니다. 없으면 size가 정한 너비입니다. resizable이면 시작 너비일 뿐입니다',
        en: 'How wide the column is, in logical pixels. Left out, it is the width size implies. With resizable it is only the width it starts at'
      }
    }),
    from('Sidebar', 'resizable', {
      type: 'bool',
      description: {
        ko: '안쪽 가장자리를 끌거나 화살표 키로 움직여 너비를 바꾸게 합니다. 잡는 영역은 가장자리 안쪽 8픽셀입니다',
        en: 'Lets the reader drag the inner edge, or move it with the arrow keys, to change the width. The handle is the 8 pixels inside the edge'
      }
    }),
    from('Sidebar', 'minWidth', { type: 'double' }),
    from('Sidebar', 'maxWidth', { type: 'double' }),
    from('Sidebar', 'onResize', { type: 'ValueChanged<double>?' }),
    from('Sidebar', 'onResizeEnd', { type: 'ValueChanged<double>?' }),
    from('Sidebar', 'collapseBelow', {
      type: 'NebaBreakpoint?',
      description: {
        ko: '이 너비보다 좁아지면 열이 drawer가 됩니다. 어떤 너비도 그보다 좁지 않은 NebaBreakpoint.xs는 언제나 열입니다. 기본값은 NebaPageLayout의 것이고, 레이아웃 밖에서는 NebaBreakpoint.xs입니다',
        en: "The window width below which the column becomes a drawer; NebaBreakpoint.xs, which no width is below, keeps it a column. Defaults to the NebaPageLayout's, and to NebaBreakpoint.xs outside one"
      }
    }),
    from('Sidebar', 'open', { type: 'bool?' }),
    from('Sidebar', 'defaultOpen', { type: 'bool' }),
    from('Sidebar', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Sidebar', 'keepMounted', {
      type: 'bool',
      description: {
        ko: '사이드바가 drawer로 접힌 뒤, 닫힌 drawer의 내용을 빌드된 채 남겨 state를 유지합니다. 열일 때는 아무것도 바꾸지 않습니다',
        en: 'Keeps the contents of the closed drawer built once the sidebar has collapsed into one, so they keep their state. Changes nothing about the column'
      }
    }),
    from('Sidebar', 'sticky', {
      type: 'bool?',
      description: {
        ko: 'NebaPageLayout이 페이지를 스크롤하는 동안 열이 제자리를 지키는지. 레이아웃 안에서는 켜져 있으며, 레이아웃 밖의 열은 다른 상자와 같습니다',
        en: "Whether the column holds its place while a NebaPageLayout's page scrolls past it. On inside a layout; a column outside one is a box like any other"
      }
    }),
    from('Sidebar', 'title', { type: `${WIDGET}?` }),
    variantRow('Sidebar', 'NebaVariant.outline'),
    sizeRow('Sidebar'),
    from('Sidebar', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Sidebar'),
    elevationRow('Sidebar'),
    from('Sidebar', 'divider', { type: 'bool' }),
    from('Sidebar', 'padded', { type: 'bool' }),
    from('Sidebar', 'label', { type: 'String?' }),
    locale('Sidebar'),
    {
      name: 'safeArea',
      type: 'bool',
      default: 'true',
      description: {
        ko: '열이나 drawer가 닿는 변의 시스템 inset만큼 내용을 안쪽으로 둡니다. NebaPageLayout은 열에 자기 쪽 변, 그리고 바가 없는 위나 아래의 inset을 넘깁니다',
        en: 'Keeps the content clear of the system insets on the edges the column or the drawer touches. A NebaPageLayout hands a column its own side, and the top or the bottom where no bar is'
      }
    }
  ],

  SidebarTrigger: [
    from('SidebarTrigger', 'side', { type: 'NebaSidebarSide', default: 'NebaSidebarSide.start' }),
    from('SidebarTrigger', 'collapseBelow', { type: 'NebaBreakpoint?' }),
    from('SidebarTrigger', 'icon', { type: `${WIDGET}?` }),
    from('SidebarTrigger', 'label', { type: 'String?' }),
    locale('SidebarTrigger'),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '누름이 drawer를 열거나 닫은 뒤에 호출됩니다',
        en: 'Called after the press has opened or closed the drawer'
      }
    },
    {
      name: 'variant',
      type: 'NebaVariant?',
      default: 'NebaVariant.text',
      shared: true,
      description: {
        ko: '버튼의 무게. 기본값은 NebaProvider의 것, 그다음 text입니다',
        en: "The weight of the button. Defaults to NebaProvider's, then text"
      }
    },
    {
      name: 'size',
      type: 'NebaSize?',
      shared: true,
      description: {
        ko: '버튼의 높이이자 너비',
        en: 'The height of the button, which is also its width'
      }
    },
    {
      name: 'color',
      type: 'NebaColor?',
      shared: true,
      description: { ko: '색 계열', en: 'The colour family' }
    },
    {
      name: 'elevation',
      type: 'NebaElevation?',
      shared: true,
      description: { ko: '그림자 깊이, 0에서 3', en: 'The drop shadow, from 0 to 3' }
    },
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
