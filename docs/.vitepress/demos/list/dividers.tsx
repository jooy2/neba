import { List, ListItem } from 'neba';

const REGIONS = [
  { name: 'Seoul', code: 'icn' },
  { name: 'Tokyo', code: 'nrt' },
  { name: 'Frankfurt', code: 'fra' }
];

export default function ListDividers() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      {/* Tiles on a sheet. */}
      <List>
        {REGIONS.map((region) => (
          <ListItem key={region.code} onClick={() => {}} endIcon={<span>{region.code}</span>}>
            {region.name}
          </ListItem>
        ))}
      </List>

      {/* Ruled lines. The rows square off and the sheet gives up its inset so
          the rules can reach both edges. */}
      <List dividers>
        {REGIONS.map((region) => (
          <ListItem key={region.code} onClick={() => {}} endIcon={<span>{region.code}</span>}>
            {region.name}
          </ListItem>
        ))}
      </List>
    </div>
  );
}
