import { Breadcrumb, BreadcrumbItem } from 'neba';

export default function BreadcrumbCollapse() {
  return (
    <div className="flex flex-col gap-4">
      {/* One step at each end, everything between folded behind the `…`. */}
      <Breadcrumb maxItems={3} label="Folded">
        <BreadcrumbItem href="#home">Home</BreadcrumbItem>
        <BreadcrumbItem href="#org">Acme</BreadcrumbItem>
        <BreadcrumbItem href="#team">Platform</BreadcrumbItem>
        <BreadcrumbItem href="#repo">neba</BreadcrumbItem>
        <BreadcrumbItem href="#branch">main</BreadcrumbItem>
        <BreadcrumbItem>Button.tsx</BreadcrumbItem>
      </Breadcrumb>

      {/* Two kept at the front, two at the end. */}
      <Breadcrumb maxItems={4} itemsBeforeCollapse={2} itemsAfterCollapse={2} label="Wider ends">
        <BreadcrumbItem href="#home">Home</BreadcrumbItem>
        <BreadcrumbItem href="#org">Acme</BreadcrumbItem>
        <BreadcrumbItem href="#team">Platform</BreadcrumbItem>
        <BreadcrumbItem href="#repo">neba</BreadcrumbItem>
        <BreadcrumbItem href="#branch">main</BreadcrumbItem>
        <BreadcrumbItem>Button.tsx</BreadcrumbItem>
      </Breadcrumb>
    </div>
  );
}
