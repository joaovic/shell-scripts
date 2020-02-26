#!/bin/bash

### OBJETIVO: 
### Atualizar sua branch com a branch master
### Ou seja, atualiza a master com os dados da master remote, 
### traz as alterações existentes na master para a sua branch corrente.
###

### PASSSOS:
# 01 - Recupera o nome da branch corrente no git
# 02 - Salva o status corrente das modificações ainda não comitadas (git stash)
# 03 - Muda para a branch da master atual (git checkout master)
# 04 - Baixa as atualizações existentes no remote para o repositório local (git fetch origin)
# 05 - Atualiza a branch da master com as informações trazidas do remote (git pull)
# 06 - Retorna para a branch corrente (git checkout "sua-branch-corrente")
# 07 - Injeta na branch corrente as atualizações recebidas na master (git merge master)
# 08 - Envia para o remote as mudanças aplicadas na branch corrente (git push origin "sua-branch-corrente")
# 09 - Restaura as modificações pendentes da branch corrente (git stash pop)

# Definição de cores para output no console
BLD='\e[1m'    # BOLD
DIM='\e[2m'    # DIM
UND='\e[4m'    # UNDERLINE
RED='\e[1;31m' # RED
GRE='\e[1;32m' # GREEN
YEL='\e[1;33m' # YELLOW
BLU='\e[0;36m' # BLUE
RES='\e[0m'    # RESET ALL

### FUNÇÃO QUE OBTEM O NOME DA BRANCH CORRENTE
function getCurrentBranchName() {
	__mybranch=$( git rev-parse --abbrev-ref HEAD )
	echo $__mybranch
}

###
### INICIO DOS PASSOS DA SINCRONIZAÇÃO
###

# 01 - Recupera o nome da branch corrente no git
__currentBranchName=$(getCurrentBranchName)


echo -e ""
echo -e "${YEL}Get master updates into your branch ${GRE}$__currentBranchName${RES}?"
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
  

# 02 - Salva o status corrente das modificações ainda não comitadas (git stash)

# Verifica a lista de stash antes do stash
git stash list > stashListAux1.tmp

# Realiza o stash se necessário
echo -e ""
echo -e "${YEL}Saving actual work in progress [${RES}git stash${YEL}]...${RES}"
echo -e ""
git stash

# Verifica a lista de stash apos o stash
git stash list > stashListAux2.tmp

# Verifica a diferenca entre as listas antes e apos o stash
diff stashListAux1.tmp stashListAux2.tmp > stashListAux.tmp

# Diferenca entre listas indica que um stash foi realizado e precisa ser desfeito (stash pop) ao final
if [[ -f "stashListAux.tmp" && -s "stashListAux.tmp" ]]; then 
	stashCount=1
	echo -e "${YEL}Content has been stashed and will be restored after sync...${RES}"
	echo -e ""
else 
	stashCount=0
	echo -e "${YEL}Stash does not need to be restored after sync...${RES}"
	echo -e ""
fi

# Remove os arquivos temporarios usados para detectar necessidade de undo stash
rm stashListAux.tmp stashListAux1.tmp stashListAux2.tmp

# 03 - Muda para a branch da master atual (git checkout master)
echo -e ""
echo -e "${YEL}Switching to the master branch [${RES}git checkout ${GRE}master${YEL}]...${RES}"
echo -e ""
git checkout master

# 04 - Baixa as atualizações existentes no remote para o repositório local (git fetch origin)
echo -e ""
echo -e "${YEL}Fetching remote repository updates [${RES}git fetch origin${YEL}]...${RES}"
echo -e ""
git fetch origin

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

# 06 - Retorna para a branch corrente (git checkout "sua-branch-corrente")
echo -e ""
echo -e "${YEL}Going back to our working branch [${RES}git checkout ${GRE}$__currentBranchName${YEL}]...${RES}"
echo -e ""
git checkout $__currentBranchName

# 07 - Injeta na branch corrente as atualizações recebidas na master (git merge master)
echo -e ""
echo -e "${YEL}Getting master updates into our working branch [${RES}git merge ${GRE}master${YEL}]...${RES}"
echo -e ""
git merge master

if [ "$?" -eq 1 ]; then
	echo -e ""
	echo -e "${RED}Problem with the merge command bringing master changes!${RES}"
	echo -e ""
	exit $?
fi

# 08 - Envia para o remote as mudanças aplicadas na branch corrente (git push origin "sua-branch-corrente")
echo -e ""
echo -e "${YEL}Sending updated data into working remote branch [${RES}git push origin ${GRE}$__currentBranchName${YEL}]...${RES}"
echo -e ""
git push origin $__currentBranchName

## Check if it is needed to run the git stash pop command
if [ $stashCount -gt 0 ]; then
	# 09 - Restaura as modificações pendentes da branch corrente (git stash pop)
	echo -e ""
	echo -e "${YEL}Restoring work stashed [${RES}git stash pop${YEL}]...${RES}"
	echo -e ""
	git stash pop
fi

echo -e ""
echo -e ""
echo -e "${GRE}Done!${RES}"
echo -e ""
