import { colorRow, elevationRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  WindowPane: [
    from('WindowPane', 'os', { type: 'NebaWindowOs?', default: 'NebaWindowOs.macos' }),
    from('WindowPane', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목표시줄에 놓이는 창의 이름. Text이면 화면 낭독기에게 창의 이름이 되기도 합니다',
        en: 'The window’s name, in the title bar. A Text also names the window for a screen reader'
      }
    }),
    from('WindowPane', 'icon', { type: `${WIDGET}?` }),
    from('WindowPane', 'actions', { type: `${WIDGET}?` }),
    from('WindowPane', 'controls', {
      type: 'Set<NebaWindowControl>',
      default: 'all three',
      description: {
        ko: '제목표시줄에 둘 버튼의 집합. 빈 집합은 없음입니다. 순서는 집합이 아니라 시스템이 정합니다. macOS는 닫기를 맨 앞에, Windows는 맨 뒤에 둡니다',
        en: 'Which buttons the title bar has; an empty set is none. The order is the system’s rather than the set’s: macOS puts close first and Windows puts it last'
      }
    }),
    sizeRow('WindowPane'),
    colorRow('WindowPane'),
    from('WindowPane', 'accent', { type: 'bool' }),
    from('WindowPane', 'transparency', { type: 'double' }),
    from('WindowPane', 'active', { type: 'bool?' }),
    elevationRow('WindowPane', '2'),
    from('WindowPane', 'position', {
      type: 'NebaWindowPanePosition',
      default: 'NebaWindowPanePosition.static',
      description: {
        ko: '창이 놓이는 방식. static은 흐름 안에 두고 offset이 주변의 아무것도 옮기지 않게 하며, absolute는 창을 담은 Stack 안에, fixed는 가장 가까운 Overlay에 화면을 기준으로 놓습니다',
        en: 'How the window is laid out. static leaves it in the flow, where offset moves nothing around it; absolute places it in the Stack it is a child of; fixed places it on the screen in the nearest Overlay'
      }
    }),
    from('WindowPane', 'draggable', { type: 'bool' }),
    from('WindowPane', 'resizable', { type: 'bool' }),
    from('WindowPane', 'width', {
      type: 'double?',
      description: {
        ko: '창의 너비. 생략하면 부모가 허락하는 만큼, Stack 안에서는 내용만큼 넓습니다',
        en: 'The window’s width. Left out, as wide as its parent allows, or as wide as what is in it inside a Stack'
      }
    }),
    from('WindowPane', 'height', { type: 'double?' }),
    from('WindowPane', 'minWidth', { type: 'double' }),
    from('WindowPane', 'minHeight', { type: 'double?' }),
    from('WindowPane', 'offset', { type: 'Offset?' }),
    from('WindowPane', 'defaultOffset', { type: 'Offset', default: 'Offset.zero' }),
    from('WindowPane', 'onOffsetChange', { type: 'ValueChanged<Offset>?' }),
    from('WindowPane', 'onResize', {
      type: 'ValueChanged<Size>?',
      description: {
        ko: '가장자리를 끄는 동안 창의 크기와 함께 호출됩니다',
        en: 'Called with the window’s size while an edge is dragged'
      }
    }),
    from('WindowPane', 'open', {
      type: 'bool?',
      description: {
        ko: '창이 화면에 있는지. 닫힌 창은 서서히 흐려진 뒤 아무것도 그리지 않습니다',
        en: 'Whether the window is on screen at all. A closed window fades out and then draws nothing'
      }
    }),
    from('WindowPane', 'defaultOpen', { type: 'bool' }),
    from('WindowPane', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('WindowPane', 'minimized', { type: 'bool?' }),
    from('WindowPane', 'defaultMinimized', { type: 'bool' }),
    from('WindowPane', 'onMinimizedChange', { type: 'ValueChanged<bool>?' }),
    from('WindowPane', 'maximized', { type: 'bool?' }),
    from('WindowPane', 'defaultMaximized', { type: 'bool' }),
    from('WindowPane', 'onMaximizedChange', { type: 'ValueChanged<bool>?' }),
    from('WindowPane', 'scroll', {
      type: 'bool',
      description: {
        ko: '창보다 긴 내용이 스크롤되는지. 끄면 내용은 창의 높이를 정확히 받으므로, 창을 가득 채우는 child는 이쪽을 씁니다',
        en: 'Whether content taller than the window scrolls. Off, the content is given the window’s height exactly, which a child that fills the window wants'
      }
    }),
    from('WindowPane', 'locale', {
      type: 'Locale?',
      default: 'NebaProvider',
      description: {
        ko: '제목표시줄의 버튼들이 이름을 대는 언어. 생략하면 NebaProvider의 것, 그다음 앱의 것을 따릅니다',
        en: 'Which language the title bar’s buttons name themselves in. Left out, NebaProvider’s and then the app’s'
      }
    }),
    from('WindowPane', 'minimizeLabel', { type: 'String?' }),
    from('WindowPane', 'maximizeLabel', { type: 'String?' }),
    from('WindowPane', 'restoreLabel', { type: 'String?' }),
    from('WindowPane', 'closeLabel', { type: 'String?' }),
    from('WindowPane', 'resizeLabel', { type: 'String?' }),
    {
      name: 'semanticLabel',
      type: 'String?',
      description: {
        ko: '화면 낭독기가 부르는 창의 이름. Text인 title보다 우선합니다',
        en: 'The name a screen reader announces for the window, over a Text title'
      }
    },
    renamed('WindowPane', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
