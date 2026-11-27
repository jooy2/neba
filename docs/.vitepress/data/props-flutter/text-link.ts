import { from, renamed, WIDGET, type PropRow } from './shared';

export default {
  TextLink: [
    renamed('TextLink', 'children', 'child', {
      type: WIDGET,
      required: true,
      description: {
        ko: '라벨. 보통 Text입니다. Text 뒤의 글리프는 마지막 줄 끝에 이어서 놓입니다',
        en: 'The label, usually a Text. A glyph after a Text flows at the end of its last line'
      }
    }),
    {
      name: 'onPressed',
      type: 'VoidCallback?',
      required: true,
      description: {
        ko: '링크가 하는 일. 패키지는 아무것도 직접 열지 않으므로 router나 URL launcher를 여기서 부릅니다. null이면 링크처럼 그려지지만 아무 일도 하지 않고 focus도 받지 않습니다',
        en: 'What the link does. The package opens nothing itself, so this calls the router or a URL launcher. With null it is drawn as a link that does nothing and takes no focus'
      }
    },
    from('TextLink', 'href', {
      type: 'Uri?',
      description: {
        ko: '링크가 가는 곳. screen reader와, 웹에서는 브라우저에 알립니다. scheme이 http, https, mailto, tel이 아니면 쓰지 않으며 상대 주소와 fragment는 그대로 둡니다',
        en: 'Where the link goes, for a screen reader and, on the web, the browser. A scheme other than http, https, mailto or tel is not written; a relative address and a fragment are kept'
      }
    }),
    from('TextLink', 'underline', {
      type: 'NebaTextLinkUnderline',
      default: 'NebaTextLinkUnderline.always'
    }),
    from('TextLink', 'color', { type: 'NebaColor?' }),
    from('TextLink', 'size', { type: 'NebaSize?' }),
    from('TextLink', 'newTab', {
      type: 'bool',
      description: {
        ko: '앱 밖으로 나가는 링크인지. 바깥 표식을 그리고 "(새 창에서 열림)"을 읽어 줍니다. 새 탭을 여는 일은 onPressed의 몫입니다',
        en: 'Whether the link leaves the app. It draws the external mark and is announced with "(opens in a new tab)"; opening the tab is onPressed’s'
      }
    }),
    from('TextLink', 'icon', {
      type: `${WIDGET}?`,
      default: undefined,
      description: {
        ko: '기본 글리프 대신 쓸 글리프',
        en: 'A glyph of your own in place of the house one'
      }
    }),
    {
      name: 'showIcon',
      type: 'bool?',
      default: 'newTab',
      description: {
        ko: '라벨 뒤에 글리프를 그릴지. 생략하면 newTab을 따르고, icon을 넘기면 true입니다',
        en: 'Whether a glyph is drawn after the label. Left out, it follows newTab, and it is true when an icon is given'
      }
    },
    from('TextLink', 'locale', {
      type: 'Locale?',
      default: { ko: 'NebaProvider의 값, 없으면 앱의 언어', en: 'NebaProvider’s, then the app’s' }
    }),
    {
      name: 'focusNode',
      type: 'FocusNode?',
      description: { ko: '링크의 focus node', en: 'The link’s focus node' }
    },
    {
      name: 'autofocus',
      type: 'bool',
      default: 'false',
      description: {
        ko: '처음 그려질 때 focus를 가져갈지',
        en: 'Whether the link takes the focus when it is first built'
      }
    }
  ]
} satisfies Record<string, PropRow[]>;
