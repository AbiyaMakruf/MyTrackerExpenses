import Chart from 'chart.js/auto';
import flatpickr from 'flatpickr';
import { library, findIconDefinition, icon } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { far } from '@fortawesome/free-regular-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';

library.add(fas, far, fab);

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

const initPickers = () => {
    document.querySelectorAll('[data-datepicker]').forEach((input) => {
        if (input._flatpickr) {
            return;
        }

        flatpickr(input, {
            dateFormat: 'Y-m-d',
            disableMobile: true,
            allowInput: false,
        });
    });

    document.querySelectorAll('[data-datetimepicker]').forEach((input) => {
        if (input._flatpickr) {
            return;
        }

        flatpickr(input, {
            enableTime: true,
            dateFormat: "Y-m-d\\TH:i",
            time_24hr: true,
            disableMobile: true,
            allowInput: false,
        });
    });
};

const renderFontAwesome = () => {
    document.querySelectorAll('[data-fa-icon]').forEach((el) => {
        const value = el.dataset.faIcon;
        if (!value) {
            return;
        }

        const [rawPrefix, rawName] = value.includes(':') ? value.split(':') : value.split('-');
        const prefix = rawPrefix && rawPrefix.length ? rawPrefix : 'fas';
        const iconName = (rawName || '').trim();

        if (!iconName) {
            return;
        }

        try {
            const definition = findIconDefinition({ prefix, iconName });
            if (!definition) {
                return;
            }

            const rendered = icon(definition, {
                classes: (el.dataset.faClasses || '').split(' ').filter(Boolean),
            });

            if (rendered && rendered.node[0]) {
                el.innerHTML = '';
                el.appendChild(rendered.node[0]);
            } else {
                el.innerHTML = '';
            }
        } catch (error) {
            console.warn('Failed to render icon', value, error);
        }
    });
};

const sanitizeMoney = (value) => {
    if (!value) {
        return '';
    }

    const sanitized = value.replace(/[^\d.]/g, '');
    const parts = sanitized.split('.');
    const integer = parts[0];
    const decimal = parts[1] ? parts[1].slice(0, 2) : '';

    return decimal ? `${integer}.${decimal}` : integer;
};

const formatMoney = (value) => {
    if (!value) {
        return '';
    }

    const [integer, decimal] = value.split('.');
    const formattedInt = integer.replace(/\B(?=(\d{3})+(?!\d))/g, ',');

    return decimal !== undefined && decimal.length
        ? `${formattedInt}.${decimal}`
        : formattedInt;
};

const formatExistingMoneyInputs = () => {
    document.querySelectorAll('[data-money-input]').forEach((input) => {
        const raw = sanitizeMoney(input.value);
        input.dataset.moneyRaw = raw;
        input.value = formatMoney(raw);
    });
};

let moneyMaskInitialized = false;

const bootMoneyMask = () => {
    formatExistingMoneyInputs();

    if (moneyMaskInitialized) {
        return;
    }

    document.addEventListener(
        'input',
        (event) => {
            const input = event.target;
            if (!input.matches('[data-money-input]')) {
                return;
            }

            const raw = sanitizeMoney(input.value);
            const formatted = formatMoney(raw);

            input.dataset.moneyRaw = raw;
            input.value = raw;

            requestAnimationFrame(() => {
                input.value = formatted;
                if (document.activeElement === input) {
                    input.setSelectionRange(formatted.length, formatted.length);
                }
            });
        },
        true,
    );

    moneyMaskInitialized = true;
};

const bootInteractive = () => {
    bootCharts();
    initPickers();
    renderFontAwesome();
    bootMoneyMask();
};

const registerLivewireHooks = () => {
    if (window.__interactiveHookAttached) {
        return;
    }

    if (typeof window.Livewire?.hook === 'function') {
        window.Livewire.hook('message.processed', () => {
            requestAnimationFrame(bootInteractive);
        });
        window.__interactiveHookAttached = true;
    }
};

document.addEventListener('DOMContentLoaded', () => {
    bootInteractive();
    registerLivewireHooks();
});

document.addEventListener('livewire:initialized', registerLivewireHooks);
document.addEventListener('livewire:init', registerLivewireHooks);
document.addEventListener('livewire:navigated', bootInteractive);
document.addEventListener('livewire:update', () => requestAnimationFrame(renderFontAwesome));
document.addEventListener('refresh-fontawesome', () => requestAnimationFrame(renderFontAwesome));
