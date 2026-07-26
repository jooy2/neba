import { Combobox } from 'neba';

const TIMEZONES = [
  { value: 'Asia/Seoul', label: 'Asia/Seoul' },
  { value: 'Asia/Tokyo', label: 'Asia/Tokyo' },
  { value: 'Europe/Berlin', label: 'Europe/Berlin' },
  { value: 'America/New_York', label: 'America/New_York' }
];

export default function ComboboxCustom() {
  return (
    <div className="flex flex-wrap items-start gap-4">
      <Combobox
        items={TIMEZONES}
        label="Anything goes"
        placeholder="Type a timezone"
        customLabel={(query) => `Use “${query}” anyway`}
        description="A typed value is offered as the last row."
      />
      <Combobox
        items={TIMEZONES}
        allowCustom={false}
        label="Closed set"
        placeholder="Pick a timezone"
        emptyMessage="No such timezone."
        description="Only what the list holds."
      />
    </div>
  );
}
