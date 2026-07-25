/**
 * The props tables, as data.
 *
 * They live here rather than as Markdown tables for three reasons: the shared
 * vocabulary (`variant`, `size`, `color`, `density`, `elevation`) is written
 * once and reused with per-component defaults, a union type like
 * `'solid' | 'outline' | 'text'` does not have to be escaped one pipe at a
 * time, and both locales come off one row — a Korean and an English table
 * cannot drift into listing different props.
 *
 * Rendered by `theme/components/PropsTable.vue`.
 */

import type { Locale } from './i18n';

/** Every human-readable string in here is written twice, once per locale. */
type Text = Record<Locale, string>;

export interface PropRow {
  name: string;
  type: string;
  /** Omitted when the prop has no default — rendered as `—`. */
  default?: string;
  required?: boolean;
  /** Part of the shared vocabulary in `src/types.ts`; tagged in the table. */
  shared?: boolean;
  description: Text;
}

const SIZE = "'xs' | 'sm' | 'md' | 'lg' | 'xl'";
const COLOR = "'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'";
const VARIANT = "'solid' | 'outline' | 'text'";
const DENSITY = "'default' | 'compact'";
const ELEVATION = '0 | 1 | 2 | 3';
const ORIENTATION = "'horizontal' | 'vertical'";

/** `size` and `color` alone, for the controls that have no surface to weigh. */
function scaleProps(size: string, color = "'primary'", colorDescription?: Text): PropRow[] {
  return [
    {
      name: 'size',
      type: SIZE,
      default: size,
      shared: true,
      description: { ko: '높이와 타입 스케일', en: 'Height and type scale' }
    },
    {
      name: 'color',
      type: COLOR,
      default: color,
      shared: true,
      description: colorDescription ?? {
        ko: '의미론적 색 역할. 임의 색상값은 받지 않습니다',
        en: 'Semantic colour role. Arbitrary colour values are not accepted'
      }
    }
  ];
}

/** The four slots a form control puts around itself. */
const fieldProps: PropRow[] = [
  {
    name: 'label',
    type: 'ReactNode',
    description: {
      ko: '컨트롤과 연결되는 라벨. Base UI Field가 묶어 줍니다',
      en: "The label, wired to the control by Base UI's Field"
    }
  },
  {
    name: 'description',
    type: 'ReactNode',
    description: { ko: '보조 설명', en: 'Helper text' }
  },
  {
    name: 'error',
    type: 'ReactNode',
    description: {
      ko: '오류 메시지. 값이 있으면 invalid 상태도 함께 켜지고 색 계열이 danger로 넘어갑니다',
      en: 'Error message. Its presence turns the control invalid and re-points the colour family at danger'
    }
  },
  {
    name: 'invalid',
    type: 'boolean',
    default: '!!error',
    description: {
      ko: '메시지 없이 invalid만 켭니다. 외부 폼 라이브러리가 유효성을 가질 때',
      en: 'Forces the invalid state without a message, for when a form library owns validity'
    }
  }
];

/** The two inert states, spelled the same way on every control. */
const inertProps: PropRow[] = [
  {
    name: 'readOnly',
    type: 'boolean',
    default: 'false',
    description: {
      ko: '값은 보이지만 바꿀 수 없음. 색과 가장자리는 유지한 채 채도만 빠집니다',
      en: 'Shown but not changeable. Keeps its colour and edge, drains the saturation'
    }
  },
  {
    name: 'disabled',
    type: 'boolean',
    default: 'false',
    description: {
      ko: '사용 불가. 색 계열을 버리고 중립 회색이 됩니다',
      en: 'Unavailable. Drops the colour family for neutral grey'
    }
  }
];

interface SharedOptions {
  variant: string;
  size: string;
  color?: string;
  density?: string;
  elevation?: string;
  variantDescription?: Text;
  sizeDescription?: Text;
  colorDescription?: Text;
  densityDescription?: Text;
  elevationDescription?: Text;
}

/** The four `NebaStyleProps` axes plus `elevation`, with per-component defaults. */
function sharedProps(options: SharedOptions): PropRow[] {
  return [
    {
      name: 'variant',
      type: VARIANT,
      default: options.variant,
      shared: true,
      description: options.variantDescription ?? {
        ko: '표면의 무게. 채움 / 하이라인 / 없음',
        en: 'Weight of the surface: filled, hairline, or none'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: options.size,
      shared: true,
      description: options.sizeDescription ?? {
        ko: '높이와 타입 스케일',
        en: 'Height and type scale'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: options.color ?? "'primary'",
      shared: true,
      description: options.colorDescription ?? {
        ko: '의미론적 색 역할. 임의 색상값은 받지 않습니다',
        en: 'Semantic colour role. Arbitrary colour values are not accepted'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: options.density ?? "'default'",
      shared: true,
      description: options.densityDescription ?? {
        ko: '여백만 바꿉니다. 높이와 글자 크기는 그대로',
        en: 'Padding only — never the height, never the type scale'
      }
    },
    {
      name: 'elevation',
      type: ELEVATION,
      default: options.elevation ?? '0',
      shared: true,
      description: options.elevationDescription ?? {
        ko: '그림자 깊이. 0은 그림자 없음',
        en: 'Drop shadow depth. 0 means no shadow at all'
      }
    }
  ];
}

export const propTables: Record<string, PropRow[]> = {
  Button: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      sizeDescription: {
        ko: '높이와 타입 스케일. xs 22px · sm 26px · md 32px · lg 40px · xl 48px',
        en: 'Height and type scale. xs 22px · sm 26px · md 32px · lg 40px · xl 48px'
      },
      elevationDescription: {
        ko: '그림자 깊이. 0은 그림자 없음. 호버는 한 단계 올리고, 누르면 한 단계 내립니다',
        en: 'Drop shadow depth. 0 is flat; hover adds a level and pressing removes one'
      }
    }),
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞에 놓이는 내용. 1.2em으로 그려져 라벨 크기를 따라갑니다',
        en: 'Content before the label. Sized in em, so it tracks the label'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '라벨 뒤에 놓이는 내용', en: 'Content after the label' }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'startIcon 자리에 스피너를 띄우고 활성화를 막습니다. 포커스는 유지됩니다',
        en: 'Spinner in place of startIcon; stops activation but keeps focus'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비활성이되 흐려지지 않음. 액션은 존재하지만 여기서는 쓸 수 없다는 뜻',
        en: 'Inert but not dimmed — the action exists, it just is not available here'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 색 계열을 버리고 중립 회색이 되며, 포커스 순서에서 빠집니다',
        en: 'Unavailable. Drops the colour family for neutral grey and leaves the tab order'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '라벨. 생략하면 정사각형 아이콘 버튼이 됩니다',
        en: 'The label. Omit it and the button goes square for an icon'
      }
    }
  ],

  TextField: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '높이와 타입 스케일. Button과 같은 높이라서 한 줄에 섞어 놓아도 기준선이 맞습니다',
        en: "Height and type scale. The same heights as Button, so a row's baseline holds"
      },
      variantDescription: {
        ko: '표면의 무게. solid도 색으로 채우지 않습니다 — 필드가 담는 것은 사용자 데이터입니다',
        en: 'Weight of the surface. Even solid is not flooded with colour — a field holds user data'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 가장자리와 포커스 링, 캐럿에만 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the edge, the focus ring and the caret'
      },
      elevationDescription: {
        ko: '그림자 깊이. 필드는 떠 있는 표면이 아니므로 거의 올리지 않습니다',
        en: 'Drop shadow depth. A field is a well, not a surface that floats — rarely raised'
      }
    }),
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 위 라벨. Base UI Field로 연결됩니다',
        en: "Label above the control, wired to it by Base UI's Field"
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '컨트롤 아래 보조 설명', en: 'Helper text below the control' }
    },
    {
      name: 'error',
      type: 'ReactNode',
      description: {
        ko: '컨트롤 아래 오류 메시지. 값이 있으면 invalid 상태도 함께 켜집니다',
        en: 'Error message below the control. Its presence also turns the field invalid'
      }
    },
    {
      name: 'invalid',
      type: 'boolean',
      default: '!!error',
      description: {
        ko: '메시지 없이 invalid만 켭니다. 외부 폼 라이브러리가 유효성을 가질 때',
        en: 'Forces the invalid state without a message, for when a form library owns validity'
      }
    },
    {
      name: 'multiline',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'input 대신 textarea로 렌더링합니다. 나머지 축은 그대로',
        en: 'Renders a textarea instead of an input. Every other axis stays identical'
      }
    },
    {
      name: 'rows',
      type: 'number',
      default: '3',
      description: { ko: 'multiline일 때 보이는 줄 수', en: 'Visible rows in multiline mode' }
    },
    {
      name: 'resize',
      type: "'none' | 'vertical' | 'horizontal' | 'both'",
      default: "'vertical'",
      description: {
        ko: '사용자가 끌어서 크기를 바꿀 수 있는 방향. 가로는 폼의 열을 깨뜨립니다',
        en: "Which way the user may drag it. Horizontal breaks a form's column"
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '컨트롤 앞에 놓이는 내용', en: 'Content before the control' }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: { ko: '컨트롤 뒤에 놓이는 내용', en: 'Content after the control' }
    },
    {
      name: 'loading',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'endIcon 자리에 스피너를 띄웁니다. 입력은 계속 가능합니다',
        en: 'Spinner in place of endIcon. Typing is deliberately still allowed'
      }
    },
    {
      name: 'readOnly',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '읽기 전용. 선택과 복사는 됩니다',
        en: 'Read-only. Selecting and copying still work'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    }
  ],

  Box: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. 시트는 염색되지 않으며, solid와 outline은 불투명도와 하이라인으로 갈립니다',
        en: 'Weight of the surface. The sheet is never dyed — solid and outline differ in opacity and hairline'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 하이라인에만 나타납니다 (solid에는 테두리가 없어 보이지 않습니다)',
        en: 'Semantic colour role. The surface is white, so it reaches the hairline only — invisible on solid, which has no border'
      },
      sizeDescription: {
        ko: '모서리 반경과 안쪽 여백. 높이도 글자 크기도 건드리지 않습니다',
        en: 'Corner radius and padding. Never a height, never the type scale'
      },
      elevationDescription: {
        ko: '그림자 깊이. variant가 text면 무시됩니다',
        en: 'Drop shadow depth. Ignored when variant is text'
      }
    }),
    {
      name: 'padded',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '안쪽 여백. 이미지·표처럼 가장자리까지 채우는 콘텐츠는 끄세요',
        en: 'Inner padding. Turn it off for full-bleed content — an image, a table'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'div 대신 다른 요소로 렌더링합니다. Base UI의 render prop 그대로',
        en: "Renders something other than a div. Base UI's own escape hatch"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '박스에 담기는 내용', en: 'What the box holds' }
    }
  ],

  Card: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 하이라인과 구분선에만 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the hairline and the dividers only'
      },
      sizeDescription: {
        ko: '모서리 반경, 안쪽 여백, 헤더와 본문의 타입 스케일',
        en: 'Corner radius, padding, and the type scale of the header and body'
      },
      elevationDescription: {
        ko: '그림자 깊이. variant가 text면 무시됩니다',
        en: 'Drop shadow depth. Ignored when variant is text'
      }
    }),
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목. 문서 개요에 넣어야 하면 실제 heading을 넘기세요 (title={<h2>…</h2>})',
        en: 'The heading. Pass a real heading element when it belongs in the document outline'
      }
    },
    {
      name: 'subtitle',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄. 한 단계 작고 muted',
        en: 'A second line under the title, one step down the type scale and muted'
      }
    },
    {
      name: 'headerAction',
      type: 'ReactNode',
      description: {
        ko: '헤더 행 끝에 고정되는 내용. 메뉴 버튼이나 상태 칩',
        en: 'Content pinned to the end of the header row — a menu button, a status chip'
      }
    },
    {
      name: 'footer',
      type: 'ReactNode',
      description: {
        ko: '아래 영역. 줄바꿈되는 행으로 배치됩니다',
        en: 'The bottom area, laid out as a wrapping row'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '섹션 사이를 공백 대신 하이라인으로 나눕니다. 선은 시트의 양 끝까지 닿습니다',
        en: 'Separates the sections with a hairline instead of space, edge to edge'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '카드 본문', en: "The card's body" }
    }
  ],

  ButtonGroup: [
    ...sharedProps({
      variant: '—',
      size: '—',
      color: '—',
      density: '—',
      elevation: '—',
      variantDescription: {
        ko: '그룹 안의 모든 버튼에 적용됩니다. 지정하지 않으면 Button 자신의 기본값이 그대로 쓰입니다',
        en: "Applied to every button in the group. Unset means the Button's own default stands"
      },
      sizeDescription: {
        ko: '그룹 안의 모든 버튼의 높이와 타입 스케일',
        en: 'Height and type scale for every button in the group'
      },
      colorDescription: {
        ko: '그룹 안의 모든 버튼의 색 역할. 버튼 하나가 자기 색을 따로 지정하면 그쪽이 이깁니다',
        en: "Colour role for every button in the group. A button's own prop still wins"
      },
      densityDescription: {
        ko: '그룹 안의 모든 버튼의 가로 여백',
        en: 'Horizontal padding for every button in the group'
      },
      elevationDescription: {
        ko: '그룹 안의 모든 버튼의 그림자 깊이',
        en: 'Drop shadow depth for every button in the group'
      }
    }),
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '버튼이 이어지는 방향. 세로면 위아래 모서리가 깎입니다',
        en: 'Which way the buttons run. Vertical flattens the top and bottom corners instead'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      description: {
        ko: '그룹 전체를 한 번에 비활성화합니다',
        en: 'Disables every button in the group at once'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '컨테이너 너비만큼 확장하고 버튼이 너비를 균등하게 나눠 가집니다',
        en: 'Stretches to the container and divides the width evenly between the buttons'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'Button들. 중간에 다른 요소로 감싸도 그룹의 값은 전달됩니다',
        en: 'The buttons. The shared props reach them even through a wrapper'
      }
    }
  ],

  Checkbox: [
    ...scaleProps("'md'"),
    ...fieldProps,
    {
      name: 'checked',
      type: 'boolean',
      description: {
        ko: '체크 여부. onCheckedChange와 함께 제어 컴포넌트로 씁니다',
        en: 'Whether it is ticked. Use with onCheckedChange for a controlled checkbox'
      }
    },
    {
      name: 'defaultChecked',
      type: 'boolean',
      default: 'false',
      description: { ko: '초기 체크 여부', en: 'The initial state, for an uncontrolled checkbox' }
    },
    {
      name: 'onCheckedChange',
      type: '(checked: boolean, details) => void',
      description: {
        ko: '체크 상태가 바뀔 때',
        en: 'Called when the checkbox is ticked or unticked'
      }
    },
    {
      name: 'indeterminate',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '켜짐도 꺼짐도 아닌 중간 상태. 하위 항목 일부만 체크된 부모 체크박스',
        en: 'Neither ticked nor unticked — a parent whose children disagree'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '폼 제출 전에 반드시 체크해야 함',
        en: 'Must be ticked before the form submits'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    ...inertProps
  ],

  Switch: [
    ...scaleProps("'md'"),
    ...fieldProps,
    {
      name: 'checked',
      type: 'boolean',
      description: {
        ko: '켜짐 여부. onCheckedChange와 함께 제어 컴포넌트로 씁니다',
        en: 'Whether it is on. Use with onCheckedChange for a controlled switch'
      }
    },
    {
      name: 'defaultChecked',
      type: 'boolean',
      default: 'false',
      description: { ko: '초기 켜짐 여부', en: 'The initial state, for an uncontrolled switch' }
    },
    {
      name: 'onCheckedChange',
      type: '(checked: boolean, details) => void',
      description: { ko: '켜고 꺼질 때', en: 'Called when the switch is turned on or off' }
    },
    {
      name: 'labelPlacement',
      type: "'start' | 'end'",
      default: "'end'",
      description: {
        ko: '라벨이 놓이는 쪽. start는 설정 목록처럼 스위치가 오른쪽에 정렬되어야 할 때',
        en: 'Which side the label sits on. `start` is for a settings list, where the switches line up on the right'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    ...inertProps
  ],

  RadioGroup: [
    ...scaleProps("'md'", "'primary'", {
      ko: '의미론적 색 역할. 그룹이 정하고 모든 Radio가 물려받습니다',
      en: 'Semantic colour role. Set on the group, inherited by every Radio'
    }),
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'vertical'",
      shared: true,
      description: {
        ko: '옵션이 쌓이는 방향. 세로가 기본입니다 — 가로는 라벨이 길어지는 순간 읽을 수 없어집니다',
        en: 'Which way the options stack. Vertical by default — a row breaks the moment one label is long'
      }
    },
    ...fieldProps,
    {
      name: 'value',
      type: 'Value',
      description: {
        ko: '선택된 값. onValueChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The chosen value. Use with onValueChange for a controlled group'
      }
    },
    {
      name: 'defaultValue',
      type: 'Value',
      description: { ko: '초기 선택 값', en: 'The initial value, for an uncontrolled group' }
    },
    {
      name: 'onValueChange',
      type: '(value: Value, details) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen option changes' }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '폼 제출 전에 하나를 골라야 함',
        en: 'One option must be chosen before the form submits'
      }
    },
    ...inertProps,
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'Radio들', en: 'The Radio options' }
    }
  ],

  Radio: [
    {
      name: 'value',
      type: 'Value',
      required: true,
      description: {
        ko: '이 옵션을 식별하는 값. 그룹의 value와 같은 언어로 말합니다',
        en: 'Identifies this option. Speaks the same language as the group’s value'
      }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '점 옆의 라벨', en: 'The text beside the dot' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 보조 설명', en: 'Helper text under the label' }
    },
    ...inertProps
  ],

  Select: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. TextField와 같은 셸이므로 폼 안에서 두 컨트롤이 구분되지 않습니다',
        en: 'Weight of the surface. The same shell as a TextField, so the two are indistinguishable in a form'
      },
      sizeDescription: {
        ko: '높이와 타입 스케일. Button·TextField와 같은 높이입니다',
        en: 'Height and type scale. The same heights as Button and TextField'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 가장자리와 포커스 링에만 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the edge and the focus ring'
      },
      elevationDescription: {
        ko: '트리거의 그림자 깊이. 팝업은 자기 그림자를 따로 가집니다',
        en: 'Drop shadow depth of the trigger. The popup carries its own'
      }
    }),
    {
      name: 'items',
      type: 'readonly SelectOption[]',
      required: true,
      description: {
        ko: '옵션 목록. { value, label?, disabled? } 배열입니다',
        en: 'The options, as an array of { value, label?, disabled? }'
      }
    },
    {
      name: 'value',
      type: 'string | number | null',
      description: {
        ko: '선택된 값. onValueChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The chosen value. Use with onValueChange for a controlled select'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      description: { ko: '초기 선택 값', en: 'The initial value, for an uncontrolled select' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | null) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen value changes' }
    },
    {
      name: 'placeholder',
      type: 'ReactNode',
      description: {
        ko: '아무것도 고르지 않았을 때 트리거에 보이는 내용',
        en: 'Shown in the trigger while nothing is chosen'
      }
    },
    ...fieldProps,
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '값 앞에 놓이는 내용', en: 'Content before the value' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    },
    ...inertProps
  ],

  Slider: [
    ...scaleProps("'md'"),
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '트랙이 놓이는 방향. 세로는 길이를 직접 정해 주세요',
        en: 'Which way the track runs. A vertical slider needs a height of its own'
      }
    },
    {
      name: 'value',
      type: 'number | number[]',
      description: {
        ko: '현재 값. 배열이면 thumb이 값마다 하나씩 생깁니다',
        en: 'The current value. An array gives one thumb per entry'
      }
    },
    {
      name: 'defaultValue',
      type: 'number | number[]',
      description: { ko: '초기 값', en: 'The initial value, for an uncontrolled slider' }
    },
    {
      name: 'onValueChange',
      type: '(value, details) => void',
      description: { ko: '끄는 동안 계속 호출됩니다', en: 'Called throughout the drag' }
    },
    {
      name: 'onValueCommitted',
      type: '(value, details) => void',
      description: {
        ko: '값이 확정될 때 한 번만. 네트워크 요청은 이쪽에 거세요',
        en: 'Called once, when the value settles. Put the network request here'
      }
    },
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: { ko: '최솟값', en: 'The lowest allowed value' }
    },
    {
      name: 'max',
      type: 'number',
      default: '100',
      description: { ko: '최댓값', en: 'The highest allowed value' }
    },
    {
      name: 'step',
      type: 'number',
      default: '1',
      description: { ko: '값이 움직이는 단위', en: 'The granularity the value moves in' }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '트랙 위의 라벨', en: 'The label above the track' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '트랙 아래 보조 설명', en: 'Helper text below the track' }
    },
    {
      name: 'showValue',
      type: 'boolean | ((formatted, values) => ReactNode)',
      default: 'false',
      description: {
        ko: '라벨 옆에 현재 값을 보여 줍니다. 함수를 넘기면 표시 형식을 직접 정할 수 있습니다',
        en: 'Shows the current value beside the label. Pass a function to format it'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    }
  ],

  Divider: [
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '선이 놓이는 방향. 세로 선은 자기 높이가 없고 flex 부모에 맞춰 늘어납니다',
        en: 'Which way the line runs. A vertical rule has no height of its own — it stretches to its flex parent'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. Card가 섹션을 나눌 때 쓰는 것과 같은 하이라인입니다',
        en: 'Semantic colour role. The same hairline a Card scores its sections with'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '라벨의 타입 스케일. 선 자체에는 크기가 없습니다',
        en: 'Type scale of the label. The line itself has no size'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '선 사이에 들어가는 라벨. 문자열이면 aria-label로도 쓰입니다',
        en: 'A label set into the line. A string is copied into aria-label as well'
      }
    },
    {
      name: 'textAlign',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      description: {
        ko: '라벨의 위치. 가운데가 아니면 가까운 쪽에 짧은 선이 남습니다',
        en: 'Where the label sits. Off-centre leaves a short stub on the near side'
      }
    }
  ],

  Chip: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '높이와 타입 스케일. 같은 size의 컨트롤보다 한 단계 낮습니다 — md 칩은 sm 컨트롤입니다',
        en: 'Height and type scale, one step below the control of the same size — a md chip is a sm control'
      },
      elevationDescription: {
        ko: '그림자 깊이. 칩은 다른 것 위에 얹힌 토큰이라 거의 올리지 않습니다',
        en: 'Drop shadow depth. A chip sits on something else, so this is rarely raised'
      }
    }),
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞에 놓이는 내용 — 아이콘, 상태 점, 아바타',
        en: 'Content before the label — an icon, a status dot, an avatar'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤, count 앞에 놓이는 내용',
        en: 'Content after the label, before any count'
      }
    },
    {
      name: 'count',
      type: 'ReactNode',
      description: {
        ko: '끝에 붙는 숫자. 자기 판 위에 그려져 칩 하나로 읽힙니다',
        en: 'A number set into the end, on its own small plate'
      }
    },
    {
      name: 'onClick',
      type: '(event) => void',
      description: {
        ko: '넘기면 라벨이 진짜 button이 됩니다',
        en: 'Passing it turns the label into a real button'
      }
    },
    {
      name: 'onDelete',
      type: '(event) => void',
      description: {
        ko: '넘기면 삭제 버튼이 나타납니다. onClick과 별개의 버튼입니다',
        en: 'Passing it adds the delete button — its own button, separate from onClick'
      }
    },
    {
      name: 'deleteLabel',
      type: 'string',
      default: "'Remove'",
      description: { ko: '삭제 버튼의 접근성 이름', en: 'Accessible name of the delete button' }
    },
    {
      name: 'selected',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '선택됨. 색 계열을 바꾸는 대신 표면을 한 단계 깊게 만듭니다',
        en: 'Chosen. Deepens the surface a step rather than changing the colour family'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가', en: 'Unavailable' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '칩의 라벨', en: "The chip's label" }
    }
  ],

  Table: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. Box에 그대로 전달됩니다 — text로 두면 시트 없이 행만 남습니다',
        en: 'Weight of the surface, passed straight to the Box. `text` leaves the rows with no sheet'
      },
      sizeDescription: {
        ko: '셀의 타입 스케일과 여백, 시트의 모서리 반경',
        en: 'Type scale and padding of the cells, and the radius of the sheet'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 시트는 흰색이므로 하이라인과 행 사이 선에만 나타납니다',
        en: 'Semantic colour role. The sheet is white, so it reaches the hairline and the rules between rows'
      }
    }),
    {
      name: 'headers',
      type: 'readonly TableColumn[]',
      required: true,
      description: {
        ko: '열 정의. key·label·width·align·render를 가집니다',
        en: 'The columns: key, label, width, align and render'
      }
    },
    {
      name: 'items',
      type: 'readonly Row[]',
      required: true,
      description: { ko: '행 데이터', en: 'The rows' }
    },
    {
      name: 'getRowKey',
      type: '(row, index) => Key',
      default: 'index',
      description: {
        ko: '행의 안정적인 key. 정렬이나 필터가 있으면 반드시 넘기세요',
        en: 'A stable key per row. Required the moment the table sorts or filters'
      }
    },
    {
      name: 'caption',
      type: 'ReactNode',
      description: {
        ko: '표 위의 설명. 접근성 이름으로도 읽힙니다',
        en: 'Shown above the table, and read as its accessible name'
      }
    },
    {
      name: 'empty',
      type: 'ReactNode',
      default: "'No data'",
      description: {
        ko: 'items가 비었을 때 대신 보여 줄 내용',
        en: 'What to show instead of rows when items is empty'
      }
    },
    {
      name: 'striped',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '한 행 걸러 배경을 깝니다. 넓은 표에서 눈이 가로로 따라가야 할 때',
        en: 'Tints every other row. For a wide table the eye has to track across'
      }
    },
    {
      name: 'hoverable',
      type: 'boolean',
      default: 'false',
      description: { ko: '포인터가 올라간 행을 밝힙니다', en: 'Lights the row under the pointer' }
    },
    {
      name: 'stickyHeader',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '본문이 스크롤될 때 머리행을 고정합니다. 표의 높이가 제한되어 있어야 의미가 있습니다',
        en: 'Pins the header while the body scrolls. Only does anything if the height is constrained'
      }
    },
    {
      name: 'onRowClick',
      type: '(row, index) => void',
      description: { ko: '행을 누를 수 있게 만듭니다', en: 'Makes the rows activatable' }
    }
  ],

  Typography: [
    {
      name: 'level',
      type: "'h1'…'h6' | 'lead' | 'body' | 'caption' | 'overline'",
      default: "'body'",
      description: {
        ko: '타입 스케일과 렌더링할 요소를 함께 정합니다. variant라고 부르지 않는 이유는 이 라이브러리에서 variant가 이미 표면의 무게를 뜻하기 때문입니다',
        en: 'The type scale, and the element that carries it. Not called `variant` — that word already means the weight of a surface here'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '의미론적 색 역할. 다른 컴포넌트와 달리 기본값이 없습니다 — 지정하지 않으면 페이지의 글자색을 그대로 씁니다',
        en: 'Semantic colour role. Unlike every other component this has no default: unset means the page’s own colour'
      }
    },
    {
      name: 'weight',
      type: "'regular' | 'medium' | 'semibold' | 'bold'",
      description: {
        ko: 'level이 정한 굵기를 덮어씁니다',
        en: 'Overrides the weight the level would pick'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end' | 'justify'",
      description: { ko: '텍스트 정렬', en: 'Text alignment' }
    },
    {
      name: 'lines',
      type: 'number',
      description: {
        ko: '이 줄 수로 자르고 말줄임표를 붙입니다. 1이면 한 줄 자르기',
        en: 'Clamps to this many lines with an ellipsis. 1 is a single-line truncation'
      }
    },
    {
      name: 'gutter',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '아래 여백을 붙입니다. 기본이 꺼짐인 이유는 여백을 스스로 만드는 컴포넌트는 레이아웃이 싸워야 할 대상이기 때문입니다',
        en: 'Adds the space below. Off by default: a component that injects margins is one a layout has to fight'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: '타입 스케일은 그대로 두고 요소만 바꿉니다. Base UI의 render prop 그대로',
        en: "Changes the element without changing the type scale. Base UI's own escape hatch"
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '텍스트', en: 'The text' }
    }
  ]
};
