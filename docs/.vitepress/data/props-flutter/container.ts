import { densityRow, from, renamed, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Container: [
    from('Container', 'maxWidth', {
      type: 'NebaMeasure',
      default: 'NebaMeasure.none',
      description: {
        ko: '내용이 넓어질 수 있는 한계. 사다리의 한 단계(NebaMeasure.size: xs 480, sm 640, md 768, lg 1024, xl 1280), 논리 픽셀 단위의 직접 쓴 폭(NebaMeasure.width), 또는 제한 없음(NebaMeasure.none)',
        en: 'How wide the content may get: a step of the measure ladder (NebaMeasure.size: xs 480, sm 640, md 768, lg 1024, xl 1280), a width of your own in logical pixels (NebaMeasure.width), or no limit (NebaMeasure.none)'
      }
    }),
    from('Container', 'padded', { type: 'bool' }),
    sizeRow('Container'),
    densityRow('Container'),
    from('Container', 'centered', { type: 'bool' }),
    renamed('Container', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
