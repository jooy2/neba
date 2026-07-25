import { Alert } from 'neba';

export default function AlertVariants() {
  return (
    <div className="flex w-full flex-col gap-3">
      <Alert variant="solid" color="warning" title="Card expiring">
        Your card ends in 4242 and expires next month.
      </Alert>
      <Alert variant="outline" color="warning" title="Card expiring">
        Your card ends in 4242 and expires next month.
      </Alert>
      <Alert variant="text" color="warning" title="Card expiring">
        Your card ends in 4242 and expires next month.
      </Alert>
    </div>
  );
}
