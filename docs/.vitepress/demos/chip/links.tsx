import { Chip } from 'neba';

const TOPICS = ['react', 'accessibility', 'design-systems', 'css'];

export default function ChipLinks() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      {TOPICS.map((topic) => (
        <Chip key={topic} href={`#${topic}`} rel="tag" selected={topic === 'react'}>
          {topic}
        </Chip>
      ))}
      <Chip href="https://github.com/topics/react" target="_blank" variant="text" color="secondary">
        More on GitHub
      </Chip>
    </div>
  );
}
