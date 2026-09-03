/**
 * SeederLinux Lite - Main JavaScript
 * Common utilities and functions
 */

// API helper with absolute path from root
let csrfToken = '';

const API = {
    baseUrl: '/api/',

    /**
     * Build URL with proper query string encoding
     * @param {string} action - The API action
     * @param {Object} params - Additional query parameters
     * @returns {string} - Properly encoded URL
     */
    buildUrl(action, params = {}) {
        const url = new URL(this.baseUrl, window.location.origin);
        url.searchParams.set('action', action);
        for (const [key, value] of Object.entries(params)) {
            if (value !== undefined && value !== null) {
                url.searchParams.set(key, value);
            }
        }
        return url.toString();
    },

    async request(action, method = 'GET', data = null, params = {}) {
        const url = this.buildUrl(action, params);

        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
                ...(csrfToken ? { 'X-CSRF-Token': csrfToken } : {})
            },
            credentials: 'same-origin'
        };

        if (data && method !== 'GET') {
            options.body = JSON.stringify(data);
        }

        try {
            const response = await fetch(url, options);
            if (!response.ok) {
                let message = `HTTP ${response.status}: ${response.statusText}`;
                try {
                    const errorBody = await response.json();
                    message = errorBody.error || errorBody.message || message;
                } catch (parseError) {
                    // Keep the HTTP status when the server did not return JSON.
                }
                throw new Error(message);
            }
            return response.json();
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    },

    async get(action, params = {}) {
        return this.request(action, 'GET', null, params);
    },

    async post(action, data, params = {}) {
        return this.request(action, 'POST', data, params);
    },

    async put(action, id, data, params = {}) {
        const merged = { id, ...params };
        return this.request(action, 'PUT', data, merged);
    },

    async delete(action, id) {
        return this.request(action, 'DELETE', null, { id });
    },

    async postMultipart(action, formData) {
        const url = this.buildUrl(action);
        const headers = csrfToken ? { 'X-CSRF-Token': csrfToken } : {};
        const res = await fetch(url, { method: 'POST', body: formData, headers, credentials: 'same-origin' });
        return res.json();
    }
};

// Toast notifications
const Toast = {
    show(message, type = 'info', duration = 4000) {
        const container = document.getElementById('toast-container');
        if (!container) {
            const newContainer = document.createElement('div');
            newContainer.id = 'toast-container';
            document.body.appendChild(newContainer);
        }

        const toastContainer = document.getElementById('toast-container');
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.innerHTML = `
            <div class="toast-content">
                <div class="toast-icon">${this.getIcon(type)}</div>
                <div class="toast-message">${String(message)}</div>
                <button class="toast-close" type="button" aria-label="Fechar notificação" onclick="this.closest('.toast').remove()">&times;</button>
            </div>
            <div class="toast-progress"></div>
        `;

        toastContainer.appendChild(toast);

        const progress = toast.querySelector('.toast-progress');
        if (progress) {
            progress.style.animationDuration = `${duration}ms`;
        }

        setTimeout(() => {
            if (!toast.isConnected) return;
            toast.classList.add('toast-hiding');
            setTimeout(() => toast.remove(), 260);
        }, duration);
    },

    getIcon(type) {
        const icons = {
            success: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 13l4 4L19 7"/></svg>',
            error: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 18L18 6M6 6l12 12"/></svg>',
            warning: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v2m0 4h.01M12 2l9 16H3L12 2z"/></svg>',
            info: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 16v-4M12 8h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>'
        };
        return icons[type] || icons.info;
    },

    success(message) { this.show(message, 'success'); },
    error(message) { this.show(message, 'error'); },
    warning(message) { this.show(message, 'warning'); },
    info(message) { this.show(message, 'info'); }
};

// Utility functions
const Utils = {
    formatDate(dateString) {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    },

    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },

    escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
};

// Make available globally
window.API = API;
window.Toast = Toast;
window.Utils = Utils;
window.showToast = (message, type = 'success') => Toast.show(message, type);
window.alert = (message) => Toast.show(message, 'warning');

// ============ THEME TOGGLE (shared) ============

function applyThemePublic(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    const iconDark = document.getElementById('theme-icon-dark');
    const iconLight = document.getElementById('theme-icon-light');
    if (iconDark && iconLight) {
        if (theme === 'light') {
            iconDark.classList.add('hidden');
            iconLight.classList.remove('hidden');
        } else {
            iconDark.classList.remove('hidden');
            iconLight.classList.add('hidden');
        }
    }
}

function toggleTheme() {
    const current = document.documentElement.getAttribute('data-theme') || 'dark';
    const next = current === 'dark' ? 'light' : 'dark';
    localStorage.setItem('seederlinux-theme', next);
    applyThemePublic(next);
}
window.toggleTheme = toggleTheme;

(function initThemePublic() {
    const saved = localStorage.getItem('seederlinux-theme') || 'dark';
    applyThemePublic(saved);
})();

// Public bundle list
function setPublicBundleState(message, type = 'empty') {
    const tbody = document.getElementById('bundles-tbody');
    const status = document.getElementById('bundle-status');
    if (!tbody) return;
    tbody.innerHTML = `<tr><td colspan="6" class="table-state table-state-${type}">${Utils.escapeHtml(message)}</td></tr>`;
    if (status) status.textContent = type === 'error' ? 'Indisponivel' : 'Nenhum publicado';
}

function renderPublicBundles(bundles) {
    const tbody = document.getElementById('bundles-tbody');
    const status = document.getElementById('bundle-status');
    if (!tbody) return;
    if (!Array.isArray(bundles) || bundles.length === 0) {
        setPublicBundleState('Nenhum bundle publico disponivel no momento.');
        return;
    }

    const dateFormatter = new Intl.DateTimeFormat('pt-BR', {
        dateStyle: 'short',
        timeStyle: 'short'
    });
    tbody.innerHTML = bundles.map((bundle) => {
        const date = bundle.generated_at ? new Date(bundle.generated_at) : null;
        const dateLabel = date && !Number.isNaN(date.getTime()) ? dateFormatter.format(date) : '-';
        const description = bundle.description || 'Sem descricao';
        return `<tr>
            <td><span class="table-file">${Utils.escapeHtml(bundle.filename || '-')}</span></td>
            <td><span class="table-org">${Utils.escapeHtml(bundle.acronym || '-')}</span><br>${Utils.escapeHtml(bundle.org_name || '')}</td>
            <td><span class="table-description" title="${Utils.escapeHtml(description)}">${Utils.escapeHtml(description)}</span></td>
            <td>${Utils.escapeHtml(String(bundle.scripts_count ?? 0))}</td>
            <td>${Utils.escapeHtml(dateLabel)}</td>
            <td><a class="download-link" href="api/?action=bundle-by-id&id=${encodeURIComponent(bundle.id)}">Baixar</a></td>
        </tr>`;
    }).join('');
    if (status) status.textContent = `${bundles.length} publicado${bundles.length === 1 ? '' : 's'}`;
}

async function loadPublicBundles() {
    const statBundles = document.getElementById('stat-bundles');
    const statUpdated = document.getElementById('stat-updated');
    try {
        const response = await API.get('public-bundles');
        if (!response.success) throw new Error(response.error || 'Resposta invalida');
        const bundles = response.data || [];
        renderPublicBundles(bundles);
        if (statBundles) statBundles.textContent = bundles.length;
        const latest = bundles.map(bundle => new Date(bundle.generated_at))
            .filter(date => !Number.isNaN(date.getTime()))
            .sort((left, right) => right - left)[0];
        if (statUpdated) statUpdated.textContent = latest ? latest.toLocaleDateString('pt-BR') : '-';
    } catch (error) {
        console.error('Erro ao carregar bundles publicos:', error);
        setPublicBundleState('Nao foi possivel carregar os bundles agora.', 'error');
        if (statBundles) statBundles.textContent = '-';
        if (statUpdated) statUpdated.textContent = '-';
    }
}

document.addEventListener('DOMContentLoaded', () => {
    if (document.querySelector('.public-page')) loadPublicBundles();
});