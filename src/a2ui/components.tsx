'use client';

/**
 * The eighteen components of `catalog.json`, as the renderer draws them.
 *
 * Each one is `createComponentImplementation(api, view)`: the *api* is the Zod
 * derived from the catalog by `schema.ts`, and the *view* is the four or five
 * lines that turn the props A2UI resolved into the props a Neba component
 * takes. Nothing here decides anything about the vocabulary — if a prop is not
 * in `catalog.json`, an agent cannot write it, and adding one here would be a
 * prop the model was never told about.
 *
 * The binder does the work that would otherwise be in every view. A prop typed
 * `DynamicString` arrives as a `string`, however the agent wrote it — a
 * literal, a path into the data model, or a function call — and comes with a
 * `setValue`-shaped setter that writes back, which is the whole of two-way
 * binding. An `Action` arrives as a `() => void` with its context already
 * gathered. A schema carrying `checks` gets `isValid` and `validationErrors`
 * evaluated reactively.
 *
 * So a view has exactly three jobs: rename, render the children it was given
 * ids for, and put `validationErrors[0]` where the component draws an error.
 */

import * as React from 'react';
import { createComponentImplementation } from '@a2ui/react/v0_9';
import type { ReactComponentImplementation } from '@a2ui/react/v0_9';
import { Alert } from '../components/alert/Alert.js';
import { Avatar } from '../components/avatar/Avatar.js';
import { Button } from '../components/button/Button.js';
import { Card } from '../components/card/Card.js';
import { Checkbox } from '../components/checkbox/Checkbox.js';
import { Chip } from '../components/chip/Chip.js';
import { DataList, DataListItem } from '../components/data-list/DataList.js';
import { Divider } from '../components/divider/Divider.js';
import { Flex } from '../components/flex/Flex.js';
import { Image } from '../components/image/Image.js';
import { NumberField } from '../components/number-field/NumberField.js';
import { Radio, RadioGroup } from '../components/radio-group/RadioGroup.js';
import { Select } from '../components/select/Select.js';
import { Slider } from '../components/slider/Slider.js';
import { Statistic } from '../components/statistic/Statistic.js';
import { Switch } from '../components/switch/Switch.js';
import { TextField } from '../components/text-field/TextField.js';
import { Typography } from '../components/typography/Typography.js';
import catalog from './catalog.json' with { type: 'json' };
import { componentSchema, type CatalogSchema } from './schema.js';

/** What the binder hands a view, once the catalog's own props are resolved. */
type Bound = Record<string, never>;

/** One child reference, as the binder leaves it in a resolved child list. */
type ChildRef = string | { id: string; basePath?: string };

type BuildChild = (id: string, basePath?: string) => React.ReactNode;

/**
 * The children of a layout component.
 *
 * A `ChildList` is either an array of ids or a template the binder has already
 * expanded into one id per row of a data list — which is why an entry may be an
 * object carrying the `basePath` its own bindings resolve against. Anything
 * else is a list that has not resolved yet, and drawing nothing is right: the
 * next data message is what fills it.
 */
function Children({ list, buildChild }: { list: unknown; buildChild: BuildChild }) {
  if (!Array.isArray(list)) {
    return null;
  }

  // Keyed by what each child is rather than where it is: keyed by position, a
  // child put in front of the others remounted every one after it, and a field
  // among them lost its focus and whatever was being typed. A template's rows
  // share an id and differ by the path they are bound to. An id the agent
  // listed twice takes its count, so the key stays unique.
  const seen = new Map<string, number>();

  return (
    <>
      {(list as ChildRef[]).map((child) => {
        const id = typeof child === 'string' ? child : child.id;
        const basePath = typeof child === 'string' ? undefined : child.basePath;
        const identity = basePath === undefined ? id : `${id}@${basePath}`;
        const count = seen.get(identity) ?? 0;

        seen.set(identity, count + 1);

        return (
          <React.Fragment key={count === 0 ? identity : `${identity}#${count}`}>
            {buildChild(id, basePath)}
          </React.Fragment>
        );
      })}
    </>
  );
}

/**
 * What an agent wrote in a component's `accessibility`, for the roots that can
 * go without a name — a Flex, a Card, and a Button with no text — and for an
 * Image's description.
 *
 * Every component's schema accepts it, since the renderer expects that of a
 * v0.9 component, and the rest already name themselves from a prop they draw
 * — a field's `label`, a Chip's text, an Image's required `alt` — so a second
 * name there would only contradict the one on screen. `label` becomes the
 * name where there is none; `description` becomes a hidden element the root
 * is described by.
 */
function useAccessibility(props: { accessibility?: { label?: string; description?: string } }) {
  const id = React.useId();
  const label = props.accessibility?.label || undefined;
  const description = props.accessibility?.description || undefined;

  return {
    label,
    describedBy: description ? id : undefined,
    note: description ? (
      <span id={id} hidden>
        {description}
      </span>
    ) : null
  };
}

type Accessible = { accessibility?: { label?: string; description?: string } };

/**
 * A field's value, held here as well as wherever the agent put it.
 *
 * The views are controlled, and the binder hands a setter that writes to the
 * data model only when the value is bound to a path. A value that was a literal
 * or was left out came with a setter that did nothing, so the field could not
 * be typed in, ticked or moved at all. The draft is what the field shows and
 * what a reader changes; it follows the resolved value whenever that changes,
 * which is every change when it is bound, and the setter still writes through.
 */
function useDraft<T>(resolved: T, write?: (value: T) => void): [T, (value: T) => void] {
  const [draft, setDraft] = React.useState(resolved);
  const [seen, setSeen] = React.useState(resolved);

  if (!Object.is(resolved, seen)) {
    setSeen(resolved);
    setDraft(resolved);
  }

  return [
    draft,
    (value) => {
      setDraft(value);
      write?.(value);
    }
  ];
}

/** The first failed check, which is what a field draws under itself. */
function firstError(props: { validationErrors?: readonly string[] }): string | undefined {
  return props.validationErrors?.[0];
}

/**
 * One implementation, with the schema read out of the catalog by name.
 *
 * The cast is where the typing stops and has to: the schema is built at
 * runtime, so TypeScript cannot infer the props from it. What each view reads
 * is checked only by drawing it, in `test/a2ui/adapter.test.tsx` — a prop that
 * type-checks against a hand-written mirror of the catalog is a prop that
 * type-checks against the wrong thing.
 */
function implement(
  name: keyof typeof catalog.components,
  view: (bound: { props: never; buildChild: BuildChild }) => React.ReactNode
): ReactComponentImplementation {
  const api = {
    name,
    schema: componentSchema(name, catalog.components[name] as CatalogSchema)
  };

  return createComponentImplementation(api, view as never);
}

/* ---------------------------------------------------------------------------
 * Layout and surface
 * ------------------------------------------------------------------------- */

export const A2uiFlex = implement('Flex', ({ props, buildChild }) => {
  const p = props as Bound as {
    children?: unknown;
    direction?: 'horizontal' | 'vertical';
    spacing?: number;
    justifyContent?: 'start' | 'center' | 'end';
    alignItems?: 'start' | 'center' | 'end' | 'stretch' | 'baseline';
    wrap?: boolean;
  } & Accessible;
  const a11y = useAccessibility(p);

  return (
    <>
      <Flex
        // A named row of things is a group; an unnamed one is only layout.
        role={a11y.label ? 'group' : undefined}
        aria-label={a11y.label}
        aria-describedby={a11y.describedBy}
        direction={p.direction}
        spacing={p.spacing}
        justifyContent={p.justifyContent}
        alignItems={p.alignItems}
        wrap={p.wrap}
      >
        <Children list={p.children} buildChild={buildChild} />
      </Flex>
      {a11y.note}
    </>
  );
});

export const A2uiCard = implement('Card', ({ props, buildChild }) => {
  const p = props as Bound as {
    child?: string;
    title?: string;
    subtitle?: string;
    variant?: 'solid' | 'outline' | 'text';
    size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
    color?: 'primary';
    density?: 'default' | 'compact';
    elevation?: 0 | 1 | 2 | 3;
  } & Accessible;
  const a11y = useAccessibility(p);

  return (
    <>
      <Card
        role={a11y.label ? 'group' : undefined}
        aria-label={a11y.label}
        aria-describedby={a11y.describedBy}
        title={p.title}
        subtitle={p.subtitle}
        variant={p.variant}
        size={p.size}
        color={p.color}
        density={p.density}
        elevation={p.elevation}
      >
        {p.child ? buildChild(p.child) : null}
      </Card>
      {a11y.note}
    </>
  );
});

export const A2uiDivider = implement('Divider', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    orientation?: 'horizontal' | 'vertical';
    size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  };

  return (
    <Divider orientation={p.orientation} size={p.size}>
      {p.label}
    </Divider>
  );
});

export const A2uiAlert = implement('Alert', ({ props, buildChild }) => {
  const p = props as Bound as {
    child?: string;
    title?: string;
    color?: 'primary';
    variant?: 'solid' | 'outline' | 'text';
    size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
    density?: 'default' | 'compact';
  };

  return (
    <Alert title={p.title} color={p.color} variant={p.variant} size={p.size} density={p.density}>
      {p.child ? buildChild(p.child) : null}
    </Alert>
  );
});

/* ---------------------------------------------------------------------------
 * Display
 * ------------------------------------------------------------------------- */

export const A2uiTypography = implement('Typography', ({ props }) => {
  const p = props as Bound as {
    text?: string;
    level?: 'h1';
    weight?: 'regular';
    align?: 'start';
    color?: 'primary';
    lines?: number;
  };

  return (
    <Typography level={p.level} weight={p.weight} align={p.align} color={p.color} lines={p.lines}>
      {p.text}
    </Typography>
  );
});

export const A2uiImage = implement('Image', ({ props }) => {
  const p = props as Bound as {
    src?: string;
    alt?: string;
    ratio?: number;
    fit?: 'cover';
    rounded?: 'md';
  } & Accessible;
  const a11y = useAccessibility(p);

  return (
    <>
      <Image
        src={p.src ?? ''}
        alt={p.alt ?? ''}
        aria-describedby={a11y.describedBy}
        ratio={p.ratio}
        fit={p.fit}
        rounded={p.rounded}
      />
      {a11y.note}
    </>
  );
});

export const A2uiChip = implement('Chip', ({ props }) => {
  const p = props as Bound as {
    text?: string;
    variant?: 'outline';
    size?: 'md';
    color?: 'primary';
    count?: number;
    selected?: boolean;
  };

  return (
    <Chip variant={p.variant} size={p.size} color={p.color} count={p.count} selected={p.selected}>
      {p.text}
    </Chip>
  );
});

export const A2uiAvatar = implement('Avatar', ({ props }) => {
  const p = props as Bound as {
    src?: string;
    name?: string;
    shape?: 'circle' | 'square';
    size?: 'md';
    color?: 'primary';
  };

  return <Avatar src={p.src} name={p.name} shape={p.shape} size={p.size} color={p.color} />;
});

export const A2uiStatistic = implement('Statistic', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    value?: string;
    unit?: string;
    caption?: string;
    previousValue?: number;
    delta?: 'percent';
    betterWhen?: 'up' | 'down';
    size?: 'md';
    align?: 'start';
  };

  /*
   * The catalog types `value` as a string, since most figures are written out
   * — "4.2M", "12 of 20" — and a Statistic draws its delta only from a number.
   * With a `previousValue` to compare against, a value written as plain digits
   * is that number; anything else is drawn as it came, with no delta.
   */
  const written = p.value ?? '';
  const figure =
    p.previousValue !== undefined && /^[-+]?(\d+\.?\d*|\.\d+)(e[-+]?\d+)?$/i.test(written.trim())
      ? Number(written)
      : written;

  return (
    <Statistic
      label={p.label}
      value={figure}
      unit={p.unit}
      caption={p.caption}
      previousValue={p.previousValue}
      delta={p.delta}
      betterWhen={p.betterWhen}
      size={p.size}
      align={p.align}
    />
  );
});

export const A2uiDataList = implement('DataList', ({ props }) => {
  const p = props as Bound as {
    items?: readonly { label?: string; value?: string }[];
    orientation?: 'horizontal' | 'vertical';
    dividers?: boolean;
    size?: 'md';
    density?: 'default' | 'compact';
  };

  return (
    <DataList orientation={p.orientation} dividers={p.dividers} size={p.size} density={p.density}>
      {(p.items ?? []).map((item, index) => (
        <DataListItem key={`${item.label}-${index}`} label={item.label}>
          {item.value}
        </DataListItem>
      ))}
    </DataList>
  );
});

/* ---------------------------------------------------------------------------
 * Inputs
 * ------------------------------------------------------------------------- */

export const A2uiButton = implement('Button', ({ props }) => {
  const p = props as Bound as {
    text?: string;
    action?: () => void;
    variant?: 'solid';
    size?: 'md';
    color?: 'primary';
    density?: 'default';
    elevation?: 0;
    loading?: boolean;
    disabled?: boolean;
    fullWidth?: boolean;
    isValid?: boolean;
  } & Accessible;
  const a11y = useAccessibility(p);

  return (
    <>
      <Button
        // Only where the button says nothing: a name that differs from the
        // text on it is a name a voice user cannot say.
        aria-label={p.text ? undefined : a11y.label}
        aria-describedby={a11y.describedBy}
        onClick={p.action}
        variant={p.variant}
        size={p.size}
        color={p.color}
        density={p.density}
        elevation={p.elevation}
        loading={p.loading}
        // A button whose form has a failed check is a button that cannot be
        // pressed, which is what the specification's own renderer does with it.
        disabled={p.disabled || p.isValid === false}
        fullWidth={p.fullWidth}
      >
        {p.text}
      </Button>
      {a11y.note}
    </>
  );
});

export const A2uiTextField = implement('TextField', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    value?: string;
    setValue?: (value: string) => void;
    placeholder?: string;
    description?: string;
    multiline?: boolean;
    rows?: number;
    variant?: 'outline';
    size?: 'md';
    color?: 'primary';
    density?: 'default';
    required?: boolean;
    disabled?: boolean;
    readOnly?: boolean;
    fullWidth?: boolean;
    validationErrors?: readonly string[];
  };

  const [value, setValue] = useDraft(p.value ?? '', p.setValue);

  return (
    <TextField
      label={p.label}
      value={value}
      onChange={(event) => setValue(event.target.value)}
      placeholder={p.placeholder}
      description={p.description}
      error={firstError(p)}
      multiline={p.multiline}
      rows={p.rows}
      variant={p.variant}
      size={p.size}
      color={p.color}
      density={p.density}
      required={p.required}
      disabled={p.disabled}
      readOnly={p.readOnly}
      fullWidth={p.fullWidth}
    />
  );
});

export const A2uiNumberField = implement('NumberField', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    value?: number;
    setValue?: (value: number | null) => void;
    description?: string;
    min?: number;
    max?: number;
    step?: number;
    variant?: 'outline';
    size?: 'md';
    color?: 'primary';
    density?: 'default';
    required?: boolean;
    disabled?: boolean;
    readOnly?: boolean;
    validationErrors?: readonly string[];
  };

  const [value, setValue] = useDraft<number | null>(p.value ?? null, p.setValue);

  return (
    <NumberField
      label={p.label}
      value={value}
      onValueChange={setValue}
      description={p.description}
      error={firstError(p)}
      min={p.min}
      max={p.max}
      step={p.step}
      variant={p.variant}
      size={p.size}
      color={p.color}
      density={p.density}
      required={p.required}
      disabled={p.disabled}
      readOnly={p.readOnly}
    />
  );
});

export const A2uiCheckbox = implement('Checkbox', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    checked?: boolean;
    setChecked?: (checked: boolean) => void;
    description?: string;
    size?: 'md';
    color?: 'primary';
    required?: boolean;
    disabled?: boolean;
    validationErrors?: readonly string[];
  };

  const [checked, setChecked] = useDraft(p.checked ?? false, p.setChecked);

  return (
    <Checkbox
      label={p.label}
      checked={checked}
      onCheckedChange={setChecked}
      description={p.description}
      error={firstError(p)}
      size={p.size}
      color={p.color}
      required={p.required}
      disabled={p.disabled}
    />
  );
});

export const A2uiSwitch = implement('Switch', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    checked?: boolean;
    setChecked?: (checked: boolean) => void;
    description?: string;
    size?: 'md';
    color?: 'primary';
    disabled?: boolean;
  };

  const [checked, setChecked] = useDraft(p.checked ?? false, p.setChecked);

  return (
    <Switch
      label={p.label}
      checked={checked}
      onCheckedChange={setChecked}
      description={p.description}
      size={p.size}
      color={p.color}
      disabled={p.disabled}
    />
  );
});

export const A2uiRadioGroup = implement('RadioGroup', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    value?: string;
    setValue?: (value: string) => void;
    options?: readonly {
      label?: string;
      value: string;
      description?: string;
      disabled?: boolean;
    }[];
    description?: string;
    orientation?: 'horizontal' | 'vertical';
    size?: 'md';
    color?: 'primary';
    required?: boolean;
    disabled?: boolean;
    validationErrors?: readonly string[];
  };

  const [value, setValue] = useDraft<string | null>(p.value ?? null, (next) =>
    p.setValue?.(next ?? '')
  );

  return (
    <RadioGroup
      label={p.label}
      value={value}
      onValueChange={(next) => setValue(String(next))}
      description={p.description}
      error={firstError(p)}
      orientation={p.orientation}
      size={p.size}
      color={p.color}
      required={p.required}
      disabled={p.disabled}
    >
      {(p.options ?? []).map((option) => (
        <Radio
          key={option.value}
          value={option.value}
          label={option.label ?? option.value}
          description={option.description}
          disabled={option.disabled}
        />
      ))}
    </RadioGroup>
  );
});

export const A2uiSelect = implement('Select', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    value?: string;
    setValue?: (value: string) => void;
    placeholder?: string;
    options?: readonly { label?: string; value: string; group?: string; disabled?: boolean }[];
    description?: string;
    variant?: 'outline';
    size?: 'md';
    color?: 'primary';
    density?: 'default';
    required?: boolean;
    disabled?: boolean;
    fullWidth?: boolean;
    validationErrors?: readonly string[];
  };

  const [value, setValue] = useDraft<string | null>(p.value ?? null, (next) =>
    p.setValue?.(next ?? '')
  );

  return (
    <Select
      label={p.label}
      value={value}
      onValueChange={(next) => setValue(next === null ? null : String(next))}
      placeholder={p.placeholder}
      items={(p.options ?? []).map((option) => ({
        value: option.value,
        label: option.label,
        group: option.group,
        disabled: option.disabled
      }))}
      description={p.description}
      error={firstError(p)}
      variant={p.variant}
      size={p.size}
      color={p.color}
      density={p.density}
      required={p.required}
      disabled={p.disabled}
      fullWidth={p.fullWidth}
    />
  );
});

export const A2uiSlider = implement('Slider', ({ props }) => {
  const p = props as Bound as {
    label?: string;
    value?: number;
    setValue?: (value: number) => void;
    min?: number;
    max?: number;
    step?: number;
    description?: string;
    size?: 'md';
    color?: 'primary';
    disabled?: boolean;
  };

  const [value, setValue] = useDraft(p.value ?? p.min ?? 0, p.setValue);

  return (
    <Slider
      label={p.label}
      value={value}
      onValueChange={(next) => setValue(Array.isArray(next) ? next[0] : next)}
      min={p.min}
      max={p.max}
      step={p.step}
      description={p.description}
      size={p.size}
      color={p.color}
      disabled={p.disabled}
    />
  );
});

/** Every implementation, in the order the catalog lists them. */
export const nebaComponents: ReactComponentImplementation[] = [
  A2uiFlex,
  A2uiCard,
  A2uiDivider,
  A2uiTypography,
  A2uiImage,
  A2uiChip,
  A2uiAvatar,
  A2uiStatistic,
  A2uiDataList,
  A2uiAlert,
  A2uiButton,
  A2uiTextField,
  A2uiNumberField,
  A2uiCheckbox,
  A2uiSwitch,
  A2uiRadioGroup,
  A2uiSelect,
  A2uiSlider
];
