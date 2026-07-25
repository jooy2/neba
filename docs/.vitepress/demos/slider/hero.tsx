import { Slider } from 'neba';

export default function SliderHero() {
  return (
    <div className="flex w-full max-w-md flex-col gap-8">
      <Slider label="Volume" defaultValue={65} showValue />
      <Slider label="Budget" defaultValue={[20, 80]} showValue color="success" />
    </div>
  );
}
