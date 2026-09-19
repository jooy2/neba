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

## An A2UI catalog

A2UI is the standard for an agent describing UI as JSON that the host renders with its own design system. It is the one agentic-UI standard a component library benefits from: MCP Apps, the competing one, puts HTML in a sandboxed iframe, where a host design system cannot reach. Ant Design X has already shipped this as `@ant-design/x-card`.

### What was verified

Read against the v1.0 spec and against `@a2ui/web_core@0.11.0` unpacked from npm.

- **A catalog is one JSON Schema file** with three keys: `components` (type name to a JSON Schema of its props), `functions` (what the renderer will execute, such as `required`, `email`, `formatCurrency`, `openUrl`), and `theme`. The standard Basic Catalog is 46 kB, 18 components, 14 functions.
- **`description` in a catalog entry is written for the model, not for a reader.** The Basic Catalog's `Button.child` says "Use a 'Text' component for a labeled button. Only use an 'Icon' if the requirements explicitly ask for an icon-only button."
- **There is no registry.** `catalogId` is a string identifier that only looks like a URL; the spec states it "does not need to point to any deployed resource or downloadable file".
- **Registration happens twice at runtime.** The renderer advertises `a2uiRendererCapabilities.v1.0.supportedCatalogIds` in message metadata, and the agent side puts the catalog schema into the prompt. `inlineCatalogs` is a third path that needs no prior agreement at all.
- **The file ships inside the npm package.** `@a2ui/web_core` carries `src/v0_9/schemas/catalogs/basic/catalog.json` plus about twenty example message files, and exports `./v0_9/basic_catalog`. The same file is also served from the docs site.
- **The wire format is a flat map with id references**, not a tree, and values are either literals or `{"path": "/json/pointer"}` bindings against a data model the renderer owns. Input components are two-way; what the reader typed is resolved and sent up when an action fires.
- **A React renderer exists.** `@a2ui/react` 0.11.1, published 2026-09-12, depending on `@a2ui/web_core`, `markdown-it`, `zod` and `clsx`.

### Two shapes it can take

|  | What ships | Dependencies |
| --- | --- | --- |
| **A. The catalog alone** | `dist/a2ui/catalog.json`, exported as `neba/a2ui/catalog.json`, and the same file under `docs/public/a2ui/`. The renderer is the consumer's problem | None |
| **B. The catalog and an adapter** | A, plus `neba/a2ui` registering this library's components with `@a2ui/react` | `markdown-it`, `zod`, inside the subpath only |

A is a prerequisite for B, and A on its own is already enough for an agent to drive a host that uses this library.

### What will bite

- **The children model differs.** A2UI passes `child: "someId"`, a string, where a component here takes `children: ReactNode`. Resolving that gap is most of what an adapter is.
- **Only half of the schema can be generated.** `docs/.vitepress/data/props.ts` holds 167 prop tables as data, and a union like `'solid' | 'outline' | 'text'` falls straight out as an `enum`. `ReactNode`, `useRender.RenderProp` and every callback cannot go in a catalog at all. The real work is deciding what to leave out.
- **Do not expose all 131 components.** The Basic Catalog is 18 on purpose; the spec calls it "intentionally sparse". A model cannot choose well from a long list. Picking the subset is the design.
- **The `theme` key is small** — `primaryColor` as a hex string, `iconUrl`, `agentDisplayName`. Anything beyond that rides on `additionalProperties: true` and other renderers will ignore it.
- **`.npmignore` is an allow-nothing list**, so a new path has to be opened there deliberately. Confirm with `npm pack --dry-run`.
- A catalog is JSON, so it never enters a bundle. `sideEffects` is unaffected and `npm run size` will not move; only `unpackedSize` grows.

### Still unchecked

- The Basic Catalog that was read came from the **v0.9** path. The v1.0 spec document was read, but the v1.0 catalog file was not.
- The custom-component registration code was only seen as an **Angular** example. The `@a2ui/react` registration API has not been opened. This is the next thing to look at, and wiring one component through it is the cheapest way to find out whether shape B is worth it.
- The packages are at 0.11.x while the spec has just moved to v1.0. Breaking changes are still likely.

## Sources

- [AI Elements](https://elements.ai-sdk.dev/) and [shadcn.io/ai](https://www.shadcn.io/ai) — the two widest component lists
- [Ant Design X](https://x.ant.design/components/overview/), [assistant-ui primitives](https://www.assistant-ui.com/docs/api-reference/primitives), [prompt-kit](https://www.prompt-kit.com/docs/installation), [beUI agents](https://beui.dev/components/agents/tool-approval), [Kibo UI](https://www.kibo-ui.com/)
- [ElevenLabs UI](https://github.com/elevenlabs/ui) and [LiveKit Agents UI](https://docs.livekit.io/frontends/agents-ui/) — the audio group
- [A2UI v1.0 protocol](https://a2ui.org/specification/v1.0-a2ui/), [the A2A extension](https://a2ui.org/specification/v1.0-a2ui-extension-specification/), [catalog concepts](https://a2ui.org/concepts/catalogs/), [the Basic Catalog](https://github.com/google/A2UI/blob/main/specification/v0_9/catalogs/basic/catalog.json)
- [Genkit's A2UI middleware](https://genkit.dev/docs/js/agents/a2ui/) — how the catalog reaches the model
- [MCP Apps (SEP-1865)](https://modelcontextprotocol.io/seps/1865-mcp-apps-interactive-user-interfaces-for-mcp) and [A2UI with MCP Apps](https://developers.googleblog.com/a2ui-and-mcp-apps/)
