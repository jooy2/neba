import {
  colorRow,
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

export default {
  List: [
    variantRow('List', 'NebaVariant.outline'),
    sizeRow('List'),
    colorRow('List'),
    densityRow('List'),
    elevationRow('List'),
    from('List', 'dividers', { type: 'bool' }),
    from('List', 'spacing', {
      type: 'double?',
      description: {
        ko: '행 사이의 간격. 간격 스케일이라 1은 4 논리 픽셀입니다. 주지 않으면 행이 맞닿습니다. dividers가 있으면 선이 행을 나누므로 무시됩니다',
        en: 'The gap between the rows, on the spacing scale: 1 is 4 logical pixels. Left out, the rows touch. Ignored with dividers, where the rule is what separates the rows'
      }
    }),
    from('List', 'children', {
      type: `List<${WIDGET}>`,
      required: true,
      description: { ko: '행. 보통 NebaListItem입니다', en: 'The rows, usually NebaListItems' }
    })
  ],

  ListItem: [
    from('ListItem', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨 앞 내용, 아이콘, 아바타, 상태 점. 행이 내려주는 IconTheme으로 라벨 크기의 1.2배, 흐린 색이 됩니다',
        en: 'Content before the label: an icon, an avatar, a status dot, muted and at 1.2 times its size through the IconTheme the row hands down'
      }
    }),
    from('ListItem', 'endIcon', { type: `${WIDGET}?` }),
    from('ListItem', 'description', { type: `${WIDGET}?` }),
    from('ListItem', 'action', {
      type: `${WIDGET}?`,
      description: {
        ko: '행 끝에 고정되는 컨트롤, 스위치, 메뉴 버튼. 누를 수 있는 영역 바깥이라 눌러도 행이 눌리지 않습니다',
        en: 'A control pinned to the end of the row. Outside the pressable area, so pressing it never presses the row'
      }
    }),
    renamed('ListItem', 'onClick', 'onPressed', {
      type: 'VoidCallback?',
      description: {
        ko: '넘기면 행이 버튼이 되고, href가 있으면 링크가 됩니다',
        en: 'Passing it turns the row into a button, or a link when it has an href'
      }
    }),
    from('ListItem', 'href', {
      type: 'Uri?',
      description: {
        ko: '행이 가는 곳. screen reader와, 웹에서는 브라우저에 알리며 누를 수 있는 행을 링크로 만듭니다. 이동은 onPressed의 몫입니다. scheme이 http, https, mailto, tel이 아니면 쓰지 않습니다',
        en: 'Where the row leads, for a screen reader and, on the web, the browser. It makes a pressable row a link; following it is onPressed’s. A scheme other than http, https, mailto or tel is not written'
      }
    }),
    from('ListItem', 'selected', {
      type: 'bool',
      description: {
        ko: '고른 행, 열려 있는 페이지, 켜진 필터. 목록의 색 계열로 물들고, screen reader에는 선택된 행으로 읽힙니다',
        en: 'The chosen row: the open page, the current filter. It is tinted in the list’s family, and a screen reader hears it as selected'
      }
    }),
    from('ListItem', 'disabled', { type: 'bool' }),
    renamed('ListItem', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨. 보통 Text이며, 한 줄에서 넘치면 말줄임표로 잘립니다',
        en: 'The label, usually a Text, cut short with an ellipsis on one line'
      }
    }),
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
