(() => {
  const body = document.body;
  const menuToggle = document.querySelector('.menu-toggle');
  const mainNav = document.querySelector('.main-nav');
  const navLinks = [...document.querySelectorAll('.main-nav a[href^="#"]')];
  const toast = document.querySelector('.toast');
  const year = document.querySelector('#current-year');

  if (year) year.textContent = new Date().getFullYear();

  menuToggle?.addEventListener('click', () => {
    const isOpen = mainNav.classList.toggle('open');
    body.classList.toggle('menu-open', isOpen);
    menuToggle.setAttribute('aria-expanded', String(isOpen));
  });

  navLinks.forEach((link) => {
    link.addEventListener('click', () => {
      mainNav.classList.remove('open');
      body.classList.remove('menu-open');
      menuToggle?.setAttribute('aria-expanded', 'false');
    });
  });

  const sections = [...document.querySelectorAll('main section[id]')];
  const updateActiveLink = () => {
    const scrollPosition = window.scrollY + 160;
    let currentId = '';
    sections.forEach((section) => {
      if (scrollPosition >= section.offsetTop) currentId = section.id;
    });
    navLinks.forEach((link) => link.classList.toggle('is-active', link.hash === `#${currentId}`));
  };
  window.addEventListener('scroll', updateActiveLink, { passive: true });
  updateActiveLink();

  const revealItems = document.querySelectorAll('.section, .proof-strip, .final-cta');
  if ('IntersectionObserver' in window) {
    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('reveal', 'visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.08 });
    revealItems.forEach((item) => revealObserver.observe(item));
  }

  const showToast = () => {
    toast?.classList.add('show');
    window.clearTimeout(showToast.timer);
    showToast.timer = window.setTimeout(() => toast?.classList.remove('show'), 2600);
  };

  document.querySelectorAll('[data-copy]').forEach((button) => {
    button.addEventListener('click', async () => {
      const command = button.dataset.copy || '';
      try {
        await navigator.clipboard.writeText(command);
        button.textContent = 'copiado';
        showToast();
        window.setTimeout(() => { button.textContent = 'copiar'; }, 1800);
      } catch (error) {
        const helper = document.createElement('textarea');
        helper.value = command;
        helper.setAttribute('readonly', '');
        helper.style.position = 'fixed';
        helper.style.opacity = '0';
        document.body.appendChild(helper);
        helper.select();
        document.execCommand('copy');
        helper.remove();
        button.textContent = 'copiado';
        showToast();
        window.setTimeout(() => { button.textContent = 'copiar'; }, 1800);
      }
    });
  });

  // ============ THEME TOGGLE ============
  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    const iconDark = document.querySelector('.theme-icon-dark');
    const iconLight = document.querySelector('.theme-icon-light');
    if (iconDark && iconLight) {
      if (theme === 'light') {
        iconDark.style.display = 'none';
        iconLight.style.display = '';
      } else {
        iconDark.style.display = '';
        iconLight.style.display = 'none';
      }
    }
  }

  window.toggleTheme = function toggleTheme() {
    const current = document.documentElement.getAttribute('data-theme') || 'dark';
    const next = current === 'dark' ? 'light' : 'dark';
    localStorage.setItem('seederlinux-theme', next);
    applyTheme(next);
  };

  const savedTheme = localStorage.getItem('seederlinux-theme') || 'dark';
  applyTheme(savedTheme);

  // ============ PUBLIC BUNDLES ============
  function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  function setBundleState(message, type) {
    const tbody = document.getElementById('bundles-tbody');
    const status = document.getElementById('bundle-status');
    if (!tbody) return;
    tbody.innerHTML = `<tr><td colspan="6" class="table-state table-state-${type || 'empty'}">${escapeHtml(message)}</td></tr>`;
    if (status) status.textContent = type === 'error' ? 'Indisponível' : 'Nenhum publicado';
  }

  function renderBundles(bundles) {
    const tbody = document.getElementById('bundles-tbody');
    const status = document.getElementById('bundle-status');
    if (!tbody) return;
    if (!Array.isArray(bundles) || bundles.length === 0) {
      setBundleState('Nenhum bundle público disponível no momento.');
      return;
    }

    const dateFormatter = new Intl.DateTimeFormat('pt-BR', { dateStyle: 'short', timeStyle: 'short' });
    tbody.innerHTML = bundles.map((bundle) => {
      const date = bundle.generated_at ? new Date(bundle.generated_at) : null;
      const dateLabel = date && !Number.isNaN(date.getTime()) ? dateFormatter.format(date) : '-';
      const description = bundle.description || 'Sem descrição';
      return `<tr>
        <td><span class="table-file">${escapeHtml(bundle.filename || '-')}</span></td>
        <td><span class="table-org">${escapeHtml(bundle.acronym || '-')}</span><br>${escapeHtml(bundle.org_name || '')}</td>
        <td><span class="table-description" title="${escapeHtml(description)}">${escapeHtml(description)}</span></td>
        <td>${escapeHtml(String(bundle.scripts_count ?? 0))}</td>
        <td>${escapeHtml(dateLabel)}</td>
        <td><a class="download-link" href="/api/?action=bundle-by-id&id=${encodeURIComponent(bundle.id)}">Baixar</a></td>
      </tr>`;
    }).join('');
    if (status) status.textContent = `${bundles.length} publicado${bundles.length === 1 ? '' : 's'}`;
  }

  async function loadBundles() {
    try {
      const response = await fetch('/api/?action=public-bundles');
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const result = await response.json();
      if (!result.success) throw new Error(result.error || 'Resposta inválida');
      renderBundles(result.data || []);
    } catch (error) {
      console.error('Erro ao carregar bundles públicos:', error);
      setBundleState('Não foi possível carregar os bundles agora.', 'error');
    }
  }

  if (document.getElementById('bundles-tbody')) loadBundles();
})();
