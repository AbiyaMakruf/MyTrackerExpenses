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
