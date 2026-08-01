import { Spoiler, Typography } from 'neba';

const LOCALES = ['en', 'ko', 'ja', 'zh-Hant', 'fr', 'ar'];

export default function SpoilerLocale() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-3 sm:grid-cols-2">
      {LOCALES.map((locale) => (
        <Spoiler key={locale} locale={locale} size="sm">
          <Typography level="caption">{locale}</Typography>
        </Spoiler>
      ))}
    </div>
  );
}
