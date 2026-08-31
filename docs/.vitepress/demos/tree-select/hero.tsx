import { useState } from 'react';
import { TreeSelect, type TreeSelectItem, type TreeViewValue } from 'neba';

const CATEGORIES: TreeSelectItem[] = [
  {
    value: 'hardware',
    label: 'Hardware',
    children: [
      { value: 'laptops', label: 'Laptops' },
      { value: 'monitors', label: 'Monitors' },
      { value: 'peripherals', label: 'Peripherals' }
    ]
  },
  {
    value: 'software',
    label: 'Software',
    children: [
      { value: 'design', label: 'Design tools' },
      { value: 'infra', label: 'Infrastructure' },
      { value: 'legacy', label: 'Legacy licences', disabled: true }
    ]
  },
  {
    value: 'services',
    label: 'Services',
    children: [
      { value: 'support', label: 'Support contracts' },
      { value: 'training', label: 'Training' }
    ]
  }
];

export default function TreeSelectHero() {
  const [one, setOne] = useState<TreeViewValue[]>(['laptops']);
  const [many, setMany] = useState<TreeViewValue[]>([]);

  return (
    <div className="flex flex-wrap items-end gap-4">
      <TreeSelect
        label="Category"
        placeholder="Pick a category"
        items={CATEGORIES}
        value={one}
        onValueChange={setOne}
        defaultExpanded={['hardware']}
        clearable
      />

      <TreeSelect
        label="Watching"
        placeholder="Pick any number"
        items={CATEGORIES}
        multiple
        searchable
        value={many}
        onValueChange={setMany}
        format={(chosen) => (chosen.length === 1 ? chosen[0].label : `${chosen.length} categories`)}
        clearable
      />
    </div>
  );
}
