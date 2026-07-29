import { Breadcrumb, BreadcrumbItem } from 'neba';

export default function BreadcrumbSizes() {
  return (
    <div className="flex flex-col gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <Breadcrumb key={size} size={size} label={size}>
          <BreadcrumbItem href="#home">Home</BreadcrumbItem>
          <BreadcrumbItem href="#projects">Projects</BreadcrumbItem>
          <BreadcrumbItem>{size}</BreadcrumbItem>
        </Breadcrumb>
      ))}
    </div>
  );
}
