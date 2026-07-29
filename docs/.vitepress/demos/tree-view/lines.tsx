import { TreeItem, TreeView } from 'neba';

export default function TreeViewLinesDemo() {
  return (
    <div className="flex flex-wrap gap-6">
      {(['none', 'simple', 'folder'] as const).map((lines) => (
        <TreeView
          key={lines}
          label={lines}
          lines={lines}
          size="sm"
          defaultExpanded={['app', 'routes']}
          className="w-52"
        >
          <TreeItem value="app" label={`app (${lines})`}>
            <TreeItem value="routes" label="routes">
              <TreeItem value="home" label="home.tsx" />
              <TreeItem value="about" label="about.tsx" />
            </TreeItem>
            <TreeItem value="root" label="root.tsx" />
          </TreeItem>
          <TreeItem value="public" label="public" />
        </TreeView>
      ))}
    </div>
  );
}
