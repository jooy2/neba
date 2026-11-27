import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateReveal: [
    ...animateRows('AnimateReveal', { duration: 620 }),
    from('AnimateReveal', 'side', { type: 'NebaSide', default: 'NebaSide.left' }),
    from('AnimateReveal', 'from', { type: 'double' }),
    ...animateChildRows('AnimateReveal')
  ]
} satisfies Record<string, PropRow[]>;
