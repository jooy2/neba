/**
 * Whether the package still runs in the browsers its documentation promises.
 *
 * `docs/{en,ko}/browser-support.md` states a floor — Chrome and Edge 111,
 * Firefox 113, Safari 16.4 — and nothing else in this repository would notice
 * the day that stopped being true. The suite runs in the current release of
 * each engine, where every feature is there: a `text-wrap: pretty` or an
 * `Object.groupBy` passes the build, the type check and every test, and ships a
 * floor nobody chose.
 *
 * This reads what the package uses and asks MDN's compatibility data whether
 * every target has it. Two sources, because the floor is set in two places:
 *
 * - **`dist/styles.css`**, the stylesheet as it ships. Compiled rather than the
 *   source, because what reaches a browser is what Tailwind and Lightning CSS
 *   made of the source: prefixes added, nesting and range queries rewritten,
 *   fallbacks inserted.
 * - **`src/`**, through the TypeScript checker. A name is resolved to the lib
 *   declaration it came from — `Array.at`, `Element.checkVisibility`,
 *   `Intl.Segmenter` — so `items.at(-1)` is recognised for what it is and a
 *   method of the same name on a caller's own object is not. The syntax is
 *   checked too, since `tsc` emits it unchanged.
 *
 *   npm run compat
 *
 * It reads `dist/`, so `npm run build` has to have run first. The targets and
 * the features deliberately used past them are in `browser-support.json` beside
 * this file.
 *
 * What counts as guarded, and therefore passes:
 *
 * - CSS inside `@supports`, a declaration with an earlier declaration of the
 *   same property in its rule to fall back to, an unprefixed property whose
 *   prefixed form is in the same rule, and an argument of `:is()` or `:where()`
 *   with a sibling argument, since those lists are forgiving.
 * - JavaScript that is the operand of `typeof`, only read to be tested, called
 *   with `?.()`, or behind a condition that mentions the same member — an
 *   enclosing `if`, a ternary, an `&&`, or an earlier `if` that returns. Which
 *   branch the use is in is not checked.
 * - A keyword of a property, or a method of an object, where the browser lacks
 *   the property or the object as well. The use cannot be reached there, and
 *   the property or the constructor is checked where it is written.
 *
 * Anything used past the floor on purpose, with a fallback this cannot see, is
 * an exception in the JSON, with the reason written down. An exception nothing
 * uses any more fails the run as well: it is permission nobody is asking for,
 * and the next feature under that name would inherit it unread.
 *
 * What this does not see: CSS written into a `style` prop or a string in
 * JavaScript, attributes passed through JSX, event names, and a lib member
 * reached through a cast to a type of the component's own. A partial
 * implementation in the data counts as support. And the dependencies are not
 * read at all — Base UI declares its own range, and the documentation cites it.
 */
import { existsSync, readFileSync } from 'node:fs';
import { dirname, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import bcd from '@mdn/browser-compat-data' with { type: 'json' };
import postcss from 'postcss';
import ts from 'typescript';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const configFile = resolve(root, 'scripts/browser-support.json');
const stylesheet = resolve(root, 'dist/styles.css');

/* ---------------------------------------------------------------------------
 * The data
 * ------------------------------------------------------------------------- */

/** The compatibility entry at a dotted path, or `undefined`. */
function compatAt(path) {
  return path.split('.').reduce((node, key) => node?.[key], bcd)?.__compat;
}

/** `'16.4'` → `[16, 4]`; `'≤79'` counts as 79, `'preview'` as never. */
function parseVersion(version) {
  if (version === true) {
    return [0];
  }

  if (typeof version !== 'string' || version === 'preview') {
    return null;
  }

  return version.replace('≤', '').split('.').map(Number);
}

function atLeast(version, target) {
  for (let index = 0; index < Math.max(version.length, target.length); index += 1) {
    const difference = (version[index] ?? 0) - (target[index] ?? 0);

    if (difference !== 0) {
      return difference > 0;
    }
  }

  return true;
}

/**
 * Whether a browser at the target version has a feature.
 *
 * `prefixes` are the vendor prefixes the same rule also declares, which makes a
 * prefixed implementation count. An entry behind a flag never counts, and one
 * removed at or before the target does not either. `null` is "the data does not
 * say", which is not reported.
 */
function supports(compat, browser, target, prefixes = []) {
  const entries = [compat.support[browser]].flat().filter(Boolean);

  if (entries.length === 0 || entries.every((entry) => entry.version_added === null)) {
    return null;
  }

  return entries.some((entry) => {
    if (entry.flags || entry.alternative_name) {
      return false;
    }

    if (entry.prefix && !prefixes.includes(entry.prefix)) {
      return false;
    }

    const added = parseVersion(entry.version_added);
    const removed = parseVersion(entry.version_removed);

    return (
      added !== null && atLeast(target, added) && (removed === null || !atLeast(target, removed))
    );
  });
}

/** The targets a feature is missing from, by the data's browser key. */
function missingFrom(compat, targets, prefixes) {
  return Object.entries(targets)
    .filter(
      ([browser, target]) => supports(compat, browser, parseVersion(target), prefixes) === false
    )
    .map(([browser]) => browser);
}

/** `firefox` → `Firefox 121`, with the version the feature arrived in or left. */
function describeMissing(compat, browser) {
  const entries = [compat.support[browser]].flat();
  const plain = entries.find((entry) => !entry.prefix && !entry.flags && !entry.alternative_name);
  const name = bcd.browsers[browser].name;

  if (plain?.version_removed) {
    return `${name} (removed in ${plain.version_removed})`;
  }

  return `${name} ${typeof plain?.version_added === 'string' ? plain.version_added : '(no support)'}`;
}

/* ---------------------------------------------------------------------------
 * Findings
 * ------------------------------------------------------------------------- */

/** Every use of a feature past a target, by the feature's path in the data. */
const findings = new Map();

/**
 * Records a use, if some target is missing the feature.
 *
 * - `prefixes` makes a prefixed implementation count, for a property whose
 *   prefixed form is declared in the same rule.
 * - `alternatives` are other features that do the same job at the same place —
 *   `-webkit-mask-composite` beside `mask-composite` — so a browser is only
 *   missing it when it is missing all of them.
 * - `owner` is what the feature is a part of. A browser missing the owner is
 *   not counted here: a keyword on a property the browser drops, or a method of
 *   an object it cannot construct, is unreachable, and the owner's own use is
 *   checked where it is.
 */
function report(path, where, targets, { prefixes = [], alternatives = [], owner } = {}) {
  const compat = compatAt(path);

  if (!compat) {
    return;
  }

  let missing = missingFrom(compat, targets, prefixes);

  for (const alternative of alternatives.map(compatAt).filter(Boolean)) {
    const without = new Set(missingFrom(alternative, targets));

    missing = missing.filter((browser) => without.has(browser));
  }

  const ownerCompat = owner && compatAt(owner);

  if (ownerCompat) {
    const unreachable = new Set(missingFrom(ownerCompat, targets));

    missing = missing.filter((browser) => !unreachable.has(browser));
  }

  if (missing.length === 0) {
    return;
  }

  const finding = findings.get(path) ?? {
    missing: missing.map((browser) => describeMissing(compat, browser)),
    where: new Set()
  };

  finding.where.add(where);
  findings.set(path, finding);
}

/* ---------------------------------------------------------------------------
 * CSS
 * ------------------------------------------------------------------------- */

/**
 * Function names to their entries, read out of `css.types`.
 *
 * The data files a function under the type it produces — `color-mix` under
 * `color`, `blur` under `filter-function` — so the tree is walked once rather
 * than the path written out per function.
 */
const cssFunctions = new Map();

(function index(node, path) {
  for (const [key, child] of Object.entries(node)) {
    if (key === '__compat' || typeof child !== 'object') {
      continue;
    }

    // The shallowest entry of a name wins: `url` is `css.types.url`, not the
    // `url` type that `attr()` can be asked to parse its value as.
    const known = cssFunctions.get(key);

    if (child.__compat && (!known || known.split('.').length > path.split('.').length + 1)) {
      cssFunctions.set(key, `${path}.${key}`);
    }

    index(child, `${path}.${key}`);
  }
})(bcd.css.types, 'css.types');

/** The units the data tracks one at a time, and the three it tracks as a set. */
function unitPath(unit) {
  const lower = unit.toLowerCase();
  const group = [
    [/^dv(h|w|i|b|min|max)$/, 'viewport_percentage_units_dynamic'],
    [/^sv(h|w|i|b|min|max)$/, 'viewport_percentage_units_small'],
    [/^lv(h|w|i|b|min|max)$/, 'viewport_percentage_units_large'],
    [/^cq(h|w|i|b|min|max)$/, 'container_query_length_units']
  ].find(([pattern]) => pattern.test(lower));

  if (group) {
    return `css.types.length.${group[1]}`;
  }

  return bcd.css.types.length[unit] ? `css.types.length.${unit}` : undefined;
}

const vendor = /^-(webkit|moz|ms|o)-/;

/** Escapes, strings and attribute selectors out of the way of the scan. */
function neutralise(text) {
  return text
    .replace(/\\[\s\S]/g, '_')
    .replace(/"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'/g, '""')
    .replace(/url\([^)]*\)/g, 'url()');
}

/** Where the parenthesis opened at `start` closes. */
function closing(text, start) {
  let depth = 0;

  for (let index = start; index < text.length; index += 1) {
    if (text[index] === '(') {
      depth += 1;
    } else if (text[index] === ')' && --depth === 0) {
      return index;
    }
  }

  return text.length;
}

/** The comma-separated arguments of a selector list, at the top level only. */
function topLevel(text) {
  const parts = [];
  let depth = 0;
  let start = 0;

  for (let index = 0; index < text.length; index += 1) {
    if (text[index] === '(') depth += 1;
    else if (text[index] === ')') depth -= 1;
    else if (text[index] === ',' && depth === 0) {
      parts.push(text.slice(start, index));
      start = index + 1;
    }
  }

  return [...parts, text.slice(start)];
}

function scanSelector(selector, where, targets, forgiving = false) {
  const pattern = /::?(-?[a-zA-Z][\w-]*)(\()?/g;
  let match;

  while ((match = pattern.exec(selector))) {
    const [, name, opens] = match;
    const inner = opens
      ? selector.slice(pattern.lastIndex, closing(selector, pattern.lastIndex - 1))
      : '';

    if (!vendor.test(name) && !forgiving) {
      report(`css.selectors.${name}`, where, targets);
    }

    if (opens) {
      const list = name === 'is' || name === 'where' ? topLevel(inner) : [inner];

      for (const argument of list) {
        scanSelector(argument, where, targets, forgiving || list.length > 1);
      }

      pattern.lastIndex += inner.length + 1;
    }
  }
}

function scanValue(property, value, where, targets) {
  const text = neutralise(value)
    .replace(/#[\da-fA-F]+\b/g, '#')
    .replace(/!important/g, '');

  for (const [, name] of text.matchAll(/(?<![\w-])(-?[a-zA-Z][\w-]*)\(/g)) {
    if (!vendor.test(name) && cssFunctions.has(name)) {
      report(cssFunctions.get(name), where, targets);
    }
  }

  for (const [, unit] of text.matchAll(
    /(?<![\w.#-])[+-]?(?:\d+\.?\d*|\.\d+)([a-zA-Z]+)(?![\w-])/g
  )) {
    const path = unitPath(unit);

    if (path) {
      report(path, where, targets);
    }
  }

  // A keyword the data tracks as a feature of the property — `overflow: clip`,
  // `display: contents`. Not for a font stack: that is a list of fallbacks by
  // definition, and a family name the browser does not know is skipped.
  const own = bcd.css.properties[property];

  if (own && property !== 'font' && property !== 'font-family') {
    for (const [, keyword] of text.matchAll(/(?<![\w-])([a-zA-Z][\w-]*)(?![\w(-])/g)) {
      if (own[keyword]?.__compat) {
        report(`css.properties.${property}.${keyword}`, where, targets, {
          owner: `css.properties.${property}`
        });
      }
    }
  }
}

function checkStylesheet(targets) {
  const tree = postcss.parse(readFileSync(stylesheet, 'utf8'), { from: stylesheet });
  let read = 0;
  const file = relative(root, stylesheet);

  const guarded = (node) => {
    for (let parent = node.parent; parent; parent = parent.parent) {
      if (parent.type === 'atrule' && parent.name === 'supports') {
        return true;
      }
    }

    return false;
  };

  tree.walkAtRules((rule) => {
    if (guarded(rule) || vendor.test(rule.name)) {
      return;
    }

    const where = `${file} @${rule.name} ${rule.params}`.trim().slice(0, 100);

    report(`css.at-rules.${rule.name}`, where, targets);

    if (rule.name === 'media') {
      for (const [, feature] of rule.params.matchAll(/\(\s*([a-z-]+)\s*[:)<>=]/g)) {
        report(`css.at-rules.media.${feature.replace(/^(min|max)-/, '')}`, where, targets);
      }
    }
  });

  tree.walkRules((rule) => {
    read += 1;

    if (guarded(rule)) {
      return;
    }

    const inKeyframes = rule.parent?.type === 'atrule' && /keyframes$/.test(rule.parent.name);
    const where = `${file} ${rule.selector}`.slice(0, 100);

    if (!inKeyframes) {
      scanSelector(neutralise(rule.selector), where, targets);
    }

    const seen = new Set();
    const prefixed = new Map();

    rule.each((node) => {
      if (node.type === 'decl' && vendor.test(node.prop)) {
        const [prefix] = node.prop.match(vendor);
        const bare = node.prop.slice(prefix.length);

        prefixed.set(bare, [...(prefixed.get(bare) ?? []), prefix]);
      }
    });

    rule.each((node) => {
      if (node.type !== 'decl') {
        return;
      }

      const property = node.prop;
      const custom = property.startsWith('--');

      // A custom property is never dropped at parse time — an unsupported
      // value in one is only discovered where `var()` reads it — so an earlier
      // declaration of it is not a fallback for a later one.
      const fallback = !custom && seen.has(property);

      seen.add(property);

      if (vendor.test(property)) {
        return;
      }

      if (!custom) {
        const prefixes = prefixed.get(property) ?? [];

        report(`css.properties.${property}`, where, targets, {
          prefixes,
          alternatives: prefixes.map((prefix) => `css.properties.${prefix}${property}`)
        });
      }

      if (!fallback) {
        scanValue(custom ? '' : property, node.value, where, targets);
      }
    });
  });

  return read;
}

/* ---------------------------------------------------------------------------
 * JavaScript
 * ------------------------------------------------------------------------- */

/**
 * Where TypeScript declares a mixin, and where the data files its members.
 *
 * The DOM lib splits an interface into the mixins the specification defines —
 * `append` is `ParentNode`'s — while the data flattens them into the interface
 * a reader would name.
 */
const mixins = {
  ARIAMixin: 'Element',
  Animatable: 'Element',
  ChildNode: 'Element',
  DocumentOrShadowRoot: 'Document',
  ElementCSSInlineStyle: 'HTMLElement',
  ElementContentEditable: 'HTMLElement',
  HTMLOrSVGElement: 'HTMLElement',
  InnerHTML: 'Element',
  NonDocumentTypeChildNode: 'Element',
  NonElementParentNode: 'Document',
  ParentNode: 'Element',
  Slottable: 'Element',
  WindowOrWorkerGlobalScope: 'Window',
  AnimationFrameProvider: 'Window'
};

/** The lib types that are one builtin under another name. */
const builtinAliases = {
  ReadonlyArray: 'Array',
  ReadonlyMap: 'Map',
  ReadonlySet: 'Set',
  IteratorObject: 'Iterator',
  ArrayIterator: 'Iterator'
};

/** The data's paths a lib declaration could be filed under, most likely first. */
function candidatePaths(declaration) {
  const owners = [];

  for (let node = declaration.parent; node; node = node.parent) {
    if ((ts.isInterfaceDeclaration(node) || ts.isModuleDeclaration(node)) && node.name) {
      owners.unshift(node.name.text);
    }
  }

  const name =
    declaration.name && ts.isIdentifier(declaration.name) ? declaration.name.text : undefined;

  if (!name) {
    return [];
  }

  if (owners.length === 0) {
    return [`javascript.builtins.${name}`, `api.${name}`, `api.Window.${name}`];
  }

  const owner = owners
    .map((part) => mixins[part] ?? builtinAliases[part] ?? part.replace(/Constructor$/, ''))
    .join('.');

  return [
    `javascript.builtins.${owner}.${name}`,
    `api.${owner}.${name}`,
    `api.${owner}.${name}_static`
  ];
}

/** Whether a node is part of a type rather than of a value. */
function inType(node) {
  for (let parent = node.parent; parent; parent = parent.parent) {
    if (
      (parent.kind >= ts.SyntaxKind.FirstTypeNode && parent.kind <= ts.SyntaxKind.LastTypeNode) ||
      ts.isHeritageClause(parent)
    ) {
      return true;
    }

    if (ts.isStatement(parent) || ts.isSourceFile(parent)) {
      return false;
    }
  }

  return false;
}

/** Whether a condition mentions the symbol, or tests for it by name with `in`. */
function mentions(condition, symbol, name, checker) {
  let found = false;

  const visit = (node) => {
    if (found) {
      return;
    }

    if (
      ts.isBinaryExpression(node) &&
      node.operatorToken.kind === ts.SyntaxKind.InKeyword &&
      ts.isStringLiteral(node.left) &&
      node.left.text === name
    ) {
      found = true;

      return;
    }

    if (
      (ts.isIdentifier(node) || ts.isPrivateIdentifier(node)) &&
      checker.getSymbolAtLocation(node) === symbol
    ) {
      found = true;

      return;
    }

    ts.forEachChild(node, visit);
  };

  visit(condition);

  return found;
}

const exits = (statement) =>
  ts.isReturnStatement(statement) ||
  ts.isThrowStatement(statement) ||
  (ts.isBlock(statement) && statement.statements.some(exits));

/** Whether a use of `symbol` at `node` is behind a check for it. */
function isGuarded(node, symbol, name, checker) {
  const access =
    ts.isPropertyAccessExpression(node.parent) && node.parent.name === node ? node.parent : node;

  if (ts.isTypeOfExpression(access.parent)) {
    return true;
  }

  // Read and only tested — `el.checkVisibility ? … : …`, `!Intl.Segmenter` —
  // which is `undefined` rather than an error where the member is missing.
  const tested = access.parent;

  if (
    (ts.isPrefixUnaryExpression(tested) && tested.operator === ts.SyntaxKind.ExclamationToken) ||
    ((ts.isIfStatement(tested) || ts.isConditionalExpression(tested)) &&
      (tested.expression ?? tested.condition) === access) ||
    (ts.isBinaryExpression(tested) &&
      tested.left === access &&
      [
        ts.SyntaxKind.AmpersandAmpersandToken,
        ts.SyntaxKind.BarBarToken,
        ts.SyntaxKind.QuestionQuestionToken
      ].includes(tested.operatorToken.kind))
  ) {
    return true;
  }

  if (
    ts.isCallExpression(access.parent) &&
    access.parent.expression === access &&
    access.parent.questionDotToken
  ) {
    return true;
  }

  let child = access;

  for (let parent = access.parent; parent; child = parent, parent = parent.parent) {
    if (
      ts.isIfStatement(parent) &&
      child !== parent.expression &&
      mentions(parent.expression, symbol, name, checker)
    ) {
      return true;
    }

    if (
      ts.isConditionalExpression(parent) &&
      child !== parent.condition &&
      mentions(parent.condition, symbol, name, checker)
    ) {
      return true;
    }

    if (
      ts.isBinaryExpression(parent) &&
      parent.operatorToken.kind === ts.SyntaxKind.AmpersandAmpersandToken &&
      child === parent.right &&
      mentions(parent.left, symbol, name, checker)
    ) {
      return true;
    }

    // An earlier `if (!supported) return;` in any block the use is inside.
    if (ts.isBlock(parent) || ts.isSourceFile(parent)) {
      for (const statement of parent.statements) {
        if (statement === child) {
          break;
        }

        if (
          ts.isIfStatement(statement) &&
          exits(statement.thenStatement) &&
          mentions(statement.expression, symbol, name, checker)
        ) {
          return true;
        }
      }
    }
  }

  return false;
}

/**
 * Syntax, by what the data calls it. Written out, and each path checked to
 * exist below, so a renamed entry fails loudly instead of passing forever.
 */
const syntax = {
  using: 'javascript.statements.using',
  awaitUsing: 'javascript.statements.await_using',
  logicalAssignment: 'javascript.operators.nullish_coalescing_assignment',
  privateFields: 'javascript.classes.private_class_fields',
  privateIn: 'javascript.classes.private_class_fields_in',
  publicFields: 'javascript.classes.public_class_fields',
  importAttributes: 'javascript.statements.import.import_attributes',
  unicodeSets: 'javascript.builtins.RegExp.unicodeSets',
  hasIndices: 'javascript.builtins.RegExp.hasIndices',
  lookbehind: 'javascript.regular_expressions.lookbehind_assertion',
  modifiers: 'javascript.regular_expressions.modifier',
  duplicateGroups:
    'javascript.regular_expressions.named_capturing_group.duplicate_named_capturing_groups',
  numericSeparators: 'javascript.grammar.numeric_separators'
};

for (const path of Object.values(syntax)) {
  if (!compatAt(path)) {
    throw new Error(
      `${path} is not in @mdn/browser-compat-data any more; update scripts/check-browsers.mjs`
    );
  }
}

function checkSyntax(node, where, targets) {
  if (ts.isVariableDeclarationList(node)) {
    if ((node.flags & ts.NodeFlags.AwaitUsing) === ts.NodeFlags.AwaitUsing) {
      report(syntax.awaitUsing, where, targets);
    } else if (node.flags & ts.NodeFlags.Using) {
      report(syntax.using, where, targets);
    }
  }

  if (
    ts.isBinaryExpression(node) &&
    [
      ts.SyntaxKind.QuestionQuestionEqualsToken,
      ts.SyntaxKind.BarBarEqualsToken,
      ts.SyntaxKind.AmpersandAmpersandEqualsToken
    ].includes(node.operatorToken.kind)
  ) {
    report(syntax.logicalAssignment, where, targets);
  }

  if (ts.isBinaryExpression(node) && ts.isPrivateIdentifier(node.left)) {
    report(syntax.privateIn, where, targets);
  }

  if (ts.isPrivateIdentifier(node)) {
    report(syntax.privateFields, where, targets);
  }

  if (ts.isPropertyDeclaration(node) && ts.isClassLike(node.parent)) {
    report(syntax.publicFields, where, targets);
  }

  if ((ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) && node.attributes) {
    report(syntax.importAttributes, where, targets);
  }

  if (ts.isNumericLiteral(node) && node.getText().includes('_')) {
    report(syntax.numericSeparators, where, targets);
  }

  if (ts.isRegularExpressionLiteral(node)) {
    const end = node.text.lastIndexOf('/');
    const body = node.text.slice(1, end);
    const flags = node.text.slice(end + 1);
    // Every group opener here is one not escaped with a backslash: `\(?i:` is
    // an optional literal parenthesis followed by `i:`, not a modifier.
    const groups = [...body.matchAll(/(?<!\\)\(\?<([A-Za-z_$][\w$]*)>/g)].map(([, group]) => group);

    if (flags.includes('v')) report(syntax.unicodeSets, where, targets);
    if (flags.includes('d')) report(syntax.hasIndices, where, targets);
    if (/(?<!\\)\(\?<[=!]/.test(body)) report(syntax.lookbehind, where, targets);
    if (/(?<!\\)\(\?(?:[ims]+(?:-[ims]+)?|-[ims]+):/.test(body))
      report(syntax.modifiers, where, targets);
    if (new Set(groups).size < groups.length) report(syntax.duplicateGroups, where, targets);
  }
}

function checkSource(targets) {
  const configPath = resolve(root, 'tsconfig.prod.json');
  const parsed = ts.getParsedCommandLineOfConfigFile(
    configPath,
    {},
    { ...ts.sys, onUnRecoverableConfigFileDiagnostic() {} }
  );
  const program = ts.createProgram({ rootNames: parsed.fileNames, options: parsed.options });
  const checker = program.getTypeChecker();
  // TypeScript names files with forward slashes on every platform.
  const source = `${resolve(root, 'src').replaceAll('\\', '/')}/`;
  let read = 0;

  for (const sourceFile of program.getSourceFiles()) {
    if (program.isSourceFileDefaultLibrary(sourceFile) || !sourceFile.fileName.startsWith(source)) {
      continue;
    }

    read += 1;

    const file = relative(root, sourceFile.fileName);

    const visit = (node) => {
      const where = () =>
        `${file}:${sourceFile.getLineAndCharacterOfPosition(node.getStart(sourceFile)).line + 1}`;

      checkSyntax(node, where(), targets);

      if (ts.isIdentifier(node) && !inType(node)) {
        const found = checker.getSymbolAtLocation(node);
        const symbol =
          found && found.flags & ts.SymbolFlags.Alias ? checker.getAliasedSymbol(found) : found;
        const declarations = (symbol?.declarations ?? []).filter((declaration) =>
          program.isSourceFileDefaultLibrary(declaration.getSourceFile())
        );

        // A value declaration where there is one: `ResizeObserver` the
        // constructor rather than `ResizeObserver` the interface.
        const declaration =
          declarations.find((candidate) => !ts.isInterfaceDeclaration(candidate)) ??
          declarations[0];

        if (declaration && !isGuarded(node, symbol, node.text, checker)) {
          const path = candidatePaths(declaration).find(compatAt);

          if (path) {
            report(path, where(), targets, {
              owner: path
                .replace(/(_static)?$/, '')
                .split('.')
                .slice(0, -1)
                .join('.')
            });
          }
        }
      }

      ts.forEachChild(node, visit);
    };

    visit(sourceFile);
  }

  return read;
}

/* ---------------------------------------------------------------------------
 * The run
 * ------------------------------------------------------------------------- */

/**
 * The exit code is set rather than forced, for `measure-bundle.mjs`'s reason:
 * `process.exit` truncates whatever stdout has not flushed yet.
 */
function main() {
  if (!existsSync(stylesheet)) {
    console.error(
      'dist/styles.css is missing. This checks the built stylesheet:\n\n  npm run build\n'
    );
    process.exitCode = 1;

    return;
  }

  const config = JSON.parse(readFileSync(configFile, 'utf8'));
  const { targets } = config;

  // An exception covers the feature and everything filed under it, so
  // `css.properties.cursor` answers for every cursor keyword at once.
  const covers = (feature, path) => path === feature || path.startsWith(`${feature}.`);
  const allowed = (path) => config.exceptions.some(({ feature }) => covers(feature, path));

  console.log(
    `\n${config.source} ${bcd.__meta.version}, against ` +
      `${Object.entries(targets)
        .map(([browser, version]) => `${bcd.browsers[browser].name} ${version}`)
        .join(', ')}\n`
  );

  const rules = checkStylesheet(targets);
  const files = checkSource(targets);

  // A check that read nothing passes everything, which is the one failure it
  // would never report on its own.
  if (rules === 0 || files === 0) {
    console.error(`Read ${rules} CSS rules and ${files} source files; expected both to be many.\n`);
    process.exitCode = 1;

    return;
  }

  console.log(`  read ${rules} rules in dist/styles.css and ${files} files in src/\n`);

  const failures = [...findings].filter(([path]) => !allowed(path));
  const stale = config.exceptions
    .map(({ feature }) => feature)
    .filter((feature) => ![...findings.keys()].some((path) => covers(feature, path)));

  for (const { feature } of config.exceptions) {
    const covered = [...findings].filter(([path]) => covers(feature, path));
    const missing = new Set(covered.flatMap(([, finding]) => finding.missing));
    const uses = covered.reduce((sum, [, finding]) => sum + finding.where.size, 0);

    if (covered.length > 0) {
      console.log(
        `  allowed  ${feature}  (${[...missing].join(', ')}; ${uses} use${uses === 1 ? '' : 's'})`
      );
    }
  }

  if (failures.length === 0 && stale.length === 0) {
    console.log(
      '\nNothing the package uses is missing from a target, beyond the exceptions above.\n'
    );

    return;
  }

  for (const [path, { missing, where }] of failures) {
    const places = [...where];

    console.error(`\n  ${path}\n    missing from ${missing.join(', ')}`);

    for (const place of places.slice(0, 5)) {
      console.error(`    ${place}`);
    }

    if (places.length > 5) {
      console.error(`    and ${places.length - 5} more`);
    }
  }

  for (const path of stale) {
    console.error(
      `\n  ${path}\n    is an exception in scripts/browser-support.json that nothing uses any more`
    );
  }

  console.error(
    '\nEither guard the use — `@supports`, a fallback declaration, a feature check — or, if\n' +
      'going without it is acceptable, add it to the exceptions in scripts/browser-support.json\n' +
      'with the reason. If a reader can see the difference, describe it in\n' +
      'docs/{en,ko}/browser-support.md as well. Remove an exception that nothing uses.\n'
  );

  process.exitCode = 1;
}

main();
