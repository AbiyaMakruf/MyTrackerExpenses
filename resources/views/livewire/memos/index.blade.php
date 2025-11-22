<section class="space-y-6" x-data="{ showImage: false, imageUrl: '' }">
    <!-- Lightbox -->
    <div x-show="showImage" class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-4" x-cloak x-transition>
        <div @click.away="showImage = false" class="relative max-h-full max-w-full">
            <img :src="imageUrl" class="max-h-[90vh] max-w-[90vw] rounded-lg object-contain shadow-2xl" />
            <button @click="showImage = false" class="absolute -top-4 -right-4 rounded-full bg-white p-1 text-black hover:bg-gray-200 shadow-lg">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-5 w-5">
                    <path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z" />
                </svg>
            </button>
        </div>
    </div>

    <!-- Header & Navigation -->
    <div class="flex flex-col gap-2">
        <div class="flex items-center gap-2">
            @if ($currentFolder)
                <button wire:click="exitFolder" class="group flex items-center gap-1 rounded-lg px-2 py-1 text-slate-500 hover:bg-slate-100 hover:text-slate-700 transition-all">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-5 w-5 transition-transform group-hover:-translate-x-1">
                        <path fill-rule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clip-rule="evenodd" />
                    </svg>
                    <span class="text-sm font-medium">Back</span>
                </button>
                <h1 class="text-2xl font-semibold text-[#095C4A]">{{ $currentFolder->name }}</h1>
            @else
                <h1 class="text-2xl font-semibold text-[#095C4A]">Memos</h1>
            @endif
        </div>
        <p class="text-sm text-slate-500">Keep track of your maintenance logs and todos.</p>
    </div>

    <!-- Actions (Add Folder / Add List) -->
    <div class="flex flex-wrap gap-4">
        <!-- Add List Button -->
        <button wire:click="$set('showCreateGroupModal', true)" class="glass-card flex flex-1 min-w-[150px] items-center justify-center gap-2 p-4 text-[#095C4A] hover:bg-slate-50 transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-6 w-6">
                <path d="M10.75 4.75a.75.75 0 00-1.5 0v4.5h-4.5a.75.75 0 000 1.5h4.5v4.5a.75.75 0 001.5 0v-4.5h4.5a.75.75 0 000-1.5h-4.5v-4.5z" />
            </svg>
            <span class="font-semibold">Add List</span>
        </button>

        <!-- Add Folder Button (Only at root) -->
        @if (!$currentFolder)
            <button wire:click="$set('showCreateFolderModal', true)" class="glass-card flex flex-1 min-w-[150px] items-center justify-center gap-2 p-4 text-[#095C4A] hover:bg-slate-50 transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-6 w-6">
                    <path d="M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z" />
                    <path stroke="#095C4A" stroke-linecap="round" stroke-linejoin="round" d="M12 10v4m-2-2h4" />
                </svg>
                <span class="font-semibold">Add Folder</span>
            </button>
        @endif
    </div>

    <!-- Folders Grid (Only at root) -->
    @if (!$currentFolder && count($folders) > 0)
        <div class="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4">
            @foreach ($folders as $folder)
                <div class="glass-card group relative flex cursor-pointer flex-col justify-between gap-2 p-4 hover:bg-slate-50"
                     wire:click="openFolder({{ $folder->id }})">
                    
                    <div class="flex flex-col items-center justify-center gap-2">
                        <!-- Folder Icon -->
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="h-12 w-12 sm:h-16 sm:w-16" style="color: {{ $folder->color }}">
                            <path d="M19.5 21a3 3 0 0 0 3-3v-4.5a3 3 0 0 0-3-3h-15a3 3 0 0 0-3 3V18a3 3 0 0 0 3 3h15ZM1.5 10.146V6a3 3 0 0 1 3-3h5.379a2.25 2.25 0 0 1 1.59.659l2.122 2.121c.14.141.331.22.53.22H19.5a3 3 0 0 1 3 3v1.146A4.483 4.483 0 0 0 19.5 9h-15a4.483 4.483 0 0 0-3 1.146Z" />
                        </svg>
                        
                        <span class="font-semibold text-slate-700 text-center text-sm sm:text-base">{{ $folder->name }}</span>
                    </div>

                    <!-- Folder Actions -->
                    <div class="flex justify-center gap-2 pt-2 border-t border-slate-100 w-full mt-2">
                        <button wire:click.stop="editFolder({{ $folder->id }})" class="rounded p-1 text-slate-400 hover:bg-slate-200 hover:text-[#08745C]" title="Edit">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-4 w-4">
                                <path d="M5.433 13.917l1.262-3.155A4 4 0 017.58 9.42l6.92-6.918a2.121 2.121 0 013 3l-6.92 6.918c-.383.383-.84.685-1.343.886l-3.154 1.262a.5.5 0 01-.65-.65z" />
                                <path d="M3.5 5.75c0-.69.56-1.25 1.25-1.25H10A.75.75 0 0010 3H4.75A2.75 2.75 0 002 5.75v9.5A2.75 2.75 0 004.75 18h9.5A2.75 2.75 0 0017 15.25V10a.75.75 0 00-1.5 0v5.25c0 .69-.56 1.25-1.25 1.25h-9.5c-.69 0-1.25-.56-1.25-1.25v-9.5z" />
                            </svg>
                        </button>
                        <button wire:click.stop="confirmDelete('folder', {{ $folder->id }})" class="rounded p-1 text-slate-400 hover:bg-slate-200 hover:text-red-500" title="Delete">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-4 w-4">
                                <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd" />
                            </svg>
                        </button>
                    </div>
                </div>
            @endforeach
        </div>
    @endif

    <!-- Lists Grid -->
    <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        @foreach ($groups as $group)
            <div class="glass-card flex flex-col gap-4">
                <!-- List Header -->
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
                            <button wire:click="openMoveGroupModal({{ $group->id }})" class="text-xs text-slate-400 hover:text-[#08745C]">Move</button>
                            <button wire:click="editGroup({{ $group->id }})" class="text-xs text-slate-400 hover:text-[#08745C]">Edit</button>
                            <button wire:click="confirmDelete('group', {{ $group->id }})" class="text-xs text-slate-400 hover:text-[#FB7185]">Delete</button>
                        </div>
                    @endif
                </div>

                <!-- List Items -->
                <ul class="space-y-3">
                    @foreach ($group->entries as $entry)
                        <li class="group relative flex gap-2 text-sm">
                            @if ($editingEntryId === $entry->id)
                                <!-- Edit Form -->
                                <div class="w-full space-y-2 rounded-xl bg-slate-50 p-2" wire:key="edit-entry-{{ $entry->id }}">
                                    <input type="text" wire:model="editingEntryDate" placeholder="Date/Label" class="w-full rounded-lg border border-slate-200 px-2 py-1 text-xs" />
                                    <textarea wire:model="editingEntryContent" rows="2" class="w-full rounded-lg border border-slate-200 px-2 py-1 text-xs"></textarea>
                                    
                                    <div class="flex items-center gap-2">
                                        <input type="file" wire:model="editingEntryFile" wire:key="edit-file-{{ $entry->id }}" class="w-full text-xs text-slate-500 file:mr-2 file:rounded-full file:border-0 file:bg-[#D2F9E7] file:px-2 file:py-1 file:text-xs file:font-semibold file:text-[#08745C] hover:file:bg-[#bbf7d0]" />
                                        <div wire:loading wire:target="editingEntryFile" class="text-xs text-slate-500">Uploading...</div>
                                        @if ($editingEntryFile)
                                            <span class="text-xs text-green-600" wire:loading.remove wire:target="editingEntryFile">New file uploaded</span>
                                        @endif
                                    </div>

                                    <div class="flex justify-end gap-2">
                                        <button wire:click="cancelEditEntry" class="text-xs text-slate-500">Cancel</button>
                                        <button wire:click="updateEntry" wire:loading.attr="disabled" wire:target="editingEntryFile, updateEntry" class="text-xs font-semibold text-[#08745C] disabled:opacity-50">Save</button>
                                    </div>
                                </div>
                            @else
                                <!-- Display Item -->
                                <div class="flex-1">
                                    @if ($entry->date_label)
                                        <span class="font-semibold text-[#08745C]">{{ $entry->date_label }}:</span>
                                    @endif
                                    <span class="text-slate-600">{{ $entry->content }}</span>
                                    
                                    <!-- File Display -->
                                    @if ($entry->file_path)
                                        <div class="mt-2">
                                            @if ($entry->is_image)
                                                <img src="{{ $entry->file_path }}" 
                                                     class="h-16 w-16 cursor-pointer rounded-lg object-cover shadow-sm hover:opacity-80 transition-opacity" 
                                                     @click="showImage = true; imageUrl = '{{ $entry->file_path }}'" />
                                            @else
                                                <a href="{{ $entry->file_path }}" target="_blank" class="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 p-2 text-xs text-slate-600 hover:bg-slate-100">
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-4 w-4 text-slate-400">
                                                        <path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zm2.25 8.5a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5zm0 3a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5z" clip-rule="evenodd" />
                                                    </svg>
                                                    <span class="truncate max-w-[150px]">{{ $entry->file_name ?? 'Download File' }}</span>
                                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-4 w-4 text-slate-400">
                                                        <path d="M10.75 2.75a.75.75 0 00-1.5 0v8.614L6.295 8.235a.75.75 0 10-1.09 1.03l4.25 4.5a.75.75 0 001.09 0l4.25-4.5a.75.75 0 00-1.09-1.03l-2.955 3.129V2.75z" />
                                                        <path d="M3.5 12.75a.75.75 0 00-1.5 0v2.5A2.75 2.75 0 004.75 18h10.5A2.75 2.75 0 0018 15.25v-2.5a.75.75 0 00-1.5 0v2.5c0 .69-.56 1.25-1.25 1.25H4.75c-.69 0-1.25-.56-1.25-1.25v-2.5z" />
                                                    </svg>
                                                </a>
                                            @endif
                                        </div>
                                    @endif
                                </div>

                                <!-- Actions -->
                                <div class="flex gap-2">
                                    <button wire:click="editEntry({{ $entry->id }})" class="text-xs text-slate-400 hover:text-[#08745C]">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-4 w-4">
                                            <path d="M5.433 13.917l1.262-3.155A4 4 0 017.58 9.42l6.92-6.918a2.121 2.121 0 013 3l-6.92 6.918c-.383.383-.84.685-1.343.886l-3.154 1.262a.5.5 0 01-.65-.65z" />
                                            <path d="M3.5 5.75c0-.69.56-1.25 1.25-1.25H10A.75.75 0 0010 3H4.75A2.75 2.75 0 002 5.75v9.5A2.75 2.75 0 004.75 18h9.5A2.75 2.75 0 0017 15.25V10a.75.75 0 00-1.5 0v5.25c0 .69-.56 1.25-1.25 1.25h-9.5c-.69 0-1.25-.56-1.25-1.25v-9.5z" />
                                        </svg>
                                    </button>
                                    <button wire:click="confirmDelete('entry', {{ $entry->id }})" class="text-xs text-slate-400 hover:text-[#FB7185]">
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
                    <div class="mt-2 space-y-2 rounded-xl bg-slate-50 p-2" wire:key="add-entry-{{ $group->id }}">
                        <input type="text" wire:model="newEntryDate" placeholder="Date/Label (e.g. 15 Nov)" class="w-full rounded-lg border border-slate-200 px-2 py-1 text-xs" />
                        <textarea wire:model="newEntryContent" rows="2" placeholder="Note content..." class="w-full rounded-lg border border-slate-200 px-2 py-1 text-xs"></textarea>
                        @error('newEntryContent') <span class="text-xs text-red-500">{{ $message }}</span> @enderror
                        
                        <div class="flex items-center gap-2">
                            <input type="file" wire:model="newEntryFile" wire:key="file-input-{{ $group->id }}" class="w-full text-xs text-slate-500 file:mr-2 file:rounded-full file:border-0 file:bg-[#D2F9E7] file:px-2 file:py-1 file:text-xs file:font-semibold file:text-[#08745C] hover:file:bg-[#bbf7d0]" />
                            <div wire:loading wire:target="newEntryFile" class="text-xs text-slate-500">Uploading...</div>
                            @if ($newEntryFile)
                                <span class="text-xs text-green-600" wire:loading.remove wire:target="newEntryFile">File uploaded</span>
                            @endif
                        </div>

                        <div class="flex justify-end gap-2">
                            <button wire:click="cancelAddEntry" class="text-xs text-slate-500">Cancel</button>
                            <button wire:click="saveEntry" wire:loading.attr="disabled" wire:target="newEntryFile, saveEntry" class="text-xs font-semibold text-[#08745C] disabled:opacity-50">Add</button>
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
    <!-- Create Folder Modal -->
    <div x-data="{ open: @entangle('showCreateFolderModal') }"
         x-show="open"
         x-transition:enter="transition ease-out duration-200"
         x-transition:enter-start="opacity-0"
         x-transition:enter-end="opacity-100"
         x-transition:leave="transition ease-in duration-150"
         x-transition:leave-start="opacity-100"
         x-transition:leave-end="opacity-0"
         class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
         style="display: none;">
        <div class="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl" @click.away="open = false">
            <div class="space-y-6">
                <div>
                    <h2 class="text-lg font-bold text-slate-900">Create Folder</h2>
                </div>
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-700">Folder Name</label>
                        <input type="text" wire:model="newFolderName" class="mt-1 block w-full border border-gray-300 text-slate-900 shadow-sm focus:border-[#095C4A] focus:ring-[#095C4A] sm:text-sm">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700">Color</label>
                        <div class="mt-2 flex flex-wrap gap-2">
                            @foreach(['#EF4444', '#F97316', '#F59E0B', '#84CC16', '#10B981', '#06B6D4', '#3B82F6', '#6366F1', '#8B5CF6', '#EC4899'] as $color)
                                <button type="button" wire:click="$set('newFolderColor', '{{ $color }}')"
                                    class="h-6 w-6 rounded-full border-2 {{ $newFolderColor === $color ? 'border-black' : 'border-transparent' }}"
                                    style="background-color: {{ $color }};"></button>
                            @endforeach
                        </div>
                    </div>
                </div>
                <div class="flex justify-end gap-2">
                    <button wire:click="$set('showCreateFolderModal', false)" class="rounded-lg bg-red-500 px-4 py-2 text-sm font-semibold text-white hover:bg-red-600">Cancel</button>
                    <button wire:click="saveFolder" class="rounded-lg px-4 py-2 text-sm font-semibold text-[#095C4A] hover:bg-[#064034] hover:text-white transition-colors">Create</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Create List Modal -->
    <div x-data="{ open: @entangle('showCreateGroupModal') }"
         x-show="open"
         x-transition:enter="transition ease-out duration-200"
         x-transition:enter-start="opacity-0"
         x-transition:enter-end="opacity-100"
         x-transition:leave="transition ease-in duration-150"
         x-transition:leave-start="opacity-100"
         x-transition:leave-end="opacity-0"
         class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
         style="display: none;">
        <div class="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl" @click.away="open = false">
            <div class="space-y-6">
                <div>
                    <h2 class="text-lg font-bold text-slate-900">Create List</h2>
                </div>
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-700">List Name</label>
                        <input type="text" wire:model="newGroupName" class="mt-1 block w-full border border-gray-300 text-slate-900 shadow-sm focus:border-[#095C4A] focus:ring-[#095C4A] sm:text-sm">
                    </div>
                </div>
                <div class="flex justify-end gap-2">
                    <button wire:click="$set('showCreateGroupModal', false)" class="rounded-lg bg-red-500 px-4 py-2 text-sm font-semibold text-white hover:bg-red-600">Cancel</button>
                    <button wire:click="saveGroup" class="rounded-lg px-4 py-2 text-sm font-semibold text-[#095C4A] hover:bg-[#064034] hover:text-white transition-colors">Create</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Folder Modal -->
    <div x-data="{ open: @entangle('editingFolderId') }"
         x-show="open"
         x-transition:enter="transition ease-out duration-200"
         x-transition:enter-start="opacity-0"
         x-transition:enter-end="opacity-100"
         x-transition:leave="transition ease-in duration-150"
         x-transition:leave-start="opacity-100"
         x-transition:leave-end="opacity-0"
         class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
         style="display: none;">
        <div class="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl" @click.away="open = null">
            <div class="space-y-6">
                <div>
                    <h2 class="text-lg font-bold text-slate-900">Edit Folder</h2>
                </div>
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-700">Folder Name</label>
                        <input type="text" wire:model="editingFolderName" class="mt-1 block w-full border border-gray-300 text-slate-900 shadow-sm focus:border-[#095C4A] focus:ring-[#095C4A] sm:text-sm">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700">Color</label>
                        <div class="mt-2 flex flex-wrap gap-2">
                            @foreach(['#EF4444', '#F97316', '#F59E0B', '#84CC16', '#10B981', '#06B6D4', '#3B82F6', '#6366F1', '#8B5CF6', '#EC4899'] as $color)
                                <button type="button" wire:click="$set('editingFolderColor', '{{ $color }}')"
                                    class="h-6 w-6 rounded-full border-2 {{ $editingFolderColor === $color ? 'border-black' : 'border-transparent' }}"
                                    style="background-color: {{ $color }};"></button>
                            @endforeach
                        </div>
                    </div>
                </div>
                <div class="flex justify-end gap-2">
                    <button wire:click="cancelEditFolder" class="rounded-lg bg-red-500 px-4 py-2 text-sm font-semibold text-white hover:bg-red-600">Cancel</button>
                    <button wire:click="updateFolder" class="rounded-lg px-4 py-2 text-sm font-semibold text-[#095C4A] hover:bg-[#064034] hover:text-white transition-colors">Save</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Move Group Modal -->
    <div x-data="{ open: @entangle('movingGroupId') }"
         x-show="open"
         x-transition:enter="transition ease-out duration-200"
         x-transition:enter-start="opacity-0"
         x-transition:enter-end="opacity-100"
         x-transition:leave="transition ease-in duration-150"
         x-transition:leave-start="opacity-100"
         x-transition:leave-end="opacity-0"
         class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
         style="display: none;">
        <div class="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl" @click.away="open = null">
            <div class="space-y-6">
                <div>
                    <h2 class="text-lg font-bold text-slate-900">Move List</h2>
                </div>
                <div>
                    <label class="block text-sm font-medium text-slate-700">Select Folder</label>
                    <select wire:model="targetFolderId" class="mt-1 block w-full border border-gray-300 text-slate-900 shadow-sm focus:border-[#095C4A] focus:ring-[#095C4A] sm:text-sm">
                        <option value="">Root (No Folder)</option>
                        @foreach($folders as $folder)
                            <option value="{{ $folder->id }}">{{ $folder->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="flex justify-end gap-2">
                    <button wire:click="cancelMoveGroup" class="rounded-lg bg-red-500 px-4 py-2 text-sm font-semibold text-white hover:bg-red-600">Cancel</button>
                    <button wire:click="moveGroup" class="rounded-lg px-4 py-2 text-sm font-semibold text-[#095C4A] hover:bg-[#064034] hover:text-white transition-colors">Move</button>
                </div>
            </div>
        </div>
    </div>
</section>
