import { Button, Empty, TextLink } from 'neba';

export default function EmptyAction() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      <Empty
        variant="outline"
        title="No results"
        action={
          <Button size="sm" variant="outline">
            Clear filters
          </Button>
        }
      >
        Nothing matched <strong>ingress-nginx</strong>.
      </Empty>

      <Empty
        variant="outline"
        title="No team members"
        action={
          <>
            <Button size="sm">Invite someone</Button>
            <TextLink href="#action">Read about roles</TextLink>
          </>
        }
      >
        You are the only one here so far.
      </Empty>
    </div>
  );
}
