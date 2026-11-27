import { COLOR, WIDGET, from, renamed, type PropRow } from './shared';

export default {
  StreamingText: [
    renamed('StreamingText', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '지금까지의 텍스트. 평범한 Text가 이 컴포넌트의 쓰임새이며, 스트림으로 도착하는 부분은 단어로 잘려 하나씩 나타납니다. 그 밖의 위젯은 손대지 않고 그리고, 커서와 잡아 둔 높이는 그대로 둘러쌉니다',
        en: 'The text so far. A plain Text is what this is for: what arrives while it streams is cut into words, each fading in as it lands. Any other widget is drawn untouched, with the caret and the reserved height still around it'
      }
    }),
    from('StreamingText', 'streaming', { type: 'bool' }),
    from('StreamingText', 'cursor', {
      type: `${WIDGET}?`,
      default: undefined,
      description: {
        ko: '스트림이 도는 동안 끝에 놓을 것. 없으면 깜빡이는 블록입니다',
        en: 'What stands at the end while the stream runs, in place of the blinking block'
      }
    }),
    {
      name: 'showCursor',
      type: 'bool',
      default: 'true',
      description: {
        ko: '끝에 무엇이든 그릴지 여부. false면 생략하며, React의 cursor={false}에 해당합니다',
        en: "Whether anything stands at the end at all; false drops it, React's cursor={false}"
      }
    },
    from('StreamingText', 'fade', { type: 'bool' }),
    from('StreamingText', 'lines', {
      type: 'int',
      description: {
        ko: '아무것도 도착하지 않은 동안 잡아 둘 높이의 줄 수. 블록의 글자 스타일로 잰 한 줄의 높이를 단위로 쓰며, 텍스트가 들어온 뒤에도 바닥값으로 남습니다',
        en: 'How many lines of height to hold before anything has arrived, in the line height of the block’s own type. A floor, kept once the text is there'
      }
    }),
    from('StreamingText', 'color', { type: `${COLOR}?`, default: 'NebaColor.primary' })
  ]
} satisfies Record<string, PropRow[]>;
