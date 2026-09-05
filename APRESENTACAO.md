# SeederLinux Lite

## Apresentação Técnica

O **SeederLinux Lite** é uma plataforma centralizada para **provisionamento, padronização e gestão contínua de estações Linux em ambientes corporativos e militares multi-organizacionais (OM)**.

Ele substitui scripts soltos e configurações manuais por um painel web que gera **bundles autônomos de instalação**, totalmente adaptados a cada organização, reduzindo drasticamente o tempo de preparação de máquinas e os erros operacionais.

---

## 1. Problema que resolve

Em ambientes com dezenas ou centenas de estações Linux, a configuração manual gera:

- Inconsistência entre máquinas da mesma organização.
- Dificuldade para replicar configurações entre unidades diferentes.
- Falta de rastreabilidade sobre quem alterou o quê.
- Retrabalho na instalação de pacotes, integração AD, impressoras, proxy e identidade visual.
- Impossibilidade de aplicar políticas diferentes por organização sem duplicar código.

O SeederLinux Lite resolve esses problemas transformando a preparação de uma estação em um **processo controlado, versionado e auditável**.

---

## 2. Visão geral do sistema

A plataforma é composta por:

- **Painel administrativo web** para gestão de OMs, variáveis, scripts e bundles.
- **Página pública** para download de bundles e agente.
- **Motor de geração de bundle** que concatena scripts Bash e substitui variáveis.
- **Banco PostgreSQL local** para armazenar organizações, variáveis, versões de scripts e auditoria.
- **Agente Python** para check-in periódico das estações.

---

## 3. Arquitetura

| Camada | Tecnologia |
|--------|------------|
| Backend | PHP 8+ monolítico (`api/index.php`) |
| Banco de dados | PostgreSQL 16+ local |
| Frontend | HTML5 + CSS3 + JavaScript vanilla |
| Scripts de provisionamento | Bash 5+ (23 módulos core) |
| Agente | Python 3 |

A arquitetura foi desenhada para **não depender de serviços cloud nem frameworks JS pesados**, garantindo:

- Instalação simples em servidores locais.
- Baixa superfície de dependências externas.
- Facilidade de auditoria e manutenção.
- Funcionamento offline após a geração do bundle.

---

## 4. Funcionalidades atuais

### 4.1 Gestão multi-organizacional

- Cadastro de múltiplas OMs com isolamento total de dados.
- Cada OM possui suas próprias variáveis, scripts e bundles.
- Soft-delete com possibilidade de reativação.
- Perfis de acesso:
  - `admin_gap` — gestão global.
  - `operador_om` — restrito à sua organização.
  - `auditor` — leitura e consulta.

### 4.2 Catálogo de variáveis tipadas

São suportados tipos como:

- String, booleano, inteiro, array, URL, IP, senha, select, imagem e JSON.

Cada organização pode sobrescrever os valores padrão sem afetar as demais.

Exemplos de variáveis gerenciadas:

- Domínio, DCs, DNS, NTP, proxy, OU, grupos AD.
- URLs de repositórios, OCS Inventory, GLPI, compartilhamentos.
- Wallpapers, logos, greeters, tema.
- Toggles para instalação de pacotes legados, Java 8, Firefox 52 ESR, OnlyOffice, Chrome, Chromium etc.

### 4.3 Módulos Core de provisionamento

O sistema utiliza **23 scripts Bash Core** com ordem de execução oficial:

| Ordem | Script | Responsabilidade |
|---:|---|---|
| 1 | `core_dns.sh` | DNS, NTP e hostname |
| 2 | `core_repositories.sh` | Repositórios APT |
| 3 | `core_packages.sh` | Pacotes essenciais |
| 4 | `core_legados.sh` | Java 8 e Firefox 52 ESR |
| 5 | `core_apps.sh` | OnlyOffice, Chrome, Chromium |
| 6 | `core_domain.sh` | Ingresso no AD (SSSD/Winbind) |
| 7 | `core_ssh.sh` | SSH e AllowGroups |
| 8 | `core_browser.sh` | Políticas de navegadores |
| 9 | `core_inventory.sh` | Agente OCS Inventory |
| 10 | `core_printers.sh` | CUPS e impressoras |
| 11 | `core_vnc.sh` | Acesso remoto VNC |
| 12 | `core_conky.sh` | Monitor Conky |
| 13 | `core_config.sh` | Configurações persistentes |
| 14 | `core_branding.sh` | Identidade visual |
| 15 | `core_logon.sh` | Logon do usuário |
| 16 | `core_password_change.sh` | Troca de senha AD |
| 17 | `core_logoff.sh` | Logoff do usuário |
| 18 | `core_session_lightdm.sh` | Sessão LightDM |
| 19 | `core_session_gdm3.sh` | Sessão GDM3 |
| 20 | `core_session_sddm.sh` | Sessão SDDM |
| 21 | `core_agent.sh` | Agente SeederLinux |
| 22 | `core_proxy.sh` | Proxy do sistema |

### 4.4 Geração de bundle

O bundle gerado é um **script shell único e autônomo** que:

- Valida execução como root.
- Aplica variáveis da OM.
- Executa os 23 módulos na ordem correta.
- Respeita o modo **não interativo** (`NON_INTERACTIVE`).
- Sanitiza automaticamente valores críticos.
- Inclui metadados de versão de cada script.

### 4.5 Versionamento de scripts

O sistema implementa **versionamento em três níveis**:

- **Factory:** versão original imutável.
- **GAP Default:** versão global aplicada a todas as OMs sem override.
- **Local OM:** versão específica de uma organização.

Recursos:

- Histórico completo de versões globais e locais.
- Visualização de conteúdo.
- Reativação de versões inativas.
- Exclusão controlada, apenas por `admin_gap`, nunca para factory.
- Reversão para fábrica com preservação de histórico.

### 4.6 Auditoria

- Todas as ações relevantes são registradas.
- Perfis com visibilidade restrita por OM.
- Classificação por severidade: Crítico, Importante, Informativo.
- Abas por categoria: Autenticação, Organizações, Usuários, Scripts, Bundles, Assets, Configurações.
- Filtros por período e severidade.
- Exportação CSV/JSON para admin_gap.
- Detalhes legíveis: quem, quando, o quê.

### 4.7 Interface web

- Painel administrativo com tema **claro/escuro**.
- Busca e filtro de variáveis.
- Tooltips de preenchimento.
- Feedback visual via toasts.
- Galeria de imagens para logos e wallpapers.
- Tabelas responsivas e organizadas.

### 4.8 Segurança e sanidade

- Senhas em base64 no bundle.
- Sanitização de URLs, IPs, NTP e grupos SSH.
- `--no-check-certificate` para ambientes com PKI interna.
- Proteção de diretórios sensíveis no Apache/Nginx.
- Suporte a execução desassistida.

---

## 5. Diferenciais

- **Multi-OM real:** cada unidade pode ter suas próprias versões de scripts e variáveis.
- **Rastreabilidade completa:** auditoria detalhada.
- **Zero dependência de nuvem:** tudo roda localmente.
- **Bundle portável:** pode ser executado em máquina limpa sem acesso ao painel.
- **Modularidade:** novos scripts Core podem ser adicionados sem reestruturar o sistema.
- **Governança de versões:** fábrica, GAP e local bem definidos.

---

## 6. Roadmap / Próximas implementações

### Em desenvolvimento

- Ajustes finos de UI/históricos.
- Validação em ambiente AD real.
- Expansão dos filtros de auditoria.

### Planejado

- **Exportação/importação de perfil da OM** em JSON.
- **Rotação automática de logs de auditoria** (mensal/90 dias).
- **Sincronização de scripts via interface** com GitHub.
- **Validação inline de variáveis críticas** (IP, URL, domínio, porta).
- **Drag and drop de imagens** na galeria.
- **Rate limiting e proteção CSRF**.
- **Painel de estações com status em tempo real**.
- **Agente background** para políticas dinâmicas (wallpaper, proxy, certificados) sem depender do logon.
- **Mirror de repositórios APT** integrado.
- **SeederHub** para compartilhamento federado de módulos entre GAPs/OMs.

---

## 7. Requisitos de implantação

- Linux (Debian/Ubuntu recomendado).
- Apache ou Nginx com PHP 8+ e módulo `pdo_pgsql`.
- PostgreSQL 16+.
- Python 3 para o agente.
- Acesso de rede para as estações baixarem o bundle (ou distribuição por mídia).

---

## 8. Conclusão

O **SeederLinux Lite** é a evolução natural dos antigos scripts soltos de provisionamento Linux. Ele entrega:

- Padronização,
- Controle de versões,
- Isolamento por organização,
- Auditoria completa,
- Operação assistida ou desassistida.

Para equipes de TI que gerenciam múltiplas unidades e precisam de **previsibilidade, rastreabilidade e eficiência**, o SeederLinux Lite é a base ideal para automação de estações Linux em ambientes críticos.
