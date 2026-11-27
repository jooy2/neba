import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateZoom: [
    from('AnimateZoom', 'from', { type: 'double' }),
    from('AnimateZoom', 'fade', { type: 'bool' }),
    ...animateRows('AnimateZoom', { duration: 340 }),
    ...animateChildRows('AnimateZoom')
  ]
} satisfies Record<string, PropRow[]>;
