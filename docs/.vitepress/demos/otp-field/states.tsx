import { OtpField } from 'neba';

export default function OtpFieldStates() {
  return (
    <div className="flex flex-wrap items-start gap-6">
      <OtpField label="Masked" mask length={4} defaultValue="8421" />
      <OtpField label="Expired" length={4} defaultValue="1234" error="That code has expired." />
      <OtpField label="Read-only" length={4} defaultValue="1234" readOnly />
      <OtpField label="Unavailable" length={4} defaultValue="1234" disabled />
    </div>
  );
}
