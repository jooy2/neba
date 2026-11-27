import { densityRow, elevationRow, from, sizeRow, variantRow, type PropRow } from './shared';

export default {
  Header: [
    from('Header', 'brand', {
      type: 'List<Widget>',
      default: '[]',
      description: {
        ko: '앞쪽 자리. 로고, 제품 이름, 그 앞의 NebaSidebarTrigger처럼 모든 페이지에서 같은 것들이며, 하나의 줄로 놓이므로 감쌀 필요가 없습니다',
        en: "The leading slot: the logo, the product's name, a NebaSidebarTrigger ahead of them. Laid out as a row of its own, so they need no wrapper"
      }
    }),
    from('Header', 'children', {
      type: 'List<Widget>',
      default: '[]',
      description: {
        ko: '가운데 자리. 대개 탐색이며, 하나의 줄로 놓입니다',
        en: 'The middle slot, usually the navigation, laid out as a row of its own'
      }
    }),
    from('Header', 'actions', {
      type: 'List<Widget>',
      default: '[]',
      description: {
        ko: '뒤쪽 자리. 계정 메뉴, 테마 전환, 주요 행동이 하나의 줄로 놓이므로 버튼 여러 개를 감쌀 필요가 없습니다',
        en: 'The trailing slot: the account menu, a theme switch, the call to action, laid out as a row of its own so several buttons need no wrapper'
      }
    }),
    from('Header', 'align', { type: 'NebaAlign', default: 'NebaAlign.start' }),
    from('Header', 'position', {
      type: 'NebaPosition',
      default: 'NebaPosition.sticky',
      description: {
        ko: 'NebaPageLayout이 페이지를 스크롤하는 동안 바를 어떻게 두는지. sticky와 fixed는 내용이 아래로 지나가는 채 위에 붙잡고, static은 함께 스크롤되어 사라집니다. 레이아웃 밖에서는 아무것도 바꾸지 않습니다',
        en: 'How a NebaPageLayout holds the bar while the page scrolls: sticky and fixed at the top, with the content passing under it, and static scrolling away with it. Outside a layout it changes nothing'
      }
    }),
    variantRow('Header', 'NebaVariant.outline'),
    sizeRow('Header'),
    from('Header', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Header'),
    elevationRow('Header'),
    from('Header', 'divider', { type: 'bool' }),
    from('Header', 'maxWidth', {
      type: 'NebaMeasure',
      default: 'NebaMeasure.none',
      description: {
        ko: '시트는 폭 전체에 걸친 채, 안쪽 줄만 이 폭으로 묶어 가운데 놓습니다. NebaContainer와 같은 사다리이거나 직접 준 논리 픽셀 폭입니다',
        en: 'Holds the row of slots to a measure and centres it while the sheet still spans the width: the ladder NebaContainer uses, or a width of your own in logical pixels'
      }
    }),
    from('Header', 'padded', { type: 'bool' }),
    from('Header', 'label', {
      type: 'String?',
      description: {
        ko: 'Flutter에는 banner 역할이 없으므로, NebaPageLayout이 받은 header에 label이 있으면 그 이름의 region이 되고, 없으면 순서대로 읽히는 묶음이 됩니다. 다른 곳의 header에는 붙지 않습니다',
        en: 'Flutter has no banner role, so the header a NebaPageLayout was handed is a region with this name when it has one, and a group read in order when it has none. Elsewhere it names nothing'
      }
    }),
    {
      name: 'safeArea',
      type: 'bool',
      default: 'true',
      description: {
        ko: '바가 닿는 위와 양옆의 시스템 inset(상태 표시줄, 노치)만큼 내용을 안쪽으로 둡니다. 시트는 그 아래까지 깔립니다',
        en: 'Keeps what is on the bar clear of the system insets on the top and the two sides: the status bar, a notch. The sheet still runs under them'
      }
    }
  ]
} satisfies Record<string, PropRow[]>;
