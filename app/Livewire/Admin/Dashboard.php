<?php

namespace App\Livewire\Admin;

use App\Models\Icon;
use App\Models\Transaction;
use App\Models\User;
use App\Services\GoogleCloudStorage;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithFileUploads;
use Livewire\WithPagination;

#[Layout('layouts.app')]
class Dashboard extends Component
{
    use WithFileUploads;
    use WithPagination;

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
    public int $perPage = 20;

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

        $filename = Str::uuid()->toString().'.'.$this->iconUpload->getClientOriginalExtension();
        $relativePath = 'icons/custom/'.$filename;
        $disk = config('filesystems.icons_disk', 'public');

        if ($disk === 'gcs') {
            app(GoogleCloudStorage::class)->upload($this->iconUpload, $relativePath);
        } else {
            $this->iconUpload->storeAs('icons/custom', $filename, $disk);
        }

        Icon::create([
            'type' => 'image',
            'label' => $this->customIconForm['label'],
            'image_path' => $relativePath,
            'image_disk' => $disk,
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
            $this->deleteIconFile($icon);
        }

        $icon->wallets()->update(['icon_id' => null]);
        $icon->categories()->update(['icon_id' => null]);

        $icon->delete();
        session()->flash('admin_status', 'Icon deleted');
    }

    protected function deleteIconFile(Icon $icon): void
    {
        $disk = $icon->image_disk ?: config('filesystems.icons_disk', 'public');

        if ($disk === 'gcs') {
            try {
                app(GoogleCloudStorage::class)->delete($icon->image_path);
            } catch (\Throwable $exception) {
                report($exception);
            }

            return;
        }

        Storage::disk($disk)->delete($icon->image_path);
    }

    public function toggleIcon(int $iconId): void
    {
        $icon = Icon::findOrFail($iconId);
        $icon->update(['is_active' => ! $icon->is_active]);
    }

    public function updatingIconSearch(): void
    {
        $this->resetPage('fa_page');
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
                $searchTerm = $this->iconSearch;
                $searchLabel = str_replace('-', ' ', $searchTerm);

                $query->where(function ($sub) use ($searchTerm, $searchLabel) {
                    $sub->where('label', 'like', '%'.$searchTerm.'%')
                        ->orWhere('label', 'like', '%'.$searchLabel.'%')
                        ->orWhere('fa_class', 'like', '%'.$searchTerm.'%');
                });
            })
            ->orderBy('label');

        $fontawesomeIcons = (clone $iconsQuery)->where('type', 'fontawesome')->paginate($this->perPage, ['*'], 'fa_page');
        $customIcons = (clone $iconsQuery)->where('type', 'image')->get();

        $this->dispatch('refresh-fontawesome');

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
