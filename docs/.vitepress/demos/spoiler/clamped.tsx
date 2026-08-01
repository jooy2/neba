import { Spoiler, Typography } from 'neba';

export default function SpoilerClamped() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <Spoiler maxHeight={120}>
        <Typography>
          The whole third act turns on the letter, which is why the first two acts keep putting it
          in shot without ever letting anybody read it. The camera passes it four times before the
          scene in the kitchen: on the hall table, in the coat, under the bowl of keys, and finally
          in her hand at the top of the stairs, where the film cuts away for the last time. When it
          is finally read out it takes ninety seconds, and everything anyone said in the first hour
          means something else.
        </Typography>
      </Spoiler>

      <Spoiler reversible>
        <Typography>
          Reversible, so the cover can go back on — useful when the spoiler sits in a page somebody
          scrolls past more than once.
        </Typography>
      </Spoiler>
    </div>
  );
}
