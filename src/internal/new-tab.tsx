'use client';

import * as React from 'react';
import { DefaultsContext } from './defaults.js';
import { linkMessages, useMessages } from './i18n.js';
import { opensElsewhere } from './link.js';
import { srOnlyClasses } from './styles.js';

/**
 * The words a link that opens somewhere other than this tab ends with, drawn
 * for nobody and read to everybody.
 *
 * A window changing under the reader is the one thing about a link that is
 * invisible until it has already happened, and TextLink was the only link in
 * the library that said so. Every other component that lets a `target` reach an
 * `<a>` puts this last inside it. The space is a real text node, so the name
 * comes out as the label and then the sentence rather than as one word.
 *
 * The language is the component's own `locale` where it has one, and the
 * provider's where it has not — a Menu row or a NavigationMenu link takes no
 * `locale` of its own.
 */
export function NewTabNote({ target, locale }: { target: string | undefined; locale?: string }) {
  const provided = React.useContext(DefaultsContext);
  const messages = useMessages(linkMessages, locale ?? provided?.locale);

  if (!opensElsewhere(target)) {
    return null;
  }

  return (
    <>
      {' '}
      <span className={srOnlyClasses}>{messages.newTab}</span>
    </>
  );
}
