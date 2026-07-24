<script setup>
import DefaultTheme from 'vitepress/theme';
import Demo from './Demo.vue';

/**
 * The default layout with one thing swapped: the home page's hero image is a
 * live composition of the library's own components rather than a picture.
 *
 * The slot only renders when the frontmatter declares `hero.image`, so the
 * home pages keep an `image` entry even though nothing of it is drawn.
 */
const { Layout } = DefaultTheme;
</script>

<template>
  <Layout>
    <template #home-hero-image>
      <Demo class="neba-home-hero" src="home/hero" plain />
    </template>
  </Layout>
</template>
