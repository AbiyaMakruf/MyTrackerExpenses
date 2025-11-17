<?php

namespace App\Livewire\Admin;

use App\Models\CategoryIcon;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class Dashboard extends Component
{
    public array $iconForm = [
        'name' => '',
        'icon_key' => '',
        'icon_type' => 'icon',
        'description' => '',
    ];

    public function mount(): void
    {
        Gate::authorize('access-admin');
    }

    public function saveIcon(): void
    {
        $data = $this->validate([
            'iconForm.name' => ['required', 'string'],
            'iconForm.icon_key' => ['required', 'string', 'max:191', Rule::unique('category_icons', 'icon_key')],
            'iconForm.icon_type' => ['required', Rule::in(['icon', 'emoji'])],
            'iconForm.description' => ['nullable', 'string', 'max:255'],
        ])['iconForm'];

        CategoryIcon::create([
            ...$data,
            'is_active' => true,
        ]);

        $this->iconForm = [
            'name' => '',
            'icon_key' => '',
            'icon_type' => 'icon',
            'description' => '',
        ];

        session()->flash('admin_status', 'Icon saved');
    }

    public function deleteIcon(int $iconId): void
    {
        CategoryIcon::findOrFail($iconId)->delete();
        session()->flash('admin_status', 'Icon deleted');
    }

    public function render(): View
    {
        $users = User::query()
            ->select(['id', 'name', 'email', 'created_at', 'last_active_at', 'role'])
            ->latest()
            ->limit(10)
            ->get();

        $stats = [
            'total_users' => User::count(),
            'active_users' => User::where('last_active_at', '>=', now()->subDays(30))->count(),
            'transactions' => Transaction::count(),
            'transactions_today' => Transaction::whereDate('transaction_date', today())->count(),
        ];

        $transactionsPerDay = Transaction::query()
            ->selectRaw('DATE(transaction_date) as date, COUNT(*) as total')
            ->where('transaction_date', '>=', now()->subDays(14))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $icons = CategoryIcon::orderBy('name')->get();

        return view('livewire.admin.dashboard', [
            'stats' => $stats,
            'users' => $users,
            'transactionsPerDay' => $transactionsPerDay,
            'icons' => $icons,
            'globalSettings' => config('myexpenses.admin.global_settings'),
        ]);
    }
}
