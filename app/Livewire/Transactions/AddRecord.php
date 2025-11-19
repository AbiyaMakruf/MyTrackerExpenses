<?php

namespace App\Livewire\Transactions;

use App\Models\Category;
use App\Models\Label;
use App\Models\RecurringTransaction;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Services\GoogleCloudStorage;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Locked;
use Livewire\Component;
use Livewire\WithFileUploads;

#[Layout('layouts.app')]
class AddRecord extends Component
{
    use WithFileUploads;

    #[Locked]
    public ?int $editingTransactionId = null;

    public string $mode = 'expense';

    public ?string $amount = null;
    public ?int $wallet_id = null;
    public ?int $to_wallet_id = null;
    public ?int $category_id = null;
    public ?int $sub_category_id = null;
    public ?string $payment_type = null;
    public string $transaction_date;
    public ?string $note = null;
    public array $labelIds = [];
    public bool $is_recurring = false;
    public string $recurring_interval = 'monthly';
    public ?int $recurring_custom_days = null;
    public ?string $recurring_end_date = null;
    public bool $auto_post = true;
    public ?string $next_run_at = null;

    public ?string $transfer_amount = null;
    public ?string $transfer_date = null;
    public ?string $transfer_note = null;

    public $receipt;

    public array $paymentTypes = ['cash', 'transfer', 'qris', 'credit_card', 'debit_card', 'virtual_account'];
    public array $intervalOptions = ['daily', 'weekly', 'monthly', 'yearly', 'custom'];

    public bool $allowAttachmentUploads = true;

    public ?Transaction $editingTransaction = null;

    public function mount(Transaction $transaction = null): void
    {
        if ($transaction && $transaction->exists) {
            if ($transaction->user_id !== Auth::id()) {
                abort(403);
            }
            
            $this->editingTransaction = $transaction;
            $this->editingTransactionId = $transaction->id;
            $this->mode = $transaction->type;
            
            if ($this->mode === 'transfer') {
                $this->wallet_id = $transaction->wallet_id;
                $this->to_wallet_id = $transaction->to_wallet_id;
                $this->transfer_amount = $transaction->amount;
                $this->transfer_date = $transaction->transaction_date->format('Y-m-d\TH:i');
                $this->transfer_note = $transaction->note;
            } else {
                $this->amount = $transaction->amount;
                $this->wallet_id = $transaction->wallet_id;
                $this->category_id = $transaction->category_id;
                $this->sub_category_id = $transaction->sub_category_id;
                $this->payment_type = $transaction->payment_type;
                $this->transaction_date = $transaction->transaction_date->format('Y-m-d\TH:i');
                $this->note = $transaction->note;
                $this->labelIds = $transaction->labels->pluck('id')->toArray();
            }
        } else {
            $this->transaction_date = now()->format('Y-m-d\TH:i');
            $this->transfer_date = now()->format('Y-m-d\TH:i');
            $this->wallet_id = Auth::user()->default_wallet_id ?? Auth::user()->wallets()->value('id');
        }
        
        $this->allowAttachmentUploads = config('myexpenses.records.allow_receipt_upload', true);
    }

    public function updatedMode(): void
    {
        $this->resetErrorBag();
        $this->category_id = null;
        $this->sub_category_id = null;
    }

    public function save(GoogleCloudStorage $gcs): void
    {
        if ($this->mode === 'transfer') {
            $this->saveTransfer();
            return;
        }

        $data = $this->validate($this->rules());
        $user = Auth::user();
        $category = $this->selectedCategory();
        $attachmentPath = null;

        if ($this->allowAttachmentUploads && $this->receipt) {
            $path = 'receipts/' . Str::random(40) . '.' . $this->receipt->getClientOriginalExtension();
            $attachmentPath = $gcs->upload($this->receipt, $path);
        }

        DB::transaction(function () use ($data, $user, $category, $attachmentPath) {
            if ($this->editingTransactionId) {
                $transaction = Transaction::find($this->editingTransactionId);
                // Revert old balance
                $oldWallet = $transaction->wallet;
                if ($transaction->type === 'expense') {
                    $oldWallet->increment('current_balance', $transaction->amount);
                } else {
                    $oldWallet->decrement('current_balance', $transaction->amount);
                }

                $transaction->update([
                    'wallet_id' => $data['wallet_id'],
                    'category_id' => $category?->id,
                    'sub_category_id' => $this->sub_category_id,
                    'type' => $this->mode,
                    'amount' => $data['amount'],
                    'payment_type' => $data['payment_type'],
                    'transaction_date' => Carbon::parse($data['transaction_date']),
                    'note' => $this->note,
                    'attachment_path' => $attachmentPath ?? $transaction->attachment_path,
                ]);
                
                // Update labels
                $transaction->labels()->sync($this->labelIds);
            } else {
                $transaction = Transaction::create([
                    'user_id' => $user->id,
                    'wallet_id' => $data['wallet_id'],
                    'category_id' => $category?->id,
                    'sub_category_id' => $this->sub_category_id,
                    'type' => $this->mode,
                    'amount' => $data['amount'],
                    'currency' => $user->base_currency,
                    'payment_type' => $data['payment_type'],
                    'transaction_date' => Carbon::parse($data['transaction_date']),
                    'note' => $this->note,
                    'attachment_path' => $attachmentPath,
                ]);

                if (! empty($this->labelIds)) {
                    $transaction->labels()->sync($this->labelIds);
                }
            }

            $wallet = Wallet::find($data['wallet_id']);

            if ($this->mode === 'expense') {
                $wallet->decrement('current_balance', $data['amount']);
            } else {
                $wallet->increment('current_balance', $data['amount']);
            }

            if ($this->is_recurring && !$this->editingTransactionId) {
                $this->createRecurringTemplate($transaction, $wallet);
            }
        });

        session()->flash('status', $this->editingTransactionId ? 'Record updated' : 'Record saved');
        
        if ($this->editingTransactionId) {
            $this->redirectRoute('transactions.index', navigate: true);
        } else {
            $this->resetExcept(['mode', 'allowAttachmentUploads', 'paymentTypes', 'intervalOptions']);
            $this->mount();
        }
    }

    protected function saveTransfer(): void
    {
        $data = $this->validate([
            'transfer_amount' => ['required', 'numeric', 'min:0.01'],
            'wallet_id' => ['required', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'to_wallet_id' => ['required', 'different:wallet_id', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'transfer_date' => ['required', 'date'],
        ]);

        DB::transaction(function () use ($data) {
            if ($this->editingTransactionId) {
                $transaction = Transaction::find($this->editingTransactionId);
                // Revert old balance
                $oldFromWallet = Wallet::find($transaction->wallet_id);
                $oldToWallet = Wallet::find($transaction->to_wallet_id);
                
                $oldFromWallet->increment('current_balance', $transaction->amount);
                $oldToWallet->decrement('current_balance', $transaction->amount);
                
                $transaction->update([
                    'wallet_id' => $data['wallet_id'],
                    'to_wallet_id' => $data['to_wallet_id'],
                    'amount' => $data['transfer_amount'],
                    'transaction_date' => Carbon::parse($data['transfer_date']),
                    'note' => $this->transfer_note,
                ]);
            } else {
                $user = Auth::user();
                Transaction::create([
                    'user_id' => $user->id,
                    'wallet_id' => $data['wallet_id'],
                    'to_wallet_id' => $data['to_wallet_id'],
                    'type' => 'transfer',
                    'amount' => $data['transfer_amount'],
                    'currency' => $user->base_currency,
                    'transaction_date' => Carbon::parse($data['transfer_date']),
                    'note' => $this->transfer_note,
                    'status' => 'posted',
                ]);
            }

            Wallet::where('id', $data['wallet_id'])->decrement('current_balance', $data['transfer_amount']);
            Wallet::where('id', $data['to_wallet_id'])->increment('current_balance', $data['transfer_amount']);
        });

        session()->flash('status', $this->editingTransactionId ? 'Transfer updated' : 'Transfer saved');
        
        if ($this->editingTransactionId) {
            $this->redirectRoute('transactions.index', navigate: true);
        } else {
            $this->reset();
            $this->mount();
        }
    }

    protected function createRecurringTemplate(Transaction $transaction, Wallet $wallet): void
    {
        $nextRun = $this->calculateNextRun(Carbon::parse($transaction->transaction_date));

        RecurringTransaction::create([
            'user_id' => $transaction->user_id,
            'wallet_id' => $wallet->id,
            'category_id' => $transaction->category_id,
            'sub_category_id' => $transaction->sub_category_id,
            'type' => $transaction->type,
            'amount' => $transaction->amount,
            'currency' => $transaction->currency,
            'payment_type' => $transaction->payment_type,
            'interval' => $this->recurring_interval,
            'custom_days' => $this->recurring_custom_days,
            'next_run_at' => $nextRun,
            'end_date' => $this->recurring_end_date,
            'auto_post' => (bool) $this->auto_post,
            'note' => $transaction->note,
        ]);
    }

    protected function calculateNextRun(Carbon $original): Carbon
    {
        return match ($this->recurring_interval) {
            'daily' => $original->copy()->addDay(),
            'weekly' => $original->copy()->addWeek(),
            'yearly' => $original->copy()->addYear(),
            'custom' => $original->copy()->addDays($this->recurring_custom_days ?? 1),
            default => $original->copy()->addMonth(),
        };
    }

    protected function rules(): array
    {
        $rules = [
            'amount' => ['required', 'numeric', 'min:0.01'],
            'wallet_id' => ['required', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'category_id' => ['nullable', Rule::exists('categories', 'id')],
            'payment_type' => ['nullable', 'string', Rule::in($this->paymentTypes)],
            'transaction_date' => ['required', 'date'],
            'labelIds' => ['array'],
            'labelIds.*' => [Rule::exists('labels', 'id')->where('user_id', Auth::id())],
            'is_recurring' => ['boolean'],
            'recurring_interval' => ['nullable', Rule::in($this->intervalOptions)],
            'recurring_custom_days' => ['nullable', 'integer', 'min:1'],
            'recurring_end_date' => ['nullable', 'date', 'after:transaction_date'],
            'auto_post' => ['boolean'],
        ];

        $rules['receipt'] = $this->allowAttachmentUploads
            ? ['nullable', 'file', 'max:4096']
            : ['prohibited'];

        return $rules;
    }

    public function getWalletsProperty()
    {
        return Auth::user()->wallets()->orderByDesc('is_default')->get();
    }

    public function getCategoriesProperty()
    {
        return Category::query()
            ->where(function ($query) {
                $query->whereNull('user_id')->orWhere('user_id', Auth::id());
            })
            ->when($this->mode !== 'transfer', fn ($query) => $query->where('type', $this->mode))
            ->orderBy('display_order')
            ->get();
    }

    public function getLabelsProperty()
    {
        return Label::query()
            ->where('user_id', Auth::id())
            ->orderBy('name')
            ->get();
    }

    protected function selectedCategory(): ?Category
    {
        return $this->categories->firstWhere('id', $this->category_id);
    }

    public function render(): View
    {
        return view('livewire.transactions.add-record', [
            'wallets' => $this->wallets,
            'categories' => $this->categories,
            'labels' => $this->labels,
        ]);
    }
}
