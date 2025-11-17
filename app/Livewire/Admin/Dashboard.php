<?php

namespace App\Livewire\Admin;

use App\Models\CategoryIcon;
use App\Models\Transaction;
use App\Models\User;
use App\Models\WalletIcon;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithFileUploads;

#[Layout('layouts.app')]
class Dashboard extends Component
{
    use WithFileUploads;

    public array $iconForm = [
        'name' => '',
        'icon_key' => '',
        'icon_type' => 'icon',
        'description' => '',
    ];

    public array $walletIconForm = [
        'name' => '',
        'source_type' => 'class',
        'value' => '',
        'icon_color' => '#095C4A',
        'background_color' => '#D2F9E7',
    ];

    public $walletIconUpload;

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

    public function saveWalletIcon(): void
    {
        $data = $this->validate([
            'walletIconForm.name' => ['required', 'string', 'max:255'],
            'walletIconForm.source_type' => ['required', Rule::in(['class', 'upload'])],
            'walletIconForm.value' => [Rule::requiredIf($this->walletIconForm['source_type'] === 'class'), 'string', 'max:191'],
            'walletIconForm.icon_color' => ['nullable', 'string'],
            'walletIconForm.background_color' => ['nullable', 'string'],
            'walletIconUpload' => [Rule::requiredIf($this->walletIconForm['source_type'] === 'upload'), 'image', 'max:1024'],
        ]);

        $value = $this->walletIconForm['value'];

        if ($this->walletIconForm['source_type'] === 'upload' && $this->walletIconUpload) {
            $value = $this->walletIconUpload->store('wallet-icons', 'public');
        }

        WalletIcon::create([
            'name' => $this->walletIconForm['name'],
            'source_type' => $this->walletIconForm['source_type'],
            'value' => $value,
            'icon_color' => $this->walletIconForm['icon_color'],
            'background_color' => $this->walletIconForm['background_color'],
        ]);

        $this->walletIconForm = [
            'name' => '',
            'source_type' => 'class',
            'value' => '',
            'icon_color' => '#095C4A',
            'background_color' => '#D2F9E7',
        ];
        $this->walletIconUpload = null;

        session()->flash('admin_status', 'Wallet icon saved');
    }

    public function deleteWalletIcon(int $iconId): void
    {
        $icon = WalletIcon::findOrFail($iconId);

        if ($icon->source_type === 'upload') {
            Storage::disk('public')->delete($icon->value);
        }

        $icon->delete();
        session()->flash('admin_status', 'Wallet icon deleted');
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
            'walletIcons' => WalletIcon::orderBy('name')->get(),
            'globalSettings' => config('myexpenses.admin.global_settings'),
        ]);
    }
}
