import { AnimateRotate, Icon } from 'neba';

function GearIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="2.5" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M8 1v2M8 13v2M1 8h2M13 8h2M3.1 3.1l1.4 1.4M11.5 11.5l1.4 1.4M12.9 3.1l-1.4 1.4M4.5 11.5l-1.4 1.4"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

/* Two angles and no fade is what turns an arrival into a spin. */
export default function AnimateRotateSpin() {
  return (
    <div className="flex items-center gap-6">
      <AnimateRotate
        from={0}
        to={360}
        repeat="infinite"
        easing="linear"
        fade={false}
        duration={2400}
      >
        <Icon icon={<GearIcon />} size="lg" color="primary" label="Working" />
      </AnimateRotate>

      <AnimateRotate
        from={0}
        to={-360}
        repeat="infinite"
        easing="linear"
        fade={false}
        duration={1400}
      >
        <Icon icon={<GearIcon />} size="md" color="secondary" label="Working faster" />
      </AnimateRotate>
    </div>
  );
}
