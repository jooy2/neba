import { useState } from 'react';
import { Checkbox } from 'neba';

const SCOPES = ['Read', 'Write', 'Delete'];

export default function CheckboxIndeterminate() {
  const [checked, setChecked] = useState([true, false, false]);
  const all = checked.every(Boolean);
  const some = checked.some(Boolean);

  return (
    <div className="flex flex-col gap-3">
      <Checkbox
        label="All permissions"
        checked={all}
        indeterminate={some && !all}
        onCheckedChange={(next) => setChecked(checked.map(() => next))}
      />
      <div className="ms-6 flex flex-col gap-3">
        {SCOPES.map((scope, index) => (
          <Checkbox
            key={scope}
            label={scope}
            checked={checked[index]}
            onCheckedChange={(next) =>
              setChecked(checked.map((value, i) => (i === index ? next : value)))
            }
          />
        ))}
      </div>
    </div>
  );
}
