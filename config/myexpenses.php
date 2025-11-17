<?php

return [
    'name' => env('APP_NAME', 'My Expenses'),
    'tagline' => env('APP_TAGLINE', 'Track your money, every day.'),
    'default_language' => env('APP_LOCALE', 'en'),
    'default_timezone' => env('APP_TIMEZONE', 'Asia/Jakarta'),
    'default_datetime_format' => env('APP_DATETIME_FORMAT', 'd-m-Y H:i'),
    'chart_library' => env('CHART_LIBRARY', 'chartjs'),
    'button_style' => env('BUTTON_STYLE', 'rounded-full'),
    'font_families' => [
        'primary' => env('APP_FONT_PRIMARY', 'Inter'),
        'secondary' => env('APP_FONT_SECONDARY', 'Nunito'),
    ],
    'logo_url' => env('APP_LOGO_URL'),
    'colors' => [
        'primary' => '#095C4A',
        'secondary' => '#08745C',
        'accent' => '#15B489',
        'light_accent' => '#72E3BD',
        'background_soft' => '#D2F9E7',
    ],
    'currency' => [
        'default' => env('BASE_CURRENCY', 'IDR'),
        'supported' => ['IDR', 'USD'],
    ],
    'dashboard' => [
        'default_period' => env('DEFAULT_DASHBOARD_PERIOD', '30_days'),
        'default_filter' => env('DASHBOARD_DEFAULT_FILTER', 'this_month'),
    ],
    'records' => [
        'allow_receipt_upload' => filter_var(env('ALLOW_RECEIPT_UPLOAD', true), FILTER_VALIDATE_BOOLEAN),
    ],
    'planning' => [
        'planned_payment_repeat_options' => explode(',', env('PLANNED_PAYMENT_REPEAT_OPTIONS', 'none,weekly,monthly,yearly')),
        'budget_period_options' => explode(',', env('BUDGET_PERIOD_OPTIONS', 'weekly,monthly,custom')),
    ],
    'statistics' => [
        'default_view' => env('STAT_DEFAULT_VIEW', 'monthly'),
        'top_n_categories' => (int) env('TOP_N_CATEGORIES', 5),
    ],
    'profile' => [
        'extra_fields' => explode(',', env('PROFILE_EXTRA_FIELDS', 'profession,salary_range')),
    ],
    'wallets' => [
        'default_name' => env('DEFAULT_WALLET_NAME', 'Main Wallet'),
        'types' => explode(',', env('WALLET_TYPE_OPTIONS', 'bank,e-wallet,cash,investment')),
    ],
    'pdf' => [
        'signature_text' => env('PDF_SIGNATURE_TEXT'),
        'include_attachments' => filter_var(env('PDF_INCLUDE_ATTACHMENTS', false), FILTER_VALIDATE_BOOLEAN),
    ],
    'admin' => [
        'stats_extra' => explode(',', env('ADMIN_STATS_EXTRA', 'transactions_per_day')),
        'global_settings' => explode(',', env('ADMIN_GLOBAL_SETTINGS', 'max_attachment_size_mb')),
    ],
];
