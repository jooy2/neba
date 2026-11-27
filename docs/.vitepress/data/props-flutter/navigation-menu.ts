import {
  COLOR,
  densityRow,
  focusRows,
  from,
  semanticLabelRow,
  sizeRow,
  WIDGET,
  type PropRow
} from './shared';

/** A link item's and a panel link's new-tab notice: React's `target`. */
const newTabRow: PropRow = {
  name: 'newTab',
  type: 'bool',
  default: 'false',
  description: {
    ko: '링크가 앱 밖으로 나가는지. screen reader가 이름 뒤에 "(새 창에서 열림)"을 읽으며, 새 탭을 여는 일은 onPressed의 몫입니다. React의 target에 해당합니다',
    en: 'Whether the link leaves the app. A screen reader hears "(opens in a new tab)" after the name; opening the tab is onPressed’s. React’s target'
  }
};

const hrefDescription = {
  ko: '가는 곳. screen reader와, 웹에서는 브라우저에 알립니다. 이동은 onPressed의 몫입니다. scheme이 http, https, mailto, tel이 아니면 쓰지 않습니다',
  en: 'Where it goes, for a screen reader and, on the web, the browser; following it is onPressed’s. A scheme other than http, https, mailto or tel is not written'
};

export default {
  NavigationMenu: [
    sizeRow('NavigationMenu'),
    from('NavigationMenu', 'color', { type: COLOR, default: 'NebaColor.primary' }),
    densityRow('NavigationMenu'),
    from('NavigationMenu', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('NavigationMenu', 'value', {
      type: 'String?',
      description: {
        ko: '어느 항목의 패널이 열려 있는지 (controlled). null로 두면 메뉴가 상태를 직접 가지며 defaultValue에서 시작하고, controlled 값이 null이 되면 패널이 닫힙니다',
        en: 'Which item’s panel is open, by its value, for a controlled menu. Left null, the menu keeps its own state from defaultValue, and a controlled value that turns null closes the panel'
      }
    }),
    from('NavigationMenu', 'defaultValue', { type: 'String?' }),
    from('NavigationMenu', 'onValueChange', {
      type: 'ValueChanged<String?>?',
      description: {
        ko: '열린 항목이 바뀔 때마다 그 value로, 패널이 닫히면 null로 호출됩니다',
        en: 'Fired whenever the open item changes, with its value, and with null once the panel closes'
      }
    }),
    from('NavigationMenu', 'delay', { type: 'Duration', default: 'Duration(milliseconds: 50)' }),
    from('NavigationMenu', 'closeDelay', {
      type: 'Duration',
      default: 'Duration(milliseconds: 50)'
    }),
    from('NavigationMenu', 'sideOffset', { type: 'double', default: '8' }),
    from('NavigationMenu', 'children', { type: 'List<Widget>' }),
    semanticLabelRow
  ],

  NavigationMenuItem: [
    from('NavigationMenuItem', 'label', {
      type: WIDGET,
      description: {
        ko: '줄에 놓이는 단어. 보통 Text입니다',
        en: 'The word in the row, usually a Text'
      }
    }),
    from('NavigationMenuItem', 'href', {
      type: 'Uri?',
      description: {
        ko: 'children이 없는 항목이 가는 곳. 그런 항목은 목적지로 안내되는 링크입니다. screen reader와, 웹에서는 브라우저에 알리며, scheme이 http, https, mailto, tel이 아니면 쓰지 않습니다. children이 있으면 쓰이지 않고, debug 빌드에서 경고합니다',
        en: 'Where an item with no children goes; such an item is a link and is announced as one. It tells a screen reader and, on the web, the browser, and a scheme other than http, https, mailto or tel is not written. With children it is not used, and a debug build warns'
      }
    }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: 'children이 없는 항목을 눌렀을 때 하는 일. 패키지는 아무것도 직접 열지 않으므로 router나 URL launcher를 여기서 부릅니다. null이면 링크처럼 그려지지만 아무 일도 하지 않고 focus도 받지 않습니다',
        en: 'What an item with no children does when pressed. The package opens nothing itself, so this calls the router or a URL launcher. With null it is drawn as a link that does nothing and takes no focus'
      }
    },
    newTabRow,
    from('NavigationMenuItem', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '단어 앞의 내용. 단어 크기의 1.2배입니다',
        en: 'Content before the word, at 1.2 times its size'
      }
    }),
    from('NavigationMenuItem', 'value', {
      type: 'String?',
      description: {
        ko: 'controlled 메뉴에서 이 항목을 식별하는 값. 생략하면 항목이 스스로 만든 식별자를 가지며, onValueChange는 그 값을 보고합니다',
        en: 'Identifies the item, for a controlled menu. Left out, the item has an identity of its own, which is what onValueChange reports for it'
      }
    }),
    from('NavigationMenuItem', 'disabled', {
      type: 'bool',
      description: {
        ko: '사용 불가. 단어는 줄에 남고 아무것도 열지 않습니다. 패널을 여는 항목은 focus 순서에 남고, 링크 항목은 링크가 아니게 됩니다',
        en: 'Unavailable. The word stays in the row and opens nothing; an item that opens a panel keeps its place in the focus order, and a link item is not a link'
      }
    }),
    from('NavigationMenuItem', 'columns', { type: 'int' }),
    from('NavigationMenuItem', 'children', {
      type: 'List<Widget>',
      default: 'const <Widget>[]'
    }),
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: {
        ko: '포커스를 밖에서 다룰 때 넘기는 노드',
        en: 'Drives the focus from outside'
      }
    }
  ],

  NavigationMenuLink: [
    from('NavigationMenuLink', 'title', {
      type: WIDGET,
      description: { ko: '행의 이름. 보통 Text입니다', en: "The row's name, usually a Text" }
    }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      required: true,
      description: {
        ko: '링크가 하는 일. 패키지는 아무것도 직접 열지 않으므로 router나 URL launcher를 여기서 부릅니다. null이면 링크처럼 그려지지만 아무 일도 하지 않고 focus도 받지 않습니다',
        en: 'What the link does. The package opens nothing itself, so this calls the router or a URL launcher. With null it is drawn as a link that does nothing and takes no focus'
      }
    },
    from('NavigationMenuLink', 'href', {
      type: 'Uri?',
      required: false,
      description: hrefDescription
    }),
    from('NavigationMenuLink', 'description', { type: `${WIDGET}?` }),
    from('NavigationMenuLink', 'startIcon', { type: `${WIDGET}?` }),
    newTabRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
