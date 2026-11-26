'use client';

import * as React from 'react';
import { Field } from '@base-ui/react/field';
import { ChevronIcon } from '../../internal/icons.js';
import { useHydrated } from '../../internal/media.js';
import { FieldNotch, NotchFrame } from '../../internal/notch.js';
import { WidthSizer, widestSamples } from '../../internal/sizer.js';
import { fieldSpotlightSlot, glowClasses, trackPointer } from '../../internal/glow.js';
import { useFieldsetDisabled } from '../../internal/fieldset.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import {
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldHeightClasses,
  fieldRestClasses,
  fieldRingClasses,
  fieldSheetClasses,
  fieldSheetDisabledClasses,
  gapClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  selectTriggerClasses,
  stackGapClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { NebaColor, NebaDensity, NebaLabelPlacement, NebaSize } from '../../types.js';

/**
 * The Select, fetched only by a table that pages.
 *
 * A Select is most of what a DataTable weighed — Base UI's listbox, its
 * positioning and its typeahead — and the only thing in the table that draws
 * one is the footer of `paging="pages"`, which is not the default. A static
 * import put every byte of it in the bundle of a table that scrolls, so this
 * is the Image viewer's arrangement: the chunk is fetched once, by the first
 * table that pages, as soon as it mounts.
 */
const requestSelect = () =>
  import('../select/Select.js').then((module) => ({ default: module.Select }));

let selectRequest: ReturnType<typeof requestSelect> | undefined;
let selectArrived = false;

/**
 * The one request for the Select's chunk, shared by every table that asks. A
 * request that fails is forgotten, so the next one tries again rather than
 * failing for good.
 *
 * An object rather than a function so a test can spy on it. Exported for that,
 * and deliberately left out of the barrel.
 */
export const rowsPerPageChunk = {
  load() {
    selectRequest ??= requestSelect().then(
      (module) => {
        selectArrived = true;

        return module;
      },
      (error: unknown) => {
        selectRequest = undefined;

        throw error;
      }
    );

    return selectRequest;
  },
  /** Whether the chunk is here, so a table mounted after it draws the Select at once. */
  arrived() {
    return selectArrived;
  }
};

const LazySelect = React.lazy(() => rowsPerPageChunk.load());

export interface RowsPerPageProps {
  size: NebaSize;
  color: NebaColor;
  density: NebaDensity;
  /** The control's name, which the label says. */
  label: string;
  options: readonly number[];
  value: number;
  onChange: (value: number) => void;
}

/**
 * The closed Select, drawn without the Select.
 *
 * What stands in while the chunk is on its way, and what a server sends: the
 * root, the label, the trigger with the value in it, the widths it reserves
 * and the chevron, written as the Select writes them, so that the moment the
 * real one replaces it nothing moves and nothing changes colour. A notched or
 * a floating label is drawn too, since a provider's `labelPlacement` reaches
 * the Select and a label that jumped from above the field onto its edge would
 * be the shift this exists to avoid.
 *
 * It is a button that cannot open anything yet. The chunk is asked for when
 * the table mounts, so a reader rarely meets it; the focus, if it lands here,
 * is handed to the Select when it arrives, and a press it takes is reported
 * through `onPress` so that the Select arrives open rather than asking for the
 * press again.
 */
const RowsPerPageStandIn = React.forwardRef<
  HTMLButtonElement,
  RowsPerPageProps & {
    labelPlacement: NebaLabelPlacement;
    disabled: boolean;
    onPress: (node: HTMLButtonElement) => void;
  }
>(function RowsPerPageStandIn(
  { size, color, density, label, options, value, labelPlacement, disabled, onPress },
  ref
) {
  const id = React.useId();
  const variant = 'outline';
  const notched = labelPlacement !== 'top' && label !== '';
  const rests = notched && labelPlacement === 'float';
  const samples = widestSamples([...options.map(String), ...(rests ? [label] : [])]);

  const trigger = (
    <button
      ref={ref}
      type="button"
      id={id}
      role="combobox"
      aria-expanded="false"
      aria-haspopup="listbox"
      disabled={disabled}
      data-neba-stand-in=""
      onPointerMove={trackPointer(undefined, !disabled)}
      // The presses a Select opens on. A mouse opens it as the button goes
      // down; a finger, a pen and Enter or Space arrive as a click, which a
      // finger that only started a scroll never sends; and an arrow opens it
      // from the keyboard.
      onPointerDown={(event) => {
        if (event.pointerType === 'mouse' && event.button === 0) {
          onPress(event.currentTarget);
        }
      }}
      onClick={(event) => onPress(event.currentTarget)}
      onKeyDown={(event) => {
        if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
          event.preventDefault();
          onPress(event.currentTarget);
        }
      }}
      className={cx(
        selectTriggerClasses,
        fieldHeightClasses[size],
        controlTextLeadingClasses[size],
        radiusClasses[size],
        gapClasses[size],
        paddingXClasses[density][size],
        notched ? '' : fieldRingClasses,
        disabled
          ? (notched ? fieldSheetDisabledClasses : disabledClasses)[variant]
          : `${(notched ? fieldSheetClasses : fieldRestClasses)[variant]} ${glowClasses}`,
        rests ? 'neba-float-control' : ''
      )}
    >
      <span className="flex min-w-0 flex-1 flex-col">
        <span className="w-full truncate text-start data-[placeholder]:text-(--neba-muted-fg)">
          {String(value)}
        </span>
        <WidthSizer samples={samples} />
      </span>

      <span
        aria-hidden="true"
        className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg) [transition:rotate_var(--neba-duration)_var(--neba-ease)] data-[popup-open]:rotate-180"
      >
        <ChevronIcon />
      </span>
    </button>
  );

  // A Field around it as the Select has one, and for the same label: Base UI's
  // label will not draw outside one. It is pointed at the stand-in's own
  // trigger, since nothing here registers itself with the Field as a control.
  return (
    <Field.Root
      disabled={disabled}
      className={cx('flex-col align-top', stackGapClasses[size], 'inline-flex')}
      style={{ ...surfaceSlots(color, 0), ...(disabled ? undefined : fieldSpotlightSlot) }}
    >
      {notched ? null : (
        <Field.Label
          htmlFor={id}
          className={cx(
            metaTextClasses[size],
            'font-medium',
            disabled ? 'text-(--neba-disabled-fg)' : 'text-(--neba-fg)'
          )}
        >
          {label}
        </Field.Label>
      )}

      {notched ? (
        <NotchFrame
          label={label}
          size={size}
          density={density}
          variant={variant}
          className={cx(radiusClasses[size], disabled ? 'cursor-not-allowed' : 'cursor-pointer')}
        >
          {trigger}
          <FieldNotch
            label={label}
            variant={variant}
            disabled={disabled}
            readOnly={false}
            rests={rests}
            beside
            htmlFor={id}
          />
        </NotchFrame>
      ) : (
        trigger
      )}
    </Field.Root>
  );
});

/**
 * The footer's page-size control: the Select once its chunk is here, and the
 * stand-in above until then.
 *
 * Never the Select in a server render or in the render that hydrates one, and
 * no Suspense boundary around it there either. A lazy component suspends
 * wherever its chunk has not loaded: `renderToString` gives up on the boundary
 * around it and leaves React an error to report at hydration, and a streaming
 * render sends the fallback and the content both, the second to be swapped in
 * by a script. So the server sends the stand-in alone, the browser hydrates
 * it, and the Select takes its place once the chunk has arrived, in a
 * transition. The boundary is there from then on for a table mounted before
 * React has drawn a Select from the chunk, which shows the stand-in for the
 * moment that takes.
 */
export function RowsPerPage(props: RowsPerPageProps) {
  // The Select reads both, so the stand-in reads them the same way.
  const { labelPlacement = 'top' } = useStyleDefaults<{ labelPlacement?: NebaLabelPlacement }>({}, [
    'labelPlacement'
  ]);
  const disabled = useFieldsetDisabled(false);
  const hydrated = useHydrated();
  const [ready, setReady] = React.useState(() => hydrated && rowsPerPageChunk.arrived());
  /**
   * Whether the Select mounts open. Settled before it mounts and never changed
   * after, since it is only the Select's `defaultOpen`: from then on the
   * Select's state is its own, exactly as when it was there from the start.
   */
  const [openOnArrival, setOpenOnArrival] = React.useState(false);
  const standInRef = React.useRef<HTMLButtonElement | null>(null);
  /** Whether the stand-in had the focus when the Select was sent for. */
  const focused = React.useRef(false);
  /** Whether the stand-in was pressed while the Select was on its way. */
  const pressed = React.useRef(false);

  React.useEffect(() => {
    if (ready) {
      return;
    }

    let live = true;

    rowsPerPageChunk.load().then(
      () => {
        if (!live) {
          return;
        }

        focused.current =
          standInRef.current !== null && document.activeElement === standInRef.current;
        // A press counts only while the reader is still where they pressed:
        // one who has moved on is not sent back by a list opening behind them.
        const opening = focused.current && pressed.current;

        pressed.current = false;
        React.startTransition(() => {
          setReady(true);
          setOpenOnArrival(opening);
        });
      },
      // The stand-in stays. A table mounted later asks again.
      () => {}
    );

    return () => {
      live = false;
    };
  }, [ready]);

  /*
   * The focus the stand-in held, handed to the Select's trigger as it mounts.
   * Only where the stand-in left it, on the page itself: the reader may have
   * moved on in the meantime.
   */
  const attachSelect = React.useCallback((node: HTMLButtonElement | null) => {
    if (!node || !focused.current) {
      return;
    }

    focused.current = false;

    if (document.activeElement === null || document.activeElement === document.body) {
      node.focus();
    }
  }, []);

  /*
   * A press on the stand-in, kept for the Select. The focus goes to the
   * stand-in with it, because Safari does not focus a button that is clicked
   * and the press only counts while the focus is still there. Once the chunk
   * is here and React is only drawing the Select from it, the stand-in is the
   * Suspense fallback, and the press decides the Select's `defaultOpen` at
   * once.
   */
  const press = (node: HTMLButtonElement) => {
    node.focus();

    if (ready) {
      focused.current = true;
      setOpenOnArrival(true);
    } else {
      pressed.current = true;
    }
  };

  const standIn = (
    <RowsPerPageStandIn
      ref={standInRef}
      {...props}
      labelPlacement={labelPlacement}
      disabled={disabled}
      onPress={press}
    />
  );

  if (!ready) {
    return standIn;
  }

  return (
    <React.Suspense fallback={standIn}>
      <LazySelect
        ref={attachSelect}
        size={props.size}
        color={props.color}
        density={props.density}
        variant="outline"
        label={props.label}
        items={props.options.map((value) => ({ value }))}
        value={props.value}
        defaultOpen={openOnArrival}
        onValueChange={(value) => props.onChange(Number(value))}
      />
    </React.Suspense>
  );
}
