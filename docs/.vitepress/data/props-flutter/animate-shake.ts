import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateShake: [
    ...animateRows('AnimateShake', {
      duration: 420,
      curve: 'Curves.easeInOut',
      trigger: 'NebaAnimateTrigger.manual',
      mode: false
    }),
    from('AnimateShake', 'distance', {
      type: 'double',
      description: {
        ko: '가장 크게 흔들릴 때의 이동 거리(논리 픽셀)',
        en: 'How far it travels at the widest point, in logical pixels'
      }
    }),
    ...animateChildRows('AnimateShake')
  ]
} satisfies Record<string, PropRow[]>;
