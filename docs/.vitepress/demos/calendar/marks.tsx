import { Calendar } from 'neba';

/** Three days this month have something on them. */
const BUSY = new Set([4, 11, 12, 19, 26]);

export default function CalendarMarks() {
  return (
    <Calendar
      size="lg"
      renderDay={(date) =>
        BUSY.has(date.getDate()) ? (
          <span
            aria-hidden="true"
            className="absolute bottom-1 size-1 rounded-full bg-(--neba-primary-accent)"
          />
        ) : null
      }
    />
  );
}
