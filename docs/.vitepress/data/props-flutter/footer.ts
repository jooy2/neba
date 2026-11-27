import {
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Footer: [
    renamed('Footer', 'children', 'child', { type: `${WIDGET}?` }),
    from('Footer', 'position', {
      type: 'NebaPosition',
      default: 'NebaPosition.static',
      description: {
        ko: 'NebaPageLayout이 페이지를 스크롤하는 동안 footer를 어떻게 두는지. static은 끝까지 스크롤해야 나타나고, sticky와 fixed는 아래에 붙잡혀 손닿는 곳에 남습니다. 레이아웃 밖에서는 아무것도 바꾸지 않습니다',
        en: 'How a NebaPageLayout holds the footer while the page scrolls: static is reached by scrolling to the end, sticky and fixed are held at the bottom and stay in reach. Outside a layout it changes nothing'
      }
    }),
    from('Footer', 'safeArea', {
      type: 'bool',
      description: {
        ko: '아래와 양옆의 시스템 inset(홈 인디케이터, 노치)만큼 내용을 안쪽으로 둡니다. 페이지 끝의 footer는 끝까지 스크롤되면 화면 아래에 닿으므로 position과 상관없이 적용됩니다',
        en: 'Keeps the content clear of the system insets on the bottom and the two sides: the home indicator, a notch. A footer at the end of a page is against the bottom of the screen once it is scrolled to, so this holds whatever its position'
      }
    }),
    variantRow('Footer', 'NebaVariant.outline'),
    sizeRow('Footer'),
    from('Footer', 'color', { type: 'NebaColor', default: 'NebaColor.primary' }),
    densityRow('Footer'),
    elevationRow('Footer'),
    from('Footer', 'divider', { type: 'bool' }),
    from('Footer', 'maxWidth', {
      type: 'NebaMeasure',
      default: 'NebaMeasure.none',
      description: {
        ko: '시트는 폭 전체에 걸친 채, 내용만 이 폭으로 묶어 가운데 놓습니다. NebaContainer와 같은 사다리이거나 직접 준 논리 픽셀 폭입니다',
        en: 'Holds the content to a measure and centres it while the sheet still spans the width: the ladder NebaContainer uses, or a width of your own in logical pixels'
      }
    }),
    from('Footer', 'padded', { type: 'bool' }),
    from('Footer', 'label', {
      type: 'String?',
      description: {
        ko: 'NebaPageLayout이 받은 footer, 곧 화면 낭독기가 사이트 정보로 알리는 contentInfo 영역의 이름. 다른 곳의 footer는 랜드마크가 아니므로 붙지 않습니다',
        en: "The name of the contentInfo region a screen reader offers as the site's information, which is the footer a NebaPageLayout was handed. A footer elsewhere is no landmark, and this names nothing"
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
