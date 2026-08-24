import { Typography, WindowPane } from 'neba';

export default function WindowPaneAppearance() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-2">
      <WindowPane os="windows10" title="Accent" accent color="primary" height={120}>
        <div className="p-3">
          <Typography level="caption" color="secondary">
            accent · color=&quot;primary&quot;
          </Typography>
        </div>
      </WindowPane>

      <WindowPane os="macos" title="Translucent" transparency={0.45} height={120}>
        <div className="p-3">
          <Typography level="caption" color="secondary">
            transparency=&#123;0.45&#125;
          </Typography>
        </div>
      </WindowPane>

      <WindowPane os="macos" title="Flat" elevation={0} height={120}>
        <div className="p-3">
          <Typography level="caption" color="secondary">
            elevation=&#123;0&#125;
          </Typography>
        </div>
      </WindowPane>

      <WindowPane os="linux" title="Behind" active={false} height={120}>
        <div className="p-3">
          <Typography level="caption" color="secondary">
            active=&#123;false&#125;
          </Typography>
        </div>
      </WindowPane>
    </div>
  );
}
