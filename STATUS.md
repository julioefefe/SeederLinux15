

# 📊 SeederLinux Lite — Documentação Técnica e Status do Projeto

**Data:** 18/08/2026  
**Versão:** MVP 1.0  

---

## 1. Visão Geral

O **SeederLinux Lite** é uma plataforma centralizada para provisionamento, padronização e gestão de estações Linux em ambientes militares multi-organizacionais (OMs). O sistema gera bundles autônomos de instalação, gerencia variáveis por organização, mantém versionamento de scripts e auditoria completa.

O projeto encontra-se em estágio **avançado de MVP funcional**, com as principais funcionalidades implementadas e operacionais. Os scripts de provisionamento estão estruturalmente prontos, mas ainda pendentes de validação prática em ambiente com Active Directory.

---

## 2. Funcionalidades Implementadas

| # | Funcionalidade | Status |
|---|----------------|--------|
| 1 | Autenticação com perfis `admin_gap`, `operador_om`, `auditor` | ✅ Funcional |
| 2 | Gestão de organizações (OMs) com isolamento de dados e soft-delete | ✅ Funcional |
| 3 | Catálogo de variáveis tipadas (string, boolean, integer, array, URL, IP, password, select, image, json) | ✅ Funcional |
| 4 | Variáveis por OM com sobrescrita de valores padrão | ✅ Funcional |
| 5 | 23 scripts Core com ordem oficial definida | ✅ Presente |
| 6 | Geração de bundle com substituição de placeholders `{{VARIAVEL}}` | ✅ Funcional |
| 7 | Sanitização de `SSH_GROUPS`, `DC_IP_LIST`, `NTP_SERVER`, `HOMEPAGE` e URLs de imagens | ✅ Implementado |
| 8 | Modo não interativo (`NON_INTERACTIVE`) no bundle e nos scripts | ✅ Implementado |
| 9 | Versionamento global (`gap_default`, `factory`) | ✅ Funcional |
| 10 | Overrides locais por OM (`om_script_versions`) com múltiplas versões | ✅ Funcional |
| 11 | Reverter global para fábrica sem apagar histórico | ✅ Corrigido |
| 12 | "Usar Default do Servidor" local preserva histórico | ✅ Corrigido |
| 13 | Histórico global e local com visualizar/reativar/deletar | ⚠️ Implementado, aguardando confirmação visual final |
| 14 | Metadados no bundle (`SCRIPTS INCLUÍDOS`) com origem e versão | ✅ Funcional |
| 15 | Upload de imagens (wallpaper, logo, greeter) com nomes aleatórios | ✅ Funcional |
| 16 | Galeria de imagens | ✅ Funcional |
| 17 | Tema claro/escuro no admin e na página pública | ✅ Funcional |
| 18 | Auditoria com registro de eventos, abas por categoria e severidade | ✅ Funcional |
| 19 | Página pública com listagem de bundles | ✅ Funcional |
| 20 | Agente Python de check-in | ✅ Implementado (não testado) |
| 21 | Exportar CSV/JSON da auditoria | ⚠️ Botões existentes, funcionalidade pode estar incompleta |
| 22 | Sincronização de scripts via script `seeder-sync-scripts.sh` | ✅ Script pronto, UI não implementada |
| 23 | Documentação README e SERVIDOR | ✅ Atualizados |

---

## 3. Auditoria de Segurança e Robustez

### P0 — Críticos

| # | Problema | Status |
|---|----------|--------|
| 1 | Senhas administrativas em Base64 (`ADMIN_PASSWORD_B64`, `VNC_PASSWORD_B64`) | ❌ Pendente — deve usar criptografia |
| 2 | Bundle executado sem verificação de integridade/assinatura | ❌ Pendente |
| 3 | Agente Python com SSL desabilitado (`no_check_certificate`) | ❌ Pendente |
| 4 | CORS aberto com `Access-Control-Allow-Origin: *` | ❌ Pendente |
| 5 | CSRF protection ausente em endpoints POST/PUT/DELETE | ❌ Pendente |
| 6 | Foreign key com `ON DELETE SET NULL` permite orfanato de usuários | ❌ Pendente |

### P1 — Altos

| # | Problema | Status |
|---|----------|--------|
| 1 | `handleDownloadBundle()` sem validação de escopo de organização | ✅ Corrigido |
| 2 | `requireAuth()` com O(n) token validation (DoS potential) | ❌ Pendente |
| 3 | Upload de wallpaper com `mkdir(0755)` | ❌ Pendente |
| 4 | Upload de script sem validação MIME | ❌ Pendente |
| 5 | XSS via `innerHTML` em diversos pontos do admin.js | ⚠️ Parcialmente corrigido |
| 6 | Rate limiting baseado apenas em IP | ❌ Pendente |
| 7 | Path traversal em uploads | ❌ Pendente |
| 8 | Race condition na geração de bundle | ❌ Pendente |
| 9 | Sem índice em `user_tokens.token_hash` | ❌ Pendente |
| 10 | Segredos em `.env` em texto puro | ❌ Pendente |
| 11 | Sem HTTPS enforcement / HSTS | ❌ Pendente |
| 12 | Sem CSP header | ❌ Pendente |
| 13 | Token de estação salvo em plain text | ❌ Pendente |
| 14 | Sem rate limiting em uploads | ❌ Pendente |
| 15 | Sem validação de tamanho de arquivo de script | ❌ Pendente |

### P2 — Médios

| # | Problema | Status |
|---|----------|--------|
| 1 | Sem retenção/rotação de `audit_events` | ❌ Pendente (planejado) |
| 2 | Sem validação de dependências circulares em scripts | ❌ Pendente |
| 3 | Sem assinatura criptográfica de bundles | ❌ Pendente |
| 4 | Sem logging detalhado de erros do bundle no agente | ❌ Pendente |
| 5 | `sanitizeInput()` apenas trim, sem validação de tipo/formato | ❌ Pendente |
| 6 | Timezone hardcoded | ❌ Pendente |
| 7 | Permissões de upload inconsistentes | ❌ Pendente |
| 8 | Lógica de bundle generation complexa e pouco modular | ❌ Pendente |
| 9 | Foreign keys inconsistentes | ❌ Pendente |
| 10 | Modal handlers não desmontam listeners | ❌ Pendente |
| 11 | Código duplicado em uploads e verificações de acesso | ❌ Pendente |
| 12 | Estado global JS sem namespacing | ❌ Pendente |
| 13 | Sem CHECK constraints em booleanos | ❌ Pendente |

---

## 4. Status dos Scripts Core

Os 23 scripts estão presentes e com a ordem oficial:

| Ordem | Script | Status |
|---:|---|---|
| 1 | `core_dns.sh` | ✅ Sintaxe OK, `NON_INTERACTIVE` aplicado; revisar `NTP_SERVER` |
| 2 | `core_repositories.sh` | ✅ OK |
| 3 | `core_packages.sh` | ✅ OK (universe antes do AD, instalação tolerante) |
| 4 | `core_legados.sh` | ✅ OK |
| 5 | `core_apps.sh` | ✅ OK |
| 6 | `core_domain.sh` | ⚠️ Crítico; SSSD com fallback Winbind; **não testado com AD real** |
| 7 | `core_ssh.sh` | ✅ OK |
| 8 | `core_browser.sh` | ✅ OK |
| 9 | `core_inventory.sh` | ✅ OK |
| 10 | `core_printers.sh` | ✅ OK |
| 11 | `core_vnc.sh` | ✅ OK |
| 12 | `core_conky.sh` | ✅ OK |
| 13 | `core_config.sh` | ✅ OK, sanitização de NTP pendente de confirmação |
| 14 | `core_branding.sh` | ✅ OK, `--no-check-certificate` presente |
| 15 | `core_logon.sh` | ✅ OK |
| 16 | `core_password_change.sh` | ✅ OK |
| 17 | `core_logoff.sh` | ✅ OK |
| 18 | `core_session_lightdm.sh` | ✅ OK, `return 0` no lugar de `exit` |
| 19 | `core_session_gdm3.sh` | ✅ OK |
| 20 | `core_session_sddm.sh` | ✅ OK |
| 21 | `core_agent.sh` | ✅ OK, `--no-check-certificate` presente |
| 22 | `core_proxy.sh` | ✅ OK |

---

## 5. Correções Recentes (já aplicadas)

- ✅ `isAdminGap()` reconhece papel legado `admin`.
- ✅ `log_audit` aceita `organization_id` opcional.
- ✅ Auditoria retorna `summary` legível.
- ✅ `handleUpdateVariables` registra nomes das variáveis e OM.
- ✅ `SSH_GROUPS` sanitizado (vírgula, underscore permitido).
- ✅ `DC_IP_LIST` montado automaticamente a partir de `DC_IP` e `DC_SECUNDARIO_IP`.
- ✅ `NTP_SERVER` sanitizado.
- ✅ Reversão de fábrica corrigida (não sobrescreve factory).
- ✅ Overrides locais múltiplos implementados.
- ✅ `handleSaveScriptOmVersion` cria nova linha em vez de sobrescrever.
- ✅ `handleResetScriptOmDefault` desativa em vez de apagar.
- ✅ `handleSetGapDefault` não altera `version_type` de factory.

---

## 6. Próximos Passos Recomendados

1. **Validar servidor**  
   Atualizar o servidor, reinstalar, e testar as últimas correções.

2. **Testar bundle em VM sem AD**  
   Executar até onde for possível, verificando `NON_INTERACTIVE` e scripts iniciais.

3. **Validar históricos global/local**  
   Testar reativação e deleção de versões.

4. **Implementar segurança P0/P1**  
   Priorizar CSRF, CORS, hash de integridade de bundle, SSL no agente, senhas criptografadas.

5. **Implementar melhorias funcionais**  
   Exportar/Importar configuração da OM, rotação de auditoria, sincronização via UI, validação inline.

6. **Teste final com AD real**  
   Provisionar VM Linux Mint (Cinnamon/MATE), validar ingresso no domínio, login AD, logon/logoff e agente.

---

## 7. Conclusão

O **SeederLinux Lite** está **funcional em nível de aplicação e gestão**, com as principais correções aplicadas. Os maiores riscos restantes são a **integração real com AD** e a **implementação de controles de segurança críticos**. O sistema está pronto para validação assistida e, com a conclusão dos itens P0/P1, estará apto para produção.

