import { Avatar, Badge } from 'neba';

export default function AvatarHero() {
  return (
    <div className="flex flex-wrap items-center gap-5">
      <Avatar src="/samples/people/nadia-rowan.jpg" name="Nadia Rowan" size="lg" />
      <Avatar name="Sam Park" color="success" size="lg" />
      <Avatar name="홍길동" variant="solid" color="info" size="lg" />
      <Avatar shape="square" variant="outline" color="warning" size="lg">
        N
      </Avatar>

      <Badge dot color="success" overlap="circle" label="Online">
        <Avatar src="/samples/people/joon-mercer.jpg" name="Joon Mercer" size="lg" />
      </Badge>

      <Avatar size="lg" color="secondary" />
    </div>
  );
}
