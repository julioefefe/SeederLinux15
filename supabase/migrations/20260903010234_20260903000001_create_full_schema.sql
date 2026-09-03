-- ============================================================================
-- SeederLinux Lite - Full Database Schema
-- ============================================================================

-- Table 1: organizations
CREATE TABLE IF NOT EXISTS organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    acronym VARCHAR(20) NOT NULL,
    domain VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    serial_config INTEGER DEFAULT 1,
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO organizations (id, name, acronym, domain, description)
VALUES (1, 'OM Padrao', 'OM', 'om.local', 'Organizacao padrao do sistema')
ON CONFLICT (id) DO NOTHING;

-- Table 2: users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(200),
    email VARCHAR(200),
    role VARCHAR(50) NOT NULL DEFAULT 'operador_om',
    organization_id INTEGER REFERENCES organizations(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, password_hash, full_name, email, role, organization_id)
VALUES ('admin', '$2y$12$aclfbpmKYX0DoMcu8EmQeO1xyziOBv9/WjuWR6y3/ovgF74QTaLhC', 'Administrator', 'admin@seeder.local', 'admin_gap', NULL)
ON CONFLICT (username) DO NOTHING;

-- Table 3: user_tokens
CREATE TABLE IF NOT EXISTS user_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL DEFAULT (NOW() + INTERVAL '24 hours'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_tokens_user ON user_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_user_tokens_expires ON user_tokens(expires_at);

-- Table 4: variable_definitions
CREATE TABLE IF NOT EXISTS variable_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    placeholder VARCHAR(150) UNIQUE,
    description TEXT,
    type VARCHAR(50) DEFAULT 'string',
    category VARCHAR(100),
    is_required BOOLEAN DEFAULT false,
    default_value TEXT,
    display_order INTEGER DEFAULT 0
);

ALTER TABLE organizations DROP CONSTRAINT IF EXISTS organizations_acronym_key;
DROP INDEX IF EXISTS organizations_acronym_key;
CREATE UNIQUE INDEX IF NOT EXISTS idx_organizations_acronym_active ON organizations (acronym) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_var_defs_category ON variable_definitions(category);
CREATE INDEX IF NOT EXISTS idx_var_defs_type ON variable_definitions(type);

-- Table 5: organization_variables
CREATE TABLE IF NOT EXISTS organization_variables (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    variable_id INTEGER NOT NULL REFERENCES variable_definitions(id) ON DELETE CASCADE,
    value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, variable_id)
);

CREATE INDEX IF NOT EXISTS idx_org_vars_org ON organization_variables(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_vars_var ON organization_variables(variable_id);

-- Table 6: scripts
CREATE TABLE IF NOT EXISTS scripts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    filename VARCHAR(200),
    description TEXT,
    content TEXT NOT NULL,
    is_core BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    execution_order INTEGER DEFAULT 0,
    version INTEGER DEFAULT 1,
    organization_id INTEGER REFERENCES organizations(id) ON DELETE CASCADE,
    current_version_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_scripts_filename ON scripts(filename);
CREATE INDEX IF NOT EXISTS idx_scripts_core ON scripts(is_core, execution_order);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'scripts_filename_key') THEN
        ALTER TABLE scripts ADD CONSTRAINT scripts_filename_key UNIQUE (filename);
    END IF;
END $$;

-- Table 6b: script_versions
CREATE TABLE IF NOT EXISTS script_versions (
    id SERIAL PRIMARY KEY,
    script_id INTEGER NOT NULL REFERENCES scripts(id) ON DELETE CASCADE,
    version_name VARCHAR(200) NOT NULL,
    version_number INTEGER NOT NULL,
    content TEXT NOT NULL,
    changelog TEXT DEFAULT '',
    version_type VARCHAR(20) NOT NULL DEFAULT 'factory' CHECK (version_type IN ('factory', 'gap_default', 'om_specific')),
    organization_id INTEGER REFERENCES organizations(id),
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(script_id, version_number)
);

CREATE INDEX IF NOT EXISTS idx_script_versions_script ON script_versions(script_id);
CREATE INDEX IF NOT EXISTS idx_script_versions_type ON script_versions(version_type);
CREATE INDEX IF NOT EXISTS idx_script_versions_org ON script_versions(organization_id);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'scripts_current_version_id_fkey' AND table_name = 'scripts') THEN
        ALTER TABLE scripts ADD CONSTRAINT scripts_current_version_id_fkey
            FOREIGN KEY (current_version_id) REFERENCES script_versions(id);
    END IF;
END $$;

-- Table 6c: om_script_versions
CREATE TABLE IF NOT EXISTS om_script_versions (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    script_id INTEGER NOT NULL REFERENCES scripts(id) ON DELETE CASCADE,
    version_id INTEGER REFERENCES script_versions(id) ON DELETE CASCADE,
    content TEXT,
    execution_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    version_number INTEGER NOT NULL DEFAULT 0,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_om_script_versions_org ON om_script_versions(organization_id);
CREATE INDEX IF NOT EXISTS idx_om_script_versions_script ON om_script_versions(script_id);
CREATE INDEX IF NOT EXISTS idx_om_script_versions_active ON om_script_versions(organization_id, script_id, is_active);

-- Table 7: deploy_bundles
CREATE TABLE IF NOT EXISTS deploy_bundles (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    filename VARCHAR(255),
    description TEXT,
    content TEXT NOT NULL,
    script_ids TEXT,
    scripts_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_deploy_bundles_org ON deploy_bundles(organization_id);
CREATE INDEX IF NOT EXISTS idx_deploy_bundles_date ON deploy_bundles(generated_at DESC);
CREATE INDEX IF NOT EXISTS idx_bundles_org_active_date ON deploy_bundles(organization_id, is_active, generated_at DESC);

-- Table 8: stations
CREATE TABLE IF NOT EXISTS stations (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id) ON DELETE SET NULL,
    hostname VARCHAR(200),
    ip_address VARCHAR(50),
    mac_address VARCHAR(50),
    os_name VARCHAR(100),
    os_version VARCHAR(50),
    last_checkin TIMESTAMP,
    status VARCHAR(50) DEFAULT 'never_connected',
    configuration_serial INTEGER DEFAULT 0,
    token TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stations_org ON stations(organization_id);
CREATE INDEX IF NOT EXISTS idx_stations_token ON stations(token);
CREATE INDEX IF NOT EXISTS idx_stations_checkin ON stations(last_checkin DESC);

-- Table 9: audit_events
CREATE TABLE IF NOT EXISTS audit_events (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id) ON DELETE SET NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    entity VARCHAR(50) NOT NULL,
    entity_id INTEGER,
    action VARCHAR(50) NOT NULL,
    details JSONB DEFAULT '{}',
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_events_org ON audit_events(organization_id);
CREATE INDEX IF NOT EXISTS idx_audit_events_user ON audit_events(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_events_entity ON audit_events(entity, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_events_date ON audit_events(created_at DESC);

-- Enable RLS on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE variable_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_variables ENABLE ROW LEVEL SECURITY;
ALTER TABLE scripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE script_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE om_script_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE deploy_bundles ENABLE ROW LEVEL SECURITY;
ALTER TABLE stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- RLS policies: the PHP backend connects with the service role (bypasses RLS).
-- For anon/authenticated browser clients, allow read on public data only.
CREATE POLICY "read_organizations" ON organizations FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "read_variable_definitions" ON variable_definitions FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "read_scripts" ON scripts FOR SELECT TO anon, authenticated USING (is_active = true);
CREATE POLICY "read_deploy_bundles" ON deploy_bundles FOR SELECT TO anon, authenticated USING (is_active = true);
CREATE POLICY "read_settings" ON settings FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "read_stations" ON stations FOR SELECT TO anon, authenticated USING (true);

-- Variable catalog seed
INSERT INTO variable_definitions (name, placeholder, description, type, category, is_required, default_value, display_order) VALUES
('DOMINIO', '{{DOMINIO}}', 'Dominio AD completo', 'domain', 'dominio', TRUE, 'om.local', 1),
('DOMINIO_NETBIOS', '{{DOMINIO_NETBIOS}}', 'Nome NetBIOS do dominio', 'netbios', 'dominio', TRUE, 'OM', 2),
('DC_IP', '{{DC_IP}}', 'IP do Controlador de Dominio', 'ip', 'dominio', TRUE, '10.0.0.1', 3),
('DC_SECUNDARIO_IP', '{{DC_SECUNDARIO_IP}}', 'IP do Controlador de Dominio secundario', 'ip', 'dominio', FALSE, '10.0.0.2', 4),
('DNS_INTERNET', '{{DNS_INTERNET}}', 'DNS publico para internet', 'ip', 'rede', TRUE, '8.8.8.8', 5),
('DNS_PRIMARIO', '{{DNS_PRIMARIO}}', 'DNS primario', 'ip', 'rede', TRUE, '10.0.0.1', 6),
('DNS_SECUNDARIO', '{{DNS_SECUNDARIO}}', 'DNS secundario', 'ip', 'rede', FALSE, '10.0.0.2', 7),
('NTP_SERVER', '{{NTP_SERVER}}', 'Servidor NTP', 'ip', 'dominio', FALSE, 'pool.ntp.org', 8),
('OU_PADRAO', '{{OU_PADRAO}}', 'OU padrao no AD', 'string', 'dominio', FALSE, 'OU=Estacoes,DC=om,DC=local', 9),
('GRUPO_ADMIN', '{{GRUPO_ADMIN}}', 'Grupo admin do dominio', 'string', 'dominio', TRUE, 'Domain Admins', 10),
('AUTH_METHOD', '{{AUTH_METHOD}}', 'Metodo de autenticacao', 'select', 'dominio', FALSE, 'sssd', 11),
('OFFLINE_AUTH_ENABLED', '{{OFFLINE_AUTH_ENABLED}}', 'Habilitar autenticacao offline', 'boolean', 'dominio', FALSE, 'true', 12),
('OFFLINE_AUTH_DAYS', '{{OFFLINE_AUTH_DAYS}}', 'Dias para cache offline', 'string', 'dominio', FALSE, '30', 13),
('ADMIN_PASSWORD_B64', '{{ADMIN_PASSWORD_B64}}', 'Senha admin (base64)', 'password', 'dominio', FALSE, '', 14),
('BASE_URL', '{{BASE_URL}}', 'URL base do repositorio', 'url', 'rede', TRUE, 'https://seederlinux.om.local', 20),
('REPOSITORY_MODE', '{{REPOSITORY_MODE}}', 'Modo de repositorio', 'select', 'repositorios', TRUE, 'MIRROR', 21),
('REPOSITORY_URL', '{{REPOSITORY_URL}}', 'URL do repositorio espelho', 'url', 'repositorios', FALSE, '', 22),
('REPOSITORY_FALLBACK', '{{REPOSITORY_FALLBACK}}', 'URL de fallback', 'url', 'repositorios', FALSE, 'http://deb.debian.org/debian', 23),
('REPOSITORY_DEBIAN_ENABLED', '{{REPOSITORY_DEBIAN_ENABLED}}', 'Habilitar mirror Debian', 'boolean', 'repositorios', FALSE, 'false', 24),
('REPOSITORY_DEBIAN_URL', '{{REPOSITORY_DEBIAN_URL}}', 'URL mirror Debian', 'url', 'repositorios', FALSE, '', 25),
('REPOSITORY_UBUNTU_ENABLED', '{{REPOSITORY_UBUNTU_ENABLED}}', 'Habilitar mirror Ubuntu', 'boolean', 'repositorios', FALSE, 'false', 26),
('REPOSITORY_UBUNTU_URL', '{{REPOSITORY_UBUNTU_URL}}', 'URL mirror Ubuntu', 'url', 'repositorios', FALSE, '', 27),
('REPOSITORY_MINT_ENABLED', '{{REPOSITORY_MINT_ENABLED}}', 'Habilitar mirror Mint', 'boolean', 'repositorios', FALSE, 'false', 28),
('REPOSITORY_MINT_URL', '{{REPOSITORY_MINT_URL}}', 'URL mirror Mint', 'url', 'repositorios', FALSE, '', 29),
('REPOSITORY_ZORIN_ENABLED', '{{REPOSITORY_ZORIN_ENABLED}}', 'Habilitar mirror Zorin', 'boolean', 'repositorios', FALSE, 'false', 30),
('REPOSITORY_ZORIN_URL', '{{REPOSITORY_ZORIN_URL}}', 'URL mirror Zorin', 'url', 'repositorios', FALSE, '', 31),
('OCS_SERVER', '{{OCS_SERVER}}', 'Servidor OCS Inventory', 'url', 'inventario', TRUE, '', 30),
('OCS_TAG', '{{OCS_TAG}}', 'Tag OCS', 'string', 'inventario', TRUE, 'OM-ESTACOES', 31),
('GLPI_SERVER', '{{GLPI_SERVER}}', 'Servidor GLPI', 'url', 'inventario', FALSE, '', 32),
('INVENTORY_ENABLED', '{{INVENTORY_ENABLED}}', 'Habilitar inventario', 'boolean', 'inventario', FALSE, 'true', 33),
('PRINT_SERVER', '{{PRINT_SERVER}}', 'Servidor de impressao', 'ip', 'rede', FALSE, '', 40),
('DEFAULT_PRINTER', '{{DEFAULT_PRINTER}}', 'Impressora padrao', 'string', 'impressoras', FALSE, '', 41),
('PRINTERS', '{{PRINTERS}}', 'Lista de impressoras', 'tags', 'impressoras', FALSE, '', 42),
('PROXY_HTTP', '{{PROXY_HTTP}}', 'Proxy HTTP', 'ip', 'proxy', FALSE, '', 50),
('PROXY_PORTA', '{{PROXY_PORTA}}', 'Porta do proxy', 'port', 'proxy', FALSE, '', 51),
('PROXY_URL', '{{PROXY_URL}}', 'URL completa do proxy', 'url', 'proxy', FALSE, '', 52),
('PROXY_MODE', '{{PROXY_MODE}}', 'Modo de proxy', 'select', 'navegador', FALSE, 'NONE', 53),
('PAC_URL', '{{PAC_URL}}', 'URL do arquivo PAC', 'url', 'navegador', FALSE, '', 54),
('NO_PROXY', '{{NO_PROXY}}', 'Excecoes de proxy', 'tags', 'navegador', FALSE, 'localhost,127.0.0.1,om.local', 55),
('HOMEPAGE', '{{HOMEPAGE}}', 'Pagina inicial', 'url', 'navegador', FALSE, 'www.om.local', 60),
('GRUPO_ADMIN_AD', '{{GRUPO_ADMIN_AD}}', 'Grupo admin AD para sudo', 'string', 'seguranca', TRUE, 'Dominio\ Admins', 70),
('GRUPO_ADMIN_LINUX', '{{GRUPO_ADMIN_LINUX}}', 'Grupo local para sudo', 'string', 'seguranca', TRUE, 'linux-admins', 71),
('GRUPO_DASTI', '{{GRUPO_DASTI}}', 'Grupo DASTI para sudo', 'string', 'seguranca', FALSE, '_DASTI', 72),
('OM_ACRONYM', '{{OM_ACRONYM}}', 'Sigla da OM', 'string', 'branding', FALSE, 'OM', 80),
('OM_NAME', '{{OM_NAME}}', 'Nome da OM', 'string', 'branding', FALSE, 'Organizacao Padrao', 81),
('DISPLAY_NAME', '{{DISPLAY_NAME}}', 'Nome de exibicao', 'string', 'branding', FALSE, 'OM Padrao', 82),
('WALLPAPER_URL', '{{WALLPAPER_URL}}', 'URL do wallpaper', 'image', 'assets', FALSE, '/assets/wallpapers/default.jpg', 83),
('WALLPAPER_LOGIN_URL', '{{WALLPAPER_LOGIN_URL}}', 'URL wallpaper login', 'image', 'assets', FALSE, '', 84),
('LOGO_URL', '{{LOGO_URL}}', 'URL do logo', 'image', 'assets', FALSE, '/assets/logos/default.png', 85),
('GREETER_URL', '{{GREETER_URL}}', 'URL do greeter', 'image', 'assets', FALSE, '', 86),
('THEME', '{{THEME}}', 'Tema GTK', 'string', 'branding', FALSE, 'DEFAULT', 87),
('CONKY_PROFILE', '{{CONKY_PROFILE}}', 'Perfil Conky', 'select', 'monitoramento', FALSE, 'default', 88),
('CONKY_CONFIG', '{{CONKY_CONFIG}}', 'Configuracao Conky', 'json_conky', 'monitoramento', FALSE, '{"position":"top_right","transparent":true,"color_text":"#FFFFFF","color_bg":"#000000","font_size":10,"gap_x":10,"gap_y":40,"show_cpu":true,"show_ram":true,"show_disk":true,"disk_partition":"/","show_network":true,"network_interface":"eth0","show_top_processes":true,"show_datetime":true,"update_interval":1.0}', 89),
('DESKTOP_ENV', '{{DESKTOP_ENV}}', 'Ambiente grafico', 'select', 'ambiente', FALSE, '', 90),
('DISPLAY_MANAGER', '{{DISPLAY_MANAGER}}', 'Gerenciador de sessao', 'select', 'ambiente', FALSE, '', 91),
('INSTALL_DESKTOP', '{{INSTALL_DESKTOP}}', 'Instalar ambiente grafico', 'boolean', 'ambiente', FALSE, 'false', 92),
('DC_IP_LIST', '{{DC_IP_LIST}}', 'Lista de IPs dos DCs', 'string', 'dominio', FALSE, '10.0.0.1,10.0.0.2', 93),
('ADMIN_USERNAME', '{{ADMIN_USERNAME}}', 'Usuario admin do dominio', 'string', 'dominio', FALSE, 'Administrator', 94),
('SERVIDOR_ARQUIVOS', '{{SERVIDOR_ARQUIVOS}}', 'Servidor de arquivos', 'ip', 'arquivos', FALSE, '', 100),
('COMPARTILHAMENTOS', '{{COMPARTILHAMENTOS}}', 'Lista de compartilhamentos', 'tags', 'arquivos', FALSE, 'publico,usuarios,setores', 101),
('MOUNT_BASE', '{{MOUNT_BASE}}', 'Base de montagem', 'string', 'arquivos', FALSE, '/mnt/servidor', 102),
('INSTALL_ONLYOFFICE', '{{INSTALL_ONLYOFFICE}}', 'Instalar OnlyOffice', 'boolean', 'aplicacoes', FALSE, 'true', 110),
('INSTALL_CHROME', '{{INSTALL_CHROME}}', 'Instalar Chrome', 'boolean', 'aplicacoes', FALSE, 'true', 111),
('INSTALL_CHROMIUM', '{{INSTALL_CHROMIUM}}', 'Instalar Chromium', 'boolean', 'aplicacoes', FALSE, 'false', 112),
('INSTALL_JAVA8', '{{INSTALL_JAVA8}}', 'Instalar Java 8', 'boolean', 'aplicacoes', FALSE, 'false', 113),
('INSTALL_FIREFOX52', '{{INSTALL_FIREFOX52}}', 'Instalar Firefox 52 ESR', 'boolean', 'aplicacoes', FALSE, 'false', 114),
('INSTALL_PASSWORD_CHANGER', '{{INSTALL_PASSWORD_CHANGER}}', 'Instalar trocador de senha', 'boolean', 'aplicacoes', FALSE, 'true', 115),
('JAVA_EXCEPTIONS', '{{JAVA_EXCEPTIONS}}', 'Excecoes Java', 'array', 'seguranca', FALSE, '', 116),
('REMOVER_LIBREOFFICE', '{{REMOVER_LIBREOFFICE}}', 'Remover LibreOffice', 'boolean', 'aplicacoes', FALSE, 'false', 117),
('REMOTE_METHOD', '{{REMOTE_METHOD}}', 'Metodo de acesso remoto', 'select', 'acesso_remoto', FALSE, 'ssh', 120),
('SSH_PORT', '{{SSH_PORT}}', 'Porta SSH', 'port', 'acesso_remoto', FALSE, '22', 121),
('SSH_GROUPS', '{{SSH_GROUPS}}', 'Grupos com acesso SSH', 'array', 'seguranca', FALSE, 'linux-admins', 124),
('VNC_ENABLED', '{{VNC_ENABLED}}', 'Habilitar VNC', 'boolean', 'acesso_remoto', FALSE, 'false', 122),
('VNC_PASSWORD_B64', '{{VNC_PASSWORD_B64}}', 'Senha VNC (base64)', 'password', 'acesso_remoto', FALSE, '', 123),
('CERTIFICATE_BUNDLE', '{{CERTIFICATE_BUNDLE}}', 'URL do pacote de certificados', 'url', 'oculto', FALSE, '', 130),
('CERTIFICATE_AUTO_INSTALL', '{{CERTIFICATE_AUTO_INSTALL}}', 'Instalar certificados automaticamente', 'boolean', 'certificados', FALSE, 'true', 131),
('SEEDER_SERVER', '{{SEEDER_SERVER}}', 'URL do servidor SeederLinux', 'url', 'rede', FALSE, 'https://seederlinux.om.local', 140),
('INSTALL_AGENT', '{{INSTALL_AGENT}}', 'Instalar agente de check-in', 'boolean', 'agente', FALSE, 'true', 150),
('AGENT_NO_CHECK_CERT', '{{AGENT_NO_CHECK_CERT}}', 'Permitir cert autoassinado', 'boolean', 'agente', FALSE, 'true', 151),
('NON_INTERACTIVE', '{{NON_INTERACTIVE}}', 'Modo nao-interativo', 'boolean', 'avancado', FALSE, 'true', 160)
ON CONFLICT (name) DO NOTHING;

-- Seed: default values for OM Padrao (org id=1)
INSERT INTO organization_variables (organization_id, variable_id, value)
SELECT 1, id, COALESCE(default_value, '') FROM variable_definitions
ON CONFLICT (organization_id, variable_id) DO NOTHING;

INSERT INTO organization_variables (organization_id, variable_id, value)
SELECT 1, id, '10.0.0.1,10.0.0.2' FROM variable_definitions WHERE name = 'DC_IP_LIST'
ON CONFLICT (organization_id, variable_id) DO NOTHING;

INSERT INTO organization_variables (organization_id, variable_id, value)
SELECT 1, id, 'Administrator' FROM variable_definitions WHERE name = 'ADMIN_USERNAME'
ON CONFLICT (organization_id, variable_id) DO NOTHING;

INSERT INTO organization_variables (organization_id, variable_id, value)
SELECT 1, id, 'false' FROM variable_definitions WHERE name = 'INSTALL_DESKTOP'
ON CONFLICT (organization_id, variable_id) DO NOTHING;

INSERT INTO organization_variables (organization_id, variable_id, value)
SELECT 1, id, 'https://seederlinux.om.local' FROM variable_definitions WHERE name = 'SEEDER_SERVER'
ON CONFLICT (organization_id, variable_id) DO NOTHING;

INSERT INTO organization_variables (organization_id, variable_id, value)
SELECT 1, id, 'true' FROM variable_definitions WHERE name = 'NON_INTERACTIVE'
ON CONFLICT (organization_id, variable_id) DO NOTHING;