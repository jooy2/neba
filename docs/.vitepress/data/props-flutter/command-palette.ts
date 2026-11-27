import { colorRow, densityRow, from, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  CommandPalette: [
    from('CommandPalette', 'items', { type: 'List<NebaCommandItem>' }),
    from('CommandPalette', 'open', { type: 'bool?' }),
    from('CommandPalette', 'defaultOpen', { type: 'bool' }),
    from('CommandPalette', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('CommandPalette', 'onSelect', { type: 'ValueChanged<NebaCommandItem>?' }),
    from('CommandPalette', 'shortcut', {
      type: 'String?',
      description: {
        ko: '팔레트를 여는 키. focus가 어디에 있든 앱 전체에 바인딩됩니다. Mod는 Mac에서 Command, 그 밖에서는 Control입니다. null은 아무것도 바인딩하지 않습니다',
        en: 'The keystroke that opens the palette, bound on the whole app wherever the focus is. Mod is Command on a Mac and Control everywhere else; null binds nothing'
      }
    }),
    from('CommandPalette', 'width', {
      type: 'double?',
      description: {
        ko: '시트가 넓어질 수 있는 한계(논리 픽셀). size가 주는 너비 대신 쓰입니다',
        en: 'How wide the sheet may get, in logical pixels, in place of the width size gives it'
      }
    }),
    from('CommandPalette', 'maxHeight', { type: 'double' }),
    sizeRow('CommandPalette'),
    colorRow('CommandPalette'),
    densityRow('CommandPalette'),
    from('CommandPalette', 'locale', {
      type: 'Locale?',
      description: {
        ko: 'placeholder와 빈 줄, dialog의 이름을 쓰는 언어. 주지 않으면 NebaProvider의 것, 그다음 앱의 것입니다',
        en: "The language of the placeholder, the empty line and the dialog's name. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('CommandPalette', 'placeholder', { type: 'String?' }),
    from('CommandPalette', 'emptyMessage', { type: `${WIDGET}?` }),
    from('CommandPalette', 'label', {
      type: 'String?',
      description: {
        ko: '화면 낭독기가 dialog를 부르는 이름. 보이는 제목이 없습니다',
        en: 'What a screen reader names the dialog, which has no visible title'
      }
    })
  ],

  CommandItem: [
    from('CommandItem', 'value', { type: 'String' }),
    from('CommandItem', 'label', { type: 'String' }),
    from('CommandItem', 'description', { type: `${WIDGET}?` }),
    from('CommandItem', 'icon', { type: `${WIDGET}?` }),
    from('CommandItem', 'shortcut', { type: 'String?' }),
    from('CommandItem', 'group', { type: 'String?' }),
    from('CommandItem', 'keywords', { type: 'List<String>', default: '[]' }),
    from('CommandItem', 'disabled', { type: 'bool' }),
    from('CommandItem', 'onSelect', { type: 'VoidCallback?' })
  ]
} satisfies Record<string, PropRow[]>;
