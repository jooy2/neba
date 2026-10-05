import { Button, Checkbox, Fieldset, NebaProvider, Select, TextField } from 'neba';

function Form({ heading }: { heading: string }) {
  return (
    <Fieldset legend={heading} className="w-56">
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
    </Fieldset>
  );
}

export default function ProviderDefaults() {
  return (
    <div className="flex flex-wrap items-start gap-8">
      <Form heading="No provider" />

      <NebaProvider defaults={{ size: 'xs', density: 'compact' }}>
        <Form heading="size xs · density compact" />
      </NebaProvider>

      <NebaProvider defaults={{ labelPlacement: 'notch' }}>
        <Form heading="labelPlacement notch" />
      </NebaProvider>

      <NebaProvider defaults={{ spacing: 7 }}>
        <Form heading="spacing 7" />
      </NebaProvider>
    </div>
  );
}
