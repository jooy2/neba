import {
  colorRow,
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  TreeView: [
    variantRow('TreeView', 'NebaVariant.outline'),
    sizeRow('TreeView'),
    colorRow('TreeView'),
    densityRow('TreeView'),
    elevationRow('TreeView'),
    from('TreeView', 'lines', {
      type: 'NebaTreeViewLines',
      default: 'NebaTreeViewLines.simple'
    }),
    from('TreeView', 'expanded', {
      type: 'List<T>?',
      description: {
        ko: '열려 있는 가지들의 value. onExpandedChange와 함께 쓰면 controlled가 되고, null이면 트리가 defaultExpanded에서 시작해 상태를 스스로 관리합니다',
        en: 'The values of the open branches. With onExpandedChange it makes the tree controlled; left null, the tree keeps its own state from defaultExpanded'
      }
    }),
    from('TreeView', 'defaultExpanded', { type: 'List<T>?' }),
    from('TreeView', 'onExpandedChange', {
      type: 'ValueChanged<List<T>>?',
      description: {
        ko: '가지가 열리거나 닫힌 뒤, 열려 있는 가지들의 value로 호출됩니다. value가 없는 행은 빠집니다',
        en: 'Called with the values of the open branches after one opens or shuts. A row with no value is left out'
      }
    }),
    from('TreeView', 'selected', { type: 'List<T>?' }),
    from('TreeView', 'defaultSelected', { type: 'List<T>?' }),
    from('TreeView', 'onSelectedChange', {
      type: 'ValueChanged<List<T>>?',
      description: {
        ko: '행이 선택된 뒤, 선택된 행들의 value로 호출됩니다',
        en: 'Called with the values of the chosen rows after a row is chosen'
      }
    }),
    from('TreeView', 'multiple', {
      type: 'bool',
      description: {
        ko: '여러 행을 동시에 선택할 수 있는지. 켜면 선택할 수 있는 행마다 선택되었는지 아닌지를 화면 낭독기에 알립니다',
        en: 'Whether more than one row may be chosen at a time. On, every row that can be chosen tells a screen reader whether it is'
      }
    }),
    from('TreeView', 'disabled', { type: 'bool' }),
    from('TreeView', 'label', {
      type: 'String?',
      description: {
        ko: '화면 낭독기가 트리를 부르는 이름',
        en: 'The name a screen reader announces the tree by'
      }
    }),
    from('TreeView', 'keepMounted', {
      type: 'bool',
      description: {
        ko: '닫힌 가지의 행을 빌드된 채로 두어 상태를 지킵니다. 닫혀 있는 동안 focus 순서, 방향키가 지나가는 행, 화면 낭독기가 듣는 내용에서는 빠집니다',
        en: 'Keeps the rows of a shut branch built, so their state survives being folded away. While it is shut they stay out of the focus order, the rows the arrow keys walk and what a screen reader hears'
      }
    }),
    from('TreeView', 'children', {
      type: 'List<NebaTreeItem<T>>',
      description: {
        ko: '최상위 행들. 위젯이 아니라 NebaTreeItem의 리스트입니다',
        en: 'The top-level rows, as a list of NebaTreeItem rather than widgets'
      }
    })
  ],

  TreeItem: [
    from('TreeItem', 'value', {
      type: 'T?',
      description: {
        ko: 'expanded와 selected에서 이 행을 가리키는 값. 생략하면 트리가 행의 자리로 이름을 붙입니다. 그런 행도 열고 닫고 선택할 수 있지만, 트리가 알리는 목록에서는 빠집니다',
        en: 'Names the row to expanded and selected. Left out, the tree names it by its place; such a row opens, shuts and is chosen, and is left out of the lists the tree reports'
      }
    }),
    from('TreeItem', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '행의 텍스트. 보통 Text이며 한 줄에서 넘치면 말줄임표로 잘립니다. Text이면 글자 입력으로 행을 찾을 때도 이것과 맞춰 봅니다',
        en: "The row's text, usually a Text, cut short with an ellipsis on one line. A Text is also what typing a letter matches"
      }
    }),
    from('TreeItem', 'startIcon', { type: `${WIDGET}?` }),
    from('TreeItem', 'endIcon', { type: `${WIDGET}?` }),
    from('TreeItem', 'action', { type: `${WIDGET}?` }),
    from('TreeItem', 'href', {
      type: 'Uri?',
      description: {
        ko: '행이 가리키는 주소. 화면 낭독기와, 웹에서는 브라우저에 알립니다. 행을 링크로 만들며, 따라가는 일은 onPressed가 합니다. http, https, mailto, tel 말고 다른 scheme은 쓰지 않습니다',
        en: "Where the row leads, for a screen reader and, on the web, the browser. It makes the row a link; following it is onPressed's. A scheme other than http, https, mailto or tel is not written"
      }
    }),
    renamed('TreeItem', 'onClick', 'onPressed', {
      type: 'VoidCallback?',
      description: {
        ko: '행을 누를 때, 열리거나 선택되기 전에 호출됩니다',
        en: 'Called when the row is pressed, before it opens or is chosen'
      }
    }),
    from('TreeItem', 'expandable', { type: 'bool?', default: 'children.isNotEmpty' }),
    from('TreeItem', 'disabled', { type: 'bool' }),
    from('TreeItem', 'selectable', { type: 'bool' }),
    from('TreeItem', 'children', {
      type: 'List<NebaTreeItem<T>>',
      default: 'const []',
      description: { ko: '이 행 아래의 행들', en: 'The rows underneath this one' }
    })
  ]
} satisfies Record<string, PropRow[]>;
