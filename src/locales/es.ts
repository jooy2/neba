/**
 * Spanish.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, es } from 'neba/locales';
 *
 * registerMessages('es', es);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const es: NebaLocale = {
  action: {
    close: 'Cerrar',
    dismiss: 'Descartar',
    clear: 'Borrar',
    remove: 'Quitar'
  },
  link: { newTab: '(se abre en una pestaña nueva)' },
  spoiler: {
    reveal: 'Mostrar',
    hide: 'Ocultar',
    notice: 'Puede contener spoilers'
  },
  chat: {
    sending: 'Enviando',
    sent: 'Enviado',
    delivered: 'Entregado',
    read: 'Leído',
    failed: 'No enviado',
    typing: 'Escribiendo…'
  },
  empty: { title: 'No hay nada aquí' },
  table: {
    search: 'Buscar',
    selectAll: 'Seleccionar todas las filas',
    selectRow: 'Seleccionar fila',
    rowsPerPage: 'Filas por página',
    range: '{start}–{end} de {total}',
    selected: '{count} seleccionadas',
    empty: 'Sin datos'
  },
  color: {
    area: 'Saturación y brillo',
    hue: 'Tono',
    alpha: 'Opacidad',
    value: 'Valor del color',
    swatches: 'Colores predefinidos',
    clear: 'Borrar',
    empty: 'Elegir un color'
  },
  rating: {
    label: 'Valoración',
    value: '{value} de {max}',
    empty: 'Sin valoración'
  },
  number: {
    increase: 'Aumentar',
    decrease: 'Disminuir'
  },
  pagination: {
    label: 'Paginación',
    page: 'Página {page}',
    status: 'Página {page} de {total}',
    previous: 'Página anterior',
    next: 'Página siguiente',
    first: 'Primera página',
    last: 'Última página'
  },
  carousel: {
    label: 'Carrusel',
    slide: 'Diapositiva {index} de {total}',
    previous: 'Diapositiva anterior',
    next: 'Diapositiva siguiente'
  },
  scroll: { previous: 'Desplazar hacia atrás', next: 'Desplazar hacia adelante' },
  breadcrumb: {
    label: 'Ruta de navegación',
    expand: 'Mostrar los pasos ocultos'
  },
  anchor: { label: 'En esta página' },
  transfer: {
    source: 'Disponibles',
    target: 'Seleccionados',
    toTarget: 'Mover a seleccionados',
    toSource: 'Devolver a disponibles',
    search: 'Buscar',
    selectAll: 'Seleccionar todo',
    empty: 'No hay nada'
  },
  command: {
    label: 'Paleta de comandos',
    search: 'Escribe un comando o busca…',
    empty: 'No se encontraron comandos'
  },
  combobox: {
    empty: 'Sin coincidencias',
    remove: 'Quitar {label}'
  },
  overlay: {
    label: 'Superposición'
  },
  window: {
    minimize: 'Minimizar',
    maximize: 'Maximizar',
    restore: 'Restaurar',
    resize: 'Cambiar el tamaño de la ventana'
  },
  layout: {
    skipToContent: 'Saltar al contenido',
    sidebar: 'Barra lateral',
    openSidebar: 'Abrir barra lateral',
    closeSidebar: 'Cerrar barra lateral',
    resizeSidebar: 'Redimensionar barra lateral'
  },
  code: {
    code: 'Código',
    copy: 'Copiar',
    copied: 'Copiado',
    copyFailed: 'No se pudo copiar',
    raw: 'Sin formato',
    prompt: 'Símbolo del sistema'
  },
  steps: {
    previous: 'Anterior',
    next: 'Siguiente',
    done: 'Hecho',
    skip: 'Omitir',
    restart: 'Empezar de nuevo',
    completed: 'Todos los pasos completados',
    steps: 'Pasos',
    position: '{index} de {total}',
    step: 'Paso {index}: {title}'
  }
};
