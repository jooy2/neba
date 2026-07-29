import { Breadcrumb, BreadcrumbItem } from 'neba';

export default function BreadcrumbSeparators() {
  return (
    <div className="flex flex-col gap-3">
      {(['chevron', 'arrow', 'slash', 'dot'] as const).map((separator) => (
        <Breadcrumb key={separator} separator={separator} label={separator}>
          <BreadcrumbItem href="#home">Home</BreadcrumbItem>
          <BreadcrumbItem href="#projects">Projects</BreadcrumbItem>
          <BreadcrumbItem>{separator}</BreadcrumbItem>
        </Breadcrumb>
      ))}

      {/* Anything else is drawn as it is given. */}
      <Breadcrumb separator="»" label="custom">
        <BreadcrumbItem href="#home">Home</BreadcrumbItem>
        <BreadcrumbItem href="#projects">Projects</BreadcrumbItem>
        <BreadcrumbItem>custom</BreadcrumbItem>
      </Breadcrumb>
    </div>
  );
}
