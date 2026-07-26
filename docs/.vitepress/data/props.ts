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

/**
 * What the three progress indicators share. The same rows, three tables, so a
 * reader on the ProgressBox page does not have to go and look at the bar's.
 */
function progressProps(sizeDescription: Text): PropRow[] {
  return [
    {
      name: 'value',
      type: 'number | null',
      default: 'null',
      description: {
        ko: 'min과 max 사이의 진행도. null(기본값)은 미정 상태입니다 — 값을 듣지 못한 표시기는 빈 막대를 그리는 대신 모른다고 말해야 합니다',
        en: 'How far along, between min and max. null — the default — is indeterminate: an indicator that has not been told a value should say so rather than draw an empty bar'
      }
    },
    {
      name: 'min',
      type: 'number',
      default: '0',
      description: { ko: '범위의 시작', en: 'The bottom of the range' }
    },
    {
      name: 'max',
      type: 'number',
      default: '100',
      description: { ko: '범위의 끝', en: 'The top of the range' }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: sizeDescription
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '의미론적 색 역할', en: 'Semantic colour role' }
    },
    {
      name: 'label',
      type: 'ReactNode',
      description: {
        ko: '무엇을 기다리는지. 값과 함께 스크린 리더가 읽습니다',
        en: 'A name for what is loading. Read out with the value by a screen reader'
      }
    },
    {
      name: 'showValue',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '도형 옆에 값을 글자로 보여 줍니다. format이 없으면 범위에 대한 백분율입니다',
        en: 'Shows the value as text beside the shape. Percentage of the range unless format says otherwise'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '값을 어떻게 쓸지. 없으면 min…max에 대한 백분율 — 설명되지 않은 범위에서 유일하게 성립하는 표기입니다',
        en: 'How to write the value. Without it the value is a percentage of min…max, the only formatting that holds for a range nobody described'
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

  Alert: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      color: "'info'",
      colorDescription: {
        ko: '심각도. 표면과 글리프를 함께 정합니다. 기본값이 primary가 아닌 info인 이유는, 심각도를 말하지 않은 알림은 정보 알림이기 때문입니다',
        en: 'The severity: it picks the surface and the glyph together. The default is info rather than primary — an alert with no severity named is an informational one'
      },
      variantDescription: {
        ko: '표면의 무게. 알림은 색이 입혀지는 대상이므로 시트가 실제로 물듭니다. text는 폼 안에 놓을 때',
        en: 'Weight of the surface. An alert *is* the thing being coloured, so the sheet takes the tint. Reach for text inside a form'
      },
      elevationDescription: {
        ko: '그림자 깊이. 알림은 페이지 흐름 안에 있습니다 — 떠 있는 쪽은 Toast입니다',
        en: 'Drop shadow depth. An alert sits in the flow of the page; the one that floats is a Toast'
      }
    }),
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목 줄. 있으면 제목+설명 두 단짜리가 되고, 없으면 전체가 한 줄입니다',
        en: 'The heading line. With it the alert is two-part; without it the whole thing is one line'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '앞머리 글리프. 기본값은 color에 딸린 그림, false면 생략. 색만으로 심각도를 말하지 않기 위해 계열마다 모양이 다릅니다',
        en: 'The glyph at the start. Defaults to the one that goes with `color`; `false` drops it. The shapes differ per family so severity is not carried by colour alone'
      }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '행 끝에 고정되는 내용 — 재시도 버튼, 링크. 본문이 줄바꿈되어도 첫 줄에 남습니다',
        en: 'Content pinned to the end of the row. Stays on the first line while the message wraps'
      }
    },
    {
      name: 'onClose',
      type: '(event) => void',
      description: {
        ko: '넘기면 닫기 버튼이 생깁니다',
        en: 'Passing it is what makes the dismiss button appear'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      default: "'Dismiss'",
      description: { ko: '닫기 버튼의 접근성 이름', en: 'Accessible name of the dismiss button' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '메시지', en: 'The message' }
    }
  ],

  Dialog: [
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: {
        ko: '타입 스케일과 여백, 그리고 시트가 넓어질 수 있는 한계까지 함께 정합니다. maxWidth라는 두 번째 축을 만들지 않은 이유입니다',
        en: 'The type scale, the padding, and how wide the sheet may get. One axis rather than a second scale spelled maxWidth'
      }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 시트는 물들지 않으므로 가장자리와 포커스 링에만 나타납니다',
        en: 'Semantic colour role. The sheet is never dyed, so it reaches the edge and the focus ring'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. onOpenChange와 함께 쓰면 제어 컴포넌트가 됩니다',
        en: 'Whether it is shown. With onOpenChange, a controlled dialog'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비제어 다이얼로그의 초기 상태',
        en: 'The initial state of an uncontrolled dialog'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때 호출', en: 'Called when it opens or closes' }
    },
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '다이얼로그를 여는 요소. Base UI가 연결합니다. 선택 사항 — 다른 곳에서 여는 제어 다이얼로그에는 필요 없습니다',
        en: 'The element that opens it, wired up by Base UI. Optional — a controlled dialog opened elsewhere needs none'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: {
        ko: '제목. 다이얼로그의 이름이 되는 h2로 렌더링됩니다',
        en: 'The heading. Rendered as the h2 that names the dialog'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '제목 아래 한 줄이자 다이얼로그의 접근성 설명',
        en: "A line under the title, and the dialog's accessible description"
      }
    },
    {
      name: 'actions',
      type: 'ReactNode',
      description: {
        ko: '아래쪽 버튼 줄. 끝 정렬됩니다. DialogClose가 그중 하나를 닫기 버튼으로 만듭니다',
        en: 'The bottom row, end-aligned. DialogClose is what makes one of them dismiss'
      }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '구역 사이를 여백 대신 하이라인으로 나눕니다. 본문이 스크롤되는 순간부터 켜는 편이 좋습니다',
        en: 'Separates the sections with hairlines instead of space. Worth turning on the moment the body scrolls'
      }
    },
    {
      name: 'showClose',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '모서리의 ×. 라이브러리의 다른 불리언과 달리 기본이 켜짐입니다 — 모달은 답할 때까지 페이지를 가져가므로 나가는 길이 보여야 합니다',
        en: 'The × in the corner. On by default, unlike most booleans here: a modal takes the page away, and the way out should be visible'
      }
    },
    {
      name: 'closeLabel',
      type: 'string',
      default: "'Close'",
      description: { ko: '× 버튼의 접근성 이름', en: 'Accessible name of the × button' }
    },
    {
      name: 'width',
      type: 'number | string',
      description: {
        ko: 'size가 정한 최대 너비를 대신할 값. 숫자는 픽셀입니다',
        en: 'A hard cap overriding the one size implies. Numbers are pixels'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'size가 허용하는 너비를 가득 채웁니다. 다른 컴포넌트와 반대로 기본이 켜짐입니다 — 다이얼로그의 컨테이너는 뷰포트입니다',
        en: 'Takes the full width its size allows. On by default, the other way round from everywhere else: a dialog’s container is the viewport'
      }
    },
    {
      name: 'fullScreen',
      type: 'boolean',
      default: 'false',
      description: { ko: '뷰포트를 가장자리까지 채웁니다', en: 'Fills the viewport edge to edge' }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'true',
      description: {
        ko: '뒤 페이지를 가져갈지. trap-focus는 스크롤과 클릭은 남기고 포커스만 가둡니다',
        en: "Whether the page behind is taken away. 'trap-focus' keeps it scrollable and clickable while holding focus inside"
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'true',
      description: {
        ko: 'Esc와 바깥 클릭으로 닫히는지. 끄려면 답할 수 있는 actions를 반드시 함께 주세요',
        en: 'Whether Escape and an outside click close it. Turn it off only with actions that answer it'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '본문. 스크롤되는 유일한 구역입니다',
        en: 'The body — the only part that scrolls'
      }
    }
  ],

  ToastProvider: [
    {
      name: 'variant',
      type: VARIANT,
      default: "'outline'",
      shared: true,
      description: {
        ko: '표면의 무게. 토스트 하나가 따로 덮어쓸 수 있습니다',
        en: 'Weight of the surface. A single toast can override it'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '타입 스케일과 여백', en: 'Type scale and padding' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: { ko: '기본 색 계열', en: 'The default colour family' }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'position',
      type: '`top-${Align}` | `bottom-${Align}`',
      default: "'bottom-end'",
      description: {
        ko: '스택이 놓이는 자리. 위·아래 두 값과 공용 Align의 조합입니다 — 화면 한복판을 세로로 가르는 스택은 만들 수 없습니다',
        en: 'Where the stack is pinned: top or bottom, times the shared Align. There is deliberately no way to ask for a column down the middle'
      }
    },
    {
      name: 'timeout',
      type: 'number',
      default: '5000',
      description: {
        ko: '기본 유지 시간(ms). 0이면 닫을 때까지 남습니다',
        en: 'How long a toast lasts by default, in ms. 0 keeps it up until it is closed'
      }
    },
    {
      name: 'limit',
      type: 'number',
      default: '3',
      description: {
        ko: '동시에 보이는 개수. 넘친 것은 버려지지 않고 스택이 빠지면 나타납니다',
        en: 'How many are shown at once. The rest are kept and revealed as the stack drains'
      }
    },
    {
      name: 'width',
      type: 'number | string',
      default: '380',
      description: { ko: '토스트 하나의 최대 너비', en: 'How wide a toast is allowed to get' }
    },
    {
      name: 'closeLabel',
      type: 'string',
      default: "'Close'",
      description: { ko: '× 버튼의 접근성 이름', en: "Accessible name of every toast's × button" }
    }
  ],

  'useToast().add': [
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '제목', en: 'The headline' }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: {
        ko: '아래 설명. 이것만 있으면 한 줄짜리 토스트입니다',
        en: 'The detail under it. A toast with only this is a one-line toast'
      }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '이 토스트만 다른 색 계열로',
        en: 'Overrides the provider for this toast alone'
      }
    },
    {
      name: 'variant',
      type: VARIANT,
      shared: true,
      description: {
        ko: '이 토스트만 다른 표면으로',
        en: 'Overrides the provider for this toast alone'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode | false',
      description: {
        ko: '앞머리 글리프. 기본값은 color에 딸린 그림',
        en: 'The glyph. Defaults to the one that goes with `color`'
      }
    },
    {
      name: 'timeout',
      type: 'number',
      description: {
        ko: '이 토스트의 유지 시간(ms). 0은 읽고 나서 조치가 필요한 메시지에 씁니다',
        en: 'How long this one lasts, in ms. 0 is the right answer for anything the reader has to act on'
      }
    },
    {
      name: 'priority',
      type: "'low' | 'high'",
      default: "'low'",
      description: {
        ko: 'high는 스크린 리더의 말을 끊습니다. 오류는 그럴 만하고 저장 완료는 아닙니다',
        en: 'high interrupts a screen reader. An error is worth interrupting for and a save is not'
      }
    },
    {
      name: 'actionLabel',
      type: 'ReactNode',
      description: {
        ko: '액션 버튼의 라벨. 넘기면 버튼이 생깁니다',
        en: 'The label of the action button. Passing it is what makes it appear'
      }
    },
    {
      name: 'onAction',
      type: '(event) => void',
      description: { ko: '액션 버튼을 눌렀을 때', en: 'Called when the action is pressed' }
    },
    {
      name: 'id',
      type: 'string',
      description: {
        ko: '같은 id로 다시 부르면 그 토스트를 제자리에서 갱신하고 타이머를 다시 시작합니다',
        en: 'Reusing an id updates that toast in place and restarts its timer'
      }
    },
    {
      name: 'onClose',
      type: '() => void',
      description: {
        ko: '어떤 방식으로든 닫혔을 때',
        en: 'Called when it closes, however it closed'
      }
    },
    {
      name: 'onRemove',
      type: '() => void',
      description: {
        ko: '애니메이션이 끝나고 DOM에서 빠졌을 때',
        en: 'Called once it has left the DOM'
      }
    }
  ],

  Tooltip: [
    {
      name: 'content',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '툴팁이 하는 말. 짧은 구절이어야 합니다 — 툴팁은 터치로 닿을 수 없고 안의 무엇도 누를 수 없습니다',
        en: 'What it says. A short phrase: a tooltip cannot be reached by touch and nothing inside it can be clicked'
      }
    },
    {
      name: 'children',
      type: 'ReactElement',
      required: true,
      description: {
        ko: '툴팁이 매달릴 요소 하나. 트리거가 감싸지 않고 이 요소에 병합되므로 레이아웃에 요소가 늘지 않습니다',
        en: 'The single element it hangs off. The trigger merges onto it rather than wrapping it, so the layout gains no element'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'sm'",
      shared: true,
      description: { ko: '판의 타입 스케일과 여백', en: "The plate's type scale and padding" }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'secondary'",
      shared: true,
      description: {
        ko: '색 계열. 툴팁은 언제나 다른 것에 대한 주석이므로 중립이 기본입니다',
        en: 'Colour family. A tooltip is always a note about something else, so the neutral family is the honest default'
      }
    },
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '여백만 바꿉니다', en: 'Padding only' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'top'",
      description: {
        ko: '트리거의 어느 쪽에 뜨는지. 자리가 없으면 반대쪽으로 넘어갑니다',
        en: 'Which edge of the trigger it appears on. Flips to the opposite side when there is no room'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      description: { ko: '그 변을 따라 놓이는 위치', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: '트리거와의 거리(px)', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'delay',
      type: 'number',
      default: '600',
      description: {
        ko: '열리기까지 포인터가 머물러야 하는 시간(ms)',
        en: 'How long the pointer has to rest before it opens, in ms'
      }
    },
    {
      name: 'closeDelay',
      type: 'number',
      default: '0',
      description: {
        ko: '포인터가 떠난 뒤 닫히기까지(ms)',
        en: 'How long it waits before closing, in ms'
      }
    },
    {
      name: 'arrow',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '트리거를 가리키는 작은 쐐기',
        en: 'The little wedge pointing at the trigger'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. onOpenChange와 함께',
        en: 'Whether it is open. With onOpenChange'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '비제어 툴팁의 초기 상태',
        en: 'The initial state of an uncontrolled tooltip'
      }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때 호출', en: 'Called when it opens or closes' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '트리거는 그대로 두고 툴팁만 열리지 않게 합니다 — 라벨이 잘렸을 때만 뜨는 툴팁 같은 경우',
        en: 'Stops it opening without disabling the trigger — for the tooltip that only exists while a label is truncated'
      }
    }
  ],

  ProgressLinear: progressProps({
    ko: '홈의 두께. 막대에서 크기를 가지는 것은 이것뿐입니다',
    en: 'Thickness of the groove. Nothing else on a bar has a size'
  }),

  ProgressCircular: progressProps({
    ko: '고리의 지름. 매 단계에서 컨트롤 사다리 바로 아래에 놓이므로, 버튼이나 필드 안에 넣어도 행이 높아지지 않습니다',
    en: 'Diameter of the ring. It lands just under the control ladder at every step, so dropping one into a button or a field never makes the row taller'
  }),

  ProgressBox: [
    ...progressProps({
      ko: '판 하나의 크기',
      en: 'The size of one plate'
    }),
    {
      name: 'count',
      type: 'number',
      default: '4',
      description: {
        ko: '판의 개수. 넷이면 파도가 파도로 읽히면서도 한눈에 셀 수 있습니다. 기다리는 대상에 실제로 단계가 있다면 그 수를 넣으세요',
        en: 'How many plates. Four reads as a wave and can still be counted at a glance. Set it to the number of steps when the thing being waited on genuinely has steps'
      }
    }
  ],

  List: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. 담는 쪽이므로 시트는 물들지 않습니다. Card 안에서는 text를 쓰세요 — 카드가 이미 시트입니다',
        en: 'Weight of the surface. The sheet is never dyed, as on Box. Reach for text inside a Card — the card is already a sheet'
      },
      sizeDescription: {
        ko: '행의 타입 스케일과 여백. 항목이 아니라 목록이 가지는 축입니다',
        en: "The rows' type scale and padding. An axis of the list, not of any one row"
      }
    }),
    {
      name: 'dividers',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '행 사이를 여백 대신 하이라인으로 나눕니다. 들리는 것보다 많이 바뀝니다 — 선이 시트 양끝까지 닿아야 하므로 목록은 안쪽 여백을, 행은 둥근 모서리를 내놓습니다',
        en: 'Separates the rows with a hairline instead of space. It changes more than it sounds like: the rules have to reach both edges, so the list gives up its inner padding and the rows give up their corners'
      }
    },
    {
      name: 'render',
      type: 'useRender.RenderProp',
      description: {
        ko: 'ul 대신 다른 것으로 — 순서가 의미를 가지면 render={<ol />}',
        en: 'Renders something other than a ul — render={<ol />} when the order is the point'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'ListItem들', en: 'The ListItems' }
    }
  ],

  ListItem: [
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 앞 내용 — 아이콘, 아바타, 상태 점',
        en: 'Content before the label — an icon, an avatar, a status dot'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤 내용. 누를 수 있는 영역 안에 있습니다',
        en: 'Content after the label, inside the pressable area'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 둘째 줄', en: 'A second line under the label' }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '행 끝에 고정되는 컨트롤 — 스위치, 메뉴 버튼. 일부러 누를 수 있는 영역 바깥입니다: 버튼 안의 버튼은 브라우저가 파싱하면서 고쳐 쓰는 마크업입니다',
        en: 'A control pinned to the end of the row. Deliberately outside the pressable area — a button inside a button is markup the browser rewrites on parse'
      }
    },
    {
      name: 'onClick',
      type: '(event) => void',
      description: {
        ko: '넘기면 행이 진짜 button이 됩니다',
        en: 'Passing it is what turns the row into a real button'
      }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '넘기면 행이 진짜 a가 됩니다',
        en: 'Passing it is what turns the row into a real link'
      }
    },
    {
      name: 'selected',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '고른 행 — 열려 있는 페이지, 켜진 필터. 링크에는 aria-current="page"가, 버튼에는 aria-current="true"가 붙습니다',
        en: 'The chosen row — the open page, the current filter. A link gets aria-current="page" and a button aria-current="true"'
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
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '라벨', en: 'The label' }
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
  ],

  Badge: [
    ...sharedProps({
      variant: "'solid'",
      size: "'md'",
      sizeDescription: {
        ko: '표식의 크기. 컨트롤 사다리와 별개입니다 — 배지는 무언가의 모서리에 걸리는 것이라 줄을 맞출 상대가 없습니다',
        en: 'The size of the mark, on a ladder of its own: a badge hangs off a corner, so it lines up with nothing'
      },
      densityDescription: {
        ko: '숫자 좌우의 여백만 바꿉니다',
        en: 'The room around the digits, and nothing else'
      }
    }),
    {
      name: 'content',
      type: 'ReactNode',
      description: {
        ko: '표식이 말하는 것. 보통 숫자, 가끔 단어. 없으면 점이 됩니다',
        en: 'What the badge says — usually a count. Omit it and the badge draws a dot'
      }
    },
    {
      name: 'max',
      type: 'number',
      default: '99',
      description: {
        ko: '숫자 content의 상한. 넘으면 99+가 됩니다. 단어는 자르지 않습니다',
        en: 'Caps a numeric content and adds a plus. Text is never truncated'
      }
    },
    {
      name: 'dot',
      type: 'boolean',
      default: 'false',
      description: {
        ko: 'content가 있어도 점으로 그립니다. 숫자는 스크린 리더에만 남습니다',
        en: 'Draws a dot even with content, keeping the count for screen readers only'
      }
    },
    {
      name: 'showZero',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '0도 보여 줍니다. 기본이 꺼짐인 이유는 읽지 않은 메시지 0개는 소식이 아니기 때문입니다',
        en: 'Shows a count of zero. Off by default — zero unread messages is not news'
      }
    },
    {
      name: 'invisible',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '자리는 지킨 채 숨깁니다. 다시 나타나도 주변이 움직이지 않습니다',
        en: 'Hides the marker without giving up its box, so nothing moves when it returns'
      }
    },
    {
      name: 'placement',
      type: "'top-start' | 'top-end' | 'bottom-start' | 'bottom-end'",
      default: "'top-end'",
      shared: true,
      description: {
        ko: '어느 모서리에 붙을지. start/end라서 쓰기 방향을 따라 뒤집힙니다',
        en: 'Which corner it sits on. start/end, so the corner flips with the writing direction'
      }
    },
    {
      name: 'overlap',
      type: "'square' | 'circle'",
      default: "'square'",
      description: {
        ko: '아래에 있는 것의 모양. 원의 모서리는 사각형보다 중심에서 멀기 때문에 파고드는 깊이가 다릅니다',
        en: "The shape underneath, which decides how far the mark tucks in — a circle's corner is further out than a square's"
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '스크린 리더가 숫자 대신 읽을 문장. 종 옆의 "3"은 아무 뜻도 없습니다',
        en: 'What a screen reader hears instead of the raw count — "3" beside a bell means nothing'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '표식이 붙을 대상. 없으면 인라인으로 놓이는 독립 표식이 됩니다',
        en: 'What the badge is pinned to. Without it, the badge is a standalone marker that lays out inline'
      }
    }
  ],

  Menu: [
    {
      name: 'trigger',
      type: 'ReactElement',
      description: {
        ko: '메뉴를 여는 요소. Base UI가 연결해 줍니다. 다른 곳에서 여는 controlled 메뉴에는 필요 없습니다',
        en: 'The element that opens the menu, wired up by Base UI. Not needed for a controlled menu opened elsewhere'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '열림 여부. controlled 메뉴',
        en: 'Whether it is open, for a controlled menu'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음부터 열려 있음', en: 'Whether it starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when it opens or closes' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'bottom'",
      shared: true,
      description: {
        ko: '트리거의 어느 변에 걸릴지. 자리가 없으면 반대편으로 뒤집힙니다',
        en: 'Which edge of the trigger it hangs off. Flips when there is no room'
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'start'",
      shared: true,
      description: { ko: '그 변 위에서의 위치', en: 'Where it sits along that edge' }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '6',
      description: { ko: '트리거와의 거리(px)', en: 'Distance from the trigger, in pixels' }
    },
    {
      name: 'modal',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '열려 있는 동안 뒤 페이지를 가져갈지',
        en: 'Whether the page behind is taken away while it is open'
      }
    },
    {
      name: 'openOnHover',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '호버로도 열립니다. 메뉴바처럼 열린 채로 옆 메뉴로 건너가야 할 때',
        en: 'Opens on hover too. For a menu bar, where crossing the row should walk through the others'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마지막 항목에서 화살표를 누르면 처음으로 돌아갈지',
        en: 'Whether the arrow keys wrap from the last row back to the first'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 트리거가 아무것도 열지 않습니다',
        en: 'Unavailable. The trigger stops opening anything'
      }
    },
    ...scaleProps("'md'"),
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: {
        ko: '행의 여백만 바꿉니다. 메뉴는 자기 팝업 폭을 스스로 정하므로 Box보다 좁은 사다리를 씁니다',
        en: 'The rows’ padding only. A menu is as wide as its longest label, so it runs a tighter ladder than Box'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '행들. MenuItem, MenuGroup, MenuSeparator, MenuSubmenu 등',
        en: 'The rows — MenuItem, MenuGroup, MenuSeparator, MenuSubmenu and the rest'
      }
    }
  ],

  MenuItem: [
    {
      name: 'onClick',
      type: '(event) => void',
      description: { ko: '행이 하는 일', en: 'What the row does' }
    },
    {
      name: 'href',
      type: 'string',
      description: {
        ko: '넘기면 진짜 a가 됩니다. 링크로 이뤄진 메뉴는 링크여야 새 탭으로 열 수 있습니다',
        en: 'Passing it renders a real anchor. A menu of links has to be links, or none of them opens in a new tab'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 내용', en: 'Content before the label' }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤, shortcut 앞의 내용',
        en: 'Content after the label, before any shortcut'
      }
    },
    {
      name: 'shortcut',
      type: 'ReactNode',
      description: {
        ko: '같은 일을 하는 단축키. 행 끝에 흐리게 놓입니다 — 표시만 하고 바인딩하지는 않습니다',
        en: 'The keystroke that does the same thing, set muted at the end. Shown, never bound'
      }
    },
    {
      name: 'description',
      type: 'ReactNode',
      description: { ko: '라벨 아래 한 줄', en: 'A second line under the label' }
    },
    {
      name: 'color',
      type: COLOR,
      shared: true,
      description: {
        ko: '이 행만 다른 색 계열로. 지우는 행에 danger. 기본값은 메뉴의 색입니다',
        en: "Re-points this row's colour family — danger for the one that deletes. Defaults to the menu's own"
      }
    },
    {
      name: 'closeOnClick',
      type: 'boolean',
      default: 'true',
      description: { ko: '고르면 메뉴가 닫힐지', en: 'Whether picking the row closes the menu' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 목록에는 남고 타이핑 검색에도 걸립니다',
        en: 'Unavailable. Still listed, and still found by typeahead'
      }
    },
    {
      name: 'label',
      type: 'string',
      description: {
        ko: '타이핑 검색이 맞춰 볼 문자열. 라벨이 평범한 문자열이 아닐 때',
        en: 'What typeahead matches against, when the label is not a plain string'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '라벨', en: 'The label' }
    }
  ],

  MenuSubmenu: [
    {
      name: 'label',
      type: 'ReactNode',
      description: { ko: '서브메뉴를 여는 행의 라벨', en: 'The label on the row that opens it' }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 내용', en: 'Content before the label' }
    },
    {
      name: 'side',
      type: "'top' | 'right' | 'bottom' | 'left'",
      default: "'right'",
      shared: true,
      description: {
        ko: '부모 행의 어느 쪽으로 열릴지',
        en: 'Which edge of the parent row it opens against'
      }
    },
    {
      name: 'sideOffset',
      type: 'number',
      default: '4',
      description: { ko: '부모 메뉴와의 거리(px)', en: 'Distance from the parent menu, in pixels' }
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
      description: {
        ko: '중첩된 행들. 그 안에 또 MenuSubmenu를 넣을 수 있고, 깊이 제한은 없습니다',
        en: 'The nested rows — one of which may be another MenuSubmenu, to any depth'
      }
    }
  ],

  ContextMenu: [
    {
      name: 'content',
      type: 'ReactNode',
      description: {
        ko: '행들. Menu 안에 쓰는 것과 똑같이 씁니다',
        en: 'The rows, written exactly as they are inside a Menu'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      required: true,
      description: {
        ko: '오른쪽 클릭이나 길게 누르기에 반응할 영역',
        en: 'The area that answers a right-click or a long press'
      }
    },
    {
      name: 'open',
      type: 'boolean',
      description: { ko: '열림 여부', en: 'Whether it is open' }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음부터 열려 있음', en: 'Whether it starts open' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when it opens or closes' }
    },
    ...scaleProps("'md'"),
    {
      name: 'density',
      type: DENSITY,
      default: "'default'",
      shared: true,
      description: { ko: '행의 여백만 바꿉니다', en: 'The rows’ padding only' }
    }
  ],

  Accordion: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      sizeDescription: {
        ko: '시트의 반경과 각 섹션의 여백. Box와 같은 뜻입니다',
        en: "The sheet's radius and each section's padding — the same thing size means on Box"
      }
    }),
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '여러 섹션을 동시에 열 수 있는지. 기본이 꺼짐인 이유는 하나를 열 때 하나를 닫는 것이 아코디언이 접이식 목록과 다른 점 전부이기 때문입니다',
        en: 'Whether more than one section may be open. Off by default: closing the last as you open the next is the whole difference between an accordion and a stack of collapsibles'
      }
    },
    {
      name: 'value',
      type: '(string | number)[]',
      description: {
        ko: '열려 있는 섹션들. controlled',
        en: 'Which sections are open, for a controlled accordion'
      }
    },
    {
      name: 'defaultValue',
      type: '(string | number)[]',
      description: { ko: '처음 열려 있는 섹션들', en: 'Which start open' }
    },
    {
      name: 'onValueChange',
      type: '(value: (string | number)[]) => void',
      description: { ko: '열린 집합이 바뀔 때', en: 'Called when the open set changes' }
    },
    {
      name: 'dividers',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '섹션 사이를 여백 대신 실선으로 나눕니다. List와 기본값이 반대인 이유는 접히는 카드 더미가 아니라 한 덩어리로 읽혀야 하기 때문입니다',
        en: 'Separates the sections with a hairline rather than space. The opposite default from List: an accordion of tiles is a stack of cards, not one thing'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 모든 섹션이 접히지 않습니다',
        en: 'Unavailable. Every section stops answering'
      }
    },
    {
      name: 'hiddenUntilFound',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남겨 브라우저의 페이지 검색이 찾아 펼칠 수 있게 합니다. keepMounted보다 우선합니다',
        en: "Keeps closed panels in the DOM so the browser's own page search can find and open them. Overrides keepMounted"
      }
    },
    {
      name: 'keepMounted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '닫힌 패널을 DOM에 남깁니다. 만들기 비싼 내용이나 접혀도 살아 있어야 하는 폼 상태',
        en: 'Keeps closed panels in the DOM. For content that is expensive to build, or form state that should survive being folded away'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: 'AccordionItem들', en: 'The AccordionItems' }
    }
  ],

  AccordionItem: [
    {
      name: 'value',
      type: 'string | number',
      description: {
        ko: 'value / defaultValue가 가리키는 식별자. 생략하면 Base UI가 만들어 줍니다',
        en: 'Identifies the section to value / defaultValue. Base UI generates one when it is left out'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '접히는 부분의 제목', en: 'The heading on the fold' }
    },
    {
      name: 'subtitle',
      type: 'ReactNode',
      description: { ko: '제목 아래 한 줄', en: 'A second line under the title' }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '제목 앞의 내용', en: 'Content before the title' }
    },
    {
      name: 'action',
      type: 'ReactNode',
      description: {
        ko: '헤더 끝에 고정되는 컨트롤. 접는 버튼 바깥에 놓입니다 — 버튼 안의 버튼은 브라우저가 고쳐 씁니다',
        en: 'A control pinned to the end of the header, outside the folding button — a button inside a button is markup the browser rewrites'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '이 섹션만 접히지 않습니다. 나머지는 그대로 동작합니다',
        en: 'This section stops folding; the rest keep working'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '펼쳤을 때의 내용', en: 'The body' }
    }
  ],

  Tabs: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '패널이 아니라 탭 **바**의 무게. solid는 분절 컨트롤(홈통 안의 타일), outline은 바 가장자리의 선, text는 그 선을 뺀 것',
        en: 'Weight of the tab **bar**, not of the panels. solid is a segmented control, outline is a rule along the bar, text is the same without it'
      },
      sizeDescription: {
        ko: '탭의 높이와 타입 스케일. Button과 같은 사다리라 툴바에 섞어 놓아도 기준선이 맞습니다',
        en: "The tabs' height and type scale, on Button's own ladder — so a tab bar keeps its baseline in a toolbar"
      }
    }).filter((row) => row.name !== 'elevation'),
    {
      name: 'value',
      type: 'string | number | null',
      description: { ko: '선택된 탭. controlled', en: 'The chosen tab, for a controlled set' }
    },
    {
      name: 'defaultValue',
      type: 'string | number | null',
      description: { ko: '처음 선택된 탭', en: 'Which starts chosen' }
    },
    {
      name: 'onValueChange',
      type: '(value: string | number | null) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen tab changes' }
    },
    {
      name: 'orientation',
      type: ORIENTATION,
      default: "'horizontal'",
      shared: true,
      description: {
        ko: '바가 흐르는 방향. vertical이면 탭이 옆으로 서고 화살표 키도 그 축으로 옮겨 갑니다',
        en: 'Which way the bar runs. vertical stands the tabs down the side and moves the arrow keys onto the other axis'
      }
    },
    {
      name: 'activateOnFocus',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '화살표로 지나가기만 해도 선택할지. 기본이 꺼짐인 이유는 패널 하나가 데이터를 받아 온다면 탭 넷을 지나가는 것이 요청 네 번이기 때문입니다',
        en: 'Whether the arrow keys also choose. Off by default: the moment one panel fetches, walking past four tabs fires four requests'
      }
    },
    {
      name: 'loopFocus',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '마지막 탭에서 화살표를 누르면 처음으로 돌아갈지',
        en: 'Whether the arrow keys wrap from the last tab back to the first'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '탭들이 바의 폭을 똑같이 나눠 갖습니다',
        en: 'The tabs share the full width of the bar, each taking an equal part'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: 'Tab과 TabPanel. 둘은 알아서 나뉘어 각자의 자리에 놓이므로 감싸는 래퍼를 쓸 필요가 없습니다',
        en: 'The Tabs and the TabPanels. They are sorted into their two boxes for you, so there is no list wrapper to remember'
      }
    }
  ],

  Tab: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: {
        ko: '탭의 식별자. 같은 값을 가진 TabPanel을 가리킵니다',
        en: 'Identifies the tab, and picks out the panel with the same value'
      }
    },
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '라벨 앞의 내용', en: 'Content before the label' }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '라벨 뒤의 내용 — 개수, Badge, 상태 점',
        en: 'Content after the label — a count, a Badge, a status dot'
      }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: { ko: '사용 불가. 목록에는 남습니다', en: 'Unavailable, but still listed' }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '탭의 라벨', en: "The tab's label" }
    }
  ],

  TabPanel: [
    {
      name: 'value',
      type: 'string | number',
      required: true,
      description: { ko: '어느 탭이 이 패널을 보여 줄지', en: 'Which tab shows this panel' }
    },
    {
      name: 'keepMounted',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '숨겨진 동안에도 DOM에 남깁니다. 만들기 비싼 내용이나 살아 있어야 하는 폼 상태',
        en: 'Keeps the panel in the DOM while hidden. For content that is expensive to build, or form state that should survive'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: { ko: '패널의 내용', en: 'The content' }
    }
  ],

  FilePicker: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. 셋 다 점선 테두리는 공유합니다 — 라이브러리에서 실선이 아닌 선을 긋는 유일한 곳이고, 장식이 아니라 "여기에 놓을 수 있다"는 관례이기 때문입니다',
        en: 'Weight of the surface. All three share the dashed edge — the one place the library draws a line that is not solid, because a dashed rectangle is the established sign for a drop target'
      },
      sizeDescription: {
        ko: '상자의 여백과 글자 크기. 상자는 안에 쓰인 글이 아니라 받아 내야 할 제스처에 맞춰 커집니다',
        en: "The box's padding and type scale. A dropzone is sized by the gesture it has to catch, not by what is written in it"
      }
    }),
    {
      name: 'accept',
      type: 'string',
      description: {
        ko: "브라우저 파일 창이 보여 줄 종류 — 'image/*,.pdf'. 드롭된 파일도 같은 문자열로 검사합니다. 브라우저는 그렇게 하지 않습니다",
        en: "Which files the browser's own picker offers — 'image/*,.pdf'. Dropped files are checked against it too, which the attribute alone does not do"
      }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '파일을 여러 개 고를 수 있는지',
        en: 'Whether more than one file may be chosen'
      }
    },
    {
      name: 'maxSize',
      type: 'number',
      description: {
        ko: '파일 하나의 최대 크기(바이트)',
        en: 'The largest a single file may be, in bytes'
      }
    },
    {
      name: 'maxFiles',
      type: 'number',
      description: {
        ko: '한 번에 들고 있을 수 있는 개수. 한 번의 드롭이 아니라 이미 들고 있는 것과 합쳐서 셉니다',
        en: 'How many files may be held at once — counted against what is already chosen, not against one drop'
      }
    },
    {
      name: 'value',
      type: 'readonly File[]',
      description: {
        ko: '고른 파일들. controlled',
        en: 'The chosen files, for a controlled picker'
      }
    },
    {
      name: 'defaultValue',
      type: 'readonly File[]',
      description: { ko: '처음 고른 파일들', en: 'The initially chosen files' }
    },
    {
      name: 'onFilesChange',
      type: '(files: File[]) => void',
      description: { ko: '파일 목록이 바뀔 때', en: 'Called when the list of files changes' }
    },
    {
      name: 'onReject',
      type: '(rejections: FileRejection[]) => void',
      description: {
        ko: '되돌려 보낸 파일과 그 이유. 없으면 거부된 파일이 조용히 사라지는데, 드롭존이 하는 가장 나쁜 일입니다',
        en: 'Called with everything turned away, and why. Without it a rejected file disappears silently, which is the worst thing a dropzone does'
      }
    },
    {
      name: 'title',
      type: 'ReactNode',
      description: { ko: '상자 안의 문장', en: 'The line inside the box' }
    },
    {
      name: 'hint',
      type: 'ReactNode',
      description: {
        ko: '그 아래 줄 — 무엇을, 얼마나 크게, 몇 개까지',
        en: 'The line under it — what is accepted, how big, how many'
      }
    },
    {
      name: 'icon',
      type: 'ReactNode',
      description: {
        ko: '문장 위의 글리프. null을 주면 그림 없는 상자가 됩니다',
        en: 'The glyph above the title. Pass null for a box with no picture in it'
      }
    },
    {
      name: 'showList',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '고른 파일들을 상자 아래에 나열하고 각각 지울 방법을 붙입니다',
        en: 'Lists the chosen files under the box, each with a way to remove it'
      }
    },
    {
      name: 'removeLabel',
      type: '(name: string) => string',
      description: {
        ko: '파일 삭제 버튼의 접근성 이름',
        en: "Accessible name of a file's remove button"
      }
    },
    ...fieldProps,
    ...inertProps,
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'true',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'required',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '폼 제출 전에 파일이 있어야 하는지',
        en: 'Whether a file must be chosen before the form is submitted'
      }
    },
    {
      name: 'name',
      type: 'string',
      description: {
        ko: '폼 제출 시의 필드 이름',
        en: 'Identifies the field when a form is submitted'
      }
    }
  ],

  Pagination: [
    ...sharedProps({
      variant: "'text'",
      size: "'md'",
      density: "'compact'",
      variantDescription: {
        ko: '쉬고 있는 페이지 버튼의 무게. 현재 페이지는 언제나 solid입니다 — 읽지 않고도 보여야 하는 유일한 정보이고, 기본값이 text인 이유도 그것입니다. 채워진 버튼 아홉 개가 한 줄에 있으면 아홉 개 모두가 주된 액션이라는 뜻이 됩니다',
        en: 'How the pages look at rest. The current page is always solid — the one thing the row has to say without being read, which is also why the default here is text: nine filled buttons in a row say all nine are the primary action'
      },
      sizeDescription: {
        ko: '버튼의 높이와 타입 스케일. 실제로 Button이므로 옆에 놓인 같은 size의 버튼과 줄이 맞습니다',
        en: 'The buttons’ height and type scale. They are real Buttons, so a lg pagination lines up with a lg button beside it'
      }
    }),
    {
      name: 'count',
      type: 'number',
      required: true,
      description: {
        ko: '전체 페이지 수. 둘보다 적으면 아무것도 그리지 않습니다 — 할 일이 없다고 광고하는 컨트롤은 컨트롤이 아닙니다',
        en: 'How many pages there are. Fewer than two and the whole control renders nothing: a row advertising that it has nothing to do is not a control'
      }
    },
    {
      name: 'page',
      type: 'number',
      description: {
        ko: '현재 페이지(1부터). controlled',
        en: 'The current page, 1-based, for a controlled set'
      }
    },
    {
      name: 'defaultPage',
      type: 'number',
      default: '1',
      description: { ko: '처음 페이지', en: 'Which page starts current' }
    },
    {
      name: 'onPageChange',
      type: '(page: number) => void',
      description: { ko: '페이지가 바뀔 때', en: 'Called when the page changes' }
    },
    {
      name: 'siblingCount',
      type: 'number',
      default: '1',
      description: {
        ko: '현재 페이지 양옆에 언제나 보이는 페이지 수',
        en: 'How many pages are always shown on either side of the current one'
      }
    },
    {
      name: 'boundaryCount',
      type: 'number',
      default: '1',
      description: {
        ko: '양 끝에 언제나 보이는 페이지 수. 0이면 첫 페이지와 마지막 페이지가 빠지고 창만 남습니다',
        en: 'How many pages are always shown at each end. 0 drops the first and last page, leaving only the window'
      }
    },
    {
      name: 'showEdges',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '맨 앞 / 맨 뒤로 건너뛰는 버튼',
        en: 'Shows the jump-to-first and jump-to-last steppers'
      }
    },
    {
      name: 'showArrows',
      type: 'boolean',
      default: 'true',
      description: { ko: '이전 / 다음 버튼', en: 'Shows the previous and next steppers' }
    },
    {
      name: 'disabled',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '사용 불가. 줄 전체가 반응하지 않습니다',
        en: 'Unavailable. Every button in the row stops answering'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Pagination'",
      description: { ko: 'nav 랜드마크의 접근성 이름', en: 'Accessible name of the nav landmark' }
    },
    {
      name: 'pageLabel',
      type: '(page: number) => string',
      description: {
        ko: '페이지 버튼의 접근성 이름. 기본값은 `Page ${page}`',
        en: 'Accessible name of a page button. `Page ${page}` by default'
      }
    },
    {
      name: 'previousLabel',
      type: 'string',
      default: "'Previous page'",
      description: { ko: '이전 버튼의 접근성 이름', en: 'Accessible name of the previous stepper' }
    },
    {
      name: 'nextLabel',
      type: 'string',
      default: "'Next page'",
      description: { ko: '다음 버튼의 접근성 이름', en: 'Accessible name of the next stepper' }
    },
    {
      name: 'firstLabel',
      type: 'string',
      default: "'First page'",
      description: {
        ko: '맨 앞 버튼의 접근성 이름',
        en: 'Accessible name of the first-page stepper'
      }
    },
    {
      name: 'lastLabel',
      type: 'string',
      default: "'Last page'",
      description: {
        ko: '맨 뒤 버튼의 접근성 이름',
        en: 'Accessible name of the last-page stepper'
      }
    }
  ],

  Combobox: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. TextField와 같은 셸이므로 폼 안에서 두 컨트롤이 구분되지 않습니다',
        en: 'Weight of the surface. The same shell as a TextField, so the two are indistinguishable in a form'
      },
      sizeDescription: {
        ko: '높이와 타입 스케일. multiple에서는 칩이 줄바꿈하는 만큼 자라므로 최소 높이가 됩니다',
        en: 'Height and type scale. With multiple it becomes a minimum, because the field grows as the chips wrap'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 가장자리·포커스 링·칩에 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the edge, the focus ring and the chips'
      },
      elevationDescription: {
        ko: '필드의 그림자 깊이. 팝업은 자기 그림자를 따로 가집니다',
        en: 'Drop shadow depth of the field. The popup carries its own'
      }
    }),
    {
      name: 'items',
      type: 'readonly ComboboxOption[]',
      required: true,
      description: {
        ko: '옵션 목록. { value, label?, disabled? } 배열이고, label은 ReactNode가 아니라 string입니다',
        en: 'The options, as an array of { value, label?, disabled? } — label is a string, not a ReactNode'
      }
    },
    {
      name: 'multiple',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '값을 여러 개 들 수 있는지. 고른 값은 필드 안의 칩이 됩니다',
        en: 'Whether more than one value may be held. The chosen ones become chips inside the field'
      }
    },
    {
      name: 'value',
      type: 'string | number | (string | number)[] | null',
      description: {
        ko: '선택된 값. multiple이면 배열입니다. onValueChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The chosen value — an array when multiple. Use with onValueChange for a controlled combobox'
      }
    },
    {
      name: 'defaultValue',
      type: 'string | number | (string | number)[] | null',
      description: { ko: '초기 선택 값', en: 'The initial value, for an uncontrolled combobox' }
    },
    {
      name: 'onValueChange',
      type: '(value) => void',
      description: { ko: '선택이 바뀔 때', en: 'Called when the chosen value changes' }
    },
    {
      name: 'onInputValueChange',
      type: '(inputValue: string) => void',
      description: {
        ko: '입력란의 글자가 바뀔 때. 값이 아니라 필터 질의입니다',
        en: 'Called as the text in the input changes — the filter query, not the value'
      }
    },
    {
      name: 'allowCustom',
      type: 'boolean',
      default: 'true',
      description: {
        ko: '목록에 없는 값을 확정할 수 있는지. 입력한 글자가 목록 맨 끝에 자기 행으로 제안됩니다 — 검색되는 select와 combobox를 가르는 지점입니다',
        en: 'Whether a value the list does not contain may be committed. The typed text is offered as its own row at the end of the list — what separates this from a searchable select'
      }
    },
    {
      name: 'customLabel',
      type: '(query: string) => ReactNode',
      default: 'Add “…”',
      description: { ko: '그 행이 하는 말', en: 'What that row says' }
    },
    {
      name: 'clearable',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '필드를 비우는 ×. 한 번에 비워지는 필드는 실수로도 비워지는 필드입니다',
        en: 'Shows a × that empties the field. A field that can be cleared in one click can be emptied by accident'
      }
    },
    {
      name: 'emptyMessage',
      type: 'ReactNode',
      default: "'No matches'",
      description: {
        ko: '일치하는 것이 없고 값을 추가할 수도 없을 때 팝업이 하는 말',
        en: 'Shown in the popup when nothing matches and no value may be added'
      }
    },
    {
      name: 'limit',
      type: 'number',
      default: '-1',
      description: {
        ko: '한 번에 보여 줄 최대 행 수. -1은 전부',
        en: 'The most rows the list will show at once. -1 is all of them'
      }
    },
    {
      name: 'placeholder',
      type: 'string',
      description: {
        ko: '아무것도 입력하지 않았을 때 보이는 내용',
        en: 'Shown in the input while nothing is typed'
      }
    },
    ...fieldProps,
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: { ko: '입력란 앞에 놓이는 내용', en: 'Content before the input' }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'removeLabel',
      type: '(label: string) => string',
      default: 'Remove …',
      description: {
        ko: '칩 제거 버튼의 접근성 이름. 칩의 라벨을 받습니다',
        en: "Accessible name of a chip's remove button. Receives the chip's label"
      }
    },
    {
      name: 'clearLabel',
      type: 'string',
      default: "'Clear'",
      description: { ko: '× 버튼의 접근성 이름', en: 'Accessible name of the clear button' }
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

  NumberField: [
    ...sharedProps({
      variant: "'outline'",
      size: "'md'",
      variantDescription: {
        ko: '표면의 무게. TextField와 같은 셸입니다',
        en: "Weight of the surface. A TextField's shell, to the pixel"
      },
      sizeDescription: {
        ko: '높이와 타입 스케일. 스테퍼는 em이므로 숫자를 따라갑니다',
        en: 'Height and type scale. The steppers are sized in em, so they track the number'
      },
      colorDescription: {
        ko: '의미론적 색 역할. 표면은 흰색이므로 가장자리·포커스 링·캐럿·스테퍼의 호버에 나타납니다',
        en: 'Semantic colour role. The surface is white, so it reaches the edge, the ring, the caret and the steppers on hover'
      }
    }),
    {
      name: 'value',
      type: 'number | null',
      description: {
        ko: '값. null이 비어 있음입니다 — 파싱해야 하는 문자열이 아닙니다',
        en: 'The number. null means empty — never a string you have to parse'
      }
    },
    {
      name: 'defaultValue',
      type: 'number',
      description: { ko: '초기 값', en: 'The initial number, for an uncontrolled field' }
    },
    {
      name: 'onValueChange',
      type: '(value: number | null) => void',
      description: {
        ko: '값이 바뀔 때마다 — 타이핑, 스테핑, 휠',
        en: 'Called on every change — typing, stepping, the wheel'
      }
    },
    {
      name: 'onValueCommitted',
      type: '(value: number | null) => void',
      description: {
        ko: '값이 자리를 잡을 때. 타이핑 후 blur, 누르기를 뗄 때',
        en: 'Called when the value settles: on blur after typing, on pointer release after a press'
      }
    },
    {
      name: 'min',
      type: 'number',
      description: { ko: '범위의 시작. 스테핑은 여기서 멈춥니다', en: 'The bottom of the range' }
    },
    {
      name: 'max',
      type: 'number',
      description: { ko: '범위의 끝', en: 'The top of the range' }
    },
    {
      name: 'step',
      type: "number | 'any'",
      default: '1',
      description: {
        ko: '한 걸음의 크기. any는 step 검증을 끕니다',
        en: "How far one step goes. 'any' turns step validation off"
      }
    },
    {
      name: 'largeStep',
      type: 'number',
      default: '10',
      description: { ko: 'Shift를 누른 채의 한 걸음', en: 'The step taken while Shift is held' }
    },
    {
      name: 'smallStep',
      type: 'number',
      default: '0.1',
      description: { ko: 'Alt를 누른 채의 한 걸음', en: 'The step taken while Alt is held' }
    },
    {
      name: 'snapOnStep',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '스테핑이 step의 배수에 붙는지',
        en: 'Whether stepping snaps to multiples of the step'
      }
    },
    {
      name: 'allowWheelScrub',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '포커스된 채 호버 중일 때 휠이 값을 바꾸는지. 포인터 아래에서 스크롤되는 페이지와 바뀌는 필드는 같은 제스처이고, 의도된 것은 하나뿐입니다',
        en: 'Whether the wheel changes the value while focused and hovered. A page that scrolls under the pointer and a field that changes under it are the same gesture, and only one was meant'
      }
    },
    {
      name: 'format',
      type: 'Intl.NumberFormatOptions',
      description: {
        ko: '숫자를 어떻게 쓸지 — 통화, 백분율, 소수 자릿수. 필드는 $1,240을 보여 주고 값으로는 1240을 보고합니다',
        en: 'How the number is written — currency, percent, decimal places. The field shows $1,240 and still reports 1240'
      }
    },
    {
      name: 'locale',
      type: 'Intl.LocalesArgument',
      description: {
        ko: '어느 로케일로 쓰고 읽을지. 기본은 런타임의 것',
        en: "Which locale the number is written and parsed in. Defaults to the runtime's"
      }
    },
    {
      name: 'steppers',
      type: "'end' | 'split' | 'none'",
      default: "'end'",
      description: {
        ko: '스테퍼가 앉는 자리. split은 숫자 양옆, none은 버튼 없음',
        en: 'Where the steppers sit. split puts them on either side of the number; none drops them'
      }
    },
    ...fieldProps,
    {
      name: 'startIcon',
      type: 'ReactNode',
      description: {
        ko: '숫자 앞에 놓이는 내용 — 통화 기호, 단위',
        en: 'Content before the number — a currency mark, a unit'
      }
    },
    {
      name: 'endIcon',
      type: 'ReactNode',
      description: {
        ko: '숫자 뒤, 스테퍼 앞에 놓이는 내용',
        en: 'Content after the number, before the steppers'
      }
    },
    {
      name: 'fullWidth',
      type: 'boolean',
      default: 'false',
      description: { ko: '컨테이너 너비만큼 확장', en: 'Stretches to the width of the container' }
    },
    {
      name: 'incrementLabel',
      type: 'string',
      default: "'Increase'",
      description: { ko: '증가 버튼의 접근성 이름', en: 'Accessible name of the increment button' }
    },
    {
      name: 'decrementLabel',
      type: 'string',
      default: "'Decrease'",
      description: { ko: '감소 버튼의 접근성 이름', en: 'Accessible name of the decrement button' }
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

  Overlay: [
    {
      name: 'open',
      type: 'boolean',
      description: {
        ko: '오버레이가 보입니다. onOpenChange와 함께 제어 컴포넌트로 씁니다',
        en: 'The overlay is shown. Use with onOpenChange for a controlled overlay'
      }
    },
    {
      name: 'defaultOpen',
      type: 'boolean',
      default: 'false',
      description: { ko: '처음부터 보일지', en: 'Whether the overlay starts shown' }
    },
    {
      name: 'onOpenChange',
      type: '(open: boolean) => void',
      description: { ko: '열리거나 닫힐 때', en: 'Called when the overlay opens or closes' }
    },
    {
      name: 'tone',
      type: "'scrim' | 'blur' | 'solid' | 'clear'",
      default: "'scrim'",
      description: {
        ko: '뒤 페이지를 얼마나 가져가는지. 하나의 축 위의 네 단계이고, 알파만큼이나 블러 반경으로 조율되어 있습니다',
        en: 'How much of the page is taken away. Four steps on one axis, tuned with the blur radius as much as with the alpha'
      }
    },
    {
      name: 'dismissible',
      type: 'boolean',
      default: 'false',
      description: {
        ko: '클릭이나 Escape로 닫히는지. Dialog와 반대로 꺼져 있습니다 — 오버레이는 묻지 않고 기다리라고 말하며, 빗나간 클릭으로 사라지는 저장은 끝났다고 믿게 되는 저장입니다',
        en: 'Whether a click or Escape closes it. Off, the other way round from Dialog: an overlay is not asking anything, and a save dismissed by a stray click is a save the user will believe finished'
      }
    },
    {
      name: 'modal',
      type: "boolean | 'trap-focus'",
      default: 'true',
      description: {
        ko: '뒤 페이지를 키보드에서도 가져가는지. trap-focus는 페이지를 스크롤·클릭할 수 있게 두고 포커스만 붙잡습니다',
        en: "Whether the page behind is taken away for the keyboard too. 'trap-focus' leaves it scrollable and clickable while still holding focus inside"
      }
    },
    {
      name: 'align',
      type: "'start' | 'center' | 'end'",
      default: "'center'",
      shared: true,
      description: {
        ko: '내용이 화면 세로에서 앉는 자리',
        en: 'Where the content sits down the viewport'
      }
    },
    {
      name: 'size',
      type: SIZE,
      default: "'md'",
      shared: true,
      description: { ko: '내용 둘레 여백의 스케일', en: 'Scale of the padding around the content' }
    },
    {
      name: 'color',
      type: COLOR,
      default: "'primary'",
      shared: true,
      description: {
        ko: '의미론적 색 역할. 포커스 링과, 내용이 읽어 가는 슬롯에 닿습니다',
        en: 'Semantic colour role. Reaches the focus ring and whatever the content reads'
      }
    },
    {
      name: 'label',
      type: 'string',
      default: "'Overlay'",
      description: {
        ko: '오버레이의 접근성 이름. 읽을 것이 없는 오버레이도 자기가 무엇인지는 말해야 하므로 선택이 아니라 기본값입니다',
        en: 'The accessible name. It has a default rather than being optional: an overlay that holds nothing readable still has to say what it is'
      }
    },
    {
      name: 'children',
      type: 'ReactNode',
      description: {
        ko: '스크림 위에 앉는 것 — 스피너, 한 줄, 작은 카드',
        en: 'What sits on top of the scrim — a spinner, a line of text, a small card'
      }
    }
  ]
};
