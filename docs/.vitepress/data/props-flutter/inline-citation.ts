import { COLOR, WIDGET, from, sizeRow, type PropRow } from './shared';

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
  InlineCitation: [
    from('InlineCitation', 'index', { type: 'int' }),
    from('InlineCitation', 'title', { type: `${WIDGET}?` }),
    from('InlineCitation', 'description', { type: `${WIDGET}?` }),
    from('InlineCitation', 'site', { type: `${WIDGET}?` }),
    from('InlineCitation', 'href', {
      type: 'Uri?',
      description: {
        ko: '가리키는 곳. 스크린 리더와 웹의 브라우저에 알립니다. 스킴이 http, https, mailto, tel 중 하나가 아니면 링크를 걸지 않습니다',
        en: 'Where it points, for a screen reader and, on the web, the browser. A scheme outside http, https, mailto and tel leaves the mark without a link'
      }
    }),
    onPressedRow(
      '표시나 미리보기 제목을 눌렀을 때 할 일. 없으면 표시는 링크가 아니며, 열 미리보기가 있을 때만 focus를 받습니다',
      'What a press on the mark or the preview’s title does. Left out, the mark is no link, and takes the focus only when it has a preview to open'
    ),
    newTabRow,
    from('InlineCitation', 'preview', { type: 'bool' }),
    sizeRow('InlineCitation'),
    from('InlineCitation', 'color', { type: `${COLOR}?`, default: 'NebaColor.primary' }),
    from('InlineCitation', 'locale', {
      type: 'Locale?',
      description: {
        ko: '표시의 이름을 말할 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것입니다',
        en: "Which language the mark's name is said in. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('InlineCitation', 'labels', {
      type: 'Map<String, String>?',
      description: {
        ko: '그 문장을 직접 씁니다. 키는 citation이고 {index}가 들어갑니다',
        en: 'That sentence, written out, under citation, with an {index} in it'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
