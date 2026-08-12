import { Rating } from 'neba';

function HeartIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="currentColor">
      <path d="M8 14S1.5 10 1.5 5.75A3.25 3.25 0 0 1 8 4.4a3.25 3.25 0 0 1 6.5 1.35C14.5 10 8 14 8 14Z" />
    </svg>
  );
}

function HeartOutlineIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M8 14S1.5 10 1.5 5.75A3.25 3.25 0 0 1 8 4.4a3.25 3.25 0 0 1 6.5 1.35C14.5 10 8 14 8 14Z"
        stroke="currentColor"
        strokeWidth="1.25"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function RatingIcons() {
  return (
    <Rating
      icon={<HeartIcon />}
      emptyIcon={<HeartOutlineIcon />}
      color="danger"
      size="lg"
      defaultValue={3}
      label="How much did you like it?"
    />
  );
}
