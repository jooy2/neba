import { Divider } from 'neba';

export default function DividerLabels() {
  return (
    <div className="flex w-full max-w-md flex-col gap-6">
      <Divider textAlign="start">Recent</Divider>
      <Divider>Older</Divider>
      <Divider textAlign="end">Archived</Divider>
    </div>
  );
}
