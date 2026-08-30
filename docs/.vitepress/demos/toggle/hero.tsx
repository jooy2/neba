import { Toggle } from 'neba';

export default function ToggleHero() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      <Toggle defaultPressed>Bold</Toggle>
      <Toggle>Italic</Toggle>
      <Toggle variant="text" defaultPressed>
        Underline
      </Toggle>
      <Toggle variant="solid" color="success" defaultPressed>
        Live
      </Toggle>
    </div>
  );
}
