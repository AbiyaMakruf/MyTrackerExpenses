<?php

namespace App\Livewire\Admin;

use App\Models\Icon;
use App\Models\Transaction;
use App\Models\User;
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

    public array $fontawesomeForm = [
        'label' => '',
        'fa_class' => '',
        'group' => 'general',
    ];

    public array $customIconForm = [
        'label' => '',
        'group' => 'general',
    ];

    public $iconUpload;

    public string $iconTab = 'fontawesome';

    public string $iconSearch = '';

    public function mount(): void
    {
        Gate::authorize('access-admin');
    }

    public function saveFontawesomeIcon(): void
    {
        $data = $this->validate([
            'fontawesomeForm.label' => ['required', 'string', 'max:255'],
            'fontawesomeForm.fa_class' => ['required', 'string', 'max:191', Rule::unique('icons', 'fa_class')],
            'fontawesomeForm.group' => ['nullable', 'string', 'max:191'],
        ])['fontawesomeForm'];

        Icon::create([
            'type' => 'fontawesome',
            'label' => $data['label'],
            'fa_class' => $data['fa_class'],
            'group' => $data['group'],
            'created_by' => auth()->id(),
            'is_active' => true,
        ]);

        $this->fontawesomeForm = [
            'label' => '',
            'fa_class' => '',
            'group' => 'general',
        ];

        session()->flash('admin_status', 'FontAwesome icon saved');
    }

    public function saveCustomIcon(): void
    {
        $this->validate([
            'customIconForm.label' => ['required', 'string', 'max:255'],
            'customIconForm.group' => ['nullable', 'string', 'max:191'],
            'iconUpload' => ['required', 'image', 'max:1024'],
        ]);

        $path = $this->iconUpload->store('icons/custom', 'public');

        Icon::create([
            'type' => 'image',
            'label' => $this->customIconForm['label'],
            'image_path' => $path,
            'group' => $this->customIconForm['group'],
            'created_by' => auth()->id(),
            'is_active' => true,
        ]);

        $this->customIconForm = [
            'label' => '',
            'group' => 'general',
        ];
        $this->iconUpload = null;

        session()->flash('admin_status', 'Custom icon saved');
    }

    public function deleteIcon(int $iconId): void
    {
        $icon = Icon::findOrFail($iconId);

        if ($icon->type === 'image' && $icon->image_path) {
            Storage::disk('public')->delete($icon->image_path);
        }

        $icon->wallets()->update(['icon_id' => null]);
        $icon->categories()->update(['icon_id' => null]);

        $icon->delete();
        session()->flash('admin_status', 'Icon deleted');
    }

    public function toggleIcon(int $iconId): void
    {
        $icon = Icon::findOrFail($iconId);
        $icon->update(['is_active' => ! $icon->is_active]);
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

        $iconsQuery = Icon::query()
            ->when($this->iconSearch, function ($query) {
                $query->where(function ($sub) {
                    $sub->where('label', 'like', '%'.$this->iconSearch.'%')
                        ->orWhere('fa_class', 'like', '%'.$this->iconSearch.'%');
                });
            })
            ->orderBy('label');

        $fontawesomeIcons = (clone $iconsQuery)->where('type', 'fontawesome')->get();
        $customIcons = (clone $iconsQuery)->where('type', 'image')->get();

        return view('livewire.admin.dashboard', [
            'stats' => $stats,
            'users' => $users,
            'transactionsPerDay' => $transactionsPerDay,
            'fontawesomeIcons' => $fontawesomeIcons,
            'customIcons' => $customIcons,
            'globalSettings' => config('myexpenses.admin.global_settings'),
        ]);
    }
}
