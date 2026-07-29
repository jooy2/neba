import { TreeItem, TreeView } from 'neba';

export default function TreeViewVariants() {
  return (
    <div className="flex flex-wrap gap-6">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <TreeView
          key={variant}
          label={variant}
          variant={variant}
          size="sm"
          defaultExpanded={['design']}
          className="w-48"
        >
          <TreeItem value="design" label={variant}>
            <TreeItem value="brand" label="Brand" />
            <TreeItem value="product" label="Product" />
          </TreeItem>
          <TreeItem value="eng" label="Engineering" />
        </TreeView>
      ))}
    </div>
  );
}
