<script>
/*
 * Module scope, deliberately: a `<script setup>` body runs once per component
 * instance, and a component page carries a dozen <Demo>s. Everything shared by
 * all of them lives here instead.
 */

// Lazy on purpose: the map is built at compile time, but nothing is fetched
// until a demo is actually mounted, and nothing is pulled into the SSR build.
const demos = import.meta.glob('../../demos/**/*.tsx');

let runtime = null;

/** React and its DOM renderer, fetched once and shared by every preview. */
function reactRuntime() {
  runtime ??= Promise.all([import('react'), import('react-dom/client')]);

  return runtime;
}

/*
 * Started here rather than in a preview's `onMounted`, which is what it used to
 * be. Together the two are the largest thing the page downloads, nothing can
 * render until they arrive, and a dynamic import inside a lifecycle hook only
 * begins once hydration is done — so the browser sat idle through hydration and
 * then went to the network. Evaluating this module is the earliest moment the
 * fetch can start, and it costs nothing on a page that turns out to have no
 * previews, since the same promise is what every preview then awaits.
 */
if (!import.meta.env.SSR) {
  reactRuntime();
}

/**
 * How far outside the viewport a preview counts as worth mounting, in px.
 * Wide enough that scrolling reaches a mounted preview rather than an empty box.
 */
const MOUNT_MARGIN = 300;
</script>

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
  plain: { type: Boolean, default: false },
  /**
   * Height the mount point holds, in px or as a CSS length.
   *
   * The box is empty until React is in the browser, so without this the page
   * reflows under the reader the moment a preview arrives. It stays applied
   * after mounting too: a reserve that is dropped once the content is there
   * moves the page a second time, which is the same jump twice.
   */
  minHeight: { type: [Number, String], default: 40 }
});

// `lang` says which language the page is; `localeIndex` says where it lives in
// the URL. They are different questions and only one of them is the default.
const { lang, localeIndex } = useData();
const locale = localeOf(lang.value);
const base = basePath(localeIndex.value);

const host = ref(null);
const open = ref(false);
let root = null;
let observer = null;

async function mount() {
  const key = `../../demos/${props.src}.tsx`;
  const load = demos[key];

  if (!load) {
    console.warn(`[neba docs] no demo at ${key}`);
    return;
  }

  // The demo's own chunk is fetched alongside React rather than after it: it
  // pulls in the components it renders, which is the other half of the payload.
  const [[React, { createRoot }], demo] = await Promise.all([reactRuntime(), load()]);

  // Navigating away during the await leaves nothing to mount into.
  if (!host.value) {
    return;
  }

  root = createRoot(host.value);
  // Demos are written in English and reused by every locale — they are code
  // samples. The few that carry docs chrome of their own (the component index)
  // take the locale and localise themselves.
  root.render(React.createElement(demo.default, { locale, base }));
}

/** Whether the mount point is on screen, or close enough to count. */
function isNear() {
  const { top, bottom } = host.value.getBoundingClientRect();

  return top < window.innerHeight + MOUNT_MARGIN && bottom > -MOUNT_MARGIN;
}

onMounted(() => {
  /*
   * A component page holds a dozen previews and every one of them used to mount
   * at the same moment, so the preview being read waited its turn behind chunks
   * for previews far below the fold. Only what is on screen mounts now.
   *
   * What is already visible is measured rather than observed: an
   * IntersectionObserver reports its first entry in a later task, and the
   * preview at the top of the page — the one the reader is waiting for — is
   * exactly what that task would delay.
   */
  if (typeof IntersectionObserver === 'undefined' || isNear()) {
    mount();
    return;
  }

  observer = new IntersectionObserver(
    (entries) => {
      if (!entries.some((entry) => entry.isIntersecting)) {
        return;
      }

      observer.disconnect();
      observer = null;
      mount();
    },
    { rootMargin: `${MOUNT_MARGIN}px 0px` }
  );

  observer.observe(host.value);
});

onBeforeUnmount(() => {
  const mounted = root;
  root = null;

  observer?.disconnect();
  observer = null;

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
      <div
        ref="host"
        class="neba-scope neba-demo-mount"
        :style="{ minHeight: typeof minHeight === 'number' ? `${minHeight}px` : minHeight }"
      />
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
