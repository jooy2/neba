import { useState } from 'react';
import { CodeBlock, Select } from 'neba';

const samples: Record<string, string> = {
  tsx: `export function Greeting({ name }: { name: string }) {
  return <p className="text-lg">Hello, {name}!</p>;
}`,
  python: `from dataclasses import dataclass

@dataclass
class Point:
    x: float = 0.0
    y: float = 0.0

    def scaled(self, by: float) -> "Point":
        return Point(self.x * by, self.y * by)`,
  yaml: `name: run-test
on:
  pull_request:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5`,
  sql: `SELECT p.name, count(o.id) AS orders
FROM products p
LEFT JOIN orders o ON o.product_id = p.id
WHERE p.archived_at IS NULL
GROUP BY p.name
ORDER BY orders DESC
LIMIT 10;`,
  rust: `fn main() {
    let names = vec!["ada", "grace", "alan"];
    for (index, name) in names.iter().enumerate() {
        println!("{index}: {name}");
    }
}`
};

export default function CodeBlockLanguage() {
  const [language, setLanguage] = useState('tsx');

  return (
    <div className="flex w-full flex-col gap-4">
      <Select
        size="sm"
        label="Language"
        items={Object.keys(samples).map((name) => ({ value: name, label: name }))}
        value={language}
        onValueChange={(next) => setLanguage(String(next))}
      />

      <CodeBlock code={samples[language]} language={language} />
    </div>
  );
}
