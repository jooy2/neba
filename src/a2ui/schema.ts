/**
 * The catalog's JSON Schema, as the Zod the renderer wants.
 *
 * `catalog.json` is what an **agent** is handed; a `ComponentApi` carries a Zod
 * schema, which is what the **renderer** binds and validates against. Writing
 * both by hand is writing the eighteen components twice, and the copy that
 * drifts is the one the agent was never told about — a model writing exactly
 * what the JSON allows, and a renderer rejecting it. So the JSON is the source
 * and this is the derivation.
 *
 * It handles the subset `catalog.json` actually uses and nothing more. That is
 * deliberate: a general JSON-Schema-to-Zod converter is a dependency, and a
 * partial one that quietly returns `z.any()` for a construct it has not met is
 * how a prop stops being validated without anybody noticing. A keyword it does
 * not know throws, and so does a `type` or a `$ref` it has not met;
 * `test/a2ui/adapter.test.tsx` converts every component in the catalog so the
 * throw happens there rather than in someone's renderer.
 *
 * The `$ref`s are the load-bearing part. `componentId()` and `childList()` are
 * not decoration over `z.string()`: the node layer reads a marker off those
 * schemas to work out which props are child references, so a `Card.child` built
 * from a bare string is a card that never resolves its child.
 *
 * The import is `zod/v3` rather than `zod` because `web_core` builds its
 * schemas with Zod 3, and the ones built here sit in the same objects as
 * those. Zod 3.25 and every Zod 4 serve the v3 API at that path, so the peer
 * range takes both: under Zod 3 it is the package root by another name, and
 * under Zod 4 it is the copy of v3 that ships inside it, while `web_core`
 * installs a Zod 3 of its own. Two copies of v3 are two sets of classes, so
 * nothing here may let an object built by one reach the other's `instanceof` —
 * see `componentSchema`. `web_core` reads the result by `_def.typeName` and
 * never by class, so the renderer does not care which copy built it.
 */

import { z } from 'zod/v3';
import { childList, CommonSchemas, componentId } from '@a2ui/web_core/v0_9';

/** As much of JSON Schema as the catalog is written in. */
export interface CatalogSchema {
  $ref?: string;
  type?: string;
  enum?: readonly (string | number)[];
  const?: string;
  default?: unknown;
  description?: string;
  properties?: Record<string, CatalogSchema>;
  required?: readonly string[];
  items?: CatalogSchema;
  allOf?: readonly CatalogSchema[];
  minimum?: number;
  additionalProperties?: boolean;
}

const COMMON = 'https://a2ui.org/specification/v1_0/common_types.json#/$defs/';

/**
 * The keywords a property may carry. `description` is read by the agent and
 * not by the renderer, so it is known and left alone; everything else here is
 * turned into Zod below. `const` is not among them: the one `const` in the
 * catalog is on `component`, which `shape` skips before it gets here.
 */
const KEYWORDS = new Set([
  '$ref',
  'type',
  'enum',
  'default',
  'description',
  'properties',
  'required',
  'items',
  'minimum',
  'additionalProperties'
]);

/** The keywords a component's own object may carry, `allOf` aside. */
const OBJECT_KEYWORDS = new Set([
  'type',
  'description',
  'properties',
  'required',
  'additionalProperties'
]);

/** Throws on a keyword `convert` would otherwise pass over in silence. */
function checkKeywords(schema: CatalogSchema, at: string, allowed: ReadonlySet<string>): void {
  for (const keyword of Object.keys(schema)) {
    if (!allowed.has(keyword)) {
      throw new Error(`a2ui: ${at} uses \`${keyword}\`, which this adapter does not know`);
    }
  }
}

/**
 * The common types the catalog refers to, and what each one is in Zod.
 *
 * `Checkable` is not here because it is never a property: it arrives through an
 * `allOf` and merges into the component's own shape, which is what gives the
 * binder its `isValid` and `validationErrors`.
 */
const commonTypes: Record<string, () => z.ZodTypeAny> = {
  Action: () => action,
  Child: () => componentId(),
  ChildList: () => childList(),
  DynamicBoolean: () => CommonSchemas.DynamicBoolean,
  DynamicNumber: () => CommonSchemas.DynamicNumber,
  DynamicString: () => CommonSchemas.DynamicString
};

/** One property, or one whole component's own object. */
function convert(schema: CatalogSchema, at: string): z.ZodTypeAny {
  checkKeywords(schema, at, KEYWORDS);

  if (schema.$ref) {
    const name = schema.$ref.startsWith(COMMON) ? schema.$ref.slice(COMMON.length) : '';
    const build = commonTypes[name];

    if (!build) {
      throw new Error(`a2ui: ${at} refers to ${schema.$ref}, which this adapter does not know`);
    }

    return build();
  }

  if (schema.enum) {
    const values = schema.enum;

    // `z.enum` takes strings and refuses everything else, so an enum of numbers
    // — `elevation` is `0` to `3` — is a union of literals instead.
    if (values.every((value) => typeof value === 'string')) {
      return z.enum(values as [string, ...string[]]);
    }

    const literals = values.map((value) => z.literal(value));

    return literals.length === 1
      ? literals[0]
      : z.union(literals as unknown as [z.ZodLiteral<number>, z.ZodLiteral<number>]);
  }

  if (schema.minimum !== undefined && schema.type !== 'number' && schema.type !== 'integer') {
    throw new Error(`a2ui: ${at} has a minimum but is not a number`);
  }

  switch (schema.type) {
    case 'string':
      return z.string();
    case 'number':
    case 'integer': {
      const number = schema.type === 'integer' ? z.number().int() : z.number();

      return schema.minimum === undefined ? number : number.min(schema.minimum);
    }
    case 'boolean':
      return z.boolean();
    case 'array':
      if (!schema.items) {
        throw new Error(`a2ui: ${at} is an array with no items`);
      }

      return z.array(convert(schema.items, `${at}[]`));
    case 'object':
      return shape(schema, at);
    default:
      throw new Error(`a2ui: ${at} has a type this adapter does not know`);
  }
}

/** An object's properties, with the required ones required and the rest not. */
function shape(schema: CatalogSchema, at: string): z.ZodObject<z.ZodRawShape> {
  // `false` is what the catalog says and what Zod does anyway: an object it
  // parses keeps only the keys it declares. A key an agent adds is dropped
  // rather than refused, because a refusal drops the whole message with it.
  if (schema.additionalProperties === true) {
    throw new Error(`a2ui: ${at} allows any property, which this adapter cannot check`);
  }

  const required = new Set(schema.required ?? []);
  const entries: z.ZodRawShape = {};

  for (const [name, property] of Object.entries(schema.properties ?? {})) {
    // `component` is the envelope's, not the component's: `ComponentApi` says
    // so, and a schema that declared it would reject every node that carries it.
    if (name === 'component') {
      continue;
    }

    const value = convert(property, `${at}.${name}`);

    entries[name] =
      property.default === undefined
        ? required.has(name)
          ? value
          : value.optional()
        : // Zod never applies this default — `.optional()` answers a missing
          // prop before the default is reached, and the view leaves it to the
          // component's own. It is here for the inline catalog `web_core`
          // writes out of these schemas, which then says what the JSON says.
          value.default(property.default as never).optional();
  }

  return z.object(entries);
}

/**
 * `Checkable`, with v1.0's rule rather than v0.9's.
 *
 * v1.0 lets a check leave its `message` out, and v0.9's rule requires one — so
 * a check an agent wrote exactly as the catalog allows was refused, and the
 * refusal took the whole batch of components with it. The binder already
 * answers a missing message with "Validation failed", which is why the only
 * change is to stop refusing it; the catalog asks the model for a message all
 * the same, since that text tells a reader nothing.
 */
const checkable = (() => {
  const base = CommonSchemas.Checkable as z.ZodObject<z.ZodRawShape>;
  const rule = (CommonSchemas.CheckRule as z.ZodObject<z.ZodRawShape>).extend({
    message: z.string().optional()
  });
  const checks = base.shape.checks as z.ZodTypeAny;

  return base.extend({
    checks: z
      .array(rule)
      .optional()
      .describe(checks.description ?? '')
  });
})();

/**
 * `Action`, with v1.0's `userMessage`.
 *
 * v1.0 gave an action's event a `userMessage`, the line a host shows as what
 * the reader asked for, and v0.9's event refuses a key it does not declare —
 * so a button written exactly as the catalog allows was refused with the rest
 * of its component. The binder already resolves a `userMessage` and the surface
 * hands it to the host, so the only change is to stop refusing it. The
 * description is kept, because it is how the binder knows the prop is an action.
 */
const action = (() => {
  const [event, functionCall] = (
    CommonSchemas.Action as z.ZodUnion<[z.ZodObject<z.ZodRawShape>, z.ZodTypeAny]>
  ).options;
  const inner = event.shape.event as z.ZodObject<z.ZodRawShape>;

  return z
    .union([
      event.extend({
        event: inner.extend({ userMessage: CommonSchemas.DynamicString.optional() })
      }),
      functionCall
    ])
    .describe(CommonSchemas.Action.description ?? '');
})();

/**
 * The arguments the catalog declares wider than `web_core` does.
 *
 * `web_core` parses a call's arguments twice: as the agent wrote them, when a
 * component arrives, and resolved, before the function runs. Its v0.9 schemas
 * are narrower than this catalog in two places, and each refused a call the
 * catalog allows. `numeric`'s `value` is a number there and a string here,
 * because what a check reads is the text a `TextField` holds, so a field
 * holding "42" failed the check it passes. `openUrl`'s `url` is a literal there
 * and may be bound here, so a button that opened an address from the data
 * model was refused with the rest of its component. Both functions already
 * take what the catalog declares — `numeric` reads a string as a number, and
 * text that is not one fails the check — so the only change is to stop
 * refusing it.
 */
const widenedArguments: Record<string, () => z.ZodRawShape> = {
  numeric: () => ({
    value: z.union([CommonSchemas.DynamicNumber, CommonSchemas.DynamicString])
  }),
  openUrl: () => ({ url: CommonSchemas.DynamicString })
};

/**
 * A function's argument schema, as wide as the catalog declares it.
 *
 * `extend` for `componentSchema`'s reason: the schema is built by `web_core`'s
 * copy of Zod, and only the arguments named above are this copy's.
 */
export function functionSchema(name: string, schema: z.ZodTypeAny): z.ZodTypeAny {
  const widened = widenedArguments[name];

  return widened ? (schema as z.ZodObject<z.ZodRawShape>).extend(widened()) : schema;
}

/**
 * One component's entry, as the schema a `ComponentApi` carries.
 *
 * `accessibility` is added rather than read, because v1.0 moved it out of the
 * catalog and into the envelope while the renderer this adapter registers with
 * still expects a component to declare it. That and a check's optional
 * `message`, above, are the two places the versions are bridged rather than
 * mapped.
 */
export function componentSchema(name: string, definition: CatalogSchema): z.ZodTypeAny {
  const parts = definition.allOf ?? [definition];
  let built: z.ZodObject<z.ZodRawShape> = z.object({
    accessibility: CommonSchemas.AccessibilityAttributes.optional()
  });

  // `extend` with a shape, never `merge` with an object: `merge` takes the
  // other object's `catchall`, and `checkable` is built by `web_core`'s copy of
  // Zod, which under a project's Zod 4 is not this one. Its `ZodNever` then
  // fails this copy's `instanceof`, and the object refuses every key it does
  // not declare — so a component whose `allOf` ended on `Checkable` would drop
  // a node over a stray key instead of stripping it.
  for (const part of parts) {
    if (part.$ref === `${COMMON}Checkable`) {
      built = built.extend(checkable.shape);
      continue;
    }

    if (part.$ref) {
      throw new Error(
        `a2ui: ${name} is composed with ${part.$ref}, which this adapter cannot merge`
      );
    }

    checkKeywords(part, name, OBJECT_KEYWORDS);
    built = built.extend(shape(part, name).shape);
  }

  return built;
}
