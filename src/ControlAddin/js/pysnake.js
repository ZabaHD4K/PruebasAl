(function () {
    'use strict';

    var BG = '#050010';

    /* ── CSS ─────────────────────────────────────────────────────────── */
    var css = [
        '* { box-sizing: border-box; margin: 0; padding: 0; }',
        'html, body { height: 100%; background: ' + BG + '; display: flex; align-items: center; justify-content: center; overflow: hidden; }',
        '#terminal { display: flex; flex-direction: column; align-items: center; }',
        '#screen { font-family: "Courier New", Courier, monospace; font-size: 18px; line-height: 1.25; white-space: pre; color: #1a0038; background: ' + BG + '; padding: 0; letter-spacing: 1px; cursor: default; outline: none; }',
        '#screen.gameover { animation: flicker .12s infinite alternate; }',
        '@keyframes flicker { from { opacity:1; } to { opacity:.78; } }',
        '#crt  { position:fixed; inset:0; pointer-events:none; background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(140,0,255,.045) 2px,rgba(140,0,255,.045) 4px); z-index:10; }',
        '#crt2 { position:fixed; inset:0; pointer-events:none; background:radial-gradient(ellipse at center,transparent 52%,rgba(15,0,50,.75) 100%); z-index:11; }',
        '#loading { position:fixed; inset:0; background:' + BG + '; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:16px; z-index:20; }',
        '#loading.hidden { display:none; }',
        '#ld-title { color:#8800ff; font-family:"Courier New",monospace; font-size:22px; font-weight:700; letter-spacing:3px; text-shadow:0 0 14px #8800ff; }',
        '#ld-sub   { color:#7755aa; font-family:"Courier New",monospace; font-size:13px; letter-spacing:1px; }',
        '#ld-bar   { width:240px; height:4px; background:#1a0038; border-radius:2px; overflow:hidden; }',
        '#ld-fill  { height:100%; background:linear-gradient(90deg,#8800ff,#00ffff); animation:ldpulse 1.4s ease-in-out infinite; }',
        '@keyframes ldpulse { 0%,100%{transform:translateX(-100%)} 50%{transform:translateX(100%)} }',
        '#ld-err   { color:#ff0044; font-family:"Courier New",monospace; font-size:12px; text-align:center; max-width:340px; display:none; line-height:1.6; }',
    ].join('\n');

    var styleEl = document.createElement('style');
    styleEl.textContent = css;
    document.head.appendChild(styleEl);

    document.body.innerHTML =
        '<div id="crt"></div><div id="crt2"></div>' +
        '<div id="terminal"><pre id="screen" tabindex="0"></pre></div>' +
        '<div id="loading">' +
            '<div id="ld-title">🐍 PySnake</div>' +
            '<div id="ld-sub">Cargando Python (Pyodide)…</div>' +
            '<div id="ld-bar"><div id="ld-fill"></div></div>' +
            '<div id="ld-err"></div>' +
        '</div>';

    /* ── Código Python del juego (ejecutado por Pyodide) ─────────────── */
    var PY = `
from js import document, Date, clearInterval, setInterval
from pyodide.ffi import create_proxy
import random

COLS, ROWS, TICK_MS, SPEED_EVERY, MIN_TICK = 38, 20, 120, 5, 55

C = {
    'border': '#8800ff', 'head':  '#00ffff',
    'bb':     '#ff00ee', 'bm':    '#bb00cc', 'bd': '#660088',
    'food':   '#ff0055', 'food2': '#ff77bb', 'em': '#1a0038',
    'sc':     '#ffdd00', 'lc':    '#00ff99', 'bc': '#ff8800',
    'hint':   '#7755aa', 'pause': '#ffff44', 'ov': '#ff0044',
}
CH = {
    'em': '·',  'fd': '◆', 'bo': '█',
    'hr': '▶',  'hl': '◀', 'hu': '▲', 'hd': '▼',
    'hb': '═',  'vb': '║', 'tl': '╔', 'tr': '╗', 'bl': '╚', 'br': '╝',
}
KEYS = {
    'ArrowUp':   [0,-1], 'w': [0,-1], 'W': [0,-1],
    'ArrowDown':  [0, 1], 's': [0, 1], 'S': [0, 1],
    'ArrowLeft':  [-1,0], 'a': [-1,0], 'A': [-1,0],
    'ArrowRight': [ 1,0], 'd': [ 1,0], 'D': [ 1,0],
}

G = dict(
    snake=[], dir=[1,0], nd=[1,0], food=[0,0],
    score=0, hi=0, level=1, ms=TICK_MS,
    over=False, started=False, paused=False, timer=None
)

screen = document.getElementById('screen')

def init():
    mx, my = COLS // 2, ROWS // 2
    G.update(
        snake=[[mx,my],[mx-1,my],[mx-2,my]],
        dir=[1,0], nd=[1,0], score=0, level=1,
        ms=TICK_MS, over=False, paused=False
    )
    spawn_food()

def spawn_food():
    while True:
        p = [random.randint(0, COLS-1), random.randint(0, ROWS-1)]
        if p not in G['snake']:
            G['food'] = p
            break

# ── Helpers de render ─────────────────────────────────────────────

def sp(col, txt):
    s = str(txt).replace('&','&amp;').replace('<','&lt;').replace('>','&gt;')
    return f'<span style="color:{col};text-shadow:0 0 6px {col}">{s}</span>'

def pad(s, n):
    return str(s).ljust(n)[:n]

def center(s, w):
    spaces = max(0, (w - len(s)) // 2)
    return (' ' * spaces + s).ljust(w)[:w]

def head_ch():
    d = G['dir']
    if d == [1,0]:  return CH['hr']
    if d == [-1,0]: return CH['hl']
    if d == [0,-1]: return CH['hu']
    return CH['hd']

def body_col(i):
    r = i / max(len(G['snake']) - 1, 1)
    if r < 0.25: return C['bb']
    if r < 0.55: return C['bm']
    return C['bd']

def score_bar():
    return (
        sp(C['sc'], pad(f"SCORE:{G['score']}", 13)) +
        sp(C['lc'], pad(f"LVL:{G['level']}",   11)) +
        sp(C['bc'], pad(f"BEST:{G['hi']}",      14))
    )

def render():
    grid = [[[CH['em'], C['em']] for _ in range(COLS)] for _ in range(ROWS)]

    # Comida pulsante
    pulse = int(Date.now() / 300) % 2 == 0
    fx, fy = G['food']
    grid[fy][fx] = [CH['fd'], C['food'] if pulse else C['food2']]

    # Cuerpo con gradiente de color
    for i in range(len(G['snake']) - 1, 0, -1):
        sx, sy = G['snake'][i]
        grid[sy][sx] = [CH['bo'], body_col(i)]

    # Cabeza
    hx, hy = G['snake'][0]
    grid[hy][hx] = [head_ch(), C['head']]

    bc = C['ov'] if G['over'] else C['border']
    lines = [sp(bc, CH['tl']) + score_bar() + sp(bc, CH['tr'])]

    for r in range(ROWS):
        row = sp(bc, CH['vb'])
        for c in range(COLS):
            ch, col = grid[r][c]
            row += sp(col, ch)
        row += sp(bc, CH['vb'])
        lines.append(row)

    lines.append(sp(bc, CH['bl']) + sp(bc, CH['hb'] * COLS) + sp(bc, CH['br']))

    if not G['started']:
        st = sp(C['head'],  center('[ ENTER o ESPACIO para empezar ]',    COLS + 2))
    elif G['over']:
        st = sp(C['ov'],    center('⚡ GAME OVER ⚡   ENTER para reiniciar', COLS + 2))
    elif G['paused']:
        st = sp(C['pause'], center('⏸  PAUSADO  —  P para continuar',      COLS + 2))
    else:
        st = sp(C['hint'],  center('WASD / Flechas  ·  P pausa  ·  ESC pausa', COLS + 2))
    lines.append(st)

    screen.innerHTML = chr(10).join(lines)
    screen.className = 'gameover' if G['over'] else ''

# ── Lógica del juego ──────────────────────────────────────────────

def stop_timer():
    if G['timer'] is not None:
        clearInterval(G['timer'])
        G['timer'] = None

def start_tick():
    stop_timer()
    G['timer'] = setInterval(tick_px, G['ms'])

def tick(_=None):
    if not G['started'] or G['paused'] or G['over']:
        render()
        return

    G['dir'] = G['nd'][:]
    hx = G['snake'][0][0] + G['dir'][0]
    hy = G['snake'][0][1] + G['dir'][1]

    if hx < 0 or hx >= COLS or hy < 0 or hy >= ROWS:
        end_game(); render(); return

    for seg in G['snake'][:-1]:
        if seg[0] == hx and seg[1] == hy:
            end_game(); render(); return

    G['snake'].insert(0, [hx, hy])

    if hx == G['food'][0] and hy == G['food'][1]:
        G['score'] += 1
        if G['score'] > G['hi']:
            G['hi'] = G['score']
        if G['score'] % SPEED_EVERY == 0:
            G['level'] += 1
            G['ms'] = max(MIN_TICK, G['ms'] - 8)
            stop_timer()
            G['timer'] = setInterval(tick_px, G['ms'])
        spawn_food()
    else:
        G['snake'].pop()

    render()

def end_game():
    G['over'] = True
    stop_timer()
    if G['score'] > G['hi']:
        G['hi'] = G['score']

def on_key(e):
    key = e.key
    if key in KEYS:
        e.preventDefault()
        m = KEYS[key]
        if not (m[0] == -G['dir'][0] and m[1] == -G['dir'][1]):
            G['nd'] = m[:]
    if key in ('p', 'P', 'Escape') and G['started'] and not G['over']:
        G['paused'] = not G['paused']
    if key in ('Enter', ' ') and not G['started']:
        G['started'] = True; start_tick()
    if key in ('Enter', ' ') and G['over']:
        init(); G['started'] = True; start_tick()

def blink(_=None):
    if not G['started'] or G['paused'] or G['over']:
        render()

# ── Inicializar ───────────────────────────────────────────────────

tick_px  = create_proxy(tick)
key_px   = create_proxy(on_key)
blink_px = create_proxy(blink)

document.addEventListener('keydown', key_px)
setInterval(blink_px, 300)
init()
render()
`;

    /* ── Arrancar Pyodide ────────────────────────────────────────────── */
    function showErr(msg) {
        var el = document.getElementById('ld-err');
        if (el) { el.style.display = 'block'; el.textContent = '⚠ ' + msg; }
    }

    function runGame(pyodide) {
        try {
            pyodide.runPython(PY);
            var ld = document.getElementById('loading');
            if (ld) ld.classList.add('hidden');
            var s = document.getElementById('screen');
            if (s) s.focus();
        } catch (err) {
            showErr('Error en Python: ' + err.message);
        }
    }

    var tag = document.createElement('script');
    tag.src = 'https://cdn.jsdelivr.net/pyodide/v0.26.4/full/pyodide.js';
    tag.onload = function () {
        var sub = document.getElementById('ld-sub');
        if (sub) sub.textContent = 'Compilando módulos Python…';
        window.loadPyodide({ indexURL: 'https://cdn.jsdelivr.net/pyodide/v0.26.4/full/' })
            .then(runGame)
            .catch(function (e) { showErr('Fallo al cargar Pyodide: ' + e.message); });
    };
    tag.onerror = function () {
        showErr('No se pudo cargar Pyodide. Comprueba la conexión a internet.');
    };
    document.head.appendChild(tag);

    Microsoft.Dynamics.NAV.AddInReady();

}());
