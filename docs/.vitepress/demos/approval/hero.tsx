import { Approval } from 'neba';

export default function ApprovalHero() {
  return (
    <div className="w-full max-w-lg">
      <Approval
        risk="high"
        title="Run a shell command?"
        description="The assistant wants to remove the build output before rebuilding."
        details={'rm -rf ./dist\nnpm run build'}
        options={[
          { value: 'once', label: 'Allow once', description: 'Just this command' },
          {
            value: 'always',
            label: 'Always allow',
            description: 'Every shell command in this session'
          },
          { value: 'deny', label: 'Deny', color: 'danger' }
        ]}
      />
    </div>
  );
}
