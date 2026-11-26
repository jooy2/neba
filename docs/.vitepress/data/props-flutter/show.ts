import { from, renamed, WIDGET, type PropRow } from './shared';

export default {
  Show: [
    from('Show', 'above', { type: 'NebaBreakpoint?' }),
    from('Show', 'below', {
      type: 'NebaBreakpoint?',
      description: {
        ko: 'child가 보이기를 멈추는 창의 너비. 이 값을 포함하지 않으므로 같은 breakpoint의 above와 정확히 짝이 되어 모든 너비를 한 번씩 덮습니다. NebaBreakpoint.xs는 아무 데서도 보이지 않습니다',
        en: 'The window width at which the child stops being shown, exclusive, so it pairs with above at the same breakpoint to cover every width exactly once. NebaBreakpoint.xs shows it nowhere'
      }
    }),
    renamed('Show', 'children', 'child', {
      type: WIDGET,
      description: {
        ko: '어떤 창 너비에서 보일지가 정해지는 것. 숨겨진 동안에는 빌드되지 않습니다',
        en: 'What is shown at some window widths and not others. It is not built while it is hidden'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
