import { useState } from 'react';
import { Alert, OtpField } from 'neba';

export default function OtpFieldHero() {
  const [code, setCode] = useState('');
  const [done, setDone] = useState(false);

  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      <OtpField
        label="Verification code"
        description="We texted a six digit code to •••• 4417."
        length={6}
        groupSize={3}
        value={code}
        onValueChange={(next) => {
          setCode(next);
          setDone(false);
        }}
        onComplete={() => setDone(true)}
      />
      {done ? (
        <Alert color="success" title="Code accepted">
          {code} checked out.
        </Alert>
      ) : null}
    </div>
  );
}
