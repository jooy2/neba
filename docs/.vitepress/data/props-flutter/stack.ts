import { from, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Stack: [
    from('Stack', 'direction', {
      type: 'NebaStackDirection',
      default: 'NebaStackDirection.horizontal'
    }),
    from('Stack', 'overlap', { type: 'double?' }),
    from('Stack', 'drop', { type: 'double?' }),
    sizeRow('Stack'),
    from('Stack', 'max', { type: 'int?' }),
    from('Stack', 'total', { type: 'int?' }),
    from('Stack', 'overflow', { type: `${WIDGET} Function(int hidden)?` }),
    from('Stack', 'front', { type: 'NebaStackFront', default: 'NebaStackFront.first' }),
    from('Stack', 'scaleStep', { type: 'double' }),
    from('Stack', 'opacityStep', { type: 'double' }),
    from('Stack', 'ring', { type: 'bool' }),
    from('Stack', 'transition', { type: 'NebaTransition?' }),
    from('Stack', 'stagger', { type: 'Duration', default: 'Duration.zero' }),
    from('Stack', 'durationStep', { type: 'Duration', default: 'Duration.zero' }),
    from('Stack', 'reverse', { type: 'bool' }),
    from('Stack', 'children', { type: `List<${WIDGET}>` })
  ]
} satisfies Record<string, PropRow[]>;
