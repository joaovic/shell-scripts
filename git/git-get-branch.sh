#!/bin/bash

### OBJETIVO: 
### Recuperar uma nova branch do VSTS baseada na master
### Ou seja, atualiza a master com os dados da master remote, 
### traz as alterações existentes na master remote para a master local
### e cria a nova branch informada no param localmente baseada na branch
### homonima remota

### PRÉ-CONDIÇÃO
### A branch corrente não pode ter nenhuma pedência local

### PASSSOS:
# 01 - Muda para a branch da master atual (git checkout master)
# 02 - Baixa as atualizações existentes no remote para o repositório local (git fetch origin)
# 03 - Atualiza a branch da master com as informações trazidas do remote (git pull)
# 04 - Cria a branch local informada no param vinculando com a branch homônima remota

# Definição de cores para output no console
BLD='\e[1m'    # BOLD
DIM='\e[2m'    # DIM
UND='\e[4m'    # UNDERLINE
RED='\e[1;31m' # RED
GRE='\e[1;32m' # GREEN
YEL='\e[1;33m' # YELLOW
BLU='\e[0;36m' # BLUE
RES='\e[0m'    # RESET ALL

###
### INICIO DOS PASSOS
###

# Valida se informou o nome da branch para buscar no remote
if [ -z "$1" ]; then
 echo -e ""
 echo -e "${RES}${RED}Please, provide the new branch name!${RES}" 
 echo -e ""
 exit 1
fi

# 01 - Verifica se deseja realmemte realizar a criação da branch
echo -e ""
echo -e "${YEL}Create local branch ${GRE}'$1'${RES} ${YEL}tracking remote branch ${GRE}'origin/$1'${YEL}?${RES}"
echo -e ""
read -p "Confirm? (Y/N) " ans_yn
case "$ans_yn" in
 [Yy]|[Ss]) 
   echo -e ""
   echo -e "${RES}${YEL}Going ahead...${RES}";;
 *) 
 echo -e "${RES}${RED}Cancelled!${RES}" 
 echo -e ""
 exit 1;;
esac

# 02 - Recupera as atualizações realizadas no remote (novas branches remotas podem ser encontradas)
#git fetch origin

# 03 - Valida se a branch informada existe remotamente
hasRemoteBranch=$(git ls-remote --heads origin $1 | wc -l)
if [ $hasRemoteBranch -eq 0 ]; then
 echo -e ""
 echo -e "${RES}${RED}Provided remote branch name not found!${RES}" 
 echo -e ""
 exit 1
fi

# 04 - Muda para a branch da master atual (git checkout master)
echo -e ""
echo -e "${YEL}Switching to the master branch [${RES}git checkout master${YEL}]...${RES}"
echo -e ""
git checkout master

# 05 - Atualiza a branch da master com as informações trazidas do remote (git pull)
echo -e ""
echo -e "${YEL}Updating master local branch with remote data [${RES}git pull${YEL}]...${RES}"
echo -e ""
git pull

if [ "$?" -eq 1 ]; then
	echo -e ""
	echo -e "${RED}Problem with the pull command!${RES}"
	echo -e ""
	exit $?
fi

# 06 - Cria a branch local (git checkout -b $1)
echo -e ""
echo -e "${YEL}Create and switch to the new local branch ${GRE}${1}${YEL} [${RES}git checkout -b $1${YEL}]...${RES}"
echo -e ""
git checkout -b $1

# 07 - Configura a branch local para rastrear a branch remota (git branch -u origin/$1)
echo -e ""
echo -e "${YEL}Configuring ${GRE}${1}${YEL} to track remote branch ${GRE}origin/${1}${YEL}... [${RES}git branch -u origin/${1}${YEL}]...${RES}"
echo -e ""
git branch -u origin/$1
git status

echo -e ""
echo -e ""
echo -e "${GRE}Done!${RES}"
echo -e ""
