import { AgentStep, AgentSteps, type NebaSize } from 'neba';

const SIZES: NebaSize[] = ['xs', 'sm', 'md', 'lg'];

export default function AgentStepsSize() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-6">
      {SIZES.map((size) => (
        <AgentSteps key={size} size={size} density="compact">
          <AgentStep title={`Planned at ${size}`} duration={120} />
          <AgentStep title="Searched the documentation" status="running" />
        </AgentSteps>
      ))}
    </div>
  );
}
