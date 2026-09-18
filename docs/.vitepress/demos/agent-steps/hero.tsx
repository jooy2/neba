import { AgentStep, AgentSteps, ToolCall } from 'neba';

export default function AgentStepsHero() {
  return (
    <div className="w-full max-w-lg">
      <AgentSteps running="Writing the answer">
        <AgentStep title="Read the request" duration={120} />
        <AgentStep title="Searched the documentation" meta="4 hits" duration={412}>
          <ToolCall
            size="sm"
            variant="text"
            name="search_docs"
            status="success"
            duration={412}
            args={'{ "query": "responsive slots" }'}
            result="design/breakpoints, internal/responsive.ts"
          />
        </AgentStep>
        <AgentStep title="Opened two files" meta="src/internal/responsive.ts" duration={86} />
      </AgentSteps>
    </div>
  );
}
