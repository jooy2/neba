import { colorRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Panes: [
    from('Panes', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.horizontal'
    }),
    from('Panes', 'resizable', { type: 'bool' }),
    sizeRow('Panes'),
    colorRow('Panes'),
    from('Panes', 'onResize', { type: 'ValueChanged<List<double>>?' }),
    from('Panes', 'onResizeEnd', { type: 'ValueChanged<List<double>>?' }),
    from('Panes', 'handleLabel', {
      type: 'String?',
      description: {
        ko: '모든 바에 붙는 이름. 기본값은 locale의 “패널 크기 조절”입니다. 바마다 다른 이름은 handleLabelBuilder로 줍니다',
        en: "Names every handle. Defaults to the locale's words for resizing panes; a name per handle is handleLabelBuilder's"
      }
    }),
    {
      name: 'handleLabelBuilder',
      type: 'String Function(int index)?',
      description: {
        ko: '바마다 이름을 붙입니다. 0부터 센 바의 순서를 받습니다. handleLabel과 함께 줄 수 없습니다',
        en: "Names each handle, handed the handle's index from 0. Not given together with handleLabel"
      }
    },
    from('Panes', 'locale', {
      type: 'Locale?',
      default: "NebaProvider's, then the app's",
      description: {
        ko: '바의 기본 이름에 쓸 언어. 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the handle's default name is in. A language nobody registered falls back to English"
      }
    }),
    from('Panes', 'children', {
      type: 'List<NebaPane>',
      description: {
        ko: 'Pane들. 타입이 List<NebaPane>이므로 직접 자식은 언제나 pane입니다',
        en: 'The panes. The type is List<NebaPane>, so every direct child is a pane'
      }
    })
  ],

  Pane: [
    from('Pane', 'defaultSize', {
      type: 'NebaPaneSize?',
      description: {
        ko: '처음 차지할 몫. NebaPaneSize.percent(25)는 퍼센트, NebaPaneSize.pixels(240)은 논리 픽셀 길이입니다. 값을 주지 않은 pane들은 남은 자리를 똑같이 나눠 갖습니다',
        en: 'The share this pane starts with: NebaPaneSize.percent(25) for a percentage, NebaPaneSize.pixels(240) for a length in logical pixels. Panes with no defaultSize split what is left equally'
      }
    }),
    from('Pane', 'minSize', { type: 'NebaPaneSize?' }),
    from('Pane', 'maxSize', { type: 'NebaPaneSize?' }),
    renamed('Pane', 'children', 'child', {
      type: WIDGET,
      description: {
        ko: 'pane 안에 들어가는 것. pane의 크기로 배치되고 넘치는 부분은 잘립니다. 더 길어질 수 있는 내용은 NebaScrollArea에 넣고, 표면이 필요하면 NebaBox나 NebaCard에 넣습니다',
        en: 'What is inside the pane, laid out at the pane’s size and clipped to it. Content that may be longer goes in a NebaScrollArea, and a surface is a NebaBox or a NebaCard'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
