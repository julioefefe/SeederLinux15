<?php
require_once __DIR__ . '/../lib/config.php';
require_once __DIR__ . '/../lib/db.php';

$pageTitle = 'SeederLinux Lite | Manual de uso';

// O manual segue o tema público definido no painel (classic | modern | solar)
$theme = 'classic';
try {
    $row = Database::fetchOne("SELECT value FROM settings WHERE key = 'public_theme'");
    if ($row && in_array($row['value'], ['classic', 'modern', 'solar'], true)) {
        $theme = $row['value'];
    }
} catch (Throwable $e) {
    // Sem banco: cai no clássico
}

$hasToggle = in_array($theme, ['modern', 'solar'], true);
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Manual de uso do SeederLinux Lite: provisionamento de estações Linux padronizado, versionado e auditável.">
  <title><?= htmlspecialchars($pageTitle, ENT_QUOTES, 'UTF-8') ?></title>
  <link rel="icon" href="/assets/images/seederlinux-logo.png">
  <?php if ($theme === 'modern'): ?>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <?php elseif ($theme === 'solar'): ?>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <?php endif; ?>
  <?php if ($hasToggle): ?>
  <script>
    (function () {
      var theme = localStorage.getItem('seederlinux-theme') || 'dark';
      document.documentElement.setAttribute('data-theme', theme);
    })();
  </script>
  <?php endif; ?>
  <style>
    :root {
      --mono: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      --sans: 'Segoe UI', Inter, system-ui, -apple-system, sans-serif;
      --radius: 14px;
      /* clássico (padrão) */
      --bg: #0f172a; --bg-soft: #0f172a; --card: #1e293b; --text: #f1f5f9; --muted: #94a3b8;
      --line: #334155; --line-soft: rgba(51, 65, 85, .6);
      --accent: #3b82f6; --accent-strong: #60a5fa; --accent-soft: rgba(59, 130, 246, .14);
      --header-bg: rgba(15, 23, 42, .86);
    }
    body.theme-modern {
      --sans: 'Manrope', Inter, ui-sans-serif, system-ui, sans-serif;
      --bg: #07111f; --bg-soft: #0b1a2d; --card: #0b1a2d; --text: #f4f7fa; --muted: #9fb0c4;
      --line: rgba(141, 173, 203, .17); --line-soft: rgba(141, 173, 203, .1);
      --accent: #75e6d0; --accent-strong: #49cfbf; --accent-soft: rgba(117, 230, 208, .12);
      --header-bg: rgba(7, 17, 31, .84);
    }
    body.theme-solar {
      --sans: 'Sora', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      --bg: #171009; --bg-soft: #1e140b; --card: #231610; --text: #f8ede0; --muted: #bda184;
      --line: rgba(255, 220, 180, .26); --line-soft: rgba(255, 220, 180, .12);
      --accent: #ff7a1a; --accent-strong: #ffb454; --accent-soft: rgba(255, 122, 26, .12);
      --header-bg: rgba(23, 16, 9, .84);
    }
    html[data-theme="light"] body.theme-modern {
      --bg: #f4f7fa; --bg-soft: #ffffff; --card: #ffffff; --text: #0a1a2e; --muted: #5b6f85;
      --line: rgba(10, 26, 46, .32); --line-soft: rgba(10, 26, 46, .14);
      --accent: #0d8f7e; --accent-strong: #0b7a6c; --accent-soft: rgba(13, 143, 126, .1);
      --header-bg: rgba(244, 247, 250, .86);
    }
    html[data-theme="light"] body.theme-solar {
      --bg: #fdf6ec; --bg-soft: #fff3e2; --card: #ffffff; --text: #26170a; --muted: #6f5841;
      --line: rgba(120, 80, 30, .3); --line-soft: rgba(120, 80, 30, .14);
      --accent: #e56a00; --accent-strong: #c2530a; --accent-soft: rgba(229, 106, 0, .1);
      --header-bg: rgba(253, 246, 236, .86);
    }

    * { box-sizing: border-box; }
    .hidden { display: none; }
    html { scroll-behavior: smooth; scroll-padding-top: 150px; }
    body { margin: 0; background: var(--bg); color: var(--text); font-family: var(--sans); line-height: 1.7; }
    a { color: var(--accent); text-decoration: none; }
    a:hover { color: var(--accent-strong); }

    /* ---------- Cabeçalho fixo: marca + links + índice ---------- */
    .manual-header { position: sticky; top: 0; z-index: 50; background: var(--header-bg); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); border-bottom: 1px solid var(--line-soft); }
    .manual-header .wrap { width: min(860px, calc(100% - 48px)); margin: 0 auto; }
    .manual-top { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 14px 0; }
    .manual-brand { display: inline-flex; align-items: center; gap: 10px; color: var(--text); font-weight: 800; font-size: 16px; letter-spacing: -.02em; }
    .manual-brand img { width: 28px; height: 28px; }
    .manual-brand span span { color: var(--accent); }
    .back-links { display: flex; align-items: center; gap: 16px; font-size: 13.5px; font-weight: 600; }
    .icon-btn { width: 34px; height: 34px; display: inline-grid; place-items: center; border: 1px solid var(--line); border-radius: 50%; background: transparent; color: var(--muted); cursor: pointer; font-size: 14px; transition: color .2s, border-color .2s; }
    .icon-btn:hover { color: var(--accent); border-color: var(--accent); }
    .toc { display: flex; flex-wrap: wrap; gap: 8px; padding: 0 0 14px; }
    .toc a { padding: 6px 13px; border: 1px solid var(--line); border-radius: 999px; color: var(--muted); background: var(--card); font-size: 12.5px; font-weight: 600; transition: color .2s, border-color .2s; }
    .toc a:hover { color: var(--accent); border-color: var(--accent); }

    /* ---------- Conteúdo ---------- */
    .wrap { width: min(860px, calc(100% - 48px)); margin: 0 auto; }
    .content { padding: 48px 0 80px; }
    h1 { font-size: clamp(30px, 4.5vw, 42px); line-height: 1.1; margin: 0 0 10px; letter-spacing: -.03em; }
    .intro { color: var(--muted); max-width: 620px; margin: 0 0 40px; font-size: 17px; }
    section.step { margin-bottom: 44px; }
    .step-n { display: inline-flex; align-items: center; gap: 10px; font: 600 12px var(--mono); letter-spacing: .12em; text-transform: uppercase; color: var(--accent); }
    .step-n b { display: inline-grid; place-items: center; width: 30px; height: 30px; border-radius: 10px; background: var(--accent-soft); }
    h2 { font-size: 24px; margin: 12px 0 10px; letter-spacing: -.02em; }
    p { margin: 0 0 14px; }
    ul, ol { margin: 0 0 14px; padding-left: 22px; }
    li { margin-bottom: 6px; }
    .card { border: 1px solid var(--line-soft); border-radius: var(--radius); background: var(--card); padding: 22px 26px; margin: 16px 0; }
    code { font-family: var(--mono); font-size: .9em; background: var(--accent-soft); color: var(--accent-strong); padding: 2px 6px; border-radius: 6px; }
    pre { background: #0d1b2e; color: #d7e4f0; border-radius: 12px; padding: 16px 20px; overflow-x: auto; font-family: var(--mono); font-size: 13px; line-height: 1.8; }
    pre b { color: #75e6d0; }
    .note { border-left: 3px solid var(--accent); padding: 10px 16px; background: var(--accent-soft); border-radius: 0 10px 10px 0; font-size: 14.5px; }
    .manual-footer { margin-top: 60px; padding-top: 24px; border-top: 1px solid var(--line-soft); color: var(--muted); font-size: 13.5px; display: flex; flex-wrap: wrap; gap: 8px 24px; justify-content: space-between; }

    @media (max-width: 620px) {
      .toc { flex-wrap: nowrap; overflow-x: auto; padding-bottom: 12px; scrollbar-width: thin; }
      .toc a { white-space: nowrap; }
      .back-links a:first-child { display: none; }
    }
  </style>
</head>
<body class="theme-<?= htmlspecialchars($theme, ENT_QUOTES, 'UTF-8') ?>">
  <header class="manual-header">
    <div class="wrap">
      <div class="manual-top">
        <a class="manual-brand" href="/"><img src="/assets/images/seederlinux-logo.png" alt=""><span>Seeder<span>Linux</span> Lite — Manual</a>
        <div class="back-links">
          <a href="/">← Voltar ao início</a>
          <a href="/login.html">Acessar o painel ↗</a>
          <?php if ($hasToggle): ?>
          <button class="icon-btn" type="button" onclick="toggleTheme()" aria-label="Alternar tema claro/escuro" title="Alternar tema">
            <span class="icon-moon" aria-hidden="true">☾</span>
            <span class="icon-sun hidden" aria-hidden="true">☀</span>
          </button>
          <?php endif; ?>
        </div>
      </div>
      <nav class="toc" aria-label="Índice">
        <a href="#visao-geral">1. Visão geral</a>
        <a href="#primeiros-passos">2. Primeiros passos</a>
        <a href="#organizacoes">3. Organizações e variáveis</a>
        <a href="#gerando-bundle">4. Gerando um bundle</a>
        <a href="#executando">5. Executando na estação</a>
        <a href="#agente">6. Agente de check-in</a>
        <a href="#duvidas">7. Dúvidas e suporte</a>
      </nav>
    </div>
  </header>

  <div class="wrap content">
    <h1>Manual de uso</h1>
    <p class="intro">Como provisionar estações Linux de forma padronizada com o SeederLinux Lite: configure a organização, gere o bundle e execute na estação.</p>

    <section class="step" id="visao-geral">
      <span class="step-n"><b>1</b> Visão geral</span>
      <h2>O que é o SeederLinux Lite</h2>
      <div class="card">
        <p>É uma plataforma local — painel web em PHP + PostgreSQL — que monta <strong>bundles de instalação</strong> (scripts shell autônomos) para padronizar estações Linux, com:</p>
        <ul>
          <li><strong>Isolamento por organização (OM):</strong> cada OM tem seus próprios dados, variáveis e bundles.</li>
          <li><strong>Versionamento em 3 camadas:</strong> valores de fábrica, GAP Default e override local.</li>
          <li><strong>Auditoria:</strong> ações administrativas registradas com visibilidade por perfil.</li>
          <li><strong>Operação 100% local:</strong> sem dependência de nuvem; o bundle roda offline na estação.</li>
        </ul>
      </div>
    </section>

    <section class="step" id="primeiros-passos">
      <span class="step-n"><b>2</b> Primeiros passos</span>
      <h2>Acessar o painel</h2>
      <div class="card">
        <ol>
          <li>Abra <code>/login.html</code> no servidor do SeederLinux Lite.</li>
          <li>Entre com seu usuário e senha (solicite ao administrador da sua OM).</li>
          <li>No painel você encontra: dashboard, organizações, variáveis, módulos, bundles e auditoria.</li>
        </ol>
        <p class="note">Perfis: administradores gerenciam usuários e configurações globais; operadores geram bundles e editam variáveis da sua OM.</p>
      </div>
    </section>

    <section class="step" id="organizacoes">
      <span class="step-n"><b>3</b> Organizações e variáveis</span>
      <h2>Cadastre a OM e os valores da estação</h2>
      <div class="card">
        <ol>
          <li>No menu <strong>Organizações</strong>, verifique se a sua OM já está cadastrada (se não, um administrador pode criá-la).</li>
          <li>Em <strong>Variáveis</strong>, preencha os valores da estação: domínio, proxy, impressoras, identidade visual etc.</li>
          <li>Os valores seguem a precedência: <code>fábrica → GAP Default → override local</code>. O override local da OM sempre vence.</li>
        </ol>
        <p class="note">Alterações em variáveis ficam registradas na auditoria, com usuário, data e valor anterior.</p>
      </div>
    </section>

    <section class="step" id="gerando-bundle">
      <span class="step-n"><b>4</b> Gerando um bundle</span>
      <h2>Monte o pacote de instalação</h2>
      <div class="card">
        <ol>
          <li>Em <strong>Bundles</strong>, selecione a organização de destino.</li>
          <li>Escolha os módulos (os 23 scripts Core: DNS, pacotes, domínio AD, navegador, inventário, sessões, proxy, sincronização periódica…) na ordem oficial.</li>
          <li>Confira as versões, gere o bundle e, se desejar, marque-o como <em>público</em> para download pela página inicial.</li>
        </ol>
        <p>O bundle sai com os <code>placeholders</code> já substituídos pelos valores das variáveis da OM e com execução não interativa.</p>
      </div>
    </section>

    <section class="step" id="executando">
      <span class="step-n"><b>5</b> Executando na estação</span>
      <h2>Um comando, estação pronta</h2>
      <div class="card">
        <p>Baixe o bundle (pelo painel ou pela seção <strong>Bundles</strong> da página inicial) e execute na estação Linux:</p>
        <pre><code><b>$</b> sudo bash bundle.sh

INFO  Organizacao: SUA_OM
INFO  Scripts incluidos: 22
OK    Variaveis aplicadas
OK    Provisionamento concluido</code></pre>
        <p class="note">Execute como root (<code>sudo</code>) e confira o log final antes de liberar a estação para o usuário.</p>
      </div>
    </section>

    <section class="step" id="agente">
      <span class="step-n"><b>6</b> Agente de check-in</span>
      <h2>Mantenha a estação conectada</h2>
      <div class="card">
        <p>O agente Python faz o check-in da estação e recebe bundles atualizados:</p>
        <ol>
          <li>Baixe o <code>agent.py</code> na seção de download da página inicial.</li>
          <li>Instale o Python 3 na estação e copie o agente.</li>
          <li>Configure o endereço do servidor e execute-o periodicamente (cron ou systemd).</li>
        </ol>
      </div>
    </section>

    <section class="step" id="duvidas">
      <span class="step-n"><b>7</b> Dúvidas e suporte</span>
      <h2>Documentação e ajuda</h2>
      <div class="card">
        <ul>
          <li>Código-fonte e detalhes técnicos: <a href="https://github.com/julioefefe/SeederLinux15" rel="noopener noreferrer">repositório no GitHub</a>.</li>
          <li>Instalação e operação do servidor: arquivos <code>README.md</code> e <code>SERVIDOR.md</code> do projeto.</li>
          <li>Problemas de acesso ou credenciais: fale com o administrador da sua OM.</li>
        </ul>
      </div>
    </section>

    <div class="manual-footer">
      <span>SeederLinux Lite — provisionamento local e auditável.</span>
      <span><a href="/">Página inicial</a> · <a href="/login.html">Painel</a></span>
    </div>
  </div>

  <?php if ($hasToggle): ?>
  <script>
    function updateToggleIcon() {
      var light = document.documentElement.getAttribute('data-theme') === 'light';
      var moon = document.querySelector('.icon-moon'), sun = document.querySelector('.icon-sun');
      if (!moon || !sun) return;
      moon.classList.toggle('hidden', light);
      sun.classList.toggle('hidden', !light);
    }
    function toggleTheme() {
      var next = document.documentElement.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
      document.documentElement.setAttribute('data-theme', next);
      localStorage.setItem('seederlinux-theme', next);
      updateToggleIcon();
    }
    updateToggleIcon();
  </script>
  <?php endif; ?>
</body>
</html>
