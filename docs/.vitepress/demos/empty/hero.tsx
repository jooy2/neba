import { Button, Card, Empty } from 'neba';

export default function EmptyHero() {
  return (
    <Card className="w-full max-w-100" title="Projects" dividers>
      <Empty title="No projects yet" action={<Button size="sm">Create a project</Button>}>
        Everything you deploy shows up here. Start from scratch or import a repository.
      </Empty>
    </Card>
  );
}
