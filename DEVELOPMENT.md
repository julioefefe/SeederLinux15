# Desenvolvimento do SeederLinux

Guia para configurar o ambiente de desenvolvimento local.

## Pré-requisitos

✅ **Já instalados neste container:**
- PHP 8.0+
- Python 3.12+
- Git, cURL, jq
- Bash

⚠️ **Requer instalação externa:**
- PostgreSQL 12+ (servidor de banco de dados)
- Apache 2.4+ ou Nginx (para servir a aplicação)

## Configuração Rápida

### 1. Criar arquivo .env

```bash
cp .env.example .env
```

Configure as variáveis de banco de dados em `.env` conforme seu ambiente:

```ini
DB_HOST=localhost
DB_PORT=5432
DB_NAME=seederlinux
DB_USER=seeder
DB_PASS=seeder123
```

### 2. Configurar Banco de Dados (se usando PostgreSQL local)

```bash
# Criar usuário e banco
sudo -u postgres psql << EOF
CREATE USER seeder WITH PASSWORD 'seeder123';
CREATE DATABASE seederlinux OWNER seeder;
EOF

# Aplicar schema
sudo -u postgres psql seederlinux < install/schema.sql

# Importar scripts core (depois de gerar ou baixar)
sudo -u postgres psql seederlinux < install/insert_core_scripts.sql
```

### 3. Gerar Catálogo de Scripts Core

Quando adicionar ou modificar scripts em `scripts/core/`:

```bash
python3 install/gen_insert_core.py
```

Isso regenera `install/insert_core_scripts.sql` com os 22 scripts na ordem correta.

### 4. Servir Localmente (Desenvolvimento)

#### Opção A: PHP Built-in Server (teste rápido)

```bash
cd /workspaces/SeederLinux_13
php -S localhost:8000
```

Acesse: http://localhost:8000/login.html

#### Opção B: Apache Virtual Host

Ver instruções completas em `SERVIDOR.md`.

## Estrutura para Desenvolvimento

```
SeederLinux_13/
├── api/
│   └── index.php           # API endpoints
├── lib/
│   ├── config.php          # Configuração (lê .env)
│   ├── db.php              # Classe Database
│   └── functions.php       # Funções auxiliares
├── scripts/
│   └── core/               # 22 scripts de configuração
├── install/
│   ├── schema.sql          # Schema do banco
│   ├── gen_insert_core.py  # Gerador do catálogo
│   └── insert_core_scripts.sql  # Scripts gerados
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
├── admin.html, index.html, login.html  # Interfaces web
└── .env                    # Configuração local (criar)
```

## Tarefas Comuns de Desenvolvimento

### Adicionar novo script core

1. Criar arquivo em `scripts/core/core_novo.sh`
2. Rodar: `python3 install/gen_insert_core.py`
3. Verificar que o script aparece em `install/insert_core_scripts.sql`
4. Aplicar ao banco de dados se necessário

### Testar API localmente

```bash
# Exemplo de chamada à API
curl -X GET "http://localhost:8000/api/organizations"
```

### Executar testes

```bash
# Testes Python
python3 -m pytest backend/tests/

# Testes PHP
php -l api/index.php  # Verifica sintaxe
php -l lib/*.php      # Verifica arquivos lib
```

### Sincronizar scripts do GitHub

```bash
./install/seeder-sync-scripts.sh --server http://localhost:8000
```

## Troubleshooting

### "Fatal error: No code specified for platform"

Significa que a API não consegue conectar ao banco de dados. Verificar:
1. PostgreSQL está rodando
2. `.env` tem credenciais corretas
3. Banco de dados foi criado
4. Schema foi aplicado

### "404 Not Found" na API

Verificar:
1. DocumentRoot do Apache/Nginx aponta para a raiz do projeto
2. Módulos de rewrite estão habilitados
3. `.htaccess` está presente (Apache)

### Sessions não persistem

Verificar:
1. Diretório `storage/` existe e tem permissões de escrita
2. PHP consegue escrever logs em `storage/logs/`

## Variáveis de Ambiente Disponíveis

Consultar `lib/config.php` para lista completa. Principais:

- `DB_HOST` - Host PostgreSQL (padrão: localhost)
- `DB_PORT` - Porta PostgreSQL (padrão: 5432)
- `DB_NAME` - Nome do banco (padrão: seederlinux)
- `DB_USER` - Usuário do banco (padrão: seeder)
- `DB_PASS` - Senha do banco (padrão: seeder123)

## Próximos Passos

1. Configurar `.env` com suas credenciais PostgreSQL
2. Criar banco de dados e aplicar schema
3. Gerar catálogo de scripts: `python3 install/gen_insert_core.py`
4. Iniciar servidor local e acessar login.html
5. Ver `SERVIDOR.md` para deploy em produção

## Links Úteis

- [README.md](README.md) - Visão geral do projeto
- [SERVIDOR.md](SERVIDOR.md) - Configuração de servidor
- [lib/config.php](lib/config.php) - Definições de configuração
- [install/schema.sql](install/schema.sql) - Schema do banco de dados
