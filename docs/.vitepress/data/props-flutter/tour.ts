import { densityRow, from, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Tour: [
    from('Tour', 'steps', { type: 'List<NebaTourStep>' }),
    from('Tour', 'open', {
      type: 'bool?',
      description: {
        ko: 'tour가 실행 중인지. onOpenChange와 함께 쓰면 controlled가 되고, null이면 tour가 상태를 직접 가지며 defaultOpen에서 시작합니다',
        en: 'Whether the tour is running. With onOpenChange it is controlled; left null, the tour keeps its own state from defaultOpen'
      }
    }),
    from('Tour', 'defaultOpen', { type: 'bool' }),
    from('Tour', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Tour', 'step', {
      type: 'int?',
      description: {
        ko: '몇 번째 정거장인지 (0부터). null이면 tour가 직접 가지며 defaultStep에서 시작합니다',
        en: 'Which stop, from 0. Left null, the tour keeps its own from defaultStep'
      }
    }),
    from('Tour', 'defaultStep', { type: 'int' }),
    from('Tour', 'onStepChange', { type: 'ValueChanged<int>?' }),
    from('Tour', 'onFinish', { type: 'VoidCallback?' }),
    from('Tour', 'mask', { type: 'bool' }),
    from('Tour', 'skippable', { type: 'bool' }),
    from('Tour', 'dismissible', {
      type: 'bool',
      description: {
        ko: 'Escape와 ×로 tour를 끝낼 수 있는지. 끄면 자기 버튼으로만 끝납니다',
        en: 'Whether Escape and the × end the tour. Off, it is left only through its own buttons'
      }
    }),
    from('Tour', 'scrollIntoView', {
      type: 'bool',
      description: {
        ko: '각 단계에 이를 때 대상을 화면 가운데로 스크롤할지. 움직임을 줄인 독자에게는 바로 이동합니다',
        en: 'Scrolls each target to the middle of its scroll view as the tour reaches it; a reader who asked for less motion gets the jump'
      }
    }),
    sizeRow('Tour'),
    from('Tour', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Tour'),
    from('Tour', 'locale', {
      type: 'Locale?',
      description: {
        ko: '버튼과 카운터를 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language the buttons and the counter are written in. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Tour', 'previousLabel', { type: `${WIDGET}?` }),
    from('Tour', 'nextLabel', { type: `${WIDGET}?` }),
    from('Tour', 'doneLabel', { type: `${WIDGET}?` }),
    from('Tour', 'skipLabel', { type: `${WIDGET}?` }),
    from('Tour', 'closeLabel', { type: 'String?' })
  ],

  TourStep: [
    from('TourStep', 'target', {
      type: 'GlobalKey?',
      description: {
        ko: '이 단계가 가리키는 위젯을, 그 위젯을 만들 때 준 key로 지목합니다. React의 CSS selector에 해당합니다. 없거나 아직 만들어지지 않았으면 아무것도 도려내지 않은 채 창 가운데에 놓입니다',
        en: 'The widget this step is about, by the key it is built with: React’s CSS selector. Left out, or not built, the step is centred over the window with nothing cut out'
      }
    }),
    from('TourStep', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '단계의 제목. 보통 Text이며, 그 글이 screen reader에게 카드의 이름이 됩니다',
        en: 'The step’s heading, usually a Text, whose words also name the card for a screen reader'
      }
    }),
    from('TourStep', 'content', { type: `${WIDGET}?` }),
    from('TourStep', 'side', { type: 'NebaSide', default: 'NebaSide.bottom' }),
    from('TourStep', 'align', { type: 'NebaAlign', default: 'NebaAlign.center' }),
    from('TourStep', 'padding', { type: 'double' })
  ]
} satisfies Record<string, PropRow[]>;
