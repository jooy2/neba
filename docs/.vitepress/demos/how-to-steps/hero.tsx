import { CodeBlock, HowToSteps, Typography } from 'neba';

/** Whatever your icon set hands back — here, four drawings of our own. */
function TerminalIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="m3.5 4.5 3 3.5-3 3.5M8.5 11.5h4"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ClockIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="5.75" stroke="currentColor" strokeWidth="1.5" />
      <path d="M8 4.75V8l2.25 1.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

function FileIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M9 2.25H4.75a1.5 1.5 0 0 0-1.5 1.5v8.5a1.5 1.5 0 0 0 1.5 1.5h6.5a1.5 1.5 0 0 0 1.5-1.5V5.75L9 2.25Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M8.75 2.5v3.25h3.5" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" />
    </svg>
  );
}

function EyeIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M1.5 8S4 3.75 8 3.75 14.5 8 14.5 8 12 12.25 8 12.25 1.5 8 1.5 8Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <circle cx="8" cy="8" r="1.75" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

export default function HowToStepsHero() {
  return (
    <HowToSteps
      title="Schedule a job with cron"
      steps={[
        {
          title: 'Open your crontab',
          icon: <TerminalIcon />,
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
          icon: <ClockIcon />,
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
          icon: <FileIcon />,
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
          icon: <EyeIcon />,
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
