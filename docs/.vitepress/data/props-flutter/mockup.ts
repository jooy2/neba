import { colorRow, elevationRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Mockup: [
    from('Mockup', 'device', { type: 'NebaMockupDevice' }),
    from('Mockup', 'os', { type: 'NebaMockupOs?' }),
    from('Mockup', 'hardware', {
      type: 'NebaMockupHardware',
      default: 'NebaMockupHardware.monitor'
    }),
    sizeRow('Mockup'),
    from('Mockup', 'resolution', { type: 'Size?' }),
    from('Mockup', 'orientation', {
      type: 'NebaMockupOrientation',
      default: 'NebaMockupOrientation.portrait'
    }),
    from('Mockup', 'bezel', { type: 'NebaMockupBezel', default: 'NebaMockupBezel.standard' }),
    from('Mockup', 'finish', { type: 'NebaMockupFinish', default: 'NebaMockupFinish.graphite' }),
    from('Mockup', 'notch', { type: 'NebaMockupNotch?' }),
    from('Mockup', 'systemUi', { type: 'bool' }),
    from('Mockup', 'scroll', {
      type: 'bool',
      description: {
        ko: '화면보다 긴 내용이 스크롤되는지. 끄면 내용은 화면 크기를 정확히 받고 넘치는 부분은 잘립니다. 정지된 기기 그림에 맞는 쪽입니다',
        en: 'Whether content taller than the screen scrolls. Off, the content is given the screen exactly and clipped to it, which a still picture of a device wants'
      }
    }),
    from('Mockup', 'wallpaper', {
      type: 'Decoration?',
      description: {
        ko: '내용 뒤에 있는 것. 색, 그레이디언트, 그림을 BoxDecoration으로 받습니다',
        en: 'What is behind the content: a colour, a gradient or a picture, as a BoxDecoration'
      }
    }),
    from('Mockup', 'time', { type: 'String' }),
    from('Mockup', 'width', {
      type: 'double?',
      default: 'the parent’s width',
      description: {
        ko: '기기 전체가 페이지에 그려지는 너비. 기기는 자기 해상도로 배치된 뒤 이 크기에 맞게 한 번 축소되므로, 안의 내용은 페이지가 아니라 화면 하나 분량입니다',
        en: 'How wide the whole device is drawn. The device is laid out at its own resolution and then scaled once to fit, so the content inside is a screen’s worth rather than a page’s'
      }
    }),
    from('Mockup', 'height', { type: 'double?' }),
    colorRow('Mockup'),
    elevationRow('Mockup'),
    {
      name: 'transition',
      type: 'NebaTransition?',
      description: {
        ko: '처음 빌드될 때 한 번 실행되는 등장 애니메이션 (`const NebaTransition.fade()`)',
        en: 'An entrance animation, run once when the mockup is first built (`const NebaTransition.fade()`)'
      }
    },
    renamed('Mockup', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '화면에 있는 것. 그 아래의 MediaQuery는 화면의 크기를 알려줍니다',
        en: 'What is on the screen. The MediaQuery below it reports the screen’s size'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
