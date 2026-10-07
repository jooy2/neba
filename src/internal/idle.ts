/**
 * Runs `task` when the browser next has nothing else to do, and returns what
 * cancels it.
 *
 * `timeout` is how long a page that is never idle may hold the task back, and
 * it is the caller's: a chart's hidden table wants its next slice within half a
 * second, a palette fetching its sheet can wait two. Where there is no idle
 * callback, which is Safari, a timer of `fallbackDelay` stands in.
 */
export function whenIdle(
  task: (deadline?: IdleDeadline) => void,
  timeout: number,
  fallbackDelay = 16
): () => void {
  if (typeof requestIdleCallback === 'function' && typeof cancelIdleCallback === 'function') {
    const handle = requestIdleCallback(task, { timeout });

    return () => cancelIdleCallback(handle);
  }

  const handle = setTimeout(task, fallbackDelay);

  return () => clearTimeout(handle);
}
