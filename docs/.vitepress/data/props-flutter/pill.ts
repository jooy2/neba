import {
  densityRow,
  elevationRow,
  focusRows,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Pill: [
    variantRow('Pill', 'NebaVariant.solid'),
    sizeRow('Pill'),
    from('Pill', 'color', { type: 'NebaColor?', default: 'NebaColor.secondary' }),
    densityRow('Pill'),
    elevationRow('Pill', '2'),
    from('Pill', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '앞자리, 글리프, 아바타, 상태 점, 사진. 아이콘 크기의 정사각형 상자를 받아 원형으로 잘립니다. 글리프는 Pill이 내려주는 IconTheme으로 글자의 1.2배로 그려지고, Image는 상자를 채우고 잘립니다',
        en: 'The leading slot: a glyph, an avatar, a status dot, a photo. It is given a square the size of a standalone icon and clipped to a circle. A glyph is drawn at 1.2 times the type through the IconTheme the pill hands down, and an Image fills the box and is cropped'
      }
    }),
    from('Pill', 'title', { type: `${WIDGET}?` }),
    from('Pill', 'description', { type: `${WIDGET}?` }),
    from('Pill', 'endIcon', { type: `${WIDGET}?` }),
    from('Pill', 'details', { type: `${WIDGET}?` }),
    from('Pill', 'expanded', { type: 'bool' }),
    from('Pill', 'position', {
      type: 'NebaPosition',
      default: 'NebaPosition.static',
      description: {
        ko: '가장자리에 어떻게 붙는지. static이 아니면 가장자리에서 12픽셀과 safe area만큼 떨어집니다. fixed는 가장 가까운 Overlay로 올라가 가로로 가운데에 놓이고 원래 자리는 비워 둡니다. sticky는 제자리를 지키며 스크롤 뷰가 가장자리에 붙들어 둡니다',
        en: 'How it sits against its edge. Unless static, it hangs 12 pixels and the safe area clear of the edge. fixed lifts it into the nearest Overlay, centred across it, and leaves no room where it was written; sticky keeps its place, for a scroll view to hold at the edge'
      }
    }),
    from('Pill', 'safeArea', {
      type: 'bool',
      description: {
        ko: 'static이 아닐 때 가장자리까지의 거리에 화면 inset을 더합니다. inset은 pill이 빌드되는 자리에서 MediaQuery가 알려 주는 padding입니다',
        en: 'On a pill that is not static, adds the screen inset to its distance from the edge: the padding MediaQuery reports where the pill is built'
      }
    }),
    from('Pill', 'side', {
      type: 'NebaSide',
      default: 'NebaSide.top',
      description: {
        ko: 'static이 아닐 때 어느 가장자리에 붙는지. NebaSide.top 또는 NebaSide.bottom',
        en: 'Which edge it is held against when position is not static: NebaSide.top or NebaSide.bottom'
      }
    }),
    renamed('Pill', 'onClick', 'onPressed', {
      type: 'VoidCallback?',
      description: {
        ko: '주면 endIcon 앞까지의 줄이 이 콜백을 부르는 버튼이 됩니다. endIcon은 그 바깥에 남습니다. details가 있으면 펼쳐짐이나 접힘 상태를 가진 버튼으로 읽힙니다',
        en: 'Makes the row up to endIcon a button that calls this. endIcon stays outside it. With details, it is heard as a button that is expanded or collapsed'
      }
    }),
    renamed('Pill', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목과 설명 아래, 같은 가운데 열에 놓이는 것. 흐르는 글자, 작은 읽을거리 한둘',
        en: 'Under the title and the description, in the same centred column: a marquee, a pair of small readouts'
      }
    }),
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
