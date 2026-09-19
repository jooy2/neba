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
 * how a prop stops being validated without anybody noticing. Anything
 * unrecognised throws, and `test/package/a2ui.test.ts` converts every component
 * in the catalog so the throw happens here rather than in someone's renderer.
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
  enum?: readonly string[];
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
  if (schema.$ref) {
    const name = schema.$ref.startsWith(COMMON) ? schema.$ref.slice(COMMON.length) : '';
    const build = commonTypes[name];

    if (!build) {
      throw new Error(`a2ui: ${at} refers to ${schema.$ref}, which this adapter does not know`);
    }

    return build();
  }

  if (schema.enum) {
    return z.enum(schema.enum as [string, ...string[]]);
  }

  switch (schema.type) {
    case 'string':
      return z.string();
    case 'number':
    case 'integer':
      return z.number();
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
        : // `.optional()` after `.default()` and not the other way round: the
          // wire may leave the prop out, and the default is what it means then.
          value.default(property.default as never).optional();
  }

  return z.object(entries);
}

/**
 * One component's entry, as the schema a `ComponentApi` carries.
 *
 * `accessibility` is added rather than read, because v1.0 moved it out of the
 * catalog and into the envelope while the renderer this adapter registers with
 * still expects a component to declare it. It is the one place the two versions
 * are bridged rather than mapped.
 */
export function componentSchema(name: string, definition: CatalogSchema): z.ZodTypeAny {
  const parts = definition.allOf ?? [definition];
  let built: z.ZodObject<z.ZodRawShape> = z.object({
    accessibility: CommonSchemas.AccessibilityAttributes.optional()
  });

  for (const part of parts) {
    if (part.$ref === `${COMMON}Checkable`) {
      built = built.merge(CommonSchemas.Checkable as z.ZodObject<z.ZodRawShape>);
      continue;
    }

    if (part.$ref) {
      throw new Error(
        `a2ui: ${name} is composed with ${part.$ref}, which this adapter cannot merge`
      );
    }

    built = built.merge(shape(part, name));
  }

  return built;
}
