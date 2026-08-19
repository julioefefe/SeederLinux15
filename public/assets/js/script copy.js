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
})();
