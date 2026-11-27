import { COLOR, densityRow, from, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Menubar: [
    sizeRow('Menubar'),
    from('Menubar', 'color', { type: COLOR, default: 'NebaColor.primary' }),
    densityRow('Menubar'),
    from('Menubar', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('Menubar', 'modal', {
      type: 'bool',
      description: {
        ko: '열린 메뉴가 뒤 페이지를 가져가는지 여부. 뒤 페이지를 누르면 메뉴만 닫힙니다. 바는 빠져 있어 포인터가 계속 건너갈 수 있습니다',
        en: 'Whether an open menu takes the page away: a press on it only closes the menu. The bar itself is left out, so the pointer can still cross it'
      }
    }),
    from('Menubar', 'loopFocus', { type: 'bool' }),
    from('Menubar', 'disabled', { type: 'bool' }),
    from('Menubar', 'children', { type: 'List<Widget>' }),
    semanticLabelRow
  ],

  MenubarMenu: [
    from('MenubarMenu', 'label', {
      type: WIDGET,
      description: {
        ko: '바 위에 놓이는 단어. 보통 Text이며, 그 글이 타이핑 검색에도 쓰입니다',
        en: 'The word on the bar, usually a Text, whose words typeahead matches against too'
      }
    }),
    from('MenubarMenu', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '단어 앞의 내용. 단어 크기의 1.2배입니다',
        en: 'Content before the word, at 1.2 times its size'
      }
    }),
    from('MenubarMenu', 'disabled', {
      type: 'bool',
      description: {
        ko: '사용 불가. 단어는 바에 남고 아무것도 열지 않으며, 방향키는 이 단어를 건너뜁니다',
        en: 'Unavailable. The word stays on the bar and opens nothing, and the arrow keys pass over it'
      }
    }),
    from('MenubarMenu', 'children', { type: 'List<Widget>' })
  ]
} satisfies Record<string, PropRow[]>;
