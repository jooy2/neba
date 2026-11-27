import { animateRows, colorRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  AnimateLighting: [
    from('AnimateLighting', 'glow', {
      type: 'Color?',
      description: {
        ko: '의미론적 색이 아닌 임의의 색. color보다 우선합니다',
        en: 'A colour of your own, when a semantic family is not what is wanted. Overrides color'
      }
    }),
    from('AnimateLighting', 'spread', {
      type: 'double',
      description: {
        ko: '내용 바깥으로 빛이 번지는 거리(논리 픽셀)',
        en: 'How far past the content the light reaches, in logical pixels'
      }
    }),
    from('AnimateLighting', 'arc', { type: 'double' }),
    from('AnimateLighting', 'blur', {
      type: 'double',
      description: {
        ko: '빛의 부드러움(논리 픽셀). 0이면 빛이 아니라 도형처럼 보입니다',
        en: 'How soft the light is, in logical pixels. At 0 it reads as a graphic rather than as light'
      }
    }),
    from('AnimateLighting', 'reverse', { type: 'bool' }),
    sizeRow('AnimateLighting'),
    { ...colorRow('AnimateLighting'), type: 'NebaColor' },
    ...animateRows('AnimateLighting', {
      duration: 3000,
      mode: false,
      repeat: 'double.infinity',
      omit: ['stagger', 'durationStep', 'reverse', 'timeline', 'range', 'easing']
    }),
    renamed('AnimateLighting', 'children', 'child', {
      type: WIDGET,
      required: true
    })
  ]
} satisfies Record<string, PropRow[]>;
