import {
  COLOR,
  WIDGET,
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  type PropRow
} from './shared';

/** What leaving the app means for a link the package does not open itself. */
const newTabRow: PropRow = {
  name: 'newTab',
  type: 'bool',
  default: 'false',
  description: {
    ko: '링크가 앱을 떠나는지. 스크린 리더에 그렇게 알리며, 다른 곳에서 여는 일은 onPressed가 합니다. React의 target에 해당합니다',
    en: "Whether the link leaves the app. A screen reader is told so; opening it elsewhere is onPressed's. React's target"
  }
};

/** A press on a link, which the package does not open itself. */
function onPressedRow(ko: string, en: string): PropRow {
  return { name: 'onPressed', type: 'VoidCallback?', description: { ko, en } };
}

export default {
  Sources: [
    from('Sources', 'items', { type: 'List<NebaSourceItem>' }),
    from('Sources', 'title', { type: `${WIDGET}?` }),
    from('Sources', 'collapsible', { type: 'bool' }),
    from('Sources', 'open', {
      type: 'bool?',
      description: {
        ko: '목록이 열려 있는지. 직접 제어할 때 씁니다. null이면 defaultOpen에서 시작해 상태를 스스로 관리합니다',
        en: 'Whether the list is showing, for a controlled Sources. Left null, it keeps its own state, starting from defaultOpen'
      }
    }),
    from('Sources', 'defaultOpen', { type: 'bool' }),
    from('Sources', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    renamed('Sources', 'hiddenUntilFound', 'keepMounted', {
      type: 'bool',
      description: {
        ko: '접힌 목록의 줄을 빌드된 채로 남깁니다',
        en: 'Keeps the rows of a folded list built'
      }
    }),
    from('Sources', 'numbered', { type: 'bool' }),
    variantRow('Sources', 'NebaVariant.text'),
    sizeRow('Sources'),
    from('Sources', 'color', { type: `${COLOR}?`, default: 'NebaColor.primary' }),
    densityRow('Sources'),
    elevationRow('Sources'),
    from('Sources', 'locale', {
      type: 'Locale?',
      description: {
        ko: '제목과 링크의 새 탭 안내를 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것입니다',
        en: "Which language the heading and a link's new-tab notice are in. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Sources', 'labels', {
      type: 'Map<String, String>?',
      description: {
        ko: '그 단어를 직접 씁니다. 키는 title',
        en: 'That word, written out, under title'
      }
    })
  ],

  SourceItem: [
    from('SourceItem', 'title', { type: WIDGET }),
    from('SourceItem', 'href', {
      type: 'Uri?',
      description: {
        ko: '가리키는 곳. 스크린 리더와 웹의 브라우저에 알립니다. 스킴이 http, https, mailto, tel 중 하나가 아니면 링크를 걸지 않습니다',
        en: 'Where it points, for a screen reader and, on the web, the browser. A scheme outside http, https, mailto and tel leaves the row without a link'
      }
    }),
    onPressedRow(
      '제목을 눌렀을 때 할 일. 패키지는 스스로 아무것도 열지 않으며, 없으면 줄은 평범한 텍스트입니다',
      'What a press on the title does. The package opens nothing itself; left out, the row is plain text'
    ),
    from('SourceItem', 'description', { type: `${WIDGET}?` }),
    from('SourceItem', 'site', { type: `${WIDGET}?` }),
    from('SourceItem', 'icon', { type: `${WIDGET}?` }),
    from('SourceItem', 'index', { type: 'int?' }),
    newTabRow
  ]
} satisfies Record<string, PropRow[]>;
