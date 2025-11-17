<?php

namespace App\Livewire\Profile;

use App\Models\Category;
use App\Models\CategoryIcon;
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
    ];

    public array $labelForm = [
        'name' => '',
        'color' => '#15B489',
    ];

    public array $categoryForm = [
        'name' => '',
        'type' => 'expense',
        'category_icon_id' => null,
        'parent_id' => null,
    ];

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

        $this->walletForm['currency'] = $user->base_currency;
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
        $data = $this->validate([
            'walletForm.name' => ['required', 'string', 'max:255'],
            'walletForm.type' => ['required', Rule::in(config('myexpenses.wallets.types'))],
            'walletForm.currency' => ['required', Rule::in(config('myexpenses.currency.supported'))],
            'walletForm.initial_balance' => ['required', 'numeric', 'min:0'],
            'walletForm.is_default' => ['boolean'],
        ])['walletForm'];

        $wallet = Wallet::create([
            ...$data,
            'user_id' => Auth::id(),
            'current_balance' => $data['initial_balance'],
        ]);

        if ($data['is_default']) {
            Auth::user()->update(['default_wallet_id' => $wallet->id]);
        }

        $this->walletForm = [
            'name' => '',
            'type' => 'bank',
            'currency' => Auth::user()->base_currency,
            'initial_balance' => null,
            'is_default' => false,
        ];

        session()->flash('profile_status', 'Wallet added');
    }

    public function deleteWallet(int $walletId): void
    {
        Wallet::where('user_id', Auth::id())->where('id', $walletId)->delete();
        session()->flash('profile_status', 'Wallet deleted');
    }

    public function saveLabel(): void
    {
        $data = $this->validate([
            'labelForm.name' => ['required', 'string', 'max:100'],
            'labelForm.color' => ['nullable', 'string'],
        ])['labelForm'];

        Label::create([
            ...$data,
            'user_id' => Auth::id(),
            'slug' => Str::slug($data['name']),
        ]);

        $this->labelForm = ['name' => '', 'color' => '#15B489'];
        session()->flash('profile_status', 'Label saved');
    }

    public function deleteLabel(int $labelId): void
    {
        Label::where('user_id', Auth::id())->where('id', $labelId)->delete();
        session()->flash('profile_status', 'Label removed');
    }

    public function saveCategory(): void
    {
        $data = $this->validate([
            'categoryForm.name' => ['required', 'string', 'max:255'],
            'categoryForm.type' => ['required', Rule::in(['expense', 'income'])],
            'categoryForm.category_icon_id' => ['required', Rule::exists('category_icons', 'id')],
            'categoryForm.parent_id' => ['nullable', Rule::exists('categories', 'id')],
        ])['categoryForm'];

        Category::create([
            ...$data,
            'user_id' => Auth::id(),
        ]);

        $this->categoryForm = [
            'name' => '',
            'type' => 'expense',
            'category_icon_id' => null,
            'parent_id' => null,
        ];

        session()->flash('profile_status', 'Category saved');
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
        return view('livewire.profile.settings-hub', [
            'wallets' => Auth::user()->wallets()->latest()->get(),
            'labels' => Auth::user()->labels()->orderBy('name')->get(),
            'categories' => Category::query()
                ->where(function ($query) {
                    $query->where('user_id', Auth::id())->orWhereNull('user_id');
                })
                ->orderBy('display_order')
                ->get(),
            'categoryIcons' => CategoryIcon::where('is_active', true)->orderBy('name')->get(),
            'timezones' => \DateTimeZone::listIdentifiers(),
        ]);
    }
}
