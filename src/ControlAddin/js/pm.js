(function () {
    'use strict';

    // ── Config ────────────────────────────────────────────────────────────────
    var REFRESH_SEC = 30;

    // ── State ─────────────────────────────────────────────────────────────────
    var markets = [];
    var activeTag = '';
    var searchQuery = '';
    var sortMode = 'volume';
    var countdown = REFRESH_SEC;
    var refreshInterval = null;
    var searchDebounce = null;
    var isLoading = false;

    // ── Palette ───────────────────────────────────────────────────────────────
    var C = {
        bg:      '#0b1120',
        surface: '#111827',
        card:    '#1a2438',
        border:  '#1f3050',
        hover:   '#1e304d',
        text:    '#e2e8f0',
        muted:   '#64748b',
        accent:  '#3b82f6',
        green:   '#22c55e',
        amber:   '#f59e0b',
        red:     '#ef4444',
        purple:  '#a855f7',
        tag:     '#0f2d5c',
        tagText: '#60a5fa',
    };

    function probColor(p) {
        if (p >= 0.65) return C.green;
        if (p >= 0.35) return C.amber;
        return C.red;
    }

    // ── CSS ───────────────────────────────────────────────────────────────────
    var styleEl = document.createElement('style');
    styleEl.textContent = [
        '*, *::before, *::after { box-sizing:border-box; margin:0; padding:0; }',
        'html, body { margin:0; padding:0; height:700px; overflow:hidden; }',
        'body { background:' + C.bg + '; color:' + C.text + '; font-family:"Segoe UI",system-ui,sans-serif; font-size:13px; line-height:1.5; }',

        /* Root */
        '#pm { display:flex; flex-direction:column; height:700px; }',

        /* ── Toolbar ── */
        '#pm-bar { background:' + C.surface + '; border-bottom:1px solid ' + C.border + '; padding:6px 14px; display:flex; flex-wrap:wrap; gap:8px; align-items:center; flex-shrink:0; }',
        '#pm-logo { font-size:15px; font-weight:800; color:#fff; letter-spacing:-.3px; white-space:nowrap; }',
        '#pm-logo em { color:' + C.accent + '; font-style:normal; }',
        '.pm-ctrl { background:' + C.card + '; border:1px solid ' + C.border + '; border-radius:7px; color:' + C.text + '; font-size:12px; padding:6px 10px; outline:none; }',
        '.pm-ctrl:focus { border-color:' + C.accent + '; }',
        '#pm-search { flex:1; min-width:140px; max-width:280px; }',
        '#pm-tag { cursor:pointer; }',
        '#pm-sort { cursor:pointer; }',
        '#pm-refresh { background:' + C.accent + '; border:none; border-radius:7px; color:#fff; font-size:12px; font-weight:700; padding:6px 13px; cursor:pointer; white-space:nowrap; transition:background .15s; }',
        '#pm-refresh:hover { background:#2563eb; }',
        '#pm-refresh:disabled { opacity:.4; cursor:default; }',
        '#pm-cd { font-size:11px; color:' + C.muted + '; background:' + C.card + '; border:1px solid ' + C.border + '; border-radius:12px; padding:4px 10px; white-space:nowrap; transition:color .3s; }',
        '#pm-cd.hot { color:' + C.accent + '; border-color:' + C.accent + '; }',
        '#pm-stats { font-size:11px; color:' + C.muted + '; white-space:nowrap; margin-left:auto; }',
        '#pm-last { font-size:10px; color:' + C.muted + '; white-space:nowrap; }',

        /* ── Grid ── */
        '#pm-grid { overflow-y:auto; padding:14px; display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:11px; align-content:start; }',

        /* ── Card ── */
        '.pm-card { background:' + C.card + '; border:1px solid ' + C.border + '; border-radius:11px; padding:14px; display:flex; flex-direction:column; gap:10px; transition:border-color .2s,box-shadow .2s,transform .15s; }',
        '.pm-card:hover { border-color:' + C.accent + '; box-shadow:0 0 0 1px ' + C.accent + '44; transform:translateY(-1px); }',

        /* Card header */
        '.pm-ch { display:flex; gap:10px; align-items:flex-start; }',
        '.pm-img { width:38px; height:38px; border-radius:7px; object-fit:cover; flex-shrink:0; background:' + C.border + '; }',
        '.pm-q { font-size:13px; font-weight:600; color:#f1f5f9; line-height:1.4; display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden; }',

        /* Outcomes */
        '.pm-outs { display:flex; flex-direction:column; gap:7px; }',
        '.pm-out { display:flex; flex-direction:column; gap:3px; }',
        '.pm-out-hdr { display:flex; justify-content:space-between; align-items:baseline; }',
        '.pm-out-lbl { font-size:10.5px; font-weight:700; color:' + C.muted + '; text-transform:uppercase; letter-spacing:.06em; }',
        '.pm-out-pct { font-size:15px; font-weight:800; }',
        '.pm-track { height:5px; background:#1e3050; border-radius:3px; overflow:hidden; }',
        '.pm-fill { height:100%; border-radius:3px; transition:width .7s cubic-bezier(.4,0,.2,1); }',

        /* Meta */
        '.pm-meta { display:flex; flex-wrap:wrap; gap:5px; align-items:center; }',
        '.pm-mi { font-size:11px; color:' + C.muted + '; display:flex; align-items:center; gap:3px; }',
        '.pm-dot { width:7px; height:7px; border-radius:50%; background:' + C.green + '; animation:blink 1.5s ease-in-out infinite; flex-shrink:0; }',
        '@keyframes blink { 0%,100%{opacity:1} 50%{opacity:.25} }',

        /* Tags */
        '.pm-tags { display:flex; flex-wrap:wrap; gap:4px; }',
        '.pm-tag { font-size:10px; padding:2px 8px; background:' + C.tag + '; color:' + C.tagText + '; border-radius:10px; font-weight:600; letter-spacing:.04em; }',

        /* Featured badge */
        '.pm-featured { font-size:9.5px; padding:2px 7px; background:#1a1a3e; color:#a78bfa; border-radius:10px; font-weight:700; letter-spacing:.05em; }',

        /* Loading / empty / error */
        '.pm-center { grid-column:1/-1; display:flex; flex-direction:column; align-items:center; justify-content:flex-start; padding:8px 20px; gap:10px; color:' + C.muted + '; }',
        '.pm-spinner { width:34px; height:34px; border:3px solid ' + C.border + '; border-top-color:' + C.accent + '; border-radius:50%; animation:spin .75s linear infinite; }',
        '@keyframes spin { to{transform:rotate(360deg)} }',
        '.pm-err { grid-column:1/-1; background:#2d1010; border:1px solid ' + C.red + '; border-radius:10px; padding:16px 18px; color:#fecaca; font-size:12.5px; line-height:1.6; }',

        /* Scrollbar */
        '#pm-grid::-webkit-scrollbar { width:5px; }',
        '#pm-grid::-webkit-scrollbar-track { background:transparent; }',
        '#pm-grid::-webkit-scrollbar-thumb { background:' + C.border + '; border-radius:3px; }',
    ].join('\n');
    document.head.appendChild(styleEl);

    // ── DOM ───────────────────────────────────────────────────────────────────
    function mk(tag, attrs, txt) {
        var n = document.createElement(tag);
        if (attrs) Object.keys(attrs).forEach(function (k) { n.setAttribute(k, attrs[k]); });
        if (txt !== undefined) n.textContent = txt;
        return n;
    }

    var root   = mk('div', { id: 'pm' });
    var bar    = mk('div', { id: 'pm-bar' });
    var logo   = mk('div', { id: 'pm-logo' });
    logo.innerHTML = '&#x1F4CA; <em>Poly</em>Market Live';

    var search = mk('input',  { id: 'pm-search', class: 'pm-ctrl', type: 'text', placeholder: '\uD83D\uDD0D Buscar mercados\u2026' });
    var tagSel = mk('select', { id: 'pm-tag',  class: 'pm-ctrl' });
    var srtSel = mk('select', { id: 'pm-sort', class: 'pm-ctrl' });
    var refBtn = mk('button', { id: 'pm-refresh' }, '\u21BB Actualizar');
    var cdEl   = mk('div',    { id: 'pm-cd' }, '');
    var stats  = mk('div',    { id: 'pm-stats' }, '');
    var lastEl = mk('div',    { id: 'pm-last' }, '');

    [['volume','&#x1F4C8; Mayor volumen'],['uncertain','&#x2696;&#xFE0F; Más disputados'],['soon','&#x1F4C5; Próximos a cerrar']].forEach(function (o) {
        var opt = mk('option', { value: o[0] }); opt.innerHTML = o[1]; srtSel.appendChild(opt);
    });

    bar.append(logo, search, tagSel, srtSel, refBtn, cdEl, stats, lastEl);
    var grid = mk('div', { id: 'pm-grid' });
    root.append(bar, grid);
    document.body.appendChild(root);

    // ── Preset categories ─────────────────────────────────────────────────────
    var PRESETS = [
        { slug: '',             label: '\uD83C\uDF10 Todos' },
        { slug: 'politics',     label: '\uD83D\uDDF3\uFE0F Política' },
        { slug: 'elections',    label: '\uD83C\uDFDB\uFE0F Elecciones' },
        { slug: 'crypto',       label: '\u20BF Crypto' },
        { slug: 'sports',       label: '\u26BD Deportes' },
        { slug: 'science',      label: '\uD83D\uDD2C Ciencia' },
        { slug: 'pop-culture',  label: '\uD83C\uDFAC Cultura Pop' },
        { slug: 'economics',    label: '\uD83D\uDCB0 Economía' },
        { slug: 'technology',   label: '\uD83D\uDCBB Tecnología' },
        { slug: 'geopolitics',  label: '\uD83C\uDF0D Geopolítica' },
    ];

    function buildTags(extras) {
        tagSel.innerHTML = '';
        var merged = PRESETS.slice();
        if (extras) extras.forEach(function (t) {
            var s = t.slug || '';
            if (s && !merged.find(function (p) { return p.slug === s; }))
                merged.push({ slug: s, label: t.label || s });
        });
        merged.forEach(function (t) {
            var o = mk('option', { value: t.slug }, t.label);
            if (t.slug === activeTag) o.selected = true;
            tagSel.appendChild(o);
        });
    }
    buildTags([]);

    // ── Helpers ───────────────────────────────────────────────────────────────
    function parseArr(v) {
        if (!v) return [];
        if (Array.isArray(v)) return v;
        try { return JSON.parse(v); } catch (_) { return []; }
    }

    function fmtVol(v) {
        v = Number(v) || 0;
        if (v >= 1e6) return '$' + (v / 1e6).toFixed(1) + 'M';
        if (v >= 1e3) return '$' + Math.round(v / 1e3) + 'K';
        return '$' + Math.round(v);
    }

    function fmtDate(d) {
        if (!d) return null;
        var dt = new Date(d);
        if (isNaN(dt)) return null;
        var now = new Date();
        var diff = Math.round((dt - now) / 864e5);
        if (diff < 0) return null;
        if (diff === 0) return 'Cierra hoy';
        if (diff === 1) return 'Cierra mañana';
        if (diff < 30) return 'Cierra en ' + diff + ' días';
        return 'Hasta ' + dt.toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' });
    }

    function fmtTime(d) {
        return new Date(d).toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    }

    // ── Data received from AL (AL uses HttpClient — no CORS issues) ──────────
    window.LoadTagsData = function (jsonText) {
        try {
            var list = JSON.parse(jsonText);
            if (Array.isArray(list)) buildTags(list);
        } catch (e) { console.warn('LoadTagsData parse error:', e); }
    };

    window.LoadMarketsData = function (jsonText) {
        try {
            var data = JSON.parse(jsonText);
            if (data && data.error) {
                showError(data.error);
            } else {
                markets = Array.isArray(data) ? data : (data.markets || data.data || []);
                render();
                lastEl.textContent = 'Actualizado ' + fmtTime(new Date());
            }
        } catch (e) {
            showError('Error al procesar datos: ' + e.message);
        }
        isLoading = false;
        refBtn.disabled = false;
        resetCountdown();
    };

    function requestRefresh() {
        if (isLoading) return;
        isLoading = true;
        refBtn.disabled = true;
        showLoading();
        try {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('RequestRefresh', null, true, true);
        } catch (e) {
            // InvokeExtensibilityMethod not available — use the BC action button to refresh
            console.warn('InvokeExtensibilityMethod not available:', e);
            isLoading = false;
            refBtn.disabled = false;
        }
    }

    // ── Sort & Filter ─────────────────────────────────────────────────────────
    function sorted(list) {
        return list.slice().sort(function (a, b) {
            if (sortMode === 'volume') return (Number(b.volume) || 0) - (Number(a.volume) || 0);
            if (sortMode === 'uncertain') {
                var pA = parseArr(a.outcomePrices).map(Number);
                var pB = parseArr(b.outcomePrices).map(Number);
                var mA = pA.length ? Math.max.apply(null, pA) : 0.5;
                var mB = pB.length ? Math.max.apply(null, pB) : 0.5;
                return Math.abs(mA - 0.5) - Math.abs(mB - 0.5); // closest to 50/50 first
            }
            if (sortMode === 'soon') return new Date(a.endDate || '9999') - new Date(b.endDate || '9999');
            return 0;
        });
    }

    function filtered(list) {
        var q = searchQuery.trim().toLowerCase();
        if (!q) return list;
        return list.filter(function (m) {
            return (m.question || '').toLowerCase().includes(q) ||
                   parseArr(m.tags).some(function (t) { return (t.label || t.slug || '').toLowerCase().includes(q); });
        });
    }

    // ── Render card ───────────────────────────────────────────────────────────
    function renderCard(m) {
        var outcomes = parseArr(m.outcomes);
        var prices   = parseArr(m.outcomePrices).map(Number);
        var tags     = parseArr(m.tags);

        var card = mk('div', { class: 'pm-card' });

        // ── Header ──
        var ch = mk('div', { class: 'pm-ch' });
        if (m.image) {
            var img = document.createElement('img');
            img.src = m.image; img.className = 'pm-img';
            img.onerror = function () { img.style.display = 'none'; };
            ch.appendChild(img);
        }
        var q = mk('div', { class: 'pm-q' }, m.question || '—');
        ch.appendChild(q);
        card.appendChild(ch);

        // ── Outcomes + prob bars ──
        if (outcomes.length && prices.length) {
            var outs = mk('div', { class: 'pm-outs' });
            var show = Math.min(outcomes.length, 4);
            for (var i = 0; i < show; i++) {
                var p = prices[i] || 0;
                var col = probColor(p);
                var out = mk('div', { class: 'pm-out' });

                var hdr = mk('div', { class: 'pm-out-hdr' });
                var lbl = mk('span', { class: 'pm-out-lbl' }, outcomes[i] || ('Opción ' + (i + 1)));
                var pctEl = mk('span', { class: 'pm-out-pct' }, (p * 100).toFixed(1) + '%');
                pctEl.style.color = col;
                hdr.append(lbl, pctEl);

                var track = mk('div', { class: 'pm-track' });
                var fill  = mk('div', { class: 'pm-fill' });
                fill.style.width = '0%'; // animate from 0
                fill.style.background = col;
                track.appendChild(fill);
                // Animate after paint
                setTimeout(function (f, pv) { f.style.width = (pv * 100).toFixed(1) + '%'; }, 80, fill, p);

                out.append(hdr, track);
                outs.appendChild(out);
            }
            if (outcomes.length > 4) {
                outs.appendChild(mk('div', { class: 'pm-mi' }, '+ ' + (outcomes.length - 4) + ' opciones más'));
            }
            card.appendChild(outs);
        }

        // ── Meta row ──
        var meta = mk('div', { class: 'pm-meta' });

        var liveW = mk('div', { class: 'pm-mi' });
        liveW.append(mk('div', { class: 'pm-dot' }), document.createTextNode(' En vivo'));
        meta.appendChild(liveW);

        if (m.volume) meta.appendChild(mk('div', { class: 'pm-mi' }, '\uD83D\uDCB0 ' + fmtVol(m.volume)));

        var dateStr = fmtDate(m.endDate);
        if (dateStr) {
            var dateEl = mk('div', { class: 'pm-mi' }, '\uD83D\uDCC5 ' + dateStr);
            if (dateStr.includes('hoy') || dateStr.includes('mañana')) dateEl.style.color = C.red;
            meta.appendChild(dateEl);
        }

        if (m.featured) meta.appendChild(mk('div', { class: 'pm-featured' }, '\u2605 Featured'));
        card.appendChild(meta);

        // ── Tags ──
        if (tags.length) {
            var tagsEl = mk('div', { class: 'pm-tags' });
            tags.slice(0, 5).forEach(function (t) {
                var lbl = (typeof t === 'string') ? t : (t.label || t.slug || '');
                if (lbl) tagsEl.appendChild(mk('span', { class: 'pm-tag' }, lbl));
            });
            card.appendChild(tagsEl);
        }

        return card;
    }

    // ── Grid render ───────────────────────────────────────────────────────────
    function render() {
        grid.innerHTML = '';
        var list = filtered(sorted(markets));
        stats.textContent = list.length + ' mercados';

        if (!list.length) {
            var empty = mk('div', { class: 'pm-center' });
            empty.textContent = searchQuery ? 'Sin resultados para "' + searchQuery + '"' : 'No hay mercados disponibles';
            grid.appendChild(empty);
            return;
        }
        // Use document fragment for performance
        var frag = document.createDocumentFragment();
        list.forEach(function (m) { frag.appendChild(renderCard(m)); });
        grid.appendChild(frag);
    }

    function showLoading() {
        grid.innerHTML = '';
        var c = mk('div', { class: 'pm-center' });
        c.append(mk('div', { class: 'pm-spinner' }), mk('div', {}, 'Cargando mercados en tiempo real\u2026'));
        grid.appendChild(c);
    }

    function showError(msg) {
        grid.innerHTML = '';
        var err = mk('div', { class: 'pm-err' });
        err.innerHTML = '<strong>\u26A0\uFE0F Error al cargar datos de PolyMarket</strong><br>' +
            msg + '<br><br>' +
            '<em>Nota: el navegador puede bloquear peticiones a APIs externas por políticas CORS. ' +
            'Si ocurre esto, considera configurar un proxy o usar la extensión en un entorno con acceso.</em>';
        grid.appendChild(err);
    }

    // ── Countdown / auto-refresh ──────────────────────────────────────────────
    function resetCountdown() {
        countdown = REFRESH_SEC;
        updateCountdown();
    }

    function updateCountdown() {
        cdEl.textContent = '\uD83D\uDD04 ' + countdown + 's';
        cdEl.className = countdown <= 6 ? 'hot' : '';
    }

    function startAutoRefresh() {
        if (refreshInterval) clearInterval(refreshInterval);
        refreshInterval = setInterval(function () {
            countdown--;
            updateCountdown();
            if (countdown <= 0) requestRefresh();
        }, 1000);
    }

    // ── Events ────────────────────────────────────────────────────────────────
    refBtn.addEventListener('click', requestRefresh);

    tagSel.addEventListener('change', function () {
        activeTag = tagSel.value;
        loadMarkets();
    });

    srtSel.addEventListener('change', function () {
        sortMode = srtSel.value;
        render();
    });

    search.addEventListener('input', function () {
        clearTimeout(searchDebounce);
        searchDebounce = setTimeout(function () {
            searchQuery = search.value;
            render();
        }, 280);
    });

    // ── Public API (called from AL) ───────────────────────────────────────────
    window.SetApiBase = function () {
        // Fetching is done server-side by AL HttpClient — no action needed here
    };

    window.Reload = function () {
        requestRefresh();
    };

    // ── Init ──────────────────────────────────────────────────────────────────
    // Calcula altura disponible basándose en la pantalla real del usuario.
    // BC con VerticalStretch=true mide scrollHeight una sola vez al cargar el script.
    // Al establecer la altura aquí (sincrónicamente) BC captura el valor correcto.
    (function applyDynamicHeight() {
        var screenH = (window.screen && window.screen.availHeight) ? window.screen.availHeight : 900;
        // Reste: barra BC (~50px) + título+acciones (~130px) + margen (~20px) = ~200px
        var gridH = Math.max(400, screenH - 200);
        var pmEl = document.getElementById('pm');
        var gridEl = document.getElementById('pm-grid');
        if (pmEl) pmEl.style.height = (gridH + 60) + 'px';
        if (gridEl) gridEl.style.height = gridH + 'px';
    }());

    // Guard against BC versions where AddInReady is not a function.
    try {
        Microsoft.Dynamics.NAV.AddInReady();
    } catch (e) { console.warn('NAV.AddInReady not available:', e); }

    showLoading(); // AL will push data via LoadTagsData / LoadMarketsData after ControlAddInReady
    updateCountdown();
    startAutoRefresh();

}());
