import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateFade: [
    from('AnimateFade', 'from', { type: 'double' }),
    ...animateRows('AnimateFade', { duration: 320 }),
    ...animateChildRows('AnimateFade')
  ]
} satisfies Record<string, PropRow[]>;
