import { Card, HeatmapChart } from 'neba';

const STAGES = [
  'Signed up',
  'Email verified',
  'Team invited',
  'Repo connected',
  'PR opened',
  'PR merged',
  'Deployed'
];

const COHORTS = [
  { name: 'Week 1', data: [980, 830, 520, 430, 290, 210, 120] },
  { name: 'Week 2', data: [1040, 910, 610, 520, 360, 270, 180] },
  { name: 'Week 3', data: [880, 760, 480, 400, 250, 190, 110] },
  { name: 'Week 4', data: [1210, 1080, 740, 640, 470, 360, 250] }
];

export default function HeatmapChartAxes() {
  return (
    <Card title="Onboarding by cohort" subtitle="Accounts reaching each stage" className="w-full">
      <HeatmapChart
        label="Accounts reaching each onboarding stage, by cohort"
        categories={STAGES}
        series={COHORTS}
        xAxis={{ label: 'Stage', tickAngle: -45 }}
        yAxis={{ label: 'Cohort' }}
      />
    </Card>
  );
}
