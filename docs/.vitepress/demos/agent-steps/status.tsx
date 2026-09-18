import { AgentStep, AgentSteps } from 'neba';

export default function AgentStepsStatus() {
  return (
    <div className="w-full max-w-lg">
      <AgentSteps>
        <AgentStep title="Read the request" status="success" duration={120} />
        <AgentStep title="Called the deploy API" status="error">
          No such environment: production
        </AgentStep>
        <AgentStep title="Retrying" status="running" />
        <AgentStep title="Report the result" status="pending" />
      </AgentSteps>
    </div>
  );
}
