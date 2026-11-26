import { densityRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  GridContainer: [
    from('GridContainer', 'columns', { type: 'int' }),
    from('GridContainer', 'spacing', { type: 'double' }),
    from('GridContainer', 'rowSpacing', { type: 'double?' }),
    from('GridContainer', 'columnSpacing', { type: 'double?' }),
    from('GridContainer', 'justifyContent', {
      type: 'NebaJustifyContent',
      default: 'NebaJustifyContent.start'
    }),
    from('GridContainer', 'alignItems', {
      type: 'NebaAlignItems',
      default: 'NebaAlignItems.stretch'
    }),
    from('GridContainer', 'alignContent', {
      type: 'NebaJustifyContent',
      default: 'NebaJustifyContent.start'
    }),
    from('GridContainer', 'wrap', { type: 'bool' }),
    from('GridContainer', 'padded', { type: 'bool' }),
    sizeRow('GridContainer'),
    densityRow('GridContainer'),
    renamed('GridContainer', 'children', 'children', { type: `List<${WIDGET}>` })
  ],
  Grid: [
    from('Grid', 'span', {
      type: 'NebaGridSpan?',
      default: 'every column',
      description: {
        ko: '칸 수(NebaGridSpan.columns), 내용 너비(NebaGridSpan.auto), 또는 내용 너비에 줄에 남은 공간을 더한 너비(NebaGridSpan.grow). 생략하면 줄의 모든 칸입니다',
        en: 'A number of columns (NebaGridSpan.columns), the content’s width (NebaGridSpan.auto), or the content’s width plus whatever the row has left (NebaGridSpan.grow). Every column of the row when left out'
      }
    }),
    from('Grid', 'offset', { type: 'int', default: '0' }),
    from('Grid', 'alignSelf', { type: 'NebaAlignSelf', default: 'NebaAlignSelf.auto' }),
    renamed('Grid', 'children', 'child', { type: WIDGET, required: true })
  ]
} satisfies Record<string, PropRow[]>;
