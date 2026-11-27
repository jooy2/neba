import {
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  transitionRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Alert: [
    from('Alert', 'locale', {
      type: 'Locale?',
      description: {
        ko: '닫기 버튼의 접근성 이름을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language the dismiss button is named in. Defaults to NebaProvider's, then the app's"
      }
    }),
    variantRow('Alert', 'NebaVariant.outline'),
    sizeRow('Alert'),
    from('Alert', 'color', { type: 'NebaColor?', default: 'NebaColor.info' }),
    densityRow('Alert'),
    elevationRow('Alert'),
    from('Alert', 'title', { type: `${WIDGET}?` }),
    from('Alert', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: '앞머리 글리프를 바꿉니다. 없으면 color에 딸린 그림이며, Alert가 내려주는 IconTheme으로 본문 크기의 1.2배가 됩니다. 색만으로 심각도를 말하지 않기 위해 계열마다 모양이 다릅니다',
        en: 'Replaces the glyph at the start, which is otherwise the one that goes with `color`, drawn at 1.2 times the message through the IconTheme the alert hands down. The shapes differ per family so severity is not carried by colour alone'
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '글리프를 그릴지 여부. false면 글리프 없이 문장만 남으며, React의 icon={false}에 해당합니다',
        en: "Whether a glyph is drawn at all; false leaves the sentence alone, React's icon={false}"
      }
    },
    from('Alert', 'action', { type: `${WIDGET}?` }),
    from('Alert', 'onClose', { type: 'VoidCallback?' }),
    from('Alert', 'closeLabel', {
      type: 'String?',
      description: {
        ko: '닫기 버튼의 접근성 이름. 기본값은 locale의 "Dismiss"입니다',
        en: 'Accessible name of the dismiss button. Defaults to the locale\'s "Dismiss"'
      }
    }),
    {
      name: 'role',
      type: 'SemanticsRole?',
      description: {
        ko: '제목과 메시지가 놓이는 live region. 기본값은 warning과 danger가 SemanticsRole.alert, 나머지가 SemanticsRole.status이며, SemanticsRole.none이면 live region이 아닙니다',
        en: 'The live region the title and the message are in. Defaults to SemanticsRole.alert for warning and danger and SemanticsRole.status for the rest; SemanticsRole.none is no live region'
      }
    },
    renamed('Alert', 'children', 'child', { type: `${WIDGET}?` }),
    transitionRow('Alert', 'const NebaTransition.slide()')
  ]
} satisfies Record<string, PropRow[]>;
