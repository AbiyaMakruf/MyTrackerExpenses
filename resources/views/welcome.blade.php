<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'MyTrackerExpenses') }}</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body class="antialiased bg-gradient-to-br from-[#D2F9E7] to-[#72E3BD]/40 text-slate-900 min-h-screen flex flex-col relative overflow-hidden"
      x-data="{ mouseX: 0, mouseY: 0 }"
      @mousemove="mouseX = $event.clientX; mouseY = $event.clientY">

    <!-- Background Elements -->
    <div class="absolute top-0 left-0 w-full h-full overflow-hidden -z-10">
        <div class="absolute -top-[20%] -left-[10%] w-[50%] h-[50%] rounded-full bg-[#095C4A]/10 blur-3xl transition-transform duration-700 ease-out"
             :style="`transform: translate(${mouseX * 0.02}px, ${mouseY * 0.02}px)`"></div>
        <div class="absolute top-[40%] -right-[10%] w-[40%] h-[40%] rounded-full bg-[#15B489]/10 blur-3xl transition-transform duration-700 ease-out"
             :style="`transform: translate(${mouseX * -0.02}px, ${mouseY * -0.02}px)`"></div>
        <div class="absolute -bottom-[10%] left-[20%] w-[30%] h-[30%] rounded-full bg-[#72E3BD]/20 blur-3xl transition-transform duration-700 ease-out"
             :style="`transform: translate(${mouseX * 0.01}px, ${mouseY * -0.01}px)`"></div>
        
        <!-- Floating Particles -->
        <div class="absolute top-1/4 left-1/4 w-4 h-4 bg-[#095C4A]/20 rounded-full animate-bounce" style="animation-duration: 3s;"></div>
        <div class="absolute top-3/4 right-1/4 w-6 h-6 bg-[#15B489]/20 rounded-full animate-bounce" style="animation-duration: 4s; animation-delay: 1s;"></div>
        <div class="absolute bottom-1/4 left-1/2 w-3 h-3 bg-[#72E3BD]/30 rounded-full animate-bounce" style="animation-duration: 2.5s; animation-delay: 0.5s;"></div>
    </div>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col items-center justify-center px-6" x-data="{ show: false }" x-init="setTimeout(() => show = true, 100)">
        
        <!-- Logo / Icon -->
        <div class="mb-8 transition-all duration-1000 ease-out transform"
             :class="show ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'">
            <div class="w-24 h-24 bg-white rounded-3xl shadow-xl flex items-center justify-center transform rotate-3 hover:rotate-0 transition-transform duration-300 hover:scale-105">
                <img src="{{ asset('favicon.png') }}" alt="Logo" class="w-16 h-16 object-contain">
            </div>
        </div>

        <!-- Text Content -->
        <div class="text-center max-w-2xl mx-auto space-y-6">
            <h1 class="text-4xl md:text-6xl font-bold text-[#095C4A] tracking-tight transition-all duration-1000 delay-300 ease-out transform"
                :class="show ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'">
                {{ config('app.name', 'MyTrackerExpenses') }}
            </h1>
            
            <p class="text-lg md:text-xl text-slate-600 transition-all duration-1000 delay-500 ease-out transform"
               :class="show ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'">
                Take control of your financial journey. <br class="hidden md:block">
                Track expenses, plan budgets, and achieve your goals effortlessly.
            </p>

            <!-- Action Buttons -->
            <div class="flex flex-col sm:flex-row items-center justify-center gap-4 mt-8 transition-all duration-1000 delay-700 ease-out transform"
                 :class="show ? 'translate-y-0 opacity-100' : 'translate-y-10 opacity-0'">
                
                @auth
                    <a href="{{ route('dashboard') }}" 
                       class="group relative inline-flex items-center justify-center px-8 py-3 text-base font-semibold text-white transition-all duration-200 bg-[#095C4A] rounded-full hover:bg-[#074a3b] hover:shadow-lg hover:-translate-y-0.5 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#095C4A]">
                        <span>Go to Dashboard</span>
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5 ml-2 transition-transform duration-200 group-hover:translate-x-1">
                            <path fill-rule="evenodd" d="M3 10a.75.75 0 01.75-.75h10.638L10.23 5.29a.75.75 0 111.04-1.08l5.5 5.25a.75.75 0 010 1.08l-5.5 5.25a.75.75 0 11-1.04-1.08l4.158-3.96H3.75A.75.75 0 013 10z" clip-rule="evenodd" />
                        </svg>
                    </a>
                @else
                    <a href="{{ route('login') }}" 
                       class="group relative inline-flex items-center justify-center px-8 py-3 text-base font-semibold text-white transition-all duration-200 bg-[#095C4A] rounded-full hover:bg-[#074a3b] hover:shadow-lg hover:-translate-y-0.5 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#095C4A]">
                        <span>Login to Account</span>
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5 ml-2 transition-transform duration-200 group-hover:translate-x-1">
                            <path fill-rule="evenodd" d="M3 10a.75.75 0 01.75-.75h10.638L10.23 5.29a.75.75 0 111.04-1.08l5.5 5.25a.75.75 0 010 1.08l-5.5 5.25a.75.75 0 11-1.04-1.08l4.158-3.96H3.75A.75.75 0 013 10z" clip-rule="evenodd" />
                        </svg>
                    </a>
                @endauth

            </div>
        </div>
    </div>

    <!-- Footer -->

</body>
</html>
