import { Breadcrumb, BreadcrumbItem } from 'neba';

function HomeIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M2.5 7 8 2.5 13.5 7v6a.5.5 0 0 1-.5.5h-3v-4H6v4H3a.5.5 0 0 1-.5-.5V7Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function FileIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path d="M4 2h5l3 3v9H4V2Z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" />
      <path d="M9 2v3h3" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" />
    </svg>
  );
}

export default function BreadcrumbIcons() {
  return (
    <Breadcrumb size="lg">
      <BreadcrumbItem href="#home" startIcon={<HomeIcon />}>
        Home
      </BreadcrumbItem>
      <BreadcrumbItem href="#src">src</BreadcrumbItem>
      <BreadcrumbItem startIcon={<FileIcon />}>Button.tsx</BreadcrumbItem>
    </Breadcrumb>
  );
}
