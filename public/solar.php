<?php
$pageTitle = 'SeederLinux Lite | Estações Linux prontas em minutos';
$release = 'MVP 1.0';
?>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="SeederLinux Lite: prepare estações Linux padronizadas, com a identidade da sua organização e tudo auditado — com um único comando.">
  <meta name="theme-color" content="#171009">
  <title><?= htmlspecialchars($pageTitle, ENT_QUOTES, 'UTF-8') ?></title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/public/assets/css/solar.css">
  <script>
    (function () {
      var theme = localStorage.getItem('seederlinux-theme') || 'dark';
      document.documentElement.setAttribute('data-theme', theme);
    })();
  </script>
</head>
<body class="solar-page">
  <div class="glow-sun" aria-hidden="true"></div>

  <header class="topbar" id="topo">
    <a class="brand" href="#topo" aria-label="SeederLinux Lite — início">
      <img class="brand-logo" src="/assets/images/seederlinux-logo.png" alt="">
      <span>Seeder<span>Linux</span> <em>Lite</em></span>
    </a>
    <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="main-nav">
      <span></span><span></span><span></span><b class="sr-only">Abrir menu</b>
    </button>
    <nav class="main-nav" id="main-nav" aria-label="Navegação principal">
      <a href="#beneficios">Benefícios</a>
      <a href="#como-funciona">Como funciona</a>
      <a href="#bundles">Bundles</a>
      <a href="#download">Download</a>
      <button class="theme-toggle" type="button" onclick="toggleTheme()" aria-label="Alternar tema claro/escuro" title="Alternar tema">
        <span class="icon-moon" aria-hidden="true">☾</span>
        <span class="icon-sun hidden" aria-hidden="true">☀</span>
      </button>
      <a class="nav-cta" href="/login.html">Acessar o painel <span aria-hidden="true">↗</span></a>
    </nav>
  </header>

  <main>
    <!-- ===== HERO ===== -->
    <section class="hero" aria-labelledby="hero-title">
      <div class="hero-copy">
        <div class="kicker"><span class="dot"></span> Provisionamento Linux sem dor de cabeça <small><?= htmlspecialchars($release, ENT_QUOTES, 'UTF-8') ?></small></div>
        <h1 id="hero-title">Estações Linux prontas para o trabalho. <span class="grad">Em minutos.</span></h1>
        <p class="lead">Chega de configurar tudo à mão, estação por estação. O SeederLinux Lite prepara cada máquina com um único comando — padronizada, com a identidade da sua organização e pronta para operar.</p>
        <div class="actions">
          <a class="btn primary" href="#bundles">Ver bundles disponíveis <span aria-hidden="true">↓</span></a>
          <a class="btn ghost" href="/login.html">Acessar o painel <span aria-hidden="true">↗</span></a>
        </div>
      </div>
      <div class="hero-visual reveal" aria-label="Exemplo de execução">
        <div class="term">
          <div class="term-top"><span class="dots"><i></i><i></i><i></i></span><span>bundle.sh</span><span class="live">● pronto</span></div>
          <pre><code><b class="prompt">$</b> sudo bash bundle.sh

<em>preparando a estação...</em>
<span class="ok">✓ 22 módulos aplicados</span>
<span class="ok">✓ identidade da OM instalada</span>
<span class="ok">✓ estação pronta em 4 min 12 s</span>

<b class="prompt">$</b> <i class="cursor"></i></code></pre>
        </div>
        <div class="chip c1"><span aria-hidden="true">⚡</span> 1 comando</div>
        <div class="chip c2"><span aria-hidden="true">★</span> padrão da OM</div>
      </div>
    </section>

    <!-- ===== PILLS DE INDICADORES (dados vivos) ===== -->
    <div class="stat-pills" aria-label="Indicadores">
      <div class="pill"><strong id="stat-bundles">-</strong><span>bundles publicados</span></div>
      <div class="pill"><strong>22</strong><span>módulos de configuração</span></div>
      <div class="pill"><strong id="stat-updated">-</strong><span>último bundle</span></div>
      <div class="pill"><strong>100%</strong><span>local, sem nuvem</span></div>
    </div>

    <!-- ===== LETREIRO ===== -->
    <div class="ticker" aria-hidden="true">
      <div class="ticker-track">
        <span>1 comando por estação <i>✦</i> 22 módulos prontos <i>✦</i> 100% local, sem nuvem <i>✦</i> zero improviso <i>✦</i> padrão da OM em toda a frota <i>✦</i></span>
        <span>1 comando por estação <i>✦</i> 22 módulos prontos <i>✦</i> 100% local, sem nuvem <i>✦</i> zero improviso <i>✦</i> padrão da OM em toda a frota <i>✦</i></span>
      </div>
    </div>

    <!-- ===== BENTO ===== -->
    <section class="block" id="beneficios" aria-labelledby="benefits-title">
      <div class="kicker reveal">por que seederlinux</div>
      <h2 id="benefits-title" class="reveal">Sua equipe tem coisa melhor a fazer <span class="grad">do que configurar estação.</span></h2>
      <div class="bento">
        <article class="card b-big reveal">
          <span class="card-icon" aria-hidden="true">◎</span>
          <h3>Toda estação sai igual</h3>
          <p>Mesma configuração, mesmo padrão, zero surpresa. O que foi testado em uma máquina funciona em todas as outras.</p>
          <ul class="check">
            <li>config idêntica em toda a frota</li>
            <li>identidade da OM aplicada de uma vez</li>
            <li>sem prompts, sem improviso</li>
          </ul>
        </article>
        <article class="card reveal">
          <span class="card-icon" aria-hidden="true">⚡</span>
          <h3>Em minutos, não em dias</h3>
          <p>Repositórios, domínio, impressoras, navegadores e identidade visual — tudo aplicado de uma vez, sem reinstalação manual.</p>
        </article>
        <article class="card reveal">
          <span class="card-icon" aria-hidden="true">✓</span>
          <h3>Nada acontece em silêncio</h3>
          <p>Cada alteração fica registrada. Você sempre sabe o que mudou, quem mudou e qual versão está valendo.</p>
        </article>
        <article class="card b-wide reveal">
          <span class="card-icon" aria-hidden="true">◫</span>
          <h3>A versão certa vence, sempre</h3>
          <p>Três camadas — core, OM e placeholders — se encaixam sem conflito: o que é padrão da organização sobrepõe o genérico, e o que é específico da estação sobrepõe tudo.</p>
        </article>
      </div>
    </section>

    <!-- ===== PASSOS EM ZIGUE-ZAGUE ===== -->
    <section class="block" id="como-funciona" aria-labelledby="how-title">
      <div class="kicker reveal">como funciona</div>
      <h2 id="how-title" class="reveal">Do pedido à estação pronta <span class="grad">em três passos.</span></h2>
      <div class="steps">
        <div class="step-row reveal">
          <div class="step-text"><h3>Configure</h3><p>Cadastre a organização e preencha os valores uma única vez. As demais estações herdam tudo.</p></div>
          <div class="step-side"><span class="num">01</span></div>
        </div>
        <div class="step-row reveal">
          <div class="step-side"><span class="num">02</span></div>
          <div class="step-text"><h3>Gere</h3><p>O painel monta o bundle com os módulos certos e as variáveis já resolvidas, na ordem oficial.</p></div>
        </div>
        <div class="step-row reveal">
          <div class="step-text"><h3>Execute</h3><p>Um comando na estação e pronto. Configuração completa, sem prompts e sem improviso.</p></div>
          <div class="step-side"><span class="num">03</span></div>
        </div>
      </div>
    </section>

    <!-- ===== BUNDLES (título lateral + tabela) ===== -->
    <section class="block" id="bundles" aria-labelledby="bundles-title">
      <div class="bundles-layout">
        <div class="bundle-side reveal">
          <div class="kicker">distribuição</div>
          <h2 id="bundles-title">Bundles <span class="grad">para download</span></h2>
          <p class="side-note">Prontos para levar à estação: módulos na ordem oficial e variáveis já resolvidas.</p>
          <p class="side-note">Novos bundles são gerados no <a href="/login.html">painel administrativo</a>.</p>
        </div>
        <div class="panel reveal">
          <div class="panel-head">
            <span>PUBLICADOS RECENTEMENTE</span>
            <span id="bundle-status" class="panel-status">Carregando...</span>
          </div>
          <div class="table-scroll">
            <table class="table">
              <thead>
                <tr><th>Arquivo</th><th>Organização</th><th>Descrição</th><th>Scripts</th><th>Gerado em</th><th><span class="sr-only">Ação</span></th></tr>
              </thead>
              <tbody id="bundles-tbody">
                <tr><td colspan="6" class="table-state">Carregando bundles...</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== BANNER DE DOWNLOAD (invertido) ===== -->
    <section class="block" id="download" aria-labelledby="download-title">
      <div class="download-banner reveal">
        <div>
          <div class="banner-kicker">cliente da estação</div>
          <h2 id="download-title">Leve o agente para cada máquina</h2>
          <p>O agente Python cuida do check-in periódico e do recebimento de bundles — baixe e instale nas estações.</p>
        </div>
        <div class="download-actions">
          <a class="btn dark" href="/api/download.php?file=agent.py">Baixar agent.py <span aria-hidden="true">↓</span></a>
          <a class="btn outline" href="https://github.com/Toledo-JC/SeederLinux_14" target="_blank" rel="noopener">Ver projeto no GitHub <span aria-hidden="true">↗</span></a>
        </div>
      </div>
    </section>

    <!-- ===== CTA FINAL ===== -->
    <section class="block cta-final" aria-labelledby="cta-title">
      <div class="cta-ring" aria-hidden="true"></div>
      <h2 id="cta-title" class="reveal">Pronto para padronizar <span class="grad">a sua próxima estação?</span></h2>
      <p class="reveal">Configure uma vez. Execute em todas. Sem improviso, sem retrabalho, sem nuvem.</p>
      <div class="cta-actions reveal">
        <a class="btn primary" href="#bundles">Ver bundles disponíveis <span aria-hidden="true">↓</span></a>
        <a class="btn ghost" href="#topo">Voltar ao início <span aria-hidden="true">↑</span></a>
      </div>
    </section>
  </main>

  <footer class="footer">
    <a class="brand" href="#topo">
      <img class="brand-logo" src="/assets/images/seederlinux-logo.png" alt="">
      <span>Seeder<span>Linux</span> <em>Lite</em></span>
    </a>
    <p>Provisionamento Linux rápido, padronizado e auditável.</p>
    <div class="footer-meta">
      <span>PHP · PostgreSQL · Bash · Python</span>
      <span>© <span id="current-year"></span> SeederLinux Lite</span>
    </div>
  </footer>

  <script src="/public/assets/js/solar.js"></script>
</body>
</html>
