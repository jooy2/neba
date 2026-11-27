import { from, WIDGET, type PropRow } from './shared';

export default {
  Popconfirm: [
    from('Popconfirm', 'trigger', {
      type: `${WIDGET}?`,
      description: {
        ko: '질문이 매달리고, 질문을 띄우는 위젯. NebaIconButton 같은 Neba 컨트롤이어야 하며, 누르면 자기 일을 하고 버블도 열고 닫습니다',
        en: 'What the question hangs off and what raises it: a Neba control such as a NebaIconButton, whose press does its own work and opens and closes the bubble too'
      }
    }),
    from('Popconfirm', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '질문. 보통 Text이며, 그 글이 화면 낭독기에게 버블의 이름이 됩니다',
        en: 'The question, usually a Text, whose words also name the bubble for a screen reader'
      }
    }),
    from('Popconfirm', 'description', { type: `${WIDGET}?` }),
    from('Popconfirm', 'onConfirm', {
      type: 'FutureOr<void> Function()?',
      description: {
        ko: '확인했을 때. Future를 돌려주면 완료될 때까지 버블이 떠 있고 확인 버튼이 busy로 남습니다. 오류로 완료되면 버블은 열린 채로 남고 오류는 잡지 않습니다',
        en: 'Called when the reader confirms. Return a Future and the bubble stays up, its confirming button busy, until it completes. An error leaves the bubble open and is not caught'
      }
    }),
    from('Popconfirm', 'onCancel', { type: 'VoidCallback?' }),
    from('Popconfirm', 'confirmLabel', { type: `${WIDGET}?` }),
    from('Popconfirm', 'cancelLabel', { type: `${WIDGET}?` }),
    from('Popconfirm', 'color', { type: 'NebaColor', default: 'NebaColor.danger' }),
    from('Popconfirm', 'size', {
      type: 'NebaSize?',
      default: 'NebaSize.sm',
      description: {
        ko: '버블과 두 버튼의 크기 단계. 기본값은 NebaProvider의 것, 그다음 sm입니다',
        en: "The step the bubble and its two buttons sit on. Defaults to NebaProvider's, then sm"
      }
    }),
    from('Popconfirm', 'icon', {
      type: `${WIDGET}?`,
      default: 'null',
      description: {
        ko: '색 계열의 severity 마크 대신 그릴 마크. 둘레의 IconTheme이 넘기는 크기와 색으로 그려집니다',
        en: "A mark of your own in place of the colour family's severity mark, drawn at the size and in the colour the IconTheme around it hands down"
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '질문 옆에 마크를 그릴지. 장식이 아니라 의미를 모양으로도 말하는 것이므로 기본이 켜짐이며, React의 icon={false}에 해당합니다',
        en: 'Whether a mark is drawn beside the question at all. On by default, since the shape carries the meaning too: React’s icon={false}'
      }
    },
    from('Popconfirm', 'side', { type: 'NebaSide', default: 'NebaSide.top' }),
    from('Popconfirm', 'align', { type: 'NebaAlign', default: 'NebaAlign.center' }),
    from('Popconfirm', 'open', { type: 'bool?' }),
    from('Popconfirm', 'defaultOpen', { type: 'bool' }),
    from('Popconfirm', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Popconfirm', 'locale', {
      type: 'Locale?',
      description: {
        ko: '두 기본 라벨의 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language of the two default labels. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Popconfirm', 'width', {
      type: 'double',
      description: {
        ko: '버블의 최대 너비(논리 픽셀)',
        en: 'The widest the bubble gets, in logical pixels'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
