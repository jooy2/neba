import { useState } from 'react';
import { Checkbox, CheckboxGroup } from 'neba';

const REGIONS = [
  { value: 'icn', label: 'Seoul' },
  { value: 'nrt', label: 'Tokyo' },
  { value: 'fra', label: 'Frankfurt' },
  { value: 'iad', label: 'Washington DC' }
];

export default function CheckboxGroupParent() {
  const [value, setValue] = useState(['icn']);

  return (
    <CheckboxGroup
      label="Deploy to"
      value={value}
      onValueChange={setValue}
      allValues={REGIONS.map((region) => region.value)}
    >
      <Checkbox parent label="Every region" />
      <div className="flex flex-col gap-2 ps-6">
        {REGIONS.map((region) => (
          <Checkbox key={region.value} value={region.value} label={region.label} />
        ))}
      </div>
    </CheckboxGroup>
  );
}
