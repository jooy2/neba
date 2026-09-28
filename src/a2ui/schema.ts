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
 */

import { z } from 'zod';
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
  Action: () => CommonSchemas.Action,
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

  for (const part of parts) {
    if (part.$ref === `${COMMON}Checkable`) {
      built = built.merge(checkable);
      continue;
    }

    if (part.$ref) {
      throw new Error(
        `a2ui: ${name} is composed with ${part.$ref}, which this adapter cannot merge`
      );
    }

    checkKeywords(part, name, OBJECT_KEYWORDS);
    built = built.merge(shape(part, name));
  }

  return built;
}
