import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { renderHook } from 'vitest-browser-react';
import { attachRef, useMergedRef } from '../../src/internal/refs.js';

/** A React 19 callback ref: it returns what lets go of the node. */
function cleanupRef() {
  const handed: (Element | null)[] = [];
  const released: Element[] = [];
  const ref = (node: Element | null) => {
    handed.push(node);

    return () => {
      released.push(node as Element);
    };
  };

  return { ref, handed, released };
}

describe('attachRef', () => {
  it('lets go of a callback ref by calling it with `null` when it returned nothing', () => {
    const ref = vi.fn();
    const node = document.createElement('div');
    const release = attachRef(ref, node);

    expect(ref.mock.calls).toEqual([[node]]);

    release();

    expect(ref.mock.calls).toEqual([[node], [null]]);
  });

  it('runs the cleanup a callback ref returned instead of calling it with `null`', () => {
    const { ref, handed, released } = cleanupRef();
    const node = document.createElement('div');
    const release = attachRef(ref, node);

    release();

    expect(handed).toEqual([node]);
    expect(released).toEqual([node]);
  });

  it('sets an object ref and clears it again', () => {
    const ref = React.createRef<HTMLDivElement>();
    const node = document.createElement('div');
    const release = attachRef(ref, node);

    expect(ref.current).toBe(node);

    release();

    expect(ref.current).toBeNull();
  });

  // A ref that has been handed another node since belongs to that one now.
  it('leaves an object ref alone once it holds another node', () => {
    const ref = React.createRef<HTMLDivElement>();
    const first = document.createElement('div');
    const second = document.createElement('div');
    const release = attachRef(ref, first);

    ref.current = second;
    release();

    expect(ref.current).toBe(second);
  });

  it('does nothing for a missing ref', () => {
    const node = document.createElement('div');

    expect(() => attachRef(null, node)()).not.toThrow();
    expect(() => attachRef(undefined, node)()).not.toThrow();
  });
});

describe('useMergedRef', () => {
  it('hands the node to the own ref and then to the forwarded one', async () => {
    const order: string[] = [];
    const own = (node: Element | null) => void order.push(node ? 'own' : 'own null');
    const ref = (node: Element | null) => void order.push(node ? 'ref' : 'ref null');
    const { result } = await renderHook(() => useMergedRef<Element>(own, ref));

    result.current(document.createElement('div'));

    expect(order).toEqual(['own', 'ref']);

    result.current(null);

    expect(order).toEqual(['own', 'ref', 'own null', 'ref null']);
  });

  // React 18 calls the merged ref with `null`, and so does 19, because it
  // returns nothing; what each side then sees is its own.
  it('gives the own ref `null` and the forwarded ref its cleanup when the node goes', async () => {
    const own = React.createRef<Element>();
    const { ref, handed, released } = cleanupRef();
    const node = document.createElement('div');
    const { result } = await renderHook(() => useMergedRef<Element>(own, ref));

    expect(result.current(node)).toBeUndefined();
    expect(own.current).toBe(node);

    result.current(null);

    expect(own.current).toBeNull();
    expect(handed).toEqual([node]);
    expect(released).toEqual([node]);
  });

  it('lets go of the last node before it takes a new one', async () => {
    const { ref, handed, released } = cleanupRef();
    const first = document.createElement('div');
    const second = document.createElement('div');
    const { result } = await renderHook(() => useMergedRef<Element>(null, ref));

    result.current(first);
    result.current(second);

    expect(handed).toEqual([first, second]);
    expect(released).toEqual([first]);
  });

  it('keeps its identity for as long as both refs do', async () => {
    const own = React.createRef<Element>();
    const first = vi.fn();
    const second = vi.fn();
    const { result, rerender } = await renderHook(
      (props?: { ref: React.Ref<Element> }) => useMergedRef<Element>(own, props!.ref),
      { initialProps: { ref: first } }
    );
    const before = result.current;

    await rerender({ ref: first });

    expect(result.current).toBe(before);

    await rerender({ ref: second });

    expect(result.current).not.toBe(before);
  });
});
