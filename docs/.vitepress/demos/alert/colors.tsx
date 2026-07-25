import { Alert } from 'neba';

const MESSAGES = [
  { color: 'info', text: 'Two review apps are still building.' },
  { color: 'success', text: 'Deployed to production.' },
  { color: 'warning', text: 'This region is at 90% of its quota.' },
  { color: 'danger', text: 'The database is unreachable.' }
] as const;

export default function AlertColors() {
  return (
    <div className="flex w-full flex-col gap-3">
      {MESSAGES.map((message) => (
        <Alert key={message.color} color={message.color}>
          {message.text}
        </Alert>
      ))}
    </div>
  );
}
