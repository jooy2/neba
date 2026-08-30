import { Toggle, ToggleGroup } from 'neba';

export default function ToggleGroupFullWidth() {
  return (
    <div className="w-full max-w-md">
      <ToggleGroup fullWidth aria-label="View" defaultValue={['board']}>
        <Toggle value="list">List</Toggle>
        <Toggle value="board">Board</Toggle>
        <Toggle value="calendar">Calendar</Toggle>
      </ToggleGroup>
    </div>
  );
}
