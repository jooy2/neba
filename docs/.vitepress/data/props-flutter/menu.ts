import { COLOR, densityRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

const ROWS = 'List<Widget>';

/** The rows a checkable row shares with a plain one, in Dart. */
function rowRows(component: string): PropRow[] {
  return [
    from(component, 'endIcon', { type: `${WIDGET}?` }),
    from(component, 'shortcut', {
      type: `${WIDGET}?`,
      description: {
        ko: '같은 일을 하는 단축키. Text나 NebaShortcut이며 행 끝에 흐리게 놓입니다. 표시만 하고 바인딩하지는 않습니다',
        en: 'The keystroke that does the same thing, a Text or a NebaShortcut, set muted at the end. Shown, never bound'
      }
    }),
    from(component, 'description', { type: `${WIDGET}?` }),
    from(component, 'color', { type: `${COLOR}?` }),
    from(component, 'disabled', { type: 'bool' }),
    from(component, 'label', {
      type: 'String?',
      description: {
        ko: '타이핑 검색이 맞춰 볼 문자열. child가 Text가 아닐 때',
        en: 'What typeahead matches against, when child is not a Text'
      }
    }),
    renamed(component, 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨. 보통 Text이며, 한 줄에서 넘치면 말줄임표로 잘립니다',
        en: 'The label, usually a Text, cut short with an ellipsis on one line'
      }
    })
  ];
}

export default {
  Menu: [
    from('Menu', 'trigger', {
      type: `${WIDGET}?`,
      description: {
        ko: '메뉴를 여는 위젯. NebaButton 같은 Neba 컨트롤이어야 하며, 누르면 자기 일을 하고 메뉴도 열고 닫습니다. 그 위에서 아래·위 방향키를 누르면 첫 행이나 마지막 행에서 열립니다. 다른 곳에서 여는 메뉴에는 필요 없습니다',
        en: 'What opens the menu: a Neba control such as a NebaButton, whose press does its own work and opens and closes the menu too. The Down and Up arrows on it open the menu at its first row and its last. Not needed for a menu opened elsewhere'
      }
    }),
    from('Menu', 'children', { type: ROWS }),
    from('Menu', 'open', { type: 'bool?' }),
    from('Menu', 'defaultOpen', { type: 'bool' }),
    from('Menu', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Menu', 'side', { type: 'NebaSide', default: 'NebaSide.bottom' }),
    from('Menu', 'align', { type: 'NebaAlign', default: 'NebaAlign.start' }),
    from('Menu', 'sideOffset', {
      type: 'double',
      description: {
        ko: '트리거와의 거리(논리 픽셀)',
        en: 'Distance from the trigger, in logical pixels'
      }
    }),
    from('Menu', 'modal', {
      type: 'bool',
      description: {
        ko: '열려 있는 동안 뒤 페이지를 가져갈지. 뒤 페이지를 누르면 메뉴만 닫힙니다. 트리거는 누를 수 있게 남아 있어 연 메뉴를 다시 닫을 수 있습니다',
        en: 'Whether the page behind is taken away while it is open: a press on it only closes the menu. The trigger stays pressable, so it can close what it opened'
      }
    }),
    from('Menu', 'openOnHover', { type: 'bool' }),
    from('Menu', 'loopFocus', { type: 'bool' }),
    from('Menu', 'disabled', {
      type: 'bool',
      description: {
        ko: '트리거가 메뉴를 열지 않게 합니다. 트리거는 호출하는 쪽의 위젯이라 그려진 모습은 그대로이므로 함께 비활성화하세요',
        en: 'Stops the trigger opening the menu. The trigger is your own widget and is drawn as it is, so disable it as well'
      }
    }),
    sizeRow('Menu'),
    from('Menu', 'color', { type: COLOR, default: 'NebaColor.primary' }),
    densityRow('Menu')
  ],

  MenuItem: [
    renamed('MenuItem', 'onClick', 'onPressed', {
      type: 'VoidCallback?',
      description: {
        ko: '행이 하는 일. 패키지는 아무것도 직접 열지 않으므로 링크인 행은 여기서 href를 따라갑니다. 없어도 고르면 메뉴가 닫히고, 막는 것은 disabled입니다',
        en: 'What the row does. The package opens nothing itself, so a row that is a link follows its href here. Without one the row still closes the menu when picked; disabled is what stops it'
      }
    }),
    from('MenuItem', 'href', {
      type: 'Uri?',
      description: {
        ko: '링크인 행이 가는 곳. screen reader와, 웹에서는 브라우저에 알리며 따라가는 일은 onPressed의 몫입니다. scheme이 http, https, mailto, tel이 아니면 쓰지 않고, 비활성인 동안에는 링크가 아닙니다',
        en: 'Where a row that is a link leads, for a screen reader and, on the web, the browser; following it is onPressed’s. A scheme other than http, https, mailto or tel is not written, and a disabled row is not a link'
      }
    }),
    renamed('MenuItem', 'target', 'newTab', {
      type: 'bool',
      default: 'false',
      description: {
        ko: '링크가 다른 곳에서 열리는지. screen reader가 라벨 뒤에 "(새 창에서 열림)"을 읽습니다. 여는 일은 onPressed의 몫입니다',
        en: 'Whether the link opens somewhere other than here. A screen reader hears "(opens in a new tab)" after the label; opening it is onPressed’s'
      }
    }),
    from('MenuItem', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨 앞의 내용. 행이 내려주는 IconTheme으로 글자 크기의 1.2배, 흐린 색이 됩니다',
        en: 'Content before the label, muted and at 1.2 times the text through the IconTheme the row hands down'
      }
    }),
    renamed('MenuItem', 'closeOnClick', 'closeOnPress', { type: 'bool' }),
    ...rowRows('MenuItem')
  ],

  MenuSubmenu: [
    from('MenuSubmenu', 'label', { type: `${WIDGET}?` }),
    from('MenuSubmenu', 'startIcon', { type: `${WIDGET}?` }),
    from('MenuSubmenu', 'side', { type: 'NebaSide?' }),
    from('MenuSubmenu', 'sideOffset', {
      type: 'double',
      description: {
        ko: '부모 메뉴와의 거리(논리 픽셀)',
        en: 'Distance from the parent menu, in logical pixels'
      }
    }),
    from('MenuSubmenu', 'disabled', { type: 'bool' }),
    from('MenuSubmenu', 'children', { type: ROWS })
  ],

  MenuGroup: [
    from('MenuGroup', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '그룹 위의 제목. 보통 Text이며 대문자로 그려지고, 쓴 그대로 그룹의 이름으로 읽힙니다',
        en: 'The heading over the group, usually a Text, drawn in capitals and read out as written as the group’s name'
      }
    }),
    from('MenuGroup', 'children', { type: ROWS })
  ],

  MenuCheckboxItem: [
    from('MenuCheckboxItem', 'checked', { type: 'bool?' }),
    from('MenuCheckboxItem', 'defaultChecked', { type: 'bool', default: 'false' }),
    from('MenuCheckboxItem', 'onCheckedChange', { type: 'ValueChanged<bool>?' }),
    renamed('MenuCheckboxItem', 'closeOnClick', 'closeOnPress', { type: 'bool' }),
    ...rowRows('MenuCheckboxItem')
  ],

  MenuRadioGroup: [
    from('MenuRadioGroup', 'value', { type: 'T?' }),
    from('MenuRadioGroup', 'defaultValue', { type: 'T?' }),
    from('MenuRadioGroup', 'onValueChange', { type: 'ValueChanged<T>?' }),
    from('MenuRadioGroup', 'disabled', { type: 'bool', default: 'false' }),
    from('MenuRadioGroup', 'children', { type: ROWS })
  ],

  MenuRadioItem: [
    from('MenuRadioItem', 'value', { type: 'T' }),
    renamed('MenuRadioItem', 'closeOnClick', 'closeOnPress', { type: 'bool' }),
    ...rowRows('MenuRadioItem')
  ],

  ContextMenu: [
    from('ContextMenu', 'content', { type: ROWS }),
    renamed('ContextMenu', 'children', 'child', {
      type: WIDGET,
      description: {
        ko: '오른쪽 클릭이나 길게 누르기에 반응할 영역. 메뉴가 없을 때와 똑같이 배치됩니다',
        en: 'The area that answers a right-click or a long press, laid out exactly as it would be without the menu'
      }
    }),
    from('ContextMenu', 'open', { type: 'bool?' }),
    from('ContextMenu', 'defaultOpen', { type: 'bool' }),
    from('ContextMenu', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('ContextMenu', 'disabled', { type: 'bool', default: 'false' }),
    from('ContextMenu', 'loopFocus', { type: 'bool' }),
    sizeRow('ContextMenu'),
    from('ContextMenu', 'color', { type: COLOR, default: 'NebaColor.primary' }),
    densityRow('ContextMenu')
  ]
} satisfies Record<string, PropRow[]>;
