import { Spoiler } from 'neba';

export default function SpoilerMedia() {
  return (
    <div className="w-full max-w-md">
      <Spoiler padded={false} label="Show the still" description="The last shot">
        <img
          src="/samples/photos/misty-tea-terraces-sunrise.jpg"
          alt="Terraced tea fields under morning mist"
          className="block w-full"
        />
      </Spoiler>
    </div>
  );
}
