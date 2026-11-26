import { from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  AspectRatio: [
    from('AspectRatio', 'ratio', {
      type: 'double',
      description: {
        ko: '상자가 지키는 비율. 너비를 높이로 나눈 값으로, 16 / 9처럼 적습니다',
        en: 'The proportion the box holds, width over height, written as 16 / 9'
      }
    }),
    from('AspectRatio', 'fit', {
      type: 'BoxFit',
      default: 'BoxFit.cover',
      description: {
        ko: '자식이 Image일 때 상자에 맞추는 방식. 그 밖의 자식은 상자에 맞게 늘어난 뒤 스스로 배치합니다',
        en: 'How a child that is an Image is fitted to the box. Any other child is stretched to the box and lays its own content out'
      }
    }),
    from('AspectRatio', 'rounded', { type: 'bool' }),
    sizeRow('AspectRatio'),
    renamed('AspectRatio', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
