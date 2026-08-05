import { AnimateTyping, Typography } from 'neba';

export default function AnimateTypingLoop() {
  return (
    <Typography level="h4" render={<div />}>
      <span className="text-(--neba-muted-fg)">A component library for </span>
      <AnimateTyping
        className="inline-block align-baseline text-(--neba-primary-accent)"
        text="dashboards"
        repeat="infinite"
        erase
        hold={1200}
        speed={14}
      />
    </Typography>
  );
}
