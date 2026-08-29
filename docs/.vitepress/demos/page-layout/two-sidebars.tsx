import { Header, List, ListItem, PageLayout, Sidebar, Typography } from 'neba';

export default function PageLayoutTwoSidebars() {
  return (
    <div className="h-72 w-full overflow-hidden rounded-(--neba-radius-md) border border-(--neba-border)">
      <PageLayout
        height="auto"
        scroll="content"
        collapseBelow="none"
        mainId="page-layout-contents"
        header={<Header>Reference</Header>}
        sidebar={
          <Sidebar label="Sections" width={150}>
            <List variant="text" size="sm">
              <ListItem href="#" selected>
                Button
              </ListItem>
              <ListItem href="#">Card</ListItem>
            </List>
          </Sidebar>
        }
        endSidebar={
          <Sidebar label="On this page" width={150} variant="text">
            <Typography level="overline">On this page</Typography>
            <List variant="text" size="sm">
              <ListItem href="#">Props</ListItem>
              <ListItem href="#">Examples</ListItem>
            </List>
          </Sidebar>
        }
      >
        <div className="p-5">
          <Typography level="h6">Button</Typography>
          <Typography color="secondary">
            Navigation down one side, contents down the other.
          </Typography>
        </div>
      </PageLayout>
    </div>
  );
}
