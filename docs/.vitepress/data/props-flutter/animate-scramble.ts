import { animateRows, from, textAlignRow, textStyleRow, type PropRow } from './shared';

export default {
  AnimateScramble: [
    from('AnimateScramble', 'text', {
      type: 'String',
      required: true,
      description: { ko: '정착할 문자열', en: 'The text to settle' }
    }),
    textStyleRow,
    textAlignRow,
    from('AnimateScramble', 'speed', { type: 'double' }),
    from('AnimateScramble', 'tick', {
      type: 'Duration',
      default: 'Duration(milliseconds: 45)',
      description: {
        ko: '아직 정착하지 않은 글자를 다시 그리는 주기. 30ms 아래로 가면 글자로 읽히지 않습니다',
        en: 'How often an unsettled character is redrawn. Below about 30 milliseconds it stops reading as characters'
      }
    }),
    from('AnimateScramble', 'characters', { type: 'String?' }),
    from('AnimateScramble', 'duration', {
      type: 'Duration?',
      default: undefined,
      description: {
        ko: '전체 실행 시간. 주면 speed 대신 쓰이고, 글자 사이 간격은 여기서 나옵니다',
        en: 'The whole run. Given, it is used instead of speed, and the delay between characters falls out of it'
      }
    }),
    ...animateRows('AnimateScramble', {
      duration: 0,
      mode: false,
      omit: [
        'stagger',
        'durationStep',
        'reverse',
        'timeline',
        'range',
        'duration',
        'easing',
        'alternate',
        'repeat'
      ]
    }),
    from('AnimateScramble', 'repeat', {
      type: 'num',
      default: '1',
      description: {
        ko: '끝이 있는지입니다. double.infinity면 화면 밖에서 멈추고, hover로 재생할 때 포인터가 떠나면 멈췄다가 다음 hover에 다시 흩어집니다',
        en: 'Whether it ends: a double.infinity one holds off the screen and, under trigger hover, stops when the pointer leaves, so the next hover scrambles it again'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
