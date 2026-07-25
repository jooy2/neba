import { Button, Dialog, DialogClose } from 'neba';
import type { NebaSize } from 'neba';

const SIZES: NebaSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

export default function DialogSizes() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      {SIZES.map((size) => (
        <Dialog
          key={size}
          size={size}
          trigger={
            <Button size="sm" variant="outline" color="secondary">
              {size}
            </Button>
          }
          title={`A ${size} dialog`}
          description="The size sets the type scale, the padding and the width it is allowed to reach."
          actions={<DialogClose render={<Button size="sm">Close</Button>} />}
        >
          One axis rather than two: there is no separate `maxWidth` to keep in step with `size`.
        </Dialog>
      ))}
    </div>
  );
}
