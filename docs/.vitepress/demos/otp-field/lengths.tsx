import { OtpField } from 'neba';

export default function OtpFieldLengths() {
  return (
    <div className="flex flex-col gap-6">
      <OtpField label="Four digit PIN" length={4} size="sm" />
      <OtpField label="Six digit code, in two blocks" length={6} groupSize={3} />
      <OtpField
        label="Nine character key, in three"
        length={9}
        groupSize={3}
        charset="alphanumeric"
        size="sm"
      />
    </div>
  );
}
