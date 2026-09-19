import { ContextWindow } from 'neba';

const LOCALES = ['en-US', 'de-DE', 'ja-JP', 'ko-KR'];

export default function ContextWindowLocale() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      {LOCALES.map((locale) => (
        <ContextWindow
          key={locale}
          size="sm"
          locale={locale}
          label={locale}
          max={200_000}
          used={124_000}
          cost={0.42}
          breakdown={false}
        />
      ))}
    </div>
  );
}
