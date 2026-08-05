import { Mockup } from 'neba';
import { PhoneScreen } from './screen';

export default function MockupHero() {
  return (
    <Mockup device="mobile" os="ios" elevation={2} width={260}>
      <PhoneScreen />
    </Mockup>
  );
}
