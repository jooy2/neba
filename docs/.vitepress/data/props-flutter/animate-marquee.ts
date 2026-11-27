import { animateRows, from, WIDGET, type PropRow } from './shared';

export default {
  AnimateMarquee: [
    from('AnimateMarquee', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('AnimateMarquee', 'reverse', { type: 'bool' }),
    from('AnimateMarquee', 'speed', {
      type: 'double',
      description: {
        ko: '초당 이동하는 논리 픽셀. 시간이 아니라 속도이므로, 짧은 띠와 긴 띠가 같은 속도로 흐릅니다',
        en: 'How fast the content travels, in logical pixels per second. A speed rather than a duration, so a short strip and a long one move at the same pace'
      }
    }),
    from('AnimateMarquee', 'gap', {
      type: 'double',
      default: '32',
      description: {
        ko: '항목 사이, 그리고 한 바퀴의 끝과 다음 시작 사이의 간격(논리 픽셀)',
        en: 'The gap between items, and between the last item and the first of the next pass, in logical pixels'
      }
    }),
    from('AnimateMarquee', 'copies', { type: 'int' }),
    from('AnimateMarquee', 'pauseOnHover', { type: 'bool' }),
    from('AnimateMarquee', 'duration', {
      type: 'Duration?',
      default: undefined,
      description: {
        ko: '한 바퀴에 걸리는 시간. 주면 speed로 계산한 값보다 우선합니다',
        en: 'How long one lap takes, over the one speed works out'
      }
    }),
    ...animateRows('AnimateMarquee', {
      duration: 0,
      mode: false,
      repeat: 'double.infinity',
      curve: 'Curves.linear',
      omit: ['stagger', 'durationStep', 'reverse', 'timeline', 'range', 'duration']
    }),
    from('AnimateMarquee', 'children', {
      type: `List<${WIDGET}>`,
      required: true
    })
  ]
} satisfies Record<string, PropRow[]>;
