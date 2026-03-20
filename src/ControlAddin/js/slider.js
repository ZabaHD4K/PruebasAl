(function () {
    'use strict';

    /* ── Estilos ─────────────────────────────────────────────────────────── */
    var style = document.createElement('style');
    style.textContent = [
        'body { margin:0; font-family: "Segoe UI", sans-serif; background: transparent; display:flex; align-items:center; justify-content:center; height:100%; }',
        '#sc-wrap { width:90%; max-width:600px; display:flex; flex-direction:column; align-items:center; gap:12px; padding:16px 0; }',
        '#sc-value { font-size:2.8em; font-weight:700; transition:color .25s; }',
        '#sc-rank  { font-size:1.1em; opacity:.85; transition:opacity .2s; }',
        '#sc-slider {',
        '  -webkit-appearance:none; appearance:none;',
        '  width:100%; height:10px; border-radius:5px; outline:none; cursor:pointer;',
        '  background: linear-gradient(to right, var(--fill,#3b82f6) 0%, var(--fill,#3b82f6) var(--pct,50%), #d1d5db var(--pct,50%), #d1d5db 100%);',
        '  transition: background .15s;',
        '}',
        '#sc-slider::-webkit-slider-thumb {',
        '  -webkit-appearance:none; width:24px; height:24px; border-radius:50%;',
        '  background:#fff; border:3px solid var(--fill,#3b82f6); cursor:pointer;',
        '  box-shadow:0 2px 6px rgba(0,0,0,.25); transition:border-color .25s;',
        '}',
        '#sc-slider::-moz-range-thumb {',
        '  width:24px; height:24px; border-radius:50%;',
        '  background:#fff; border:3px solid var(--fill,#3b82f6); cursor:pointer;',
        '  box-shadow:0 2px 6px rgba(0,0,0,.25); transition:border-color .25s;',
        '}',
        '#sc-saving { font-size:.85em; color:#6b7280; min-height:1.2em; transition:opacity .3s; }'
    ].join('\n');
    document.head.appendChild(style);

    /* ── DOM ─────────────────────────────────────────────────────────────── */
    var wrap    = el('div',   { id: 'sc-wrap' });
    var valLbl  = el('div',   { id: 'sc-value' }, '—');
    var slider  = el('input', { id: 'sc-slider', type: 'range', min: '0', max: '2000', value: '0', step: '1' });
    var rankLbl = el('div',   { id: 'sc-rank'  }, '');
    var saveLbl = el('div',   { id: 'sc-saving'}, '');
    wrap.appendChild(valLbl);
    wrap.appendChild(slider);
    wrap.appendChild(rankLbl);
    wrap.appendChild(saveLbl);
    document.body.appendChild(wrap);

    /* ── Helpers ─────────────────────────────────────────────────────────── */
    function el(tag, attrs, text) {
        var node = document.createElement(tag);
        if (attrs) Object.keys(attrs).forEach(function (k) { node.setAttribute(k, attrs[k]); });
        if (text !== undefined) node.textContent = text;
        return node;
    }

    function rankOf(v) {
        if (v >= 1500) return { text: '🟢 Ciudadano Ejemplar', color: '#16a34a' };
        if (v >= 1000) return { text: '🔵 Ciudadano Normal',   color: '#2563eb' };
        if (v >= 500)  return { text: '🟡 Bajo Supervisión',   color: '#d97706' };
        return               { text: '🔴 Lista Negra',          color: '#dc2626' };
    }

    function updateUI(v) {
        var pct  = (v / 2000 * 100).toFixed(2) + '%';
        var rank = rankOf(v);
        valLbl.textContent  = v;
        rankLbl.textContent = rank.text;
        valLbl.style.color  = rank.color;
        slider.style.setProperty('--fill', rank.color);
        slider.style.setProperty('--pct',  pct);
    }

    /* ── Eventos del slider ──────────────────────────────────────────────── */
    slider.addEventListener('input', function () {
        updateUI(parseInt(slider.value, 10));
        saveLbl.textContent = '';
    });

    var saveTimer = null;
    slider.addEventListener('change', function () {
        // Auto-save al soltar (debounce 200ms por si hay drag rápido)
        clearTimeout(saveTimer);
        saveLbl.textContent = '⏳ Guardando...';
        saveTimer = setTimeout(function () {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnValueChanged', [parseInt(slider.value, 10)]);
            saveLbl.textContent = '✅ Guardado';
            setTimeout(function () { saveLbl.textContent = ''; }, 1800);
        }, 200);
    });

    /* ── API expuesta a AL ───────────────────────────────────────────────── */
    // AL llama a SetValue(n) para inicializar/actualizar el slider
    window.SetValue = function (newValue) {
        var v = parseInt(newValue, 10) || 0;
        slider.value = v;
        updateUI(v);
    };

    /* ── Listo ───────────────────────────────────────────────────────────── */
    updateUI(0);
    Microsoft.Dynamics.NAV.AddInReady();
}());
