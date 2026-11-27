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
  Empty: [
    variantRow('Empty', 'NebaVariant.text'),
    sizeRow('Empty'),
    from('Empty', 'color', { type: 'NebaColor?', default: 'NebaColor.secondary' }),
    densityRow('Empty'),
    elevationRow('Empty'),
    from('Empty', 'title', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목 줄. 기본값은 locale이 “여기에는 아무것도 없다”를 말하는 방식입니다',
        en: "The headline. Defaults to the locale's way of saying that there is nothing here"
      }
    }),
    {
      name: 'showTitle',
      type: 'bool',
      default: 'true',
      description: {
        ko: '제목 줄을 둘지 여부. false면 글리프와 문장만 남으며, React의 title={false}에 해당합니다',
        en: "Whether there is a headline at all; false leaves the glyph and the sentence, React's title={false}"
      }
    },
    from('Empty', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: '제목 위의 글리프. 기본값은 빈 트레이입니다. IconTheme을 읽는 글리프는 size 사다리에 맞춰 흐린 잉크로 그려지고, 그 밖의 것은 원래 크기 그대로입니다',
        en: 'The glyph above the headline. Defaults to the empty tray. A glyph that reads the IconTheme is sized off the size ladder in the muted ink, and anything else is left at the size it came in at'
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '글리프를 그릴지 여부. false면 생략하며, React의 icon={false}에 해당합니다',
        en: "Whether a glyph is drawn at all; false drops it, React's icon={false}"
      }
    },
    renamed('Empty', 'action', 'actions', {
      type: `List<${WIDGET}>`,
      default: 'const []',
      description: {
        ko: '본문 아래에 놓이는 다음 할 일, “첫 항목 만들기” 버튼, “필터 지우기” 링크. 여럿이면 8픽셀 간격으로 한 줄에 놓이고 함께 줄바꿈됩니다',
        en: 'What to do about it, under the text: a "Create the first one" button, a "Clear filters" link. Several sit in a row 8 pixels apart and wrap together'
      }
    }),
    from('Empty', 'locale', {
      type: 'Locale?',
      default: undefined,
      description: {
        ko: '기본 제목의 언어. title을 주면 무시됩니다. 기본값은 NebaProvider의 것, 그다음 앱의 locale이며, 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the default headline is written in, ignored once title is given. Defaults to NebaProvider's, then the app's; a language that was never registered falls back to English"
      }
    }),
    {
      name: 'role',
      type: 'SemanticsRole?',
      default: 'SemanticsRole.status',
      description: {
        ko: '상태가 어떤 live region인지. SemanticsRole.none이면 live region이 아니며, 처음부터 화면의 일부로 놓이는 상태에 씁니다',
        en: 'The live region the state is. SemanticsRole.none is no live region, for a state that is simply part of the screen when it arrives'
      }
    },
    renamed('Empty', 'children', 'child', { type: `${WIDGET}?` }),
    transitionRow('Empty')
  ]
} satisfies Record<string, PropRow[]>;
