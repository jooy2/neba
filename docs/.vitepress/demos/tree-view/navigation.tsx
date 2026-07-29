import { Badge, TreeItem, TreeView } from 'neba';

/* A sidebar: `text` so the tree draws no sheet of its own, `lines="none"`
   because two levels of navigation say what they are with words. */
export default function TreeViewNavigation() {
  return (
    <TreeView
      label="Documentation"
      variant="text"
      lines="none"
      density="compact"
      defaultExpanded={['components']}
      defaultSelected={['inputs']}
      className="w-56"
    >
      <TreeItem value="guide" label="Getting started" href="#guide" />
      <TreeItem value="components" label="Components">
        <TreeItem value="display" label="Display" href="#display" />
        <TreeItem
          value="inputs"
          label="Inputs"
          href="#inputs"
          endIcon={<Badge content={19} variant="outline" />}
        />
        <TreeItem value="surfaces" label="Surfaces" href="#surfaces" />
      </TreeItem>
      <TreeItem value="design" label="Design language" href="#design" />
    </TreeView>
  );
}
