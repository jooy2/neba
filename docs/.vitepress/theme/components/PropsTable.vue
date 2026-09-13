<script setup>
import { computed } from 'vue';
import { useData } from 'vitepress';
import { localeOf, t } from '../../data/i18n';
import { propTables } from '../../data/props';

/**
 * Renders one component's props table from `data/props.ts`.
 *
 * `<PropsTable name="Button" />`
 */
const props = defineProps({
  name: { type: String, required: true }
});

const { lang } = useData();
const locale = computed(() => localeOf(lang.value));
const rows = computed(() => propTables[props.name] ?? []);
const hasRequired = computed(() => rows.value.some((row) => row.required));
</script>

<template>
  <div class="neba-props">
    <table>
      <thead>
        <tr>
          <th>{{ t(locale, 'propColumn') }}</th>
          <th>{{ t(locale, 'typeColumn') }}</th>
          <th>{{ t(locale, 'defaultColumn') }}</th>
          <th>{{ t(locale, 'descriptionColumn') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in rows" :key="row.name">
          <td>
            <span class="neba-props-name">{{ row.name }}</span>
            <!-- The star is for the eye, and a `title` reaches neither a screen
                 reader nor a finger: the word is said to one, and the legend
                 under the table says it to the other. -->
            <template v-if="row.required">
              <span class="neba-props-required" aria-hidden="true">*</span>
              <span class="neba-props-hidden">{{ t(locale, 'required') }}</span>
            </template>
            <span v-if="row.shared" class="neba-props-shared" :title="t(locale, 'sharedTitle')">
              {{ t(locale, 'sharedTag') }}
            </span>
          </td>
          <td class="neba-props-type">{{ row.type }}</td>
          <td class="neba-props-default">{{ row.default ?? '—' }}</td>
          <td class="neba-props-desc">{{ row.description[locale] }}</td>
        </tr>
      </tbody>
    </table>
    <p v-if="hasRequired" class="neba-props-legend" aria-hidden="true">
      <span class="neba-props-required">*</span> {{ t(locale, 'required') }}
    </p>
  </div>
</template>
