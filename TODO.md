# TODO

Work that has been researched but not started. Each section carries enough of what was found to be acted on without repeating the research, and says which claims were verified and which were not. Delete a section once it lands.

## Agent-facing components

Twelve libraries were surveyed in September 2026 for what they ship and this library does not: Vercel AI Elements (50 components), Ant Design X, assistant-ui, prompt-kit, beUI, shadcn.io/ai, Kibo UI, ElevenLabs UI, LiveKit Agents UI, CopilotKit, LlamaIndex chat-ui, and OpenAI ChatKit widgets. Links are under [Sources](#sources).

What survives below is what more than one of them ships, what the existing components do not compose into, and what a presentational library can hold without taking on a runtime dependency. **Seen in** is how many of the twelve carry it. The names are proposals, not decisions.

### First tier

| Component | What it draws | Why the existing set does not cover it | Seen in |
| --- | --- | --- | --- |
| `ToolCall` | One tool invocation: name, arguments, result, elapsed time | Nothing here is close. The state moves `pending` to `running` to `success`/`error` on its own, the body collapses to a header, and the result arrives after the first render | 9 |
| `Approval` | The agent asking permission: allow once, always allow, deny, with a risk level and editable arguments | `Confirm` and `Popconfirm` are opened by the reader, offer two answers, and vanish when closed. This is opened by the agent, offers three or more, and stays in the transcript as a record of what was decided | 8 |
| `Terminal` | ANSI-coloured stdout and stderr, a prompt line, a running cursor, stuck to the bottom | `CodeBlock` highlights a grammar and takes a finished string. This parses escape sequences and appends a line at a time, and it needs no highlighter at all | 5 |
| `Diff` | A file change: unified or split, added, removed and context lines, collapsed hunks, per-hunk accept | Absent. `tokenize` in `src/internal/highlight.ts` already returns per-line coloured runs, which is the half that would otherwise be expensive | 4 |
| `Reasoning` | A collapsible thinking panel that opens while the stream runs, closes when it ends, and keeps "thought for N seconds" | On `Spoiler` and `Collapsible` the reader owns the open state. Here the stream owns it | 10 |
| `AgentSteps` | A chain of steps that grows as it runs, each with a state and nested children such as a search query or a file read | `Timeline` and `HowToSteps` draw a list that is known up front. This one does not know how many items it has | 8 |
| `Context` | A context-window gauge: a ring, the input, output, reasoning and cached token split, and a cost estimate | `Meter` draws the ring, but the token formatting (K/M/B) and the four-way split are the component | 5 |
| `Sources` and `InlineCitation` | A source list, and a numbered footnote in the body with a hover preview | `HoverCard` gives the preview. The numbering and the body-to-list link are missing | 11 |
| `StreamingText` | Text arriving from outside: a placeholder that does not shift the layout, a cursor, a per-word fade-in | `AnimateTyping` types a string it already has. This is the opposite direction | 9 |
| `PromptInput` | Attach, model, send and stop in one input. Auto height, Enter and Shift+Enter, drop target | `TextField` plus `Toolbar` gets the shell, but the send-becomes-stop state and the auto height are rewritten every time | 12 |

Notes for whoever picks these up:

- `ToolCall` and `Approval` are the smallest unit of every agent UI in the survey. Start there.
- `Terminal` and `Diff` are next because both reuse `tokenize`, and neither needs highlight.js.
- `Diff` and `ToolCall` both want a collapsible JSON tree. Decide early whether that is a `JsonView` of its own (second tier) or private to each.
- None of these belongs in a new group. `ToolCall`, `Approval`, `Reasoning`, `AgentSteps`, `StreamingText` and `Context` are `feedback`; `Terminal`, `Diff`, `Sources` and `InlineCitation` are `display`; `PromptInput` is `inputs`. See the group definitions in [CLAUDE.md](CLAUDE.md).
- Adding a component is still the six edits listed under Documentation in [CLAUDE.md](CLAUDE.md), and its tests ship in the same commit.

### Second tier, where the scope has to be settled first

- **Audio.** `Waveform`, `VoiceOrb`, `AudioPlayer`, `Transcript`. There is no audio component here at all, and ElevenLabs UI and LiveKit have taken the whole area. An orb is normally three.js; a CSS and SVG reading of it is the thing to work out before committing to the group.
- **`JsonView`.** A collapsible JSON tree. Also the inside of `ToolCall`, so it may come first by necessity.
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
- **`ModelSelector`, `MicSelector`, `VoiceSelector`, `Actions`, suggestion chips, a conversation list, a welcome screen.** All of them compose out of `Select`, `Toolbar`, `Chip` with `ScrollZone`, `List` and `Empty`.

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
