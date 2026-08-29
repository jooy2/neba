import {
  AppLogo,
  Button,
  Footer,
  Header,
  List,
  ListItem,
  PageLayout,
  Sidebar,
  SidebarTrigger,
  TextLink,
  Typography
} from 'neba';

export default function PageLayoutHero() {
  return (
    <div className="h-96 w-full overflow-hidden rounded-(--neba-radius-md) border border-(--neba-border)">
      <PageLayout
        height="auto"
        scroll="content"
        collapseBelow="sm"
        header={
          <Header
            brand={
              <>
                <SidebarTrigger />
                <AppLogo name="Neba" shape="app" showName size="sm" />
              </>
            }
            actions={
              <Button size="sm" variant="outline">
                Sign in
              </Button>
            }
          />
        }
        sidebar={
          <Sidebar label="Sections">
            <List variant="text" size="sm">
              <ListItem href="#" selected>
                Overview
              </ListItem>
              <ListItem href="#">Components</ListItem>
              <ListItem href="#">Design</ListItem>
            </List>
          </Sidebar>
        }
        footer={
          <Footer>
            <Typography level="caption" color="secondary">
              © 2026 Neba
            </Typography>
          </Footer>
        }
      >
        <div className="flex flex-col gap-2 p-5">
          <Typography level="h5">Overview</Typography>
          <Typography color="secondary">
            The header, the sidebar and the footer are slots. This is the{' '}
            <TextLink href="#">main</TextLink> landmark between them.
          </Typography>
        </div>
      </PageLayout>
    </div>
  );
}
