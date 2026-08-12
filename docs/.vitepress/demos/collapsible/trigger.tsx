import { Button, Collapsible, Typography } from 'neba';

export default function CollapsibleTrigger() {
  return (
    <div className="w-full max-w-lg">
      <Collapsible
        variant="text"
        padded={false}
        trigger={
          <Button variant="text" size="sm">
            Show the full changelog
          </Button>
        }
      >
        <Typography className="pt-3">
          1.4.0 added nine chart components and a shared data model behind them. 1.3.0 was the date
          pickers. Everything before that is in the changelog itself.
        </Typography>
      </Collapsible>
    </div>
  );
}
