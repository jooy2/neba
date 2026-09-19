import { PromptInput, Shortcut } from 'neba';

export default function PromptInputSubmitKey() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-6">
      <PromptInput
        label="Enter sends"
        placeholder="Enter sends, Shift+Enter breaks the line"
        end={<Shortcut size="xs" keys="Enter" />}
      />
      <PromptInput
        label="Mod+Enter sends"
        submitKey="Mod+Enter"
        placeholder="Enter breaks the line, Mod+Enter sends"
        end={<Shortcut size="xs" keys="Mod+Enter" />}
      />
    </div>
  );
}
