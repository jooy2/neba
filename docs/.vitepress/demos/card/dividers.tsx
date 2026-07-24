import { Card } from 'neba';

export default function CardDividers() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <Card title="Without" subtitle="separated by space" footer="Footer">
        Body
      </Card>
      <Card dividers title="With" subtitle="separated by a hairline" footer="Footer">
        Body
      </Card>
    </div>
  );
}
