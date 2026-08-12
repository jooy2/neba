import { Button } from 'neba';

export default function ButtonRender() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <Button render={<a href="/guide/getting-started" />}>Get started</Button>
      <Button render={<a href="/components/" />} variant="outline" color="secondary">
        All components
      </Button>
      <Button render={<a href="/design/design-language" />} variant="text" size="sm">
        Design language
      </Button>
    </div>
  );
}
