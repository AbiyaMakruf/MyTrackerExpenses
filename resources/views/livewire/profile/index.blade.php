@php use Illuminate\Support\Str; @endphp

<section class="glass-card space-y-6">
    <div class="flex flex-col gap-2">
        <h1 class="text-2xl font-semibold text-[#095C4A]">Profile</h1>
        <p class="text-sm text-slate-500">Update your profile details and password.</p>
    </div>

    @if (session('profile_status'))
        <div class="rounded-2xl bg-[#D2F9E7] px-4 py-2 text-sm font-semibold text-[#08745C]">
            {{ session('profile_status') }}
        </div>
    @endif

    <div class="grid gap-4 md:grid-cols-2">
        <form wire:submit.prevent="saveProfile" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h2 class="text-lg font-semibold text-[#095C4A]">Profile details</h2>
            
            <div class="flex items-center gap-4 py-2">
                <div class="relative h-16 w-16 overflow-hidden rounded-full border border-slate-200">
                    @if ($photo)
                        <img src="{{ $photo->temporaryUrl() }}" class="h-full w-full object-cover" />
                    @elseif (auth()->user()->profile_photo_path)
                        <img src="{{ auth()->user()->profile_photo_path }}" class="h-full w-full object-cover" />
                    @else
                        <div class="flex h-full w-full items-center justify-center bg-[#D2F9E7] text-xl font-bold text-[#095C4A]">
                            {{ auth()->user()->initials() }}
                        </div>
                    @endif
                </div>
                <div class="flex flex-col gap-1">
                    <label for="photo" class="cursor-pointer rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-50 shadow-sm">
                        Change Photo
                    </label>
                    <input type="file" id="photo" wire:model="photo" class="hidden" accept="image/*" />
                    <div wire:loading wire:target="photo" class="text-xs text-slate-500">Uploading...</div>
                    @error('photo') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
            </div>

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
</section>
