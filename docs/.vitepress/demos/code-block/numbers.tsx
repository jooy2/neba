import { CodeBlock } from 'neba';

const source = `  const collapse = useCollapsed(collapseBelow);
  const [ownOpen, setOwnOpen] = useState(defaultOpen);
  const open = controlled ? openProp : ownOpen;

  return collapse ? <Drawer open={open} /> : <aside>{children}</aside>;`;

export default function CodeBlockNumbers() {
  return <CodeBlock code={source} language="tsx" lineNumbers startLine={286} title="Sidebar.tsx" />;
}
