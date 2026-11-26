<script setup>
import { computed } from 'vue';
import { useData } from 'vitepress';
import { localeOf, t } from '../../data/i18n';
import { propTables } from '../../data/props';
import { flutterPropTables } from '../../data/props-flutter';

/**
 * Renders one component's props tables: the React one from `data/props.ts`,
 * and the Flutter one from `data/props-flutter/`.
 *
 * `<PropsTable name="Button" />`
 *
 * Both are in the page, each inside a `.neba-fw` block, and the framework
 * switch displays one. A component the Flutter package does not have yet says
 * so in the Flutter half instead of showing nothing.
 */
const props = defineProps({
  name: { type: String, required: true }
});

const { lang } = useData();
const locale = computed(() => localeOf(lang.value));

const tables = computed(() => [
  { framework: 'react', rows: propTables[props.name] ?? [] },
  { framework: 'flutter', rows: flutterPropTables[props.name] ?? null }
]);

/** A default written in words has one per locale; a code value is the same in both. */
function defaultOf(row) {
  if (row.default === undefined) return '—';
  return typeof row.default === 'string' ? row.default : row.default[locale.value];
}
</script>

<template>
  <div
    v-for="table in tables"
    :key="table.framework"
    class="neba-props neba-fw"
    :data-fw="table.framework"
  >
    <p v-if="table.rows === null" class="neba-props-pending">
      {{ t(locale, 'flutterPropsPending') }}
    </p>
    <template v-else>
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
          <tr v-for="row in table.rows" :key="row.name">
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
            <td class="neba-props-default">{{ defaultOf(row) }}</td>
            <td class="neba-props-desc">{{ row.description[locale] }}</td>
          </tr>
        </tbody>
      </table>
      <p v-if="table.rows.some((row) => row.required)" class="neba-props-legend" aria-hidden="true">
        <span class="neba-props-required">*</span> {{ t(locale, 'required') }}
      </p>
    </template>
  </div>
</template>
