import {
  colorRow,
  densityRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  DataTable: [
    from('DataTable', 'columnOrder', { type: 'List<String>?' }),
    from('DataTable', 'defaultColumnOrder', { type: 'List<String>?' }),
    from('DataTable', 'onColumnOrderChange', { type: 'ValueChanged<List<String>>?' }),
    from('DataTable', 'reorderable', { type: 'bool' }),
    from('DataTable', 'onCellEdit', {
      type: 'void Function(T row, NebaDataTableColumn<T> column, Object value)?',
      description: {
        ko: '편집한 셀을 확정할 때 호출됩니다. value는 String이거나 number 열이면 num입니다. 이것이 없으면 어떤 셀도 편집되지 않습니다. 표는 행의 사본을 갖지 않고 값을 넘긴 뒤 items로 돌아온 것을 그립니다',
        en: 'Called when an edited cell is committed, with a String, or a num for a number column. Nothing is editable without it: the table holds no copy of the rows, it hands the value over and draws what comes back in items'
      }
    }),
    from('DataTable', 'groupBy', {
      type: 'String? Function(T row)?',
      description: {
        ko: '행을 제목 아래로 묶습니다. 검색과 정렬 다음에 돌므로 각 그룹 안의 정렬이 유지됩니다. null을 돌려준 행은 아무 그룹에도 속하지 않고 맨 위로 갑니다. 묶인 표도 가상 스크롤을 합니다',
        en: 'Groups the rows under a heading. It runs after the search and the sort, so each group stays sorted; a row it returns null for goes above everything, in no group. A grouped table is virtual too'
      }
    }),
    from('DataTable', 'collapsibleGroups', { type: 'bool' }),
    from('DataTable', 'defaultCollapsedGroups', { type: 'List<String>?' }),
    from('DataTable', 'exportable', {
      type: 'bool',
      description: {
        ko: '지금 보고 있는 페이지가 아니라 검색과 정렬이 남긴 모든 행을 CSV로 onExport에 넘기는 버튼을 그립니다. 패키지는 내려받기를 시작하지 않으므로 onExport가 있을 때만 그려집니다',
        en: 'Draws a button that hands onExport every row the search and the sort left as CSV, not the page the reader is on. The package starts no download, so the button is drawn only with an onExport'
      }
    }),
    from('DataTable', 'onExport', {
      type: 'ValueChanged<String>?',
      description: {
        ko: '내보내기 버튼이 쓴 CSV를 받습니다. 파일로 저장하거나 공유하는 것은 앱의 몫입니다',
        en: 'Takes the CSV the export button writes. Saving or sharing it is the app’s to do'
      }
    }),
    from('DataTable', 'exportEscapeFormulas', { type: 'bool' }),
    variantRow('DataTable', 'NebaVariant.outline'),
    sizeRow('DataTable', 'NebaSize.sm'),
    colorRow('DataTable'),
    densityRow('DataTable', 'NebaDensity.compact'),
    from('DataTable', 'headers', { type: 'List<NebaDataTableColumn<T>>' }),
    from('DataTable', 'items', { type: 'List<T>' }),
    renamed('DataTable', 'getRowKey', 'rowKey', { type: 'Object Function(T row, int index)?' }),
    from('DataTable', 'height', {
      type: 'double?',
      description: {
        ko: '스크롤되는 본문의 높이(논리 픽셀). **가상 스크롤을 켜는 것이 이것입니다**',
        en: 'The height of the scrolling body, in logical pixels. **This is what turns virtual scrolling on**'
      }
    }),
    from('DataTable', 'maxHeight', { type: 'double?' }),
    from('DataTable', 'rowHeight', {
      type: 'double?',
      description: {
        ko: '한 행의 높이(논리 픽셀). 모든 행이 이 높이이고 셀은 줄바꿈 대신 말줄임합니다',
        en: 'How tall one row is, in logical pixels. Every row is this tall and cells truncate rather than wrap'
      }
    }),
    from('DataTable', 'virtual', {
      type: 'bool',
      description: {
        ko: '화면 밖 행을 빌드하지 않습니다. height 또는 maxHeight가 있어야 동작합니다',
        en: 'Leaves the rows off screen unbuilt. Needs a height or a maxHeight to do anything'
      }
    }),
    from('DataTable', 'overscan', {
      type: 'int',
      description: {
        ko: '본문의 위아래 가장자리 너머로 빌드해 두는 행 수',
        en: 'How many rows are kept built past each edge of the body'
      }
    }),
    from('DataTable', 'striped', {
      type: 'NebaDataTableStripe',
      default: 'NebaDataTableStripe.none',
      description: {
        ko: '한 행 걸러 색을 깝니다. odd는 첫째·셋째 행, even은 둘째·넷째 행이며, 홀짝은 페이지 전체 순번으로 셉니다',
        en: 'Tints every other row: odd is the first and the third, even the second and the fourth, counted over the whole page'
      }
    }),
    from('DataTable', 'hoverable', { type: 'bool' }),
    from('DataTable', 'stickyHeader', { type: 'bool' }),
    from('DataTable', 'caption', {
      type: `${WIDGET}?`,
      description: {
        ko: '표 위의 설명. Text이고 semanticLabel이 없으면 표의 이름으로도 읽힙니다',
        en: 'Shown above the table, and read as its name when it is a Text and there is no semanticLabel'
      }
    }),
    renamed('DataTable', 'label', 'semanticLabel', {
      type: 'String?',
      description: {
        ko: 'screen reader가 표를 부르는 이름. React의 label에 해당하며, caption보다 앞섭니다',
        en: "The name a screen reader announces the table by: React's label. It wins over a caption"
      }
    }),
    from('DataTable', 'empty', { type: `${WIDGET}?` }),
    from('DataTable', 'sortable', { type: 'bool' }),
    from('DataTable', 'sortMode', {
      type: 'NebaDataTableSortMode',
      default: 'NebaDataTableSortMode.single'
    }),
    from('DataTable', 'sort / defaultSort', {
      type: 'List<NebaDataTableSort>?',
      description: {
        ko: '정렬 상태. NebaDataTableSort(key, direction) 목록이며 앞쪽이 우선입니다',
        en: 'The sort: a list of NebaDataTableSort(key, direction), first key outermost'
      }
    }),
    from('DataTable', 'onSortChange', { type: 'ValueChanged<List<NebaDataTableSort>>?' }),
    from('DataTable', 'resizable', { type: 'bool' }),
    from('DataTable', 'columnWidths / defaultColumnWidths', {
      type: 'Map<String, double>?',
      description: {
        ko: '열별 너비(논리 픽셀)',
        en: 'The widths, in logical pixels, keyed by column'
      }
    }),
    from('DataTable', 'onColumnWidthsChange', { type: 'ValueChanged<Map<String, double>>?' }),
    from('DataTable', 'selectionMode', {
      type: 'NebaDataTableSelectionMode',
      default: 'NebaDataTableSelectionMode.none'
    }),
    from('DataTable', 'selected / defaultSelected', { type: 'List<Object>?' }),
    from('DataTable', 'onSelectedChange', {
      type: 'void Function(List<Object> selected, List<T> rows)?'
    }),
    from('DataTable', 'checkboxes', { type: 'bool' }),
    renamed('DataTable', 'onRowClick', 'onRowPressed', {
      type: 'void Function(T row, int index)?',
      description: {
        ko: '행을 누를 때마다, 그 누름이 선택을 바꾼 뒤에 호출됩니다. 셀 안의 컨트롤을 누른 것은 그 컨트롤의 몫이라 행을 누른 것으로 치지 않습니다. 행의 체크박스와 열린 셀 편집기도 마찬가지입니다',
        en: 'Called on every press of a row, after the press has changed the selection. A press on a control inside a cell is that control’s, the row’s own tick and an open cell editor included'
      }
    }),
    from('DataTable', 'onRowActivate', { type: 'void Function(T row, int index)?' }),
    from('DataTable', 'paging', {
      type: 'NebaDataTablePaging',
      default: 'NebaDataTablePaging.scroll'
    }),
    from('DataTable', 'page / defaultPage', { type: 'int? / int' }),
    from('DataTable', 'onPageChange', { type: 'ValueChanged<int>?' }),
    from('DataTable', 'pageSize / defaultPageSize', { type: 'int? / int' }),
    from('DataTable', 'onPageSizeChange', { type: 'ValueChanged<int>?' }),
    from('DataTable', 'pageSizeOptions', {
      type: 'List<int>',
      default: 'const <int>[10, 25, 50, 100]'
    }),
    from('DataTable', 'footer', { type: 'bool?' }),
    from('DataTable', 'search / defaultSearch', { type: 'String?' }),
    from('DataTable', 'onSearchChange', { type: 'ValueChanged<String>?' }),
    from('DataTable', 'searchable', { type: 'bool' }),
    from('DataTable', 'searchPlaceholder', { type: 'String?' }),
    from('DataTable', 'filter', { type: 'bool Function(T row, int index)?' }),
    from('DataTable', 'toolbar', { type: `${WIDGET}?` }),
    from('DataTable', 'manual', {
      type: 'Set<NebaDataTableStage>',
      default: 'const <NebaDataTableStage>{}',
      description: {
        ko: '이미 caller가 끝낸 단계. NebaDataTableStage.values.toSet()은 셋 다입니다',
        en: 'Which stages the caller has already done. NebaDataTableStage.values.toSet() is all three'
      }
    }),
    from('DataTable', 'rowCount', { type: 'int?' }),
    from('DataTable', 'locale', {
      type: 'Locale?',
      description: {
        ko: '표가 스스로 말하는 문구의 언어. 주지 않으면 NebaProvider의 것, 그다음 앱의 것을 따릅니다. widgets 레이어에는 intl이 없어서 기본 정렬은 대소문자와 악센트를 무시하고 숫자를 수로 비교할 뿐 언어별 순서를 모르며, builder 없는 열의 날짜와 푸터의 개수는 영어로 씁니다',
        en: "The language of the table's own words. Defaults to NebaProvider's, then the app's. The widgets layer has no intl, so the default sort folds case and accents and compares digits as numbers without any language's own order, and a date in a column without a builder and the footer's counts are written in English"
      }
    })
  ],
  DataTableColumn: [
    from('DataTableColumn', 'pinned', {
      type: 'NebaDataTablePin?',
      description: {
        ko: '나머지가 지나가는 동안 그 가장자리에 얼려 둡니다. 열을 옮기기도 합니다. start는 맨 앞, end는 맨 뒤입니다',
        en: 'Freezes the column against that edge while the rest scroll past. It also moves it: start first, end last'
      }
    }),
    from('DataTableColumn', 'editable', {
      type: 'bool',
      default: 'false',
      description: {
        ko: '이 열의 셀을 그 자리에서 편집하게 합니다. 위에 onCellEdit가 없으면 편집되지 않습니다',
        en: 'Lets a cell in this column be edited in place. Not editable at all without an onCellEdit above it'
      }
    }),
    {
      name: 'editableWhen',
      type: 'bool Function(T row)?',
      description: {
        ko: '행마다 편집 여부를 정합니다. 잠긴 레코드나 계산된 필드에 씁니다. 주면 editable이 켜집니다',
        en: 'Decides per row whether a cell edits, for a locked record or a computed field. Setting it makes the column editable'
      }
    },
    from('DataTableColumn', 'editType', {
      type: 'NebaDataTableEditType',
      default: 'NebaDataTableEditType.text'
    }),
    from('DataTableColumn', 'aggregate', { type: 'Widget Function(List<T> rows)?' }),
    from('DataTableColumn', 'exportValue', {
      type: 'Object? Function(T row)?',
      description: {
        ko: '내보내기가 이 셀에 쓰는 값. builder와 따로 둡니다. Chip을 그리는 셀에는 파일에 넣을 텍스트가 없기 때문입니다',
        en: 'What an export writes for this cell. Separate from builder: a cell that draws a Chip has no text to put in a file'
      }
    }),
    from('DataTableColumn', 'exportable', { type: 'bool' }),
    from('DataTableColumn', 'key', {
      type: 'String',
      description: {
        ko: '열을 식별하고, value가 없으면 Map인 행에서 읽을 항목의 이름이 됩니다',
        en: 'Identifies the column, and without a value names the entry to read off a row that is a Map'
      }
    }),
    from('DataTableColumn', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '머리글. Text이면 내보내기, 편집기, 크기 조절 핸들에서도 열의 이름으로 씁니다',
        en: 'The heading. A Text also names the column in an export, an editor and a resize handle'
      }
    }),
    from('DataTableColumn', 'group', { type: 'String?' }),
    from('DataTableColumn', 'width', {
      type: 'double?',
      description: {
        ko: '너비(논리 픽셀). 지정하지 않은 열들이 남은 공간을 나눕니다',
        en: 'How wide, in logical pixels. Columns that do not say share whatever is left'
      }
    }),
    from('DataTableColumn', 'minWidth', { type: 'double?' }),
    from('DataTableColumn', 'align / headerAlign', {
      type: 'NebaAlign / NebaAlign?',
      default: 'NebaAlign.start'
    }),
    from('DataTableColumn', 'sortable / resizable', { type: 'bool?' }),
    from('DataTableColumn', 'searchable', { type: 'bool' }),
    from('DataTableColumn', 'hidden', { type: 'bool', default: 'false' }),
    from('DataTableColumn', 'value', {
      type: 'Object? Function(T row)?',
      default: 'row[key]',
      description: {
        ko: '셀 뒤의 값. 정렬되고, 검색되고, builder 없는 셀에 쓰이고, 편집되는 것입니다. Map인 행은 생략하면 row[key]입니다',
        en: 'The value behind the cell: what is sorted, searched, written by a cell without a builder and edited. Defaults to row[key] for a row that is a Map'
      }
    }),
    from('DataTableColumn', 'compare', { type: 'int Function(T a, T b)?' }),
    renamed('DataTableColumn', 'render', 'builder', {
      type: 'Widget Function(BuildContext context, T row, int index)?'
    })
  ]
} satisfies Record<string, PropRow[]>;
