import { animateChildRows, animateRows, from, WIDGET, type PropRow } from './shared';

export default {
  AnimateAppear: [
    from('AnimateAppear', 'from', { type: 'NebaSide', default: 'NebaSide.bottom' }),
    from('AnimateAppear', 'distance', {
      type: 'double',
      default: '12',
      description: {
        ko: '각 자식의 이동 거리(논리 픽셀). 화면 밖에서 들어오는 것이 아니라 제자리에 내려앉는 정도로 짧습니다',
        en: 'How far each child travels, in logical pixels. Short on purpose: this is a settling, not an entrance from off screen'
      }
    }),
    from('AnimateAppear', 'fade', { type: 'bool' }),
    from('AnimateAppear', 'stagger', {
      type: 'Duration',
      default: 'Duration(milliseconds: 80)',
      description: {
        ko: '한 자식 뒤 다음 자식이 시작하기까지의 간격. 0이어도 각 자식이 저마다 효과를 재생합니다',
        en: 'How long after one child the next one starts. Even at zero, each child runs the effect on its own'
      }
    }),
    ...animateRows('AnimateAppear', { duration: 420, mode: false, omit: ['stagger'] }),
    ...animateChildRows('AnimateAppear').filter((row) => row.name === 'layoutBuilder'),
    from('AnimateAppear', 'children', { type: `List<${WIDGET}>`, required: true })
  ]
} satisfies Record<string, PropRow[]>;
