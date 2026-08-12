import { Breadcrumb, BreadcrumbItem } from 'neba';

/**
 * The preview looks exactly like any other trail, which is the point: what
 * `structuredData` adds is a `<script type="application/ld+json">` beside the
 * markup, drawn for nobody and read by a crawler. Open the inspector to see it.
 */
export default function BreadcrumbStructuredData() {
  return (
    <Breadcrumb structuredData baseUrl="https://neba.cdget.com">
      <BreadcrumbItem href="/">Home</BreadcrumbItem>
      <BreadcrumbItem href="/components/">Components</BreadcrumbItem>
      <BreadcrumbItem href="/components/display/">Display</BreadcrumbItem>
      <BreadcrumbItem>Breadcrumb</BreadcrumbItem>
    </Breadcrumb>
  );
}
