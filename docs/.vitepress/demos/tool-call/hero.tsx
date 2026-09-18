import { ToolCall } from 'neba';

export default function ToolCallHero() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-2">
      <ToolCall
        name="search_docs"
        status="success"
        duration={412}
        args={'{\n  "query": "acrylic surface",\n  "limit": 5\n}'}
        result={'{\n  "hits": 4,\n  "top": "design-language"\n}'}
      />
      <ToolCall name="read_file" status="running" meta="src/styles.css" />
      <ToolCall
        name="deploy"
        status="error"
        duration={1840}
        args={'{\n  "environment": "production"\n}'}
        error="No such environment: production"
      />
    </div>
  );
}
