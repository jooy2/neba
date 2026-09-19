---
title: A2UI catalog
order: 4
---

# A2UI catalog

<p class="neba-lede">The package ships an A2UI catalog: a JSON Schema file that tells an agent which Neba components it may describe and what each one takes. An agent writes a surface as JSON, your renderer draws it with the components you already have.</p>

```ts
import catalog from 'neba/a2ui/catalog.json' with { type: 'json' };
```

It is also served from the URL it names itself by:

```
https://neba.cdget.com/a2ui/catalog.json
```

## What A2UI is

[A2UI](https://a2ui.org) is a protocol for an agent describing an interface as JSON that the **host** renders with the host's own design system. The agent never writes markup and never writes CSS: it writes a flat map of components with IDs, and the renderer turns each one into whatever that design system calls it.

A catalog is how the two sides agree on the vocabulary. It is a single JSON Schema file with a `catalogId`, a set of `components`, a set of `functions` the renderer will execute, and `instructions` written for the model rather than for a reader. There is no registry: the `catalogId` is an identifier that only looks like a URL, and the spec says it does not have to point at anything. This one does anyway.

## What ships, and what does not

**The catalog, and nothing else.** There is no renderer in this package, no adapter, and no new dependency — a catalog is JSON, so it never enters a bundle and `npm run size` does not move. What it costs is about 57 kB of the published tarball.

Wiring it up is yours, and it is two things: tell the agent the vocabulary, and map a component name onto the component. Both are small, and both belong in your application rather than here, because only you know which model you are calling and how your surfaces reach the page.

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

Written against **A2UI v1.0**, which the file states in its own `protocolVersion`. The v0.9 catalog had a `theme` key and wrapped every component in a `ComponentCommon`; v1.0 has neither, and adds `instructions` and a `$defs` holding `anyComponent` and `anyFunction`. The packages under `@a2ui/*` are still on 0.11.x while the specification is at 1.0, so expect the tooling around it to move before the format does.

## Next

- The protocol: [a2ui.org](https://a2ui.org), and the [Basic Catalog](https://github.com/google/A2UI/blob/main/specification/v1_0/catalogs/basic/catalog.json) it is modelled on.
- What the props mean on the components themselves is under [Components](../components/).
