import { ProgressCircular, StreamingText } from 'neba';

export default function StreamingTextCursor() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4 text-[0.9375rem]/[1.7]">
      <StreamingText streaming>The block at the end is the default</StreamingText>
      <StreamingText
        streaming
        cursor={<ProgressCircular size="xs" className="ms-1 align-[-0.1em]" />}
      >
        A ring instead, for an answer that is waiting on a tool
      </StreamingText>
      <StreamingText streaming cursor={false}>
        And none at all, where something else already says the answer is not finished
      </StreamingText>
    </div>
  );
}
