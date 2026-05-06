(function () {
    'use strict';

    var C = {
        bg:        '#0f0f1a',
        panel:     '#16162a',
        border:    '#1e1e3a',
        accent:    '#00ff88',
        accentDim: '#00cc66',
        text:      '#e8e8f0',
        sub:       '#888899',
        cardBg:    '#13131f',
        cardHover: '#1a1a2e',
        cardGlow:  'rgba(0,255,136,0.12)',
    };

    var SC_CARDS = [
        { target: 'adjust',      icon: '✏️',  title: 'Ajustar Puntos',    desc: 'Ajuste manual con motivo y log' },
        { target: 'history',     icon: '📋',  title: 'Historial',         desc: 'Log completo de cambios' },
        { target: 'report',      icon: '📊',  title: 'Informe',           desc: 'Puntuaciones de todos los clientes' },
        { target: 'customers',   icon: '👥',  title: 'Clientes SC',       desc: 'Lista oscura con rangos y puntos' },
        { target: 'chat',        icon: '🤖',  title: 'Chat IA',           desc: 'Asistente con inteligencia artificial' },
        { target: 'slider',      icon: '🎚️', title: 'Slider',            desc: 'Ajuste interactivo con slider JS' },
        { target: 'polymarket',  icon: '📈',  title: 'PolyMarket',        desc: 'Mercados de predicción en tiempo real' },
        { target: 'importexport',icon: '📦',  title: 'Import / Export',   desc: 'CSV, XML, JSON y Excel' },
        { target: 'snake',       icon: '🐍',  title: 'Snake',             desc: 'El clásico juego integrado en BC' },
        { target: 'pysnake',     icon: '🖥️', title: 'PySnake',           desc: 'Snake estilo terminal Python curses' },
        { target: 'spaceinvaders',icon: '👾', title: 'Space Invaders',    desc: 'El clásico arcade integrado en BC' },
        { target: 'ej1task',     icon: '✅',  title: 'Tareas EJ1',        desc: 'Gestión básica de tareas con estados' },
        { target: 'ej2lista',    icon: '📋',  title: 'Tareas EJ2',        desc: 'Tareas con cabecera, líneas y horas' },
        { target: 'ej7lista',    icon: '🏠',  title: 'Clientes Locales',  desc: 'Tabla local con relación a clientes BC' },
    ];

    var BC_CARDS = [
        { target: 'customerlist', icon: '👥', title: 'Lista Clientes',   desc: 'Columnas SC añadidas' },
        { target: 'customercard', icon: '👤', title: 'Ficha Cliente',    desc: 'FactBox y acciones SC' },
        { target: 'salesorder',   icon: '📝', title: 'Pedidos',          desc: 'Validación SC al seleccionar cliente' },
        { target: 'salesquote',   icon: '💬', title: 'Ofertas',          desc: 'Validación SC' },
        { target: 'salesinvoice', icon: '🧾', title: 'Facturas',         desc: 'Validación SC' },
        { target: 'salescrmemo',  icon: '↩️', title: 'Abonos',           desc: 'Validación SC' },
        { target: 'vendors',      icon: '🏭', title: 'Proveedores',      desc: 'Acción de exportación añadida' },
        { target: 'items',        icon: '📦', title: 'Productos',        desc: 'Acción de exportación añadida' },
    ];

    /* ── Styles ──────────────────────────────────────────────────────── */
    var css = [
        '* { box-sizing: border-box; margin: 0; padding: 0; }',
        'html, body { height: 100%; background: ' + C.bg + '; font-family: "Segoe UI", sans-serif; color: ' + C.text + '; }',
        '#hub-root { display: flex; flex-direction: column; height: 100vh; min-height: 600px; overflow: hidden; }',

        '#hub-header { background: ' + C.panel + '; border-bottom: 2px solid ' + C.border + '; padding: 14px 24px; display: flex; align-items: center; gap: 16px; flex-shrink: 0; }',
        '#hub-logo   { font-size: 28px; }',
        '#hub-title  { color: ' + C.accent + '; font-size: 17px; font-weight: 700; letter-spacing: 2px; font-family: "Courier New", monospace; }',
        '#hub-sub    { color: ' + C.sub + '; font-size: 11px; margin-top: 3px; }',

        '#hub-body   { flex: 1; overflow-y: auto; padding: 24px; display: flex; flex-direction: column; gap: 28px; }',
        '#hub-body::-webkit-scrollbar { width: 4px; }',
        '#hub-body::-webkit-scrollbar-thumb { background: ' + C.border + '; border-radius: 2px; }',

        '.section-title { font-size: 11px; font-weight: 700; letter-spacing: 2px; color: ' + C.sub + '; font-family: "Courier New", monospace; margin-bottom: 12px; text-transform: uppercase; border-left: 3px solid ' + C.accent + '; padding-left: 10px; }',

        '.card-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 12px; }',

        '.card { background: ' + C.cardBg + '; border: 1px solid ' + C.border + '; border-radius: 10px; padding: 16px 14px; cursor: pointer; transition: all .2s; display: flex; flex-direction: column; gap: 8px; user-select: none; }',
        '.card:hover { background: ' + C.cardHover + '; border-color: ' + C.accentDim + '; box-shadow: 0 0 18px ' + C.cardGlow + '; transform: translateY(-2px); }',
        '.card:active { transform: translateY(0); }',
        '.card-icon  { font-size: 24px; }',
        '.card-title { font-size: 13px; font-weight: 700; color: ' + C.text + '; font-family: "Courier New", monospace; }',
        '.card-desc  { font-size: 11px; color: ' + C.sub + '; line-height: 1.5; }',
    ].join('\n');

    var styleEl = document.createElement('style');
    styleEl.textContent = css;
    document.head.appendChild(styleEl);

    /* ── DOM ─────────────────────────────────────────────────────────── */
    document.body.innerHTML =
        '<div id="hub-root">' +
            '<div id="hub-header">' +
                '<div id="hub-logo">⬡</div>' +
                '<div>' +
                    '<div id="hub-title">SOCIAL CREDIT</div>' +
                    '<div id="hub-sub">Centro de extensión — Business Central</div>' +
                '</div>' +
            '</div>' +
            '<div id="hub-body">' +
                '<div>' +
                    '<div class="section-title">Páginas de Social Credit</div>' +
                    '<div class="card-grid" id="sc-grid"></div>' +
                '</div>' +
                '<div>' +
                    '<div class="section-title">Páginas de BC modificadas</div>' +
                    '<div class="card-grid" id="bc-grid"></div>' +
                '</div>' +
            '</div>' +
        '</div>';

    /* ── Build cards ─────────────────────────────────────────────────── */
    function buildCards(cards, gridId) {
        var grid = document.getElementById(gridId);
        cards.forEach(function (c) {
            var card = document.createElement('div');
            card.className = 'card';
            card.innerHTML =
                '<div class="card-icon">' + c.icon + '</div>' +
                '<div class="card-title">' + c.title + '</div>' +
                '<div class="card-desc">' + c.desc + '</div>';
            card.addEventListener('click', function () {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnNavigate', [c.target]);
            });
            grid.appendChild(card);
        });
    }

    buildCards(SC_CARDS, 'sc-grid');
    buildCards(BC_CARDS, 'bc-grid');

    Microsoft.Dynamics.NAV.AddInReady();

}());
