#!/bin/bash

# Script originalmente desenvolvido por "kemazon" em https://github.com/kemazon/tools

# Lista de pacotes requeridos
REQUIRED_PACKAGES=("curl" "wget" "unzip" "lynx")

# Definir diretório de download
if [ -d "/roms2/tools" ]; then
    SCRIPT_DEST="/roms2/tools/Downloader.sh"
elif [ -d "/roms/tools" ]; then
    SCRIPT_DEST="/roms/tools/Downloader.sh"
else
    echo "❌ Não foi encontrado o diretório /roms2/tools nem o /roms/tools."
    exit 1
fi

# URL do script para baixar
SCRIPT_URL="https://raw.githubusercontent.com/IgorIsaiasBanlian/tools/refs/heads/main/Downloader.sh"

GPTK_URL="https://raw.githubusercontent.com/IgorIsaiasBanlian/tools/refs/heads/main/downloader.gptk"
GPTK_DEST="/opt/inttools/downloader.gptk"

RC_URL="https://raw.githubusercontent.com/IgorIsaiasBanlian/tools/refs/heads/main/.lynxrc"
RC_DEST="/home/ark/.lynxrc"

CFG_URL="https://raw.githubusercontent.com/IgorIsaiasBanlian/tools/refs/heads/main/lynx.cfg"
CFG_DEST="/etc/lynx/lynx.cfg"

sudo chmod u+s $(which ping)

# Verifica conexão com a Internet
check_internet() {
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo "✔ Conexão com a Internet disponível."
        return 0
    else
        echo "✖ Não há conexão com a Internet. Não é possível continuar."
		sleep 5
        exit 1
    fi
}

# Verifica e instala pacotes conforme a distribuição
install_packages() {
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            echo "⚠ O pacote '$package' não está instalado. Instalando..."
            if [[ -f /etc/debian_version ]]; then
                sudo apt update && sudo apt install -y "$package"
            elif [[ -f /etc/arch-release ]]; then
                sudo pacman -Sy --noconfirm "$package"
            else
                echo "❌ Não foi possível determinar a distribuição. Instale '$package' manualmente."
                exit 1
            fi
        else
            echo "✔ O pacote '$package' já está instalado."
        fi
    done
}

# Baixa o script se tudo estiver correto
download_script() {
    echo "⬇ Baixando o script de $SCRIPT_URL..."
    wget -O "$SCRIPT_DEST" "$SCRIPT_URL" || curl -o "$SCRIPT_DEST" "$SCRIPT_URL"
	wget -O "$GPTK_DEST" "$GPTK_URL" || curl -o "$GPTK_DEST" "$GPTK_URL"
	wget -O "$RC_DEST" "$RC_URL" || curl -o "$RC_DEST" "$RC_URL"
	sudo wget -O "$CFG_DEST" "$CFG_URL" || sudo curl -o "$CFG_DEST" "$CFG_URL"
    chmod +x "$SCRIPT_DEST"
    echo "✔ Script baixado e marcado como executável em $SCRIPT_DEST."
	echo "✔ INSTALAÇÃO CONCLUÍDA, REINICIANDO."
	sleep 4
	sudo systemctl restart emulationstation
}

# Executar funções
check_internet
install_packages
download_script
