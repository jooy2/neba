import { Toggle, ToggleGroup } from 'neba';

const variants = ['solid', 'outline', 'text'] as const;

export default function ToggleGroupVariants() {
  return (
    <div className="flex flex-col items-center gap-5">
      {variants.map((variant) => (
        <ToggleGroup key={variant} aria-label={variant} variant={variant} defaultValue={['week']}>
          <Toggle value="day">Day</Toggle>
          <Toggle value="week">Week</Toggle>
          <Toggle value="month">Month</Toggle>
        </ToggleGroup>
      ))}
    </div>
  );
}
