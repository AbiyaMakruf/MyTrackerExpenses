<section class="glass-card space-y-6">
    <div class="flex flex-col gap-2">
        <h1 class="text-2xl font-semibold text-[#095C4A]">Profile & Settings</h1>
        <p class="text-sm text-slate-500">Update your profile, wallets, categories, and export your data.</p>
    </div>

    @if (session('profile_status'))
        <div class="rounded-2xl bg-[#D2F9E7] px-4 py-2 text-sm font-semibold text-[#08745C]">
            {{ session('profile_status') }}
        </div>
    @endif

    <div class="grid gap-4 md:grid-cols-2">
        <form wire:submit.prevent="saveProfile" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h2 class="text-lg font-semibold text-[#095C4A]">Profile details</h2>
            <div>
                <label class="text-xs text-slate-500">Name</label>
                <input type="text" wire:model.live="profileForm.name" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('profileForm.name') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">Email</label>
                <input type="email" wire:model.live="profileForm.email" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('profileForm.email') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div class="grid gap-3 md:grid-cols-2">
                <div>
                    <label class="text-xs text-slate-500">Base currency</label>
                    <select wire:model.live="profileForm.base_currency" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        @foreach (config('myexpenses.currency.supported') as $currency)
                            <option value="{{ $currency }}">{{ $currency }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Language</label>
                    <input type="text" wire:model.live="profileForm.language" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                </div>
            </div>
            <div>
                <label class="text-xs text-slate-500">Timezone</label>
                <select wire:model.live="profileForm.timezone" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                    @foreach ($timezones as $tz)
                        <option value="{{ $tz }}">{{ $tz }}</option>
                    @endforeach
                </select>
            </div>
            <button type="submit" class="btn-primary w-full">Save profile</button>
        </form>

        <form wire:submit.prevent="updatePassword" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h2 class="text-lg font-semibold text-[#095C4A]">Change password</h2>
            <div>
                <label class="text-xs text-slate-500">Current password</label>
                <input type="password" wire:model.live="passwordForm.current_password" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('passwordForm.current_password') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">New password</label>
                <input type="password" wire:model.live="passwordForm.password" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('passwordForm.password') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">Confirm password</label>
                <input type="password" wire:model.live="passwordForm.password_confirmation" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
            </div>
            <button type="submit" class="btn-primary w-full">Save password</button>
        </form>
    </div>

    <div class="grid gap-4 md:grid-cols-2" id="wallets">
        <div class="space-y-3 rounded-2xl border border-[#D2F9E7] bg-white/80 p-4">
            <h2 class="text-lg font-semibold text-[#095C4A]">Wallets</h2>
            <div class="space-y-2">
                @forelse ($wallets as $wallet)
                    <div class="flex items-center justify-between rounded-2xl bg-[#F6FFFA] px-4 py-2">
                        <div>
                            <p class="text-sm font-semibold">{{ $wallet->name }}</p>
                            <p class="text-xs text-slate-500">{{ ucfirst($wallet->type) }} • {{ $wallet->currency }}</p>
                        </div>
                        <button type="button" wire:click="deleteWallet({{ $wallet->id }})" class="text-xs font-semibold text-red-500">Delete</button>
                    </div>
                @empty
                    <p class="text-sm text-slate-400">No wallets yet.</p>
                @endforelse
            </div>
        </div>
        <form wire:submit.prevent="saveWallet" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h3 class="text-base font-semibold text-[#095C4A]">Add wallet</h3>
            <div>
                <label class="text-xs text-slate-500">Wallet name</label>
                <input type="text" wire:model.live="walletForm.name" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('walletForm.name') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div class="grid gap-3 md:grid-cols-2">
                <div>
                    <label class="text-xs text-slate-500">Type</label>
                    <select wire:model.live="walletForm.type" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        @foreach (config('myexpenses.wallets.types') as $type)
                            <option value="{{ $type }}">{{ ucfirst($type) }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Currency</label>
                    <select wire:model.live="walletForm.currency" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        @foreach (config('myexpenses.currency.supported') as $currency)
                            <option value="{{ $currency }}">{{ $currency }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
            <div>
                <label class="text-xs text-slate-500">Initial balance</label>
                <input type="number" step="0.01" wire:model.live="walletForm.initial_balance" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('walletForm.initial_balance') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <label class="inline-flex items-center gap-2 text-sm text-[#095C4A]">
                <input type="checkbox" wire:model.live="walletForm.is_default" class="rounded text-[#095C4A]" />
                Set as default wallet
            </label>
            <button type="submit" class="btn-primary w-full">Save wallet</button>
        </form>
    </div>

    <div class="grid gap-4 md:grid-cols-2" id="labels">
        <div class="space-y-3 rounded-2xl border border-[#D2F9E7] bg-white/80 p-4">
            <h2 class="text-lg font-semibold text-[#095C4A]">Labels</h2>
            <div class="flex flex-wrap gap-2">
                @foreach ($labels as $label)
                    <span class="inline-flex items-center gap-2 rounded-full border border-[#D2F9E7] bg-white px-4 py-1 text-sm font-semibold text-[#095C4A]">
                        <span class="inline-block h-2 w-2 rounded-full" style="background-color: {{ $label->color }}"></span>
                        {{ $label->name }}
                        <button type="button" wire:click="deleteLabel({{ $label->id }})" class="text-xs text-red-500">✕</button>
                    </span>
                @endforeach
            </div>
        </div>
        <form wire:submit.prevent="saveLabel" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h3 class="text-base font-semibold text-[#095C4A]">Add label</h3>
            <div>
                <label class="text-xs text-slate-500">Label name</label>
                <input type="text" wire:model.live="labelForm.name" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('labelForm.name') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">Color</label>
                <input type="color" wire:model.live="labelForm.color" class="h-10 w-full rounded-2xl border border-[#D2F9E7] px-2 py-1" />
            </div>
            <button type="submit" class="btn-primary w-full">Save label</button>
        </form>
    </div>

    <div class="grid gap-4 md:grid-cols-2" id="categories">
        <div class="space-y-3 rounded-2xl border border-[#D2F9E7] bg-white/80 p-4">
            <h2 class="text-lg font-semibold text-[#095C4A]">My categories</h2>
            <div class="space-y-2 max-h-64 overflow-y-auto">
                @foreach ($categories->where('user_id', auth()->id()) as $category)
                    <div class="flex items-center justify-between rounded-xl bg-[#F6FFFA] px-3 py-2">
                        <div>
                            <p class="text-sm font-semibold">{{ $category->name }}</p>
                            <p class="text-xs text-slate-500">{{ ucfirst($category->type) }}</p>
                        </div>
                        <span class="text-xs text-slate-400">Icon #{{ $category->category_icon_id }}</span>
                    </div>
                @endforeach
                @if ($categories->where('user_id', auth()->id())->isEmpty())
                    <p class="text-sm text-slate-400">No custom categories.</p>
                @endif
            </div>
        </div>
        <form wire:submit.prevent="saveCategory" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h3 class="text-base font-semibold text-[#095C4A]">Create category</h3>
            <div>
                <label class="text-xs text-slate-500">Category name</label>
                <input type="text" wire:model.live="categoryForm.name" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('categoryForm.name') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div class="grid gap-3 md:grid-cols-2">
                <div>
                    <label class="text-xs text-slate-500">Type</label>
                    <select wire:model.live="categoryForm.type" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        <option value="expense">Expense</option>
                        <option value="income">Income</option>
                    </select>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Parent</label>
                    <select wire:model.live="categoryForm.parent_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        <option value="">None</option>
                        @foreach ($categories->whereNull('parent_id') as $parent)
                            <option value="{{ $parent->id }}">{{ $parent->name }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
            <div>
                <label class="text-xs text-slate-500">Icon (admin curated)</label>
                <select wire:model.live="categoryForm.category_icon_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                    <option value="">Select icon</option>
                    @foreach ($categoryIcons as $icon)
                        <option value="{{ $icon->id }}">{{ $icon->name }} ({{ $icon->icon_key }})</option>
                    @endforeach
                </select>
                @error('categoryForm.category_icon_id') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <button type="submit" class="btn-primary w-full">Save category</button>
        </form>
    </div>

    <div class="rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4" id="export">
        <h2 class="text-lg font-semibold text-[#095C4A]">Export data</h2>
        <p class="text-sm text-slate-500">Download your transactions as CSV, Excel, or PDF.</p>
        <div class="mt-4 grid gap-3 md:grid-cols-3">
            <div>
                <label class="text-xs text-slate-500">Format</label>
                <select wire:model.live="exportForm.format" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                    <option value="csv">CSV</option>
                    <option value="xlsx">Excel</option>
                    <option value="pdf">PDF</option>
                </select>
            </div>
            <div>
                <label class="text-xs text-slate-500">Date range</label>
                <select wire:model.live="exportForm.date_range" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                    <option value="daily">Daily</option>
                    <option value="weekly">Weekly</option>
                    <option value="monthly">Monthly</option>
                    <option value="yearly">Yearly</option>
                    <option value="custom">Custom</option>
                </select>
            </div>
            @if ($exportForm['date_range'] === 'custom')
                <div>
                    <label class="text-xs text-slate-500">From</label>
                    <input type="date" wire:model.live="exportForm.custom_from" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                </div>
                <div>
                    <label class="text-xs text-slate-500">To</label>
                    <input type="date" wire:model.live="exportForm.custom_to" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                </div>
            @endif
        </div>
        <div class="mt-3 grid gap-3 md:grid-cols-3">
            <div>
                <label class="text-xs text-slate-500">Wallet</label>
                <select wire:model.live="exportForm.wallet_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                    <option value="">All</option>
                    @foreach ($wallets as $wallet)
                        <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                    @endforeach
                </select>
            </div>
            <div>
                <label class="text-xs text-slate-500">Category</label>
                <select wire:model.live="exportForm.category_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                    <option value="">All</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}">{{ $category->name }}</option>
                    @endforeach
                </select>
            </div>
            <div>
                <label class="text-xs text-slate-500">Type</label>
                <select wire:model.live="exportForm.transaction_type" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                    <option value="all">All</option>
                    <option value="income">Income</option>
                    <option value="expense">Expense</option>
                </select>
            </div>
        </div>
        <div class="mt-3 grid gap-3 md:grid-cols-3 text-sm text-[#095C4A]">
            <label class="inline-flex items-center gap-2">
                <input type="checkbox" wire:model.live="exportForm.include_attachments" class="rounded text-[#095C4A]" />
                Include attachments
            </label>
            <label class="inline-flex items-center gap-2">
                <input type="checkbox" wire:model.live="exportForm.group_by_category" class="rounded text-[#095C4A]" />
                Group by category
            </label>
            <label class="inline-flex items-center gap-2">
                <input type="checkbox" wire:model.live="exportForm.compress" class="rounded text-[#095C4A]" />
                Compress (zip)
            </label>
        </div>
        <div class="mt-4 flex flex-wrap gap-2">
            <button type="button" wire:click.prevent="export('csv')" class="btn-primary bg-[#095C4A]">Download CSV</button>
            <button type="button" wire:click.prevent="export('xlsx')" class="btn-primary bg-[#08745C]">Download Excel</button>
            <button type="button" wire:click.prevent="export('pdf')" class="btn-primary bg-[#15B489]">Download PDF</button>
        </div>
    </div>
</section>
