import { Transfer } from 'neba';

const ITEMS = [
  { value: 'read', label: 'Read' },
  { value: 'write', label: 'Write' },
  { value: 'deploy', label: 'Deploy' },
  { value: 'billing', label: 'Billing', disabled: true }
];

export default function TransferStates() {
  return (
    <div className="flex w-full max-w-2xl flex-col gap-6">
      <Transfer size="sm" height={120} items={ITEMS} defaultValue={['read']} />
      <Transfer size="sm" height={120} items={ITEMS} defaultValue={['read']} disabled />
    </div>
  );
}
