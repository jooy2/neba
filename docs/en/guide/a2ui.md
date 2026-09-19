---
title: A2UI catalog
order: 4
---

# A2UI catalog

<p class="neba-lede">The package ships an A2UI catalog and a renderer to go with it. The catalog tells an agent which Neba components it may describe; the adapter turns what the agent writes back into those components. An agent writes a surface as JSON and it comes out as your design system.</p>

```ts
// What the agent is handed.
import catalog from 'neba/a2ui/catalog.json' with { type: 'json' };

// What draws what it writes back.
import { createNebaCatalog } from 'neba/a2ui';
```

The catalog is also served from the URL it names itself by:

```
https://neba.cdget.com/a2ui/catalog.json
```

## What A2UI is

[A2UI](https://a2ui.org) is a protocol for an agent describing an interface as JSON that the **host** renders with the host's own design system. The agent never writes markup and never writes CSS: it writes a flat map of components with IDs, and the renderer turns each one into whatever that design system calls it.

A catalog is how the two sides agree on the vocabulary. It is a single JSON Schema file with a `catalogId`, a set of `components`, a set of `functions` the renderer will execute, and `instructions` written for the model rather than for a reader. There is no registry: the `catalogId` is an identifier that only looks like a URL, and the spec says it does not have to point at anything. This one does anyway.

## Two halves, and you can take one

**`neba/a2ui/catalog.json` costs nothing.** It is JSON, so it never enters a bundle, and whether you render it with this library's adapter or with a renderer of your own is your decision. Take it alone and the mapping is yours.

**`neba/a2ui` is the adapter**, and it needs three packages this library does not install for you:

```bash
npm install @a2ui/react @a2ui/web_core zod
```

They are **optional peer dependencies**, which is safe here because `neba/a2ui` is not re-exported from `neba`: a bundler walking the package never reaches it, so a project that imports `Button` and has never heard of A2UI resolves nothing new. Only the import below pulls them in.

```tsx
import { MessageProcessor } from '@a2ui/web_core/v0_9';
import { A2uiSurface } from '@a2ui/react/v0_9';
import { createNebaCatalog } from 'neba/a2ui';

const processor = new MessageProcessor([createNebaCatalog()]);

processor.processMessages(whateverTheAgentSent);

// …then render each surface the agent created.
<A2uiSurface surface={surface} />;
```

That is the whole of it. The adapter registers the eighteen components and the fourteen functions, and the `catalogId` a surface names is the one in the file the agent was given — so the two halves cannot drift apart.

### What the adapter does, and does not

The renderer does the work: a prop the agent wrote as a literal, as a path into the data model or as a function call arrives at the component already resolved; a field's edits are written back to the data model; an action arrives as a function with its context gathered; a `checks` rule is evaluated as the data changes. What this package adds is the rename — `Alert`'s `child` is its children, `Select`'s `options` are its `items` — and putting a failed check's message where the field draws its own error.

The Zod schemas the renderer binds against are **derived from `catalog.json` at load time** rather than written a second time. That is the point: a hand-written mirror is a mirror that drifts, and the copy that drifts is the one the agent was never told about — a model writing exactly what the JSON allows, and a renderer rejecting it.

## The eighteen

The standard Basic Catalog is eighteen components and calls itself "intentionally sparse". This one is eighteen too, and the number is the decision rather than an accident: a model chooses badly from a list of a hundred and thirty-eight, and the components left out are the ones whose useful props are functions, React nodes or render props — things a JSON schema cannot describe at all.

| Group | Components |
| --- | --- |
| Layout and surface | `Flex` `Card` `Divider` `Alert` |
| Display | `Typography` `Image` `Chip` `Avatar` `Statistic` `DataList` |
| Inputs | `Button` `TextField` `NumberField` `Checkbox` `Switch` `RadioGroup` `Select` `Slider` |

`Table` is the most obvious absence and the clearest example of the rule: its columns are objects carrying render functions, so a catalog entry for it would be a schema the adapter had to invent rather than one the component already has.

The names are Neba's own rather than the Basic Catalog's, which is what makes the mapping on your side a lookup instead of a translation.

## What the model is told

`instructions` is the field the specification sets aside for design guidance, written for the model. This catalog's says the four things a screen gets wrong without them:

- **Nothing has a margin.** Two components sit beside each other only inside a `Flex`, and the gutter is that `Flex`'s `spacing`.
- **Colour is semantic.** Six families, each meaning something; `danger` is for what failed or what destroys, and none of them is a way of making a screen more varied. One `solid` control in a view.
- **One ladder.** `size` is the same five steps everywhere, so a row of controls lines up.
- **Fields carry their own words.** A `TextField` draws its own label and its own error; a `Typography` above it is a second label, and one below it is an error the field does not know about.

## Functions

Fourteen, with the specification's own names and call signatures: `required`, `length`, `regex`, `numeric`, `email`, `formatString`, `formatNumber`, `formatCurrency`, `formatDate`, `pluralize`, `openUrl`, `and`, `or` and `not`.

Declaring one is a claim that your renderer implements it. Ten of the fourteen are one `Intl` call, three are boolean arithmetic, and `openUrl` is the only one that does anything to the page — which is why it is declared `rendererOnly` and needing a user activation.

`formatString` is the one to know about: A2UI has no operators, so it is the only way to put a value into a sentence.

## Versions

The catalog is written against **A2UI v1.0**, which the file states in its own `protocolVersion`. The v0.9 catalog had a `theme` key and wrapped every component in a `ComponentCommon`; v1.0 has neither, and adds `instructions` and a `$defs` holding `anyComponent` and `anyFunction`.

**The adapter registers with `@a2ui/react/v0_9`**, because 0.11 has no v1.0 renderer — its root export is still v0.8. The eighteen components only use constructs the two versions share, which is what makes the bridge a rename rather than a translation, and the two differences that exist are both harmless: v1.0 moved `accessibility` out of the catalog entry and into the envelope, which the adapter puts back, and v1.0's `Action` gained a `userMessage` that the v0.9 schema strips rather than rejects.

The `@a2ui/*` packages are on 0.11.x while the specification is at 1.0, so expect the tooling to move before the format does. When there is a v1.0 React renderer, what changes is one import inside this package and nothing in `catalog.json`.

## Next

- The protocol: [a2ui.org](https://a2ui.org), and the [Basic Catalog](https://github.com/google/A2UI/blob/main/specification/v1_0/catalogs/basic/catalog.json) it is modelled on.
- What the props mean on the components themselves is under [Components](../components/).
