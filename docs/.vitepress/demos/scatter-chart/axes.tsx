import { Card, ScatterChart } from 'neba';

const READINGS = [
  { x: -8, y: 412 },
  { x: -3, y: 388 },
  { x: 2, y: 341 },
  { x: 6, y: 310 },
  { x: 11, y: 264 },
  { x: 15, y: 238 },
  { x: 19, y: 201 },
  { x: 24, y: 176 },
  { x: 28, y: 168 },
  { x: 31, y: 155 }
];

/**
 * Neither axis is dragged down to zero — a scatter is about where the cloud
 * sits, and a scale that starts at zero on both axes would push all of it into
 * one corner. `min` and `max` pin an axis when a comparison needs a fixed frame.
 */
export default function ScatterChartAxes() {
  return (
    <Card title="Heating load" subtitle="Against outdoor temperature" className="w-full">
      <ScatterChart
        label="Heating load against outdoor temperature"
        xAxis={{ label: 'Outdoor °C', min: -10, max: 35, tickFormat: (value) => `${value}°` }}
        yAxis={{ label: 'kWh per day', grid: false }}
        pointRadius={5}
        series={[{ name: 'Readings', data: READINGS, color: 'warning' }]}
      />
    </Card>
  );
}
