<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue';
import { useData } from 'vitepress';
import { basePath, localeOf, t } from '../../data/i18n';

/**
 * A live preview of a React component inside a Vue page.
 *
 * VitePress compiles Markdown to Vue, so `<Button />` cannot be written
 * directly. The bridge is the usual one: Vue owns a plain `<div>`, and React
 * takes it over with `createRoot()` once the page is in the browser.
 *
 * `src` names a file under `.vitepress/demos` without its extension, so
 * `<Demo src="button/variants" />` renders `demos/button/variants.tsx`. The
 * same path goes into the `<<<` snippet in the Markdown next to it, which is
 * how the code shown under a preview is guaranteed to be the code that ran.
 */
const props = defineProps({
  /** Demo module path, relative to `.vitepress/demos`, without `.tsx`. */
  src: { type: String, required: true },
  /** `center` for a single control that would look lost against a left edge. */
  align: { type: String, default: 'start' },
  /** Drops the frame — for previews that bring their own, like the index grid. */
  plain: { type: Boolean, default: false }
});

// Lazy on purpose: the map is built at compile time, but nothing is fetched
// until a demo is actually mounted, and nothing is pulled into the SSR build.
const demos = import.meta.glob('../../demos/**/*.tsx');

// `lang` says which language the page is; `localeIndex` says where it lives in
// the URL. They are different questions and only one of them is the default.
const { lang, localeIndex } = useData();
const locale = localeOf(lang.value);
const base = basePath(localeIndex.value);

const host = ref(null);
const open = ref(false);
let root = null;

onMounted(async () => {
  const key = `../../demos/${props.src}.tsx`;
  const load = demos[key];

  if (!load) {
    console.warn(`[neba docs] no demo at ${key}`);
    return;
  }

  const [React, { createRoot }, demo] = await Promise.all([
    import('react'),
    import('react-dom/client'),
    load()
  ]);

  // Navigating away during the await leaves nothing to mount into.
  if (!host.value) {
    return;
  }

  root = createRoot(host.value);
  // Demos are written in English and reused by every locale — they are code
  // samples. The few that carry docs chrome of their own (the component index)
  // take the locale and localise themselves.
  root.render(React.createElement(demo.default, { locale, base }));
});

onBeforeUnmount(() => {
  const mounted = root;
  root = null;

  // React refuses to unmount a root synchronously while it is rendering, and
  // client-side navigation tears the page down from inside Vue's own update.
  if (mounted) {
    setTimeout(() => mounted.unmount(), 0);
  }
});
</script>

<template>
  <div class="neba-demo" :class="{ 'neba-demo--plain': plain }">
    <div class="neba-demo-canvas" :data-align="align">
      <div ref="host" class="neba-scope neba-demo-mount" />
    </div>
    <div v-if="$slots.default" class="neba-demo-source">
      <button
        type="button"
        class="neba-demo-toggle"
        :aria-expanded="open ? 'true' : 'false'"
        @click="open = !open"
      >
        <span class="neba-demo-toggle-icon" :class="{ 'is-open': open }" aria-hidden="true">›</span>
        {{ open ? t(locale, 'hideCode') : t(locale, 'showCode') }}
      </button>
      <div v-show="open" class="neba-demo-code">
        <slot />
      </div>
    </div>
  </div>
</template>
