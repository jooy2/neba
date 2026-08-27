import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Avatar, ChatBubble } from 'neba';
import { ja, ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);
registerMessages('ja', ja);

/**
 * A 1×1 transparent GIF. Inline so nothing here depends on the network — and so
 * the browser is never handed an empty `src`, which it answers by fetching the
 * page again.
 */
const PIXEL = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

describe('ChatBubble', () => {
  describe('rendering', () => {
    it('renders the message it is given', async () => {
      const screen = await render(<ChatBubble>Are we still on for 3?</ChatBubble>);

      await expect.element(screen.getByText('Are we still on for 3?')).toBeInTheDocument();
    });

    it('reflects a changed message on re-render', async () => {
      const screen = await render(<ChatBubble>Before</ChatBubble>);

      await screen.rerender(<ChatBubble>After</ChatBubble>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <ChatBubble className="my-own-class" data-testid="bubble">
          Hi
        </ChatBubble>
      );

      expect(screen.getByTestId('bubble').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(
        <ChatBubble data-testid="bubble" id="message-1">
          Hi
        </ChatBubble>
      );

      expect(screen.getByTestId('bubble').element()).toHaveAttribute('id', 'message-1');
    });

    it('draws the name, the time and the avatar when it has them', async () => {
      // The avatar takes `initials` rather than the same `name`: with both, the
      // sender's name would be in the document twice and every query for it
      // ambiguous — which is exactly what a caller will hit too.
      const screen = await render(
        <ChatBubble name="Jane Doe" time="09:41" avatar={<Avatar initials="JD" />}>
          Morning
        </ChatBubble>
      );

      await expect.element(screen.getByText('Jane Doe')).toBeInTheDocument();
      await expect.element(screen.getByText('09:41')).toBeInTheDocument();
      await expect.element(screen.getByText('JD')).toBeInTheDocument();
    });

    it('says nothing beyond the message when it is given nothing else', async () => {
      const screen = await render(<ChatBubble data-testid="bubble">Hi</ChatBubble>);

      expect(screen.getByTestId('bubble').element().textContent).toBe('Hi');
    });
  });

  describe('side', () => {
    it('runs the row the other way for a message of your own', async () => {
      const screen = await render(
        <ChatBubble side="end" data-testid="bubble">
          Sure
        </ChatBubble>
      );

      expect(screen.getByTestId('bubble').element()).toHaveClass('flex-row-reverse');
    });

    it('starts at the start', async () => {
      const screen = await render(<ChatBubble data-testid="bubble">Sure</ChatBubble>);

      expect(screen.getByTestId('bubble').element()).not.toHaveClass('flex-row-reverse');
    });
  });

  describe('status', () => {
    it('draws nothing at all when no status is given', async () => {
      const screen = await render(<ChatBubble>Hi</ChatBubble>);

      expect(screen.getByText('Read').query()).toBeNull();
      expect(screen.getByText('Sent').query()).toBeNull();
    });

    it('names the mark for a screen reader', async () => {
      const screen = await render(<ChatBubble status="read">Hi</ChatBubble>);

      await expect.element(screen.getByText('Read')).toBeInTheDocument();
    });

    it('names it in the language it was given', async () => {
      const screen = await render(
        <ChatBubble status="read" locale="ko">
          안녕
        </ChatBubble>
      );

      await expect.element(screen.getByText('읽음')).toBeInTheDocument();
    });

    it('takes a word of its own over both', async () => {
      const screen = await render(
        <ChatBubble status="read" locale="ko" statusLabel="Seen by 3">
          안녕
        </ChatBubble>
      );

      await expect.element(screen.getByText('Seen by 3')).toBeInTheDocument();
      expect(screen.getByText('읽음').query()).toBeNull();
    });

    it('moves between steps on re-render', async () => {
      const screen = await render(<ChatBubble status="sending">Hi</ChatBubble>);

      await expect.element(screen.getByText('Sending')).toBeInTheDocument();

      await screen.rerender(<ChatBubble status="delivered">Hi</ChatBubble>);

      await expect.element(screen.getByText('Delivered')).toBeInTheDocument();
      expect(screen.getByText('Sending').query()).toBeNull();
    });
  });

  describe('typing', () => {
    it('draws the dots in place of the message', async () => {
      const screen = await render(<ChatBubble typing>Are we still on?</ChatBubble>);

      await expect.element(screen.getByRole('status')).toBeInTheDocument();
      expect(screen.getByText('Are we still on?').query()).toBeNull();
    });

    it('says what the dots mean, in the language it was given', async () => {
      const screen = await render(
        <ChatBubble typing locale="ja">
          こんにちは
        </ChatBubble>
      );

      await expect.element(screen.getByText('入力中…')).toBeInTheDocument();
    });

    it('gives the message back when the typing stops', async () => {
      const screen = await render(<ChatBubble typing>Are we still on?</ChatBubble>);

      await screen.rerender(<ChatBubble>Are we still on?</ChatBubble>);

      await expect.element(screen.getByText('Are we still on?')).toBeInTheDocument();
      expect(screen.getByRole('status').query()).toBeNull();
    });
  });

  describe('media and previews', () => {
    it('draws the media it is handed', async () => {
      const screen = await render(
        <ChatBubble media={<img src={PIXEL} alt="The plan" />}>Here it is</ChatBubble>
      );

      await expect.element(screen.getByRole('img', { name: 'The plan' })).toBeInTheDocument();
    });

    it('unfurls a link into a card', async () => {
      const screen = await render(
        <ChatBubble
          preview={{
            url: 'https://example.com/post',
            title: 'A very good post',
            description: 'Everything about it',
            site: 'example.com'
          }}
        >
          Read this
        </ChatBubble>
      );
      const card = screen.getByRole('link', { name: /A very good post/ });

      await expect.element(card).toBeInTheDocument();
      expect(card.element()).toHaveAttribute('href', 'https://example.com/post');
    });

    it('opens the card in a new tab only when asked', async () => {
      const screen = await render(
        <ChatBubble preview={{ url: 'https://example.com', title: 'Post', newTab: true }}>
          Read this
        </ChatBubble>
      );

      expect(screen.getByRole('link').element()).toHaveAttribute('target', '_blank');
    });
  });

  describe('actions', () => {
    it('renders the actions it is handed', async () => {
      const screen = await render(
        <ChatBubble actions={<button type="button">Options</button>}>Hi</ChatBubble>
      );

      await expect.element(screen.getByRole('button', { name: 'Options' })).toBeInTheDocument();
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(
        <ChatBubble color="success" data-testid="bubble">
          Hi
        </ChatBubble>
      );
      const element = screen.getByTestId('bubble').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });

    it('defaults to the primary colour', async () => {
      const screen = await render(<ChatBubble data-testid="bubble">Hi</ChatBubble>);
      const element = screen.getByTestId('bubble').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-fill')).toBe('var(--neba-primary-fill)');
    });
  });
});
