import { Blockquote } from 'neba';

export default function BlockquoteHero() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-6">
      <Blockquote author="Antoine de Saint-Exupéry" source="Terre des Hommes">
        Perfection is achieved, not when there is nothing more to add, but when there is nothing
        left to take away.
      </Blockquote>

      <Blockquote variant="outline" color="info" icon={false}>
        A design system is not a component library. It is an agreement about what the components
        mean.
      </Blockquote>
    </div>
  );
}
