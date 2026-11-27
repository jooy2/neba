import { animateRows, from, textAlignRow, textStyleRow, WIDGET, type PropRow } from './shared';

export default {
  AnimateTyping: [
    from('AnimateTyping', 'text', {
      type: 'String',
      required: true,
      description: { ko: '타이핑할 문자열', en: 'The text to type' }
    }),
    textStyleRow,
    textAlignRow,
    from('AnimateTyping', 'speed', { type: 'double' }),
    from('AnimateTyping', 'hold', {
      type: 'Duration',
      default: 'Duration(milliseconds: 1400)',
      description: {
        ko: '다 쓴 뒤 반복 전까지 머무는 시간',
        en: 'How long the finished text is held before it repeats'
      }
    }),
    from('AnimateTyping', 'erase', { type: 'bool' }),
    from('AnimateTyping', 'eraseSpeed', { type: 'double?' }),
    from('AnimateTyping', 'caret', { type: 'bool' }),
    from('AnimateTyping', 'caretChar', {
      type: `${WIDGET}?`,
      default: "Text('|')",
      description: { ko: '커서로 그릴 위젯', en: 'The widget the caret is drawn as' }
    }),
    from('AnimateTyping', 'duration', {
      type: 'Duration?',
      default: undefined,
      description: {
        ko: '문자열 전체를 쓰는 데 걸리는 시간. 주면 speed 대신 쓰입니다',
        en: 'The time for the whole string. Given, it is used instead of speed'
      }
    }),
    ...animateRows('AnimateTyping', {
      duration: 0,
      mode: false,
      omit: [
        'stagger',
        'durationStep',
        'reverse',
        'timeline',
        'range',
        'duration',
        'easing',
        'alternate'
      ]
    })
  ]
} satisfies Record<string, PropRow[]>;
