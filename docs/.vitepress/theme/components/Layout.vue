<script setup>
import { computed, nextTick, onMounted, watch } from 'vue';
import DefaultTheme from 'vitepress/theme';
import { onContentUpdated, useData, withBase } from 'vitepress';
import Demo from './Demo.vue';
import FrameworkSelect from './FrameworkSelect.vue';
import { framework } from '../../data/framework';
import { localeOf, t } from '../../data/i18n';

/**
 * The default layout with what the site adds to it.
 *
 * On the home page, the mark above the hero's title and a hero "image" that is
 * a live composition of the library's own components rather than a picture.
 * The image slot only renders when the frontmatter declares `hero.image`, so
 * the home pages keep an `image` entry even though nothing of it is drawn. The
 * mark is the 256px source at a third of its size, which keeps it crisp on a
 * retina screen; `width` and `height` are on the tag so the hero does not jump.
 *
 * On every other page, the framework switch at the top of the sidebar, and on
 * a component page the Flutter package does not have yet, a note in the
 * page's Flutter half saying so. A page says it has been ported with
 * `flutter: true` in its frontmatter.
 */
const { Layout } = DefaultTheme;
const { lang, page, frontmatter, theme } = useData();
const locale = computed(() => localeOf(lang.value));

// `components/inputs/button.md` in the default locale, which is served from
// the root, and `ko/components/inputs/button.md` in the others.
const isComponentPage = computed(() =>
  /(^|\/)components\/[^/]+\/[^/]+\.md$/.test(page.value.relativePath)
);
const flutterPending = computed(() => isComponentPage.value && frontmatter.value.flutter !== true);
const roadmap = computed(() => {
  const github = theme.value.socialLinks?.find((link) => link.icon === 'github')?.link;

  return github ? `${github}/blob/main/TODO.md` : null;
});

/**
 * Fits the outline to the framework the reader chose.
 *
 * The outline is built once per page from every heading in it, and both
 * halves of a `::: fw` pair are in the page. So an entry whose heading sits in
 * the hidden half is hidden, and an entry whose heading is an `<Fw>` phrase is
 * renamed to the half that is shown; VitePress would otherwise list both names
 * with a slash between them. Rerun when the framework changes and after every
 * page the outline is rebuilt for.
 */
function fitOutline() {
  for (const link of document.querySelectorAll('.VPDocAsideOutline .outline-link')) {
    const id = decodeURIComponent(link.getAttribute('href')?.slice(1) ?? '');
    const heading = id ? document.getElementById(id) : null;
    const block = heading?.closest('.neba-fw');
    const item = link.closest('li');

    if (item) {
      item.hidden = Boolean(block) && getComputedStyle(block).display === 'none';
    }

    if (heading?.querySelector('.neba-fw')) {
      link.textContent = heading.innerText.replace(/\u200b/g, '').trim();
    }
  }
}

/**
 * After the outline has rendered: its own update lands on the next tick, and a
 * timeout runs after that one. Not `requestAnimationFrame`, which a browser
 * holds back in a tab that is not showing.
 */
function scheduleFit() {
  nextTick(() => setTimeout(fitOutline));
}

onMounted(scheduleFit);
onContentUpdated(scheduleFit);
watch(framework, scheduleFit);
</script>

<template>
  <Layout>
    <template #sidebar-nav-before>
      <FrameworkSelect />
    </template>
    <template #doc-before>
      <div v-if="flutterPending" class="neba-fw neba-flutter-pending" data-fw="flutter">
        {{ t(locale, 'flutterPending') }}
        <a v-if="roadmap" :href="roadmap" target="_blank" rel="noopener noreferrer">
          {{ t(locale, 'flutterPendingLink') }}
        </a>
      </div>
    </template>
    <template #home-hero-info-before>
      <img
        class="neba-home-logo"
        :src="withBase('/256x256.png')"
        alt="Neba"
        width="96"
        height="96"
        fetchpriority="high"
      />
    </template>
    <template #home-hero-image>
      <Demo class="neba-home-hero" src="home/hero" plain />
    </template>
  </Layout>
</template>
