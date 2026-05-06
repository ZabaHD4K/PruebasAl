/* ============================================================
   SPACE INVADERS — Neon Arcade Edition
   Social Credit Management Extension — BC ControlAddin
   ============================================================ */
(function () {
    'use strict';

    // ── Canvas & container ──────────────────────────────────────
    var W = 800, H = 600;
    var root = document.getElementById('controlAddIn') || document.body;
    root.style.cssText = 'background:#000014;margin:0;padding:0;overflow:hidden;' +
        'display:flex;flex-direction:column;align-items:center;justify-content:center;' +
        'height:100%;width:100%;user-select:none;';

    var canvas = document.createElement('canvas');
    canvas.width = W; canvas.height = H;
    canvas.style.cssText = 'display:block;max-width:100%;max-height:100%;' +
        'border:2px solid #0ff;' +
        'box-shadow:0 0 18px #0ff,0 0 40px #0088ff,inset 0 0 60px rgba(0,0,0,0.8);';
    root.appendChild(canvas);
    var ctx = canvas.getContext('2d');

    // ── Audio ────────────────────────────────────────────────────
    var ac = null;
    function audio() {
        if (!ac) ac = new (window.AudioContext || window.webkitAudioContext)();
        return ac;
    }
    function tone(f, type, dur, vol, slide) {
        try {
            var a = audio(), o = a.createOscillator(), g = a.createGain();
            o.connect(g); g.connect(a.destination);
            o.type = type || 'square';
            o.frequency.setValueAtTime(f, a.currentTime);
            if (slide) o.frequency.exponentialRampToValueAtTime(slide, a.currentTime + dur);
            g.gain.setValueAtTime(vol || 0.25, a.currentTime);
            g.gain.exponentialRampToValueAtTime(0.001, a.currentTime + dur);
            o.start(); o.stop(a.currentTime + dur);
        } catch (e) {}
    }
    function noise(dur, vol) {
        try {
            var a = audio(), size = a.sampleRate * dur;
            var buf = a.createBuffer(1, size, a.sampleRate);
            var d = buf.getChannelData(0);
            for (var i = 0; i < size; i++) d[i] = Math.random() * 2 - 1;
            var src = a.createBufferSource(), g = a.createGain();
            var flt = a.createBiquadFilter();
            flt.type = 'lowpass'; flt.frequency.value = 1200;
            src.buffer = buf; src.connect(flt); flt.connect(g); g.connect(a.destination);
            g.gain.setValueAtTime(vol || 0.3, a.currentTime);
            g.gain.exponentialRampToValueAtTime(0.001, a.currentTime + dur);
            src.start(); src.stop(a.currentTime + dur);
        } catch (e) {}
    }
    var SFX = {
        shoot:    function () { tone(900, 'square', 0.08, 0.18, 300); },
        hit:      function () { noise(0.12, 0.35); tone(120, 'sawtooth', 0.18, 0.25, 60); },
        explode:  function () { noise(0.25, 0.5); tone(80, 'sawtooth', 0.3, 0.3, 40); },
        die:      function () { noise(0.5, 0.6); tone(440, 'sawtooth', 0.6, 0.4, 55); },
        powerup:  function () { tone(660, 'sine', 0.05, 0.2); setTimeout(function(){tone(880,'sine',0.05,0.2);},60); setTimeout(function(){tone(1320,'sine',0.1,0.2);},120); },
        ufo:      function () { for (var i=0;i<4;i++) (function(j){setTimeout(function(){tone(200+j*80,'sine',0.12,0.15);},j*120);})(i); },
        levelup:  function () { [440,550,660,880].forEach(function(f,i){setTimeout(function(){tone(f,'sine',0.12,0.25);},i*110);}); },
        march:    function (idx) { var notes=[160,130,110,130]; tone(notes[idx%4],'square',0.06,0.12); }
    };

    // ── Sprite definitions (10 × 8, 'X'=pixel, ' '=empty) ──────
    //    Displayed at SCALE px per logical pixel
    var SCALE = 3;
    var SP_W = 10, SP_H = 8;   // logical size
    var CELL_W = SP_W * SCALE + 16, CELL_H = SP_H * SCALE + 16;  // cell inc. padding

    var SPRITES = {
        squid: [
            ['...XX.....',
             '..XXXX....',
             '.XXXXXX...',
             'XX.XX.XX..',
             'XXXXXXXXXX',
             '.XX..XX...',
             'X..XX..X..',
             '.X.XX.X...'],
            ['...XX.....',
             '..XXXX....',
             '.XXXXXX...',
             'XX.XX.XX..',
             'XXXXXXXXXX',
             '..XXXX....',
             '.X....X...',
             'X......X..']
        ],
        crab: [
            ['X....X....',
             '.X..X.....',
             'XXXXXXXXXX',
             'XX.XX.XXXX',
             'XXXXXXXXXX',
             '.XXXXXXXX.',
             'X.X....X.X',
             '..X....X..'],
            ['X....X....',
             'XX..XX....',
             'XXXXXXXXXX',
             'XXX.XX.XXX',
             'XXXXXXXXXX',
             '..XXXXXX..',
             '.X.X..X.X.',
             'X.......X.']
        ],
        octopus: [
            ['..XXXXXX..',
             '.XXXXXXXX.',
             'XXXXXXXXXX',
             'X.XXXXXX.X',
             'XXXXXXXXXX',
             '..XX..XX..',
             '.X.X..X.X.',
             'X.......X.'],
            ['..XXXXXX..',
             '.XXXXXXXX.',
             'XXXXXXXXXX',
             'X.XXXXXX.X',
             'XXXXXXXXXX',
             '.XXX..XXX.',
             'X..X..X..X',
             '.X......X.']
        ]
    };

    // Prerender alien sprites to offscreen canvases for performance
    var spriteCache = {};
    function buildSpriteCache() {
        var types = [
            { name:'squid',   color:'#ff44ff', glow:'#ff00ff' },
            { name:'squid',   color:'#ff44ff', glow:'#ff00ff' },
            { name:'crab',    color:'#44ddff', glow:'#00ccff' },
            { name:'crab',    color:'#44ddff', glow:'#00ccff' },
            { name:'octopus', color:'#44ffaa', glow:'#00ff88' }
        ];
        types.forEach(function (t, row) {
            for (var f = 0; f < 2; f++) {
                var key = t.name + '_' + f + '_flash0';
                if (spriteCache[key]) return;
                var frames = SPRITES[t.name];
                [false, true].forEach(function (flash) {
                    var k = t.name + '_r' + row + '_' + f + '_fl' + (flash?1:0);
                    var oc = document.createElement('canvas');
                    oc.width = SP_W * SCALE; oc.height = SP_H * SCALE;
                    var oc2 = oc.getContext('2d');
                    oc2.shadowBlur = flash ? 18 : 10;
                    oc2.shadowColor = flash ? '#ffffff' : t.glow;
                    oc2.fillStyle = flash ? '#ffffff' : t.color;
                    frames[f].forEach(function (row_s, ry) {
                        for (var cx = 0; cx < row_s.length; cx++) {
                            if (row_s[cx] === 'X')
                                oc2.fillRect(cx * SCALE, ry * SCALE, SCALE, SCALE);
                        }
                    });
                    spriteCache[k] = oc;
                });
            }
        });
    }

    // ── Stars ────────────────────────────────────────────────────
    var STARS = (function () {
        var s = [];
        for (var i = 0; i < 200; i++)
            s.push({ x: Math.random()*W, y: Math.random()*H,
                     size: Math.random()*1.8+0.3,
                     speed: Math.random()*0.4+0.05,
                     bright: Math.random() });
        return s;
    })();

    // ── Game state ───────────────────────────────────────────────
    var G, keys = {};

    function initGame(keepHi) {
        var hi = keepHi && G ? G.hiScore : 0;
        G = {
            state: 'title',    // title | playing | paused | dead | levelup | gameover
            score: 0,
            hiScore: hi,
            lives: 3,
            level: 1,

            // Player
            px: W / 2 - 22,   // ship x (ship is 44px wide)
            py: H - 56,
            pvx: 0,
            invincible: 0,     // frames of invincibility
            shieldTimer: 0,    // power-up shield duration

            // Bullets
            pbullets: [],      // player bullets
            abullets: [],      // alien bullets

            // Aliens
            aliens: [],
            dir: 1,            // 1=right, -1=left
            step: 1.2,         // horizontal step per march
            marchTimer: 0,
            marchInterval: 720,
            marchIdx: 0,

            // UFO
            ufo: null,
            ufoTimer: 0,

            // Shields
            shields: [],

            // Power-ups
            drops: [],
            rapidFire: 0,      // frames left
            multiShot: 0,      // frames left

            // Particles
            particles: [],
            scorePopups: [],

            // Timers
            shootCD: 0,
            alienShootTimer: 0,
            frame: 0,
            flashTimer: 0      // screen flash on power-up
        };
        spawnAliens();
        buildShields();
    }

    // ── Alien grid ───────────────────────────────────────────────
    var ROW_TYPES = [
        { shape:'squid',   color:'#ff44ff', glow:'#ff00ff', pts:40 },
        { shape:'crab',    color:'#44ddff', glow:'#00ccff', pts:20 },
        { shape:'crab',    color:'#44ddff', glow:'#00ccff', pts:20 },
        { shape:'octopus', color:'#44ffaa', glow:'#00ff88', pts:10 },
        { shape:'octopus', color:'#44ffaa', glow:'#00ff88', pts:10 }
    ];
    var COLS = 11, ROWS = 5;

    function spawnAliens() {
        G.aliens = [];
        var ofx = (W - COLS * CELL_W + 16) / 2;
        var ofy = 52 + Math.min((G.level - 1) * 6, 60);
        for (var r = 0; r < ROWS; r++) {
            for (var c = 0; c < COLS; c++) {
                G.aliens.push({
                    r: r, c: c,
                    x: ofx + c * CELL_W,
                    y: ofy + r * CELL_H,
                    alive: true,
                    type: ROW_TYPES[r],
                    anim: (r + c) % 2,
                    flash: 0
                });
            }
        }
        recalcMarch();
    }

    function recalcMarch() {
        var alive = G.aliens.filter(function (a) { return a.alive; }).length;
        G.marchInterval = Math.max(60, Math.floor(720 * alive / (COLS * ROWS)));
    }

    function liveAliens() { return G.aliens.filter(function(a){return a.alive;}); }

    // ── Shields ──────────────────────────────────────────────────
    function buildShields() {
        G.shields = [];
        var count = 4, sw = 66, sh = 42;
        var gap = (W - count * sw) / (count + 1);
        for (var i = 0; i < count; i++) {
            var sx = gap + i * (sw + gap);
            var sy = H - 140;
            var blocks = [];
            // Bunker shape: 7 cols × 4 rows with arched top and notch at bottom
            var shape = [
                [0,1,1,1,1,1,0],
                [1,1,1,1,1,1,1],
                [1,1,1,1,1,1,1],
                [1,1,0,0,0,1,1]
            ];
            for (var by = 0; by < shape.length; by++) {
                for (var bx = 0; bx < shape[by].length; bx++) {
                    if (shape[by][bx]) {
                        blocks.push({
                            x: sx + bx * 10,
                            y: sy + by * 10,
                            hp: 4   // 4 hit points, changes color
                        });
                    }
                }
            }
            G.shields.push({ blocks: blocks });
        }
    }

    // ── Shooting ─────────────────────────────────────────────────
    function playerShoot() {
        if (G.shootCD > 0) return;
        var maxB = G.rapidFire > 0 ? 5 : 2;
        if (G.pbullets.length >= maxB) return;
        SFX.shoot();
        G.shootCD = G.rapidFire > 0 ? 7 : 18;
        var bx = G.px + 22, by = G.py - 2;
        if (G.multiShot > 0) {
            G.pbullets.push({ x: bx - 14, y: by, vx: -1.5, vy: -9.5 });
            G.pbullets.push({ x: bx,      y: by, vx:  0,   vy: -11 });
            G.pbullets.push({ x: bx + 14, y: by, vx:  1.5, vy: -9.5 });
        } else {
            G.pbullets.push({ x: bx, y: by, vx: 0, vy: -11 });
        }
    }

    function alienShoot() {
        var alive = liveAliens();
        if (!alive.length) return;
        // Pick a random front-line alien (lowest in its column)
        var front = {};
        alive.forEach(function (a) {
            if (!front[a.c] || a.r > front[a.c].r) front[a.c] = a;
        });
        var pool = Object.values ? Object.values(front) :
            Object.keys(front).map(function(k){return front[k];});
        var shooter = pool[Math.floor(Math.random() * pool.length)];
        var zigzag = Math.random() > 0.65;
        G.abullets.push({
            x: shooter.x + (SP_W * SCALE) / 2,
            y: shooter.y + SP_H * SCALE,
            vx: (Math.random() - 0.5) * 1.2,
            vy: 3.5 + G.level * 0.4,
            type: zigzag ? 'zz' : 'bolt',
            phase: 0
        });
    }

    // ── Particles ────────────────────────────────────────────────
    function explode(x, y, color, n) {
        n = n || 22;
        for (var i = 0; i < n; i++) {
            var a = Math.PI * 2 * i / n + (Math.random() - 0.5) * 0.8;
            var spd = 1.2 + Math.random() * 3.5;
            G.particles.push({
                x: x, y: y,
                vx: Math.cos(a) * spd,
                vy: Math.sin(a) * spd - 0.5,
                life: 1,
                decay: 0.018 + Math.random() * 0.025,
                size: 2 + Math.random() * 3,
                color: color
            });
        }
    }

    function scorePopup(x, y, pts, color) {
        G.scorePopups.push({ x: x, y: y, vy: -1.2, life: 1.5, text: '+' + pts, color: color });
    }

    // ── Power-up drops ───────────────────────────────────────────
    var POWERUPS = [
        { id: 'rapid',  label: '⚡ RAPID FIRE',   color: '#ffff00', chance: 0.08 },
        { id: 'multi',  label: '✦ MULTI SHOT',    color: '#ff88ff', chance: 0.07 },
        { id: 'shield', label: '🛡 SHIELD',        color: '#00ffff', chance: 0.06 },
        { id: 'bomb',   label: '💣 SMART BOMB',   color: '#ff4400', chance: 0.04 },
        { id: 'life',   label: '♥ EXTRA LIFE',    color: '#ff0055', chance: 0.03 }
    ];

    function maybeDrop(x, y) {
        var roll = Math.random();
        var acc = 0;
        for (var i = 0; i < POWERUPS.length; i++) {
            acc += POWERUPS[i].chance;
            if (roll < acc) {
                G.drops.push({ x: x - 34, y: y, vy: 1.4, w: 68, h: 22,
                               type: POWERUPS[i], glow: 0 });
                return;
            }
        }
    }

    function applyDrop(d) {
        SFX.powerup();
        explode(d.x + 34, d.y + 11, d.type.color, 30);
        G.flashTimer = 6;
        switch (d.type.id) {
            case 'rapid':  G.rapidFire = 360; break;
            case 'multi':  G.multiShot = 360; break;
            case 'shield': G.shieldTimer = 480; break;
            case 'bomb':
                // Destroy the entire bottom-most surviving row
                var maxR = -1;
                liveAliens().forEach(function(a){ if(a.r>maxR) maxR=a.r; });
                G.aliens.forEach(function(a) {
                    if (a.alive && a.r === maxR) {
                        a.alive = false;
                        G.score += a.type.pts;
                        explode(a.x + SP_W*SCALE/2, a.y + SP_H*SCALE/2, a.type.color, 18);
                    }
                });
                recalcMarch();
                break;
            case 'life': G.lives = Math.min(5, G.lives + 1); break;
        }
    }

    // ── Collision helper ─────────────────────────────────────────
    function hit(ax, ay, aw, ah, bx, by, bw, bh) {
        return ax < bx+bw && ax+aw > bx && ay < by+bh && ay+ah > by;
    }

    // ── Player hit ───────────────────────────────────────────────
    function playerHit() {
        if (G.shieldTimer > 0) {
            G.shieldTimer = 0;
            explode(G.px + 22, G.py + 12, '#00ffff', 20);
            return;
        }
        if (G.invincible > 0) return;
        SFX.die();
        explode(G.px + 22, G.py + 12, '#00ff88', 50);
        G.lives--;
        G.invincible = 140;
        G.px = W / 2 - 22;
        if (G.lives <= 0) {
            G.state = 'gameover';
        } else {
            G.state = 'dead';
            setTimeout(function () { if (G.state === 'dead') G.state = 'playing'; }, 900);
        }
    }

    // ── Main update ──────────────────────────────────────────────
    function update() {
        if (G.state !== 'playing' && G.state !== 'dead') return;
        G.frame++;

        // Timers
        if (G.shootCD > 0)     G.shootCD--;
        if (G.invincible > 0)  G.invincible--;
        if (G.rapidFire > 0)   G.rapidFire--;
        if (G.multiShot > 0)   G.multiShot--;
        if (G.shieldTimer > 0) G.shieldTimer--;
        if (G.flashTimer > 0)  G.flashTimer--;

        // Stars parallax
        STARS.forEach(function (s) {
            s.y += s.speed;
            if (s.y > H) s.y = 0;
        });

        if (G.state === 'dead') { updateParticles(); return; }

        // Player movement
        var spd = 5.5;
        if (keys['ArrowLeft'] || keys['a'] || keys['A']) G.pvx = -spd;
        else if (keys['ArrowRight'] || keys['d'] || keys['D']) G.pvx = spd;
        else G.pvx = 0;
        G.px += G.pvx;
        G.px = Math.max(0, Math.min(W - 44, G.px));

        // Player shoot
        if (keys[' '] || keys['ArrowUp'] || keys['z'] || keys['Z'] || keys['x'] || keys['X'])
            playerShoot();

        // Player bullets
        G.pbullets = G.pbullets.filter(function (b) {
            b.x += b.vx; b.y += b.vy;
            if (b.y < -14) return false;

            // vs aliens
            var killed = false;
            G.aliens.forEach(function (a) {
                if (!a.alive || killed) return;
                if (hit(b.x - 2, b.y, 4, 10, a.x, a.y, SP_W*SCALE, SP_H*SCALE)) {
                    killed = true;
                    a.alive = false;
                    a.flash = 3;
                    G.score += a.type.pts * G.level;
                    if (G.score > G.hiScore) G.hiScore = G.score;
                    SFX.explode();
                    explode(a.x + SP_W*SCALE/2, a.y + SP_H*SCALE/2, a.type.color, 28);
                    scorePopup(a.x + SP_W*SCALE/2, a.y, a.type.pts * G.level, a.type.color);
                    maybeDrop(a.x + SP_W*SCALE/2, a.y + SP_H*SCALE);
                    recalcMarch();
                }
            });
            if (killed) return false;

            // vs UFO
            if (G.ufo && hit(b.x-2, b.y, 4, 10, G.ufo.x, G.ufo.y, 52, 20)) {
                var ufoPts = (Math.floor(Math.random() * 8) + 1) * 50;
                G.score += ufoPts;
                if (G.score > G.hiScore) G.hiScore = G.score;
                SFX.explode();
                explode(G.ufo.x+26, G.ufo.y+10, '#ff2200', 36);
                scorePopup(G.ufo.x+26, G.ufo.y, ufoPts, '#ff2200');
                G.ufo = null;
                return false;
            }

            // vs shields
            var shieldKill = false;
            G.shields.forEach(function (sh) {
                sh.blocks.forEach(function (bl) {
                    if (shieldKill || bl.hp <= 0) return;
                    if (hit(b.x-1, b.y, 3, 10, bl.x, bl.y, 10, 10)) {
                        bl.hp--;
                        explode(b.x, b.y, '#00cc66', 6);
                        shieldKill = true;
                    }
                });
            });
            return !shieldKill;
        });

        // Alien bullets
        G.alienBullets_update();

        // Alien march
        G.marchTimer++;
        if (G.marchTimer >= G.marchInterval) {
            G.marchTimer = 0;
            SFX.march(G.marchIdx++);
            var alive = liveAliens();
            if (!alive.length) return;

            // Animate
            alive.forEach(function(a){ a.anim ^= 1; });

            // Check wall
            var wall = false;
            alive.forEach(function(a){
                if (a.x + G.dir * G.step < 4 || a.x + SP_W*SCALE + G.dir * G.step > W - 4) wall = true;
            });
            if (wall) {
                G.dir *= -1;
                alive.forEach(function(a){ a.y += 14; });
                // Check if aliens reached player zone
                var maxY = 0;
                alive.forEach(function(a){ if(a.y+SP_H*SCALE > maxY) maxY = a.y+SP_H*SCALE; });
                if (maxY >= G.py) { G.state = 'gameover'; SFX.die(); return; }
            } else {
                alive.forEach(function(a){ a.x += G.dir * G.step; });
            }
        }

        // Alien shooting
        G.alienShootTimer++;
        var shootInterval = Math.max(30, 100 - G.level * 7);
        if (G.alienShootTimer >= shootInterval + Math.random() * 50) {
            G.alienShootTimer = 0;
            alienShoot();
        }

        // UFO
        G.ufoTimer++;
        if (!G.ufo && G.ufoTimer > 500 + Math.random() * 700) {
            G.ufoTimer = 0;
            var dir = Math.random() > 0.5 ? 1 : -1;
            G.ufo = { x: dir > 0 ? -60 : W + 60, y: 34, vx: dir * 2.8, anim: 0 };
            SFX.ufo();
        }
        if (G.ufo) {
            G.ufo.x += G.ufo.vx;
            G.ufo.anim = (G.ufo.anim + 1) % 60;
            if (G.ufo.x < -80 || G.ufo.x > W + 80) G.ufo = null;
        }

        // Shield erosion by aliens
        liveAliens().forEach(function(a) {
            G.shields.forEach(function(sh){
                sh.blocks.forEach(function(bl){
                    if(bl.hp > 0 && hit(a.x, a.y, SP_W*SCALE, SP_H*SCALE, bl.x, bl.y, 10, 10))
                        bl.hp = 0;
                });
            });
        });

        // Power-up drops
        G.drops = G.drops.filter(function(d) {
            d.y += d.vy;
            d.glow = (d.glow + 0.12) % (Math.PI * 2);
            if (hit(d.x, d.y, d.w, d.h, G.px, G.py, 44, 26)) {
                applyDrop(d);
                return false;
            }
            return d.y < H + 30;
        });

        // Particles & popups
        updateParticles();

        // Check win
        if (!liveAliens().length) {
            G.score += G.level * 200;
            G.state = 'levelup';
            SFX.levelup();
            setTimeout(function () {
                G.level++;
                spawnAliens();
                buildShields();
                G.abullets = [];
                G.pbullets = [];
                G.drops = [];
                G.state = 'playing';
            }, 2800);
        }
    }

    // Inline method on G for alien bullet update (avoids giant update fn)
    G = G || {};  // will be replaced by initGame, keep for reference
    function setupGMethods() {
        G.alienBullets_update = function () {
            G.abullets = G.abullets.filter(function (b) {
                if (b.type === 'zz') { b.phase += 0.22; b.x += Math.sin(b.phase) * 2; }
                b.x += b.vx; b.y += b.vy;

                // vs player
                if (hit(b.x-2, b.y, 4, 12, G.px, G.py, 44, 26)) {
                    playerHit();
                    return false;
                }
                // vs shields
                var dead = false;
                G.shields.forEach(function(sh){
                    sh.blocks.forEach(function(bl){
                        if (dead || bl.hp <= 0) return;
                        if (hit(b.x-2, b.y, 4, 12, bl.x, bl.y, 10, 10)) {
                            bl.hp--;
                            dead = true;
                        }
                    });
                });
                return !dead && b.y < H + 20;
            });
        };
    }

    function updateParticles() {
        G.particles = G.particles.filter(function(p){
            p.x += p.vx; p.y += p.vy; p.vy += 0.06; p.life -= p.decay;
            return p.life > 0;
        });
        G.scorePopups = G.scorePopups.filter(function(p){
            p.y += p.vy; p.life -= 0.025; return p.life > 0;
        });
    }

    // ── Rendering ────────────────────────────────────────────────

    function drawStars() {
        STARS.forEach(function(s) {
            var flicker = 0.4 + s.bright * 0.6 + Math.sin(G.frame * 0.015 + s.x * 0.1) * 0.15;
            ctx.globalAlpha = Math.max(0, Math.min(1, flicker));
            ctx.fillStyle = '#ffffff';
            ctx.fillRect(s.x, s.y, s.size, s.size);
        });
        ctx.globalAlpha = 1;
    }

    function drawAlien(a) {
        if (!a.alive) return;
        var t = a.type;
        var key = t.shape + '_r' + a.r + '_' + a.anim + '_fl' + (a.flash > 0 ? 1 : 0);
        var oc = spriteCache[key];
        if (oc) {
            ctx.drawImage(oc, a.x, a.y);
        } else {
            // Fallback: draw inline
            ctx.save();
            ctx.shadowBlur = a.flash > 0 ? 18 : 9;
            ctx.shadowColor = a.flash > 0 ? '#fff' : t.glow;
            ctx.fillStyle = a.flash > 0 ? '#fff' : t.color;
            var rows = SPRITES[t.shape][a.anim];
            rows.forEach(function(row, ry) {
                for (var cx = 0; cx < row.length; cx++) {
                    if (row[cx] === 'X')
                        ctx.fillRect(a.x + cx*SCALE, a.y + ry*SCALE, SCALE, SCALE);
                }
            });
            ctx.restore();
        }
        if (a.flash > 0) a.flash--;
    }

    function drawUFO() {
        if (!G.ufo) return;
        var u = G.ufo;
        var pulse = Math.sin(u.anim * 0.2) * 5 + 12;
        ctx.save();
        ctx.shadowBlur = pulse;
        ctx.shadowColor = '#ff0000';
        ctx.fillStyle = '#ff3333';
        // Body
        var px2 = 2;
        var shape = [
            '  XXXXXXXXXX  ',
            'XXXXXXXXXXXXXX',
            'XXX XXX XXX XX',
            ' XXXXXXXXXXXX ',
            '  XXXXXXXXXX  '
        ];
        shape.forEach(function(row, ry){
            for(var cx=0;cx<row.length;cx++){
                if(row[cx]==='X') ctx.fillRect(u.x+cx*px2, u.y+ry*px2, px2, px2);
            }
        });
        // Cockpit glow
        ctx.fillStyle = '#ff8888';
        ctx.shadowColor = '#ffaaaa';
        ctx.fillRect(u.x + 12, u.y + 2, 4, 4);
        ctx.restore();

        // Label
        ctx.save();
        ctx.shadowBlur = 8;
        ctx.shadowColor = '#ff0000';
        ctx.fillStyle = '#ff5555';
        ctx.font = 'bold 9px monospace';
        ctx.textAlign = 'center';
        ctx.fillText('???', u.x + 14, u.y - 4);
        ctx.restore();
    }

    function drawPlayer() {
        if (G.invincible > 0 && Math.floor(G.frame / 5) % 2 === 0) return;
        var x = G.px, y = G.py;
        var shielded = G.shieldTimer > 0;
        ctx.save();
        ctx.shadowBlur = shielded ? 20 : 14;
        ctx.shadowColor = shielded ? '#00ffff' : '#00ff88';
        ctx.fillStyle = shielded ? '#88ffff' : '#00ff88';

        var px2 = 2;
        var ship = [
            '         XX          ',
            '        XXXX         ',
            '       XXXXXX        ',
            ' XXXXXXXXXXXXXXXXXXX ',
            'XXXXXXXXXXXXXXXXXXXXX',
            'XXXXXXXXXXXXXXXXXXXXX',
            'XXXXXXXXXXXXXXXXXXXXX'
        ];
        ship.forEach(function(row, ry){
            for(var cx=0;cx<row.length;cx++){
                if(row[cx]==='X') ctx.fillRect(x+cx*px2, y+ry*px2, px2, px2);
            }
        });

        // Engine flame
        var flameH = 2 + Math.floor(Math.random() * 5);
        ctx.fillStyle = Math.random() > 0.5 ? '#ff8800' : '#ffcc00';
        ctx.shadowColor = '#ff8800';
        ctx.fillRect(x + 18, y + 14, 6, flameH);

        // Shield bubble
        if (shielded) {
            ctx.strokeStyle = 'rgba(0,255,255,' + (0.3 + Math.sin(G.frame*0.15)*0.2) + ')';
            ctx.lineWidth = 2;
            ctx.shadowBlur = 18;
            ctx.beginPath();
            ctx.ellipse(x + 21, y + 7, 28, 22, 0, 0, Math.PI * 2);
            ctx.stroke();
        }
        ctx.restore();
    }

    function drawBullets() {
        // Player bullets
        G.pbullets.forEach(function(b) {
            ctx.save();
            ctx.shadowBlur = 12;
            ctx.shadowColor = '#00ffff';
            ctx.fillStyle = '#00ffff';
            ctx.fillRect(b.x - 1, b.y, 3, 11);
            // Core
            ctx.fillStyle = '#ffffff';
            ctx.fillRect(b.x, b.y + 1, 1, 8);
            ctx.restore();
        });

        // Alien bullets
        G.abullets.forEach(function(b) {
            ctx.save();
            ctx.shadowBlur = 10;
            if (b.type === 'zz') {
                ctx.strokeStyle = '#ff6600';
                ctx.shadowColor = '#ff4400';
                ctx.lineWidth = 2.5;
                ctx.beginPath();
                var step = 4;
                for (var i = 0; i < 14; i += step) {
                    var wx = b.x + (i % (step*2) < step ? 3 : -3);
                    if (i === 0) ctx.moveTo(b.x, b.y + i);
                    else ctx.lineTo(wx, b.y + i);
                }
                ctx.stroke();
            } else {
                ctx.fillStyle = '#ff4444';
                ctx.shadowColor = '#ff2200';
                ctx.fillRect(b.x - 1, b.y, 3, 13);
                ctx.fillStyle = '#ffaaaa';
                ctx.fillRect(b.x, b.y+1, 1, 10);
            }
            ctx.restore();
        });
    }

    function drawShields() {
        G.shields.forEach(function(sh) {
            sh.blocks.forEach(function(bl) {
                if (bl.hp <= 0) return;
                var a = bl.hp / 4;
                var g2 = Math.floor(a * 220);
                ctx.save();
                ctx.shadowBlur = a > 0.5 ? 7 : 3;
                ctx.shadowColor = 'rgb(0,' + g2 + ',80)';
                ctx.fillStyle = 'rgb(0,' + g2 + ',80)';
                ctx.globalAlpha = 0.5 + a * 0.5;
                ctx.fillRect(bl.x, bl.y, 10, 10);
                ctx.restore();
            });
        });
    }

    function drawDrops() {
        G.drops.forEach(function(d) {
            var pulse = Math.sin(d.glow) * 6 + 11;
            ctx.save();
            ctx.shadowBlur = pulse;
            ctx.shadowColor = d.type.color;
            ctx.strokeStyle = d.type.color;
            ctx.lineWidth = 1.5;
            ctx.strokeRect(d.x + 1, d.y + 1, d.w - 2, d.h - 2);
            ctx.fillStyle = 'rgba(0,0,0,0.55)';
            ctx.fillRect(d.x + 2, d.y + 2, d.w - 4, d.h - 4);
            ctx.fillStyle = d.type.color;
            ctx.font = 'bold 10px monospace';
            ctx.textAlign = 'center';
            ctx.fillText(d.type.label, d.x + d.w / 2, d.y + 15);
            ctx.restore();
        });
    }

    function drawParticles() {
        G.particles.forEach(function(p) {
            ctx.save();
            ctx.globalAlpha = Math.max(0, p.life);
            ctx.shadowBlur = 5;
            ctx.shadowColor = p.color;
            ctx.fillStyle = p.color;
            ctx.fillRect(p.x - p.size/2, p.y - p.size/2, p.size, p.size);
            ctx.restore();
        });
        G.scorePopups.forEach(function(p) {
            ctx.save();
            ctx.globalAlpha = Math.min(1, p.life);
            ctx.shadowBlur = 8;
            ctx.shadowColor = p.color;
            ctx.fillStyle = p.color;
            ctx.font = 'bold 13px monospace';
            ctx.textAlign = 'center';
            ctx.fillText(p.text, p.x, p.y);
            ctx.restore();
        });
    }

    function drawHUD() {
        // Top bar
        ctx.save();
        ctx.fillStyle = 'rgba(0,0,10,0.8)';
        ctx.fillRect(0, 0, W, 24);

        ctx.font = 'bold 13px monospace';
        ctx.textBaseline = 'middle';

        // Score
        ctx.shadowBlur = 8; ctx.shadowColor = '#0ff'; ctx.fillStyle = '#0ff';
        ctx.textAlign = 'left';
        ctx.fillText('SCORE', 8, 12);
        ctx.fillStyle = '#fff';
        ctx.fillText(String(G.score).padStart(7, '0'), 68, 12);

        // Hi-Score
        ctx.shadowColor = '#ff0'; ctx.fillStyle = '#ff0';
        ctx.textAlign = 'center';
        ctx.fillText('HI  ' + String(G.hiScore).padStart(7,'0'), W / 2, 12);

        // Lives
        ctx.shadowColor = '#0f8'; ctx.fillStyle = '#0f8';
        ctx.textAlign = 'right';
        ctx.fillText('LIVES', W - 90, 12);
        for (var i = 0; i < G.lives; i++) {
            ctx.fillStyle = '#00ff88';
            ctx.fillRect(W - 72 + i * 22, 5, 14, 10);
        }

        // Level bar bottom
        ctx.shadowColor = '#ff88ff'; ctx.fillStyle = '#ff88ff';
        ctx.font = '11px monospace';
        ctx.textAlign = 'center';
        ctx.fillText('— WAVE ' + G.level + ' —', W / 2, H - 9);

        // Active powerup timers (bottom left)
        var ox = 8;
        ctx.font = '10px monospace';
        ctx.textAlign = 'left';
        if (G.rapidFire > 0) {
            ctx.shadowColor = '#ffff00'; ctx.fillStyle = '#ffff00';
            ctx.fillText('⚡ ' + Math.ceil(G.rapidFire / 60) + 's', ox, H - 9); ox += 56;
        }
        if (G.multiShot > 0) {
            ctx.shadowColor = '#ff88ff'; ctx.fillStyle = '#ff88ff';
            ctx.fillText('✦ ' + Math.ceil(G.multiShot / 60) + 's', ox, H - 9); ox += 56;
        }
        if (G.shieldTimer > 0) {
            ctx.shadowColor = '#00ffff'; ctx.fillStyle = '#00ffff';
            ctx.fillText('🛡 ' + Math.ceil(G.shieldTimer / 60) + 's', ox, H - 9);
        }

        ctx.restore();
    }

    function drawScanlines() {
        ctx.save();
        ctx.globalAlpha = 0.03;
        ctx.fillStyle = '#000';
        for (var y = 0; y < H; y += 3) ctx.fillRect(0, y, W, 1);
        ctx.restore();
    }

    function drawOverlay(title, lines, col) {
        ctx.save();
        ctx.fillStyle = 'rgba(0,0,16,0.82)';
        ctx.fillRect(0, 0, W, H);
        ctx.textAlign = 'center';

        // Glow title
        ctx.shadowBlur = 35 + Math.sin(G.frame * 0.04) * 8;
        ctx.shadowColor = col;
        ctx.fillStyle = col;
        ctx.font = 'bold 54px monospace';
        ctx.fillText(title, W / 2, H / 2 - 70);

        ctx.font = '16px monospace';
        ctx.shadowBlur = 10;
        lines.forEach(function(ln, i) {
            ctx.fillStyle = i === 0 ? '#ffffff' : col;
            ctx.shadowColor = i === 0 ? '#ffffff' : col;
            ctx.fillText(ln, W / 2, H / 2 - 10 + i * 32);
        });
        ctx.restore();
    }

    function drawTitle() {
        ctx.save();
        var t = G.frame;

        // Title text
        ctx.textAlign = 'center';
        ctx.shadowBlur = 28 + Math.sin(t * 0.03) * 10;
        ctx.shadowColor = '#00ffff';
        ctx.fillStyle = '#00ffff';
        ctx.font = 'bold 58px monospace';
        ctx.fillText('SPACE', W / 2, 100);

        ctx.shadowColor = '#ff00ff';
        ctx.fillStyle = '#ff00ff';
        ctx.font = 'bold 58px monospace';
        ctx.fillText('INVADERS', W / 2, 162);

        ctx.shadowColor = '#ffff00';
        ctx.fillStyle = '#ffff00';
        ctx.font = '11px monospace';
        ctx.shadowBlur = 8;
        ctx.fillText('✦  NEON ARCADE EDITION  ✦', W / 2, 185);

        // Score table
        var tx = W / 2 - 120, ty = 215;
        ctx.font = 'bold 12px monospace';
        ctx.textAlign = 'left';
        var tableRows = [
            { label:'▲▲  = 40 PTS', col:'#ff44ff' },
            { label:'≡≡  = 20 PTS', col:'#44ddff' },
            { label:'⊕⊕  = 10 PTS', col:'#44ffaa' },
            { label:'⊘⊘  = ???', col:'#ff3333' }
        ];
        tableRows.forEach(function(r, i) {
            ctx.shadowBlur = 10; ctx.shadowColor = r.col; ctx.fillStyle = r.col;
            ctx.fillText(r.label, tx, ty + i * 26);
        });

        // Power-up table
        ctx.shadowBlur = 6;
        ctx.font = '11px monospace';
        var puY = 340;
        ctx.fillStyle = '#888'; ctx.shadowColor='#888';
        ctx.textAlign = 'center';
        ctx.fillText('POWER-UPS', W / 2, puY);
        var puCols = ['#ffff00','#ff88ff','#00ffff','#ff4400','#ff0055'];
        var puLabels = ['⚡ RAPID','✦ MULTI','🛡 SHIELD','💣 BOMB','♥ LIFE'];
        puLabels.forEach(function(l, i) {
            ctx.shadowColor = puCols[i]; ctx.fillStyle = puCols[i];
            ctx.fillText(l, 100 + i * 148, puY + 20);
        });

        // Controls
        ctx.fillStyle = '#556'; ctx.shadowBlur = 0;
        ctx.font = '12px monospace';
        ctx.fillText('← → MOVE      SPACE / Z  FIRE      P  PAUSE', W / 2, H - 50);

        // Blinking CTA
        if (Math.floor(t / 28) % 2 === 0) {
            ctx.shadowBlur = 16; ctx.shadowColor = '#0ff'; ctx.fillStyle = '#0ff';
            ctx.font = 'bold 18px monospace';
            ctx.fillText('PRESS  SPACE  TO  START', W / 2, H - 22);
        }
        ctx.restore();
    }

    // ── Render loop ──────────────────────────────────────────────
    function render() {
        // Background
        ctx.fillStyle = '#000014';
        ctx.fillRect(0, 0, W, H);

        // Screen flash (power-up pickup)
        if (G.flashTimer > 0) {
            ctx.save();
            ctx.globalAlpha = G.flashTimer * 0.06;
            ctx.fillStyle = '#ffffff';
            ctx.fillRect(0, 0, W, H);
            ctx.restore();
        }

        drawStars();

        if (G.state === 'title') { drawTitle(); drawScanlines(); return; }

        // Game content
        drawShields();

        G.aliens.forEach(function(a){ drawAlien(a); });
        drawUFO();
        drawParticles();
        drawDrops();
        drawBullets();
        drawPlayer();

        drawHUD();
        drawScanlines();

        if (G.state === 'paused') {
            drawOverlay('PAUSED', ['PRESS P TO CONTINUE', 'SCORE: ' + G.score], '#ffff00');
        } else if (G.state === 'levelup') {
            drawOverlay('WAVE CLEAR!',
                ['WAVE BONUS  +' + (G.level * 200) + ' PTS', 'PREPARING NEXT WAVE...'], '#00ffff');
        } else if (G.state === 'gameover') {
            drawOverlay('GAME OVER', [
                'SCORE   ' + String(G.score).padStart(7,'0'),
                'HI-SCORE ' + String(G.hiScore).padStart(7,'0'),
                '',
                Math.floor(G.frame/30)%2===0 ? 'PRESS SPACE TO PLAY AGAIN' : ''
            ], '#ff3300');
        }
    }

    // ── Input ────────────────────────────────────────────────────
    window.addEventListener('keydown', function(e) {
        keys[e.key] = true;
        if (e.key === ' ' || e.key === 'ArrowLeft' || e.key === 'ArrowRight' ||
            e.key === 'ArrowUp' || e.key === 'ArrowDown') e.preventDefault();

        if (G.state === 'title' && e.key === ' ') {
            G.state = 'playing';
        } else if (G.state === 'gameover' && e.key === ' ') {
            var hi = G.hiScore;
            initGame(false);
            G.hiScore = hi;
            G.state = 'playing';
        } else if ((e.key === 'p' || e.key === 'P') && (G.state === 'playing' || G.state === 'paused')) {
            G.state = G.state === 'paused' ? 'playing' : 'paused';
        }
    });
    window.addEventListener('keyup', function(e) { keys[e.key] = false; });

    // Gamepad (bonus)
    var gpad = { left: false, right: false, fire: false };
    function pollGamepad() {
        var gps = navigator.getGamepads ? navigator.getGamepads() : [];
        if (gps[0]) {
            var g = gps[0];
            gpad.left  = g.axes[0] < -0.3 || (g.buttons[14] && g.buttons[14].pressed);
            gpad.right = g.axes[0] >  0.3 || (g.buttons[15] && g.buttons[15].pressed);
            gpad.fire  = g.buttons[0] && g.buttons[0].pressed;
            if (gpad.left)  keys['ArrowLeft']  = true; else delete keys['ArrowLeft'];
            if (gpad.right) keys['ArrowRight'] = true; else delete keys['ArrowRight'];
            if (gpad.fire)  keys[' '] = true; else delete keys[' '];
        }
    }

    // ── Loop ─────────────────────────────────────────────────────
    var last = 0;
    function loop(ts) {
        requestAnimationFrame(loop);
        if (ts - last < 15) return;
        last = ts;
        pollGamepad();
        update();
        render();
    }

    // ── Boot ─────────────────────────────────────────────────────
    initGame(false);
    setupGMethods();
    buildSpriteCache();
    requestAnimationFrame(loop);

})();
