import { colorRow, densityRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Timeline: [
    from('Timeline', 'active', { type: 'int?' }),
    sizeRow('Timeline'),
    colorRow('Timeline'),
    densityRow('Timeline'),
    from('Timeline', 'orientation', {
      type: 'NebaOrientation',
      default: 'NebaOrientation.vertical'
    }),
    from('Timeline', 'locale', {
      type: 'Locale?',
      default: { ko: 'NebaProvider의 값, 없으면 앱의 언어', en: 'NebaProvider’s, then the app’s' }
    }),
    from('Timeline', 'labels', {
      type: 'Map<NebaTimelineStatus, String>?',
      description: {
        ko: '완료·예정 상태를 말하는 낱말을 상태별로 적습니다. locale의 문구보다 우선하며, current는 말하지 않고 선택된 항목으로 표시됩니다',
        en: 'The words for a finished and a waiting step, by status. They override the locale’s; the current step says nothing and is selected instead'
      }
    }),
    from('Timeline', 'children', {
      type: `List<${WIDGET}>`,
      required: true,
      description: {
        ko: '단계. 보통 NebaTimelineItem이며, 인덱스는 여기서 매겨지므로 중간에 하나를 끼워 넣어도 뒤의 것을 다시 번호 매길 필요가 없습니다',
        en: 'The steps, usually NebaTimelineItems. They are numbered here, so inserting one in the middle does not mean renumbering the ones after it'
      }
    })
  ],

  TimelineItem: [
    from('TimelineItem', 'title', { type: `${WIDGET}?` }),
    from('TimelineItem', 'meta', {
      type: `${WIDGET}?`,
      description: {
        ko: '언제 일어났는지, 날짜, 소요 시간, 이름. 제목 옆에 놓이고, 한 줄에 들어가지 않으면 아래로 내려갑니다',
        en: 'When it happened: a date, a duration, a name. Beside the title, and under it when the two do not fit on one line'
      }
    }),
    from('TimelineItem', 'bullet', {
      type: `${WIDGET}?`,
      description: {
        ko: '불릿 안에 들어가는 것, 번호, 아이콘. 글자는 불릿의 절반, 아이콘은 0.6배 크기가 됩니다. 생략하면 그냥 원입니다',
        en: 'What goes inside the bullet: a number, an icon. Text is set at half the bullet and an icon at six tenths of it. Omit it and the bullet is a plain disc'
      }
    }),
    from('TimelineItem', 'status', { type: 'NebaTimelineStatus?' }),
    from('TimelineItem', 'color', { type: 'NebaColor?' }),
    from('TimelineItem', 'connector', {
      type: 'NebaTimelineConnector',
      default: 'NebaTimelineConnector.solid'
    }),
    renamed('TimelineItem', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
