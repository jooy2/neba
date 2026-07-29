import { Avatar, Badge } from 'neba';
import { portrait } from './portrait';

export default function AvatarStatus() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <Badge dot color="success" overlap="circle" label="Online">
        <Avatar size="xl" src={portrait(148)} name="Alex Kim" />
      </Badge>

      <Badge dot color="warning" overlap="circle" label="Away">
        <Avatar size="xl" name="Sam Park" color="warning" />
      </Badge>

      <Badge dot color="secondary" overlap="circle" placement="bottom-end" label="Offline">
        <Avatar size="xl" src={portrait(30)} name="Jane Doe" />
      </Badge>

      <Badge content={12} overlap="circle" label="12 unread messages">
        <Avatar size="xl" name="홍길동" color="info" />
      </Badge>
    </div>
  );
}
