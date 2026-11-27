import {
  colorRow,
  densityRow,
  elevationRow,
  from,
  sizeRow,
  variantRow,
  type PropRow
} from './shared';

export default {
  FloatingBottomNavigation: [
    variantRow('FloatingBottomNavigation', 'NebaVariant.outline'),
    sizeRow('FloatingBottomNavigation'),
    colorRow('FloatingBottomNavigation'),
    densityRow('FloatingBottomNavigation'),
    elevationRow('FloatingBottomNavigation', '2'),
    from('FloatingBottomNavigation', 'value', {
      type: 'T?',
      description: {
        ko: '지금 있는 목적지의 값. controlled 바에 씁니다. null이면 바가 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: 'The value of the destination the reader is on, for a controlled bar. Left null, the bar keeps its own state, starting from defaultValue'
      }
    }),
    from('FloatingBottomNavigation', 'defaultValue', { type: 'T?' }),
    from('FloatingBottomNavigation', 'onValueChange', {
      type: 'ValueChanged<T>?',
      description: {
        ko: '눌린 목적지의 값과 함께 호출됩니다. 지금 있는 목적지를 다시 눌러도 호출됩니다',
        en: 'Called with the value of the destination that was pressed, the current one included'
      }
    }),
    from('FloatingBottomNavigation', 'position', {
      type: 'NebaFloatingBottomNavigationPosition',
      default: 'NebaFloatingBottomNavigationPosition.fixed',
      description: {
        ko: '어디에 앉는지. NebaFloatingActionButtonPosition과 같은 타입입니다. static이 아니면 바가 받은 공간 전체를 차지하고 그 아래쪽 가운데에 뜨므로, 떠 있을 화면이나 영역 위의 Stack에 넣습니다. static은 흐름 안에서 가운데 놓입니다',
        en: 'Where it sits: the same type as NebaFloatingActionButtonPosition. Anything but static takes the whole of the space it is given and floats at the bottom of it, centred, so it goes in a Stack over the screen or the region it floats over. static puts it in the flow, centred'
      }
    }),
    from('FloatingBottomNavigation', 'offset', {
      type: 'double',
      description: {
        ko: '아래 가장자리에서 얼마나 떠 있는지, 논리 픽셀. BottomNavigation과의 차이 전부가 여기서 나옵니다',
        en: 'How far the bar floats above the bottom edge, in logical pixels. This is the whole difference from BottomNavigation'
      }
    }),
    from('FloatingBottomNavigation', 'labels', {
      type: 'NebaBottomNavigationLabels',
      default: 'NebaBottomNavigationLabels.selected'
    }),
    from('FloatingBottomNavigation', 'safeArea', {
      type: 'bool',
      description: {
        ko: 'fixed나 sticky일 때 아래쪽 시스템 inset을 offset에 더해 홈 인디케이터를 피합니다. 시트 전체가 올라갑니다. absolute는 화면 가장자리에 닿지 않는 영역용이라 더하지 않습니다',
        en: 'On a fixed or sticky bar, adds the bottom system inset to offset, so the bar clears the home indicator. The whole sheet moves up. absolute is for a region that is not against the edge of the screen, and adds none'
      }
    }),
    from('FloatingBottomNavigation', 'disabled', { type: 'bool' }),
    from('FloatingBottomNavigation', 'label', { type: 'String?' }),
    from('FloatingBottomNavigation', 'children', {
      type: 'List<NebaBottomNavigationItem<T>>',
      description: {
        ko: '목적지들. BottomNavigation과 같은 항목을 씁니다',
        en: 'The destinations: the same item BottomNavigation takes'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
