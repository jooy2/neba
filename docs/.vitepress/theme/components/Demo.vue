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

/**
 * How far outside the viewport a preview counts as worth mounting, in px.
 * Wide enough that scrolling reaches a mounted preview rather than an empty box.
 */
const MOUNT_MARGIN = 300;

/** The channel the Flutter gallery and this page talk on. `host_bridge_web.dart` agrees. */
const CHANNEL = 'neba-demo';

let flutterList = null;

/**
 * The demos the Flutter gallery has, from the `demos.json` that
 * `scripts/build-flutter-demos.mjs` writes beside the build. Fetched once, and
 * only for a reader on Flutter. A site built without Flutter has no file, and
 * every preview stays the React one.
 */
function flutterDemos(url) {
  flutterList ??= fetch(url)
    .then((response) => (response.ok ? response.json() : []))
    .catch(() => [])
    .then((keys) => new Set(keys));

  return flutterList;
}
</script>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch, watchEffect } from 'vue';
import { useData, withBase } from 'vitepress';
import { framework } from '../../data/framework';
import { basePath, localeOf, t } from '../../data/i18n';

/**
 * A live preview of a React component inside a Vue page.
 *
 * VitePress compiles Markdown to Vue, so `<Button />` cannot be written
 * directly. The bridge is the usual one: Vue owns a plain `<div>`, and React
 * takes it over with `createRoot()` once the page is in the browser.
 *
 * On Flutter, a demo the Flutter gallery also has is shown as that instead: an
 * iframe of `public/flutter` with `?demo=<src>`, sized to the height the
 * gallery reports and themed by message, so one `<Demo src>` names both. A
 * demo with no Dart twin stays the React one, which the page's note about an
 * unported component already says.
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
   * Keeps VitePress's router out of the preview's links.
   *
   * The router listens for a click on `window` in the capture phase, so it sees
   * every `<a>` in the page before React does, and for a same-page `#fragment`
   * it prevents the default and scrolls the *window* to the heading. In an
   * Anchor preview that is exactly wrong twice over: the page moves, and the
   * box the headings are actually in does not. `vp-raw` is the router's own
   * opt-out — it skips any link inside one — and it is not applied to every
   * preview because most of the demos that carry links point at real docs
   * pages, which the router is what keeps as SPA navigation rather than a full
   * page load.
   */
  raw: { type: Boolean, default: false },
  /**
   * Height the mount point holds, in px or as a CSS length.
   *
   * The box is empty until React is in the browser, so without this the page
   * reflows under the reader the moment a preview arrives. It stays applied
   * after mounting too: a reserve that is dropped once the content is there
   * moves the page a second time, which is the same jump twice.
   *
   * A Flutter preview's frame keeps it as a floor under the height the gallery
   * reports. A popup the gallery opens is drawn inside the frame, where a
   * React one is drawn over the page, so a preview that opens one asks for the
   * room it needs here.
   */
  minHeight: { type: [Number, String], default: 40 },
  /**
   * The least height of the Flutter preview, in px or as a CSS length, in
   * place of `minHeight`, which it otherwise is.
   *
   * For a demo that opens a surface over the window, such as a Drawer. A React
   * preview opens it over the whole page; a Flutter one can only open it over
   * its own frame, which is otherwise as tall as the buttons that open it. Set
   * here, the room is the Flutter frame's alone and a React preview keeps its
   * own height.
   */
  frameMinHeight: { type: [Number, String], default: 0 }
});

// `lang` says which language the page is; `localeIndex` says where it lives in
// the URL. They are different questions and only one of them is the default.
const { isDark, lang, localeIndex } = useData();
const locale = localeOf(lang.value);
const base = basePath(localeIndex.value);

/*
 * The reserve and the frame's floor, as CSS lengths. A bare number is pixels
 * whichever way it was written: `min-height="380"` in Markdown is a static
 * attribute and arrives as the string "380", which as `min-height: 380` is no
 * length at all — the browser dropped it, and a hundred and five previews
 * reserved nothing.
 */
const toLength = (value) => (/^\d+(\.\d+)?$/.test(String(value)) ? `${value}px` : value);
const reserve = computed(() => toLength(props.minHeight));
const frameFloor = computed(() =>
  props.frameMinHeight ? toLength(props.frameMinHeight) : reserve.value
);

const host = ref(null);
const open = ref(false);
let root = null;
let observer = null;

/*
 * Started as a preview is set up rather than in its `onMounted`. Together the
 * two are the largest thing the page downloads, nothing can render until they
 * arrive, and a dynamic import inside a lifecycle hook only begins once
 * hydration is done — so the browser sat idle through hydration and then went
 * to the network. Setup runs during hydration, which is early enough. It is not
 * started when this module is evaluated, because the theme imports this file on
 * every page, and a page with no previews has no use for React.
 */
if (!import.meta.env.SSR) {
  reactRuntime();
}

/*
 * Which theme this one preview is in, and it is a *deviation* rather than a
 * value: `null` means "whatever the page is", so an untouched preview carries
 * no theme root at all and a reader flipping the site switch takes every
 * preview with them. Only once someone asks for the other one does the canvas
 * become a theme root of its own — which is all it takes, since `styles.css`
 * declares both themes on `[data-theme]` as well as on `:root`.
 */
const override = ref(null);
const pageTheme = computed(() => (isDark.value ? 'dark' : 'light'));
const theme = computed(() => override.value ?? pageTheme.value);

function flip() {
  const next = theme.value === 'dark' ? 'light' : 'dark';

  // Landing back on the page's own theme drops the override instead of pinning
  // it, so the preview rejoins the site switch rather than quietly ignoring it.
  override.value = next === pageTheme.value ? null : next;
}

async function mountReact() {
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

/*
 * The framework this preview is drawn in. Everything here waits for the
 * component to mount, so the first render is the server's, whose HTML only
 * ever has the React mount point in it.
 */
const hydrated = ref(false);
const near = ref(false);
const reactStarted = ref(false);
/** `null` until the gallery's list has answered for this demo. */
const inGallery = ref(null);
const wantsFlutter = computed(
  () => hydrated.value && framework.value === 'flutter' && !props.plain
);
const useFrame = computed(() => wantsFlutter.value && inGallery.value === true);
const frame = ref(null);
const frameUrl = ref(null);
const frameHeight = ref(null);

watch(
  wantsFlutter,
  async (wanted) => {
    if (!wanted || inGallery.value !== null) {
      return;
    }

    const keys = await flutterDemos(withBase('/flutter/demos.json'));
    inGallery.value = keys.has(props.src);
  },
  { immediate: true }
);

/*
 * Mounts whichever half is wanted once the preview is near the screen, and
 * waits while a Flutter reader's list is still on its way, so that a page
 * whose demos are all in the gallery does not boot React for nothing.
 */
watchEffect(() => {
  if (!near.value || (wantsFlutter.value && inGallery.value === null)) {
    return;
  }

  if (useFrame.value) {
    frameUrl.value ??=
      `${withBase('/flutter/index.html')}?demo=${encodeURIComponent(props.src)}` +
      `&theme=${theme.value}&align=${props.align}`;
  } else if (!reactStarted.value) {
    reactStarted.value = true;
    mountReact();
  }
});

/** The gallery's height reports, from this preview's own frame only. */
function onMessage(event) {
  const data = event.data;

  if (
    event.origin !== window.location.origin ||
    event.source !== frame.value?.contentWindow ||
    data?.channel !== CHANNEL ||
    data.type !== 'size'
  ) {
    return;
  }

  frameHeight.value = Math.ceil(data.height);
}

watch(theme, (next) => {
  frame.value?.contentWindow?.postMessage(
    { channel: CHANNEL, type: 'theme', theme: next },
    window.location.origin
  );
});

onMounted(() => {
  hydrated.value = true;
  window.addEventListener('message', onMessage);

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
    near.value = true;
    return;
  }

  observer = new IntersectionObserver(
    (entries) => {
      if (!entries.some((entry) => entry.isIntersecting)) {
        return;
      }

      observer.disconnect();
      observer = null;
      near.value = true;
    },
    { rootMargin: `${MOUNT_MARGIN}px 0px` }
  );

  observer.observe(host.value);
});

onBeforeUnmount(() => {
  window.removeEventListener('message', onMessage);
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
  <div class="neba-demo" :class="{ 'neba-demo--plain': plain, 'vp-raw': raw }">
    <div
      class="neba-demo-canvas"
      :class="{ 'neba-demo-canvas--frame': useFrame }"
      :data-align="align"
      :data-theme="override"
    >
      <button
        v-if="!plain"
        type="button"
        class="neba-demo-theme"
        :title="t(locale, theme === 'dark' ? 'viewLight' : 'viewDark')"
        :aria-label="t(locale, theme === 'dark' ? 'viewLight' : 'viewDark')"
        @click="flip"
      >
        <svg
          v-if="theme === 'dark'"
          viewBox="0 0 16 16"
          width="15"
          height="15"
          fill="none"
          stroke="currentColor"
          stroke-width="1.4"
          stroke-linecap="round"
          aria-hidden="true"
        >
          <circle cx="8" cy="8" r="3" />
          <path
            d="M8 1.4v1.3M8 13.3v1.3M1.4 8h1.3M13.3 8h1.3M3.4 3.4l.9.9M11.7 11.7l.9.9M12.6 3.4l-.9.9M4.3 11.7l-.9.9"
          />
        </svg>
        <svg
          v-else
          viewBox="0 0 16 16"
          width="15"
          height="15"
          fill="none"
          stroke="currentColor"
          stroke-width="1.4"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="M13.4 10.1A5.7 5.7 0 0 1 5.9 2.6a5.7 5.7 0 1 0 7.5 7.5Z" />
        </svg>
      </button>
      <div
        v-show="!useFrame"
        ref="host"
        class="neba-scope neba-demo-mount"
        :style="{ minHeight: reserve }"
      />
      <iframe
        v-if="useFrame && frameUrl"
        ref="frame"
        class="neba-demo-frame"
        :src="frameUrl"
        :title="t(locale, 'flutterFrame')"
        :style="{
          height: frameHeight ? `max(${frameHeight}px, ${frameFloor})` : reserve,
          minHeight: frameFloor
        }"
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
