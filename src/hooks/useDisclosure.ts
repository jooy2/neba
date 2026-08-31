'use client';

import * as React from 'react';

/** What `useDisclosure` hands back: the state, and the three ways to change it. */
export interface Disclosure {
  open: boolean;
  setOpen: (open: boolean) => void;
  onOpen: () => void;
  onClose: () => void;
  onToggle: () => void;
}

/**
 * The caller's half of the `open` / `onOpenChange` pair every overlay in the
 * library offers.
 *
 * A Dialog, a Drawer, a Popover, a Tour, a Menu, a CommandPalette and all four
 * pickers take the same three props, so the state beside them is the same six
 * lines every time — and the sixth is the one that gets written wrong: a
 * `setOpen(!open)` closed over a stale render rather than an updater.
 *
 * Every function it returns is stable for the life of the component, so passing
 * `onClose` straight to a memoised child does not re-render it on every open.
 */
export function useDisclosure(defaultOpen = false): Disclosure {
  const [open, setOpen] = React.useState(defaultOpen);

  const onOpen = React.useCallback(() => setOpen(true), []);
  const onClose = React.useCallback(() => setOpen(false), []);
  const onToggle = React.useCallback(() => setOpen((current) => !current), []);

  return React.useMemo(
    () => ({ open, setOpen, onOpen, onClose, onToggle }),
    [open, onOpen, onClose, onToggle]
  );
}
