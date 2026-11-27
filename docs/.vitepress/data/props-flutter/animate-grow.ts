import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateGrow: [
    from('AnimateGrow', 'from', { type: 'double' }),
    from('AnimateGrow', 'origin', {
      type: 'AlignmentGeometry',
      default: 'Alignment.center',
      description: {
        ko: '펼쳐지는 기준점. Alignment로 줍니다',
        en: 'Which point stays put while the rest moves: an Alignment'
      }
    }),
    from('AnimateGrow', 'fade', { type: 'bool' }),
    ...animateRows('AnimateGrow', { duration: 340 }),
    ...animateChildRows('AnimateGrow')
  ]
} satisfies Record<string, PropRow[]>;
