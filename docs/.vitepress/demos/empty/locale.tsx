import { Empty } from 'neba';

const LOCALES = ['en', 'ko', 'ja', 'fr', 'ar'];

export default function EmptyLocale() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      {LOCALES.map((locale) => (
        <Empty key={locale} variant="outline" size="sm" locale={locale} />
      ))}
    </div>
  );
}
