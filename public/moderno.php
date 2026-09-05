<?php
$pageTitle = 'SeederLinux Lite | Governança de estações Linux para equipes de TI';
$release = 'MVP 1.0';
?>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="SeederLinux Lite: provisionamento, padronização e gestão contínua de estações Linux em ambientes multi-organizacionais.">
  <meta name="theme-color" content="#07111f">
  <title><?= htmlspecialchars($pageTitle, ENT_QUOTES, 'UTF-8') ?></title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/public/assets/css/styles.css">
  <script>
    (function () {
      var theme = localStorage.getItem('seederlinux-theme') || 'dark';
      document.documentElement.setAttribute('data-theme', theme);
    })();
  </script>
</head>
<body>
  <div class="site-shell">
    <header class="site-header" id="topo">
      <a class="brand" href="#topo" aria-label="SeederLinux Lite — início">
        <img class="brand-logo" src="/assets/images/seederlinux-logo.png" alt="">
        <span>Seeder<span>Linux</span> <em>Lite</em></span>
      </a>
      <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="main-nav">
        <span></span><span></span><span></span><b class="sr-only">Abrir menu</b>
      </button>
      <nav class="main-nav" id="main-nav" aria-label="Navegação principal">
        <a href="#plataforma">Plataforma</a>
        <a href="#arquitetura">Arquitetura</a>
        <a href="#governanca">Governança</a>
        <a href="#bundles">Bundles</a>
        <a href="#transparencia">Status</a>
        <button class="theme-toggle-btn" type="button" onclick="toggleTheme()" aria-label="Alternar tema claro/escuro" title="Alternar tema">
          <span class="theme-icon-dark" aria-hidden="true">☾</span>
          <span class="theme-icon-light" aria-hidden="true">☀</span>
        </button>
        <a class="nav-cta" href="/login.html">Acessar painel <span aria-hidden="true">↗</span></a>
      </nav>
    </header>

    <main>
      <section class="hero section-grid" aria-labelledby="hero-title">
        <div class="hero-copy">
          <div class="eyebrow"><span class="status-dot"></span> Plataforma local para operações críticas <small><?= htmlspecialchars($release, ENT_QUOTES, 'UTF-8') ?></small></div>
          <h1 id="hero-title">Menos improviso.<br><span>Mais controle</span> sobre cada estação.</h1>
          <p class="hero-lead">O SeederLinux Lite transforma a preparação de estações Linux em um processo <strong>padronizado, versionado e auditável</strong> — pronto para a realidade de equipes de TI que administram múltiplas organizações.</p>
          <div class="hero-actions">
            <a class="button button-primary" href="#implantacao">Conheça o fluxo <span aria-hidden="true">↗</span></a>
            <a class="button button-ghost" href="#transparencia">Ver status do projeto <span aria-hidden="true">↓</span></a>
          </div>
          <div class="hero-note"><span class="lock-icon" aria-hidden="true">⌁</span> Sem dependência de cloud. O bundle pode operar offline após a geração.</div>
        </div>
        <div class="hero-visual" aria-label="Representação visual do fluxo de provisionamento">
          <div class="visual-orbit orbit-a"></div><div class="visual-orbit orbit-b"></div>
          <div class="terminal-card">
            <div class="terminal-top"><span class="terminal-dots"><i></i><i></i><i></i></span><span>bundle_om.sh</span><span class="terminal-live">● ready</span></div>
            <div class="terminal-body">
              <p><b class="prompt">$</b> seeder <span>generate --om</span> alpha</p>
              <p class="terminal-muted">loading organization variables...</p>
              <p><b class="check">✓</b> 22 core modules resolved</p>
              <p><b class="check">✓</b> non-interactive mode enabled</p>
              <p><b class="check">✓</b> version metadata attached</p>
              <p class="terminal-cursor"><b class="prompt">$</b> <span class="cursor"></span></p>
            </div>
            <div class="terminal-foot"><span>autonomous install bundle</span><span>v1.0</span></div>
          </div>
          <div class="float-tag tag-version"><span>◎</span> versionado</div>
          <div class="float-tag tag-audit"><span>✓</span> auditável</div>
          <div class="visual-caption"><span class="caption-line"></span><span>provisionamento controlado</span></div>
        </div>
      </section>

      <section class="proof-strip" aria-label="Indicadores da plataforma">
        <div><strong>22</strong><span>módulos Core<br>na ordem oficial</span></div>
        <div><strong>03</strong><span>camadas de<br>versionamento</span></div>
        <div><strong>∞</strong><span>organizações<br>com isolamento</span></div>
        <div><strong>01</strong><span>bundle shell<br>autônomo por OM</span></div>
      </section>

      <section class="section problem-section" id="plataforma" aria-labelledby="platform-title">
        <div class="section-kicker">01 / o desafio operacional</div>
        <div class="split-heading">
          <h2 id="platform-title">A complexidade não precisa<br>ser <span>replicada</span> à mão.</h2>
          <p>Quando a infraestrutura cresce, scripts soltos e configurações manuais deixam de ser agilidade. Tornam-se pontos cegos para a operação.</p>
        </div>
        <div class="problem-grid">
          <article class="problem-card"><span class="card-index">01</span><h3>Inconsistência</h3><p>Máquinas da mesma organização podem terminar com configurações diferentes e difíceis de reproduzir.</p></article>
          <article class="problem-card"><span class="card-index">02</span><h3>Retrabalho</h3><p>Pacotes, domínio AD, impressoras, proxy e identidade visual exigem repetição de tarefas.</p></article>
          <article class="problem-card"><span class="card-index">03</span><h3>Baixa rastreabilidade</h3><p>Sem histórico, fica difícil saber quem alterou o quê — e qual configuração está efetivamente ativa.</p></article>
        </div>
        <div class="solution-banner"><div class="solution-symbol">+</div><div><strong>Uma camada de governança entre a intenção e a execução.</strong><p>O SeederLinux Lite centraliza variáveis, módulos, versões e auditoria em um painel web local.</p></div><a href="#governanca" aria-label="Conhecer a governança">→</a></div>
      </section>

      <section class="section architecture-section" id="arquitetura" aria-labelledby="architecture-title">
        <div class="section-kicker">02 / como funciona</div>
        <div class="split-heading">
          <h2 id="architecture-title">Do painel ao endpoint,<br>um fluxo <span>rastreável.</span></h2>
          <p>Uma arquitetura enxuta, baseada em PHP, PostgreSQL, Bash e Python. Sem frameworks JavaScript pesados e com baixa superfície de dependências externas.</p>
        </div>
        <div class="flow-diagram" role="img" aria-label="Fluxo: painel administrativo, banco local, motor de bundle e estações Linux">
          <div class="flow-node node-panel"><span class="node-number">01</span><span class="node-icon">⌘</span><strong>Painel web</strong><small>OMs · variáveis · scripts</small></div>
          <div class="flow-connector"><span></span><small>configura</small></div>
          <div class="flow-node node-db"><span class="node-number">02</span><span class="node-icon">◫</span><strong>PostgreSQL local</strong><small>versões · auditoria</small></div>
          <div class="flow-connector"><span></span><small>gera</small></div>
          <div class="flow-node node-bundle"><span class="node-number">03</span><span class="node-icon">▣</span><strong>Bundle autônomo</strong><small>22 scripts · placeholders</small></div>
          <div class="flow-connector"><span></span><small>executa</small></div>
          <div class="flow-node node-endpoint"><span class="node-number">04</span><span class="node-icon">⌁</span><strong>Estação Linux</strong><small>provisionada · check-in</small></div>
        </div>
        <div class="stack-row"><span class="stack-label">STACK DECLARADA</span><span>PHP 8+</span><span>PostgreSQL 16+</span><span>Bash 5+</span><span>Python 3</span><span>HTML5 / CSS3 / JS vanilla</span></div>
      </section>

      <section class="section feature-section" aria-labelledby="feature-title">
        <div class="section-kicker">03 / capacidade operacional</div>
        <div class="split-heading">
          <h2 id="feature-title">Controle onde a equipe<br>mais precisa: <span>na exceção.</span></h2>
          <p>O padrão global dá escala. O override local preserva a autonomia de cada organização sem duplicar código.</p>
        </div>
        <div class="feature-layout">
          <article class="feature-card feature-main"><div class="feature-top"><span class="feature-icon">⌘</span><span class="feature-tag">multi-OM real</span></div><h3>Uma base comum.<br>Configurações que respeitam o contexto.</h3><p>Cadastre organizações com isolamento de dados. Cada OM mantém suas próprias variáveis, scripts e bundles, com possibilidade de herdar o padrão global.</p><div class="feature-line"><span>global</span><i></i><span>local</span><i></i><span>efetivo</span></div></article>
          <div class="feature-stack"><article class="feature-card"><div class="feature-top"><span class="feature-icon small">↺</span><span class="feature-tag">versionamento</span></div><h3>Histórico sem perder o caminho de volta</h3><p>Factory, GAP Default e Local OM. Reative versões e reverta para fábrica preservando o histórico.</p></article><article class="feature-card"><div class="feature-top"><span class="feature-icon small">◌</span><span class="feature-tag">automação</span></div><h3>Execução assistida ou desassistida</h3><p>Bundles únicos, com variáveis aplicadas, ordem oficial dos módulos e modo <code>NON_INTERACTIVE</code>.</p></article></div>
        </div>
      </section>

      <section class="section governance-section" id="governanca" aria-labelledby="governance-title">
        <div class="governance-copy"><div class="section-kicker">04 / governança de versões</div><h2 id="governance-title">O estado efetivo<br>não é um <span>mistério.</span></h2><p>Para cada script, o sistema resolve a versão que realmente será executada seguindo uma precedência explícita. Menos suposição. Mais previsibilidade.</p><a class="text-link" href="#implantacao">Entender a implantação <span>↗</span></a></div>
        <div class="version-ladder" aria-label="Precedência das versões de script"><div class="ladder-item active"><span>01</span><div><strong>Override local da OM</strong><small>Exceção controlada para uma organização</small></div><b>efetivo</b></div><div class="ladder-item"><span>02</span><div><strong>GAP Default</strong><small>Padrão global para as OMs sem override</small></div></div><div class="ladder-item"><span>03</span><div><strong>Factory</strong><small>Versão original preservada</small></div></div><div class="ladder-item"><span>04</span><div><strong>Conteúdo base</strong><small>Fallback do catálogo de scripts</small></div></div></div>
      </section>

      <section class="section bundles-section" id="bundles" aria-labelledby="bundles-title">
        <div class="section-kicker">distribuição</div>
        <div class="split-heading">
          <h2 id="bundles-title">Bundles disponíveis<br><span>para download</span></h2>
          <p>Arquivos publicados pelo painel administrativo. O conteúdo é específico para cada organização.</p>
        </div>
        <div class="bundle-panel">
          <div class="bundle-panel-head">
            <span>PUBLICADOS RECENTEMENTE</span>
            <span id="bundle-status" class="bundle-status-label">Carregando...</span>
          </div>
          <div class="table-scroll">
            <table class="public-table">
              <thead>
                <tr>
                  <th>Arquivo</th>
                  <th>Organização</th>
                  <th>Descrição</th>
                  <th>Scripts</th>
                  <th>Gerado em</th>
                  <th><span class="sr-only">Ação</span></th>
                </tr>
              </thead>
              <tbody id="bundles-tbody">
                <tr><td colspan="6" class="table-state"><span class="loader" aria-hidden="true"></span> Carregando bundles...</td></tr>
              </tbody>
            </table>
          </div>
        </div>
        <p class="section-note">Novos bundles são gerados no <a href="/login.html">painel administrativo</a>.</p>
      </section>

      <section class="section transparency-section" id="transparencia" aria-labelledby="transparency-title">
        <div class="section-kicker">05 / transparência para TI</div>
        <div class="split-heading"><h2 id="transparency-title">Pronto para avançar,<br>sem esconder o que <span>falta.</span></h2><p>O MVP está funcional em nível de aplicação e gestão. A validação assistida é a próxima etapa — com integração AD real e controles de segurança críticos no centro da evolução.</p></div>
        <div class="status-board"><div class="status-main"><div class="status-label"><span class="status-dot amber"></span> status atual</div><strong>MVP funcional<br>avançado</strong><p>Principais funcionalidades implementadas e operacionais.</p><div class="progress"><span style="width: 78%"></span></div><small>base funcional consolidada</small></div><div class="status-list"><div class="status-row"><span class="status-icon done">✓</span><div><strong>Gestão e geração</strong><small>Autenticação, OMs, variáveis, bundles e auditoria.</small></div><b>operacional</b></div><div class="status-row"><span class="status-icon warn">!</span><div><strong>Validação de integração</strong><small>Teste final com Active Directory real ainda previsto.</small></div><b>próximo passo</b></div><div class="status-row"><span class="status-icon warn">!</span><div><strong>Hardening</strong><small>CSRF, CORS, integridade de bundle, SSL do agente e criptografia.</small></div><b>prioridade P0/P1</b></div></div></div>
      </section>

      <section class="section deploy-section" id="implantacao" aria-labelledby="deploy-title">
        <div class="deploy-heading"><div class="section-kicker">06 / implantação</div><h2 id="deploy-title">Comece no seu<br>próprio <span>servidor.</span></h2><p>O projeto foi desenhado para Linux, Apache ou Nginx, PHP 8+ e PostgreSQL local. A documentação cobre instalação, permissões, operação e verificação.</p></div>
        <div class="code-card"><div class="code-top"><span><i></i><i></i><i></i></span><small>quick-start.sh</small><button class="copy-button" type="button" data-copy="sudo apt install -y apache2 php php-pgsql php-mbstring php-curl php-json php-xml php-gd postgresql postgresql-contrib git python3 python3-requests jq">copiar</button></div><pre><code><span class="code-comment"># dependências do servidor</span>
<span class="code-command">sudo apt install -y</span> apache2 php php-pgsql \
  php-mbstring php-curl php-json php-xml php-gd \
  postgresql postgresql-contrib git python3 jq

<span class="code-comment"># gerar o catálogo com os 22 scripts Core</span>
<span class="code-command">python3</span> install/gen_insert_core.py</code></pre><div class="code-foot"><span>Debian / Ubuntu recomendado</span><span>Apache ou Nginx</span></div></div>
      </section>

      <section class="section download-section" id="download" aria-labelledby="download-title">
        <div class="section-kicker">cliente da estação</div>
        <div class="split-heading">
          <h2 id="download-title">Agente SeederLinux<br><span>para check-in</span></h2>
          <p>Baixe o agente Python para o check-in e o recebimento de bundles da estação.</p>
        </div>
        <div class="download-actions">
          <a class="button button-primary" href="/api/download.php?file=agent.py">Baixar agent.py <span aria-hidden="true">↓</span></a>
          <a class="button button-outline" href="https://github.com/Toledo-JC/SeederLinux_14" target="_blank" rel="noopener">Ver projeto no GitHub <span aria-hidden="true">↗</span></a>
        </div>
      </section>

      <section class="final-cta" aria-labelledby="cta-title"><div class="cta-glow"></div><div class="section-kicker">uma base para operações previsíveis</div><h2 id="cta-title">Leve clareza para<br>a sua <span>próxima estação.</span></h2><p>Padronização, controle de versões, isolamento por organização e auditoria completa em uma plataforma local.</p><div class="cta-actions"><a class="button button-primary" href="#bundles">Ver bundles disponíveis <span aria-hidden="true">↗</span></a><a class="button button-outline" href="#topo">Voltar ao início <span aria-hidden="true">↑</span></a></div></section>
    </main>

    <footer class="site-footer"><a class="brand footer-brand" href="#topo"><img class="brand-logo" src="/assets/images/seederlinux-logo.png" alt=""><span>Seeder<span>Linux</span> <em>Lite</em></span></a><p>Provisionamento Linux com previsibilidade, rastreabilidade e eficiência.</p><div class="footer-meta"><span>PHP · PostgreSQL · Bash · Python</span><span>documentação técnica baseada no projeto</span><span>© <span id="current-year"></span> SeederLinux Lite</span></div></footer>
  </div>
  <div class="toast" role="status" aria-live="polite">Comando copiado para a área de transferência.</div>
  <script src="/public/assets/js/script.js"></script>
</body>
</html>
