import { colorRow, densityRow, from, sizeRow, variantRow, WIDGET, type PropRow } from './shared';

export default {
  ToastProvider: [
    {
      name: 'child',
      type: WIDGET,
      required: true,
      description: {
        ko: '앱. 그 아래 어디서든 NebaToastProvider.of(context)로 Toast를 띄웁니다',
        en: 'The app, anywhere below which NebaToastProvider.of(context) raises a toast'
      }
    },
    from('ToastProvider', 'locale', {
      type: 'Locale?',
      description: {
        ko: '모든 toast의 ×와 스택 영역의 이름을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language the × on every toast and the stack's region are named in. Defaults to NebaProvider's, then the app's"
      }
    }),
    variantRow('ToastProvider', 'NebaVariant.outline'),
    sizeRow('ToastProvider'),
    colorRow('ToastProvider'),
    densityRow('ToastProvider'),
    from('ToastProvider', 'position', {
      type: 'NebaToastPosition',
      default: 'NebaToastPosition.bottomEnd',
      description: {
        ko: '스택이 놓이는 자리. 위·아래 가장자리와 start·center·end를 조합한 여섯 값입니다. 화면 한복판을 세로로 가르는 스택은 만들 수 없습니다',
        en: 'Where the stack is pinned: the top or the bottom edge, at its start, centre or end. There is deliberately no way to ask for a column down the middle'
      }
    }),
    from('ToastProvider', 'timeout', {
      type: 'Duration',
      default: 'Duration(milliseconds: 5000)',
      description: {
        ko: '기본 유지 시간. Duration.zero면 닫을 때까지 남습니다',
        en: 'How long a toast lasts by default. Duration.zero keeps it up until it is closed'
      }
    }),
    from('ToastProvider', 'limit', { type: 'int' }),
    from('ToastProvider', 'width', {
      type: 'double',
      description: {
        ko: '토스트 하나의 최대 너비(논리 픽셀)',
        en: 'How wide a toast is allowed to get, in logical pixels'
      }
    }),
    from('ToastProvider', 'closeLabel', { type: 'String?' }),
    from('ToastProvider', 'label', {
      type: 'String?',
      description: {
        ko: '토스트 스택이 놓이는 영역의 접근성 이름. 스크린 리더가 이 영역으로 건너뛸 수 있습니다. 기본값은 locale의 단어입니다',
        en: "Accessible name of the region the stack lives in, which a screen reader can move to. Defaults to the locale's word"
      }
    })
  ],

  'useToast().add': [
    from('useToast().add', 'title', { type: `${WIDGET}?` }),
    from('useToast().add', 'description', { type: `${WIDGET}?` }),
    from('useToast().add', 'color', { type: 'NebaColor?' }),
    from('useToast().add', 'variant', { type: 'NebaVariant?' }),
    from('useToast().add', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: '앞머리 글리프를 바꿉니다. 없으면 color에 딸린 그림이며, Toast가 내려주는 IconTheme으로 글자 크기의 1.2배가 됩니다',
        en: 'Replaces the glyph, which is otherwise the one that goes with `color`, drawn at 1.2 times the text through the IconTheme the toast hands down'
      }
    }),
    {
      name: 'showIcon',
      type: 'bool?',
      default: 'true',
      description: {
        ko: '글리프를 그릴지 여부. false면 그리지 않으며, React의 icon: false에 해당합니다',
        en: "Whether a glyph is drawn at all; false draws none, React's icon: false"
      }
    },
    from('useToast().add', 'timeout', {
      type: 'Duration?',
      description: {
        ko: '이 토스트의 유지 시간. Duration.zero는 읽고 나서 조치가 필요한 메시지에 씁니다',
        en: 'How long this one lasts. Duration.zero is the right answer for anything the reader has to act on'
      }
    }),
    from('useToast().add', 'priority', {
      type: 'NebaToastPriority?',
      default: 'NebaToastPriority.low'
    }),
    from('useToast().add', 'actionLabel', { type: `${WIDGET}?` }),
    from('useToast().add', 'onAction', { type: 'VoidCallback?' }),
    from('useToast().add', 'id', { type: 'String?' }),
    from('useToast().add', 'onClose', { type: 'VoidCallback?' }),
    from('useToast().add', 'onRemove', {
      type: 'VoidCallback?',
      description: {
        ko: '흐려지며 사라진 뒤 스택에서 빠졌을 때',
        en: 'Called once it has faded out and left the stack'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
