import { animateRows, from, textAlignRow, textStyleRow, type PropRow } from './shared';

export default {
  AnimateSplit: [
    from('AnimateSplit', 'text', {
      type: 'String',
      required: true,
      description: { ko: '쪼갤 문자열', en: 'The text to split' }
    }),
    textStyleRow,
    textAlignRow,
    from('AnimateSplit', 'by', { type: 'NebaSplitBy', default: 'NebaSplitBy.word' }),
    from('AnimateSplit', 'effect', { type: 'NebaAnimation', default: 'NebaAnimation.slide' }),
    from('AnimateSplit', 'from', { type: 'NebaSide', default: 'NebaSide.bottom' }),
    from('AnimateSplit', 'distance', {
      type: 'double?',
      default: undefined,
      description: {
        ko: 'slide 조각의 이동 거리(논리 픽셀). 생략하면 글자 크기의 10분의 4입니다',
        en: 'How far a slide piece travels, in logical pixels. Left out, four tenths of the font size'
      }
    }),
    from('AnimateSplit', 'scale', { type: 'double?' }),
    from('AnimateSplit', 'angle', { type: 'double?' }),
    from('AnimateSplit', 'side', { type: 'NebaSide?' }),
    from('AnimateSplit', 'stagger', {
      type: 'Duration',
      default: 'Duration(milliseconds: 45)',
      description: {
        ko: '한 조각 뒤 다음 조각이 시작하기까지의 간격. 0이어도 각 조각이 저마다 효과를 재생합니다',
        en: 'How long after one piece the next one starts. Even at zero, each piece runs the effect on its own'
      }
    }),
    ...animateRows('AnimateSplit', { duration: 520, mode: false, omit: ['stagger', 'repeat'] }),
    from('AnimateSplit', 'repeat', {
      type: 'num?',
      default: undefined,
      description: {
        ko: '반복 횟수. 생략하면 한 번이고, effect가 blink이면 double.infinity입니다',
        en: 'How many times it runs. Left out, once, and double.infinity with a blink effect'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
