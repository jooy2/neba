import { from, renamed, WIDGET, type PropRow } from './shared';

export default {
  Image: [
    renamed('Image', 'src', 'image', {
      type: 'ImageProvider?',
      required: true,
      description: {
        ko: '그림. AssetImage, NetworkImage처럼 어떤 ImageProvider든 됩니다. null이면 아직 파일을 기다리는 그림이고, 새 provider는 처음부터 다시 시작합니다',
        en: 'The picture, as any ImageProvider: an AssetImage, a NetworkImage. null is a picture still waiting for a file, and a new provider starts over'
      }
    }),
    from('Image', 'alt', { type: 'String', required: true }),
    from('Image', 'ratio', {
      type: 'double?',
      default: undefined,
      description: {
        ko: '파일이 도착하는 동안과 그 뒤에 지킬 비율(너비 ÷ 높이). 생략하면 파일이 도착한 뒤 파일이 정합니다',
        en: 'The proportion to hold, width over height, while the file is arriving and after. Left out, the file decides once it is in'
      }
    }),
    from('Image', 'width · height', {
      type: 'double?',
      description: {
        ko: '파일 자체의 픽셀 크기. 둘 다 주면 크기가 아니라 비율만 정해 상자는 주어진 너비만큼 퍼집니다. 하나만 주면 그 축의 상자 크기(논리 픽셀)가 됩니다',
        en: "The file's own pixel dimensions. Give both and they set a proportion rather than a size, and the box spans the width it is given. Give one and it sizes the box on that axis, in logical pixels"
      }
    }),
    from('Image', 'fit', {
      type: 'BoxFit',
      default: 'BoxFit.cover'
    }),
    from('Image', 'position', {
      type: 'Alignment?',
      default: 'Alignment.center',
      description: {
        ko: '상자 안에서 그림이 놓이는 자리. cover에서는 남는 부분을, 다른 fit에서는 빈 영역의 위치를 정합니다. 화면에 보이는 그림 기준이라 rotate와 flip을 거쳐도 유지되고, 물리 방향이라 RTL에서도 바뀌지 않습니다',
        en: 'Where the picture sits in the box: which part a cover crop keeps, and where the other fits leave their space. Read on the picture as shown, so it holds through rotate and flip, and physical, so RTL leaves it alone'
      }
    }),
    from('Image', 'letterbox', {
      type: 'NebaImageLetterbox',
      default: 'NebaImageLetterbox.none',
      description: {
        ko: 'contain · none · scaleDown이 남긴 빈 영역을 채우는 것. blur는 같은 그림을 흐리게 깔고, color와 decoration은 색과 Decoration입니다',
        en: 'What fills the space contain, none or scaleDown leave empty. blur lays the same picture behind it, blurred; color and decoration take a colour and a Decoration'
      }
    }),
    from('Image', 'rounded', {
      type: 'NebaSize?',
      default: 'null',
      description: {
        ko: 'radius 사다리의 한 단계로 모서리를 둥글게. null이면 각진 모서리',
        en: 'Rounds the corners at this step of the radius ladder. null is square'
      }
    }),
    from('Image', 'placeholder', {
      type: 'NebaImagePlaceholder?',
      description: {
        ko: '파일이 도착하는 동안 자리를 지키는 것. 기본값은 같은 모양의 Skeleton이고, .widget은 직접 만든 위젯, .image는 같은 fit · position · rotate · flip으로 그리는 그림, .none은 아무것도 두지 않습니다',
        en: 'What stands in while the file is arriving. A Skeleton of the right shape by default; .widget is a widget of your own, .image a picture drawn with the same fit, position, rotate and flip, and .none nothing'
      }
    }),
    from('Image', 'fallback', {
      type: `${WIDGET}?`,
      description: {
        ko: '도착하지 못했을 때 그려지는 것, Image의 errorBuilder에 해당합니다. 기본값은 alt을 담은 상자입니다',
        en: 'Drawn instead when it does not arrive, where Image would call its errorBuilder. A box carrying the alt by default'
      }
    }),
    from('Image', 'preview', {
      type: 'bool',
      description: {
        ko: '누르면 Dialog의 시트에 원본을 확대 없이 띄웁니다. 그림이 alt을 이름으로 갖는 버튼이 되므로 키보드로도 열립니다. 위에 Overlay가 있어야 합니다',
        en: 'Opens the full picture, never enlarged, on the sheet a Dialog draws when it is pressed. The picture becomes a button named by its alt, so a keyboard can open it too. Needs an Overlay above it'
      }
    }),
    from('Image', 'filter', {
      type: 'NebaImageFilter',
      default: 'NebaImageFilter.none',
      description: {
        ko: '그림의 색조. 이름 붙은 일곱 가지, 또는 ColorFilter.matrix가 받는 숫자 스무 개의 NebaImageFilter.matrix. 바뀌면 스냅이 아니라 스며듭니다',
        en: 'How the picture is coloured: one of seven names, or NebaImageFilter.matrix with the twenty numbers ColorFilter.matrix takes. A change fades rather than snaps'
      }
    }),
    from('Image', 'rotate', {
      type: 'int',
      description: {
        ko: '그림을 시계 방향으로 90도 단위로 돌립니다. 그 밖의 각도는 가장 가까운 90도로 읽습니다. 옆으로 누우면 상자도 누운 모양으로 잡히며, width와 height는 여전히 파일의 크기입니다',
        en: 'Turns the picture clockwise, a quarter at a time; any other number is the nearest quarter. On its side it reserves a box on its side, with width and height still describing the file'
      }
    }),
    from('Image', 'flip', { type: 'NebaImageFlip', default: 'NebaImageFlip.none' }),
    from('Image', 'frame', { type: 'NebaImageFrame?' }),
    from('Image', 'watermark', {
      type: 'NebaImageWatermark?',
      description: {
        ko: '그림 위에 그리는 표식, 저작자 표시, 라이선스, DRAFT. repeat이면 타일로 깔립니다. 자물쇠가 아니라 억지책입니다',
        en: 'A mark drawn over the picture: a credit, a licence, the word DRAFT. repeat tiles it. A deterrent, not a lock'
      }
    }),
    from('Image', 'protect', {
      type: 'bool',
      description: {
        ko: '웹에서 pointer가 그림 위에 있는 동안 브라우저 메뉴를 끕니다. Flutter가 그리는 그림을 무심코 가져가는 경로는 그것 하나뿐입니다. 파일 자체는 여전히 남아 있습니다',
        en: 'Holds the browser menu off while the pointer is over the picture, on the web: the one way a picture Flutter draws is casually taken. The file itself is still there'
      }
    }),
    from('Image', 'priority', {
      type: 'bool',
      description: {
        ko: '화면의 평가 기준이 되는 그림을 페이드나 Skeleton 없이 그립니다. placeholder 그림은 여전히 그 아래에 깔립니다',
        en: 'Draws the picture a screen is judged by with no fade and no Skeleton. A placeholder picture still stands beneath it'
      }
    }),
    from('Image', 'onLoadingStatusChange', {
      type: 'ValueChanged<NebaImageLoadingStatus>?',
      description: {
        ko: '파일을 요청할 때 loading으로, 다 받았거나 받지 못했을 때 loaded나 failed로, 그 프레임이 끝난 뒤 호출됩니다. 이미 캐시에 있던 그림은 loaded만 알립니다',
        en: 'Called with loading when the file is asked for, then loaded or failed once it settles, after the frame. A picture already in the cache says loaded alone'
      }
    }),
    from('Image', 'locale', {
      type: 'Locale?',
      description: {
        ko: '파일이 도착하지 못하고 alt도 비었을 때 쓰는 문장과 미리보기 버튼 이름의 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language of the sentence used when the file fails and alt is empty, and of the preview button's name. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Image', 'unavailableLabel', { type: 'String?' })
  ]
} satisfies Record<string, PropRow[]>;
