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

## Sources

- [AI Elements](https://elements.ai-sdk.dev/) and [shadcn.io/ai](https://www.shadcn.io/ai) — the two widest component lists
- [Ant Design X](https://x.ant.design/components/overview/), [assistant-ui primitives](https://www.assistant-ui.com/docs/api-reference/primitives), [prompt-kit](https://www.prompt-kit.com/docs/installation), [beUI agents](https://beui.dev/components/agents/tool-approval), [Kibo UI](https://www.kibo-ui.com/)
- [ElevenLabs UI](https://github.com/elevenlabs/ui) and [LiveKit Agents UI](https://docs.livekit.io/frontends/agents-ui/) — the audio group
- [A2UI](https://a2ui.org) — the catalog and the adapter have both shipped; see [the guide page](docs/en/guide/a2ui.md) and the section in [CLAUDE.md](CLAUDE.md). [Genkit's middleware](https://genkit.dev/docs/js/agents/a2ui/) is how a catalog reaches the model, and [MCP Apps](https://modelcontextprotocol.io/seps/1865-mcp-apps-interactive-user-interfaces-for-mcp) is the competing standard that was looked at and passed over.
