#!/bin/bash
# ============================================================================
# Core Script: core_logon.sh
# SeederLinux Lite - Logon MINIMALISTA (via autostart XDG)
# ============================================================================
# MUDANCA DE ARQUITETURA:
# A versao anterior era chamada pelo display manager via
# session-setup-script (LightDM) / PreSession (GDM3) / Xsetup (SDDM) -
# hooks que rodam como ROOT, ANTES da sessao grafica existir. Isso e
# documentado assim nos tres DMs: sem $HOME/$USER do usuario real e
# sem D-Bus de sessao, o que tornava suspeita a eficacia de tudo que
# dependia desses dois (montagem em $HOME, gsettings, etc).
#
# Agora o /usr/local/bin/seederlinux-logon roda via ENTRADA DE
# AUTOSTART XDG (/etc/xdg/autostart/), que e honrada por GNOME,
# Cinnamon, MATE, XFCE, KDE e LXDE de forma padronizada - executando
# DENTRO da sessao ja iniciada, como o proprio usuario, com $HOME,
# $USER e D-Bus corretos. Um mecanismo so para qualquer DE/DM.
#
# ESCOPO REDUZIDO (minimalista, conforme especificacao original):
# so o que precisa rodar em TODO login e e rapido (< 3s): montar
# compartilhamentos, impressora padrao, atalhos. Branding, tema,
# politicas de navegador, proxy, certificados etc. NAO rodam mais
# aqui - isso agora e responsabilidade do core_sync.sh (aplicador
# tipo GPO, rodando via timer systemd, independente de login).
#
# PRIVILEGIO: como o script agora roda como usuario comum (nao root),
# `mount`/`umount` dos compartilhamentos CIFS precisam de sudo. Uma
# regra sudoers bem restrita (so mount.cifs/umount na pasta de
# compartilhamentos + o binario seeder-sync, nada generico) e criada
# abaixo.
#
# Os placeholders VARIAVEL são substituídos automaticamente
# pelo sistema na geração do bundle.
# ============================================================================

set -e

echo "============================================================"
echo "15 - Logon minimalista (via autostart)"
echo "============================================================"

# ============================================================
# Variáveis
# ============================================================
SERVIDOR_ARQUIVOS="{{SERVIDOR_ARQUIVOS}}"
COMPARTILHAMENTOS="{{COMPARTILHAMENTOS}}"
MOUNT_BASE="{{MOUNT_BASE}}"
DEFAULT_PRINTER="{{DEFAULT_PRINTER}}"
HOMEPAGE="{{HOMEPAGE}}"
OM_ACRONYM="{{OM_ACRONYM}}"
DOMINIO_NETBIOS="{{DOMINIO_NETBIOS}}"

MOUNT_DIR="${MOUNT_BASE:-/mnt}"

# ============================================================
# 1. Regra sudoers restrita - mount/umount de CIFS (so na pasta de
#    compartilhamentos) e o binario seeder-sync (sem argumentos).
#    Nada mais e liberado por essa regra.
# ============================================================
echo ">>> Configurando sudoers restrito para logon..."
SUDOERS_FILE="/etc/sudoers.d/seederlinux-logon"
cat > "$SUDOERS_FILE" <<EOF
# SeederLinux - permissoes minimas para o logon do usuario (nao roda
# mais como root). Restrito a mount/umount de CIFS dentro de
# ${MOUNT_DIR} e ao disparo do seeder-sync - nada generico.
Cmnd_Alias SEEDERLINUX_MOUNT = /bin/mount -t cifs *, /usr/bin/mount -t cifs *
Cmnd_Alias SEEDERLINUX_UMOUNT = /bin/umount ${MOUNT_DIR}/*, /usr/bin/umount ${MOUNT_DIR}/*
Cmnd_Alias SEEDERLINUX_SYNC = /usr/local/bin/seeder-sync
ALL ALL=(root) NOPASSWD: SEEDERLINUX_MOUNT, SEEDERLINUX_UMOUNT, SEEDERLINUX_SYNC
EOF
chmod 440 "$SUDOERS_FILE"
# CORRECAO: antes, sudoers invalido dava `exit 1` aqui - como este
# script roda no nivel raiz do bundle (sem subshell), isso abortava
# TUDO que vem depois (troca de senha, proxy, agente, sync), nao so
# a montagem de compartilhamentos. Agora so desativa o mount via
# sudo para esta estacao (com aviso claro) e o resto do bundle
# continua normalmente.
if ! visudo -cf "$SUDOERS_FILE"; then
    echo ">>> ERRO: sintaxe invalida no sudoers gerado. Removendo."
    echo ">>> AVISO: montagem de compartilhamentos via sudo ficara indisponivel nesta estacao."
    echo ">>> O restante do bundle continua normalmente."
    rm -f "$SUDOERS_FILE"
else
    echo ">>> sudoers configurado: $SUDOERS_FILE"
fi

# ============================================================
# 2. Preparar diretorio de log (mundo-gravavel com sticky bit, ja
#    que quem escreve agora e o usuario comum, nao mais root)
# ============================================================
mkdir -p /var/log/logon-logoff
chmod 1777 /var/log/logon-logoff

# ============================================================
# 3. Pre-criar os pontos de montagem (como root, agora, uma vez)
# ============================================================
mkdir -p "$MOUNT_DIR"
if [ -n "$COMPARTILHAMENTOS" ]; then
    for SHARE in $COMPARTILHAMENTOS; do
        mkdir -p "${MOUNT_DIR}/${SHARE}"
    done
fi
chmod 755 "$MOUNT_DIR"

# ============================================================
# 4. Criar o script PERMANENTE em /usr/local/bin/seederlinux-logon
#    Sera chamado via autostart XDG a cada login, DENTRO da sessao
#    do usuario (nao mais como hook do display manager).
# ============================================================
echo ">>> Criando script permanente: /usr/local/bin/seederlinux-logon"

cat > /usr/local/bin/seederlinux-logon <<'PERMSCRIPT'
#!/bin/bash
# seederlinux-logon - script MINIMALISTA de logon do SeederLinux.
# Executado via autostart XDG (dentro da sessao do usuario).
# Alvo: menos de 3 segundos. So o que precisa rodar em TODO login.

CONFIG_FILE="/etc/seederlinux/config.env"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
else
    exit 0
fi

USERNAME="${USER:-$(whoami)}"
USER_HOME="${HOME:-/home/$USERNAME}"
LOG_FILE="/var/log/logon-logoff/logon_${USERNAME}.log"

exec >> "$LOG_FILE" 2>&1
echo "=== Logon (minimo): $(date) - Usuario: $USERNAME ==="

# ============================================================
# Diretorios basicos do usuario (idempotente, rapido)
# ============================================================
mkdir -p "$USER_HOME/Desktop" "$USER_HOME/Downloads" "$USER_HOME/Documents" 2>/dev/null || true

# ============================================================
# Montar compartilhamentos CIFS (via sudo restrito - ver sudoers)
# ============================================================
if [ -n "$SERVIDOR_ARQUIVOS" ] && [ -n "$COMPARTILHAMENTOS" ]; then
    MOUNT_DIR="${MOUNT_BASE:-/mnt}"
    for SHARE in $COMPARTILHAMENTOS; do
        SHARE_MOUNT="${MOUNT_DIR}/${SHARE}"
        if ! mountpoint -q "$SHARE_MOUNT" 2>/dev/null; then
            sudo -n mount -t cifs "//${SERVIDOR_ARQUIVOS}/${SHARE}" "$SHARE_MOUNT" \
                -o "username=${USERNAME},domain=${DOMINIO_NETBIOS},uid=$(id -u),gid=$(id -g),iocharset=utf8,vers=3.0" \
                2>/dev/null && echo "Compartilhamento montado: ${SHARE}" \
                || echo "AVISO: falha ao montar ${SHARE} (verifique credenciais/sudoers)"
        fi

        cat > "$USER_HOME/Desktop/${SHARE}.desktop" <<EOF
[Desktop Entry]
Type=Link
Name=${SHARE}
URL=file://${SHARE_MOUNT}
Icon=folder
EOF
        chmod +x "$USER_HOME/Desktop/${SHARE}.desktop" 2>/dev/null || true
    done
fi

# ============================================================
# Impressora padrao (config per-user do CUPS, nao precisa root)
# ============================================================
if [ -n "$DEFAULT_PRINTER" ]; then
    lpoptions -d "$DEFAULT_PRINTER" 2>/dev/null || true
fi

# ============================================================
# Atalho do portal
# ============================================================
if [ -n "$HOMEPAGE" ]; then
    cat > "$USER_HOME/Desktop/Portal-${OM_ACRONYM}.desktop" <<EOF
[Desktop Entry]
Type=Link
Name=Portal ${OM_ACRONYM}
URL=${HOMEPAGE}
Icon=web-browser
EOF
    chmod +x "$USER_HOME/Desktop/Portal-${OM_ACRONYM}.desktop" 2>/dev/null || true
fi

# ============================================================
# Disparar seeder-sync em background, so se o timer ainda nao
# estiver ativo (ex: bundle rodado antes do core_sync.sh, ou timer
# desabilitado manualmente) - nao bloqueia o login esperando.
# ============================================================
if ! systemctl is-active --quiet seeder-sync.timer 2>/dev/null; then
    ( sudo -n /usr/local/bin/seeder-sync >/dev/null 2>&1 & ) 2>/dev/null || true
fi

echo "=== Logon concluido: $(date) ==="
exit 0
PERMSCRIPT

chmod 755 /usr/local/bin/seederlinux-logon
echo ">>> Script permanente criado: /usr/local/bin/seederlinux-logon"

# ============================================================
# 5. Registrar via autostart XDG (funciona em GNOME, Cinnamon, MATE,
#    XFCE, KDE, LXDE/LXQt de forma padronizada - um mecanismo so)
# ============================================================
echo ">>> Registrando autostart..."
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/seederlinux-logon.desktop <<EOF
[Desktop Entry]
Type=Application
Name=SeederLinux Logon
Comment=Monta compartilhamentos e aplica configuracoes essenciais de logon
Exec=/usr/local/bin/seederlinux-logon
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel
EOF

echo ">>> [15] Logon minimalista instalado (via autostart)!"
echo "============================================================"
