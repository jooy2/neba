import { Chip, Flex } from 'neba';

const TAGS = ['production', 'staging', 'preview', 'canary', 'edge', 'legacy', 'archived'];

export default function FlexSpacing() {
  return (
    <Flex wrap spacing={{ xs: 1, md: 3 }} className="w-full max-w-md">
      {TAGS.map((tag) => (
        <Chip key={tag}>{tag}</Chip>
      ))}
    </Flex>
  );
}
