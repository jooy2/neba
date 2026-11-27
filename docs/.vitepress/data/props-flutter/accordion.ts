import {
  colorRow,
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Accordion: [
    variantRow('Accordion', 'NebaVariant.outline'),
    sizeRow('Accordion'),
    colorRow('Accordion'),
    densityRow('Accordion'),
    elevationRow('Accordion'),
    from('Accordion', 'multiple', { type: 'bool' }),
    from('Accordion', 'value', {
      type: 'List<T>?',
      description: {
        ko: '열려 있는 섹션의 value. controlled 아코디언에 씁니다. null이면 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: 'Which sections are open, by their value, for a controlled accordion. Left null, it keeps its own state, starting from defaultValue'
      }
    }),
    from('Accordion', 'defaultValue', { type: 'List<T>?' }),
    from('Accordion', 'onValueChange', {
      type: 'ValueChanged<List<T>>?',
      description: {
        ko: '헤더를 누른 뒤 열려 있는 섹션의 value들과 함께 호출됩니다. value가 없는 섹션도 열리고 닫히지만 이 목록에는 들어가지 않습니다',
        en: 'Called with the values of the open sections after a header is pressed. A section with no value opens and closes, and is left out of the list'
      }
    }),
    from('Accordion', 'dividers', { type: 'bool' }),
    from('Accordion', 'headingLevel', { type: 'int' }),
    from('Accordion', 'disabled', { type: 'bool' }),
    from('Accordion', 'keepMounted', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '닫힌 섹션의 내용을 빌드된 채로 남겨, 접혔다 펴져도 안의 상태가 그대로입니다. 열려 있을 때만 있으면 되는, 만드는 비용이 큰 섹션에는 끄면 됩니다',
        en: 'Keeps what a closed section holds built, so its state survives being folded away. Turn it off for sections that are expensive to build and only need to exist while open'
      }
    }),
    from('Accordion', 'children', {
      type: `List<${WIDGET}>`,
      description: { ko: 'NebaAccordionItem들', en: 'The NebaAccordionItems' }
    })
  ],

  AccordionItem: [
    from('AccordionItem', 'value', {
      type: 'T?',
      description: {
        ko: '아코디언의 value와 defaultValue에서 이 섹션을 가리키는 이름. 생략하면 스택 안의 자리로 이름이 붙으므로, 코드로 제어하지 않는 아코디언이라면 생략해도 됩니다',
        en: "Names the section to the accordion's value and defaultValue. Left out, the section is named by its place in the stack, which is fine for an accordion nobody drives from code"
      }
    }),
    from('AccordionItem', 'title', { type: `${WIDGET}?` }),
    from('AccordionItem', 'subtitle', { type: `${WIDGET}?` }),
    from('AccordionItem', 'startIcon', { type: `${WIDGET}?` }),
    from('AccordionItem', 'action', { type: `${WIDGET}?` }),
    from('AccordionItem', 'lines', { type: 'int?' }),
    from('AccordionItem', 'disabled', { type: 'bool' }),
    renamed('AccordionItem', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
