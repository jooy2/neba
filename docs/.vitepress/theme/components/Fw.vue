<script setup>
import { computed, useAttrs } from 'vue';
import { FRAMEWORKS } from '../../data/frameworks';

/**
 * The inline half of `::: fw`: a few words that differ inside a sentence that
 * does not.
 *
 * `<Fw react="onClick" flutter="onPressed" code />`
 *
 * A container cannot do this, because `:::` is a block, and splitting a
 * sentence into two blocks to swap one name in it leaves two paragraphs where
 * there was one. Anything longer than a phrase belongs in the block form.
 *
 * Each framework's text is an attribute named after its id, read off `$attrs`
 * so that adding a framework stays an entry in `data/frameworks.ts`. A
 * framework given nothing renders nothing, which is how a clause only one of
 * them has is written.
 *
 * Inside a phrase an identifier is written as Markdown writes it, between
 * backticks, and drawn as `<code>`. The text is split into plain and code parts
 * rather than handed to `v-html`, so nothing in an attribute becomes markup.
 * With `code`, the whole variant is one `<code>`.
 *
 * A heading written as one of these takes its anchor from the default
 * framework's text; see `headingText` in `config.ts`.
 */
defineOptions({ inheritAttrs: false });

defineProps({
  /** Renders each variant as `<code>`, for a prop or an identifier. */
  code: { type: Boolean, default: false }
});

const attrs = useAttrs();
const codeSpan = /`([^`]+)`/g;

function partsOf(text) {
  const parts = [];
  let from = 0;

  for (const match of text.matchAll(codeSpan)) {
    if (match.index > from) {
      parts.push({ code: false, text: text.slice(from, match.index) });
    }

    parts.push({ code: true, text: match[1] });
    from = match.index + match[0].length;
  }

  if (from < text.length) {
    parts.push({ code: false, text: text.slice(from) });
  }

  return parts;
}

const variants = computed(() =>
  FRAMEWORKS.filter((item) => attrs[item.id] !== undefined).map((item) => {
    const text = String(attrs[item.id]);

    return { id: item.id, text, parts: partsOf(text) };
  })
);
</script>

<template>
  <template v-for="(variant, at) in variants" :key="variant.id">
    <!-- Never displayed. It is for whatever reads the text rather than the
         page, the search index above all, which would otherwise run the
         variants together into one word that matches neither. -->
    <span v-if="at > 0" class="neba-fw-sep" aria-hidden="true"> / </span>
    <code v-if="code" class="neba-fw" :data-fw="variant.id">{{ variant.text }}</code>
    <span v-else class="neba-fw" :data-fw="variant.id">
      <template v-for="(part, index) in variant.parts" :key="index">
        <code v-if="part.code">{{ part.text }}</code>
        <template v-else>{{ part.text }}</template>
      </template>
    </span>
  </template>
</template>
