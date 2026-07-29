import { Highlight } from 'neba';

export default function HighlightMatching() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4 text-[0.8125rem]/[1.6]">
      {/* Several terms at once. The longest is tried first, so `database` wins
          over `data` rather than leaving `base` outside the mark. */}
      <Highlight query={['data', 'database']}>
        One data row in one database, and the data it holds.
      </Highlight>

      {/* Case, which is off by default. */}
      <Highlight query="fox" caseSensitive color="primary">
        Fox, FOX and fox are three different words to a case-sensitive search.
      </Highlight>

      {/* Whole words, which is what stops `cat` marking `concatenate`. */}
      <Highlight query="cat" wholeWord color="success">
        A cat that concatenates is still a cat.
      </Highlight>

      {/* A regular expression, used as written. */}
      <Highlight query={/\b[A-Z]{2,}\b/} color="danger">
        HTTP and TLS are acronyms; Http and Tls are not.
      </Highlight>
    </div>
  );
}
