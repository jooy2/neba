import { Divider, Typography, WindowPane } from 'neba';

export default function WindowPaneHero() {
  return (
    <WindowPane title="Notes" width="100%" height={280} elevation={2}>
      <div className="flex h-full">
        <div className="w-40 shrink-0 bg-(--neba-primary-soft) p-3">
          <Typography level="caption" color="secondary">
            Folders
          </Typography>
          <div className="mt-2 flex flex-col gap-2">
            {['All', 'Work', 'Recipes', 'Trips'].map((folder) => (
              <Typography key={folder} level="body">
                {folder}
              </Typography>
            ))}
          </div>
        </div>

        <div className="flex-1 p-4">
          <Typography level="h6">Cold brew, third attempt</Typography>
          <Typography level="caption" color="secondary">
            Edited 4 minutes ago
          </Typography>
          <Divider className="my-3" />
          <Typography>
            Coarse grind, 1:8, sixteen hours on the counter. Strained twice. Less bitter than the
            last one and it keeps for a week.
          </Typography>
        </div>
      </div>
    </WindowPane>
  );
}
