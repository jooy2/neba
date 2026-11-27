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

const LIST = `List<${WIDGET}>`;

export default {
  Toolbar: [
    variantRow('Toolbar', 'NebaVariant.outline'),
    sizeRow('Toolbar'),
    colorRow('Toolbar'),
    densityRow('Toolbar'),
    elevationRow('Toolbar'),
    from('Toolbar', 'position', {
      type: 'NebaPosition',
      default: 'NebaPosition.static',
      description: {
        ko: '바가 가장자리에 어떻게 붙는지. static은 모서리가 있는 시트입니다. sticky는 모서리를 버리고 safe area를 피한 모습으로 그려지며, 가장자리에 붙들어 두는 일은 PinnedHeaderSliver 같은 스크롤 뷰가 맡습니다. fixed는 같은 모습으로 가장 가까운 Overlay의 가장자리에 폭 전체로 붙고 원래 자리는 비워 둡니다',
        en: 'How the bar sits against its edge. static is a sheet with corners. sticky drops the corners and keeps clear of the safe area, for a scroll view such as a PinnedHeaderSliver to hold it at the edge. fixed does the same in the nearest Overlay, across its width, and takes no room where it was written'
      }
    }),
    from('Toolbar', 'safeArea', {
      type: 'bool',
      description: {
        ko: 'static이 아닐 때 붙은 쪽 가장자리의 화면 inset을 여백에 더해 휴대폰의 노치와 홈 인디케이터를 피합니다. inset은 바가 빌드되는 자리에서 MediaQuery가 알려 주는 padding이라, SafeArea 안의 바는 아무것도 더하지 않습니다',
        en: 'On a bar that is not static, adds the screen inset on the edge it is held against to its padding, clearing a phone notch and home indicator. The inset is the padding MediaQuery reports where the bar is built, so a bar under a SafeArea adds nothing'
      }
    }),
    from('Toolbar', 'side', {
      type: 'NebaSide',
      default: 'NebaSide.top',
      description: {
        ko: 'static이 아닐 때 어느 가장자리에 붙는지. NebaSide.top 또는 NebaSide.bottom',
        en: 'Which edge it is held against when position is not static: NebaSide.top or NebaSide.bottom'
      }
    }),
    from('Toolbar', 'divider', { type: 'bool' }),
    from('Toolbar', 'start', {
      type: LIST,
      default: 'const []',
      description: {
        ko: '바의 앞쪽에 고정되는 위젯들. 로고, 제목, 뒤로 가기. 8픽셀 간격으로 한 줄에 놓입니다',
        en: 'Pinned to the start of the bar: a logo, a title, a back button. Laid out in a row 8 pixels apart'
      }
    }),
    from('Toolbar', 'end', {
      type: LIST,
      default: 'const []',
      description: {
        ko: '뒤쪽에 고정되는 위젯들, 액션들. 8픽셀 간격으로 한 줄에 놓입니다',
        en: 'Pinned to the end: the actions. Laid out in a row 8 pixels apart'
      }
    }),
    from('Toolbar', 'children', {
      type: LIST,
      default: 'const []',
      description: {
        ko: '가운데. start와 end가 남긴 폭을 가져가며 8픽셀 간격으로 한 줄에 놓입니다. 그 폭을 채워야 하는 위젯은 Expanded로 감쌉니다',
        en: 'The middle, which takes whatever width start and end leave, laid out in a row 8 pixels apart. A widget that should fill that width goes in an Expanded'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
