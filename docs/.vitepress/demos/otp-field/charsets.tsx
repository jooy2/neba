import { OtpField } from 'neba';

export default function OtpFieldCharsets() {
  return (
    <div className="flex flex-wrap items-end gap-6">
      <OtpField label="Numeric" charset="numeric" length={4} defaultValue="1234" />
      <OtpField label="Alpha" charset="alpha" length={4} defaultValue="beta" />
      <OtpField label="Alphanumeric" charset="alphanumeric" length={4} defaultValue="a1b2" />
    </div>
  );
}
