<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Transactions Export</title>
    <style>
        body {
            font-family: sans-serif;
            font-size: 12px;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f4f4f4;
            font-weight: bold;
        }
        .header {
            margin-bottom: 20px;
        }
        .header h1 {
            margin: 0;
            color: #095C4A;
        }
        .header p {
            margin: 5px 0 0;
            color: #666;
        }
        .amount-income {
            color: #08745C;
        }
        .amount-expense {
            color: #DC2626;
        }
        .badge {
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 10px;
            background-color: #eee;
        }
        .summary {
            margin-bottom: 20px;
            padding: 12px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            background: #f8fafc;
        }
        .summary h2 {
            margin: 0 0 8px 0;
            color: #095C4A;
        }
        .bar-container {
            width: 100%;
            background: #e2e8f0;
            border-radius: 8px;
            overflow: hidden;
            height: 12px;
            margin-top: 4px;
        }
        .bar-fill {
            height: 100%;
            background: linear-gradient(90deg, #10B981, #14A58A);
        }
        .bar-fill.expense {
            background: linear-gradient(90deg, #FB7185, #E11D48);
        }
        .summary-grid {
            display: table;
            width: 100%;
            border-spacing: 12px 0;
        }
        .summary-col {
            display: table-cell;
            vertical-align: top;
            width: 50%;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Transaction Report</h1>
        <p>Generated on {{ now()->format('d M Y H:i') }}</p>
        @if($start && $end)
            <p>Period: {{ $start->format('d M Y') }} - {{ $end->format('d M Y') }}</p>
        @endif
    </div>

    @if(isset($summary))
        @php
            $incomePercent = $summary['income_total'] > 0 ? round(($summary['income_total'] / $summary['max_total']) * 100) : 0;
            $expensePercent = $summary['expense_total'] > 0 ? round(($summary['expense_total'] / $summary['max_total']) * 100) : 0;
        @endphp
        <div class="summary">
            <h2>Summary</h2>
            <div class="summary-grid">
                <div class="summary-col">
                    <strong>Total Income:</strong> {{ number_format($summary['income_total'], 0) }}<br>
                    <div class="bar-container">
                        <div class="bar-fill" style="width: {{ $incomePercent }}%;"></div>
                    </div>
                    <strong>Total Expense:</strong> {{ number_format($summary['expense_total'], 0) }}<br>
                    <div class="bar-container">
                        <div class="bar-fill expense" style="width: {{ $expensePercent }}%;"></div>
                    </div>
                    <strong>Net:</strong>
                    @php $net = $summary['net_total']; @endphp
                    <span style="color: {{ $net >= 0 ? '#08745C' : '#DC2626' }};">
                        {{ $net >= 0 ? '+' : '-' }}{{ number_format(abs($net), 0) }}
                    </span>
                </div>
                <div class="summary-col">
                    <strong>Top Income Categories</strong>
                    @forelse($summary['top_income_categories'] as $cat)
                        @php
                            $pct = $summary['income_total'] > 0 ? round(($cat['amount'] / $summary['income_total']) * 100) : 0;
                        @endphp
                        <div style="margin-top: 6px;">
                            {{ $cat['name'] }} ({{ number_format($cat['amount'], 0) }}) - {{ $pct }}%
                            <div class="bar-container">
                                <div class="bar-fill" style="width: {{ $pct }}%;"></div>
                            </div>
                        </div>
                    @empty
                        <p style="margin-top: 4px; color: #6b7280;">No income data.</p>
                    @endforelse

                    <strong style="display: block; margin-top: 10px;">Top Expense Categories</strong>
                    @forelse($summary['top_expense_categories'] as $cat)
                        @php
                            $pct = $summary['expense_total'] > 0 ? round(($cat['amount'] / $summary['expense_total']) * 100) : 0;
                        @endphp
                        <div style="margin-top: 6px;">
                            {{ $cat['name'] }} ({{ number_format($cat['amount'], 0) }}) - {{ $pct }}%
                            <div class="bar-container">
                                <div class="bar-fill expense" style="width: {{ $pct }}%;"></div>
                            </div>
                        </div>
                    @empty
                        <p style="margin-top: 4px; color: #6b7280;">No expense data.</p>
                    @endforelse
                </div>
            </div>
        </div>
    @endif

    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Type</th>
                <th>Wallet</th>
                <th>Category</th>
                <th style="text-align: right;">Amount</th>
                <th>Note</th>
            </tr>
        </thead>
        <tbody>
            @foreach($transactions as $transaction)
                <tr>
                    <td>{{ $transaction->transaction_date->format('d M Y H:i') }}</td>
                    <td>{{ ucfirst($transaction->type) }}</td>
                    <td>{{ $transaction->wallet->name ?? '-' }}</td>
                    <td>
                        {{ $transaction->category->name ?? '-' }}
                        @if($transaction->subCategory)
                            <br><small class="text-gray-500">{{ $transaction->subCategory->name }}</small>
                        @endif
                    </td>
                    <td style="text-align: right;" class="{{ $transaction->type === 'income' ? 'amount-income' : ($transaction->type === 'expense' ? 'amount-expense' : '') }}">
                        {{ number_format($transaction->amount, 0) }} {{ $transaction->currency }}
                    </td>
                    <td>{{ $transaction->note }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
