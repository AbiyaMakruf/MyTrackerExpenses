<?php

namespace App\Livewire\Memos;

use App\Models\MemoEntry;
use App\Models\MemoFolder;
use App\Models\MemoGroup;
use App\Services\GoogleCloudStorage;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Livewire\Attributes\Layout;
use Livewire\Attributes\On;
use Livewire\Component;
use Livewire\WithFileUploads;

#[Layout('layouts.app')]
class Index extends Component
{
    use WithFileUploads;

    // Folder State
    public $currentFolderId = null;
    public $showCreateFolderModal = false;
    public $newFolderName = '';
    public $newFolderColor = '#095C4A';
    public $editingFolderId = null;
    public $editingFolderName = '';
    public $editingFolderColor = '';

    // Group State
    public $showCreateGroupModal = false;
    public $newGroupName = '';
    public $editingGroupId = null;
    public $editingGroupName = '';
    public $movingGroupId = null;
    public $targetFolderId = null;

    // Entry State
    public $newEntryGroupId = null;
    public $newEntryDate = '';
    public $newEntryContent = '';
    public $newEntryFile;

    public $editingEntryId = null;
    public $editingEntryDate = '';
    public $editingEntryContent = '';
    public $editingEntryFile;

    // Delete Modal State
    public $deleteType = ''; // 'folder', 'group', 'entry'
    public $deleteId = null;

    public function saveFolder()
    {
        $this->validate([
            'newFolderName' => 'required|string|max:255',
            'newFolderColor' => 'required|string|max:7',
        ]);

        MemoFolder::create([
            'user_id' => Auth::id(),
            'name' => $this->newFolderName,
            'color' => $this->newFolderColor,
        ]);

        $this->newFolderName = '';
        $this->newFolderColor = '#095C4A';
        $this->showCreateFolderModal = false;
    }

    public function editFolder($id)
    {
        $folder = MemoFolder::where('user_id', Auth::id())->find($id);
        if ($folder) {
            $this->editingFolderId = $id;
            $this->editingFolderName = $folder->name;
            $this->editingFolderColor = $folder->color;
        }
    }

    public function updateFolder()
    {
        $this->validate([
            'editingFolderName' => 'required|string|max:255',
            'editingFolderColor' => 'required|string|max:7',
        ]);

        $folder = MemoFolder::where('user_id', Auth::id())->find($this->editingFolderId);
        if ($folder) {
            $folder->update([
                'name' => $this->editingFolderName,
                'color' => $this->editingFolderColor,
            ]);
        }

        $this->editingFolderId = null;
        $this->editingFolderName = '';
        $this->editingFolderColor = '';
    }

    public function cancelEditFolder()
    {
        $this->editingFolderId = null;
        $this->editingFolderName = '';
        $this->editingFolderColor = '';
    }

    public function openFolder($id)
    {
        $this->currentFolderId = $id;
    }

    public function exitFolder()
    {
        $this->currentFolderId = null;
    }

    public function saveGroup()
    {
        $this->validate(['newGroupName' => 'required|string|max:255']);

        MemoGroup::create([
            'user_id' => Auth::id(),
            'memo_folder_id' => $this->currentFolderId,
            'name' => $this->newGroupName,
        ]);

        $this->newGroupName = '';
        $this->showCreateGroupModal = false;
    }

    public function editGroup($id)
    {
        $group = MemoGroup::where('user_id', Auth::id())->find($id);
        if ($group) {
            $this->editingGroupId = $id;
            $this->editingGroupName = $group->name;
        }
    }

    public function updateGroup()
    {
        $this->validate(['editingGroupName' => 'required|string|max:255']);

        $group = MemoGroup::where('user_id', Auth::id())->find($this->editingGroupId);
        if ($group) {
            $group->update(['name' => $this->editingGroupName]);
        }

        $this->editingGroupId = null;
        $this->editingGroupName = '';
    }

    public function confirmDelete($type, $id)
    {
        $this->deleteType = $type;
        $this->deleteId = $id;
        
        $this->dispatch('open-confirmation-modal', [
            'title' => 'Confirm Delete',
            'message' => 'Are you sure you want to delete this item? This action cannot be undone.',
            'action' => 'delete-memo-confirmed',
        ]);
    }

    #[On('delete-memo-confirmed')]
    public function deleteConfirmed(GoogleCloudStorage $gcs)
    {
        if ($this->deleteType === 'folder') {
            $folder = MemoFolder::where('user_id', Auth::id())->find($this->deleteId);
            if ($folder) $folder->delete();
        } elseif ($this->deleteType === 'group') {
            $group = MemoGroup::where('user_id', Auth::id())->find($this->deleteId);
            if ($group) $group->delete();
        } elseif ($this->deleteType === 'entry') {
            $this->deleteEntry($this->deleteId, $gcs);
        }

        $this->deleteType = '';
        $this->deleteId = null;
    }

    public function cancelEditGroup()
    {
        $this->editingGroupId = null;
        $this->editingGroupName = '';
    }

    public function addEntry($groupId)
    {
        $this->newEntryGroupId = $groupId;
        $this->newEntryDate = '';
        $this->newEntryContent = '';
        $this->newEntryFile = null;
    }

    public function saveEntry(GoogleCloudStorage $gcs)
    {
        $this->validate([
            'newEntryContent' => 'required|string',
            'newEntryDate' => 'nullable|string|max:255',
            'newEntryFile' => 'nullable|file|max:10240', // 10MB max
        ]);

        $filePath = null;
        $fileName = null;
        $mimeType = null;

        if ($this->newEntryFile) {
            $fileName = $this->newEntryFile->getClientOriginalName();
            $mimeType = $this->newEntryFile->getMimeType();
            $storedName = Str::random(40) . '.' . $this->newEntryFile->getClientOriginalExtension();
            
            if (app()->environment('local')) {
                $path = $this->newEntryFile->storeAs('memos/' . Auth::id(), $storedName, 'public');
                $filePath = asset('storage/' . $path);
            } else {
                $filePath = $gcs->upload($this->newEntryFile, 'memos/' . Auth::id() . '/' . $storedName);
            }
        }

        MemoEntry::create([
            'memo_group_id' => $this->newEntryGroupId,
            'date_label' => $this->newEntryDate,
            'content' => $this->newEntryContent,
            'file_path' => $filePath,
            'file_name' => $fileName,
            'mime_type' => $mimeType,
        ]);

        $this->newEntryGroupId = null;
        $this->newEntryDate = '';
        $this->newEntryContent = '';
        $this->newEntryFile = null;
    }

    public function cancelAddEntry()
    {
        $this->newEntryGroupId = null;
    }

    public function editEntry($id)
    {
        $entry = MemoEntry::find($id);
        if ($entry && $entry->group->user_id === Auth::id()) {
            $this->editingEntryId = $id;
            $this->editingEntryDate = $entry->date_label;
            $this->editingEntryContent = $entry->content;
            $this->editingEntryFile = null; // Reset upload input
        }
    }

    public function updateEntry(GoogleCloudStorage $gcs)
    {
        $this->validate([
            'editingEntryContent' => 'required|string',
            'editingEntryDate' => 'nullable|string|max:255',
            'editingEntryFile' => 'nullable|file|max:10240',
        ]);

        $entry = MemoEntry::find($this->editingEntryId);
        if ($entry && $entry->group->user_id === Auth::id()) {
            $data = [
                'date_label' => $this->editingEntryDate,
                'content' => $this->editingEntryContent,
            ];

            if ($this->editingEntryFile) {
                // Delete old file if exists
                if ($entry->file_path) {
                    $bucket = config('services.gcs.bucket', 'tracker-expenses');
                    $prefix = "https://storage.googleapis.com/{$bucket}/";
                    if (str_starts_with($entry->file_path, $prefix)) {
                        $oldPath = substr($entry->file_path, strlen($prefix));
                        try {
                            $gcs->delete($oldPath);
                        } catch (\Exception $e) {
                            // Ignore deletion errors
                        }
                    }
                }

                $fileName = $this->editingEntryFile->getClientOriginalName();
                $mimeType = $this->editingEntryFile->getMimeType();
                $storedName = Str::random(40) . '.' . $this->editingEntryFile->getClientOriginalExtension();
                
                if (app()->environment('local')) {
                    $path = $this->editingEntryFile->storeAs('memos/' . Auth::id(), $storedName, 'public');
                    $data['file_path'] = asset('storage/' . $path);
                } else {
                    $data['file_path'] = $gcs->upload($this->editingEntryFile, 'memos/' . Auth::id() . '/' . $storedName);
                }
                
                $data['file_name'] = $fileName;
                $data['mime_type'] = $mimeType;
            }

            $entry->update($data);
        }

        $this->editingEntryId = null;
        $this->editingEntryDate = '';
        $this->editingEntryContent = '';
        $this->editingEntryFile = null;
    }

    private function deleteEntry($id, GoogleCloudStorage $gcs)
    {
        $entry = MemoEntry::find($id);
        if ($entry && $entry->group->user_id === Auth::id()) {
            if ($entry->file_path) {
                $bucket = config('services.gcs.bucket', 'tracker-expenses');
                $prefix = "https://storage.googleapis.com/{$bucket}/";
                if (str_starts_with($entry->file_path, $prefix)) {
                    $oldPath = substr($entry->file_path, strlen($prefix));
                    try {
                        $gcs->delete($oldPath);
                    } catch (\Exception $e) {
                        // Ignore deletion errors
                    }
                }
            }
            $entry->delete();
        }
    }

    public function cancelEditEntry()
    {
        $this->editingEntryId = null;
    }

    public function openMoveGroupModal($groupId)
    {
        $this->movingGroupId = $groupId;
        $group = MemoGroup::find($groupId);
        $this->targetFolderId = $group->memo_folder_id;
    }

    public function moveGroup()
    {
        $group = MemoGroup::where('user_id', Auth::id())->find($this->movingGroupId);
        
        if ($group) {
            $targetId = $this->targetFolderId;
            
            // Convert empty values to null
            if (empty($targetId)) {
                $targetId = null;
            }
            
            $group->memo_folder_id = $targetId;
            $group->save();
        }
        
        $this->movingGroupId = null;
        $this->targetFolderId = null;
    }

    public function cancelMoveGroup()
    {
        $this->movingGroupId = null;
        $this->targetFolderId = null;
    }

    public function render()
    {
        $folders = [];
        $allFolders = MemoFolder::where('user_id', Auth::id())->latest()->get();
        $groups = [];
        $currentFolder = null;

        if ($this->currentFolderId) {
            $groups = MemoGroup::where('user_id', Auth::id())
                ->where('memo_folder_id', $this->currentFolderId)
                ->with(['entries' => function ($query) {
                    $query->orderBy('created_at', 'asc');
                }])
                ->latest()
                ->get();
            $currentFolder = MemoFolder::find($this->currentFolderId);
        } else {
            $folders = $allFolders;
            $groups = MemoGroup::where('user_id', Auth::id())
                ->whereNull('memo_folder_id')
                ->with(['entries' => function ($query) {
                    $query->orderBy('created_at', 'asc');
                }])
                ->latest()
                ->get();
        }

        return view('livewire.memos.index', [
            'folders' => $folders,
            'allFolders' => $allFolders,
            'groups' => $groups,
            'currentFolder' => $currentFolder,
        ]);
    }
}
