import { ToolCall } from 'neba';

export default function ToolCallVariant() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['outline', 'solid', 'text'] as const).map((variant) => (
        <ToolCall
          key={variant}
          variant={variant}
          name="fetch_page"
          status="success"
          duration={730}
          meta={variant}
          result="200 OK"
        />
      ))}
    </div>
  );
}
