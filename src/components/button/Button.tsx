import { Button as BaseUIButton } from '@base-ui/react/button';

export function Button({ text }: { text: string }) {
  return <BaseUIButton>{text}</BaseUIButton>;
}
