import { PromptInput } from 'neba';

export default function PromptInputRows() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-6">
      <PromptInput label="One line to start" placeholder="Type, and watch it grow" maxRows={4} />
      <PromptInput
        label="Three lines to start"
        minRows={3}
        maxRows={6}
        defaultValue={
          'It starts three rows tall\nand stops growing at six,\nafter which it scrolls.'
        }
      />
    </div>
  );
}
