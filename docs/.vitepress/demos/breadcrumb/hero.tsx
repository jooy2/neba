import { Breadcrumb, BreadcrumbItem } from 'neba';

export default function BreadcrumbHero() {
  return (
    <Breadcrumb>
      <BreadcrumbItem href="#home">Home</BreadcrumbItem>
      <BreadcrumbItem href="#projects">Projects</BreadcrumbItem>
      <BreadcrumbItem href="#neba">Neba</BreadcrumbItem>
      <BreadcrumbItem>Settings</BreadcrumbItem>
    </Breadcrumb>
  );
}
