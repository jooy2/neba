import {
  colorRow,
  densityRow,
  elevationRow,
  from,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  HowToSteps: [
    from('HowToSteps', 'steps', { type: 'List<NebaHowToStep>' }),
    from('HowToSteps', 'title', { type: `${WIDGET}?` }),
    from('HowToSteps', 'headingLevel', {
      type: 'int',
      description: {
        ko: 'screen reader에게 title이 몇 단계 heading인지, 2부터 5까지. 단계의 제목은 그보다 한 단계 아래이고, title이 없으면 이 단계를 그대로 씁니다',
        en: "The heading level a screen reader hears title at, from 2 to 5, with a step's title one below it, or at this level when there is no title"
      }
    }),
    from('HowToSteps', 'step', {
      type: 'int?',
      description: {
        ko: '지금 보이는 단계. 직접 몰고 갈 때 onStepChange와 함께 넘깁니다. null이면 defaultStep에서 시작해 스스로 관리합니다',
        en: 'Which step is showing. Pass it with onStepChange to drive the guide yourself; left null, it keeps its own, starting from defaultStep'
      }
    }),
    from('HowToSteps', 'defaultStep', { type: 'int' }),
    from('HowToSteps', 'onStepChange', { type: 'ValueChanged<int>?' }),
    from('HowToSteps', 'completed', {
      type: 'bool?',
      description: {
        ko: '끝났는지. 이것도 직접 몰고 갈 수 있고, null이면 defaultCompleted에서 시작해 스스로 관리합니다',
        en: 'Whether the guide is finished. Controllable too; left null, it keeps its own, starting from defaultCompleted'
      }
    }),
    from('HowToSteps', 'defaultCompleted', { type: 'bool' }),
    from('HowToSteps', 'onCompletedChange', { type: 'ValueChanged<bool>?' }),
    from('HowToSteps', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.vertical',
      description: {
        ko: '목록이 흐르는 방향. vertical은 번호가 옆으로 내려가고 본문이 그 옆에 놓이며, 창 너비가 sm breakpoint보다 좁으면 쌓입니다. horizontal은 위쪽에 가로로 늘어놓는데, 제목이 짧을 때에만 정직합니다',
        en: 'Which way the list runs. vertical puts the numbers down one side with the body beside them, stacking on a window narrower than the sm breakpoint; horizontal runs them across the top, and is only honest while every title is short'
      }
    }),
    from('HowToSteps', 'maxHeight', {
      type: 'double?',
      description: {
        ko: '스크롤이 시작되기 전까지 커질 수 있는 높이(논리 픽셀). 시트가 커지는 대신 목록과 본문이 각자 스크롤되고, 현재 행은 보이는 자리로 따라옵니다',
        en: 'How tall the guide may get before it scrolls, in logical pixels. The list and the body scroll inside it rather than the sheet growing, and the current row is kept in view'
      }
    }),
    from('HowToSteps', 'railWidth', {
      type: 'double',
      default: '240',
      description: {
        ko: '목록이 본문 옆의 열일 때의 너비(논리 픽셀). divider와 그 여백을 포함합니다',
        en: 'How wide the list is while it is a column beside the body, in logical pixels, the divider and its gutter included'
      }
    }),
    from('HowToSteps', 'navigation', { type: 'bool' }),
    from('HowToSteps', 'divider', { type: 'bool' }),
    from('HowToSteps', 'transition', {
      type: 'NebaTransition?',
      default: 'const NebaTransition.fade()',
      description: {
        ko: '독자가 옮겨간 단계가 등장하는 방식. null이면 꺼집니다. 눌리는 것이 아니라 패널에서 실행되고, 처음 그려지는 단계에는 쓰지 않으며, 움직임을 줄여 달라는 설정에서는 마지막 장면만 보여 줍니다',
        en: 'How a step arrives when the reader moves to it; null turns it off. It runs on the panel rather than on anything that is pressed, not on the step the guide is first built with, and shows its last frame alone to a reader who asked for less motion'
      }
    }),
    from('HowToSteps', 'completion', { type: 'bool' }),
    from('HowToSteps', 'completedContent', { type: `${WIDGET}?` }),
    variantRow('HowToSteps', 'NebaVariant.outline'),
    sizeRow('HowToSteps'),
    colorRow('HowToSteps'),
    densityRow('HowToSteps'),
    elevationRow('HowToSteps'),
    from('HowToSteps', 'locale', {
      type: 'Locale?',
      default: undefined,
      description: {
        ko: '네 개의 버튼과 마지막 문장, screen reader에게 알리는 말이 쓰이는 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale이며, 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the four buttons, the closing sentence and what a screen reader is told are in. Defaults to NebaProvider's, then the app's; a language that was never registered falls back to English"
      }
    }),
    from('HowToSteps', 'previousLabel · nextLabel · doneLabel · restartLabel', {
      type: 'String?'
    })
  ],

  HowToStep: [
    from('HowToStep', 'title', {
      type: WIDGET,
      description: {
        ko: '제목. 목록에도, 그 단계 본문 위에도 같은 것이 놓입니다. Text면 그 글자가 목록 행의 이름, "Step 3: Use it"이 됩니다',
        en: 'The heading, shown both in the list and over the step\'s own body. A Text also names the row for a screen reader, "Step 3: Use it"'
      }
    }),
    from('HowToStep', 'icon', { type: `${WIDGET}?` }),
    from('HowToStep', 'content', { type: `${WIDGET}?` }),
    from('HowToStep', 'image', {
      type: 'ImageProvider?',
      description: {
        ko: 'content 위의 그림. 본문 너비를 채우고 288픽셀보다 높아지지 않습니다',
        en: 'A picture above the content. It spans the panel and is never taller than 288 pixels'
      }
    }),
    from('HowToStep', 'imageAlt', {
      type: 'String?',
      description: {
        ko: '그 그림이 볼 수 없는 독자에게 하는 말. 기본값은 title이 Text일 때 그 글자입니다',
        en: "What that picture says for a reader who cannot see it. Defaults to the title's words when the title is a Text"
      }
    }),
    from('HowToStep', 'imageWidth · imageHeight', {
      type: 'double?',
      description: {
        ko: '그림 파일 자체의 픽셀 크기. 그 비율만큼 그림이 도착하기 전에 자리를 잡아 두므로 그림이 도착해도 본문이 자라지 않습니다. 크기가 아니라 비율이라 그림은 여전히 본문 너비를 채웁니다',
        en: "The picture file's own pixel dimensions. Their proportion is reserved before the picture arrives, so the panel does not grow when it lands. A proportion rather than a size: the picture still spans the panel"
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
