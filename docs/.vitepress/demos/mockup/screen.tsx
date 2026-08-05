/**
 * Two sample screens, so the demos below are about the device rather than about
 * what is on it. In an app this would be your own page — or an `<img>` of one.
 *
 * They are written the way a real screen is written, at the size the screen
 * really is: the phone one lays out against 390 pixels and the desktop one
 * against 1440, because that is what the mockup gives them.
 */
import { Avatar, Button, Card, Chip, Divider, ProgressLinear, Statistic, Typography } from 'neba';

export function PhoneScreen() {
  return (
    <div className="flex h-full flex-col gap-3 p-4">
      <div className="flex items-center gap-3">
        <Avatar size="md" name="Ada Park" />
        <div className="min-w-0 flex-1">
          <Typography level="body" weight="semibold">
            Good morning
          </Typography>
          <Typography level="caption" color="secondary">
            Three deploys waiting
          </Typography>
        </div>
        <Chip size="xs" color="success">
          On track
        </Chip>
      </div>

      <Card size="sm" title="Build minutes" subtitle="Resets in 6 days">
        <ProgressLinear size="sm" value={72} label="Used this month" showValue />
      </Card>

      <Card size="sm" dividers>
        <div className="flex items-center justify-between">
          <Typography level="caption">api-gateway</Typography>
          <Chip size="xs" variant="text" color="success">
            Live
          </Chip>
        </div>
        <div className="flex items-center justify-between">
          <Typography level="caption">web-storefront</Typography>
          <Chip size="xs" variant="text" color="info">
            Building
          </Chip>
        </div>
      </Card>

      <div className="mt-auto">
        <Button className="w-full">Start a deploy</Button>
      </div>
    </div>
  );
}

export function DesktopScreen() {
  return (
    <div className="flex h-full flex-col gap-5 p-8">
      <div className="flex items-center gap-4">
        <Typography level="h4">Overview</Typography>
        <Chip size="sm" variant="outline" color="secondary">
          Production
        </Chip>
        <div className="ml-auto flex items-center gap-2">
          <Button variant="text">Logs</Button>
          <Button>Deploy</Button>
        </div>
      </div>

      <Divider />

      <div className="grid grid-cols-3 gap-4">
        <Card>
          <Statistic label="Requests" value={1284000} previousValue={1120000} betterWhen="up" />
        </Card>
        <Card>
          <Statistic label="Error rate" value={0.42} previousValue={0.71} betterWhen="down" />
        </Card>
        <Card>
          <Statistic
            label="p95 latency"
            value={186}
            unit="ms"
            previousValue={204}
            betterWhen="down"
          />
        </Card>
      </div>

      <Card title="Rollout" subtitle="web-storefront · 4 of 6 regions" className="flex-1">
        <ProgressLinear value={66} label="Regions updated" showValue />
      </Card>
    </div>
  );
}
