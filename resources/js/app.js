import Chart from 'chart.js/auto';

const chartInstances = new WeakMap();

const bootCharts = () => {
    document.querySelectorAll('[data-chart] canvas').forEach((canvas) => {
        const payload = canvas.dataset.chart ? JSON.parse(canvas.dataset.chart) : null;
        if (!payload) {
            return;
        }

        if (chartInstances.has(canvas)) {
            chartInstances.get(canvas).destroy();
        }

        const instance = new Chart(canvas, {
            type: payload.type ?? 'line',
            data: payload.data,
            options: payload.options ?? {
                responsive: true,
                maintainAspectRatio: false,
            },
        });

        chartInstances.set(canvas, instance);
    });
};

document.addEventListener('DOMContentLoaded', bootCharts);
document.addEventListener('livewire:navigated', bootCharts);
