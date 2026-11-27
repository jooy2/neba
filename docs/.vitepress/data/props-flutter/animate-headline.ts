import { animateRows, from, WIDGET, type PropRow } from './shared';

export default {
  AnimateHeadline: [
    from('AnimateHeadline', 'interval', {
      type: 'Duration',
      default: 'Duration(milliseconds: 2600)',
      description: {
        ko: '한 줄이 머무는 시간. 줄이 도착한 순간부터 세므로 읽는 시간입니다',
        en: 'How long each line is held. Counted from the moment a line arrives, so it is reading time'
      }
    }),
    from('AnimateHeadline', 'index', { type: 'int?' }),
    from('AnimateHeadline', 'defaultIndex', { type: 'int' }),
    from('AnimateHeadline', 'onIndexChange', { type: 'ValueChanged<int>?' }),
    from('AnimateHeadline', 'loop', { type: 'bool' }),
    from('AnimateHeadline', 'rise', {
      type: 'double?',
      default: undefined,
      description: {
        ko: '한 줄이 올라오거나 나가며 이동하는 거리(논리 픽셀). 생략하면 한 줄 자신의 높이입니다',
        en: "How far a line travels as it comes up or leaves, in logical pixels. Left out, one line's own height"
      }
    }),
    ...animateRows('AnimateHeadline', {
      duration: 480,
      mode: false,
      omit: ['stagger', 'durationStep', 'reverse', 'timeline', 'range', 'alternate', 'repeat']
    }),
    from('AnimateHeadline', 'repeat', {
      type: 'num',
      default: 'double.infinity',
      description: {
        ko: '줄을 몇 번 돌리는지가 아니라(그것은 loop) 끝이 있는지입니다. double.infinity면 화면 밖에서 멈추고, hover로 재생하면 포인터가 떠날 때 멈춥니다',
        en: 'Not how many times the reel turns, which is loop, but whether it ends: a double.infinity one holds off the screen and, under trigger hover, stops when the pointer leaves'
      }
    }),
    from('AnimateHeadline', 'children', {
      type: `List<${WIDGET}>`,
      required: true
    })
  ]
} satisfies Record<string, PropRow[]>;
