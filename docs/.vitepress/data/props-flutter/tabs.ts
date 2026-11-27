import {
  colorRow,
  densityRow,
  from,
  renamed,
  semanticLabelRow,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Tabs: [
    variantRow('Tabs', 'NebaVariant.outline'),
    sizeRow('Tabs'),
    colorRow('Tabs'),
    densityRow('Tabs'),
    from('Tabs', 'value', {
      type: 'T?',
      description: {
        ko: '선택된 탭의 value. controlled 세트에 씁니다. null이면 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: "The chosen tab's value, for a controlled set. Left null, the set keeps its own state, starting from defaultValue"
      }
    }),
    from('Tabs', 'defaultValue', { type: 'T?' }),
    from('Tabs', 'onValueChange', { type: 'ValueChanged<T?>?' }),
    from('Tabs', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('Tabs', 'activateOnFocus', { type: 'bool' }),
    from('Tabs', 'loopFocus', { type: 'bool' }),
    from('Tabs', 'overflow', { type: 'NebaTabsOverflow', default: 'NebaTabsOverflow.scroll' }),
    from('Tabs', 'lines', { type: 'int?' }),
    from('Tabs', 'wheel', { type: 'bool' }),
    from('Tabs', 'fullWidth', {
      type: 'bool',
      description: {
        ko: '가로 바의 탭들이 바의 폭을 똑같이 나눠 갖습니다. 라벨이 제 몫보다 넓은 탭은 제 폭을 지킵니다',
        en: 'The tabs of a horizontal bar share its width equally, unless a label needs more than its share'
      }
    }),
    from('Tabs', 'align', { type: 'NebaAlign', default: 'NebaAlign.center' }),
    from('Tabs', 'keepMounted', {
      type: 'bool',
      description: {
        ko: '선택되지 않은 패널을 숨긴 채 빌드된 상태로 남겨, 다시 고를 때까지 안의 상태를 지킵니다. 패널에 직접 준 keepMounted가 우선합니다',
        en: "Keeps every unchosen panel built and hidden, so its state survives being switched away from. A panel's own keepMounted still wins"
      }
    }),
    from('Tabs', 'children', {
      type: `List<${WIDGET}>`,
      description: {
        ko: 'NebaTab과 NebaTabPanel. NebaTabPanel은 패널 자리로, 나머지는 바로 알아서 나뉩니다',
        en: 'The NebaTabs and the NebaTabPanels. A NebaTabPanel goes to the panel area and everything else to the bar, so there is no list wrapper to remember'
      }
    }),
    {
      ...semanticLabelRow,
      description: {
        ko: '화면 낭독기가 탭 바를 부르는 이름',
        en: 'What a screen reader calls the tab bar'
      }
    }
  ],

  Tab: [
    from('Tab', 'value', { type: 'T' }),
    from('Tab', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨 앞의 내용. 탭이 내려주는 IconTheme으로 라벨 크기의 1.2배가 됩니다',
        en: 'Content before the label, drawn at 1.2 times its size through the IconTheme the tab hands down'
      }
    }),
    from('Tab', 'endIcon', { type: `${WIDGET}?` }),
    from('Tab', 'disabled', {
      type: 'bool',
      description: {
        ko: '사용 불가. 목록에 남고 화살표 키로도 닿지만 선택되지 않습니다',
        en: 'Unavailable, but still listed: the arrow keys still reach it, and it is never chosen'
      }
    }),
    renamed('Tab', 'children', 'child', { type: `${WIDGET}?` }),
    {
      ...semanticLabelRow,
      description: {
        ko: '라벨 대신 화면 낭독기가 읽는 이름. 이 탭이 가리키는 패널의 이름도 됩니다',
        en: 'What a screen reader hears in place of the label, and calls the panel the tab picks out'
      }
    }
  ],

  TabPanel: [
    from('TabPanel', 'value', { type: 'T' }),
    from('TabPanel', 'keepMounted', {
      type: 'bool?',
      description: {
        ko: '탭이 선택되지 않은 동안에도 빌드된 채로 숨겨 두어 안의 상태를 지킵니다. 만들기 비싼 내용이나 살아 있어야 하는 폼 상태에 씁니다. null이면 Tabs의 값을 따릅니다',
        en: 'Keeps the panel built and hidden while its tab is not chosen, so its state survives. For content that is expensive to build, or form state that should survive. Left null, it follows the Tabs'
      }
    }),
    renamed('TabPanel', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
