<?php

namespace App\Livewire\Transactions;

use App\Models\Transaction;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Storage;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Url;
use Livewire\Component;

#[Layout('layouts.app')]
class Show extends Component
{
    #[Url]
    public ?int $transactionId = null;

    public ?Transaction $transaction = null;

    public bool $confirmingDelete = false;

    public function mount(Transaction $transaction): void
    {
        abort_unless($transaction->user_id === auth()->id(), 403);

        $this->transaction = $transaction->load(['wallet', 'destinationWallet', 'category', 'subCategory', 'labels', 'recurringTemplate', 'user']);
        $this->transactionId = $transaction->id;
    }

    public function deleteTransaction(): void
    {
        if (! $this->transaction) {
            return;
        }

        abort_unless($this->transaction->user_id === auth()->id(), 403);

        $this->transaction->labels()->detach();
        $this->transaction->delete();

        session()->flash('status', __('Transaction deleted.'));
        $this->redirectRoute('dashboard');
    }

    public function downloadAttachment()
    {
        if (! $this->transaction || ! $this->transaction->attachment_path) {
            return;
        }

        return Storage::disk('public')->download($this->transaction->attachment_path);
    }

    public function render(): View
    {
        abort_unless($this->transaction, 404);

        return view('livewire.transactions.show', [
            'transaction' => $this->transaction,
        ]);
    }
}
