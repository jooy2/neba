import { VisuallyHidden } from 'neba';

export default function VisuallyHiddenSkipLink() {
  return (
    <div className="flex flex-col gap-3">
      <VisuallyHidden
        render={<a href="#main-content" />}
        className="focus:relative focus:inline-flex focus:size-auto focus:overflow-visible focus:rounded-(--neba-radius-sm) focus:bg-(--neba-primary-fill) focus:px-3 focus:py-1.5 focus:text-(--neba-primary-on-solid) focus:[clip-path:none]"
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
