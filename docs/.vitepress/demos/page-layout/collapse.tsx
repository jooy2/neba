import {
  AppLogo,
  Header,
  List,
  ListItem,
  PageLayout,
  Sidebar,
  SidebarTrigger,
  Typography
} from 'neba';

export default function PageLayoutCollapse() {
  return (
    <div className="h-80 w-full max-w-[26rem] overflow-hidden rounded-(--neba-radius-md) border border-(--neba-border)">
      <PageLayout
        height="auto"
        scroll="content"
        collapseBelow="xl"
        mainId="page-layout-collapse"
        header={
          <Header
            brand={
              <>
                <SidebarTrigger />
                <AppLogo name="Neba" shape="app" size="sm" />
              </>
            }
          />
        }
        sidebar={
          <Sidebar label="Sections" title="Sections">
            <List variant="text" size="sm">
              <ListItem href="#" selected>
                Overview
              </ListItem>
              <ListItem href="#">Components</ListItem>
              <ListItem href="#">Design</ListItem>
            </List>
          </Sidebar>
        }
      >
        <div className="flex flex-col gap-2 p-5">
          <Typography level="h6">Narrow</Typography>
          <Typography color="secondary">
            Below the breakpoint the column is a drawer, and the hamburger is what opens it.
          </Typography>
        </div>
      </PageLayout>
    </div>
  );
}
