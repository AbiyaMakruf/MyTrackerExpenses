@php use Illuminate\Support\Str; @endphp

<section class="glass-card space-y-6">
    <div class="flex flex-col gap-2">
        <h1 class="text-2xl font-semibold text-[#095C4A]">Settings</h1>
        <p class="text-sm text-slate-500">Manage wallets, categories, labels, and export data.</p>
    </div>

    @if (session('settings_status'))
        <div class="rounded-2xl bg-[#D2F9E7] px-4 py-2 text-sm font-semibold text-[#08745C]">
            {{ session('settings_status') }}
        </div>
    @endif

    <div class="grid gap-4 md:grid-cols-2" id="wallets">
        <div class="space-y-3 rounded-2xl border border-[#D2F9E7] bg-white/80 p-4">
            <h2 class="text-lg font-semibold text-[#095C4A]">Wallets</h2>
            <div class="space-y-2">
                @forelse ($wallets as $wallet)
                    @php
                        $icon = $wallet->iconDefinition;
                        $bg = $wallet->icon_background ?? '#F6FFFA';
                        $color = $wallet->icon_color ?? '#095C4A';
                    @endphp
                    <div class="flex items-center justify-between rounded-2xl border border-[#E2F5ED] bg-white px-4 py-2 shadow-sm">
                        <div class="flex items-center gap-3">
                            <div class="flex h-12 w-12 items-center justify-center rounded-2xl" style="background-color: {{ $bg }}; color: {{ $color }}">
                                @if ($icon && $icon->image_url)
                                    <img src="{{ $icon->image_url }}" alt="{{ $icon->label }}" class="h-6 w-6 object-contain">
                                @elseif ($icon && $icon->fa_class)
                                    <span data-fa-icon="{{ $icon->fa_class }}" class="text-lg"></span>
                                @else
                                    <span class="text-xs font-semibold">{{ Str::upper(Str::substr($wallet->name, 0, 2)) }}</span>
                                @endif
                            </div>
                            <div>
                                <p class="text-sm font-semibold">{{ $wallet->name }}</p>
                                <p class="text-xs text-slate-500">{{ ucfirst($wallet->type) }} • {{ $wallet->currency }}</p>
                                @if ($wallet->is_default)
                                    <span class="text-[11px] font-semibold text-[#08745C]">Default</span>
                                @endif
                            </div>
                        </div>
                        <div class="flex items-center gap-2 text-xs font-semibold">
                            <button type="button" wire:click="editWallet({{ $wallet->id }})" class="text-[#095C4A]">Edit</button>
                            <button type="button" wire:click="deleteWallet({{ $wallet->id }})" class="text-red-500">Delete</button>
                        </div>
                    </div>
                @empty
                    <p class="text-sm text-slate-400">No wallets yet.</p>
                @endforelse
            </div>
        </div>
        <form wire:submit.prevent="saveWallet" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <div class="flex items-center justify-between">
                <h3 class="text-base font-semibold text-[#095C4A]">{{ $editingWalletId ? 'Edit wallet' : 'Add wallet' }}</h3>
                @if ($editingWalletId)
                    <button type="button" wire:click="cancelWalletEdit" class="text-xs font-semibold text-red-500">Cancel edit</button>
                @endif
            </div>
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
            @if (! $editingWalletId)
                <div>
                    <label class="text-xs text-slate-500">Initial balance</label>
                    <input type="text" inputmode="decimal" data-money-input wire:model.live="walletForm.initial_balance" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    @error('walletForm.initial_balance') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
            @else
                <p class="text-xs text-slate-500">Balance adjustments are handled via transactions.</p>
            @endif
            <div class="space-y-2">
                <label class="text-xs text-slate-500">Icon</label>
                <div class="flex items-center gap-3">
                    <div class="flex h-12 w-12 items-center justify-center rounded-2xl border border-[#D2F9E7]" style="background-color: {{ $walletForm['icon_background'] ?? '#F6FFFA' }}; color: {{ $walletForm['icon_color'] ?? '#095C4A' }}">
                        @if ($walletIconPreview && $walletIconPreview['image_url'])
                            <img src="{{ $walletIconPreview['image_url'] }}" alt="{{ $walletIconPreview['label'] }}" class="h-6 w-6 object-contain">
                        @elseif ($walletIconPreview && $walletIconPreview['fa_class'])
                            <span data-fa-icon="{{ $walletIconPreview['fa_class'] }}" class="text-lg"></span>
                        @else
                            <span class="text-xs text-slate-400">None</span>
                        @endif
                    </div>
                    <button type="button" wire:click="openIconPicker('wallet')" class="rounded-full border border-[#095C4A] px-4 py-2 text-sm font-semibold text-[#095C4A]">Choose icon</button>
                </div>
                <p class="text-[11px] text-slate-400">Icons use the default palette for consistency.</p>
                @error('walletForm.icon_id') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
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
                <input type="hidden" wire:model.live="labelForm.color" />
                <div class="grid grid-cols-5 gap-2">
                    @foreach ($labelPalette as $color)
                        <button type="button" wire:click="$set('labelForm.color', '{{ $color }}')" class="h-10 rounded-2xl border-2 transition-all duration-200 ease-out hover:scale-[1.05]" style="background-color: {{ $color }}; border-color: {{ $labelForm['color'] === $color ? '#095C4A' : 'transparent' }}"></button>
                    @endforeach
                </div>
                @error('labelForm.color') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
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
                        <div class="flex items-center gap-3">
                            <div class="flex h-10 w-10 items-center justify-center rounded-2xl border border-white/70" style="background-color: {{ $category->icon_background ?? '#F6FFFA' }}; color: {{ $category->icon_color ?? '#095C4A' }}">
                                @if ($category->icon && $category->icon->image_url)
                                    <img src="{{ $category->icon->image_url }}" alt="{{ $category->icon->label }}" class="h-6 w-6 object-contain">
                                @elseif ($category->icon && $category->icon->fa_class)
                                    <span data-fa-icon="{{ $category->icon->fa_class }}" class="text-lg"></span>
                                @else
                                    <span class="text-xs font-semibold">{{ Str::upper(Str::substr($category->name, 0, 2)) }}</span>
                                @endif
                            </div>
                            <div>
                                <p class="text-sm font-semibold">{{ $category->name }}</p>
                                <p class="text-xs text-slate-500">{{ ucfirst($category->type) }}</p>
                            </div>
                        </div>
                        <button type="button" wire:click="editCategory({{ $category->id }})" class="text-xs font-semibold text-[#095C4A]">Edit</button>
                    </div>
                @endforeach
                @if ($categories->where('user_id', auth()->id())->isEmpty())
                    <p class="text-sm text-slate-400">No custom categories.</p>
                @endif
            </div>
        </div>
        <form wire:submit.prevent="saveCategory" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <div class="flex items-center justify-between">
                <h3 class="text-base font-semibold text-[#095C4A]">{{ $editingCategoryId ? 'Edit category' : 'Create category' }}</h3>
                @if ($editingCategoryId)
                    <button type="button" wire:click="cancelCategoryEdit" class="text-xs font-semibold text-red-500">Cancel edit</button>
                @endif
            </div>
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
            <div class="space-y-2">
                <label class="text-xs text-slate-500">Icon</label>
                <div class="flex items-center gap-3">
                    <div class="flex h-12 w-12 items-center justify-center rounded-2xl border border-[#D2F9E7]" style="background-color: {{ $categoryForm['icon_background'] ?? '#F6FFFA' }}; color: {{ $categoryForm['icon_color'] ?? '#095C4A' }}">
                        @if ($categoryIconPreview && $categoryIconPreview['image_url'])
                            <img src="{{ $categoryIconPreview['image_url'] }}" alt="{{ $categoryIconPreview['label'] }}" class="h-6 w-6 object-contain">
                        @elseif ($categoryIconPreview && $categoryIconPreview['fa_class'])
                            <span data-fa-icon="{{ $categoryIconPreview['fa_class'] }}" class="text-lg"></span>
                        @else
                            <span class="text-xs text-slate-400">None</span>
                        @endif
                    </div>
                    <button type="button" wire:click="openIconPicker('category')" class="rounded-full border border-[#095C4A] px-4 py-2 text-sm font-semibold text-[#095C4A]">Choose icon</button>
                </div>
                <p class="text-[11px] text-slate-400">Icons inherit default colors.</p>
                @error('categoryForm.icon_id') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <button type="submit" class="btn-primary w-full">Save category</button>
        </form>
    </div>

    <div class="space-y-3 rounded-2xl border border-[#D2F9E7] bg-white/80 p-4">
        <h2 class="text-lg font-semibold text-[#095C4A]">Category hierarchy</h2>
        <div class="space-y-3">
            @forelse ($categoryHierarchy as $group)
                <div class="rounded-2xl border border-[#E2F5ED] bg-white px-4 py-3 shadow-sm">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-semibold">{{ $group['parent']->name }}</p>
                            <p class="text-xs text-slate-500">{{ $group['parent']->type === 'income' ? 'Income' : 'Expense' }}</p>
                        </div>
                        @if ($group['parent']->user_id === auth()->id())
                            <button type="button" wire:click="editCategory({{ $group['parent']->id }})" class="text-xs font-semibold text-[#095C4A]">Edit</button>
                        @endif
                    </div>
                    <div class="mt-3 space-y-2 border-l border-dashed border-[#D2F9E7] pl-4">
                        @forelse ($group['children'] as $child)
                            <div class="flex items-center justify-between">
                                <span class="text-sm text-slate-600">{{ $child->name }}</span>
                                <button type="button" wire:click="editCategory({{ $child->id }})" class="text-xs font-semibold text-[#095C4A]">Edit</button>
                            </div>
                        @empty
                            <p class="text-xs text-slate-400">No child categories.</p>
                        @endforelse
                    </div>
                </div>
            @empty
                <p class="text-sm text-slate-400">No categories to display.</p>
            @endforelse
        </div>
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
                    <input type="text" data-datepicker wire:model.live="exportForm.custom_from" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                </div>
                <div>
                    <label class="text-xs text-slate-500">To</label>
                    <input type="text" data-datepicker wire:model.live="exportForm.custom_to" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
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

    @if ($iconPickerOpen)
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4" wire:click.self="closeIconPicker">
            <div class="flex w-full max-w-2xl flex-col overflow-hidden rounded-3xl border border-white/40 bg-white shadow-2xl max-h-[85vh]">
                <div class="flex items-start justify-between gap-4 border-b border-slate-100 px-6 py-4">
                    <div>
                        <p class="text-xs uppercase tracking-[0.3em] text-[#15B489]">Icon picker</p>
                        <h3 class="text-xl font-semibold text-[#095C4A]">Choose {{ $iconPickerContext === 'wallet' ? 'wallet' : 'category' }} icon</h3>
                    </div>
                    <button type="button" class="rounded-full bg-[#F2FFFA] px-4 py-1 text-sm font-semibold text-[#08745C]" wire:click="closeIconPicker">Close</button>
                </div>
                <div class="flex flex-1 flex-col gap-4 overflow-hidden px-6 py-4">
                    <div class="flex items-center gap-2">
                        <input type="text" wire:model.live="iconPickerSearch" placeholder="Search icons..." class="w-full rounded-2xl border border-[#D2F9E7] px-4 py-2 text-sm" />
                        @if($iconPickerTab === 'fontawesome')
                            <select wire:model.live="perPage" class="rounded-2xl border border-[#D2F9E7] px-3 py-2 text-sm">
                                <option value="20">20</option>
                                <option value="50">50</option>
                                <option value="100">100</option>
                            </select>
                        @endif
                    </div>
                    <div class="flex flex-wrap gap-2">
                        <button type="button" wire:click="$set('iconPickerTab','fontawesome')" @class([
                            'rounded-full px-4 py-2 text-sm font-semibold transition',
                            'bg-[#095C4A] text-white' => $iconPickerTab === 'fontawesome',
                            'bg-[#F6FFFA] text-[#095C4A]' => $iconPickerTab !== 'fontawesome',
                        ])>Font Awesome</button>
                        <button type="button" wire:click="$set('iconPickerTab','image')" @class([
                            'rounded-full px-4 py-2 text-sm font-semibold transition',
                            'bg-[#095C4A] text-white' => $iconPickerTab === 'image',
                            'bg-[#F6FFFA] text-[#095C4A]' => $iconPickerTab !== 'image',
                        ])>Custom icons</button>
                    </div>
                    @php($pickerIcons = $iconPickerTab === 'image' ? $iconPickerCustom : $iconPickerFontawesome)
                    @php($currentSelection = $iconPickerContext === 'wallet' ? $walletForm['icon_id'] : $categoryForm['icon_id'])
                    <div class="flex-1 overflow-y-auto pr-1">
                        <div class="grid gap-3 sm:grid-cols-3 md:grid-cols-4">
                            @forelse ($pickerIcons as $icon)
                                <button type="button" wire:click="selectIconFromPicker({{ $icon->id }})" @class([
                                    'flex flex-col items-center gap-2 rounded-2xl border bg-[#F6FFFA] p-3 text-sm font-semibold text-[#095C4A] transition',
                                    'border-[#095C4A] ring-2 ring-[#095C4A]/40' => $currentSelection === $icon->id,
                                    'border-[#D2F9E7]' => $currentSelection !== $icon->id,
                                ])>
                                    <div class="flex h-12 w-12 items-center justify-center rounded-2xl border border-white/60 bg-white text-[#095C4A]">
                                @if ($icon->image_url)
                                    <img src="{{ $icon->image_url }}" alt="{{ $icon->label }}" class="h-8 w-8 object-contain">
                                        @else
                                            <span data-fa-icon="{{ $icon->fa_class }}" class="text-xl"></span>
                                        @endif
                                    </div>
                                    <span class="text-xs text-center">{{ $icon->label }}</span>
                                </button>
                            @empty
                                <p class="text-sm text-slate-400 sm:col-span-3">{{ __('No icons found') }}</p>
                            @endforelse
                        </div>
                        @if($iconPickerTab === 'fontawesome')
                            <div class="mt-4">
                                {{ $pickerIcons->links() }}
                            </div>
                        @endif
                    </div>
                    <div class="grid gap-3 md:grid-cols-2">
                        <div>
                            <label class="text-xs text-slate-500">Icon color</label>
                            <input type="color" wire:model.live="iconPickerIconColor" class="h-10 w-full rounded-2xl border border-[#D2F9E7]" />
                        </div>
                        <div>
                            <label class="text-xs text-slate-500">Background color</label>
                            <input type="color" wire:model.live="iconPickerBackgroundColor" class="h-10 w-full rounded-2xl border border-[#D2F9E7]" />
                        </div>
                    </div>
                </div>
                <div class="flex items-center justify-end gap-3 border-t border-slate-100 px-6 py-4">
                    <button type="button" class="text-sm font-semibold text-slate-500" wire:click="closeIconPicker">Cancel</button>
                </div>
            </div>
        </div>
    @endif
</section>
