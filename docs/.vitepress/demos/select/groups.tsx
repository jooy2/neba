import { Select } from 'neba';

/**
 * A group is a run of adjacent options naming it, so the array's order is the
 * list's order. The last two belong to no group and stay where they were put.
 */
const ZONES = [
  { value: 'icn', label: 'Seoul', group: 'Asia' },
  { value: 'nrt', label: 'Tokyo', group: 'Asia' },
  { value: 'sin', label: 'Singapore', group: 'Asia' },
  { value: 'cdg', label: 'Paris', group: 'Europe' },
  { value: 'lhr', label: 'London', group: 'Europe' },
  { value: 'utc', label: 'UTC' }
];

export default function SelectGroups() {
  return <Select items={ZONES} label="Time zone" defaultValue="icn" />;
}
