import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateFloat: [
    ...animateRows('AnimateFloat', {
      duration: 3200,
      curve: 'Curves.easeInOut',
      repeat: 'double.infinity',
      alternate: 'true',
      mode: false
    }),
    from('AnimateFloat', 'from', { type: 'NebaSide', default: 'NebaSide.top' }),
    from('AnimateFloat', 'distance', {
      type: 'double',
      default: '8',
      description: {
        ko: '드리프트 정점까지의 거리(논리 픽셀)',
        en: 'How far, at the top of the drift, in logical pixels'
      }
    }),
    ...animateChildRows('AnimateFloat')
  ]
} satisfies Record<string, PropRow[]>;
