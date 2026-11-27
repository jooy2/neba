import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateBlink: [
    from('AnimateBlink', 'min', { type: 'double' }),
    ...animateRows('AnimateBlink', {
      duration: 900,
      repeat: 'double.infinity',
      mode: false
    }),
    ...animateChildRows('AnimateBlink')
  ]
} satisfies Record<string, PropRow[]>;
