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

  return (
    <>
      {(list as ChildRef[]).map((child, index) =>
        typeof child === 'string' ? (
          <React.Fragment key={`${child}-${index}`}>{buildChild(child)}</React.Fragment>
        ) : (
          <React.Fragment key={`${child.id}-${index}`}>
            {buildChild(child.id, child.basePath)}
          </React.Fragment>
        )
      )}
    </>
  );
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
 * is checked against the catalog by `test/package/a2ui.test.ts`, which is the
 * check that matters — a prop that type-checks against a hand-written mirror of
 * the catalog is a prop that type-checks against the wrong thing.
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
  };

  return (
    <Flex
      direction={p.direction}
      spacing={p.spacing}
      justifyContent={p.justifyContent}
      alignItems={p.alignItems}
      wrap={p.wrap}
    >
      <Children list={p.children} buildChild={buildChild} />
    </Flex>
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
  };

  return (
    <Card
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
  };

  return (
    <Image src={p.src ?? ''} alt={p.alt ?? ''} ratio={p.ratio} fit={p.fit} rounded={p.rounded} />
  );
});

export const A2uiChip = implement('Chip', ({ props }) => {
  const p = props as Bound as {
    text?: string;
    variant?: 'outline';
    size?: 'sm';
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

  return (
    <Statistic
      label={p.label}
      value={p.value ?? ''}
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
  };

  return (
    <Button
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

  return (
    <TextField
      label={p.label}
      value={p.value ?? ''}
      onChange={(event) => p.setValue?.(event.target.value)}
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

  return (
    <NumberField
      label={p.label}
      value={p.value ?? null}
      onValueChange={(value) => p.setValue?.(value)}
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

  return (
    <Checkbox
      label={p.label}
      checked={p.checked ?? false}
      onCheckedChange={(checked) => p.setChecked?.(checked)}
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

  return (
    <Switch
      label={p.label}
      checked={p.checked ?? false}
      onCheckedChange={(checked) => p.setChecked?.(checked)}
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

  return (
    <RadioGroup
      label={p.label}
      value={p.value ?? null}
      onValueChange={(value) => p.setValue?.(String(value))}
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

  return (
    <Select
      label={p.label}
      value={p.value ?? null}
      onValueChange={(value) => p.setValue?.(String(value ?? ''))}
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

  return (
    <Slider
      label={p.label}
      value={p.value ?? p.min ?? 0}
      onValueChange={(value) => p.setValue?.(Array.isArray(value) ? value[0] : value)}
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
