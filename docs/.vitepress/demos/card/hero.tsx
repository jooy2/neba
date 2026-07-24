import { Button, Card } from 'neba';

export default function CardHero() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <Card
        title="Starter"
        subtitle="For a single project"
        footer={
          <>
            <Button size="sm" variant="text" color="secondary">
              Compare
            </Button>
            <Button size="sm" className="ml-auto">
              Choose
            </Button>
          </>
        }
      >
        Everything you need to put one site in front of real users.
      </Card>
      <Card
        variant="solid"
        color="secondary"
        title="Team"
        subtitle="Up to twelve seats"
        headerAction={
          <Button size="xs" variant="outline" color="secondary">
            Popular
          </Button>
        }
        footer={
          <Button size="sm" fullWidth>
            Choose
          </Button>
        }
      >
        Shared environments, review apps and a seat for everyone.
      </Card>
    </div>
  );
}
