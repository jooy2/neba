/*
 * A module of its own, with no 'use client', so a Server Component can call it:
 * exported from `FilePicker.tsx` it reached one as a client reference, and
 * calling that throws.
 */

/**
 * `1.4 MB`, in the units a person reading a file list expects.
 *
 * Base 1000 rather than 1024, and `MB` rather than `MiB`: it is the number every
 * operating system's file browser shows, and a picker that disagrees with the
 * Finder about how big the file is has picked a fight it cannot win.
 */
export function formatFileSize(bytes: number): string {
  if (bytes < 1000) {
    return `${bytes} B`;
  }

  const units = ['kB', 'MB', 'GB', 'TB'];
  let value = bytes / 1000;
  let unit = 0;

  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit += 1;
  }

  return `${value < 10 ? value.toFixed(1) : Math.round(value)} ${units[unit]}`;
}
