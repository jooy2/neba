# TODO

Work that has been researched but not started. Each section carries enough of what was found to be acted on without repeating the research, and says which claims were verified and which were not. Delete a section once it lands.

## Agent-facing components

Twelve libraries were surveyed in September 2026 for what they ship and this library does not: Vercel AI Elements (50 components), Ant Design X, assistant-ui, prompt-kit, beUI, shadcn.io/ai, Kibo UI, ElevenLabs UI, LiveKit Agents UI, CopilotKit, LlamaIndex chat-ui, and OpenAI ChatKit widgets. Links are under [Sources](#sources).

**Nine of the ten first-tier components have shipped** as the `agent` group: `ToolCall`, `Approval`, `Reasoning`, `AgentSteps`, `ContextWindow` (named for the window rather than `Context`, which beside `ContextMenu` and React's own would have been a word this library cannot afford to spend), `Sources`, `InlineCitation`, `StreamingText` and `PromptInput`. What is left of that tier is the two below.

### First tier, what is left

| Component | What it draws | Why the existing set does not cover it | Seen in |
| --- | --- | --- | --- |
| `Terminal` | ANSI-coloured stdout and stderr, a prompt line, a running cursor, stuck to the bottom | `CodeBlock` highlights a grammar and takes a finished string. This parses escape sequences and appends a line at a time, and it needs no highlighter at all | 5 |
| `Diff` | A file change: unified or split, added, removed and context lines, collapsed hunks, per-hunk accept | Absent. `tokenize` in `src/internal/highlight.ts` already returns per-line coloured runs, which is the half that would otherwise be expensive | 4 |

Notes for whoever picks these up:

- Both reuse `tokenize` and neither needs highlight.js, which is why they were the pair to take together.
- `Diff` wants a collapsible JSON tree for nothing, but `ToolCall` renders a string `args` as a `<pre>` and a node as it is — so the tree is still a second-tier `JsonView` question rather than something either of these has to answer.
- Both belong in `display` rather than in `agent`: a diff of a file and a terminal's output are things a page shows, and neither is about what an agent is doing. `StreamingText` is the group's precedent for the other direction — see the group definitions in [CLAUDE.md](CLAUDE.md).
- Adding a component is the six edits listed under Documentation in [CLAUDE.md](CLAUDE.md), and its tests ship in the same commit.

### What the nine settled, for the two that are left

- **`NebaRunStatus`** is in `src/types.ts`, and `src/internal/run.tsx` holds the mark, the colour family and the elapsed clock that go with it. A `Terminal` reporting an exit code should read that rather than inventing a fifth word.
- **`preformattedClasses`** and **`collapsiblePanelClasses`** are in `internal/styles.ts`. A `Diff`'s hunks fold, and its lines are preformatted text.
- **The `run` namespace** in `internal/i18n.ts` is already the four status words in nineteen languages.

### Second tier, where the scope has to be settled first

- **Audio.** `Waveform`, `VoiceOrb`, `AudioPlayer`, `Transcript`. There is no audio component here at all, and ElevenLabs UI and LiveKit have taken the whole area. An orb is normally three.js; a CSS and SVG reading of it is the thing to work out before committing to the group.
- **`JsonView`.** A collapsible JSON tree. `ToolCall` and `Approval` both take a node where one would go, so this is now an addition rather than a prerequisite.
- **`FileTree`.** Extension icons and an A/M/D change marker. Likely a preset on `TreeView` rather than a component.
- **`Artifact`.** The side canvas. `Panes` and `WindowPane` already do half of it.
- **`Branch` and `Checkpoint`.** Walking regenerated answers, and a rewind marker in the transcript. Both small.
- **`Comparison`.** A before-and-after slider, for comparing generated images.
- **`RelativeTime`.** Small, and needed by every log and thread list.
- **`TestResults`, `StackTrace`, `Commit`, `PackageInfo`, `EnvVars`.** Five thin cards for coding agents. Take all five or none.
- **`WebPreview`.** An address bar over a live iframe. May be an extension to `Mockup` rather than a component.

### Rejected, so it does not get re-litigated

- **A Markdown or Mermaid renderer.** Runtime dependencies would go from two to half a dozen. Ant Design X ships its renderer as a separate package, which is the right call.
- **Workflow `Canvas`, `Node`, `Edge`.** That is react-flow's territory, and it changes what this library is.
- **`Sandbox` and `JSX Preview`.** Executing code adds a security surface.
- **`ModelSelector`, `MicSelector`, `VoiceSelector`, `Actions`, suggestion chips, a conversation list, a welcome screen.** All of them compose out of `Select`, `Toolbar`, `Chip` with `ScrollZone`, `List` and `Empty` — and `PromptInput`'s `start` and `end` are where the first four of them now go.

## An A2UI adapter

**The catalog has shipped.** `src/a2ui/catalog.json` is written against A2UI v1.0, copied to `dist/a2ui/catalog.json` by `scripts/build-catalog.mjs` and served from `https://neba.cdget.com/a2ui/catalog.json`; eighteen components and the specification's fourteen functions, with `test/package/a2ui.test.ts` holding the shape and [CLAUDE.md](CLAUDE.md) recording the four decisions behind it. That was shape A below, and on its own it is already enough for an agent to drive a host that uses this library.

What is left is shape B: `neba/a2ui`, a module that registers these components with `@a2ui/react` so a consumer does not write the mapping themselves.

### What was verified

Read against the v1.0 specification in September 2026 — the v0.9 notes this section used to carry were re-checked and several of them had moved.

- **A catalog is one JSON Schema file** validated by `specification/v1_0/json/catalog_definition.json`: `additionalProperties: false` over `$schema`, `$id`, `protocolVersion`, `title`, `description`, `catalogId`, `instructions`, `components`, `functions` and `$defs`, with `catalogId` the only required key. `components` and `functions` are **maps**, not arrays.
- **v1.0 dropped `theme`** and the `ComponentCommon` wrapper the v0.9 catalog put round every component, and added `instructions` — Markdown design guidance written for the model — and a `$defs` that must hold both `anyComponent` and `anyFunction` or neither.
- **`description` in a catalog entry is written for the model, not for a reader.** The Basic Catalog's `Button.child` says "Use a 'Text' component for a labeled button. Only use an 'Icon' if the requirements explicitly ask for an icon-only button."
- **There is no registry.** `catalogId` is a string identifier that only looks like a URL; the spec states it does not need to point at anything.
- **Registration happens twice at runtime.** The renderer advertises its supported catalog IDs in message metadata, and the agent side puts the catalog schema into the prompt. `inlineCatalogs` is a third path that needs no prior agreement at all.
- **The wire format is a flat map with id references**, not a tree, and values are either literals or `{"path": "/json/pointer"}` bindings against a data model the renderer owns. Input components are two-way; what the reader typed is resolved and sent up when an action fires.
- **A2UI is Apache-2.0**, which is why this repository's catalog states the protocol's names, argument shapes and return types — the interface — and writes its own descriptions.

### What an adapter would cost

|  | What ships | Dependencies |
| --- | --- | --- |
| **A. The catalog alone** | Done. `neba/a2ui/catalog.json` | None |
| **B. An adapter** | A, plus `neba/a2ui` registering these components with `@a2ui/react` | `@a2ui/react`, and its `markdown-it` and `zod`, inside the subpath only |

### What will bite

- **The children model differs.** A2UI passes `child: "someId"`, a string, where a component here takes `children: ReactNode`. Resolving that gap is most of what an adapter is, and it is the reason the catalog is useful without one: a host that already has a renderer has already solved it.
- **Four of the eighteen have no one-to-one prop.** `DataList` takes `items` in the catalog and `DataListItem` children in the library; `RadioGroup` and `Select` take an `options` array where the library takes children and an `items` array respectively; `Alert` takes a `child` where the library takes `children`. Each is three lines in an adapter and none of them is a question about the catalog.
- **The packages are at 0.11.x while the spec is at 1.0.** Breaking changes are likelier in the tooling than in the format.
- **The `@a2ui/react` registration API has still not been opened.** It was only ever seen as an Angular example. Wiring one component through it is the cheapest way to find out whether B is worth it.

## Sources

- [AI Elements](https://elements.ai-sdk.dev/) and [shadcn.io/ai](https://www.shadcn.io/ai) — the two widest component lists
- [Ant Design X](https://x.ant.design/components/overview/), [assistant-ui primitives](https://www.assistant-ui.com/docs/api-reference/primitives), [prompt-kit](https://www.prompt-kit.com/docs/installation), [beUI agents](https://beui.dev/components/agents/tool-approval), [Kibo UI](https://www.kibo-ui.com/)
- [ElevenLabs UI](https://github.com/elevenlabs/ui) and [LiveKit Agents UI](https://docs.livekit.io/frontends/agents-ui/) — the audio group
- [A2UI v1.0 protocol](https://a2ui.org/specification/v1.0-a2ui/), [the A2A extension](https://a2ui.org/specification/v1.0-a2ui-extension-specification/), [catalog concepts](https://a2ui.org/concepts/catalogs/), [the Basic Catalog](https://github.com/google/A2UI/blob/main/specification/v0_9/catalogs/basic/catalog.json)
- [Genkit's A2UI middleware](https://genkit.dev/docs/js/agents/a2ui/) — how the catalog reaches the model
- [MCP Apps (SEP-1865)](https://modelcontextprotocol.io/seps/1865-mcp-apps-interactive-user-interfaces-for-mcp) and [A2UI with MCP Apps](https://developers.googleblog.com/a2ui-and-mcp-apps/)
