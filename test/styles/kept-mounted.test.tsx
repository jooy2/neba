/**
 * Content kept in the document while it is hidden, checked against the
 * stylesheet.
 *
 * `keepMounted` leaves a hidden tab panel, a shut inline drawer and a folded
 * breadcrumb step in the DOM so a crawler can read them, marked `hidden`. The
 * shipped reset leaves out Preflight's `[hidden]` rule, so a `flex` class on the
 * same element would beat the browser's own `display: none` and draw the hidden
 * content on the page. No component test loads CSS, so only this file can see
 * that happen.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Breadcrumb, BreadcrumbItem, Drawer, Tab, TabPanel, Tabs } from 'neba';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** Every element in `root` that is marked `hidden` but still laid out. */
function drawnWhileHidden(root: Element): string[] {
  return [...root.querySelectorAll('[hidden]')]
    .filter((element) => getComputedStyle(element).display !== 'none')
    .map((element) => element.outerHTML.slice(0, 120));
}

describe('kept-mounted content under the stylesheet', () => {
  it('does not draw the panels behind the tabs nobody pressed', async () => {
    const screen = await render(
      <Tabs defaultValue="a" keepMounted>
        <Tab value="a">First</Tab>
        <Tab value="b">Second</Tab>
        <TabPanel value="a">First panel</TabPanel>
        <TabPanel value="b">Second panel</TabPanel>
      </Tabs>
    );

    expect(screen.container.innerHTML).toContain('Second panel');
    expect(drawnWhileHidden(screen.container)).toEqual([]);
  });

  it('does not draw a shut inline drawer', async () => {
    const screen = await render(
      <Drawer mode="inline" open={false} onOpenChange={() => {}} title="Projects" keepMounted>
        Inside
      </Drawer>
    );

    expect(screen.container.innerHTML).toContain('Inside');
    expect(drawnWhileHidden(screen.container)).toEqual([]);
  });

  it('does not draw the steps a fold is hiding', async () => {
    const screen = await render(
      <Breadcrumb maxItems={3} keepMounted>
        <BreadcrumbItem href="/">Home</BreadcrumbItem>
        <BreadcrumbItem href="/a">Projects</BreadcrumbItem>
        <BreadcrumbItem href="/b">Neba</BreadcrumbItem>
        <BreadcrumbItem href="/c">Settings</BreadcrumbItem>
        <BreadcrumbItem>Billing</BreadcrumbItem>
      </Breadcrumb>
    );

    expect(screen.container.innerHTML).toContain('href="/b"');
    expect(drawnWhileHidden(screen.container)).toEqual([]);
  });
});
