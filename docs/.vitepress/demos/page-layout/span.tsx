import { useState } from 'react';
import {
  AppLogo,
  Header,
  List,
  ListItem,
  PageLayout,
  SegmentedButton,
  Segment,
  Sidebar,
  Typography
} from 'neba';

type Span = 'full' | 'content';

export default function PageLayoutSpan() {
  const [span, setSpan] = useState<Span>('full');

  return (
    <div className="flex w-full flex-col gap-4">
      <SegmentedButton size="sm" value={span} onValueChange={(next) => setSpan(next as Span)}>
        <Segment value="full">headerSpan=&quot;full&quot;</Segment>
        <Segment value="content">headerSpan=&quot;content&quot;</Segment>
      </SegmentedButton>

      <div className="h-72 w-full overflow-hidden rounded-(--neba-radius-md) border border-(--neba-border)">
        <PageLayout
          height="auto"
          scroll="content"
          collapseBelow="none"
          headerSpan={span}
          mainId="page-layout-span"
          header={<Header brand={<AppLogo name="Neba" showName size="sm" />} />}
          sidebar={
            <Sidebar label="Sections" width={160}>
              <List variant="text" size="sm">
                <ListItem href="#" selected>
                  Overview
                </ListItem>
                <ListItem href="#">Components</ListItem>
              </List>
            </Sidebar>
          }
        >
          <div className="p-5">
            <Typography color="secondary">
              {span === 'full'
                ? 'The bar takes the corner: a website.'
                : 'The rail takes the corner: an application.'}
            </Typography>
          </div>
        </PageLayout>
      </div>
    </div>
  );
}
