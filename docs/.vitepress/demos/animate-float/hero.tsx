import { AnimateFloat, Card, Typography } from 'neba';

export default function AnimateFloatHero() {
  return (
    <AnimateFloat>
      <Card size="sm" elevation={2} className="w-52">
        <Typography level="body">Not fixed to the page.</Typography>
      </Card>
    </AnimateFloat>
  );
}
