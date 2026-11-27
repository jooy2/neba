import {
  colorRow,
  densityRow,
  focusRows,
  from,
  renamed,
  sizeRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Breadcrumb: [
    from('Breadcrumb', 'locale', {
      type: 'Locale?',
      default: { ko: 'NebaProvider의 값, 없으면 앱의 언어', en: 'NebaProvider’s, then the app’s' },
      description: {
        ko: '트레일과 …의 이름을 쓸 언어',
        en: 'The language the trail and the … are named in'
      }
    }),
    sizeRow('Breadcrumb'),
    colorRow('Breadcrumb'),
    densityRow('Breadcrumb'),
    from('Breadcrumb', 'separator', {
      type: 'NebaBreadcrumbSeparator',
      default: 'NebaBreadcrumbSeparator.chevron',
      description: {
        ko: '두 단계 사이에 그려지는 표시. chevron, arrow, slash, dot 중 하나이거나 NebaBreadcrumbSeparator.widget(…)으로 넘긴 widget입니다. chevron과 arrow는 "그다음"을, slash는 "경로"를, dot은 "한 가지의 동급들"을 말합니다',
        en: 'What is drawn between two steps: chevron, arrow, slash or dot, or a widget passed as NebaBreadcrumbSeparator.widget(…). chevron and arrow say "and then", slash says "path", dot says "peers of one thing"'
      }
    }),
    from('Breadcrumb', 'maxItems', { type: 'int?' }),
    from('Breadcrumb', 'itemsBeforeCollapse', { type: 'int' }),
    from('Breadcrumb', 'itemsAfterCollapse', { type: 'int' }),
    from('Breadcrumb', 'expandable', { type: 'bool' }),
    from('Breadcrumb', 'label', {
      type: 'String?',
      description: {
        ko: '트레일이 읽히는 이름. 기본값은 locale의 "Breadcrumb"입니다',
        en: 'The name the trail is announced by. Defaults to the locale’s "Breadcrumb"'
      }
    }),
    from('Breadcrumb', 'expandLabel', { type: 'String?' }),
    from('Breadcrumb', 'children', {
      type: 'List<NebaBreadcrumbItem>',
      required: true,
      description: {
        ko: '위에서부터 지금 페이지까지의 단계',
        en: 'The steps, from the top of the hierarchy down to the current page'
      }
    })
  ],

  BreadcrumbItem: [
    renamed('BreadcrumbItem', 'onClick', 'onPressed', {
      type: 'VoidCallback?',
      description: {
        ko: '단계를 누를 때 하는 일. 보통 그 페이지로 가는 router 호출입니다. href가 있으면 링크, 없으면 버튼이 됩니다',
        en: 'What pressing the step does, usually the router going to that page. With an href the step is a link, without one a button'
      }
    }),
    from('BreadcrumbItem', 'href', {
      type: 'Uri?',
      description: {
        ko: '단계가 가는 곳. screen reader와, 웹에서는 브라우저에 알리며 누를 수 있는 단계를 링크로 만듭니다. 이동은 onPressed의 몫입니다. scheme이 http, https, mailto, tel이 아니면 쓰지 않습니다',
        en: 'Where the step leads, for a screen reader and, on the web, the browser. It makes a pressable step a link; following it is onPressed’s. A scheme other than http, https, mailto or tel is not written'
      }
    }),
    {
      name: 'newTab',
      type: 'bool',
      default: 'false',
      description: {
        ko: '단계의 링크가 앱 밖으로 나가는지. screen reader가 라벨 뒤에 "(새 창에서 열림)"을 읽으며, 새 탭을 여는 일은 onPressed의 몫입니다. React의 target에 해당합니다',
        en: 'Whether the step’s link leaves the app. A screen reader hears "(opens in a new tab)" after the label; opening the tab is onPressed’s. React’s target'
      }
    },
    from('BreadcrumbItem', 'startIcon', { type: `${WIDGET}?` }),
    from('BreadcrumbItem', 'endIcon', { type: `${WIDGET}?` }),
    from('BreadcrumbItem', 'current', { type: 'bool?' }),
    from('BreadcrumbItem', 'disabled', { type: 'bool' }),
    renamed('BreadcrumbItem', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '단계의 라벨. 보통 Text이며, 줄이 좁으면 말줄임표로 잘립니다',
        en: 'The step’s label, usually a Text, cut short with an ellipsis when the row is too narrow'
      }
    }),
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
