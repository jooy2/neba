<script setup>
import { computed, onMounted, ref } from 'vue';
import { useData } from 'vitepress';
import FrameworkMark from './FrameworkMark.vue';
import { framework, setFramework } from '../../data/framework';
import { DEFAULT_FRAMEWORK, FRAMEWORKS } from '../../data/frameworks';
import { localeOf, t } from '../../data/i18n';

/**
 * The framework switch, at the top of the sidebar.
 *
 * Above the menu rather than in the navbar, because it is not navigation: it
 * takes the reader nowhere and changes what the page they are on says. On a
 * phone the sidebar's drawer carries it along.
 *
 * A segmented control of two radios, hidden and labelled, rather than a row of
 * buttons: the radio group gives the arrow keys, the group semantics and the
 * focus behaviour without a roving tab index written by hand. Each option
 * carries its framework's mark beside its name; see `FrameworkMark.vue`.
 */
const { lang } = useData();
const locale = computed(() => localeOf(lang.value));

/*
 * The pre-rendered HTML has the default checked, because that is all a build
 * can know, and hydration keeps a `checked` the server wrote. So the first
 * render says the default too and `onMounted` corrects it as an ordinary
 * update. What the eye reads meanwhile comes from `html[data-fw]`, which the
 * head script set before the first paint.
 */
const hydrated = ref(false);

onMounted(() => {
  hydrated.value = true;
});

const checked = computed(() => (hydrated.value ? framework.value : DEFAULT_FRAMEWORK));
</script>

<template>
  <div class="neba-framework">
    <p id="neba-framework-label" class="neba-framework-title">
      {{ t(locale, 'frameworkLabel') }}
    </p>
    <div class="neba-framework-track" role="radiogroup" aria-labelledby="neba-framework-label">
      <label
        v-for="item in FRAMEWORKS"
        :key="item.id"
        class="neba-framework-option"
        :data-fw="item.id"
      >
        <input
          type="radio"
          name="neba-framework"
          :value="item.id"
          :checked="checked === item.id"
          @change="setFramework(item.id)"
        />
        <FrameworkMark :framework="item.id" />
        <span>{{ item.label }}</span>
      </label>
    </div>
  </div>
</template>
