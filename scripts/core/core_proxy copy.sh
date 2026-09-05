#!/bin/bash
# ============================================================================
# Core Script: core_proxy.sh
# SeederLinux Lite - Proxy do sistema
# ============================================================================
# Configura o proxy HTTP/HTTPS no nivel do sistema (/etc/environment,
# /etc/apt/apt.conf.d) e em variaveis de ambiente globais.
# Os placeholders VARIAVEL são substituídos automaticamente
# pelo sistema na geração do bundle.
# ============================================================================

set -e

echo "============================================================"
echo "ATENCAO: Proxy sera configurado agora."
echo "Todos os pacotes ja foram instalados."
echo "A partir deste ponto, a internet pode exigir autenticacao."
echo "============================================================"
echo "17 - Configurar proxy do sistema"
echo "============================================================"

# ============================================================
# Variáveis
# ============================================================
PROXY_MODE="{{PROXY_MODE}}"
PROXY_HTTP="{{PROXY_HTTP}}"
PROXY_PORTA="{{PROXY_PORTA}}"
PROXY_URL="{{PROXY_URL}}"
PAC_URL="{{PAC_URL}}"
NO_PROXY="{{NO_PROXY}}"

# CORRECAO: faltava tratamento de NON_INTERACTIVE (ja usado em
# core_dns.sh/core_domain.sh). Sem isso, os dois `read -p` abaixo
# dependiam do stdin do cron vir vazio por acaso para nao travar -
# comportamento acidental, nao garantido.
NON_INTERACTIVE="${NON_INTERACTIVE:-false}"

echo ">>> Modo de proxy: $PROXY_MODE"

# ============================================================
# Configurar conforme o modo
# ============================================================
case "$PROXY_MODE" in
    NONE)
        echo ">>> Proxy desativado (NONE)"
        # Remover configuracoes de proxy existentes
        rm -f /etc/apt/apt.conf.d/95seederlinux-proxy 2>/dev/null || true
        # Limpar /etc/environment de entradas de proxy
        if [ -f /etc/environment ]; then
            sed -i '/^http_proxy=/d; /^https_proxy=/d; /^ftp_proxy=/d; /^no_proxy=/d; /^HTTP_PROXY=/d; /^HTTPS_PROXY=/d; /^FTP_PROXY=/d; /^NO_PROXY=/d' /etc/environment || true
        fi
        echo ">>> Configuracoes de proxy removidas"
        ;;

    MANUAL)
        echo ">>> Configurando proxy manual: ${PROXY_HTTP}:${PROXY_PORTA}"

        # Construir URL do proxy
        if [ -n "$PROXY_URL" ] && [ "$PROXY_URL" != "" ]; then
            PROXY_FULL_URL="$PROXY_URL"
        else
            PROXY_FULL_URL="http://${PROXY_HTTP}:${PROXY_PORTA}"
        fi

        # Configurar APT
        cat > /etc/apt/apt.conf.d/95seederlinux-proxy <<EOF
Acquire::http::Proxy "${PROXY_FULL_URL}";
Acquire::https::Proxy "${PROXY_FULL_URL}";
Acquire::ftp::Proxy "${PROXY_FULL_URL}";
EOF

        # Configurar /etc/environment
        if [ -f /etc/environment ]; then
            # Remover entradas antigas
            sed -i '/^http_proxy=/d; /^https_proxy=/d; /^ftp_proxy=/d; /^no_proxy=/d; /^HTTP_PROXY=/d; /^HTTPS_PROXY=/d; /^FTP_PROXY=/d; /^NO_PROXY=/d' /etc/environment || true
        fi

        cat >> /etc/environment <<EOF
http_proxy="${PROXY_FULL_URL}"
https_proxy="${PROXY_FULL_URL}"
ftp_proxy="${PROXY_FULL_URL}"
HTTP_PROXY="${PROXY_FULL_URL}"
HTTPS_PROXY="${PROXY_FULL_URL}"
FTP_PROXY="${PROXY_FULL_URL}"
EOF

        if [ -n "$NO_PROXY" ] && [ "$NO_PROXY" != "" ]; then
            echo "no_proxy=\"${NO_PROXY}\"" >> /etc/environment
            echo "NO_PROXY=\"${NO_PROXY}\"" >> /etc/environment
        fi

        echo ">>> Proxy manual configurado"
        ;;

    PAC)
        echo ">>> Configurando proxy via PAC: ${PAC_URL}"

        PAC_SKIP="false"
        if [ -z "$PAC_URL" ] || [ "$PAC_URL" = "" ]; then
            echo ">>> ERRO: PAC_URL nao definido para modo PAC"
            if [ "$NON_INTERACTIVE" = "true" ]; then
                echo ">>> Modo nao interativo: pulando configuracao PAC (bundle continua)."
                PAC_SKIP="true"
            else
                read -p ">>> Deseja pular a configuracao de PAC e continuar o bundle? (S/n): " CONTINUE
                if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
                    echo ">>> Tentando aplicar PAC mesmo com URL vazia (nao recomendado)."
                else
                    echo ">>> Pulando configuracao de PAC."
                    PAC_SKIP="true"
                fi
            fi
        fi

        if [ "$PAC_SKIP" = "true" ]; then
            echo ">>> [17] PAC nao configurado (PAC_URL ausente) - restante do proxy nao afetado."
        else
            # Configurar APT com PAC (apt suporta PAC via auto)
            cat > /etc/apt/apt.conf.d/95seederlinux-proxy <<EOF
Acquire::http::Proxy::Pac "${PAC_URL}";
Acquire::https::Proxy::Pac "${PAC_URL}";
EOF

            # Para navegadores, o PAC sera configurado no core_browser.sh
            echo "PAC_URL=${PAC_URL}" > /etc/seederlinux/pac_url.conf 2>/dev/null || {
                mkdir -p /etc/seederlinux
                echo "PAC_URL=${PAC_URL}" > /etc/seederlinux/pac_url.conf
            }

            echo ">>> Proxy via PAC configurado"
        fi
        ;;

    *)
        echo ">>> ERRO: Modo de proxy invalido: $PROXY_MODE"
        # CORRECAO: antes dava `exit 1` aqui, abortando o bundle
        # inteiro (script roda sem subshell). Um PROXY_MODE invalido
        # e um erro de configuracao da OM, nao motivo para impedir o
        # resto do provisionamento (branding, impressoras, VNC, SSH,
        # etc. nao dependem de proxy correto). Agora so avisa e segue
        # sem aplicar nenhuma config de proxy.
        if [ "$NON_INTERACTIVE" = "true" ]; then
            echo ">>> Modo nao interativo: nenhuma configuracao de proxy sera aplicada."
        else
            read -p ">>> PROXY_MODE invalido. Continuar sem aplicar proxy? (S/n): " CONTINUE
            if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
                echo ">>> Prosseguindo mesmo assim (nenhuma configuracao de proxy sera aplicada)."
            fi
        fi
        echo ">>> [17] Nenhuma configuracao de proxy aplicada (PROXY_MODE='$PROXY_MODE' invalido)."
        ;;
esac

echo ">>> [17] Proxy do sistema configurado!"
echo "============================================================"
