import { from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  ConfirmProvider: [
    renamed('ConfirmProvider', 'children', 'child', {
      type: WIDGET,
      required: true,
      description: {
        ko: '앱. 그 아래 어디서든 NebaConfirmProvider.of(context)로 질문합니다',
        en: 'The app, anywhere below which NebaConfirmProvider.of(context) asks a question'
      }
    }),
    from('ConfirmProvider', 'defaults', {
      type: 'NebaConfirmOptions',
      default: 'const NebaConfirmOptions()',
      description: {
        ko: '그 아래 모든 질문이 공유하는 color, size, width, locale 같은 값. 각 질문이 덮어씁니다',
        en: 'What every question asked under it shares, such as its color, size, width and locale. Each question overrides them'
      }
    })
  ],

  ConfirmOptions: [
    from('ConfirmOptions', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '질문. 보통 Text이며, dialog의 제목이자 스크린 리더가 읽는 이름입니다',
        en: "The question, usually a Text: the dialog's heading, and what a screen reader announces"
      }
    }),
    from('ConfirmOptions', 'description', { type: `${WIDGET}?` }),
    from('ConfirmOptions', 'confirmLabel', { type: `${WIDGET}?` }),
    from('ConfirmOptions', 'cancelLabel', { type: `${WIDGET}?` }),
    from('ConfirmOptions', 'color', { type: 'NebaColor?', default: 'NebaColor.primary' }),
    sizeRow('ConfirmOptions', 'NebaSize.sm'),
    from('ConfirmOptions', 'alert', { type: 'bool?', default: 'false' }),
    from('ConfirmOptions', 'dismissible', {
      type: 'bool?',
      default: 'true',
      description: {
        ko: 'Escape, 시트 바깥 누름, 화면 낭독기의 닫기 동작이 아니오로 답할지. 끄면 버튼으로만 답할 수 있습니다. 나갈 길 없는 modal은 사람들이 제보하는 그것이니 거의 쓰지 마세요',
        en: "Whether Escape, a press outside the sheet and a screen reader's dismiss gesture answer no. Off makes a question the reader has to answer with a button: use it rarely, since a modal with no way out is the thing people report"
      }
    }),
    from('ConfirmOptions', 'width', {
      type: 'double?',
      description: {
        ko: '시트의 최대 너비(논리 픽셀). NebaDialog로 전달됩니다',
        en: 'The widest the sheet gets, in logical pixels, passed to NebaDialog'
      }
    }),
    from('ConfirmOptions', 'locale', {
      type: 'Locale?',
      description: {
        ko: '두 기본 라벨의 언어. 기본값은 provider의 defaults, NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language of the two default labels. Defaults to the provider's defaults, then NebaProvider's, then the app's"
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
