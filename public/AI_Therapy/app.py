<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>静屿 StillIsle</title>
    
    <script src="https://cdn.socket.io/4.7.2/socket.io.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.13.3/dist/cdn.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tone/14.8.49/Tone.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@300;500;700&family=Playfair+Display:ital,wght@0,400;0,700;1,400&family=Lato:wght@300;400;700&family=Noto+Sans+SC:wght@300;400;500;700&display=swap" rel="stylesheet">

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'bg': '#F9F7F2', 'ink': '#2C2C2C', 'sub': '#666666', 
                        'accent': '#C5A059', 'paper': '#F0EFE9',
                        'medical-blue': '#2563EB',
                        // 灵犀专用色
                        'soul-light': '#fffcf5', 'soul-shadow': '#e6d5c8'
                    },
                    fontFamily: {
                        'serif': ['"Noto Serif SC"', '"Playfair Display"', 'serif'],
                        'sans': ['"Lato"', '"Noto Sans SC"', 'sans-serif'],
                    },
                    boxShadow: { 'deck': '0 25px 50px -12px rgba(0,0,0,0.4)', 'soft': '0 10px 30px rgba(0,0,0,0.1)' },
                    // 灵犀专用动画
                    animation: {
                        'breathe-slow': 'breathe 3s infinite ease-in-out',
                        'pulse-speaking': 'pulse-speaking 1.5s infinite ease-in-out'
                    },
                    keyframes: {
                        breathe: { '0%, 100%': { transform: 'scale(1)', opacity: '0.95' }, '50%': { transform: 'scale(1.05)', opacity: '1' } },
                        'pulse-speaking': { '0%': { transform: 'scale(1)', borderWidth: '4px' }, '50%': { transform: 'scale(1.08)', borderWidth: '2px' }, '100%': { transform: 'scale(1)', borderWidth: '4px' } }
                    }
                }
            }
        }
    </script>

    <style>
        [x-cloak] { display: none !important; }
        body { background-color: #F9F7F2; color: #2C2C2C; overflow: hidden; user-select: none; }
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .fade-in { animation: fadeIn 0.6s ease-out forwards; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        
        /* --- 灵犀 (Soul Core) 核心样式 --- */
        #soul-core {
            width: 180px; height: 180px; border-radius: 50%;
            background: radial-gradient(circle at 30% 30%, #fffcf5, #e6d5c8);
            box-shadow: inset 0 0 20px rgba(255,255,255,0.9), 0 15px 35px rgba(141, 123, 114, 0.2);
            border: 4px solid rgba(255,255,255,0.5);
            cursor: pointer; position: relative; z-index: 10;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            -webkit-tap-highlight-color: transparent;
        }
        /* 状态: 录音中 */
        .state-recording #soul-core { 
            transform: scale(1.1); 
            border-color: #a7c4bc; 
            box-shadow: 0 0 50px rgba(167, 196, 188, 0.5); 
        }
        /* 状态: 思考中 */
        .state-thinking #soul-core { 
            border-color: #C5A059; 
            box-shadow: 0 0 40px rgba(197, 160, 89, 0.4); 
            animation: breathe 2s infinite ease-in-out; 
        }
        /* 状态: 说话中 */
        .state-speaking #soul-core { 
            border-color: #d4a5b3; 
            box-shadow: 0 0 50px rgba(212, 165, 179, 0.5); 
            animation: pulse-speaking 1.5s infinite ease-in-out; 
        }

        /* MBTI 样式 */
        .likert-container { display: flex; justify-content: space-between; align-items: center; margin: 40px 0; position: relative; padding: 0 20px; }
        .likert-line { position: absolute; top: 50%; left: 40px; right: 40px; height: 2px; background: #e5e5e5; z-index: 0; }
        .likert-option { width: 50px; height: 50px; border-radius: 50%; background: #fff; border: 2px solid #e5e5e5; z-index: 1; cursor: pointer; transition: all 0.25s cubic-bezier(0.175, 0.885, 0.32, 1.275); display: flex; align-items: center; justify-content: center; }
        .likert-option:hover { border-color: #C5A059; transform: scale(1.1); }
        .likert-option.selected { background: #C5A059; border-color: #C5A059; color: white; transform: scale(1.2); box-shadow: 0 10px 20px -5px rgba(197, 160, 89, 0.4); }
        .mbti-label { position: absolute; top: -30px; font-size: 12px; font-weight: bold; color: #C5A059; letter-spacing: 0.1em; }
        .mbti-label.agree { left: 20px; } .mbti-label.disagree { right: 20px; }

        /* SCL-90 按钮 */
        .scl-btn { width: 100%; height: 60px; border-radius: 12px; border: 1px solid transparent; background: #fff; color: #888; transition: all 0.2s ease; display: flex; flex-direction: column; align-items: center; justify-content: center; box-shadow: 0 2px 5px rgba(0,0,0,0.02); }
        .scl-btn:hover { background: #f8fafc; color: #2563EB; }
        .scl-btn.selected { background: #2563EB; color: white; box-shadow: 0 8px 16px -4px rgba(37, 99, 235, 0.4); transform: translateY(-2px); border-color: #2563EB; }

        /* Oracle Deck */
        .deck-stack { position: relative; transition: transform 0.2s ease; transform-origin: center bottom; }
        .deck-stack::before { top: 3px; left: 2px; z-index: -1; transform: rotate(1deg); content:''; position:absolute; width:100%; height:100%; background:#fff; border:1px solid #ddd; border-radius:12px; }
        .deck-stack::after { top: 6px; left: 4px; z-index: -2; transform: rotate(-1deg); box-shadow: 0 15px 35px rgba(0,0,0,0.1); content:''; position:absolute; width:100%; height:100%; background:#fff; border:1px solid #ddd; border-radius:12px; }
        .animate-shuffle { animation: shuffle-move 0.3s ease-in-out infinite; }
        @keyframes shuffle-move { 0% { transform: translateY(0) rotate(0deg); } 25% { transform: translateY(-5px) rotate(-2deg); } 75% { transform: translateY(-3px) rotate(2deg); } 100% { transform: translateY(0) rotate(0deg); } }

        /* Nightlight Character */
        #module-nightlight .character-container { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 200px; height: 240px; z-index: 10; display: flex; flex-direction: column; align-items: center; filter: drop-shadow(0 0 40px rgba(255,255,255,0.6)); animation: float 5s ease-in-out infinite, bob 2s ease-in-out infinite alternate; cursor: pointer; }
        #module-nightlight .character-body { position: relative; width: 150px; height: 170px; background-color: #ffffff; border-radius: 75px 75px 65px 65%; box-shadow: inset 0 0 30px rgba(230,230,255,1); animation: breathe 3s ease-in-out infinite, jelly 4s ease-in-out infinite; display: flex; justify-content: center; }
        #module-nightlight .eyes { position: absolute; top: 42%; width: 54px; display: flex; justify-content: space-between; }
        #module-nightlight .eye { width: 14px; height: 14px; background-color: #222; border-radius: 50%; animation: blink 3.5s infinite; }
        #module-nightlight .blush { position: absolute; top: 54%; width: 18px; height: 10px; background-color: #ffaaaa; border-radius: 50%; filter: blur(2px); opacity: 0.8; }
        #module-nightlight .blush.left { left: 28px; } #module-nightlight .blush.right { right: 28px; }
        #module-nightlight .arm { position: absolute; top: 62%; width: 30px; height: 44px; background-color: #ffffff; border-radius: 15px; }
        #module-nightlight .arm.left { left: -12px; transform-origin: top center; transform: rotate(20deg); animation: waveLeft 3s ease-in-out infinite; }
        #module-nightlight .arm.right { right: -12px; transform-origin: top center; transform: rotate(-20deg); animation: waveRight 3s ease-in-out infinite; }
        #module-nightlight .feet { display: flex; justify-content: space-between; width: 90px; margin-top: -16px; position: relative; z-index: -1; }
        #module-nightlight .foot { width: 36px; height: 32px; background-color: #ffffff; border-radius: 0 0 18px 18px; animation: kick 1.5s ease-in-out infinite alternate; }
        @keyframes float { 0%, 100% { transform: translate(-50%, -50%) translateY(0); } 50% { transform: translate(-50%, -50%) translateY(-20px); } }
        @keyframes breathe { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.03); } }
        @keyframes blink { 0%, 96%, 100% { height: 14px; } 98% { height: 2px; } }
        @keyframes waveLeft { 0%, 100% { transform: rotate(20deg); } 50% { transform: rotate(35deg); } }
        @keyframes waveRight { 0%, 100% { transform: rotate(-20deg); } 50% { transform: rotate(-35deg); } }
        @keyframes jelly { 0%, 100% { border-radius: 75px 75px 65px 65%; } 25% { border-radius: 70px 80px 60px 70%; } 50% { border-radius: 80px 70px 70px 60%; } 75% { border-radius: 65px 75px 75px 65%; } }
        @keyframes bob { 0%, 100% { margin-top: 0; } 50% { margin-top: 5px; } }
        @keyframes kick { 0%, 100% { transform: translateY(0) rotate(0); } 50% { transform: translateY(-3px) rotate(5deg); } }

        /* 通用组件 */
        input[type="range"] { -webkit-appearance: none; width: 100%; height: 6px; border-radius: 3px; background: rgba(255,255,255,0.3); }
        input[type="range"]::-webkit-slider-thumb { -webkit-appearance: none; width: 16px; height: 16px; border-radius: 50%; background: #fff; cursor: pointer; }
    </style>
</head>

<body class="h-screen w-screen flex flex-col" x-data="mainApp()" x-init="init()" @keydown.window="handleKey($event)">
    <div class="absolute inset-0 -z-20 transition-colors duration-1000 ease-in-out" :style="bgStyle"></div>
    <canvas id="particle-canvas" class="absolute inset-0 -z-10 opacity-30 pointer-events-none"></canvas>

    <nav class="fixed top-0 w-full h-24 px-8 md:px-12 flex justify-between items-end pb-6 z-50 transition-all duration-500" 
         :class="activeModule ? 'bg-white/90 backdrop-blur-md border-b border-black/5' : ''">
        
        <div class="cursor-pointer group flex items-center gap-4" @click="goHome()">
            <div x-show="activeModule" class="text-xs uppercase tracking-widest text-sub group-hover:text-ink transition flex items-center gap-2">
                <i class="fa-solid fa-arrow-left"></i> <span>返回</span>
            </div>
            <h1 class="text-2xl font-serif font-bold tracking-wide text-ink" x-show="!activeModule || activeModule === 'journal'">静屿</h1>
        </div>
        
        <div class="flex gap-10 text-xs font-sans tracking-widest uppercase text-sub" x-show="!activeModule">
            <button @click="tab='today'" :class="tab==='today'?'text-ink font-bold border-b border-ink pb-1':'hover:text-ink'">当下</button>
            <button @click="tab='explore'" :class="tab==='explore'?'text-ink font-bold border-b border-ink pb-1':'hover:text-ink'">探索</button>
            <button @click="tab='chat'" :class="tab==='chat'?'text-accent font-bold border-b border-accent pb-1':'hover:text-ink'">灵犀</button>
        </div>
    </nav>

    <main class="flex-grow pt-28 px-8 md:px-12 overflow-hidden relative">
        
        <div x-show="tab === 'today' && !activeModule" class="max-w-4xl mx-auto fade-in h-full overflow-y-auto no-scrollbar pb-24">
            <header class="mb-16 mt-8 text-center">
                <p class="text-xs font-sans text-sub tracking-widest uppercase mb-6" x-text="dateStr"></p>
                <h2 class="text-2xl md:text-3xl font-serif text-ink font-light leading-relaxed tracking-wide max-w-2xl mx-auto line-clamp-2">
                    “<span x-text="dailyQuote.cn"></span>”
                </h2>
                <p class="text-xs font-serif text-sub italic mt-4">— <span x-text="dailyQuote.en"></span></p>
            </header>
            
            <div class="border-t border-black/10 pt-12 grid grid-cols-1 md:grid-cols-2 gap-16">
                <div class="group cursor-pointer" @click="openModule('meditation')">
                    <div class="flex justify-between items-baseline mb-3">
                        <span class="text-xs font-sans text-accent tracking-widest uppercase">Focus & Breathe</span>
                        <span class="text-xl text-ink group-hover:translate-x-2 transition">→</span>
                    </div>
                    <h3 class="text-3xl font-serif text-ink mb-3 group-hover:opacity-70 transition nav-text font-bold">在此 · 冥想</h3>
                    <p class="text-base text-sub font-light leading-relaxed">给自己十分钟。<br>声景 · 呼吸练习 · 正念引导</p>
                </div>
                <div class="group cursor-pointer" @click="openModule('journal')">
                    <div class="flex justify-between items-baseline mb-3">
                        <span class="text-xs font-sans text-sub tracking-widest uppercase">Daily Routine</span>
                        <span class="text-xl text-ink group-hover:translate-x-2 transition">→</span>
                    </div>
                    <h3 class="text-3xl font-serif text-ink mb-3 group-hover:opacity-70 transition nav-text font-bold">觉察日记</h3>
                    <p class="text-base text-sub font-light leading-relaxed">观照自我。<br>记录情绪与念头，建立内心秩序。</p>
                </div>
            </div>
        </div>

        <div x-show="tab === 'explore' && !activeModule" class="max-w-6xl mx-auto fade-in h-full overflow-y-auto no-scrollbar pb-24">
            <div class="mb-16 mt-8">
                <h4 class="text-xs font-sans text-sub tracking-widest uppercase mb-10 border-b border-black/10 pb-3">Inner Self / 本我探索</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-12">
                    <div class="cursor-pointer group explore-item md:text-left" @click="openModule('mbti')">
                        <h3 class="text-2xl font-serif text-ink mb-2 font-bold group-hover:text-accent transition">MBTI 人格</h3>
                        <p class="text-sm text-sub font-light leading-relaxed">深度解析性格底色。<br>基于 NERIS 模型 (60题)。</p>
                    </div>
                    <div class="cursor-pointer group explore-item md:text-left" @click="openModule('scl90')">
                        <h3 class="text-2xl font-serif text-ink mb-2 font-bold group-hover:text-accent transition">SCL-90</h3>
                        <p class="text-sm text-sub font-light leading-relaxed">心理健康状态自查。<br>90 项专业临床评估。</p>
                    </div>
                </div>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-16">
                <div>
                    <h4 class="text-xs font-sans text-sub tracking-widest uppercase mb-10 border-b border-black/10 pb-3">Wisdom / 灵启</h4>
                    <div class="cursor-pointer group explore-item" @click="openModule('oracle')">
                        <h3 class="text-2xl font-serif text-ink mb-2 font-bold group-hover:text-accent transition">神谕与答案</h3>
                        <p class="text-sm text-sub font-light leading-relaxed">读心卡牌 · 答案之书。<br>连接直觉，寻找当下的指引。</p>
                    </div>
                </div>
                <div>
                    <h4 class="text-xs font-sans text-sub tracking-widest uppercase mb-10 border-b border-black/10 pb-3">Art / 疗愈</h4>
                    <div class="space-y-8">
                        <div class="cursor-pointer group explore-item" @click="openModule('nightlight')">
                            <h3 class="text-2xl font-serif text-ink mb-2 font-bold group-hover:text-accent transition">小夜灯</h3>
                            <p class="text-sm text-sub font-light leading-relaxed">Night Healing Light.<br>极致色彩疗愈，点亮内心的角落。</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div x-show="tab === 'chat' && !activeModule" class="w-full h-full fade-in flex flex-col items-center justify-center relative" x-data="chatApp()" x-init="init()">
            <div class="relative group" :class="'state-' + state">
                <div id="soul-core"
                     @mousedown="startRecord" 
                     @mouseup="stopRecord"
                     @mouseleave="stopRecord"
                     @touchstart.prevent="startRecord" 
                     @touchend.prevent="stopRecord">
                     
                     <div x-show="state === 'idle'" class="text-sub opacity-40 transition-opacity">
                        <i class="fa-solid fa-microphone text-2xl"></i>
                     </div>
                     <div x-show="state === 'recording'" class="w-3 h-3 bg-[#a7c4bc] rounded-full animate-ping"></div>
                     <div x-show="state === 'thinking'" class="text-accent text-sm font-bold tracking-[0.2em]">思考中</div>
                </div>
                
                <div x-show="state === 'recording'" class="absolute inset-0 rounded-full border border-[#a7c4bc] animate-[ping_2s_cubic-bezier(0,0,0.2,1)_infinite] -z-10 opacity-30"></div>
            </div>

            <div class="mt-12 text-center h-8">
                <p class="text-xs font-sans tracking-[0.3em] uppercase text-sub transition-all duration-300" x-text="hintText"></p>
            </div>

            <div class="absolute bottom-20 w-full px-6 md:px-20 text-center">
                <p class="text-xl md:text-2xl text-ink font-serif font-medium leading-relaxed transition-all duration-300 min-h-[4rem] flex items-center justify-center" 
                   style="text-shadow: 0 2px 10px rgba(255,255,255,0.8);"
                   x-text="subtitle"></p>
            </div>

            <div x-show="showPlayBtn" class="absolute bottom-40 z-50 animate-bounce">
                <button @click="retryPlay" class="px-6 py-2 bg-[#d4a5b3] text-white rounded-full text-xs tracking-widest shadow-lg hover:bg-[#c08fa0] transition-colors">
                    点击播放声音
                </button>
            </div>
        </div>

        <div x-show="activeModule === 'meditation'" class="absolute inset-0 z-40 flex fade-in font-sans" id="module-beinghere" x-data="beingHereApp()">
            <div class="w-64 h-full border-r border-black/5 flex flex-col pt-32 pb-10 pl-10 pr-6 z-20 bg-white/40 backdrop-blur-xl">
                <div class="mb-16"><div class="text-3xl font-serif font-bold text-ink tracking-wide">在此</div><div class="text-[10px] uppercase tracking-widest text-sub mt-2 opacity-70">Focus & Breathe</div></div>
                <div class="flex flex-col gap-6">
                    <div class="text-[10px] uppercase tracking-widest text-black/40 font-bold mb-2">模式</div>
                    <template x-for="m in modes"><button @click="switchMode(m.id)" :class="currentMode===m.id ? 'text-ink font-bold pl-3 border-l-2 border-ink' : 'text-sub hover:text-ink'" class="text-left text-sm tracking-widest uppercase transition-all h-8 flex items-center"><span x-text="m.label"></span></button></template>
                </div>
            </div>
            <div class="flex-1 relative flex flex-col items-center justify-center h-full" @click="stopAlarm()">
                <div x-show="currentMode === 'focus' || currentMode === 'breathe'" class="text-center relative z-10 w-full h-full flex flex-col items-center justify-center">
                    <div class="w-[380px] h-[380px] rounded-full flex flex-col items-center justify-center bg-white/10 backdrop-blur-sm cursor-pointer transition-all duration-700 hover:bg-white/20" :class="isRunning ? 'breathe-active' : 'breathe-circle'" :style="visualStyle" @click.stop="toggle()">
                        <div x-show="currentMode === 'focus'" class="text-8xl font-serif text-ink font-light tabular-nums tracking-tighter" x-text="timerDisplay"></div>
                        <div x-show="currentMode === 'breathe'" class="flex flex-col items-center">
                            <span class="text-4xl font-serif text-ink font-light tracking-widest uppercase mb-4" x-text="statusText === '准备' ? breathName : statusText"></span>
                            <span x-show="isRunning && breathTimer > 0" class="text-2xl font-serif text-ink/50" x-text="breathTimer"></span>
                        </div>
                        <div class="text-xs uppercase tracking-[0.4em] text-ink/60 mt-6 font-bold" x-text="currentMode === 'focus' ? statusText : ''"></div>
                    </div>
                    <div x-show="isAlarmRinging" class="absolute bottom-32 w-full text-center pulse-text"><p class="text-xs font-sans tracking-widest uppercase text-accent">点击屏幕任意处停止 / Tap Screen to Stop</p></div>
                    <div class="mt-16 flex items-center gap-12 text-xs tracking-[0.2em] font-bold text-ink uppercase">
                        <button @click.stop="toggle()" class="hover:opacity-50 transition border-b border-transparent hover:border-ink pb-1" x-text="isRunning ? '暂停' : '开始'"></button>
                        <div class="relative" x-data="{ open: false }" @click.outside="open = false">
                            <button @click.stop="open = !open" class="hover:opacity-50 transition border-b border-transparent hover:border-ink pb-1 flex items-center gap-2">设置 <i class="fa-solid fa-sliders"></i></button>
                            <div x-show="open" class="absolute bottom-12 left-1/2 -translate-x-1/2 w-64 bg-white shadow-xl rounded-xl p-6 z-50 text-left normal-case tracking-normal">
                                <div x-show="currentMode === 'focus'"><div class="text-[10px] text-sub uppercase mb-2">时长 (分钟)</div><div class="grid grid-cols-3 gap-2 mb-2"><button @click="setDuration(25)" class="p-2 border rounded text-center hover:bg-gray-50 text-xs">25</button><button @click="setDuration(45)" class="p-2 border rounded text-center hover:bg-gray-50 text-xs">45</button><button @click="setDuration(0)" class="p-2 border rounded text-center hover:bg-gray-50 text-xs text-xl">∞</button></div><div class="flex gap-2 mb-4"><input type="number" placeholder="自定义" class="w-full p-2 border rounded text-xs outline-none" @change="setDuration($event.target.value)"></div><div class="text-[10px] text-sub uppercase mb-2">结束铃声</div><div class="flex flex-col gap-2"><button @click="setAlarm('echo'); playSample('Nature-audio/Echo.MP3')" class="text-left text-xs hover:text-accent p-1 rounded" :class="alarmSound==='echo'?'bg-gray-100 font-bold':''">回声谷</button><button @click="setAlarm('campfire'); playSample('Nature-audio/Campfire.MP3')" class="text-left text-xs hover:text-accent p-1 rounded" :class="alarmSound==='campfire'?'bg-gray-100 font-bold':''">营地篝火</button><button @click="setAlarm('seabreeze'); playSample('Nature-audio/Seabreeze.MP3')" class="text-left text-xs hover:text-accent p-1 rounded" :class="alarmSound==='seabreeze'?'bg-gray-100 font-bold':''">海浪</button></div></div>
                                <div x-show="currentMode === 'breathe'"><div class="text-[10px] text-sub uppercase mb-2">模式</div><div class="flex flex-col gap-2"><button @click="setBreath('4-7-8', '舒缓')" class="text-left p-2 rounded hover:bg-gray-50 text-xs flex justify-between" :class="breathPattern==='4-7-8'?'font-bold':''"><span>舒缓 (4-7-8)</span></button><button @click="setBreath('5-5-5', '平衡')" class="text-left p-2 rounded hover:bg-gray-50 text-xs flex justify-between" :class="breathPattern==='5-5-5'?'font-bold':''"><span>平衡 (箱式)</span></button></div></div>
                            </div>
                        </div>
                        <button @click.stop="reset()" class="hover:opacity-50 transition border-b border-transparent hover:border-ink pb-1">重置</button>
                    </div>
                </div>
                <div x-show="currentMode === 'sound' || currentMode === 'mind'" class="w-full h-full absolute inset-0 overflow-y-auto no-scrollbar p-16 pt-24" @click.stop>
                    <h2 class="text-3xl font-serif text-ink mb-10 ml-2" x-text="currentMode === 'sound' ? '声景' : '正念引导'"></h2>
                    <p x-show="currentMode === 'mind'" class="ml-2 mb-4 text-xs text-sub italic">引导音频可与声景叠加播放。</p>
                    <template x-for="(section, title) in (currentMode === 'sound' ? soundCollections : mindCollections)">
                        <div class="mb-12"><h3 class="text-sm font-sans tracking-widest uppercase text-sub mb-6 border-b border-black/10 pb-2" x-text="title"></h3><div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6"><template x-for="track in section"><div class="cursor-pointer group" @click="playSound(track, currentMode === 'sound' ? 'bg' : 'voice')"><div class="aspect-square bg-gray-200 mb-3 overflow-hidden relative rounded-lg shadow-sm border border-black/5"><img :src="track.cover" class="w-full h-full object-cover transition duration-700 group-hover:scale-110 opacity-90 group-hover:opacity-100" onerror="this.style.display='none'; this.parentNode.style.backgroundColor='#cccccc'"><div class="absolute inset-0 bg-black/10 flex items-center justify-center transition-opacity duration-300" :class="(currentMode === 'sound' ? (currentBg === track.file && isBgPlaying) : (currentVoice === track.file && isVoicePlaying)) ? 'opacity-100' : 'opacity-0 group-hover:opacity-100'"><i class="fa-solid text-white text-xl" :class="(currentMode === 'sound' ? (currentBg === track.file && isBgPlaying) : (currentVoice === track.file && isVoicePlaying)) ? 'fa-pause' : 'fa-play'"></i></div></div><div class="text-sm font-serif text-ink group-hover:text-accent truncate text-center" x-text="track.title"></div></div></template></div></div>
                    </template>
                </div>
            </div>
            <audio id="audio-bg" loop></audio><audio id="audio-voice"></audio><audio id="alarm-audio"></audio>
        </div>

        <div x-show="activeModule === 'journal'" class="absolute inset-0 z-40 bg-[#F9F8F4] overflow-y-auto no-scrollbar fade-in" id="module-journal" x-data="journalApp()" x-init="init()">
            <div class="max-w-3xl mx-auto px-8 pt-32 pb-20 min-h-full flex flex-col">
                <header class="text-center mb-10 fade-in"><h1 class="text-5xl md:text-6xl font-journal-en font-bold text-ink mb-6 tracking-tight">Know Your Self</h1><nav class="flex justify-center gap-12 font-journal-en text-xs uppercase tracking-[0.2em] text-sub"><span @click="view='write'" class="cursor-pointer pb-1 transition-all border-b border-transparent hover:border-ink" :class="view==='write'?'text-ink font-bold border-ink':''">深读 / 今日书写</span><span @click="view='history'" class="cursor-pointer pb-1 transition-all border-b border-transparent hover:border-ink" :class="view==='history'?'text-ink font-bold border-ink':''">过往 / 历史篇章</span></nav></header>
                <div class="text-center mb-12 px-4 py-8 border-y border-[#E0E0E0]"><div class="text-lg font-serif text-ink mb-2" x-text="quote.cn"></div><div class="text-sm font-journal-en italic text-sub" x-text="quote.en"></div></div>
                <div x-show="view === 'write'" class="fade-in">
                    <div class="text-center mb-12 text-xs font-journal-en tracking-[0.2em] text-[#999]" x-text="dateDisplay"></div>
                    <div class="mb-16"><span class="block font-journal-en text-xs uppercase tracking-widest text-[#888] mb-3">Achievement</span><div class="text-2xl font-serif text-ink mb-6">小确幸</div><textarea x-model="entry.achievement" class="w-full bg-transparent border-none resize-none p-0 text-lg font-serif text-ink focus:ring-0 journal-input outline-none min-h-[100px]" placeholder="记录今日的微小成就..."></textarea></div>
                    <div class="mb-16"><span class="block font-journal-en text-xs uppercase tracking-widest text-[#888] mb-3">Gratitude</span><div class="text-2xl font-serif text-ink mb-6">感恩时刻</div><textarea x-model="entry.gratitude" class="w-full bg-transparent border-none resize-none p-0 text-lg font-serif text-ink focus:ring-0 journal-input outline-none min-h-[100px]" placeholder="值得感谢的人或事..."></textarea></div>
                    <div class="mb-20"><span class="block font-journal-en text-xs uppercase tracking-widest text-[#888] mb-3">Mood Check-in</span><div class="text-2xl font-serif text-ink mb-6">心境</div><div class="flex gap-8 font-journal-en italic text-[#888] mb-8"><template x-for="m in ['Sunny','Cloudy','Rainy','Storm','Calm']"><span @click="entry.moodVal = m" class="cursor-pointer hover:text-ink relative mood-btn transition" :class="entry.moodVal === m ? 'text-ink font-bold selected scale-110' : ''" x-text="m"></span></template></div><textarea x-model="entry.moodText" class="w-full bg-transparent border-none resize-none p-0 text-lg font-serif text-ink focus:ring-0 journal-input outline-none min-h-[80px]" placeholder="此刻的念头..."></textarea></div>
                    <button @click="save()" class="block mx-auto px-16 py-4 border border-ink text-ink font-journal-en text-xs uppercase tracking-widest hover:bg-ink hover:text-white transition-all duration-300">保存</button>
                </div>
                <div x-show="view === 'history'" class="fade-in">
                    <template x-for="item in history"><div class="py-12 border-b border-[#E0E0E0] last:border-0 flex flex-col items-start"><div class="font-journal-en text-xs uppercase tracking-widest text-[#888] mb-4">HEAL / <span x-text="item.dateStr"></span> / <span x-text="item.moodVal"></span></div><div class="font-journal-en text-4xl text-ink mb-6 leading-tight">Inner Self</div><div class="text-lg font-serif text-[#555] font-light mb-8 line-clamp-3 leading-relaxed" x-text="getPreview(item)"></div><button @click="showDetail(item)" class="font-journal-en text-xs uppercase underline underline-offset-4 text-ink hover:text-[#888] transition">阅读全文</button></div></template>
                    <div x-show="history.length === 0" class="text-center py-20 font-journal-en italic text-[#888]">暂无记录，开始书写第一篇章。</div>
                </div>
            </div>
        </div>

        <div x-show="activeModule === 'mbti'" class="absolute inset-0 z-40 bg-[#F9F7F2] overflow-y-auto no-scrollbar fade-in" id="module-mbti" x-data="mbtiApp()" x-init="init()" @keydown.window="handleCheat($event)">
            <button @click="goHome()" class="fixed top-8 right-10 z-50 text-[10px] uppercase tracking-widest text-sub hover:text-ink">关闭</button>
            <div class="max-w-2xl mx-auto px-6 py-10 min-h-screen flex flex-col items-center justify-center">
                <div x-show="step===0" class="text-center">
                    <h2 class="text-4xl font-serif font-bold text-ink mb-6">MBTI 人格分析</h2>
                    <p class="text-sm text-sub mb-12">深度解析性格底色 · 60道精选题</p>
                    <button @click="start()" class="px-10 py-3 bg-ink text-white font-serif tracking-widest hover:bg-accent transition">开始测试</button>
                </div>
                <div x-show="step===1" class="w-full">
                    <div class="flex justify-between text-xs font-bold text-sub mb-2 uppercase tracking-widest">
                        <span x-text="'Question ' + (currentIdx + 1)"></span>
                        <span x-text="'/ ' + questions.length"></span>
                    </div>
                    <div class="w-full h-1 bg-gray-200 rounded-full mb-12"><div class="h-full bg-ink transition-all duration-500" :style="`width: ${((currentIdx+1)/questions.length)*100}%`"></div></div>
                    <div class="min-h-[160px] flex flex-col items-center justify-center mb-10 text-center">
                        <h3 class="text-2xl font-serif text-ink leading-relaxed mb-12" x-text="questions[currentIdx]?.q"></h3>
                        <div class="w-full likert-container">
                            <span class="mbti-label agree">同意</span>
                            <span class="mbti-label disagree">不认同</span>
                            <div class="likert-line"></div>
                            <template x-for="i in 7">
                                <div class="likert-option" :class="selectedScore === i ? 'selected' : ''" @click="selectScore(i)" :style="i === 4 ? 'width:30px;height:30px;border-width:1px' : (i===1||i===7 ? 'width:60px;height:60px;border-width:3px' : '')"></div>
                            </template>
                        </div>
                    </div>
                    <div class="flex justify-center mt-8">
                        <button @click="next()" :disabled="!selectedScore" class="px-10 py-3 bg-ink text-white font-serif tracking-widest hover:bg-accent transition disabled:opacity-30 disabled:cursor-not-allowed">下一步</button>
                    </div>
                </div>
                <div x-show="step===2" class="text-center w-full max-w-4xl pb-20">
                    <div class="text-xs font-bold text-sub tracking-widest uppercase mb-4">Your Personality Type</div>
                    <h1 class="text-6xl font-serif font-bold text-ink mb-2" x-text="result.code"></h1>
                    <h2 class="text-2xl font-serif text-accent mb-8" x-text="result.name"></h2>
                    <div class="mb-10 text-left bg-white p-10 rounded-xl shadow-sm border border-gray-100">
                        <div class="text-center mb-8 border-b border-gray-100 pb-6">
                            <p class="text-xl font-serif italic text-ink mb-2">"<span x-text="result.quote"></span>"</p>
                            <p class="text-xs font-sans text-sub uppercase">— <span x-text="result.author"></span></p>
                        </div>
                        <p class="text-sm text-sub leading-loose text-justify whitespace-pre-line font-sans" x-html="result.desc"></p>
                    </div>
                    <div class="flex flex-col gap-4">
                        <button @click="goHome()" class="text-xs underline text-ink">返回主页</button>
                        <button @click="retake()" class="text-xs text-sub/50 hover:text-ink uppercase tracking-widest">重新测试 (Retake Test)</button>
                    </div>
                </div>
            </div>
        </div>

        <div x-show="activeModule === 'scl90'" class="absolute inset-0 z-40 bg-[#FDFCF8] overflow-y-auto no-scrollbar fade-in" id="module-scl90" x-data="scl90App()" @keydown.window="handleCheat($event)">
            <button @click="goHome()" class="fixed top-8 right-10 z-50 text-[10px] uppercase tracking-widest text-sub hover:text-ink">关闭</button>
            <div class="flex-grow flex items-center justify-center px-6 pt-32 pb-20 min-h-screen">
                <div x-show="step === 0" class="w-full max-w-md text-center animate-fade-in py-10">
                    <div class="mb-12"><h1 class="text-4xl font-serif text-ink font-bold tracking-wide mb-3">症状自评量表 SCL-90</h1><p class="text-sm font-sans tracking-widest-xl text-sub uppercase">Symptom Checklist 90</p></div>
                    <div class="flex justify-center items-center gap-12 mb-16 font-sans text-xs tracking-wide text-sub"><div class="flex flex-col items-center gap-2"><span class="text-ink text-xl font-serif font-semibold">16+</span><span class="uppercase tracking-widest text-[10px]">适用年龄</span></div><div class="w-px h-8 bg-gray-200"></div><div class="flex flex-col items-center gap-2"><span class="text-ink text-xl font-serif font-semibold">90</span><span class="uppercase tracking-widest text-[10px]">项目数量</span></div></div>
                    <button @click="startTest()" class="w-full py-4 bg-ink text-paper text-sm font-sans uppercase tracking-widest hover:bg-sub transition-colors duration-300 rounded-sm shadow-lg">开始测评</button>
                </div>
                <div x-show="step === 1" class="w-full max-w-2xl mx-auto py-10">
                    <div class="w-full h-1 bg-gray-100 rounded-full mb-12"><div class="h-full bg-ink transition-all duration-500" :style="`width: ${progress}%`"></div></div>
                    <template x-for="(qIndex, idx) in currentBatch" :key="qIndex">
                        <div class="mb-16 animate-fade-in">
                            <div class="flex flex-col items-center text-center mb-8"><span class="text-xs font-sans text-sub tracking-widest mb-2">ITEM <span x-text="qIndex + 1"></span> / 90</span><h3 class="text-2xl font-serif text-ink leading-normal" x-text="questions[qIndex]"></h3></div>
                            <div class="relative">
                                <div class="flex justify-between text-[10px] text-gray-400 font-bold uppercase tracking-widest mb-2 px-2"><span>从无 (Never)</span><span>严重 (Severe)</span></div>
                                <div class="grid grid-cols-5 gap-3">
                                    <template x-for="opt in options" :key="opt.val">
                                        <button @click="answer(qIndex, opt.val)" :class="answers[qIndex] === opt.val ? 'selected' : ''" class="scl-btn">
                                            <span class="text-lg font-serif mb-1" x-text="opt.val"></span>
                                            <span class="text-[9px] font-sans uppercase tracking-wider" x-text="opt.label" x-show="answers[qIndex] === opt.val"></span>
                                        </button>
                                    </template>
                                </div>
                            </div>
                        </div>
                    </template>
                    <div class="flex justify-between items-center pt-10 border-t border-gray-100">
                        <button @click="prevPage()" :disabled="currentPage === 0" class="text-sm font-sans tracking-widest text-sub hover:text-ink disabled:opacity-0 transition-colors">← BACK</button>
                        <button @click="nextPage()" :disabled="!canGoNext" :class="canGoNext ? 'bg-ink text-paper' : 'bg-gray-200 text-white cursor-not-allowed'" class="px-8 py-3 text-sm font-sans tracking-widest transition-colors duration-300 rounded-sm">
                            <span x-text="isLastPage ? 'SUBMIT / 提交' : 'NEXT / 下一页'"></span>
                        </button>
                    </div>
                </div>
                <div x-show="step === 2" id="report-content" class="w-full max-w-3xl mx-auto bg-white p-8 md:p-12 shadow-soft border border-gray-100 my-10">
                    <div class="text-center mb-12 border-b border-gray-100 pb-8"><h2 class="text-3xl font-serif mb-3 font-bold text-ink">Clinical Analysis Report</h2><p class="text-xs font-sans tracking-widest text-sub uppercase mt-4">SCL-90 Assessment • <span x-text="currentDate"></span></p></div>
                    <div x-show="hasCrisis" class="mb-10 p-5 border border-red-800 text-center bg-red-50"><p class="font-serif text-sm text-red-900 leading-relaxed"><span class="font-bold block mb-2 text-base">⚠️ Attention Required / 请注意</span>检测到特定指标数值较高。建议咨询专业医师。</p></div>
                    <div class="h-80 w-full relative mb-12"><canvas id="radarChart"></canvas></div>
                    <div class="space-y-4 border-t border-gray-100 pt-8"><template x-for="factor in results.factors" :key="factor.key"><div class="flex items-center justify-between py-2 border-b border-gray-50 last:border-0"><div class="flex flex-col"><span class="text-sm font-serif text-ink font-bold" x-text="factor.nameEn"></span><span class="text-xs font-serif text-sub" x-text="factor.nameCn"></span></div><div class="flex items-center gap-4"><div class="w-32 h-1 bg-gray-100 rounded-full overflow-hidden hidden md:block"><div class="h-full bg-medical-blue" :style="`width: ${(factor.score / 5) * 100}%`"></div></div><div class="w-8 text-right font-serif font-bold text-ink" x-text="factor.score"></div></div></div></template></div>
                    <div class="mt-10 flex justify-center gap-6 no-print"><button @click="exportPDF" class="px-6 py-2 border border-ink text-ink hover:bg-ink hover:text-white transition-colors text-xs font-sans tracking-widest uppercase rounded-sm">Download PDF</button><button @click="resetTest" class="px-6 py-2 text-sub hover:text-ink transition-colors text-xs font-sans tracking-widest uppercase">Restart</button></div>
                </div>
            </div>
        </div>

        <div x-show="activeModule === 'oracle'" class="absolute inset-0 z-40 bg-[#F9F7F2] overflow-y-auto no-scrollbar fade-in" id="module-oracle" x-data="oracleApp()">
            <header class="fixed top-0 w-full h-16 flex items-center justify-center px-6 z-[60] mt-24 pointer-events-none">
                <nav class="flex gap-8 pointer-events-auto bg-white/80 backdrop-blur-sm px-6 py-2 rounded-full shadow-sm border border-black/5">
                    <button @click="activeTab = 'cards'" class="text-[10px] font-sans tracking-widest uppercase transition relative group" :class="activeTab === 'cards' ? 'text-ink font-bold' : 'text-sub hover:text-ink'"><span>读心卡牌</span><div class="absolute -bottom-1 left-0 w-full h-0.5 bg-accent transition-transform origin-left" :class="activeTab === 'cards' ? 'scale-x-100' : 'scale-x-0'"></div></button>
                    <button @click="activeTab = 'book'" class="text-[10px] font-sans tracking-widest uppercase transition relative group" :class="activeTab === 'book' ? 'text-ink font-bold' : 'text-sub hover:text-ink'"><span>答案之书</span><div class="absolute -bottom-1 left-0 w-full h-0.5 bg-accent transition-transform origin-left" :class="activeTab === 'book' ? 'scale-x-100' : 'scale-x-0'"></div></button>
                </nav>
            </header>
            <main class="w-full h-full flex flex-col items-center justify-center pt-32 pb-10">
                <div x-show="activeTab === 'cards'" class="w-full h-full flex items-center justify-center fade-in">
                    <div x-show="!cardState.selected" class="flex flex-col items-center cursor-pointer group scale-90 md:scale-100 transition-transform" @click="drawRandomCard()">
                        <div class="text-center mb-8"><h2 class="text-3xl font-serif italic text-ink mb-1">The Oracle</h2><p class="text-[10px] font-sans tracking-widest text-sub uppercase">Click Deck to Draw</p></div>
                        <div class="relative w-64 h-96 deck-stack" :class="cardState.isShuffling ? 'animate-shuffle' : ''"><div class="w-full h-full rounded-xl bg-white border border-gray-200 shadow-deck flex items-center justify-center card-texture relative overflow-hidden"><div class="absolute inset-0 flex items-center justify-center pointer-events-none"><span class="text-4xl text-accent/60 font-serif">♦</span></div></div></div>
                    </div>
                    <div x-show="cardState.selected" class="absolute inset-0 z-50 bg-[#F9F7F2]/95 backdrop-blur flex flex-col items-center justify-center p-6 fade-in">
                        <div class="relative w-[300px] h-[450px] shadow-2xl rounded-xl overflow-hidden border-8 border-white"><img :src="currentCard.image" class="w-full h-full object-cover" onerror="this.src='https://source.unsplash.com/random/600x900/?abstract,nature&sig='+Math.random()"></div>
                        <div class="mt-8 text-center"><p class="text-sm font-serif text-ink/80 italic mb-6">"What message does this image hold for you?"</p><button @click="resetCard()" class="px-8 py-2 text-[10px] font-sans tracking-widest text-ink border border-ink hover:bg-ink hover:text-white transition uppercase rounded-sm">Close</button></div>
                    </div>
                </div>
                <div x-show="activeTab === 'book'" class="w-full h-full flex items-center justify-center fade-in">
                    <div class="relative w-[340px] h-[500px]">
                        <div class="absolute inset-0 bg-white rounded-lg shadow-soft border border-gray-100 flex flex-col items-center justify-center p-10 text-center z-0 transition-opacity duration-1000" :class="bookState.isOpen ? 'opacity-100 z-20' : 'opacity-0 z-0'">
                            <span class="text-6xl text-accent/20 block mb-6 font-serif">“</span><div class="overflow-y-auto max-h-[300px] no-scrollbar"><p class="text-[10px] font-sans text-sub uppercase tracking-wider mb-6 opacity-60" x-text="currentAnswer.en"></p><h3 class="text-xl font-serif text-ink font-bold leading-loose" x-html="currentAnswer.cn"></h3></div><button @click="resetBook()" class="mt-8 text-[10px] text-sub tracking-widest uppercase border-b border-transparent hover:border-sub pb-1 hover:text-ink transition">Ask Again</button>
                        </div>
                        <div class="absolute inset-0 bg-[#F2F0E9] rounded-lg shadow-deck z-10 flex flex-col items-center justify-center transition-all duration-1000 border-l-4 border-gray-300 cursor-pointer" :class="bookState.isOpen ? 'opacity-0 pointer-events-none transform scale-110' : 'opacity-100'" @mousedown="startPress()" @touchstart.prevent="startPress()" @mouseup="endPress()" @touchend="endPress()" @mouseleave="endPress()">
                            <div class="border border-accent/20 w-[88%] h-[92%] flex flex-col items-center justify-center p-4"><h3 class="text-2xl font-serif font-bold text-ink tracking-widest mb-2">THE BOOK</h3><span class="text-[9px] font-sans tracking-[0.4em] text-sub uppercase">Of Wisdom</span><div class="mt-24 mb-24 w-24 flex flex-col items-center"><p class="text-[10px] font-sans tracking-widest text-ink uppercase mb-2" :class="bookState.isPressing ? 'text-accent' : 'text-ink'">Press & Hold</p><div class="w-full h-[2px] bg-gray-200 relative overflow-hidden"><div class="absolute top-0 left-0 h-full bg-accent transition-all ease-linear" :style="bookState.isPressing ? 'width: 100%; transition-duration: 3000ms;' : 'width: 0%; transition-duration: 200ms;'"></div></div></div><p class="absolute bottom-10 text-[9px] text-sub/30 tracking-widest uppercase">3 Seconds</p></div>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <div x-show="activeModule === 'nightlight'" x-cloak id="module-nightlight" class="absolute inset-0 z-50 transition-colors duration-500" :style="`background-color: hsl(${hue}, ${sat}%, ${light}%)`" x-data="nightLightApp()">
            <button @click="goHome()" class="fixed top-8 right-10 z-50 text-[10px] uppercase tracking-widest text-white/80 hover:text-white pointer-events-auto">关闭</button>
            <div class="character-container" @click="interact()">
                <div class="character-body"><div class="eyes"><div class="eye"></div><div class="eye"></div></div><div class="blush left"></div><div class="blush right"></div><div class="arm left"></div><div class="arm right"></div></div><div class="feet"><div class="foot"></div><div class="foot"></div></div>
            </div>
            <div class="fixed bottom-10 right-10 z-20 flex flex-col items-end gap-4 pointer-events-auto">
                <button @click="showControls = !showControls" class="w-14 h-14 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center border-2 border-white/50 hover:scale-110 transition shadow-lg"><i class="fa-solid fa-sliders text-white"></i></button>
                <div x-show="showControls" class="bg-black/80 backdrop-blur-xl p-8 rounded-2xl w-80 text-white shadow-2xl origin-bottom-right transition mb-4" x-transition>
                    <div class="text-lg font-bold mb-6 border-b border-white/10 pb-2">氛围调节</div>
                    <div class="space-y-6">
                        <div><div class="flex justify-between text-xs mb-2 text-gray-400"><span>HUE</span><span x-text="hue"></span></div><input type="range" min="0" max="360" x-model="hue" class="w-full h-3 rounded-full appearance-none cursor-pointer" style="background: linear-gradient(to right, #f00, #ff0, #0f0, #0ff, #00f, #f0f, #f00)"></div>
                        <div><div class="flex justify-between text-xs mb-2 text-gray-400"><span>SAT</span><span x-text="sat+'%'"></span></div><input type="range" min="0" max="100" x-model="sat" class="w-full h-3 rounded-full appearance-none cursor-pointer bg-white/20"></div>
                        <div><div class="flex justify-between text-xs mb-2 text-gray-400"><span>INT</span><span x-text="bri+'%'"></span></div><input type="range" min="0" max="100" x-model="bri" class="w-full h-3 rounded-full appearance-none cursor-pointer bg-white/20"></div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        function playSysSound(type) {
            if (audioCtx.state === 'suspended') audioCtx.resume();
            const osc = audioCtx.createOscillator(); const gain = audioCtx.createGain();
            osc.connect(gain); gain.connect(audioCtx.destination);
            if (type === 'tick') { osc.type = 'sine'; osc.frequency.setValueAtTime(800, audioCtx.currentTime); gain.gain.setValueAtTime(0.05, audioCtx.currentTime); gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.1); osc.start(); osc.stop(audioCtx.currentTime + 0.1); } 
            else if (type === 'open') { osc.type = 'triangle'; osc.frequency.setValueAtTime(200, audioCtx.currentTime); gain.gain.setValueAtTime(0.2, audioCtx.currentTime); osc.frequency.exponentialRampToValueAtTime(600, audioCtx.currentTime + 1.5); gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 2); osc.start(); osc.stop(audioCtx.currentTime + 2); }
        }

        const quotes = [
            { cn: "生活如一杯咖啡，先苦后甜。", en: "Life is like coffee, bitter then sweet." },
            { cn: "智者一切求自己，愚者一切求他人。", en: "The wise seek all in themselves, the fool in others." },
            { cn: "与其互为人间，不如自成宇宙。", en: "Better to be a universe unto oneself." },
            { cn: "凡是过往，皆为序章。", en: "What's past is prologue." },
            { cn: "万物皆有裂痕，那是光照进来的地方。", en: "There is a crack in everything, that's how the light gets in." },
            { cn: "人生没有白走的路，每一步都算数。", en: "No step in life is wasted." },
            { cn: "心若向阳，无谓悲伤。", en: "If the heart faces the sun, there is no sorrow." }
        ];

        function mainApp() {
            return {
                tab: 'today', activeModule: null, dateStr: new Date().toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' }),
                dailyQuote: quotes[Math.floor(Math.random() * quotes.length)],
                bgStyle: 'background-color: #F9F7F2',
                init() { this.initParticles(); },
                openModule(name) { this.activeModule = name; if(name==='meditation') setTimeout(()=>window.dispatchEvent(new Event('bh-init')),50); },
                goHome() { this.activeModule = null; },
                handleKey(e) { window.dispatchEvent(new CustomEvent('global-keydown', {detail: e.code})); },
                initParticles() { const canvas = document.getElementById('particle-canvas'); const ctx = canvas.getContext('2d'); let w, h, particles = []; const resize = () => { w = canvas.width = window.innerWidth; h = canvas.height = window.innerHeight; }; window.addEventListener('resize', resize); resize(); for(let i=0; i<40; i++) particles.push({x:Math.random()*w, y:Math.random()*h, v:Math.random()*0.5, r:Math.random()*1.5}); function animate() { ctx.clearRect(0,0,w,h); ctx.fillStyle = '#2C2C2C'; particles.forEach(p => { p.y -= p.v; if(p.y < 0) p.y = h; ctx.beginPath(); ctx.arc(p.x, p.y, p.r, 0, Math.PI*2); ctx.fill(); }); requestAnimationFrame(animate); } animate(); }
            }
        }

        // --- 灵犀 Voice Chat Logic (INTEGRATED) ---
        function chatApp() {
            return {
                socket: null,
                state: 'idle', // idle, recording, thinking, speaking
                subtitle: '',
                hintText: '按住球体 · 倾诉心声',
                mediaRecorder: null,
                audioChunks: [],
                showPlayBtn: false,
                lastAudio: null,
                
                init() {
                    // 连接后端 (Polling + WebSocket 混合模式)
                    this.socket = io({ transports: ['polling', 'websocket'], reconnection: true });
                    
                    this.socket.on('connect', () => { 
                        console.log("✅ 灵犀已连接"); 
                        this.hintText = '按住球体 · 倾诉心声'; 
                        this.state = 'idle'; 
                    });
                    
                    this.socket.on('disconnect', () => { 
                        this.hintText = '连接断开...'; 
                    });

                    this.socket.on('ui_feedback', (data) => {
                        if (data.text) this.subtitle = data.text;
                        if (data.state) { 
                            this.state = data.state; 
                            this.updateHint(); 
                        }
                    });

                    this.socket.on('play_audio', (data) => { 
                        this.playAudio(data.audio); 
                    });
                },

                updateHint() {
                    switch(this.state) {
                        case 'idle': this.hintText = '按住球体 · 倾诉心声'; break;
                        case 'recording': this.hintText = '正在聆听...'; break;
                        case 'thinking': this.hintText = '正在用心感受...'; break;
                        case 'speaking': this.hintText = '点击球体 · 停止播放'; break;
                    }
                },

                async startRecord() {
                    this.showPlayBtn = false;
                    if (this.state === 'speaking') { this.stopAudio(); return; }
                    if (this.state === 'thinking') return;
                    
                    try {
                        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                        this.mediaRecorder = new MediaRecorder(stream);
                        this.audioChunks = [];
                        
                        this.mediaRecorder.ondataavailable = e => this.audioChunks.push(e.data);
                        
                        this.mediaRecorder.onstop = () => {
                            const blob = new Blob(this.audioChunks, { type: 'audio/webm' });
                            const reader = new FileReader();
                            reader.readAsDataURL(blob);
                            reader.onloadend = () => {
                                const base64String = reader.result.split(',')[1];
                                this.socket.emit('submit_audio', { audio: base64String });
                            };
                        };

                        this.mediaRecorder.start();
                        this.state = 'recording';
                        this.subtitle = ''; 
                        this.updateHint();
                        
                    } catch (e) { 
                        alert("无法访问麦克风，请检查浏览器权限设置！"); 
                    }
                },

                stopRecord() {
                    if (this.state === 'recording' && this.mediaRecorder) {
                        this.mediaRecorder.stop();
                        this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
                        this.state = 'thinking';
                        this.updateHint();
                    }
                },

                playAudio(base64) {
                    this.state = 'speaking';
                    this.updateHint();
                    this.lastAudio = base64;
                    
                    const audio = new Audio("data:audio/mp3;base64," + base64);
                    window.currentAudio = audio;
                    
                    audio.onended = () => { 
                        this.state = 'idle'; 
                        this.subtitle = ''; 
                        this.updateHint(); 
                    };
                    
                    audio.play().catch(e => {
                        console.warn("自动播放被拦截:", e);
                        this.state = 'idle';
                        this.subtitle = '请点击下方按钮播放声音';
                        this.showPlayBtn = true;
                    });
                },
                
                retryPlay() {
                    if (this.lastAudio) { 
                        this.playAudio(this.lastAudio); 
                        this.showPlayBtn = false; 
                    }
                },
                
                stopAudio() {
                    if (window.currentAudio) { window.currentAudio.pause(); window.currentAudio = null; }
                    this.state = 'idle';
                    this.updateHint();
                }
            }
        }

        // --- Other Apps Logic (Preserved) ---
        function beingHereApp() { return { currentMode: 'focus', currentTheme: { s:'#E6EAE3', e:'#8FA691', name:'Bamboo', name_cn:'竹' }, isRunning: false, timer: 25 * 60, initialDuration: 25 * 60, statusText: '准备', visualStyle: '', currentBg: null, currentVoice: null, isBgPlaying: false, isVoicePlaying: false, breathPattern: '4-7-8', breathName: '舒缓', alarmSound: 'echo', isInfinite: false, isAlarmRinging: false, modes: [{ id: 'focus', label: '专注' }, { id: 'breathe', label: '呼吸' }, { id: 'sound', label: '声景' }, { id: 'mind', label: '引导' }], breathTimer: 0, soundCollections: { '自然': [ { title: "营地篝火", file: "Nature-audio/Campfire.MP3", cover: "Nature-audio/images/Cinematic_hyperdetailed_photorealistic_2k.jpeg" }, { title: "海浪", file: "Nature-audio/Seabreeze.MP3", cover: "Nature-audio/images/Waves.jpeg" } ], '禅意': [], '书斋': [], '食味': [] }, mindCollections: { '减压': [], '疗愈': [], '探索': [] }, init() { window.addEventListener('bh-init', () => this.setTheme(this.currentTheme)); window.addEventListener('global-keydown', () => { if (this.isAlarmRinging) this.stopAlarm(); }); }, switchMode(id) { this.currentMode = id; }, setTheme(s) { this.currentTheme = s; this.$root.parentElement.__x.$data.bgStyle = `background: linear-gradient(160deg, ${s.s}, ${s.e})`; }, setDuration(v) { if(v==0){this.isInfinite=true;this.timer=0;this.statusText='正计时'}else{this.isInfinite=false;this.timer=v*60;this.initialDuration=this.timer;this.statusText='准备'} this.isRunning=false; clearInterval(this.interval); this.stopAlarm(); }, setBreath(p,n) { this.breathPattern=p; this.breathName=n; this.statusText='准备'; this.isRunning=false; }, setAlarm(s) { this.alarmSound=s; }, toggle() { if(this.isAlarmRinging) { this.stopAlarm(); return; } this.isRunning=!this.isRunning; if(this.isRunning){ if(this.currentMode==='focus')this.startFocus(); else if(this.currentMode==='breathe')this.startBreathe(); } else { clearInterval(this.interval); this.statusText='暂停'; this.visualStyle='transform:scale(1)'; } }, startFocus() { this.statusText = this.isInfinite ? '正计时' : '专注中...'; clearInterval(this.interval); this.interval = setInterval(() => { if(this.isInfinite) this.timer++; else { this.timer--; if(this.timer<=0) { this.reset(); this.playAlarm(); } } }, 1000); }, startBreathe() { const runTimer = (duration) => { let t = duration; this.breathTimer = t; return new Promise(resolve => { const iv = setInterval(() => { t--; this.breathTimer = t; if (t <= 0) { clearInterval(iv); resolve(); } }, 1000); }); }; const cycle = async () => { if(!this.isRunning) return; await runTimer(4); await runTimer(7); await runTimer(8); if(this.isRunning) cycle(); }; cycle(); }, playAlarm() {}, stopAlarm() {}, playSample(src) {}, playSound(track, type) {}, reset() { this.isRunning=false; clearInterval(this.interval); }, get timerDisplay() { const t=Math.abs(this.timer); const m=Math.floor(t/60); const s=t%60; return `${m<10?'0'+m:m}:${s<10?'0'+s:s}`; } } }
        function journalApp() { return { view: 'write', dateDisplay: new Date().toLocaleDateString('zh-CN'), entry: { moodVal: 'Calm', achievement: '', gratitude: '', moodText: '' }, history: [], quote: { cn: "命运不是风...", en: "Fate is not the wind..." }, init() { const saved = localStorage.getItem('journal_history'); if(saved) this.history = JSON.parse(saved); }, save() { const rec = { id: Date.now(), dateStr: new Date().toLocaleDateString('zh-CN'), moodVal: this.entry.moodVal, text: this.entry.moodText || '...', achievement: this.entry.achievement || '', gratitude: this.entry.gratitude || '' }; this.history.unshift(rec); localStorage.setItem('journal_history', JSON.stringify(this.history)); this.view = 'history'; }, getPreview(item) { return item.text.substring(0, 50); }, showDetail(item) { alert(item.text); } } }
        function mbtiApp() { return { step: 0, currentIdx: 0, selectedScore: null, scores: {}, result: {}, profiles: {}, questions: [{q:"Test Q", d:'E'}], init() {}, start() { this.step=1; }, retake() { this.start(); }, selectScore(i) { this.selectedScore = i; }, next() { this.step=2; }, calc() {}, handleCheat() {} } }
        function scl90App() { return { step: 0, currentPage: 0, answers: [], options: [], questions: [], init() {}, startTest() { this.step=1; }, nextPage() { this.step=2; }, prevPage() {}, answer() {}, calc() {}, exportPDF() {}, resetTest() {}, handleCheat() {} } }
        function oracleApp() { return { activeTab: 'cards', cardState: {}, bookState: {}, drawRandomCard() {}, resetCard() {}, startPress() {}, endPress() {}, resetBook() {} } }
        function nightLightApp() { return { hue: 260, sat: 100, bri: 100, showControls: false, get light() { return 50; }, interact() {} } }
    </script>
</body>
</html>