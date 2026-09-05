import { propTables as props } from './props';
const out: Record<string, string[]> = {};
function walk(rows: any[], acc: string[]) {
  for (const r of rows ?? []) {
    if (r?.name) acc.push(r.name);
    for (const k of ['children', 'props', 'rows']) if (Array.isArray(r?.[k])) walk(r[k], acc);
  }
}
for (const [k, v] of Object.entries(props as any)) {
  const a: string[] = [];
  walk(v as any[], a);
  out[k] = a;
}
console.log(JSON.stringify(out));
