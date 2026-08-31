import { Button, Checkbox, NebaProvider, Select, TextField } from 'neba';

function Form({ heading }: { heading: string }) {
  return (
    <div className="flex w-56 flex-col gap-3">
      <p className="text-sm font-medium text-(--neba-fg)">{heading}</p>
      <TextField fullWidth label="Project" placeholder="neba" />
      <Select
        fullWidth
        label="Region"
        placeholder="Pick one"
        items={[
          { value: 'icn', label: 'Seoul' },
          { value: 'fra', label: 'Frankfurt' }
        ]}
      />
      <Checkbox label="Deploy on push" />
      <Button fullWidth>Create</Button>
    </div>
  );
}

export default function ProviderDefaults() {
  return (
    <div className="flex flex-wrap items-start gap-8">
      <Form heading="No provider" />

      <NebaProvider defaults={{ size: 'xs', density: 'compact' }}>
        <Form heading="size xs · density compact" />
      </NebaProvider>
    </div>
  );
}
