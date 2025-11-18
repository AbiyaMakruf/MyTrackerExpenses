<?php

namespace App\Livewire\Profile;

use App\Models\Category;
use App\Models\Icon;
use App\Models\Label;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class SettingsHub extends Component
{
    public array $profileForm = [];
    public array $passwordForm = [
        'current_password' => '',
        'password' => '',
        'password_confirmation' => '',
    ];

    public array $walletForm = [
        'name' => '',
        'type' => 'bank',
        'currency' => null,
        'initial_balance' => null,
        'is_default' => false,
        'icon_id' => null,
        'icon_color' => '#095C4A',
        'icon_background' => '#D2F9E7',
    ];

    public array $labelForm = [
        'name' => '',
        'color' => '',
    ];

    public array $labelPalette = [];

    public bool $iconPickerOpen = false;
    public string $iconPickerContext = 'wallet';
    public string $iconPickerTab = 'fontawesome';
    public string $iconPickerSearch = '';
    public string $iconPickerIconColor = '#095C4A';
    public string $iconPickerBackgroundColor = '#D2F9E7';

    public array $categoryForm = [
        'name' => '',
        'type' => 'expense',
        'icon_id' => null,
        'icon_color' => '#095C4A',
        'icon_background' => '#F6FFFA',
        'parent_id' => null,
    ];

    public ?array $walletIconPreview = null;
    public ?array $categoryIconPreview = null;
    public ?int $editingWalletId = null;
    public ?int $editingCategoryId = null;

    public array $exportForm = [
        'format' => 'csv',
        'date_range' => 'monthly',
        'wallet_id' => null,
        'category_id' => null,
        'transaction_type' => 'all',
        'include_attachments' => false,
        'group_by_category' => false,
        'compress' => false,
        'custom_from' => null,
        'custom_to' => null,
    ];

    public function mount(): void
    {
        $user = Auth::user();
        $this->profileForm = [
            'name' => $user->name,
            'email' => $user->email,
            'base_currency' => $user->base_currency,
            'language' => $user->language,
            'timezone' => $user->timezone,
        ];

        $this->labelPalette = [
            '#095C4A', '#08745C', '#15B489', '#72E3BD', '#0F172A',
            '#1D4ED8', '#2563EB', '#38BDF8', '#F97316', '#EA580C',
            '#DC2626', '#F43F5E', '#EC4899', '#A855F7', '#6366F1',
            '#14B8A6', '#0EA5E9', '#22C55E', '#84CC16', '#FACC15',
        ];

        $this->labelForm['color'] = $this->labelPalette[0];

        $this->resetWalletForm();
        $this->resetCategoryForm();
        $this->syncWalletIconPreview();
        $this->syncCategoryIconPreview();
    }

    public function saveProfile(): void
    {
        $user = Auth::user();
        $data = $this->validate([
            'profileForm.name' => ['required', 'string', 'max:255'],
            'profileForm.email' => ['required', 'email', Rule::unique('users', 'email')->ignore($user->id)],
            'profileForm.base_currency' => ['required', Rule::in(config('myexpenses.currency.supported'))],
            'profileForm.language' => ['required', 'string'],
            'profileForm.timezone' => ['required', 'string'],
        ])['profileForm'];

        $user->update($data);
        session()->flash('profile_status', 'Profile updated');
    }

    public function updatePassword(): void
    {
        $this->validate([
            'passwordForm.current_password' => ['required'],
            'passwordForm.password' => ['required', 'confirmed', 'min:8'],
        ]);

        $user = Auth::user();

        if (! Hash::check($this->passwordForm['current_password'], $user->password)) {
            $this->addError('passwordForm.current_password', 'Current password does not match.');
            return;
        }

        $user->update(['password' => Hash::make($this->passwordForm['password'])]);
        $this->passwordForm = ['current_password' => '', 'password' => '', 'password_confirmation' => ''];
        session()->flash('profile_status', 'Password changed');
    }

    public function saveWallet(): void
    {
        $rules = [
            'walletForm.name' => ['required', 'string', 'max:255'],
            'walletForm.type' => ['required', Rule::in(config('myexpenses.wallets.types'))],
            'walletForm.currency' => ['required', Rule::in(config('myexpenses.currency.supported'))],
            'walletForm.is_default' => ['boolean'],
            'walletForm.icon_id' => ['nullable', Rule::exists('icons', 'id')],
            'walletForm.icon_color' => ['nullable', 'string'],
            'walletForm.icon_background' => ['nullable', 'string'],
        ];

        if ($this->editingWalletId) {
            $rules['walletForm.initial_balance'] = ['nullable', 'numeric', 'min:0'];
        } else {
            $rules['walletForm.initial_balance'] = ['required', 'numeric', 'min:0'];
        }

        $data = $this->validate($rules)['walletForm'];

        if ($this->editingWalletId) {
            $wallet = Wallet::where('user_id', Auth::id())->findOrFail($this->editingWalletId);
            $wallet->update([
                'name' => $data['name'],
                'type' => $data['type'],
                'currency' => $data['currency'],
                'icon_id' => $data['icon_id'],
                'icon_color' => $data['icon_color'] ?: '#095C4A',
                'icon_background' => $data['icon_background'] ?: '#D2F9E7',
            ]);

            if ($data['is_default']) {
                Auth::user()->update(['default_wallet_id' => $wallet->id]);
            }

            $message = 'Wallet updated';
        } else {
            $wallet = Wallet::create([
                ...$data,
                'user_id' => Auth::id(),
                'icon_color' => $data['icon_color'] ?: '#095C4A',
                'icon_background' => $data['icon_background'] ?: '#D2F9E7',
                'current_balance' => $data['initial_balance'],
            ]);

            if ($data['is_default']) {
                Auth::user()->update(['default_wallet_id' => $wallet->id]);
            }

            $message = 'Wallet added';
        }

        $this->resetWalletForm();
        session()->flash('profile_status', $message);
    }

    public function deleteWallet(int $walletId): void
    {
        Wallet::where('user_id', Auth::id())->where('id', $walletId)->delete();
        if ($this->editingWalletId === $walletId) {
            $this->resetWalletForm();
        }
        session()->flash('profile_status', 'Wallet deleted');
    }

    public function editWallet(int $walletId): void
    {
        $wallet = Wallet::where('user_id', Auth::id())->with('iconDefinition')->findOrFail($walletId);

        $this->editingWalletId = $wallet->id;
        $this->walletForm = [
            'name' => $wallet->name,
            'type' => $wallet->type,
            'currency' => $wallet->currency,
            'initial_balance' => $wallet->initial_balance,
            'is_default' => $wallet->is_default,
            'icon_id' => $wallet->icon_id,
            'icon_color' => $wallet->icon_color ?: '#095C4A',
            'icon_background' => $wallet->icon_background ?: '#D2F9E7',
        ];

        $this->syncWalletIconPreview();
    }

    public function cancelWalletEdit(): void
    {
        $this->resetWalletForm();
    }

    public function saveLabel(): void
    {
        $data = $this->validate([
            'labelForm.name' => ['required', 'string', 'max:100'],
            'labelForm.color' => ['required', 'string', Rule::in($this->labelPalette)],
        ])['labelForm'];

        Label::create([
            ...$data,
            'user_id' => Auth::id(),
            'slug' => Str::slug($data['name']),
        ]);

        $this->labelForm = ['name' => '', 'color' => $this->labelPalette[0]];
        session()->flash('profile_status', 'Label saved');
    }

    public function deleteLabel(int $labelId): void
    {
        Label::where('user_id', Auth::id())->where('id', $labelId)->delete();
        session()->flash('profile_status', 'Label removed');
    }

    public function openIconPicker(string $context): void
    {
        $this->iconPickerContext = $context;
        $this->iconPickerOpen = true;
        $this->iconPickerSearch = '';
        $this->iconPickerTab = 'fontawesome';

        if ($context === 'wallet') {
            $this->iconPickerIconColor = $this->walletForm['icon_color'] ?? '#095C4A';
            $this->iconPickerBackgroundColor = $this->walletForm['icon_background'] ?? '#D2F9E7';
        } else {
            $this->iconPickerIconColor = $this->categoryForm['icon_color'] ?? '#095C4A';
            $this->iconPickerBackgroundColor = $this->categoryForm['icon_background'] ?? '#F6FFFA';
        }
    }

    public function closeIconPicker(): void
    {
        $this->iconPickerOpen = false;
    }

    public function selectIconFromPicker(?int $iconId): void
    {
        if ($this->iconPickerContext === 'wallet') {
            $this->walletForm['icon_id'] = $iconId;
            $this->walletForm['icon_color'] = $this->iconPickerIconColor;
            $this->walletForm['icon_background'] = $this->iconPickerBackgroundColor;
            $this->syncWalletIconPreview();
        } else {
            $this->categoryForm['icon_id'] = $iconId;
            $this->categoryForm['icon_color'] = $this->iconPickerIconColor;
            $this->categoryForm['icon_background'] = $this->iconPickerBackgroundColor;
            $this->syncCategoryIconPreview();
        }

        $this->iconPickerOpen = false;
    }

    public function saveCategory(): void
    {
        $data = $this->validate([
            'categoryForm.name' => ['required', 'string', 'max:255'],
            'categoryForm.type' => ['required', Rule::in(['expense', 'income'])],
            'categoryForm.icon_id' => ['nullable', Rule::exists('icons', 'id')],
            'categoryForm.icon_color' => ['nullable', 'string'],
            'categoryForm.icon_background' => ['nullable', 'string'],
            'categoryForm.parent_id' => ['nullable', Rule::exists('categories', 'id')],
        ])['categoryForm'];

        if ($this->editingCategoryId) {
            $category = Category::where('user_id', Auth::id())->findOrFail($this->editingCategoryId);
            $category->update([
                'name' => $data['name'],
                'type' => $data['type'],
                'icon_id' => $data['icon_id'],
                'icon_color' => $data['icon_color'] ?: '#095C4A',
                'icon_background' => $data['icon_background'] ?: '#F6FFFA',
                'parent_id' => $data['parent_id'],
            ]);
            $message = 'Category updated';
        } else {
            Category::create([
                ...$data,
                'user_id' => Auth::id(),
                'icon_color' => $data['icon_color'] ?: '#095C4A',
                'icon_background' => $data['icon_background'] ?: '#F6FFFA',
            ]);
            $message = 'Category saved';
        }

        $this->resetCategoryForm();
        session()->flash('profile_status', $message);
    }

    public function editCategory(int $categoryId): void
    {
        $category = Category::where('user_id', Auth::id())->with('icon')->findOrFail($categoryId);

        $this->editingCategoryId = $category->id;
        $this->categoryForm = [
            'name' => $category->name,
            'type' => $category->type,
            'icon_id' => $category->icon_id,
            'icon_color' => $category->icon_color ?: '#095C4A',
            'icon_background' => $category->icon_background ?: '#F6FFFA',
            'parent_id' => $category->parent_id,
        ];

        $this->syncCategoryIconPreview();
    }

    public function cancelCategoryEdit(): void
    {
        $this->resetCategoryForm();
    }

    public function export(string $format = 'csv')
    {
        $this->exportForm['format'] = $format;
        $data = $this->validate([
            'exportForm.format' => ['required', Rule::in(['csv', 'xlsx', 'pdf'])],
            'exportForm.date_range' => ['required', 'string'],
            'exportForm.wallet_id' => ['nullable', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'exportForm.category_id' => ['nullable', Rule::exists('categories', 'id')],
            'exportForm.transaction_type' => ['required', Rule::in(['all', 'income', 'expense'])],
            'exportForm.include_attachments' => ['boolean'],
            'exportForm.group_by_category' => ['boolean'],
            'exportForm.compress' => ['boolean'],
            'exportForm.custom_from' => [Rule::requiredIf($this->exportForm['date_range'] === 'custom'), 'nullable', 'date'],
            'exportForm.custom_to' => [Rule::requiredIf($this->exportForm['date_range'] === 'custom'), 'nullable', 'date', 'after_or_equal:exportForm.custom_from'],
        ])['exportForm'];

        [$start, $end] = $this->exportRange($data['date_range']);

        $transactions = Transaction::query()
            ->where('user_id', Auth::id())
            ->when($start && $end, fn ($query) => $query->whereBetween('transaction_date', [$start, $end]))
            ->when($data['wallet_id'], fn ($query) => $query->where('wallet_id', $data['wallet_id']))
            ->when($data['category_id'], fn ($query) => $query->where('category_id', $data['category_id']))
            ->when($data['transaction_type'] !== 'all', fn ($query) => $query->where('type', $data['transaction_type']))
            ->with(['wallet', 'category'])
            ->orderBy('transaction_date')
            ->get();

        $filename = 'transactions-' . now()->format('YmdHis') . '.' . $format;

        return Response::streamDownload(function () use ($transactions) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, ['Date', 'Type', 'Wallet', 'Category', 'Amount', 'Currency', 'Note']);
            foreach ($transactions as $transaction) {
                fputcsv($handle, [
                    $transaction->transaction_date->format(config('myexpenses.default_datetime_format')),
                    ucfirst($transaction->type),
                    $transaction->wallet->name ?? '',
                    $transaction->category->name ?? '',
                    $transaction->amount,
                    $transaction->currency,
                    $transaction->note,
                ]);
            }
            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv',
        ]);
    }

    protected function exportRange(string $range): array
    {
        return match ($range) {
            'daily' => [now()->startOfDay(), now()->endOfDay()],
            'weekly' => [now()->startOfWeek(), now()->endOfWeek()],
            'yearly' => [now()->startOfYear(), now()->endOfYear()],
            'custom' => [
                $this->exportForm['custom_from'] ? Carbon::parse($this->exportForm['custom_from']) : null,
                $this->exportForm['custom_to'] ? Carbon::parse($this->exportForm['custom_to']) : null,
            ],
            default => [now()->startOfMonth(), now()->endOfMonth()],
        };
    }

    public function render(): View
    {
        $iconQuery = Icon::query()
            ->where('is_active', true)
            ->when($this->iconPickerSearch, function ($query) {
                $query->where(function ($sub) {
                    $sub->where('label', 'like', '%'.$this->iconPickerSearch.'%')
                        ->orWhere('fa_class', 'like', '%'.$this->iconPickerSearch.'%');
                });
            })
            ->orderBy('label');

        $fontawesomeIcons = $this->iconPickerOpen
            ? (clone $iconQuery)->where('type', 'fontawesome')->get()
            : collect();

        $customIcons = $this->iconPickerOpen
            ? (clone $iconQuery)->where('type', 'image')->get()
            : collect();

        $this->dispatch('refresh-fontawesome');

        $categories = Category::query()
            ->with(['icon'])
            ->where(function ($query) {
                $query->where('user_id', Auth::id())->orWhereNull('user_id');
            })
            ->orderBy('display_order')
            ->get();

        $ownedCategories = $categories->where('user_id', Auth::id());
        $referencedParentIds = $ownedCategories->whereNotNull('parent_id')->pluck('parent_id')->unique();
        $referencedParents = $categories->whereIn('id', $referencedParentIds);
        $hierarchyParents = $ownedCategories->whereNull('parent_id')
            ->merge($referencedParents)
            ->unique('id');

        $categoryHierarchy = $hierarchyParents->map(function ($parent) use ($ownedCategories) {
            return [
                'parent' => $parent,
                'children' => $ownedCategories->where('parent_id', $parent->id),
            ];
        })->values();

        return view('livewire.profile.settings-hub', [
            'wallets' => Auth::user()->wallets()->with('iconDefinition')->latest()->get(),
            'labels' => Auth::user()->labels()->orderBy('name')->get(),
            'categories' => $categories,
            'categoryHierarchy' => $categoryHierarchy,
            'iconPickerFontawesome' => $fontawesomeIcons,
            'iconPickerCustom' => $customIcons,
            'timezones' => \DateTimeZone::listIdentifiers(),
        ]);
    }

    protected function syncWalletIconPreview(): void
    {
        $this->walletIconPreview = $this->buildIconPreview($this->walletForm['icon_id'] ?? null);
    }

    protected function syncCategoryIconPreview(): void
    {
        $this->categoryIconPreview = $this->buildIconPreview($this->categoryForm['icon_id'] ?? null);
    }

    protected function buildIconPreview(?int $iconId): ?array
    {
        if (! $iconId) {
            return null;
        }

        $icon = Icon::find($iconId);

        if (! $icon) {
            return null;
        }

        return [
            'id' => $icon->id,
            'type' => $icon->type,
            'fa_class' => $icon->fa_class,
            'image_path' => $icon->image_path,
            'image_url' => $icon->image_url,
            'label' => $icon->label,
        ];
    }

    protected function resetCategoryForm(): void
    {
        $this->editingCategoryId = null;
        $this->categoryForm = [
            'name' => '',
            'type' => 'expense',
            'icon_id' => null,
            'icon_color' => '#095C4A',
            'icon_background' => '#F6FFFA',
            'parent_id' => null,
        ];
        $this->categoryIconPreview = null;
    }

    protected function resetWalletForm(): void
    {
        $this->editingWalletId = null;
        $this->walletForm = [
            'name' => '',
            'type' => 'bank',
            'currency' => Auth::user()->base_currency,
            'initial_balance' => null,
            'is_default' => false,
            'icon_id' => null,
            'icon_color' => '#095C4A',
            'icon_background' => '#D2F9E7',
        ];
        $this->walletIconPreview = null;
    }
}
