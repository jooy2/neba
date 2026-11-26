import { from, transitionRow, type PropRow } from './shared';

export default {
  Typography: [
    from('Typography', 'children', {
      name: 'data',
      type: 'String',
      description: {
        ko: '텍스트. 첫 번째 인자로 받으며, 여러 스타일이 섞인 텍스트는 NebaTypography.rich에 InlineSpan으로 넘깁니다',
        en: 'The text, as the first argument. Text in more than one style goes to NebaTypography.rich as an InlineSpan'
      }
    }),
    from('Typography', 'level', {
      type: 'NebaTypographyLevel',
      default: 'NebaTypographyLevel.body',
      description: {
        ko: '타입 스케일과 화면 낭독기가 듣는 제목 단계. variant라고 부르지 않는 것은 그 말이 이미 표면의 무게를 뜻하기 때문입니다',
        en: 'The type scale, and the heading level a screen reader hears. Not called variant: that word already means the weight of a surface here'
      }
    }),
    from('Typography', 'color', { type: 'NebaColor?' }),
    from('Typography', 'weight', { type: 'FontWeight?' }),
    from('Typography', 'align', {
      type: 'TextAlign?',
      description: { ko: '텍스트 정렬', en: 'Text alignment' }
    }),
    from('Typography', 'lines', { type: 'int?' }),
    from('Typography', 'gutter', {
      type: 'bool',
      description: {
        ko: '아래 여백을 더합니다. 기본은 꺼짐입니다. 여백을 스스로 넣는 위젯은 레이아웃이 맞서 싸워야 하는 위젯이기 때문입니다',
        en: 'Adds the space below. Off by default: a widget that brings its own margin is one a layout has to fight'
      }
    }),
    {
      name: 'headingLevel',
      type: 'int?',
      default: "the level's",
      description: {
        ko: '화면 낭독기가 듣는 제목 단계. 1부터 6, 제목이 아니면 0. 크기는 바꾸지 않으며 React의 render에 해당합니다',
        en: "The heading level a screen reader hears, 1 to 6, or 0 for none. It leaves the scale alone: React's render"
      }
    },
    {
      name: 'style',
      type: 'TextStyle?',
      description: {
        ko: 'level의 스타일 위에 얹는 스타일. 크기를 바꾸면 행간과 자간이 비율대로 따라옵니다',
        en: "A style laid over the level's. A size set here keeps the leading and the tracking in proportion"
      }
    },
    {
      name: 'semanticsLabel',
      type: 'String?',
      description: {
        ko: '텍스트 대신 화면 낭독기가 읽는 말',
        en: 'What a screen reader hears instead of the text'
      }
    },
    transitionRow('Typography', 'const NebaTransition.fade()')
  ]
} satisfies Record<string, PropRow[]>;
