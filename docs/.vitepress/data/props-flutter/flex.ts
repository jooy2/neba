import { from, WIDGET, type PropRow } from './shared';

export default {
  Flex: [
    from('Flex', 'direction', { type: 'NebaOrientation', default: 'NebaOrientation.horizontal' }),
    from('Flex', 'reverse', { type: 'bool' }),
    from('Flex', 'spacing', { type: 'double' }),
    from('Flex', 'rowSpacing', { type: 'double?' }),
    from('Flex', 'columnSpacing', { type: 'double?' }),
    from('Flex', 'justifyContent', {
      type: 'NebaJustifyContent',
      default: 'NebaJustifyContent.start'
    }),
    from('Flex', 'alignItems', { type: 'NebaAlignItems', default: 'NebaAlignItems.stretch' }),
    from('Flex', 'alignContent', {
      type: 'NebaJustifyContent',
      default: 'NebaJustifyContent.start'
    }),
    from('Flex', 'wrap', { type: 'bool' }),
    from('Flex', 'inline', { type: 'bool' }),
    from('Flex', 'children', { type: `List<${WIDGET}>` })
  ]
} satisfies Record<string, PropRow[]>;
