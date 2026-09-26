import { TreeSelect, type TreeSelectItem } from 'neba';

const CATEGORIES: TreeSelectItem[] = [
  {
    value: 'hardware',
    label: 'Hardware',
    children: [
      { value: 'laptops', label: 'Laptops' },
      { value: 'monitors', label: 'Monitors' }
    ]
  },
  {
    value: 'software',
    label: 'Software',
    children: [
      { value: 'design', label: 'Design tools' },
      { value: 'infra', label: 'Infrastructure' }
    ]
  }
];

export default function TreeSelectLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <TreeSelect
        labelPlacement="notch"
        label="Notch"
        placeholder="Pick a category"
        items={CATEGORIES}
        defaultValue={['laptops']}
      />
      <TreeSelect
        labelPlacement="float"
        label="Float"
        placeholder="Pick a category"
        items={CATEGORIES}
      />
    </div>
  );
}
