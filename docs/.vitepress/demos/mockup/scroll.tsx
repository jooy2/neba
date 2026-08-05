import { Card, Chip, Mockup, Typography } from 'neba';

const SERVICES = [
  'api-gateway',
  'web-storefront',
  'checkout',
  'search-index',
  'image-resizer',
  'mailer',
  'billing',
  'webhooks',
  'auth',
  'analytics',
  'scheduler',
  'notifications',
  'exports',
  'admin'
];

export default function MockupScroll() {
  return (
    <Mockup device="mobile" size="xs" scroll width={150}>
      <div className="flex flex-col gap-2 p-3">
        {SERVICES.map((service, index) => (
          <Card key={service} size="xs">
            <div className="flex items-center justify-between gap-2">
              <Typography level="caption">{service}</Typography>
              <Chip size="xs" variant="text" color={index % 4 === 1 ? 'info' : 'success'}>
                {index % 4 === 1 ? 'Building' : 'Live'}
              </Chip>
            </div>
          </Card>
        ))}
      </div>
    </Mockup>
  );
}
