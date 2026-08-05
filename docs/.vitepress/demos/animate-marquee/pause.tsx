import { AnimateMarquee, TextLink } from 'neba';

const POSTS = [
  'Why a control never moves',
  'Acrylic, not moulded plastic',
  'One prop vocabulary',
  'Press is instant, release is slow'
];

/* Links inside a strip that never stopped would be links nobody could follow. */
export default function AnimateMarqueePause() {
  return (
    <AnimateMarquee className="w-full max-w-sm" speed={40} gap="2rem">
      {POSTS.map((post) => (
        <TextLink key={post} href="#pause">
          {post}
        </TextLink>
      ))}
    </AnimateMarquee>
  );
}
