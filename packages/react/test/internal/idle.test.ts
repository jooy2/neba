import { describe, expect, it, vi } from 'vitest';
import { whenIdle } from '../../src/internal/idle.js';

describe('whenIdle', () => {
  it('runs the task once the browser is idle', async () => {
    const task = vi.fn();

    whenIdle(task, 500);

    await expect.poll(() => task.mock.calls.length).toBe(1);
  });

  it('does not run a task that was cancelled', async () => {
    const task = vi.fn();
    const cancel = whenIdle(task, 500);

    cancel();
    await new Promise((resolve) => setTimeout(resolve, 600));

    expect(task).not.toHaveBeenCalled();
  });
});
