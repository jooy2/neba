/**
 * A table as CSV.
 *
 * It is here rather than in DataTable because the escaping is the whole job and
 * getting it wrong is silent: a comma inside a cell shifts every column after
 * it by one, and nobody notices until a spreadsheet somewhere is off by a
 * column. RFC 4180 is four rules, and all four are below.
 */

/**
 * One field, quoted only when it has to be.
 *
 * A field is quoted if it holds the separator, a quote, or a line break, and a
 * quote inside a quoted field is written twice. `null` and `undefined` are
 * empty rather than the words "null" and "undefined", which is what `String()`
 * would put in a spreadsheet cell.
 */
export function csvField(value: unknown, separator = ','): string {
  if (value === null || value === undefined) {
    return '';
  }

  const text =
    value instanceof Date
      ? value.toISOString()
      : typeof value === 'object'
        ? JSON.stringify(value)
        : String(value);

  return /["\r\n]/.test(text) || text.includes(separator)
    ? `"${text.replaceAll('"', '""')}"`
    : text;
}

export interface CsvOptions {
  /** What goes between fields. `;` for the locales whose spreadsheets expect it. */
  separator?: string;
  /**
   * Writes a byte-order mark in front.
   *
   * On by default, and not as a nicety: Excel reads a UTF-8 CSV without one as
   * the local code page, so every non-ASCII name in the file arrives as
   * mojibake. Every other reader ignores the mark.
   */
  bom?: boolean;
}

/** Rows of already-stringable values, as one CSV document. */
export function toCsv(rows: readonly (readonly unknown[])[], options: CsvOptions = {}): string {
  const { separator = ',', bom = true } = options;

  // CRLF, which is what RFC 4180 says and what the spreadsheets that care
  // about the BOM also expect.
  const body = rows
    .map((row) => row.map((field) => csvField(field, separator)).join(separator))
    .join('\r\n');

  // Written as an escape rather than as the character: a lone zero-width
  // no-break space in a source file is invisible to every reviewer.
  return bom ? `\uFEFF${body}` : body;
}

/**
 * Hands the file to the browser.
 *
 * A `blob:` URL and a synthesised click, which is the only way a page can
 * produce a file the reader keeps. The URL is revoked on the next frame rather
 * than immediately: some browsers have not finished reading it when the click
 * returns, and revoking too early is a download that silently produces nothing.
 */
export function downloadText(text: string, fileName: string, type: string): void {
  const url = URL.createObjectURL(new Blob([text], { type }));
  const anchor = document.createElement('a');

  anchor.href = url;
  anchor.download = fileName;
  anchor.rel = 'noopener';
  anchor.style.display = 'none';

  document.body.append(anchor);
  anchor.click();
  anchor.remove();

  requestAnimationFrame(() => URL.revokeObjectURL(url));
}
