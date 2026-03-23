(function () {
    'use strict';

    /* ── Constants ──────────────────────────────────────────────── */
    var CELL = 20;
    var COLS = 30;
    var ROWS = 25;
    var HEADER_H = 60;
    var W = COLS * CELL;                 // 600
    var H = ROWS * CELL + HEADER_H;     // 560

    var MOVE_INTERVAL_MS = 110;         // ms per snake step (base speed)
    var SPEED_UP_EVERY   = 5;           // speed up every N foods eaten
    var MIN_INTERVAL     = 55;          // fastest possible interval

    var C = {
        bg:       '#0f0f1a',
        grid:     '#16162a',
        head:     '#00ff88',
        body:     '#00cc66',
        tail:     '#009944',
        food:     '#ff3860',
        text:     '#ffffff',
        sub:      '#888899',
        score:    '#00ff88',
        overlay:  'rgba(0,0,0,0.78)',
        border:   '#1e1e3a',
    };

    /* ── Canvas setup ───────────────────────────────────────────── */
    var canvas = document.createElement('canvas');
    canvas.width  = W;
    canvas.height = H;
    canvas.style.cssText =
        'display:block;margin:0 auto;border-radius:10px;' +
        'box-shadow:0 0 36px 4px rgba(0,255,136,0.18),0 0 0 2px ' + C.border + ';' +
        'outline:none;cursor:default;';
    canvas.setAttribute('tabindex', '0');

    var host = document.getElementById('controlAddIn') || document.body;
    host.style.cssText =
        'display:flex;justify-content:center;align-items:center;' +
        'background:#0a0a12;height:100%;padding:12px;box-sizing:border-box;';
    host.appendChild(canvas);
    canvas.focus();

    var ctx = canvas.getContext('2d');

    /* ── Game state ─────────────────────────────────────────────── */
    var snake, dir, nextDir, food, score, gameOver, paused;
    var lastTimestamp = 0;
    var accumulator   = 0;
    var moveInterval  = MOVE_INTERVAL_MS;
    var highScore     = 0;
    var level         = 1;

    function initGame() {
        var mx = Math.floor(COLS / 2);
        var my = Math.floor(ROWS / 2);
        snake = [
            { x: mx,     y: my },
            { x: mx - 1, y: my },
            { x: mx - 2, y: my },
        ];
        dir          = { x: 1, y: 0 };
        nextDir      = { x: 1, y: 0 };
        score        = 0;
        level        = 1;
        gameOver     = false;
        paused       = false;
        accumulator  = 0;
        moveInterval = MOVE_INTERVAL_MS;
        spawnFood();
    }

    function spawnFood() {
        var pos;
        do {
            pos = {
                x: Math.floor(Math.random() * COLS),
                y: Math.floor(Math.random() * ROWS),
            };
        } while (snake.some(function (s) { return s.x === pos.x && s.y === pos.y; }));
        food = pos;
    }

    /* ── Input ──────────────────────────────────────────────────── */
    var KEY_MAP = {
        'ArrowUp':    { x:  0, y: -1 },
        'ArrowDown':  { x:  0, y:  1 },
        'ArrowLeft':  { x: -1, y:  0 },
        'ArrowRight': { x:  1, y:  0 },
        'w': { x:  0, y: -1 }, 'W': { x:  0, y: -1 },
        's': { x:  0, y:  1 }, 'S': { x:  0, y:  1 },
        'a': { x: -1, y:  0 }, 'A': { x: -1, y:  0 },
        'd': { x:  1, y:  0 }, 'D': { x:  1, y:  0 },
    };

    document.addEventListener('keydown', function (e) {
        var mapped = KEY_MAP[e.key];
        if (mapped) {
            e.preventDefault();
            if (!(mapped.x === -dir.x && mapped.y === -dir.y)) {
                nextDir = mapped;
            }
        }
        if (e.key === 'p' || e.key === 'P' || e.key === 'Escape') {
            if (!gameOver) paused = !paused;
        }
        if ((e.key === 'Enter' || e.key === ' ') && gameOver) {
            initGame();
        }
    });

    // Click/tap on canvas to re-focus (so arrow keys work inside BC)
    canvas.addEventListener('click', function () { canvas.focus(); });

    /* ── Game logic step ────────────────────────────────────────── */
    function step() {
        dir = nextDir;
        var head = { x: snake[0].x + dir.x, y: snake[0].y + dir.y };

        // Wall collision
        if (head.x < 0 || head.x >= COLS || head.y < 0 || head.y >= ROWS) {
            endGame(); return;
        }
        // Self collision (exclude last segment — it moves away this tick)
        for (var i = 0; i < snake.length - 1; i++) {
            if (snake[i].x === head.x && snake[i].y === head.y) {
                endGame(); return;
            }
        }

        snake.unshift(head);

        if (head.x === food.x && head.y === food.y) {
            score++;
            if (score > highScore) highScore = score;
            if (score % SPEED_UP_EVERY === 0) {
                moveInterval = Math.max(MIN_INTERVAL, moveInterval - 8);
                level++;
            }
            spawnFood();
        } else {
            snake.pop();
        }
    }

    function endGame() {
        gameOver = true;
        if (score > highScore) highScore = score;
    }

    /* ── Drawing helpers ────────────────────────────────────────── */
    function roundRect(x, y, w, h, r) {
        ctx.beginPath();
        ctx.moveTo(x + r, y);
        ctx.lineTo(x + w - r, y);
        ctx.quadraticCurveTo(x + w, y, x + w, y + r);
        ctx.lineTo(x + w, y + h - r);
        ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
        ctx.lineTo(x + r, y + h);
        ctx.quadraticCurveTo(x, y + h, x, y + h - r);
        ctx.lineTo(x, y + r);
        ctx.quadraticCurveTo(x, y, x + r, y);
        ctx.closePath();
    }

    /* ── Draw background + grid ─────────────────────────────────── */
    function drawBackground() {
        ctx.fillStyle = C.bg;
        ctx.fillRect(0, 0, W, H);

        ctx.strokeStyle = C.grid;
        ctx.lineWidth   = 0.4;
        for (var c = 0; c <= COLS; c++) {
            ctx.beginPath();
            ctx.moveTo(c * CELL, HEADER_H);
            ctx.lineTo(c * CELL, H);
            ctx.stroke();
        }
        for (var r = 0; r <= ROWS; r++) {
            ctx.beginPath();
            ctx.moveTo(0, HEADER_H + r * CELL);
            ctx.lineTo(W, HEADER_H + r * CELL);
            ctx.stroke();
        }
    }

    /* ── Draw header ────────────────────────────────────────────── */
    function drawHeader() {
        var cy = HEADER_H / 2;

        ctx.fillStyle    = C.score;
        ctx.font         = 'bold 22px "Courier New", monospace';
        ctx.textBaseline = 'middle';
        ctx.textAlign    = 'left';
        ctx.fillText('SCORE  ' + score, 18, cy);

        ctx.fillStyle = C.head;
        ctx.font      = '13px "Courier New", monospace';
        ctx.textAlign = 'center';
        ctx.fillText('LVL ' + level, W / 2, cy);

        ctx.fillStyle = C.sub;
        ctx.font      = '13px "Courier New", monospace';
        ctx.textAlign = 'right';
        ctx.fillText('BEST  ' + highScore, W - 18, cy);

        // Separator line
        ctx.strokeStyle = C.border;
        ctx.lineWidth   = 1;
        ctx.beginPath();
        ctx.moveTo(0, HEADER_H);
        ctx.lineTo(W, HEADER_H);
        ctx.stroke();
    }

    /* ── Draw food ──────────────────────────────────────────────── */
    function drawFood(t) {
        var fx   = food.x * CELL + CELL / 2;
        var fy   = food.y * CELL + HEADER_H + CELL / 2;
        var pulse = 0.75 + 0.25 * Math.sin(t * 0.006);
        var r    = (CELL / 2 - 2) * pulse;

        // Glow
        var grd = ctx.createRadialGradient(fx, fy, 0, fx, fy, CELL * 1.2);
        grd.addColorStop(0, 'rgba(255,56,96,0.5)');
        grd.addColorStop(1, 'rgba(255,56,96,0)');
        ctx.fillStyle = grd;
        ctx.fillRect(fx - CELL * 1.2, fy - CELL * 1.2, CELL * 2.4, CELL * 2.4);

        // Dot
        ctx.fillStyle = C.food;
        ctx.shadowColor = C.food;
        ctx.shadowBlur  = 10;
        ctx.beginPath();
        ctx.arc(fx, fy, r, 0, Math.PI * 2);
        ctx.fill();
        ctx.shadowBlur = 0;
    }

    /* ── Draw snake ─────────────────────────────────────────────── */
    function lerpColor(a, b, t) {
        var ar = parseInt(a.slice(1, 3), 16);
        var ag = parseInt(a.slice(3, 5), 16);
        var ab = parseInt(a.slice(5, 7), 16);
        var br = parseInt(b.slice(1, 3), 16);
        var bg = parseInt(b.slice(3, 5), 16);
        var bb = parseInt(b.slice(5, 7), 16);
        var r  = Math.round(ar + (br - ar) * t);
        var g  = Math.round(ag + (bg - ag) * t);
        var bv = Math.round(ab + (bb - ab) * t);
        return 'rgb(' + r + ',' + g + ',' + bv + ')';
    }

    function drawSnake() {
        var len = snake.length;
        for (var i = len - 1; i >= 0; i--) {
            var seg = snake[i];
            var sx  = seg.x * CELL + 1;
            var sy  = seg.y * CELL + HEADER_H + 1;
            var sw  = CELL - 2;
            var sh  = CELL - 2;
            var t   = i / Math.max(len - 1, 1);

            if (i === 0) {
                ctx.shadowColor = C.head;
                ctx.shadowBlur  = 14;
                ctx.fillStyle   = C.head;
            } else {
                ctx.shadowBlur  = 0;
                ctx.fillStyle   = lerpColor(C.body, C.tail, Math.min(t * 1.4, 1));
            }

            roundRect(sx, sy, sw, sh, i === 0 ? 6 : 3);
            ctx.fill();
        }
        ctx.shadowBlur = 0;
    }

    /* ── Draw overlays ──────────────────────────────────────────── */
    function drawPaused() {
        ctx.fillStyle = C.overlay;
        ctx.fillRect(0, HEADER_H, W, H - HEADER_H);

        ctx.textAlign    = 'center';
        ctx.textBaseline = 'middle';

        ctx.fillStyle = C.text;
        ctx.font      = 'bold 36px "Courier New", monospace';
        ctx.fillText('PAUSADO', W / 2, H / 2 - 18);

        ctx.fillStyle = C.sub;
        ctx.font      = '15px "Courier New", monospace';
        ctx.fillText('P o ESC para continuar', W / 2, H / 2 + 22);
    }

    function drawGameOver() {
        ctx.fillStyle = C.overlay;
        ctx.fillRect(0, HEADER_H, W, H - HEADER_H);

        ctx.textAlign    = 'center';
        ctx.textBaseline = 'middle';

        ctx.fillStyle   = C.food;
        ctx.shadowColor = C.food;
        ctx.shadowBlur  = 20;
        ctx.font        = 'bold 42px "Courier New", monospace';
        ctx.fillText('GAME OVER', W / 2, H / 2 - 70);
        ctx.shadowBlur  = 0;

        ctx.fillStyle = C.score;
        ctx.font      = 'bold 28px "Courier New", monospace';
        ctx.fillText('Puntos: ' + score, W / 2, H / 2 - 16);

        ctx.fillStyle = C.sub;
        ctx.font      = '17px "Courier New", monospace';
        ctx.fillText('Record: ' + highScore, W / 2, H / 2 + 24);

        // Blinking hint
        var blink = Math.floor(Date.now() / 600) % 2 === 0;
        if (blink) {
            ctx.fillStyle = C.text;
            ctx.font      = '15px "Courier New", monospace';
            ctx.fillText('ENTER o ESPACIO para jugar de nuevo', W / 2, H / 2 + 70);
        }
    }

    /* ── Draw start screen ──────────────────────────────────────── */
    var started = false;

    function drawStart() {
        ctx.fillStyle = C.overlay;
        ctx.fillRect(0, HEADER_H, W, H - HEADER_H);

        ctx.textAlign    = 'center';
        ctx.textBaseline = 'middle';

        ctx.fillStyle   = C.head;
        ctx.shadowColor = C.head;
        ctx.shadowBlur  = 24;
        ctx.font        = 'bold 52px "Courier New", monospace';
        ctx.fillText('SNAKE', W / 2, H / 2 - 60);
        ctx.shadowBlur  = 0;

        ctx.fillStyle = C.sub;
        ctx.font      = '15px "Courier New", monospace';
        ctx.fillText('Flechas o WASD para mover', W / 2, H / 2 + 10);
        ctx.fillText('P / ESC para pausar', W / 2, H / 2 + 36);

        var blink = Math.floor(Date.now() / 600) % 2 === 0;
        if (blink) {
            ctx.fillStyle = C.text;
            ctx.font      = '16px "Courier New", monospace';
            ctx.fillText('ENTER o ESPACIO para empezar', W / 2, H / 2 + 76);
        }
    }

    // Show start screen until first keypress
    document.addEventListener('keydown', function (e) {
        if (!started && (e.key === 'Enter' || e.key === ' ')) {
            started = true;
        }
    }, { once: false });

    /* ── Main loop ──────────────────────────────────────────────── */
    function loop(timestamp) {
        requestAnimationFrame(loop);

        var dt = timestamp - lastTimestamp;
        if (dt > 100) dt = 100;        // cap spike to avoid tunneling
        lastTimestamp = timestamp;

        if (started && !paused && !gameOver) {
            accumulator += dt;
            while (accumulator >= moveInterval) {
                step();
                accumulator -= moveInterval;
            }
        }

        drawBackground();
        drawHeader();

        if (started) {
            drawFood(timestamp);
            drawSnake();
            if (paused)   drawPaused();
            if (gameOver) drawGameOver();
        } else {
            drawStart();
        }
    }

    /* ── Bootstrap ──────────────────────────────────────────────── */
    initGame();
    requestAnimationFrame(function (ts) {
        lastTimestamp = ts;
        requestAnimationFrame(loop);
    });

}());
