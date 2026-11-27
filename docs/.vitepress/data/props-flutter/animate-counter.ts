import { from, textStyleRow, type PropRow } from './shared';

export default {
  AnimateCounter: [
    from('AnimateCounter', 'value', { type: 'num' }),
    from('AnimateCounter', 'from', { type: 'num' }),
    from('AnimateCounter', 'duration', {
      type: 'Duration',
      default: 'Duration(milliseconds: 1200)',
      description: { ko: '세는 데 걸리는 시간', en: 'How long the count takes' }
    }),
    from('AnimateCounter', 'delay', {
      type: 'Duration',
      default: 'Duration.zero',
      description: {
        ko: '첫 카운트 전 대기 시간',
        en: 'How long the first count waits'
      }
    }),
    from('AnimateCounter', 'format', {
      type: 'String Function(num)?',
      description: {
        ko: '숫자를 문자열로 쓰는 함수. 생략하면 세 자리마다 쉼표를 찍고 소수점 아래는 세 자리까지 씁니다. 세는 동안 넘어가는 숫자는 value와 from 중 소수 자릿수가 많은 쪽에 맞춰 반올림되어 있습니다',
        en: 'How the number is written, as a function. Left out, its thousands are grouped and it has at most three digits after the point. While it counts, the number it is handed keeps the decimal places of value or from, whichever has more'
      }
    }),
    textStyleRow,
    from('AnimateCounter', 'trigger', {
      type: 'NebaAnimateTrigger',
      default: 'NebaAnimateTrigger.mount'
    }),
    from('AnimateCounter', 'play', {
      type: 'Object?',
      description: {
        ko: 'trigger가 manual일 때 세기 시작합니다. bool이나 숫자를 받고, 숫자가 바뀌면 처음부터 다시 셉니다. false, 0, null이면 멈춰 있습니다',
        en: 'Runs it when trigger is manual: a bool, or a number that starts it over each time it changes; false, 0 and null hold it'
      }
    }),
    from('AnimateCounter', 'once', { type: 'bool' }),
    from('AnimateCounter', 'threshold', { type: 'double' })
  ]
} satisfies Record<string, PropRow[]>;
