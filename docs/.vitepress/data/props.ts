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
        ko: '표면의 무게. solid도 색으로 채우지 않습니다 — 박스가 담는 것은 남의 콘텐츠입니다',
        en: "Weight of the surface. Even solid is not flooded — a box holds other people's content"
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
  ]
};
