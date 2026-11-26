<script setup>
/**
 * The mark beside a framework's name in the switch.
 *
 * Simplified outlines of each framework's own mark, drawn here, used only to
 * say which framework a choice is, and painted in `currentColor` so a mark
 * follows its label from muted to selected rather than carrying a palette of
 * its own into the sidebar.
 */
defineProps({
  framework: { type: String, required: true }
});
</script>

<template>
  <svg
    v-if="framework === 'react'"
    class="neba-framework-mark"
    viewBox="-12 -12 24 24"
    width="16"
    height="16"
    aria-hidden="true"
  >
    <circle r="2.2" fill="currentColor" />
    <g fill="none" stroke="currentColor" stroke-width="1.3">
      <ellipse rx="11" ry="4.2" />
      <ellipse rx="11" ry="4.2" transform="rotate(60)" />
      <ellipse rx="11" ry="4.2" transform="rotate(120)" />
    </g>
  </svg>
  <svg
    v-else-if="framework === 'flutter'"
    class="neba-framework-mark"
    viewBox="0 0 166 202"
    width="14"
    height="16"
    aria-hidden="true"
  >
    <path fill="currentColor" d="M38 129 10 101 100 10h56L38 129Z" />
    <path fill="currentColor" d="M156 94h-56l-48 49 48 49h56l-48-49 48-49Z" />
  </svg>
</template>
