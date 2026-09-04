/* SeederLinux Lite — tema Solar (JS da página pública) */
(function () {
    'use strict';

    /* ---- Alternância claro/escuro (mesma chave dos demais temas) ---- */
    function currentTheme() {
        return localStorage.getItem('seederlinux-theme') || 'dark';
    }
    function applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        var isLight = theme === 'light';
        document.querySelectorAll('.theme-toggle .icon-moon').forEach(function (el) { el.classList.toggle('hidden', isLight); });
        document.querySelectorAll('.theme-toggle .icon-sun').forEach(function (el) { el.classList.toggle('hidden', !isLight); });
    }
    window.toggleTheme = function () {
        var next = currentTheme() === 'dark' ? 'light' : 'dark';
        localStorage.setItem('seederlinux-theme', next);
        applyTheme(next);
    };
    applyTheme(currentTheme());

    /* ---- Menu mobile ---- */
    var menuToggle = document.querySelector('.menu-toggle');
    var mainNav = document.getElementById('main-nav');
    if (menuToggle && mainNav) {
        menuToggle.addEventListener('click', function () {
            var open = mainNav.classList.toggle('open');
            menuToggle.classList.toggle('open', open);
            menuToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        });
    }

    /* ---- Bundles públicos (mesma API dos outros temas) ---- */
    function escapeHtml(value) {
        var div = document.createElement('div');
        div.textContent = value == null ? '' : String(value);
        return div.innerHTML;
    }
    function setState(message) {
        var status = document.getElementById('bundle-status');
        var tbody = document.getElementById('bundles-tbody');
        if (status) status.textContent = message;
        if (tbody) tbody.innerHTML = '<tr><td colspan="6" class="table-state">' + escapeHtml(message) + '</td></tr>';
    }
    function render(bundles) {
        var tbody = document.getElementById('bundles-tbody');
        var status = document.getElementById('bundle-status');
        var statBundles = document.getElementById('stat-bundles');
        var statUpdated = document.getElementById('stat-updated');
        if (statBundles) statBundles.textContent = bundles.length;
        var latest = bundles
            .map(function (b) { return new Date(b.generated_at); })
            .filter(function (d) { return !Number.isNaN(d.getTime()); })
            .sort(function (a, b) { return b - a; })[0];
        if (statUpdated) statUpdated.textContent = latest ? latest.toLocaleDateString('pt-BR') : '-';
        if (!tbody) return;
        if (!bundles.length) {
            setState('Nenhum bundle publicado ainda. Gere o primeiro no painel.');
            return;
        }
        if (status) status.textContent = bundles.length + (bundles.length === 1 ? ' publicado' : ' publicados');
        var fmt = new Intl.DateTimeFormat('pt-BR', { dateStyle: 'short', timeStyle: 'short' });
        tbody.innerHTML = bundles.map(function (b) {
            var date = b.generated_at ? new Date(b.generated_at) : null;
            var dateLabel = date && !Number.isNaN(date.getTime()) ? fmt.format(date) : '-';
            return '<tr>' +
                '<td><span class="table-file">' + escapeHtml(b.filename || '-') + '</span></td>' +
                '<td><span class="table-org">' + escapeHtml(b.acronym || '-') + '</span> ' + escapeHtml(b.org_name || '') + '</td>' +
                '<td><span class="table-desc" title="' + escapeHtml(b.description || '') + '">' + escapeHtml(b.description || 'Sem descrição') + '</span></td>' +
                '<td>' + escapeHtml(String(b.scripts_count == null ? 0 : b.scripts_count)) + '</td>' +
                '<td>' + dateLabel + '</td>' +
                '<td><a class="download-link" href="/api/?action=bundle-by-id&id=' + encodeURIComponent(b.id) + '">Baixar</a></td>' +
                '</tr>';
        }).join('');
    }

    fetch('/api/?action=public-bundles', { cache: 'no-store' })
        .then(function (r) { return r.json(); })
        .then(function (res) {
            if (res && res.success) render(res.data || []);
            else setState('Não foi possível carregar os bundles agora.');
        })
        .catch(function () { setState('Não foi possível carregar os bundles agora.'); });

    var year = document.getElementById('current-year');
    if (year) year.textContent = new Date().getFullYear();

    /* ---- Animação de entrada ao rolar ---- */
    var revealables = document.querySelectorAll('.reveal');
    if ('IntersectionObserver' in window) {
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                    io.unobserve(entry.target);
                }
            });
        }, { threshold: 0.15 });
        revealables.forEach(function (el) { io.observe(el); });
    } else {
        revealables.forEach(function (el) { el.classList.add('revealed'); });
    }
})();
