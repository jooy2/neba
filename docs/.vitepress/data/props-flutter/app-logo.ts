import { from, renamed, sizeRow, variantRow, WIDGET, type PropRow } from './shared';

export default {
  AppLogo: [
    renamed('AppLogo', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '마크를 그린 위젯. 마크의 높이에 맞춰 놓이고 주변 색을 물려받습니다. 스스로 폭이 없는 그림은 AspectRatio로 폭을 줍니다',
        en: 'A drawing of the mark, laid out at the mark’s height. It takes the colour around it, and a drawing with no width of its own takes one from an AspectRatio'
      }
    }),
    renamed('AppLogo', 'src', 'image', {
      type: 'ImageProvider?',
      description: {
        ko: '마크의 그림. 받은 그대로 그립니다. 마크의 높이에 맞추고 폭은 그림의 비율을 따릅니다',
        en: 'A picture of the mark, drawn as it came at the mark’s height, its width from its own proportion'
      }
    }),
    from('AppLogo', 'name', { type: 'String?' }),
    renamed('AppLogo', 'alt', 'semanticLabel', { type: 'String?' }),
    from('AppLogo', 'initials', { type: 'String?' }),
    from('AppLogo', 'showName', { type: 'bool' }),
    from('AppLogo', 'shape', { type: 'NebaAppLogoShape', default: 'NebaAppLogoShape.bare' }),
    variantRow('AppLogo'),
    sizeRow('AppLogo'),
    from('AppLogo', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    from('AppLogo', 'elevation', { type: 'NebaElevation', default: '0' }),
    from('AppLogo', 'padded', { type: 'bool' }),
    from('AppLogo', 'height', {
      type: 'double?',
      description: {
        ko: 'size 대신 쓸 마크의 높이(논리 픽셀)',
        en: 'The mark’s height in logical pixels, in place of the size’s'
      }
    }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      description: {
        ko: '링크로서 하는 일. 대개 홈으로 가는 것입니다. null이면 그림일 뿐입니다',
        en: 'What the logo does as a link, usually going home. With null it is a picture'
      }
    },
    from('AppLogo', 'href', {
      type: 'Uri?',
      description: {
        ko: '링크가 가는 곳. screen reader와, 웹에서는 브라우저에 알립니다. scheme이 http, https, mailto, tel이 아니면 쓰지 않습니다',
        en: 'Where the link goes, for a screen reader and, on the web, the browser. A scheme other than http, https, mailto or tel is not written'
      }
    }),
    {
      name: 'newTab',
      type: 'bool',
      default: 'false',
      description: {
        ko: '앱 밖으로 나가는 링크인지. screen reader에 "(새 창에서 열림)"을 알립니다',
        en: 'Whether the link leaves the app, said to a screen reader as "(opens in a new tab)"'
      }
    },
    {
      name: 'locale',
      type: 'Locale?',
      description: {
        ko: '새 창 안내를 쓸 언어',
        en: 'The language the new-tab notice is written in'
      }
    },
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: { ko: '링크의 focus node', en: 'The link’s focus node' }
    }
  ]
} satisfies Record<string, PropRow[]>;
