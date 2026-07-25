import { ProgressBox } from 'neba';

export default function ProgressBoxCounts() {
  return (
    <div className="flex flex-col gap-5">
      {[3, 4, 6, 10].map((count) => (
        <ProgressBox key={count} count={count} />
      ))}
    </div>
  );
}
