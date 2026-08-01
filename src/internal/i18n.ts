/**
 * The words the library says on its own behalf.
 *
 * Almost nothing in Neba writes text a reader sees — a Button says whatever it
 * was handed, a Card's title is the caller's. The exceptions are the strings a
 * component has to invent because there is nowhere else for them to come from:
 * the sentence behind a link that opens a new tab, the label on the button that
 * uncovers a Spoiler, the word under a chat message that says it was read.
 *
 * Those are collected here rather than defaulted inside each component, for the
 * reason every other table in `internal/` exists: they are a set. A product in
 * Korean does not want eight components each defaulting to English and each
 * needing its own override prop, and the next component that needs a word —
 * a picker's "Today", a Pagination's "Next page" — should get it from the same
 * place rather than starting a second table beside this one.
 *
 * What is *not* in here is anything `Intl` already knows. Month names, weekday
 * names, AM/PM and number formats come from the platform, which speaks more
 * languages than this file ever will. This is only for the words the platform
 * has no opinion about.
 *
 * Every component that reads this takes a `locale` and an override prop for the
 * string itself, so an unsupported language is never a dead end: `locale` gets
 * you a translation for free, and the prop gets you one for anything else.
 */

import * as React from 'react';

/**
 * One namespace per component, rather than one flat list of keys.
 *
 * A namespace is what makes a partial translation possible: a locale supplies
 * whatever it has and the rest falls back to English one namespace at a time,
 * so adding a namespace here does not silently blank the strings in every
 * language that has not caught up with it yet.
 */
export interface NebaMessages {
  /** TextLink. */
  link: {
    /**
     * What is read out after a link that opens a new tab, and never drawn. A
     * window changing under the reader is the one thing about a link that is
     * invisible until it has already happened.
     */
    newTab: string;
  };
  /** Spoiler. */
  spoiler: {
    /** The button that uncovers the content. */
    reveal: string;
    /** And the one that covers it again, when the Spoiler is reversible. */
    hide: string;
    /** The line above the button, saying why the content is covered. */
    notice: string;
  };
  /** ChatBubble. */
  chat: {
    /** The four steps a message goes through, as the mark under it. */
    sending: string;
    sent: string;
    delivered: string;
    read: string;
    /** And the fifth, which is not a step: it did not go. */
    failed: string;
    /** What the three dots mean. */
    typing: string;
  };
}

/** A translation may fill in as much or as little of the table as it has. */
type PartialMessages = {
  [Namespace in keyof NebaMessages]?: Partial<NebaMessages[Namespace]>;
};

/**
 * English is the base, and the only entry that is complete by construction —
 * every other locale is merged over it, so a missing string is an English one
 * rather than an empty box.
 */
const base: NebaMessages = {
  link: {
    newTab: '(opens in a new tab)'
  },
  spoiler: {
    reveal: 'Reveal',
    hide: 'Hide',
    notice: 'This may contain spoilers'
  },
  chat: {
    sending: 'Sending',
    sent: 'Sent',
    delivered: 'Delivered',
    read: 'Read',
    failed: 'Not sent',
    typing: 'Typing…'
  }
};

/**
 * The translations, keyed by the lowercased tag they answer to.
 *
 * Chinese is keyed by script rather than by region, because that is the axis
 * the words actually differ on — `zh-TW` and `zh-HK` want the same characters
 * as each other and different ones from `zh-CN`. The regions are mapped onto
 * the two scripts below.
 */
const translations: Record<string, PartialMessages> = {
  ko: {
    link: { newTab: '(새 창에서 열림)' },
    spoiler: {
      reveal: '내용 보기',
      hide: '숨기기',
      notice: '스포일러가 포함되어 있을 수 있습니다'
    },
    chat: {
      sending: '보내는 중',
      sent: '보냄',
      delivered: '전달됨',
      read: '읽음',
      failed: '전송 실패',
      typing: '입력 중…'
    }
  },
  ja: {
    link: { newTab: '(新しいタブで開きます)' },
    spoiler: {
      reveal: '表示する',
      hide: '隠す',
      notice: 'ネタバレを含む可能性があります'
    },
    chat: {
      sending: '送信中',
      sent: '送信済み',
      delivered: '配信済み',
      read: '既読',
      failed: '送信できませんでした',
      typing: '入力中…'
    }
  },
  'zh-hans': {
    link: { newTab: '(在新标签页中打开)' },
    spoiler: {
      reveal: '显示内容',
      hide: '隐藏',
      notice: '此内容可能包含剧透'
    },
    chat: {
      sending: '发送中',
      sent: '已发送',
      delivered: '已送达',
      read: '已读',
      failed: '发送失败',
      typing: '正在输入…'
    }
  },
  'zh-hant': {
    link: { newTab: '(在新分頁中開啟)' },
    spoiler: {
      reveal: '顯示內容',
      hide: '隱藏',
      notice: '此內容可能包含劇透'
    },
    chat: {
      sending: '傳送中',
      sent: '已傳送',
      delivered: '已送達',
      read: '已讀',
      failed: '傳送失敗',
      typing: '正在輸入…'
    }
  },
  es: {
    link: { newTab: '(se abre en una pestaña nueva)' },
    spoiler: {
      reveal: 'Mostrar',
      hide: 'Ocultar',
      notice: 'Puede contener spoilers'
    },
    chat: {
      sending: 'Enviando',
      sent: 'Enviado',
      delivered: 'Entregado',
      read: 'Leído',
      failed: 'No enviado',
      typing: 'Escribiendo…'
    }
  },
  pt: {
    link: { newTab: '(abre em uma nova aba)' },
    spoiler: {
      reveal: 'Mostrar',
      hide: 'Ocultar',
      notice: 'Pode conter spoilers'
    },
    chat: {
      sending: 'Enviando',
      sent: 'Enviado',
      delivered: 'Entregue',
      read: 'Lido',
      failed: 'Não enviado',
      typing: 'Digitando…'
    }
  },
  fr: {
    link: { newTab: '(s’ouvre dans un nouvel onglet)' },
    spoiler: {
      reveal: 'Afficher',
      hide: 'Masquer',
      notice: 'Peut contenir des spoilers'
    },
    chat: {
      sending: 'Envoi en cours',
      sent: 'Envoyé',
      delivered: 'Distribué',
      read: 'Lu',
      failed: 'Non envoyé',
      typing: 'En train d’écrire…'
    }
  },
  de: {
    link: { newTab: '(wird in einem neuen Tab geöffnet)' },
    spoiler: {
      reveal: 'Anzeigen',
      hide: 'Ausblenden',
      notice: 'Kann Spoiler enthalten'
    },
    chat: {
      sending: 'Wird gesendet',
      sent: 'Gesendet',
      delivered: 'Zugestellt',
      read: 'Gelesen',
      failed: 'Nicht gesendet',
      typing: 'Schreibt…'
    }
  },
  it: {
    link: { newTab: '(si apre in una nuova scheda)' },
    spoiler: {
      reveal: 'Mostra',
      hide: 'Nascondi',
      notice: 'Può contenere spoiler'
    },
    chat: {
      sending: 'Invio in corso',
      sent: 'Inviato',
      delivered: 'Consegnato',
      read: 'Letto',
      failed: 'Non inviato',
      typing: 'Sta scrivendo…'
    }
  },
  nl: {
    link: { newTab: '(opent in een nieuw tabblad)' },
    spoiler: {
      reveal: 'Tonen',
      hide: 'Verbergen',
      notice: 'Kan spoilers bevatten'
    },
    chat: {
      sending: 'Wordt verzonden',
      sent: 'Verzonden',
      delivered: 'Afgeleverd',
      read: 'Gelezen',
      failed: 'Niet verzonden',
      typing: 'Aan het typen…'
    }
  },
  pl: {
    link: { newTab: '(otwiera się w nowej karcie)' },
    spoiler: {
      reveal: 'Pokaż',
      hide: 'Ukryj',
      notice: 'Może zawierać spoilery'
    },
    chat: {
      sending: 'Wysyłanie',
      sent: 'Wysłano',
      delivered: 'Dostarczono',
      read: 'Przeczytano',
      failed: 'Nie wysłano',
      typing: 'Pisze…'
    }
  },
  ru: {
    link: { newTab: '(откроется в новой вкладке)' },
    spoiler: {
      reveal: 'Показать',
      hide: 'Скрыть',
      notice: 'Может содержать спойлеры'
    },
    chat: {
      sending: 'Отправляется',
      sent: 'Отправлено',
      delivered: 'Доставлено',
      read: 'Прочитано',
      failed: 'Не отправлено',
      typing: 'Печатает…'
    }
  },
  tr: {
    link: { newTab: '(yeni sekmede açılır)' },
    spoiler: {
      reveal: 'Göster',
      hide: 'Gizle',
      notice: 'Spoiler içerebilir'
    },
    chat: {
      sending: 'Gönderiliyor',
      sent: 'Gönderildi',
      delivered: 'İletildi',
      read: 'Okundu',
      failed: 'Gönderilemedi',
      typing: 'Yazıyor…'
    }
  },
  ar: {
    link: { newTab: '(يفتح في علامة تبويب جديدة)' },
    spoiler: {
      reveal: 'إظهار',
      hide: 'إخفاء',
      notice: 'قد يحتوي على حرق للأحداث'
    },
    chat: {
      sending: 'جارٍ الإرسال',
      sent: 'تم الإرسال',
      delivered: 'تم التسليم',
      read: 'تمت القراءة',
      failed: 'لم يتم الإرسال',
      typing: 'يكتب الآن…'
    }
  },
  hi: {
    link: { newTab: '(नए टैब में खुलता है)' },
    spoiler: {
      reveal: 'दिखाएँ',
      hide: 'छिपाएँ',
      notice: 'इसमें स्पॉइलर हो सकते हैं'
    },
    chat: {
      sending: 'भेजा जा रहा है',
      sent: 'भेजा गया',
      delivered: 'डिलीवर हुआ',
      read: 'पढ़ा गया',
      failed: 'नहीं भेजा गया',
      typing: 'टाइप कर रहे हैं…'
    }
  },
  id: {
    link: { newTab: '(terbuka di tab baru)' },
    spoiler: {
      reveal: 'Tampilkan',
      hide: 'Sembunyikan',
      notice: 'Mungkin mengandung spoiler'
    },
    chat: {
      sending: 'Mengirim',
      sent: 'Terkirim',
      delivered: 'Diterima',
      read: 'Dibaca',
      failed: 'Gagal terkirim',
      typing: 'Sedang mengetik…'
    }
  },
  vi: {
    link: { newTab: '(mở trong tab mới)' },
    spoiler: {
      reveal: 'Hiện nội dung',
      hide: 'Ẩn',
      notice: 'Có thể chứa nội dung tiết lộ'
    },
    chat: {
      sending: 'Đang gửi',
      sent: 'Đã gửi',
      delivered: 'Đã nhận',
      read: 'Đã xem',
      failed: 'Chưa gửi được',
      typing: 'Đang nhập…'
    }
  },
  th: {
    link: { newTab: '(เปิดในแท็บใหม่)' },
    spoiler: {
      reveal: 'แสดงเนื้อหา',
      hide: 'ซ่อน',
      notice: 'อาจมีการเปิดเผยเนื้อหา'
    },
    chat: {
      sending: 'กำลังส่ง',
      sent: 'ส่งแล้ว',
      delivered: 'ส่งถึงแล้ว',
      read: 'อ่านแล้ว',
      failed: 'ส่งไม่สำเร็จ',
      typing: 'กำลังพิมพ์…'
    }
  }
};

/**
 * The tags that are a different spelling of an entry above.
 *
 * Only the Chinese ones for now, and they are the reason the table is keyed by
 * script: a reader in Taipei asking for `zh-TW` and one in Hong Kong asking for
 * `zh-HK` want the same words, and a table keyed by region would hold that pair
 * twice. Bare `zh` resolves to Simplified, which is what every other library
 * that has had to pick one has picked.
 */
const aliases: Record<string, string> = {
  zh: 'zh-hans',
  'zh-cn': 'zh-hans',
  'zh-my': 'zh-hans',
  'zh-sg': 'zh-hans',
  'zh-hk': 'zh-hant',
  'zh-mo': 'zh-hant',
  'zh-tw': 'zh-hant'
};

/**
 * A BCP 47 tag, broadest match last.
 *
 * `zh-Hant-TW` asks for `zh-hant`, then `zh-tw`, then `zh`; `pt-BR` asks for
 * `pt-br` and then `pt`. The subtags are found by shape rather than by
 * position, because a tag can carry an extension or a variant between them and
 * `split('-')[1]` would take that for the script.
 */
function candidates(locale: string): string[] {
  const subtags = locale.toLowerCase().split(/[-_]/).filter(Boolean);
  const language = subtags[0];

  if (!language) {
    return [];
  }

  const rest = subtags.slice(1);
  const script = rest.find((subtag) => /^[a-z]{4}$/.test(subtag));
  const region = rest.find((subtag) => /^([a-z]{2}|\d{3})$/.test(subtag));

  return [
    script ? `${language}-${script}` : '',
    region ? `${language}-${region}` : '',
    language
  ].filter(Boolean);
}

/**
 * Resolved tables, keyed by the tag that was asked for.
 *
 * A module-level cache rather than a `useMemo` per component: the merge is the
 * same work for every ChatBubble in a thread, and a thread is where this gets
 * called a hundred times.
 */
const resolved = new Map<string, NebaMessages>([['', base]]);

/**
 * The strings for a locale, merged over English.
 *
 * `undefined` is English rather than the runtime's own locale, and that is
 * deliberate: `navigator.language` differs between the server that renders the
 * markup and the browser that hydrates it, and text that changes between those
 * two is a hydration mismatch in the one part of the page a reader is looking
 * at. A component that should follow the reader is told which language to
 * follow.
 */
export function resolveMessages(locale?: string): NebaMessages {
  const key = locale?.trim() ?? '';
  const cached = resolved.get(key);

  if (cached) {
    return cached;
  }

  const match = candidates(key)
    .map((candidate) => translations[candidate] ?? translations[aliases[candidate] ?? ''])
    .find(Boolean);

  const messages: NebaMessages = match
    ? {
        link: { ...base.link, ...match.link },
        spoiler: { ...base.spoiler, ...match.spoiler },
        chat: { ...base.chat, ...match.chat }
      }
    : base;

  resolved.set(key, messages);

  return messages;
}

/** The same, as a hook, for the components that read it during a render. */
export function useMessages(locale?: string): NebaMessages {
  return React.useMemo(() => resolveMessages(locale), [locale]);
}
