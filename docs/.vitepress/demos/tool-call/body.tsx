import { CodeBlock, DataList, DataListItem, ToolCall } from 'neba';

export default function ToolCallBody() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-2">
      <ToolCall
        name="run_query"
        status="success"
        duration={86}
        defaultOpen
        args="select id, name from regions where active = true"
        result={
          <DataList size="sm" dividers>
            <DataListItem label="Rows">4</DataListItem>
            <DataListItem label="Scanned">1.2k</DataListItem>
          </DataList>
        }
      />
      <ToolCall
        name="write_file"
        status="success"
        duration={12}
        args={
          <CodeBlock
            size="sm"
            language="json"
            code={'{ "path": "src/index.ts", "mode": "append" }'}
          />
        }
        result="18 bytes written"
      />
    </div>
  );
}
