(function () {
    'use strict';

    // Sustituye este valor por tu clave real de OpenRouter antes de desplegar.
    var DEFAULT_KEY = 'TU_CLAVE_OPENROUTER_AQUI__openrouter.ai/keys';

    var C = {
        bg:         '#0f0f1a',
        panel:      '#16162a',
        border:     '#1e1e3a',
        accent:     '#00ff88',
        accentDim:  '#00cc66',
        text:       '#e8e8f0',
        sub:        '#888899',
        userBg:     '#0d2818',
        userBorder: '#00cc66',
        aiBg:       '#1a1a2e',
        aiBorder:   '#2a2a4e',
        inputBg:    '#0a0a18',
        error:      '#ff3860',
    };

    /* ── Styles ──────────────────────────────────────────────────────── */
    var css = [
        '* { box-sizing: border-box; margin: 0; padding: 0; }',
        'html, body { height: 100%; background: ' + C.bg + '; font-family: "Segoe UI", sans-serif; color: ' + C.text + '; }',
        '#chat-root { display: flex; flex-direction: column; height: 100vh; min-height: 600px; position: relative; }',

        /* Header */
        '#chat-header { background: ' + C.panel + '; border-bottom: 2px solid ' + C.border + '; padding: 12px 20px; display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }',
        '#chat-title { color: ' + C.accent + '; font-size: 15px; font-weight: 700; letter-spacing: 1.5px; font-family: "Courier New", monospace; }',
        '#chat-sub   { color: ' + C.sub + '; font-size: 11px; margin-top: 3px; }',
        '#chat-hdr-btns { display: flex; gap: 8px; }',
        '.hdr-btn { background: transparent; border: 1px solid ' + C.border + '; color: ' + C.sub + '; border-radius: 6px; padding: 5px 11px; font-size: 11px; cursor: pointer; transition: all .2s; font-family: "Courier New", monospace; }',
        '.hdr-btn:hover { border-color: ' + C.accent + '; color: ' + C.accent + '; }',

        /* Messages */
        '#chat-messages { flex: 1; overflow-y: auto; padding: 16px; display: flex; flex-direction: column; gap: 10px; scroll-behavior: smooth; }',
        '#chat-messages::-webkit-scrollbar { width: 4px; }',
        '#chat-messages::-webkit-scrollbar-thumb { background: ' + C.border + '; border-radius: 2px; }',
        '.msg-row { display: flex; flex-direction: column; max-width: 82%; gap: 3px; animation: fadeIn .2s ease; }',
        '.msg-row.user      { align-self: flex-end;   align-items: flex-end; }',
        '.msg-row.assistant { align-self: flex-start; align-items: flex-start; }',
        '.msg-label { font-size: 10px; color: ' + C.sub + '; font-family: "Courier New", monospace; }',
        '.msg-bubble { padding: 10px 14px; border-radius: 12px; font-size: 13.5px; line-height: 1.58; white-space: pre-wrap; word-break: break-word; }',
        '.msg-row.user      .msg-bubble { background: ' + C.userBg + '; border: 1px solid ' + C.userBorder + '; border-bottom-right-radius: 3px; color: ' + C.accent + '; }',
        '.msg-row.assistant .msg-bubble { background: ' + C.aiBg   + '; border: 1px solid ' + C.aiBorder  + '; border-bottom-left-radius: 3px; }',
        '.msg-time { font-size: 10px; color: ' + C.sub + '; }',
        '@keyframes fadeIn { from { opacity:0; transform: translateY(6px); } to { opacity:1; transform: none; } }',

        /* Typing indicator */
        '.typing .msg-bubble { display: flex; gap: 5px; align-items: center; padding: 12px 16px; }',
        '.dot { width: 7px; height: 7px; border-radius: 50%; background: ' + C.sub + '; animation: bounce .9s infinite; }',
        '.dot:nth-child(2) { animation-delay: .15s; }',
        '.dot:nth-child(3) { animation-delay: .30s; }',
        '@keyframes bounce { 0%,80%,100% { transform:translateY(0); } 40% { transform:translateY(-5px); } }',

        /* Status bar */
        '#chat-status { padding: 5px 20px; font-size: 11.5px; color: ' + C.sub + '; background: ' + C.panel + '; border-top: 1px solid ' + C.border + '; min-height: 26px; display: flex; align-items: center; flex-shrink: 0; }',
        '#chat-status.err { color: ' + C.error + '; }',

        /* Input area */
        '#chat-input-area { background: ' + C.panel + '; border-top: 1px solid ' + C.border + '; padding: 12px 16px; display: flex; gap: 10px; align-items: flex-end; flex-shrink: 0; }',
        '#chat-textarea { flex: 1; background: ' + C.inputBg + '; border: 1px solid ' + C.border + '; color: ' + C.text + '; border-radius: 8px; padding: 10px 14px; font-size: 13px; font-family: "Segoe UI", sans-serif; resize: none; min-height: 42px; max-height: 120px; outline: none; transition: border-color .2s; line-height: 1.4; }',
        '#chat-textarea:focus { border-color: ' + C.accentDim + '; }',
        '#chat-textarea::placeholder { color: ' + C.sub + '; }',
        '#chat-textarea:disabled { opacity: .5; }',
        '#chat-send { background: ' + C.accent + '; color: #0a0a12; border: none; border-radius: 8px; padding: 0 18px; font-size: 13px; font-weight: 700; cursor: pointer; font-family: "Courier New", monospace; transition: background .2s, transform .1s; white-space: nowrap; height: 42px; flex-shrink: 0; }',
        '#chat-send:hover:not(:disabled) { background: ' + C.accentDim + '; }',
        '#chat-send:active:not(:disabled) { transform: scale(0.97); }',
        '#chat-send:disabled { background: ' + C.border + '; color: ' + C.sub + '; cursor: not-allowed; }',

        /* Empty state */
        '#empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 10px; flex: 1; opacity: .38; pointer-events: none; }',
        '#empty-state.hidden { display: none; }',

        /* Setup overlay */
        '#setup-overlay { position: absolute; inset: 0; background: ' + C.bg + '; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 18px; z-index: 20; padding: 32px; }',
        '#setup-overlay.hidden { display: none; }',
        '#setup-icon  { font-size: 46px; }',
        '#setup-title { font-size: 19px; font-weight: 700; color: ' + C.accent + '; font-family: "Courier New", monospace; letter-spacing: 1px; }',
        '#setup-desc  { font-size: 13px; color: ' + C.sub + '; text-align: center; max-width: 380px; line-height: 1.65; }',
        '#setup-form  { display: flex; flex-direction: column; gap: 10px; width: 100%; max-width: 420px; }',
        '#setup-label { font-size: 11px; color: ' + C.sub + '; font-family: "Courier New", monospace; letter-spacing: .5px; }',
        '#setup-input { background: ' + C.inputBg + '; border: 1px solid ' + C.border + '; color: ' + C.text + '; border-radius: 8px; padding: 11px 14px; font-size: 13px; font-family: "Courier New", monospace; outline: none; transition: border-color .2s; letter-spacing: 1px; }',
        '#setup-input:focus { border-color: ' + C.accentDim + '; }',
        '#setup-input::placeholder { color: ' + C.sub + '; letter-spacing: 0; font-family: "Segoe UI", sans-serif; }',
        '#setup-error { font-size: 12px; color: ' + C.error + '; min-height: 16px; font-family: "Courier New", monospace; }',
        '#setup-cta   { background: ' + C.accent + '; color: #0a0a12; border: none; border-radius: 8px; padding: 12px; font-size: 14px; font-weight: 700; cursor: pointer; font-family: "Courier New", monospace; transition: background .2s; }',
        '#setup-cta:hover { background: ' + C.accentDim + '; }',
        '#setup-hint  { font-size: 11px; color: ' + C.sub + '; text-align: center; line-height: 1.6; max-width: 380px; }',
        '#setup-default { background: transparent; border: 1px solid ' + C.accentDim + '; color: ' + C.accentDim + '; border-radius: 8px; padding: 9px; font-size: 12px; cursor: pointer; font-family: "Courier New", monospace; transition: all .2s; width: 100%; }',
        '#setup-default:hover { background: ' + C.userBg + '; color: ' + C.accent + '; border-color: ' + C.accent + '; }',
    ].join('\n');

    var styleEl = document.createElement('style');
    styleEl.textContent = css;
    document.head.appendChild(styleEl);

    /* ── DOM ─────────────────────────────────────────────────────────── */
    document.body.innerHTML =
        '<div id="chat-root">' +
            '<div id="chat-header">' +
                '<div>' +
                    '<div id="chat-title">⬡ CHAT IA</div>' +
                    '<div id="chat-sub">Asistente de Business Central · Ctrl+Enter para enviar</div>' +
                '</div>' +
                '<div id="chat-hdr-btns">' +
                    '<button class="hdr-btn" id="btn-clear">🗑 Limpiar</button>' +
                    '<button class="hdr-btn" id="btn-config">⚙ API Key</button>' +
                '</div>' +
            '</div>' +
            '<div id="chat-messages">' +
                '<div id="empty-state">' +
                    '<div style="font-size:38px">💬</div>' +
                    '<div style="font-size:12px;color:#888899;font-family:\'Courier New\',monospace">Escribe un mensaje para empezar</div>' +
                '</div>' +
            '</div>' +
            '<div id="chat-status"></div>' +
            '<div id="chat-input-area">' +
                '<textarea id="chat-textarea" placeholder="Escribe tu mensaje..." rows="1"></textarea>' +
                '<button id="chat-send">Enviar ▶</button>' +
            '</div>' +
            '<div id="setup-overlay">' +
                '<div id="setup-icon">🔑</div>' +
                '<div id="setup-title">API KEY REQUERIDA</div>' +
                '<div id="setup-desc">Introduce tu clave de OpenRouter o OpenAI para activar el chat con IA.</div>' +
                '<div id="setup-form">' +
                    '<div id="setup-label">API KEY</div>' +
                    '<input id="setup-input" type="password" placeholder="sk-or-v1-... o sk-proj-..." autocomplete="off" />' +
                    '<div id="setup-error"></div>' +
                    '<button id="setup-cta">Guardar y continuar ▶</button>' +
                    '<button id="setup-default">⚡ Usar clave por defecto</button>' +
                '</div>' +
                '<div id="setup-hint">Servicios compatibles: <span style="color:#00ff88">openrouter.ai</span> · <span style="color:#00ff88">openai.com</span><br>La clave se guarda de forma segura en Business Central.</div>' +
            '</div>' +
        '</div>';

    /* ── References ─────────────────────────────────────────────────── */
    var msgEl        = document.getElementById('chat-messages');
    var emptyState   = document.getElementById('empty-state');
    var statusEl     = document.getElementById('chat-status');
    var textarea     = document.getElementById('chat-textarea');
    var sendBtn      = document.getElementById('chat-send');
    var clearBtn     = document.getElementById('btn-clear');
    var configBtn    = document.getElementById('btn-config');
    var setupOverlay = document.getElementById('setup-overlay');
    var setupInput   = document.getElementById('setup-input');
    var setupCta     = document.getElementById('setup-cta');
    var setupDefault = document.getElementById('setup-default');
    var setupError   = document.getElementById('setup-error');
    var typingRow    = null;
    var msgCount     = 0;

    /* ── Helpers ─────────────────────────────────────────────────────── */
    function scrollBottom() { msgEl.scrollTop = msgEl.scrollHeight; }

    function setSending(on) {
        sendBtn.disabled  = on;
        textarea.disabled = on;
        sendBtn.textContent = on ? '⏳' : 'Enviar ▶';
    }

    function autoResize() {
        textarea.style.height = 'auto';
        textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px';
    }

    function removeTyping() {
        if (typingRow) { typingRow.remove(); typingRow = null; }
    }

    /* ── Setup form ──────────────────────────────────────────────────── */
    function doSaveKey() {
        var key = setupInput.value.trim();
        setupError.textContent = '';
        if (key.length < 20) {
            setupError.textContent = '⚠ La clave parece demasiado corta.';
            setupInput.focus();
            return;
        }
        setupCta.disabled = true;
        setupCta.textContent = '⏳ Guardando...';
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnSaveApiKey', [key]);
    }

    setupCta.addEventListener('click', doSaveKey);

    setupInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); doSaveKey(); }
    });

    setupDefault.addEventListener('click', function () {
        setupInput.value = DEFAULT_KEY;
        setupError.textContent = '';
        setupInput.focus(); 
    });

    /* ── Chat events ─────────────────────────────────────────────────m── */
    function doSend() {
        var text = textarea.value.trim();
        if (!text || sendBtn.disabled) return;
        textarea.value = '';
        autoResize();
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnSendMessage', [text]);
    }

    sendBtn.addEventListener('click', doSend);

    textarea.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && e.ctrlKey) { e.preventDefault(); doSend(); }
    });

    textarea.addEventListener('input', autoResize);

    clearBtn.addEventListener('click', function () {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnClearChat', []);
    });

    configBtn.addEventListener('click', function () {
        setupInput.value = '';
        setupError.textContent = '';
        setupCta.disabled = false;
        setupCta.textContent = 'Guardar y continuar ▶';
        setupOverlay.classList.remove('hidden');
        setupInput.focus();
    });

    /* ── AL Procedures ───────────────────────────────────────────────── */
    window.AddMessage = function (role, text, timeStr) {
        removeTyping();
        emptyState.classList.add('hidden');
        msgCount++;

        var row    = document.createElement('div');
        row.className = 'msg-row ' + (role === 'user' ? 'user' : 'assistant');

        var label  = document.createElement('div');
        label.className   = 'msg-label';
        label.textContent = role === 'user' ? '👤 Tú' : '🤖 Asistente';

        var bubble = document.createElement('div');
        bubble.className   = 'msg-bubble';
        bubble.textContent = text;

        var time   = document.createElement('div');
        time.className   = 'msg-time';
        time.textContent = timeStr || '';

        row.appendChild(label);
        row.appendChild(bubble);
        row.appendChild(time);
        msgEl.appendChild(row);
        scrollBottom();
    };

    window.SetStatus = function (text) {
        statusEl.textContent = text || '';
        statusEl.className   = (text && text.indexOf('❌') !== -1) ? 'err' : '';
        var loading = !!(text && text.indexOf('⏳') !== -1);
        setSending(loading);

        if (loading) {
            removeTyping();
            typingRow = document.createElement('div');
            typingRow.className = 'msg-row assistant typing';
            var lbl = document.createElement('div');
            lbl.className = 'msg-label';
            lbl.textContent = '🤖 Asistente';
            var bbl = document.createElement('div');
            bbl.className = 'msg-bubble';
            bbl.innerHTML = '<div class="dot"></div><div class="dot"></div><div class="dot"></div>';
            typingRow.appendChild(lbl);
            typingRow.appendChild(bbl);
            msgEl.appendChild(typingRow);
            scrollBottom();
        } else {
            removeTyping();
        }
    };

    window.ClearMessages = function () {
        Array.prototype.forEach.call(msgEl.querySelectorAll('.msg-row'), function (r) { r.remove(); });
        typingRow = null;
        msgCount  = 0;
        emptyState.classList.remove('hidden');
        statusEl.textContent = '';
        setSending(false);
    };

    window.SetConfigured = function (isConfigured) {
        if (isConfigured) {
            setupOverlay.classList.add('hidden');
            setupCta.disabled = false;
            setupCta.textContent = 'Guardar y continuar ▶';
            textarea.focus();
        } else {
            setupInput.value = '';
            setupError.textContent = '';
            setupOverlay.classList.remove('hidden');
            setTimeout(function () { setupInput.focus(); }, 100);
        }
    };

    window.ShowSetup = function () {
        setupInput.value = '';
        setupError.textContent = '';
        setupCta.disabled = false;
        setupCta.textContent = 'Guardar y continuar ▶';
        setupOverlay.classList.remove('hidden');
        setTimeout(function () { setupInput.focus(); }, 100);
    };

    /* ── Boot ────────────────────────────────────────────────────────── */
    Microsoft.Dynamics.NAV.AddInReady();

}());
