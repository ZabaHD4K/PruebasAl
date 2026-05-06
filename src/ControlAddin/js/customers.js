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
        inputBg:   '#0a0a18',
        rowHover:  '#1a1a2e',
        error:     '#ff3860',
        r0:        '#dc2626',
        r1:        '#d97706',
        r2:        '#2563eb',
        r3:        '#16a34a',
    };

    var css = [
        '* { box-sizing: border-box; margin: 0; padding: 0; }',
        'html, body { height: 100%; background: ' + C.bg + '; font-family: "Segoe UI", sans-serif; color: ' + C.text + '; }',
        '#root { display: flex; flex-direction: column; height: 100vh; min-height: 600px; }',

        '#header { background: ' + C.panel + '; border-bottom: 2px solid ' + C.border + '; padding: 12px 20px; display: flex; align-items: center; gap: 12px; flex-shrink: 0; }',
        '#header-title { color: ' + C.accent + '; font-size: 15px; font-weight: 700; letter-spacing: 1.5px; font-family: "Courier New", monospace; flex: 1; }',
        '#search { background: ' + C.inputBg + '; border: 1px solid ' + C.border + '; color: ' + C.text + '; border-radius: 6px; padding: 7px 12px; font-size: 12px; outline: none; width: 200px; transition: border-color .2s; }',
        '#search:focus { border-color: ' + C.accentDim + '; }',
        '#search::placeholder { color: ' + C.sub + '; }',
        '#refresh { background: transparent; border: 1px solid ' + C.border + '; color: ' + C.sub + '; border-radius: 6px; padding: 7px 12px; font-size: 12px; cursor: pointer; font-family: "Courier New", monospace; transition: all .2s; }',
        '#refresh:hover { border-color: ' + C.accent + '; color: ' + C.accent + '; }',

        '#status { padding: 5px 20px; font-size: 11.5px; color: ' + C.sub + '; background: ' + C.panel + '; border-bottom: 1px solid ' + C.border + '; min-height: 26px; display: flex; align-items: center; flex-shrink: 0; }',

        '#table-wrap { flex: 1; overflow-y: auto; }',
        '#table-wrap::-webkit-scrollbar { width: 4px; }',
        '#table-wrap::-webkit-scrollbar-thumb { background: ' + C.border + '; border-radius: 2px; }',

        'table { width: 100%; border-collapse: collapse; }',
        'thead th { background: ' + C.panel + '; color: ' + C.sub + '; font-size: 10px; font-family: "Courier New", monospace; letter-spacing: 1px; text-transform: uppercase; padding: 10px 14px; text-align: left; position: sticky; top: 0; border-bottom: 1px solid ' + C.border + '; cursor: pointer; user-select: none; }',
        'thead th:hover { color: ' + C.accent + '; }',
        'tbody tr { border-bottom: 1px solid ' + C.border + '; cursor: pointer; transition: background .15s; }',
        'tbody tr:hover { background: ' + C.rowHover + '; }',
        'tbody td { padding: 10px 14px; font-size: 13px; }',
        '.td-no    { color: ' + C.sub + '; font-family: "Courier New", monospace; font-size: 11px; width: 80px; }',
        '.td-name  { font-weight: 500; }',
        '.td-pts   { font-family: "Courier New", monospace; font-weight: 700; text-align: right; width: 80px; }',
        '.td-label { width: 160px; }',
        '.rank-badge { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-family: "Courier New", monospace; font-weight: 600; }',
        '.r3 { background: rgba(22,163,74,.18);  color: ' + C.r3 + '; border: 1px solid rgba(22,163,74,.3); }',
        '.r2 { background: rgba(37,99,235,.18);  color: ' + C.r2 + '; border: 1px solid rgba(37,99,235,.3); }',
        '.r1 { background: rgba(217,119,6,.18);  color: ' + C.r1 + '; border: 1px solid rgba(217,119,6,.3); }',
        '.r0 { background: rgba(220,38,38,.18);  color: ' + C.r0 + '; border: 1px solid rgba(220,38,38,.3); }',
        '.dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 6px; flex-shrink: 0; }',
        '.empty { display: flex; align-items: center; justify-content: center; height: 200px; color: ' + C.sub + '; font-size: 13px; font-family: "Courier New", monospace; opacity: .5; }',
    ].join('\n');

    document.head.appendChild(Object.assign(document.createElement('style'), { textContent: css }));

    document.body.innerHTML =
        '<div id="root">' +
            '<div id="header">' +
                '<div id="header-title">👥 CLIENTES — SOCIAL CREDIT</div>' +
                '<input id="search" placeholder="🔍 Buscar..." />' +
                '<button id="refresh">↻ Recargar</button>' +
            '</div>' +
            '<div id="status">⏳ Cargando clientes...</div>' +
            '<div id="table-wrap">' +
                '<table>' +
                    '<thead>' +
                        '<tr>' +
                            '<th data-col="no">Nº</th>' +
                            '<th data-col="name">Nombre</th>' +
                            '<th data-col="points">Puntos ↕</th>' +
                            '<th data-col="label">Estado</th>' +
                        '</tr>' +
                    '</thead>' +
                    '<tbody id="tbody"></tbody>' +
                '</table>' +
            '</div>' +
        '</div>';

    var tbodyEl  = document.getElementById('tbody');
    var searchEl = document.getElementById('search');
    var statusEl = document.getElementById('status');
    var refreshEl = document.getElementById('refresh');

    var allRows  = [];
    var sortCol  = 'points';
    var sortAsc  = false;

    /* ── Helpers ─────────────────────────────────────────────────────── */
    function rankClass(pts) {
        if (pts >= 1500) return 'r3';
        if (pts >= 1000) return 'r2';
        if (pts >= 500)  return 'r1';
        return 'r0';
    }

    function rankLabel(pts) {
        if (pts >= 1500) return '🟢 Ejemplar';
        if (pts >= 1000) return '🔵 Normal';
        if (pts >= 500)  return '🟡 Supervisión';
        return '🔴 Lista Negra';
    }

    function dotColor(pts) {
        if (pts >= 1500) return C.r3;
        if (pts >= 1000) return C.r2;
        if (pts >= 500)  return C.r1;
        return C.r0;
    }

    function render() {
        var q = searchEl.value.trim().toLowerCase();
        var rows = allRows.filter(function (r) {
            return !q || r.no.toLowerCase().indexOf(q) !== -1 || r.name.toLowerCase().indexOf(q) !== -1;
        });

        rows.sort(function (a, b) {
            var av = sortCol === 'points' ? a.points : (a[sortCol] || '').toString().toLowerCase();
            var bv = sortCol === 'points' ? b.points : (b[sortCol] || '').toString().toLowerCase();
            if (av < bv) return sortAsc ? -1 : 1;
            if (av > bv) return sortAsc ? 1 : -1;
            return 0;
        });

        tbodyEl.innerHTML = '';

        if (rows.length === 0) {
            tbodyEl.innerHTML = '<tr><td colspan="4"><div class="empty">Sin resultados</div></td></tr>';
            return;
        }

        rows.forEach(function (r) {
            var rc = rankClass(r.points);
            var tr = document.createElement('tr');
            tr.innerHTML =
                '<td class="td-no">' + escHtml(r.no) + '</td>' +
                '<td class="td-name">' +
                    '<span class="dot" style="background:' + dotColor(r.points) + '"></span>' +
                    escHtml(r.name) +
                '</td>' +
                '<td class="td-pts" style="color:' + dotColor(r.points) + '">' + r.points + '</td>' +
                '<td class="td-label"><span class="rank-badge ' + rc + '">' + rankLabel(r.points) + '</span></td>';
            tr.addEventListener('click', function () {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnOpenCustomer', [r.no]);
            });
            tbodyEl.appendChild(tr);
        });

        statusEl.textContent = rows.length + ' cliente' + (rows.length !== 1 ? 's' : '') +
            (q ? ' (filtrado de ' + allRows.length + ')' : '');
    }

    function escHtml(s) {
        return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    /* ── Events ──────────────────────────────────────────────────────── */
    searchEl.addEventListener('input', render);

    refreshEl.addEventListener('click', function () {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnReady', []);
    });

    document.querySelectorAll('thead th').forEach(function (th) {
        th.addEventListener('click', function () {
            var col = th.getAttribute('data-col');
            if (sortCol === col) sortAsc = !sortAsc;
            else { sortCol = col; sortAsc = col !== 'points'; }
            render();
        });
    });

    /* ── AL Procedures ───────────────────────────────────────────────── */
    window.LoadCustomers = function (json) {
        try {
            allRows = JSON.parse(json);
        } catch (e) {
            allRows = [];
        }
        render();
    };

    window.SetStatus = function (text) {
        statusEl.textContent = text || '';
    };

    Microsoft.Dynamics.NAV.AddInReady();

}());
