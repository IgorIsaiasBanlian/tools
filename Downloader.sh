#!/bin/bash

# Script originalmente desenvolvido por "kemazon" em https://github.com/kemazon/tools

#sudo nmui
#mod
sudo chmod 666 /dev/tty1
#printf "\033c" > /dev/tty1
reset

# Esconder o cursor
printf "\e[?25l" > /dev/tty1
dialog --clear

height="15"
width="55"

if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RG503 | tr -d '\0')"
then
  height="20"
  width="60"
elif test ! -z "$(cat /home/ark/.config/.DEVICE | grep RGB20PRO | tr -d '\0')"
then
  height="20"
  width="70"
fi

export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/

if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RG503 | tr -d '\0')"
  then
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold20x10.psf.gz
  elif test ! -z "$(cat /home/ark/.config/.DEVICE | grep RGB20PRO | tr -d '\0')"
  then
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold32x16.psf.gz
  else
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold22x11.psf.gz
  fi
else
  sudo setfont /usr/share/consolefonts/Lat7-Terminus16.psf.gz
fi

pgrep -f gptokeyb | sudo xargs kill -9
pgrep -f osk.py | sudo xargs kill -9
printf "\033c" > /dev/tty1
printf "Iniciando o Gerenciador de Downloads. Aguarde..." > /dev/tty1

old_ifs="$IFS"

ToggleWifi() {
  MainMenu
}

ExitMenu() {
  printf "\033c" > /dev/tty1
  if [[ ! -z $(pgrep -f gptokeyb) ]]; then
    pgrep -f gptokeyb | sudo xargs kill -9
  fi
  if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  fi
  exit 0
}


Connect() {
  dialog --infobox "\nAbrindo a WEB..." 5 $width > /dev/tty1
  sleep 1
  lynx "https://myrient.erista.me/files/" -nomore
}

MainMenu() {

  mainoptions=( 1 "Abrir a WEB para baixar ROMs" 2 "Sair" )
  IFS="$old_ifs"
  while true; do
    mainselection=(dialog \
   	--backtitle "ROMs Downloader:" \
   	--title "Menu Principal" \
   	--no-collapse \
   	--clear \
	--cancel-label "Select + Start = Sair" \
    --menu "Escolha uma opção" $height $width 15)
	
	mainchoices=$("${mainselection[@]}" "${mainoptions[@]}" 2>&1 > /dev/tty1)
	if [[ $? != 0 ]]; then
	  exit 1
	fi
    for mchoice in $mainchoices; do
      case $mchoice in
    1) Connect ;;
    2) ExitMenu ;;
      esac
    done
  done
}

sudo chmod 666 /dev/uinput

export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
export TEXTINPUTPRESET="My Name"        # Define o texto pré-definido a ser inserido
export TEXTINPUTINTERACTIVE="Y"         # Habilita o modo de entrada interativa de texto
export TEXTINPUTNOAUTOCAPITALS="Y"      # Desabilita a capitalização automática da primeira letra das palavras no modo de entrada interativa de texto
export TEXTINPUTADDEXTRASYMBOLS="Y"     # Habilita símbolos adicionais para entrada interativa de texto
export TEXTINPUTNUMBERSONLY="Y"         # Restringe a entrada interativa de texto para números inteiros de 0 a 9

if [[ ! -z $(pgrep -f gptokeyb) ]]; then
  pgrep -f gptokeyb | sudo xargs kill -9
fi
/opt/inttools/gptokeyb textinput -1 "Downloader.sh" -c "/opt/inttools/downloader.gptk" > /dev/null 2>&1 &
printf "\033c" > /dev/tty1
dialog --clear
trap ExitMenu EXIT
MainMenu
