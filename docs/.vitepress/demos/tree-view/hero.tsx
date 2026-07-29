import { TreeItem, TreeView } from 'neba';

export default function TreeViewHero() {
  return (
    <TreeView
      label="Project files"
      lines="folder"
      defaultExpanded={['src', 'components']}
      defaultSelected={['button']}
      className="w-full max-w-72"
    >
      <TreeItem value="src" label="src">
        <TreeItem value="components" label="components">
          <TreeItem value="button" label="Button.tsx" />
          <TreeItem value="card" label="Card.tsx" />
        </TreeItem>
        <TreeItem value="internal" label="internal">
          <TreeItem value="styles" label="styles.ts" />
        </TreeItem>
        <TreeItem value="index" label="index.ts" />
      </TreeItem>
      <TreeItem value="package" label="package.json" />
      <TreeItem value="readme" label="README.md" />
    </TreeView>
  );
}
