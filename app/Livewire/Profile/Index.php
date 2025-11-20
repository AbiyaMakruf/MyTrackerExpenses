<?php

namespace App\Livewire\Profile;

use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class Index extends Component
{
    public array $profileForm = [];
    public array $passwordForm = [
        'current_password' => '',
        'password' => '',
        'password_confirmation' => '',
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

    public function render(): View
    {
        return view('livewire.profile.index', [
            'timezones' => \DateTimeZone::listIdentifiers(),
        ]);
    }
}
