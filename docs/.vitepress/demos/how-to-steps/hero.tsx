import { CodeBlock, HowToSteps, Typography } from 'neba';

export default function HowToStepsHero() {
  return (
    <HowToSteps
      title="Schedule a job with cron"
      steps={[
        {
          title: 'Open your crontab',
          content: (
            <div className="flex flex-col gap-3">
              <Typography>
                Every user has a crontab of their own. This opens yours in the editor
                <code> $EDITOR</code> points at.
              </Typography>
              <CodeBlock size="sm" language="bash" prompt="$" code="crontab -e" />
            </div>
          )
        },
        {
          title: 'Write the schedule',
          content: (
            <div className="flex flex-col gap-3">
              <Typography>
                Five fields, then the command: minute, hour, day of month, month, day of week.
              </Typography>
              <CodeBlock size="sm" language="bash" code="*/5 * * * * /usr/local/bin/backup.sh" />
            </div>
          )
        },
        {
          title: 'Keep the output',
          content: (
            <div className="flex flex-col gap-3">
              <Typography>
                cron mails you anything a job prints. Redirect it to a file instead, so a failure is
                somewhere you will look.
              </Typography>
              <CodeBlock
                size="sm"
                language="bash"
                wrap
                code="*/5 * * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1"
              />
            </div>
          )
        },
        {
          title: 'Check it took',
          content: (
            <div className="flex flex-col gap-3">
              <Typography>Print the crontab back and read what is actually in it.</Typography>
              <CodeBlock size="sm" language="bash" prompt="$" code="crontab -l" />
            </div>
          )
        }
      ]}
    />
  );
}
