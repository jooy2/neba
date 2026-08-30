import { Transfer } from 'neba';

const PEOPLE = [
  'Kim Minji',
  'Alex Park',
  'Sam Lee',
  'Noa Cohen',
  'Ravi Patel',
  'Jane Doe',
  'Hana Sato',
  'Luis Ortiz',
  'Mia Fischer'
].map((name) => ({ value: name.toLowerCase().replace(/\s+/g, '-'), label: name }));

export default function TransferSearchable() {
  return (
    <Transfer
      searchable
      size="sm"
      className="max-w-2xl"
      items={PEOPLE}
      defaultValue={['sam-lee']}
      sourceLabel="Everyone"
      targetLabel="On this channel"
    />
  );
}
