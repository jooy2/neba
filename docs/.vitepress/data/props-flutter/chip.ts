import {
  densityRow,
  elevationRow,
  focusRows,
  from,
  renamed,
  sizeRow,
  transitionRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Chip: [
    from('Chip', 'locale', {
      type: 'Locale?',
      description: {
        ko: '× 버튼의 접근성 이름을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language the × button is named in. Defaults to NebaProvider's, then the app's"
      }
    }),
    variantRow('Chip', 'NebaVariant.outline'),
    sizeRow('Chip'),
    from('Chip', 'color', { type: 'NebaColor?', default: 'NebaColor.primary' }),
    densityRow('Chip'),
    elevationRow('Chip'),
    from('Chip', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '라벨 앞에 놓이는 아이콘, 상태 점, 아바타. Chip이 내려주는 IconTheme으로 라벨 크기의 1.2배가 됩니다',
        en: 'Before the label: an icon, a status dot, an avatar, drawn at 1.2 times its size through the IconTheme the chip hands down'
      }
    }),
    from('Chip', 'endIcon', { type: `${WIDGET}?` }),
    from('Chip', 'count', {
      type: `${WIDGET}?`,
      description: {
        ko: '끝에 붙는 숫자. 보통 Text이며, 자기 판 위에 그려져 칩 하나로 읽힙니다',
        en: 'A number set into the end, usually a Text, on its own small plate'
      }
    }),
    renamed('Chip', 'onClick', 'onPressed', {
      type: 'VoidCallback?',
      description: {
        ko: '넘기면 라벨이 자기 focus를 가진 버튼이 됩니다',
        en: 'Passing it turns the label into a button with a focus stop of its own'
      }
    }),
    from('Chip', 'onDelete', { type: 'VoidCallback?' }),
    from('Chip', 'deleteLabel', {
      type: 'String?',
      description: {
        ko: '× 버튼의 접근성 이름. 기본값은 라벨이 Text이면 locale의 "Remove {label}", 아니면 "Remove"입니다',
        en: 'Accessible name of the × button. Defaults to the locale\'s "Remove {label}" when the label is a Text, and to its "Remove" otherwise'
      }
    }),
    from('Chip', 'selected', {
      type: 'bool?',
      description: {
        ko: '선택됨. 색 계열을 바꾸는 대신 표면을 한 단계 깊게 만듭니다. false를 포함해 값을 주면 누를 수 있는 Chip이 선택 상태를 화면 낭독기에 알립니다',
        en: 'Chosen. Deepens the surface a step rather than changing the colour family. Passing it, false included, makes a pressable chip announce whether it is selected'
      }
    }),
    from('Chip', 'disabled', {
      type: 'bool',
      description: {
        ko: '사용 불가. 중립 회색이 되고, 라벨은 버튼이 아니며 ×는 누를 수 없습니다',
        en: 'Unavailable. Turns neutral grey; the label is not a button and the × cannot be pressed'
      }
    }),
    renamed('Chip', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '칩의 라벨. 보통 Text이며, 자리가 모자라면 말줄임표로 잘립니다',
        en: "The chip's label, usually a Text, cut short with an ellipsis when it is given less room"
      }
    }),
    transitionRow('Chip', 'const NebaTransition.zoom()'),
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
