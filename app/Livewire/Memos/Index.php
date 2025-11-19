<?php

namespace App\Livewire\Memos;

use App\Models\MemoEntry;
use App\Models\MemoGroup;
use Illuminate\Support\Facades\Auth;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class Index extends Component
{
    public $newGroupName = '';
    public $editingGroupId = null;
    public $editingGroupName = '';

    public $newEntryGroupId = null;
    public $newEntryDate = '';
    public $newEntryContent = '';

    public $editingEntryId = null;
    public $editingEntryDate = '';
    public $editingEntryContent = '';

    public function saveGroup()
    {
        $this->validate(['newGroupName' => 'required|string|max:255']);

        MemoGroup::create([
            'user_id' => Auth::id(),
            'name' => $this->newGroupName,
        ]);

        $this->newGroupName = '';
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

    public function deleteGroup($id)
    {
        $group = MemoGroup::where('user_id', Auth::id())->find($id);
        if ($group) {
            $group->delete();
        }
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
    }

    public function saveEntry()
    {
        $this->validate([
            'newEntryContent' => 'required|string',
            'newEntryDate' => 'nullable|string|max:255',
        ]);

        MemoEntry::create([
            'memo_group_id' => $this->newEntryGroupId,
            'date_label' => $this->newEntryDate,
            'content' => $this->newEntryContent,
        ]);

        $this->newEntryGroupId = null;
        $this->newEntryDate = '';
        $this->newEntryContent = '';
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
        }
    }

    public function updateEntry()
    {
        $this->validate([
            'editingEntryContent' => 'required|string',
            'editingEntryDate' => 'nullable|string|max:255',
        ]);

        $entry = MemoEntry::find($this->editingEntryId);
        if ($entry && $entry->group->user_id === Auth::id()) {
            $entry->update([
                'date_label' => $this->editingEntryDate,
                'content' => $this->editingEntryContent,
            ]);
        }

        $this->editingEntryId = null;
        $this->editingEntryDate = '';
        $this->editingEntryContent = '';
    }

    public function deleteEntry($id)
    {
        $entry = MemoEntry::find($id);
        if ($entry && $entry->group->user_id === Auth::id()) {
            $entry->delete();
        }
    }

    public function cancelEditEntry()
    {
        $this->editingEntryId = null;
    }

    public function render()
    {
        $groups = MemoGroup::where('user_id', Auth::id())
            ->with('entries')
            ->latest()
            ->get();

        return view('livewire.memos.index', [
            'groups' => $groups,
        ]);
    }
}
