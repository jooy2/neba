import { Approval, type ApprovalRisk } from 'neba';

const REQUESTS: Array<{ risk: ApprovalRisk; title: string; details: string }> = [
  { risk: 'low', title: 'Read a file?', details: 'read src/index.ts' },
  { risk: 'medium', title: 'Open a pull request?', details: 'gh pr create --fill' },
  { risk: 'high', title: 'Delete a branch?', details: 'git push origin --delete release/1.3' }
];

export default function ApprovalRisks() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {REQUESTS.map((request) => (
        <Approval
          key={request.risk}
          size="sm"
          risk={request.risk}
          title={request.title}
          details={request.details}
          options={[
            { value: 'allow', label: 'Allow' },
            { value: 'deny', label: 'Deny' }
          ]}
        />
      ))}
    </div>
  );
}
