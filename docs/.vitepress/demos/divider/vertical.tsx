import { Divider } from 'neba';

export default function DividerVertical() {
  return (
    <div className="flex h-32 items-stretch gap-6">
      <div className="flex w-28 items-center justify-center text-[0.8125rem]">Before</div>
      <Divider orientation="vertical" />
      <div className="flex w-28 items-center justify-center text-[0.8125rem]">Between</div>
      <Divider orientation="vertical">AND</Divider>
      <div className="flex w-28 items-center justify-center text-[0.8125rem]">After</div>
    </div>
  );
}
