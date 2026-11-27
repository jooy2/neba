import { animateChildRows, animateRows, from, type PropRow } from './shared';

export default {
  AnimateSlide: [
    from('AnimateSlide', 'from', { type: 'NebaSide', default: 'NebaSide.bottom' }),
    from('AnimateSlide', 'distance', {
      type: 'double?',
      default: undefined,
      description: {
        ko: '이동 거리(논리 픽셀). 생략하면 위젯 자신의 너비나 높이만큼입니다',
        en: "How far it travels, in logical pixels. Left out, it is the widget's own width or height"
      }
    }),
    from('AnimateSlide', 'fade', { type: 'bool' }),
    ...animateRows('AnimateSlide', { duration: 380 }),
    ...animateChildRows('AnimateSlide')
  ]
} satisfies Record<string, PropRow[]>;
