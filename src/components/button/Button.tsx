import { Button as BaseUIButton } from '@base-ui-components/react/button';

export function Button({ text }: { text: string }) {
  return <BaseUIButton>{text}</BaseUIButton>;
}
