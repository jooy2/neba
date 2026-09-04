import { Avatar, Badge } from 'neba';

export default function AvatarStatus() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <Badge dot color="success" overlap="circle" label="Online">
        <Avatar size="xl" src="/samples/people/lucas-adebayo.jpg" name="Lucas Adebayo" />
      </Badge>

      <Badge dot color="warning" overlap="circle" label="Away">
        <Avatar size="xl" name="Sam Park" color="warning" />
      </Badge>

      <Badge dot color="secondary" overlap="circle" placement="bottom-end" label="Offline">
        <Avatar size="xl" src="/samples/people/helen-voss.jpg" name="Helen Voss" />
      </Badge>

      <Badge content={12} overlap="circle" label="12 unread messages">
        <Avatar size="xl" name="홍길동" color="info" />
      </Badge>
    </div>
  );
}
