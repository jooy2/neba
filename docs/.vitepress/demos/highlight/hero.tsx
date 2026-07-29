import { useState } from 'react';
import { Highlight, TextField } from 'neba';

const results = [
  'Acrylic surfaces and the light that lands on them',
  'A control never moves: colour and depth carry every state',
  'Translucency is tuned with the blur radius, not the alpha'
];

export default function HighlightHero() {
  const [query, setQuery] = useState('a control');

  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <TextField
        label="Search"
        value={query}
        onChange={(event) => setQuery(event.target.value)}
        placeholder="Type to highlight"
        fullWidth
      />

      <div className="flex flex-col gap-2 text-[0.8125rem]/[1.5]">
        {results.map((result) => (
          <Highlight key={result} query={query}>
            {result}
          </Highlight>
        ))}
      </div>
    </div>
  );
}
