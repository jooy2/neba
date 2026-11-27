import { densityRow, from, sizeRow, variantRow, WIDGET, type PropRow } from './shared';

export default {
  Shortcut: [
    from('Shortcut', 'keys', {
      type: 'String | List<String>',
      description: {
        ko: '키. 생성자가 타입을 정합니다. NebaShortcut은 문자열을 +로 나누고, 키 자체가 +인 단축키는 NebaShortcut.split에 목록으로 넘깁니다',
        en: 'The keys, typed by the constructor: NebaShortcut splits a string on `+`, and a shortcut whose key is itself a plus goes to NebaShortcut.split as a list'
      }
    }),
    from('Shortcut', 'os', {
      type: 'NebaShortcutOS',
      default: 'NebaShortcutOS.auto',
      description: {
        ko: '어느 키보드로 읽을지. auto는 defaultTargetPlatform을 따라 macOS와 iOS는 mac, Windows는 windows, 나머지는 linux로 읽습니다. 웹에서는 브라우저의 플랫폼입니다',
        en: 'Which keyboard to name the modifiers for. `auto` follows defaultTargetPlatform: macOS and iOS are mac, Windows is windows and everything else linux. On the web it is the browser’s platform'
      }
    }),
    from('Shortcut', 'separator', {
      type: `${WIDGET}?`,
      description: {
        ko: '키 사이에 들어갈 것. 생략하면 플랫폼 관례를 따라 Windows와 Linux는 +, macOS는 아무것도 넣지 않습니다. 어디서나 비우려면 SizedBox.shrink()를 넘기세요',
        en: 'What goes between two keys. Left out, the platform’s convention: a `+` on Windows and Linux and nothing on macOS. A SizedBox.shrink() puts nothing between them anywhere'
      }
    }),
    variantRow('Shortcut', 'NebaVariant.outline'),
    sizeRow('Shortcut'),
    from('Shortcut', 'color', { type: 'NebaColor', default: 'NebaColor.secondary' }),
    densityRow('Shortcut', 'NebaDensity.compact'),
    from('Shortcut', 'elevation', { type: 'NebaElevation', default: '0' })
  ]
} satisfies Record<string, PropRow[]>;
