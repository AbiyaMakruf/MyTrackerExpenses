<?php

use App\Livewire\Admin\Dashboard as AdminDashboard;
use App\Livewire\Dashboard\Overview as DashboardOverview;
use App\Livewire\Planning\Hub as PlanningHub;
use App\Livewire\Profile\SettingsHub;
use App\Livewire\Statistics\Overview as StatisticsOverview;
use App\Livewire\Transactions\AddRecord;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
})->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', DashboardOverview::class)->name('dashboard');
    Route::get('records/add', AddRecord::class)->name('records.add');
    Route::get('planning', PlanningHub::class)->name('planning');
    Route::get('statistics', StatisticsOverview::class)->name('statistics');
    Route::get('profile', SettingsHub::class)->name('profile.settings');
});

Route::redirect('settings', 'profile')->middleware('auth');

Route::middleware(['auth', 'can:access-admin'])
    ->prefix('admin')
    ->as('admin.')
    ->group(function () {
        Route::get('dashboard', AdminDashboard::class)->name('dashboard');
    });
