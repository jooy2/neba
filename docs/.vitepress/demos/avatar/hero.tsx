import { Avatar, Badge } from 'neba';
import { portrait } from './portrait';

export default function AvatarHero() {
  return (
    <div className="flex flex-wrap items-center gap-5">
      <Avatar src={portrait(262)} name="Jane Doe" size="lg" />
      <Avatar name="Sam Park" color="success" size="lg" />
      <Avatar name="홍길동" variant="solid" color="info" size="lg" />
      <Avatar shape="square" variant="outline" color="warning" size="lg">
        N
      </Avatar>

      <Badge dot color="success" overlap="circle" label="Online">
        <Avatar src={portrait(148)} name="Alex Kim" size="lg" />
      </Badge>

      <Avatar size="lg" color="secondary" />
    </div>
  );
}
