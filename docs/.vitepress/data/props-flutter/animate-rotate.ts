import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateRotate: [
    from('AnimateRotate', 'from', { type: 'double' }),
    from('AnimateRotate', 'to', { type: 'double' }),
    from('AnimateRotate', 'origin', {
      type: 'AlignmentGeometry',
      default: 'Alignment.center',
      description: {
        ko: '회전축. Alignment로 줍니다',
        en: 'Which point it turns about: an Alignment'
      }
    }),
    from('AnimateRotate', 'fade', { type: 'bool' }),
    ...animateRows('AnimateRotate', { duration: 460 }),
    ...animateChildRows('AnimateRotate')
  ]
} satisfies Record<string, PropRow[]>;
