import { colorRow, from, renamed, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Slider: [
    sizeRow('Slider'),
    colorRow('Slider'),
    from('Slider', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal',
      description: {
        ko: '트랙이 놓이는 방향. 세로 slider는 받은 높이를 쓰고, 제한이 없으면 160픽셀입니다',
        en: 'Which way the track runs. A vertical slider takes the height it is given, and 160 pixels where there is no limit'
      }
    }),
    from('Slider', 'value', {
      type: 'double?',
      description: {
        ko: '현재 값. onValueChange와 함께 주면 controlled가 되고, 주지 않으면 slider가 defaultValue에서 시작하는 자기 값을 둡니다',
        en: 'The current value, for a controlled slider with onValueChange. Leave it out and the slider keeps its own, starting from defaultValue'
      }
    }),
    from('Slider', 'defaultValue', { type: 'double?', default: 'min' }),
    from('Slider', 'onValueChange', { type: 'ValueChanged<double>?' }),
    from('Slider', 'onValueCommitted', { type: 'ValueChanged<double>?' }),
    renamed('Slider', 'value', 'values', {
      type: 'List<double>?',
      description: {
        ko: 'NebaSlider.range의 값. 항목마다 thumb이 하나씩 생기며, 정렬되고 범위 안으로 잡힙니다',
        en: "NebaSlider.range's values: one thumb per entry, sorted and held to the range"
      }
    }),
    renamed('Slider', 'defaultValue', 'defaultValues', {
      type: 'List<double>?',
      default: '[min, max]',
      description: {
        ko: 'uncontrolled NebaSlider.range의 초기 값',
        en: 'Where an uncontrolled NebaSlider.range starts'
      }
    }),
    renamed('Slider', 'onValueChange', 'onValuesChange', {
      type: 'ValueChanged<List<double>>?',
      description: {
        ko: 'NebaSlider.range의 onValueChange. 끄는 동안 계속 호출됩니다',
        en: "NebaSlider.range's onValueChange, called throughout the drag"
      }
    }),
    renamed('Slider', 'onValueCommitted', 'onValuesCommitted', {
      type: 'ValueChanged<List<double>>?',
      description: {
        ko: 'NebaSlider.range의 onValueCommitted. 값이 확정될 때 한 번만 호출됩니다',
        en: "NebaSlider.range's onValueCommitted, called once, when the values settle"
      }
    }),
    from('Slider', 'min', { type: 'double' }),
    from('Slider', 'max', { type: 'double' }),
    from('Slider', 'step', {
      type: 'double',
      description: {
        ko: 'thumb이 멈추는 간격. min에서부터 세며, 방향키 한 번이 움직이는 양이기도 합니다',
        en: 'The interval a thumb settles on, counted from min, and what an arrow key moves it by'
      }
    }),
    {
      name: 'largeStep',
      type: 'double',
      default: '10',
      description: {
        ko: 'Shift를 누른 방향키와 Page Up, Page Down이 thumb을 움직이는 양',
        en: 'What Shift with an arrow key, Page Up and Page Down move a thumb by'
      }
    },
    from('Slider', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '트랙 위의 라벨. 보통 Text이며, 누르면 thumb 하나짜리 slider는 focus가 thumb으로 가고, 화면 낭독기는 이것을 각 thumb의 이름으로 읽습니다',
        en: "The label above the track, usually a Text. A press on it puts the focus on a single slider's thumb, and a screen reader hears it as each thumb's name"
      }
    }),
    from('Slider', 'description', { type: `${WIDGET}?` }),
    from('Slider', 'showValue', {
      type: 'bool',
      description: {
        ko: '라벨 줄 끝에 현재 값을 보여 줍니다. 범위의 값은 대시로 이어지고, 글은 format이 씁니다',
        en: 'Shows the current value at the end of the label’s row, the values of a range joined by a dash and written by format'
      }
    }),
    {
      name: 'format',
      type: 'String Function(double value)?',
      description: {
        ko: '값을 글자로 쓰는 함수. showValue가 그리는 줄과 화면 낭독기가 읽는 값에 쓰이며, 단위나 통화를 앱이 쓰는 formatter와 언어로 씁니다. 없으면 세 자리마다 쉼표를 넣고 소수는 세 자리까지 씁니다',
        en: "Writes a value as text, for the row showValue draws and for what a screen reader hears: a unit or a currency, in the app's own formatter and language. Without it the number is grouped by threes, with at most three decimals"
      }
    },
    from('Slider', 'marks', {
      type: 'NebaSliderMarks?',
      default: undefined,
      description: {
        ko: '트랙에 표시하는 지점. NebaSliderMarks([...])는 NebaSliderMark(value:, label:) 목록이고, NebaSliderMarks.steps는 step마다 눈금 하나입니다',
        en: 'Points named along the track: NebaSliderMarks([...]) is a list of NebaSliderMark(value:, label:), and NebaSliderMarks.steps is a tick at every step'
      }
    }),
    renamed('Slider', 'getAriaLabel', 'thumbSemanticLabel', {
      type: 'String Function(int index)?'
    }),
    renamed('Slider', 'getAriaValueText', 'thumbSemanticValue', {
      type: 'String Function(String formatted, double value, int index)?'
    }),
    from('Slider', 'disabled', {
      type: 'bool',
      description: {
        ko: '사용 불가. disabled 토큰으로 그려지고 thumb이 focus 순서에서 빠집니다',
        en: 'Unavailable. Drawn in the disabled tokens, with the thumbs out of the focus order'
      }
    }),
    {
      ...semanticLabelRow,
      description: {
        ko: 'label 대신 화면 낭독기가 각 thumb을 부르는 이름. React의 `aria-label`에 해당합니다',
        en: "What a screen reader calls each thumb in place of label: React's `aria-label`"
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: {
        ko: '첫 thumb의 focus node. 포커스를 밖에서 다룰 때 넘깁니다',
        en: "The first thumb's focus node, when the caller drives the focus"
      }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '처음 그려질 때 첫 thumb이 focus를 가져갈지',
        en: 'Whether the first thumb takes the focus when it is first built'
      }
    }
  ]
} satisfies Record<string, PropRow[]>;
