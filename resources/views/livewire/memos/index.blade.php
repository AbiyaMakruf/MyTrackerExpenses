<section class="space-y-6">
    <div class="flex flex-col gap-2">
        <h1 class="text-2xl font-semibold text-[#095C4A]">Memos</h1>
        <p class="text-sm text-slate-500">Keep track of your maintenance logs and todos.</p>
    </div>

    <div class="glass-card">
        <form wire:submit.prevent="saveGroup" class="flex gap-2">
            <input type="text" wire:model="newGroupName" placeholder="New list name (e.g. Motor, Mobil)" class="w-full rounded-2xl border border-[#D2F9E7] px-4 py-2" />
            <button type="submit" class="btn-primary whitespace-nowrap">Add List</button>
        </form>
    </div>

    <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        @foreach ($groups as $group)
            <div class="glass-card flex flex-col gap-4">
                <div class="flex items-center justify-between border-b border-[#F1F5F9] pb-2">
                    @if ($editingGroupId === $group->id)
                        <div class="flex w-full gap-2">
                            <input type="text" wire:model="editingGroupName" class="w-full rounded-xl border border-[#D2F9E7] px-2 py-1 text-sm" />
                            <button wire:click="updateGroup" class="text-xs font-semibold text-[#08745C]">Save</button>
                            <button wire:click="cancelEditGroup" class="text-xs text-slate-400">Cancel</button>
                        </div>
                    @else
                        <h3 class="text-lg font-bold text-[#095C4A]">{{ $group->name }}</h3>
                        <div class="flex gap-2">
                            <button wire:click="editGroup({{ $group->id }})" class="text-xs text-slate-400 hover:text-[#08745C]">Edit</button>
                            <button wire:click="deleteGroup({{ $group->id }})" wire:confirm="Delete this list?" class="text-xs text-slate-400 hover:text-[#FB7185]">Delete</button>
                        </div>
                    @endif
                </div>

                <ul class="space-y-3">
                    @foreach ($group->entries as $entry)
                        <li class="group relative flex gap-2 text-sm">
                            @if ($editingEntryId === $entry->id)
                                <div class="w-full space-y-2 rounded-xl bg-slate-50 p-2">
                                    <input type="text" wire:model="editingEntryDate" placeholder="Date/Label" class="w-full rounded-lg border border-slate-200 px-2 py-1 text-xs" />
                                    <textarea wire:model="editingEntryContent" rows="2" class="w-full rounded-lg border border-slate-200 px-2 py-1 text-xs"></textarea>
                                    <div class="flex justify-end gap-2">
                                        <button wire:click="cancelEditEntry" class="text-xs text-slate-500">Cancel</button>
                                        <button wire:click="updateEntry" class="text-xs font-semibold text-[#08745C]">Save</button>
                                    </div>
                                </div>
                            @else
                                <div class="flex-1">
                                    @if ($entry->date_label)
                                        <span class="font-semibold text-[#08745C]">{{ $entry->date_label }}:</span>
                                    @endif
                                    <span class="text-slate-600">{{ $entry->content }}</span>
                                </div>
                                <div class="hidden gap-2 group-hover:flex">
                                    <button wire:click="editEntry({{ $entry->id }})" class="text-xs text-slate-400 hover:text-[#08745C]">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-4 w-4">
                                            <path d="M5.433 13.917l1.262-3.155A4 4 0 017.58 9.42l6.92-6.918a2.121 2.121 0 013 3l-6.92 6.918c-.383.383-.84.685-1.343.886l-3.154 1.262a.5.5 0 01-.65-.65z" />
                                            <path d="M3.5 5.75c0-.69.56-1.25 1.25-1.25H10A.75.75 0 0010 3H4.75A2.75 2.75 0 002 5.75v9.5A2.75 2.75 0 004.75 18h9.5A2.75 2.75 0 0017 15.25V10a.75.75 0 00-1.5 0v5.25c0 .69-.56 1.25-1.25 1.25h-9.5c-.69 0-1.25-.56-1.25-1.25v-9.5z" />
                                        </svg>
                                    </button>
                                    <button wire:click="deleteEntry({{ $entry->id }})" wire:confirm="Delete this item?" class="text-xs text-slate-400 hover:text-[#FB7185]">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-4 w-4">
                                            <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd" />
                                        </svg>
                                    </button>
                                </div>
                            @endif
                        </li>
                    @endforeach
                </ul>

                @if ($newEntryGroupId === $group->id)
                    <div class="mt-2 space-y-2 rounded-xl bg-slate-50 p-2">
                        <input type="text" wire:model="newEntryDate" placeholder="Date/Label (e.g. 15 Nov)" class="w-full rounded-lg border border-slate-200 px-2 py-1 text-xs" />
                        <textarea wire:model="newEntryContent" rows="2" placeholder="Note content..." class="w-full rounded-lg border border-slate-200 px-2 py-1 text-xs"></textarea>
                        <div class="flex justify-end gap-2">
                            <button wire:click="cancelAddEntry" class="text-xs text-slate-500">Cancel</button>
                            <button wire:click="saveEntry" class="text-xs font-semibold text-[#08745C]">Add</button>
                        </div>
                    </div>
                @else
                    <button wire:click="addEntry({{ $group->id }})" class="mt-2 flex items-center gap-1 text-xs font-semibold text-[#08745C] hover:underline">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-4 w-4">
                            <path d="M10.75 4.75a.75.75 0 00-1.5 0v4.5h-4.5a.75.75 0 000 1.5h4.5v4.5a.75.75 0 001.5 0v-4.5h4.5a.75.75 0 000-1.5h-4.5v-4.5z" />
                        </svg>
                        Add item
                    </button>
                @endif
            </div>
        @endforeach
    </div>
</section>
