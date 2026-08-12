import * as React from 'react';
import { Box, type BoxProps } from '../box/Box';
import { controlTextLeadingClasses, metaTextClasses, paddingXValues } from '../../internal/styles';
import type { NebaAlign, NebaDensity, NebaSize } from '../../types';

/** Which edge the text in a column lines up against. */
export type TableAlign = NebaAlign;

/**
 * A column: its heading, its default width, and how to get a cell out of a row.
 *
 * This is the whole reason Table takes data rather than markup. A `<td>` written
 * out per row can silently disagree with the `<th>` above it about how many
 * there are or what order they come in; a column list cannot.
 */
export interface TableColumn<Row> {
  /**
   * Identifies the column, and — unless `render` says otherwise — names the
   * property to read off each row.
   */
  key: string;
  /** The heading. Defaults to the `key`, which is usually not what you want. */
  label?: React.ReactNode;
  /**
   * The column's default width. A number is pixels; a string is any CSS length
   * (`'30%'`, `'12rem'`, `'minmax(...)'` is not — this is a `<col>`, not a grid).
   *
   * "Default" is meant: the table still balances the columns to fill its width,
   * so this is a starting proportion rather than a guarantee.
   */
  width?: number | string;
  /**
   * Text alignment. Numbers usually want `end` so their digits line up in a
   * column; everything else wants `start`.
   * @default 'start'
   */
  align?: TableAlign;
  /**
   * Renders the cell. Without it the cell is `row[key]` rendered as-is, which
   * covers strings and numbers and nothing else.
   */
  render?: (row: Row, index: number) => React.ReactNode;
}

export interface TableProps<Row> extends Omit<
  BoxProps,
  'padded' | 'children' | 'render' | 'title'
> {
  /** The columns, in the order they appear. */
  headers: readonly TableColumn<Row>[];
  /** The rows. */
  items: readonly Row[];
  /**
   * A stable key per row. Defaults to the row's index, which is fine for a
   * static table and wrong for one that sorts or filters.
   */
  getRowKey?: (row: Row, index: number) => React.Key;
  /** Shown above the table, and read out as its accessible name. */
  caption?: React.ReactNode;
  /** What to show instead of rows when `items` is empty. */
  empty?: React.ReactNode;
  /**
   * Tints every other row. Useful for a wide table where the eye has to track
   * across; noise on a narrow one.
   * @default false
   */
  striped?: boolean;
  /** Lights the row under the pointer. @default false */
  hoverable?: boolean;
  /**
   * Pins the header while the body scrolls. Only does anything if something
   * around the table actually constrains its height.
   * @default false
   */
  stickyHeader?: boolean;
  /** Makes rows activatable. Also turns on the hover treatment. */
  onRowClick?: (row: Row, index: number) => void;
}

/**
 * Row height, as vertical padding — and, like the horizontal track, a raw
 * length rather than a class. See the note on `paddingXValues`.
 */
const cellPaddingYValues: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: '0.25rem', sm: '0.375rem', md: '0.625rem', lg: '0.75rem', xl: '0.875rem' },
  compact: { xs: '0.125rem', sm: '0.25rem', md: '0.375rem', lg: '0.5rem', xl: '0.625rem' }
};

/**
 * Everything a cell is painted with is written inline.
 *
 * This is the one component in the library that has to do that, and the reason
 * is the elements it renders. A Button owns its `<button>`; nobody else styles
 * it. A `<td>` is different — VitePress's `.vp-doc td`, Tailwind Typography's
 * `.prose td` and every CSS framework in existence style table cells by tag
 * name, at two-class specificity that a Tailwind utility of one class cannot
 * outrank. Padding, alignment, backgrounds and the rules between rows all
 * silently lost to the host before this was inline.
 *
 * What is *not* inline is the row's own background, because it has a hover
 * state and inline styles have no `:hover`. It reads a `--n-row` slot instead,
 * which classes then set — a custom property is invisible to a host stylesheet,
 * so a one-class variant wins there without a fight.
 */
const rowClasses = [
  '[--n-row:transparent]',
  '[transition:background-color_var(--neba-duration)_var(--neba-ease)]'
].join(' ');

/**
 * What a row that answers a press needs beyond the pointer treatment.
 *
 * `tabIndex` is the whole point: a row whose only way in is `onClick` is a
 * control that a keyboard cannot reach at all, and `cursor-pointer` advertises
 * it as one anyway. The ring is inset rather than offset, because the sheet
 * clips at its own rounded edge and an outline drawn outside the first or last
 * row is an outline with its top or bottom sliced off.
 *
 * The `role` is deliberately left alone. `role="button"` on a `<tr>` reads well
 * in isolation and takes the row semantics off it — which orphans every `<td>`
 * inside from the table they belong to, and costs a screen reader the column
 * headers, the row position and the count.
 */
const clickableRowClasses = [
  'cursor-pointer [outline:none]',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]'
].join(' ');

/**
 * The rule between rows is the same `--n-line` a Card scores its sections with,
 * so a table on a card and the card's own dividers are one family of lines.
 */
const rowRuleStyle: React.CSSProperties = {
  borderTop: '1px solid var(--n-line)',
  backgroundColor: 'var(--n-row)'
};

/**
 * A grid of data.
 *
 * The sheet is a Box — `variant`, `size`, `color`, `density` and `elevation` all
 * pass straight through, so a table is styled on the same axes as everything it
 * might sit next to. What Table adds is the part that is genuinely tabular: the
 * columns, the rows, and the fact that the two cannot drift apart.
 */
export function Table<Row>({
  headers,
  items,
  getRowKey,
  caption,
  empty,
  striped = false,
  hoverable = false,
  stickyHeader = false,
  onRowClick,
  size = 'md',
  density = 'default',
  className,
  ...boxProps
}: TableProps<Row>) {
  const padX = paddingXValues[density][size];
  const padY = cellPaddingYValues[density][size];
  const clickable = Boolean(onRowClick);
  const lit = hoverable || clickable;

  const cellStyle: React.CSSProperties = { padding: `${padY} ${padX}` };

  const headCellStyle: React.CSSProperties = {
    ...cellStyle,
    // The header sits one step up the sheet's opacity ladder rather than taking
    // a tint: it is still the container, and a coloured band behind a row of
    // column names is the fastest way to make data look like chrome.
    backgroundColor: 'var(--n-panel-press)'
  };

  return (
    <Box
      size={size}
      density={density}
      padded={false}
      className={['overflow-x-auto', className ?? ''].filter(Boolean).join(' ')}
      {...boxProps}
    >
      <table
        className={`w-full text-start ${controlTextLeadingClasses[size]} text-(--neba-fg)`}
        style={{ borderCollapse: 'collapse' }}
      >
        {caption ? (
          <caption
            className={`${metaTextClasses[size]} text-(--neba-muted-fg)`}
            style={{ ...cellStyle, textAlign: 'start' }}
          >
            {caption}
          </caption>
        ) : null}

        {/* Widths belong on a `<col>`, not on the first row's cells: a width set
            on a `<th>` is a width the browser is free to renegotiate against
            every other row, and only the column element states it once. */}
        <colgroup>
          {headers.map((column) => (
            <col
              key={column.key}
              style={
                column.width === undefined
                  ? undefined
                  : { width: typeof column.width === 'number' ? `${column.width}px` : column.width }
              }
            />
          ))}
        </colgroup>

        <thead>
          <tr>
            {headers.map((column) => (
              <th
                key={column.key}
                scope="col"
                className={[
                  'font-semibold whitespace-nowrap text-(--neba-muted-fg)',
                  stickyHeader ? 'sticky top-0 z-10 [backdrop-filter:var(--neba-blur)]' : ''
                ]
                  .filter(Boolean)
                  .join(' ')}
                style={{ ...headCellStyle, textAlign: column.align ?? 'start' }}
              >
                {column.label ?? column.key}
              </th>
            ))}
          </tr>
        </thead>

        <tbody>
          {items.length === 0 ? (
            <tr className={rowClasses} style={rowRuleStyle}>
              <td
                colSpan={headers.length}
                className="text-(--neba-muted-fg)"
                style={{ padding: `2rem ${padX}`, textAlign: 'center' }}
              >
                {empty ?? 'No data'}
              </td>
            </tr>
          ) : (
            items.map((row, index) => (
              <tr
                key={getRowKey ? getRowKey(row, index) : index}
                className={[
                  rowClasses,
                  striped && index % 2 === 1 ? '[--n-row:var(--n-panel-hover)]' : '',
                  lit ? 'hover:[--n-row:var(--n-soft)]' : '',
                  clickable ? clickableRowClasses : ''
                ]
                  .filter(Boolean)
                  .join(' ')}
                style={rowRuleStyle}
                tabIndex={clickable ? 0 : undefined}
                onClick={onRowClick ? () => onRowClick(row, index) : undefined}
                onKeyDown={
                  onRowClick
                    ? (event) => {
                        // Only the row's own keys. A cell can hold a link or a
                        // button, and those have an Enter of their own — running
                        // both would open the row and follow the link at once.
                        if (event.target !== event.currentTarget) {
                          return;
                        }

                        if (event.key !== 'Enter' && event.key !== ' ') {
                          return;
                        }

                        // Space scrolls the page otherwise, which is the one
                        // thing a reader pressing it on a row did not ask for.
                        event.preventDefault();
                        onRowClick(row, index);
                      }
                    : undefined
                }
              >
                {headers.map((column) => (
                  <td key={column.key} style={{ ...cellStyle, textAlign: column.align ?? 'start' }}>
                    {column.render
                      ? column.render(row, index)
                      : ((row as Record<string, unknown>)[column.key] as React.ReactNode)}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </Box>
  );
}
