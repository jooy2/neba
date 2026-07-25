import { Divider } from 'neba';

export default function DividerHero() {
  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      <Divider />
      <Divider>OR</Divider>
      <div className="flex h-10 items-center gap-4">
        <span className="text-[0.8125rem]">Draft</span>
        <Divider orientation="vertical" />
        <span className="text-[0.8125rem]">Edited 2 min ago</span>
        <Divider orientation="vertical" />
        <span className="text-[0.8125rem]">3 comments</span>
      </div>
    </div>
  );
}
