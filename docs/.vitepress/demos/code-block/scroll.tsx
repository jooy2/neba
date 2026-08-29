import { useState } from 'react';
import { CodeBlock, Segment, SegmentedButton } from 'neba';

const source = `# One long line, so there is something for wrap to actually do.
curl --fail --silent --show-error --location --retry 3 --retry-delay 2 --header "authorization: Bearer $NEBA_TOKEN" --header "content-type: application/json" --data '{"region":"icn","runtime":"node22","memory":512}' https://api.example.com/v1/projects/neba/deployments
echo "queued"

# And a second one, because a single wrapped line is easy to mistake for two.
docker run --rm --interactive --tty --volume "$PWD:/work" --workdir /work --env CI=1 --env NODE_OPTIONS=--max-old-space-size=4096 node:22-bookworm npm run build -- --profile
echo "built"`;

export default function CodeBlockScroll() {
  const [wrap, setWrap] = useState(false);

  return (
    <div className="flex w-full flex-col gap-4">
      <SegmentedButton
        size="sm"
        value={wrap ? 'wrap' : 'scroll'}
        onValueChange={(next) => setWrap(next === 'wrap')}
      >
        <Segment value="scroll">scroll</Segment>
        <Segment value="wrap">wrap</Segment>
      </SegmentedButton>

      <CodeBlock
        code={source}
        language="bash"
        wrap={wrap}
        maxHeight={220}
        lineNumbers
        title="deploy.sh"
      />
    </div>
  );
}
