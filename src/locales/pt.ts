/**
 * Portuguese.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, pt } from 'neba/locales';
 *
 * registerMessages('pt', pt);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const pt: NebaLocale = {
  action: {
    close: 'Fechar',
    dismiss: 'Dispensar',
    clear: 'Limpar',
    remove: 'Remover'
  },
  link: { newTab: '(abre em uma nova aba)' },
  spoiler: {
    reveal: 'Mostrar',
    hide: 'Ocultar',
    notice: 'Pode conter spoilers'
  },
  chat: {
    sending: 'Enviando',
    sent: 'Enviado',
    delivered: 'Entregue',
    read: 'Lido',
    failed: 'Não enviado',
    typing: 'Digitando…'
  },
  empty: { title: 'Nada por aqui' },
  table: {
    search: 'Pesquisar',
    selectAll: 'Selecionar todas as linhas',
    selectRow: 'Selecionar linha',
    rowsPerPage: 'Linhas por página',
    range: '{start}–{end} de {total}',
    selected: '{count} selecionadas',
    empty: 'Sem dados'
  },
  color: {
    area: 'Saturação e brilho',
    hue: 'Matiz',
    alpha: 'Opacidade',
    value: 'Valor da cor',
    swatches: 'Cores predefinidas',
    clear: 'Limpar',
    empty: 'Escolher uma cor'
  },
  rating: {
    label: 'Avaliação',
    value: '{value} de {max}',
    empty: 'Sem avaliação'
  },
  number: {
    increase: 'Aumentar',
    decrease: 'Diminuir'
  },
  pagination: {
    label: 'Paginação',
    page: 'Página {page}',
    status: 'Página {page} de {total}',
    previous: 'Página anterior',
    next: 'Próxima página',
    first: 'Primeira página',
    last: 'Última página'
  },
  carousel: {
    label: 'Carrossel',
    slide: 'Slide {index} de {total}',
    previous: 'Slide anterior',
    next: 'Próximo slide'
  },
  scroll: { previous: 'Rolar para trás', next: 'Rolar para a frente' },
  breadcrumb: {
    label: 'Trilha de navegação',
    expand: 'Mostrar as etapas ocultas'
  },
  anchor: { label: 'Nesta página' },
  combobox: {
    empty: 'Nenhuma correspondência',
    remove: 'Remover {label}'
  },
  overlay: {
    label: 'Sobreposição'
  },
  window: {
    minimize: 'Minimizar',
    maximize: 'Maximizar',
    restore: 'Restaurar',
    resize: 'Redimensionar a janela'
  },
  layout: {
    skipToContent: 'Ir para o conteúdo',
    sidebar: 'Barra lateral',
    openSidebar: 'Abrir barra lateral',
    closeSidebar: 'Fechar barra lateral',
    resizeSidebar: 'Redimensionar barra lateral'
  },
  code: {
    code: 'Código',
    copy: 'Copiar',
    copied: 'Copiado',
    copyFailed: 'Não foi possível copiar',
    raw: 'Sem formatação',
    prompt: 'Prompt'
  },
  steps: {
    previous: 'Anterior',
    next: 'Próximo',
    done: 'Concluir',
    restart: 'Começar de novo',
    completed: 'Todas as etapas concluídas',
    steps: 'Etapas',
    position: '{index} de {total}',
    step: 'Etapa {index}: {title}'
  }
};
