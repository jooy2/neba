import { useState } from 'react';
import { VisuallyHidden } from 'neba';

export default function VisuallyHiddenSkipLink() {
  const [focused, setFocused] = useState(false);

  return (
    <div className="flex flex-col gap-3">
      <VisuallyHidden
        render={<a href="#main-content" />}
        visible={focused}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        className={
          focused
            ? 'self-start rounded-(--neba-radius-sm) bg-(--neba-primary-fill) px-3 py-1.5 text-(--neba-primary-on-solid)'
            : undefined
        }
      >
        Skip to content
      </VisuallyHidden>

      <p className="text-sm text-(--neba-muted-fg)">
        Press <kbd>Tab</kbd> with this preview focused — the link appears, then hides again.
      </p>

      <div
        id="main-content"
        className="rounded-(--neba-radius-md) border border-(--neba-border) p-4"
      >
        Main content
      </div>
    </div>
  );
}
