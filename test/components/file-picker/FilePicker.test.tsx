import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { FilePicker } from 'neba';

function file(name: string, type = 'text/plain', size = 10) {
  return new File(['x'.repeat(size)], name, { type });
}

/**
 * Drops a batch of files on the zone.
 *
 * A real `DataTransfer` rather than a stub, because that is what the component
 * reads — and building one is the only way to exercise the path a dropped file
 * takes, which is the path `accept` is never checked on by the browser.
 */
async function drop(target: Element, files: File[]) {
  const transfer = new DataTransfer();
  files.forEach((item) => transfer.items.add(item));

  target.dispatchEvent(
    new DragEvent('dragenter', { bubbles: true, cancelable: true, dataTransfer: transfer })
  );
  target.dispatchEvent(
    new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer: transfer })
  );

  await new Promise((resolve) => setTimeout(resolve, 0));
}

describe('FilePicker', () => {
  describe('rendering', () => {
    it('renders a button that opens the file dialog', async () => {
      const screen = await render(<FilePicker />);

      await expect
        .element(screen.getByRole('button', { name: /Drop files here/ }))
        .toBeInTheDocument();
    });

    it('renders its own copy when it is given some', async () => {
      const screen = await render(<FilePicker title="Drop a CSV" hint="Up to 5 MB" />);

      await expect.element(screen.getByRole('button', { name: /Drop a CSV/ })).toBeInTheDocument();
      await expect.element(screen.getByText('Up to 5 MB')).toBeInTheDocument();
    });

    it('renders the label, the description and the error', async () => {
      const screen = await render(<FilePicker label="Attachments" description="PDF or PNG." />);

      await expect.element(screen.getByText('Attachments')).toBeInTheDocument();
      await expect.element(screen.getByText('PDF or PNG.')).toBeInTheDocument();

      await screen.rerender(<FilePicker label="Attachments" error="Pick at least one." />);

      await expect.element(screen.getByText('Pick at least one.')).toBeInTheDocument();
    });

    it('carries accept and multiple onto the real input', async () => {
      const screen = await render(<FilePicker accept="image/*" multiple />);
      const input = screen.container.querySelector('input[type="file"]') as HTMLInputElement;

      expect(input).toHaveAttribute('accept', 'image/*');
      expect(input.multiple).toBe(true);
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(<FilePicker title="Before" />);

      await screen.rerender(<FilePicker title="After" />);

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<FilePicker className="my-own-class" />);

      expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('the files it holds', () => {
    it('lists the files it is given', async () => {
      const screen = await render(<FilePicker multiple defaultValue={[file('notes.txt')]} />);

      await expect.element(screen.getByText('notes.txt')).toBeInTheDocument();
    });

    it('shows each file with its size', async () => {
      const screen = await render(
        <FilePicker defaultValue={[file('notes.txt', 'text/plain', 2500)]} />
      );

      await expect.element(screen.getByText('2.5 kB')).toBeInTheDocument();
    });

    it('hides the list when told to', async () => {
      const screen = await render(
        <FilePicker showList={false} defaultValue={[file('notes.txt')]} />
      );

      expect(screen.getByText('notes.txt').query()).toBeNull();
    });

    it('removes a file when its remove button is pressed', async () => {
      const onFilesChange = vi.fn();
      const screen = await render(
        <FilePicker defaultValue={[file('notes.txt')]} onFilesChange={onFilesChange} />
      );

      await screen.getByRole('button', { name: 'Remove notes.txt' }).click();

      expect(onFilesChange).toHaveBeenCalledWith([]);
      expect(screen.getByText('notes.txt').query()).toBeNull();
    });

    it('follows a controlled value', async () => {
      const screen = await render(<FilePicker value={[file('a.txt')]} />);

      await expect.element(screen.getByText('a.txt')).toBeInTheDocument();

      await screen.rerender(<FilePicker value={[file('b.txt')]} />);

      await expect.element(screen.getByText('b.txt')).toBeInTheDocument();
      expect(screen.getByText('a.txt').query()).toBeNull();
    });
  });

  describe('dropping', () => {
    it('takes a dropped file', async () => {
      const onFilesChange = vi.fn();
      const screen = await render(<FilePicker onFilesChange={onFilesChange} />);

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('notes.txt')
      ]);

      expect(onFilesChange).toHaveBeenCalledTimes(1);
      await expect.element(screen.getByText('notes.txt')).toBeInTheDocument();
    });

    it('replaces rather than appends when it holds one file at a time', async () => {
      const screen = await render(<FilePicker defaultValue={[file('first.txt')]} />);

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('second.txt')
      ]);

      await expect.element(screen.getByText('second.txt')).toBeInTheDocument();
      expect(screen.getByText('first.txt').query()).toBeNull();
    });

    it('appends when it takes more than one', async () => {
      const screen = await render(<FilePicker multiple defaultValue={[file('first.txt')]} />);

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('second.txt')
      ]);

      await expect.element(screen.getByText('first.txt')).toBeInTheDocument();
      await expect.element(screen.getByText('second.txt')).toBeInTheDocument();
    });

    it('ignores a drop while it is disabled', async () => {
      const onFilesChange = vi.fn();
      const screen = await render(<FilePicker disabled onFilesChange={onFilesChange} />);

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('notes.txt')
      ]);

      expect(onFilesChange).not.toHaveBeenCalled();
    });

    it('ignores a drop while it is read-only', async () => {
      const onFilesChange = vi.fn();
      const screen = await render(<FilePicker readOnly onFilesChange={onFilesChange} />);

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('notes.txt')
      ]);

      expect(onFilesChange).not.toHaveBeenCalled();
    });
  });

  describe('what it turns away', () => {
    // The browser applies `accept` to its own dialog and to nothing else, so a
    // dropped file has never been checked against it.
    it('rejects a dropped file the accept string does not match', async () => {
      const onReject = vi.fn();
      const onFilesChange = vi.fn();
      const screen = await render(
        <FilePicker accept="image/*" onReject={onReject} onFilesChange={onFilesChange} />
      );

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('notes.txt', 'text/plain')
      ]);

      expect(onFilesChange).not.toHaveBeenCalled();
      expect(onReject).toHaveBeenCalledWith([expect.objectContaining({ reason: 'type' })]);
    });

    it('matches an accept entry written as an extension', async () => {
      const onFilesChange = vi.fn();
      const screen = await render(<FilePicker accept=".txt" onFilesChange={onFilesChange} />);

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('notes.txt', '')
      ]);

      expect(onFilesChange).toHaveBeenCalledTimes(1);
    });

    it('matches an accept entry written as a wildcard type', async () => {
      const onFilesChange = vi.fn();
      const screen = await render(<FilePicker accept="image/*" onFilesChange={onFilesChange} />);

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('cat.png', 'image/png')
      ]);

      expect(onFilesChange).toHaveBeenCalledTimes(1);
    });

    it('rejects a file over maxSize', async () => {
      const onReject = vi.fn();
      const screen = await render(<FilePicker maxSize={5} onReject={onReject} />);

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('big.txt', 'text/plain', 50)
      ]);

      expect(onReject).toHaveBeenCalledWith([expect.objectContaining({ reason: 'size' })]);
    });

    // `maxFiles` means "you may end up with this many", not "you may drop this
    // many", so it is checked against what is already held.
    it('rejects the files past maxFiles, counting what it already holds', async () => {
      const onReject = vi.fn();
      const screen = await render(
        <FilePicker multiple maxFiles={2} defaultValue={[file('one.txt')]} onReject={onReject} />
      );

      await drop(screen.getByRole('button', { name: /Drop files here/ }).element(), [
        file('two.txt'),
        file('three.txt')
      ]);

      await expect.element(screen.getByText('two.txt')).toBeInTheDocument();
      expect(screen.getByText('three.txt').query()).toBeNull();
      expect(onReject).toHaveBeenCalledWith([expect.objectContaining({ reason: 'count' })]);
    });
  });

  describe('inert states', () => {
    it('disables the browse button and the input', async () => {
      const screen = await render(<FilePicker disabled />);
      const input = screen.container.querySelector('input[type="file"]') as HTMLInputElement;

      await expect.element(screen.getByRole('button', { name: /Drop files here/ })).toBeDisabled();
      expect(input.disabled).toBe(true);
    });

    it('drops the remove buttons when read-only', async () => {
      const screen = await render(<FilePicker readOnly defaultValue={[file('notes.txt')]} />);

      await expect.element(screen.getByText('notes.txt')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Remove notes.txt' }).query()).toBeNull();
    });
  });

  describe('style props', () => {
    it('re-points the colour family at danger when invalid', async () => {
      const screen = await render(<FilePicker error="Pick one." className="probe" />);
      const element = screen.container.querySelector('.probe') as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-danger-line)');
    });

    it('maps elevation onto the token slots', async () => {
      const screen = await render(<FilePicker elevation={2} className="probe" />);
      const element = screen.container.querySelector('.probe') as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-2)');
    });

    // A dropzone that grows or lifts under the pointer moves the target while
    // the reader is aiming at it.
    it('never applies a transform', async () => {
      const screen = await render(<FilePicker defaultValue={[file('notes.txt')]} error="Nope." />);

      expect(screen.container.innerHTML).not.toContain('translate');
    });
  });
});
