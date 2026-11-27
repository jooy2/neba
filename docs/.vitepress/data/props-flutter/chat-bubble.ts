import {
  COLOR,
  ELEVATION,
  WIDGET,
  densityRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  type PropRow
} from './shared';

export default {
  ChatBubble: [
    from('ChatBubble', 'side', {
      type: 'NebaChatBubbleSide',
      default: 'NebaChatBubbleSide.start'
    }),
    from('ChatBubble', 'name', { type: `${WIDGET}?` }),
    from('ChatBubble', 'time', { type: `${WIDGET}?` }),
    from('ChatBubble', 'avatar', {
      type: `${WIDGET}?`,
      description: {
        ko: '보낸 사람의 그림, 보통 NebaAvatar. 없으면 말풍선이 줄 전체를 씁니다',
        en: 'The sender’s picture: a NebaAvatar. Left out, the bubble takes the whole row'
      }
    }),
    from('ChatBubble', 'status', { type: 'NebaChatBubbleStatus?' }),
    from('ChatBubble', 'statusLabel', { type: 'String?' }),
    from('ChatBubble', 'typing', {
      type: 'bool',
      description: {
        ko: '메시지 대신 점 세 개를 그립니다. child는 그대로 두므로 같은 말풍선이 다시 돌아올 수 있습니다',
        en: 'Draws the three dots instead of the message. child is left alone, so the same bubble can go back to it'
      }
    }),
    from('ChatBubble', 'media', {
      type: `${WIDGET}?`,
      description: {
        ko: '사진·영상·지도. 텍스트 위에 가장자리까지 채워 그려지고 말풍선의 모서리가 잘라 냅니다. 넘긴 위젯이 말풍선의 너비를 받습니다',
        en: 'A picture, a video, a map: drawn edge to edge above the text, cropped by the bubble’s corners. The widget is given the bubble’s width'
      }
    }),
    from('ChatBubble', 'preview', {
      type: 'NebaChatBubbleLinkPreview?',
      description: {
        ko: '메시지 안의 링크를 카드로 펼칩니다. url · onPressed · title · description · image · site · newTab',
        en: 'A link in the message, unfurled into a card: url · onPressed · title · description · image · site · newTab'
      }
    }),
    from('ChatBubble', 'actions', {
      type: `${WIDGET}?`,
      description: {
        ko: '메시지의 액션, 보통 NebaMenu의 trigger. 말풍선 옆에 놓이고, 줄에 hover나 focus가 오기 전까지는 비켜서 있습니다. 터치 화면에서는 늘 보입니다',
        en: 'The message’s own actions: usually a NebaMenu trigger. Sits beside the bubble and stays out of the way until the row is hovered or focused; always shown on a touch screen'
      }
    }),
    from('ChatBubble', 'locale', {
      type: 'Locale?',
      default: undefined,
      description: {
        ko: '표식을 읽어 주는 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것이며, 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the marks are read out in. Defaults to NebaProvider's, then the app's; a language that was never registered falls back to English"
      }
    }),
    variantRow('ChatBubble', 'NebaVariant.outline'),
    sizeRow('ChatBubble'),
    from('ChatBubble', 'color', { type: COLOR, default: 'NebaColor.primary' }),
    densityRow('ChatBubble'),
    from('ChatBubble', 'elevation', { type: ELEVATION, default: '0' }),
    renamed('ChatBubble', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
