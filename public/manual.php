<?php
$pageTitle = 'SeederLinux Lite | Manual de uso';
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Manual de uso do SeederLinux Lite: provisionamento de estações Linux padronizado, versionado e auditável.">
  <title><?= htmlspecialchars($pageTitle, ENT_QUOTES, 'UTF-8') ?></title>
  <style>
    :root {
      --bg: #f6f8fb; --card: #ffffff; --ink: #0d1b2e; --muted: #54687f;
      --line: #dbe4ee; --accent: #0d8f7e; --accent-soft: rgba(13,143,126,.1);
      --mono: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      --sans: 'Segoe UI', Inter, system-ui, -apple-system, sans-serif;
    }
    * { box-sizing: border-box; }
    body { margin: 0; background: var(--bg); color: var(--ink); font-family: var(--sans); line-height: 1.7; }
    .wrap { width: min(860px, calc(100% - 48px)); margin: 0 auto; padding: 40px 0 80px; }
    a { color: var(--accent); }
    .manual-top { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 40px; }
    .manual-brand { display: inline-flex; align-items: center; gap: 10px; color: var(--ink); text-decoration: none; font-weight: 800; font-size: 18px; letter-spacing: -.02em; }
    .manual-brand img { width: 32px; height: 32px; }
    .manual-brand span span { color: var(--accent); }
    .back-links { display: flex; gap: 18px; font-size: 14px; font-weight: 600; }
    h1 { font-size: clamp(30px, 4.5vw, 42px); line-height: 1.1; margin: 0 0 10px; letter-spacing: -.03em; }
    .intro { color: var(--muted); max-width: 620px; margin: 0 0 36px; }
    .toc { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 44px; }
    .toc a { padding: 8px 14px; border: 1px solid var(--line); border-radius: 999px; background: var(--card); text-decoration: none; font-size: 13px; font-weight: 600; }
    .toc a:hover { border-color: var(--accent); }
    section.step { margin-bottom: 44px; }
    .step-n { display: inline-flex; align-items: center; gap: 10px; font: 600 12px var(--mono); letter-spacing: .12em; text-transform: uppercase; color: var(--accent); }
    .step-n b { display: inline-grid; place-items: center; width: 30px; height: 30px; border-radius: 10px; background: var(--accent-soft); }
    h2 { font-size: 24px; margin: 12px 0 10px; letter-spacing: -.02em; }
    p { margin: 0 0 14px; }
    ul, ol { margin: 0 0 14px; padding-left: 22px; }
    li { margin-bottom: 6px; }
    .card { border: 1px solid var(--line); border-radius: 16px; background: var(--card); padding: 22px 26px; margin: 16px 0; }
    code { font-family: var(--mono); font-size: .9em; background: var(--accent-soft); padding: 2px 6px; border-radius: 6px; }
    pre { background: #0d1b2e; color: #d7e4f0; border-radius: 12px; padding: 16px 20px; overflow-x: auto; font-family: var(--mono); font-size: 13px; line-height: 1.8; }
    pre b { color: #75e6d0; }
    .note { border-left: 3px solid var(--accent); padding: 10px 16px; background: var(--accent-soft); border-radius: 0 10px 10px 0; font-size: 14.5px; }
    .manual-footer { margin-top: 60px; padding-top: 24px; border-top: 1px solid var(--line); color: var(--muted); font-size: 13.5px; display: flex; flex-wrap: wrap; gap: 8px 24px; justify-content: space-between; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="manual-top">
      <a class="manual-brand" href="/"><img src="/assets/images/seederlinux-logo.png" alt=""><span>Seeder<span>Linux</span> Lite — Manual</a>
      <div class="back-links"><a href="/">← Voltar ao início</a><a href="/login.html">Acessar o painel ↗</a></div>
    </div>

    <h1>Manual de uso</h1>
    <p class="intro">Como provisionar estações Linux de forma padronizada com o SeederLinux Lite: configure a organização, gere o bundle e execute na estação.</p>

    <nav class="toc" aria-label="Índice">
      <a href="#visao-geral">1. Visão geral</a>
      <a href="#primeiros-passos">2. Primeiros passos</a>
      <a href="#organizacoes">3. Organizações e variáveis</a>
      <a href="#gerando-bundle">4. Gerando um bundle</a>
      <a href="#executando">5. Executando na estação</a>
      <a href="#agente">6. Agente de check-in</a>
      <a href="#duvidas">7. Dúvidas e suporte</a>
    </nav>

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
          <li>Escolha os módulos (os 22 scripts Core: DNS, pacotes, domínio AD, navegador, inventário, sessões, proxy…) na ordem oficial.</li>
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
        <p class="note">Execute como root (<code>sudo</code>) e confirme o log final antes de liberar a estação para o usuário.</p>
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
</body>
</html>
