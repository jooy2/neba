import { colorRow, densityRow, from, sizeRow, variantRow, WIDGET, type PropRow } from './shared';

export default {
  Transfer: [
    variantRow('Transfer', 'NebaVariant.outline'),
    sizeRow('Transfer'),
    colorRow('Transfer'),
    densityRow('Transfer'),
    from('Transfer', 'items', { type: 'List<NebaTransferItem<T>>' }),
    from('Transfer', 'value', {
      type: 'List<T>?',
      description: {
        ko: '오른쪽에 있는 것들. null이면 transfer가 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: 'What is on the right. Left null, the transfer keeps its own state from defaultValue'
      }
    }),
    from('Transfer', 'defaultValue', { type: 'List<T>?' }),
    from('Transfer', 'onValueChange', { type: 'ValueChanged<List<T>>?' }),
    from('Transfer', 'sourceLabel', { type: `${WIDGET}?` }),
    from('Transfer', 'targetLabel', { type: `${WIDGET}?` }),
    from('Transfer', 'searchable', { type: 'bool' }),
    from('Transfer', 'height', {
      type: 'double',
      description: {
        ko: '각 목록의 높이(논리 픽셀)',
        en: 'How tall each list is, in logical pixels'
      }
    }),
    from('Transfer', 'disabled', { type: 'bool' }),
    from('Transfer', 'locale', {
      type: 'Locale?',
      description: {
        ko: '제목, 화살표, 필터, 옮긴 뒤 화면 낭독기에 알리는 문장을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language of the headings, the arrows, the filter and what a screen reader is told after a move. Defaults to NebaProvider's, then the app's"
      }
    })
  ],

  TransferItem: [
    from('TransferItem', 'value', { type: 'T' }),
    from('TransferItem', 'label', {
      type: WIDGET,
      description: {
        ko: '행에 쓰이는 말. 보통 Text이며, Text이면 검색도 이것과 맞춰 봅니다. 다른 위젯인 행은 어떤 검색에도 남습니다',
        en: 'What the row says, usually a Text, which is also what a search matches. A row with any other widget stays through every search'
      }
    }),
    from('TransferItem', 'disabled', { type: 'bool' })
  ]
} satisfies Record<string, PropRow[]>;
