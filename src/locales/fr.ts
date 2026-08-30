/**
 * French.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, fr } from 'neba/locales';
 *
 * registerMessages('fr', fr);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const fr: NebaLocale = {
  action: {
    close: 'Fermer',
    dismiss: 'Ignorer',
    clear: 'Effacer',
    remove: 'Supprimer'
  },
  link: { newTab: '(s’ouvre dans un nouvel onglet)' },
  spoiler: {
    reveal: 'Afficher',
    hide: 'Masquer',
    notice: 'Peut contenir des spoilers'
  },
  chat: {
    sending: 'Envoi en cours',
    sent: 'Envoyé',
    delivered: 'Distribué',
    read: 'Lu',
    failed: 'Non envoyé',
    typing: 'En train d’écrire…'
  },
  empty: { title: 'Rien ici' },
  table: {
    search: 'Rechercher',
    selectAll: 'Sélectionner toutes les lignes',
    selectRow: 'Sélectionner la ligne',
    rowsPerPage: 'Lignes par page',
    range: '{start}–{end} sur {total}',
    selected: '{count} sélectionnées',
    empty: 'Aucune donnée'
  },
  color: {
    area: 'Saturation et luminosité',
    hue: 'Teinte',
    alpha: 'Opacité',
    value: 'Valeur de la couleur',
    swatches: 'Couleurs prédéfinies',
    clear: 'Effacer',
    empty: 'Choisir une couleur'
  },
  rating: {
    label: 'Note',
    value: '{value} sur {max}',
    empty: 'Aucune note'
  },
  number: {
    increase: 'Augmenter',
    decrease: 'Diminuer'
  },
  pagination: {
    label: 'Pagination',
    page: 'Page {page}',
    status: 'Page {page} sur {total}',
    previous: 'Page précédente',
    next: 'Page suivante',
    first: 'Première page',
    last: 'Dernière page'
  },
  carousel: {
    label: 'Carrousel',
    slide: 'Diapositive {index} sur {total}',
    previous: 'Diapositive précédente',
    next: 'Diapositive suivante'
  },
  chart: { label: 'Graphique' },
  scroll: {
    label: 'Contenu défilant',
    previous: 'Faire défiler vers l’arrière',
    next: 'Faire défiler vers l’avant'
  },
  breadcrumb: {
    label: 'Fil d’Ariane',
    expand: 'Afficher les étapes masquées'
  },
  anchor: { label: 'Sur cette page' },
  transfer: {
    source: 'Disponibles',
    target: 'Sélectionnés',
    toTarget: 'Déplacer vers les sélectionnés',
    toSource: 'Renvoyer vers les disponibles',
    search: 'Rechercher',
    selectAll: 'Tout sélectionner',
    empty: 'Rien ici'
  },
  command: {
    label: 'Palette de commandes',
    search: 'Tapez une commande ou recherchez…',
    empty: 'Aucune commande trouvée'
  },
  combobox: {
    empty: 'Aucun résultat',
    remove: 'Supprimer {label}'
  },
  overlay: {
    label: 'Superposition'
  },
  window: {
    minimize: 'Réduire',
    maximize: 'Agrandir',
    restore: 'Restaurer',
    resize: 'Redimensionner la fenêtre'
  },
  layout: {
    skipToContent: 'Aller au contenu',
    sidebar: 'Barre latérale',
    openSidebar: 'Ouvrir la barre latérale',
    closeSidebar: 'Fermer la barre latérale',
    resizeSidebar: 'Redimensionner la barre latérale'
  },
  code: {
    code: 'Code',
    copy: 'Copier',
    copied: 'Copié',
    copyFailed: 'Copie impossible',
    raw: 'Brut',
    prompt: 'Invite'
  },
  steps: {
    previous: 'Précédent',
    next: 'Suivant',
    done: 'Terminer',
    skip: 'Passer',
    restart: 'Recommencer',
    completed: 'Toutes les étapes sont terminées',
    steps: 'Étapes',
    position: '{index} sur {total}',
    step: 'Étape {index} : {title}'
  }
};
