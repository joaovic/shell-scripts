#!/bin/bash

### OBJETIVO: 
### Sincronizar sua branch com a branch da sprint.
### Ou seja, envia e recupera as alterações existentes.
###
### OBS: O nome da sprint está fixo na variável 'defaultSprintName'
###      ou pode ser informada como primeiro parametro 

defaultSprintName="CR110342"

### PASSSOS:
# 01 - Recupera o nome da branch corrente no git
# 02 - Salva o status corrente das modificações ainda não comitadas (git stash)
# 03 - Muda para a branch da sprint atual (git checkout "branch-da-sprint")
# 04 - Baixa as atualizações existentes no remote para o repositório local (git fetch origin)
# 05 - Atualiza a branch da sprint com as informações trazidas do remote (git pull)
# 06 - Injeta as atualizações da branch corrente para a branch da sprint (git merge "sua-branch-corrente")
# 07 - Exibe o status corrente para verificação (git status)
# 08 - Envia para o remote as mudanças realizadas na branch da sprint (git push origin "branch-da-sprint")
# 09 - Retorna para a branch corrente (git checkout "sua-branch-corrente")
# 10 - Injeta na branch corrente as atualizações recebidas na branch da sprint (git merge "branch-da-sprint")
# 11 - Envia para o remote as mudanças aplicadas na branch corrente (git push origin "sua-branch-corrente")
# 12 - Restaura as modificações pendentes da branch corrente (git stash pop)

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

### Se foi informado algum parametro 
### este valor será usado como o nome da sprint
### no lugar do valor em '$defaultSprintName'
if [ "$#" -eq 1 ]; then
	__sprintBranchName=$1
else
	__sprintBranchName=$defaultSprintName
fi

###
### INICIO DOS PASSOS DA SINCRONIZAÇÃO
###

# 01 - Recupera o nome da branch corrente no git
__currentBranchName=$(getCurrentBranchName)

echo -e ""
echo -e "${YEL}Syncronize your branch ${GRE}$__currentBranchName${YEL} with sprint branch ${GRE}$__sprintBranchName${YEL}.${RES}"
echo -e ""
read -p "Confirm? (Y/N) " ans_yn
case "$ans_yn" in
 [Yy]|[Ss]) 
   echo -e ""
   echo -e "${YEL}Going ahead...${RES}";;
 *) 
 echo -e "${RED}Cancelled!${RES}" 
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

# 03 - Muda para a branch da sprint atual (git checkout "branch-da-sprint")
echo -e ""
echo -e "${YEL}Switching to the sprint branch [${RES}git checkout ${GRE}$__sprintBranchName${YEL}]...${RES}"
echo -e ""
git checkout $__sprintBranchName

# 04 - Baixa as atualizações existentes no remote para o repositório local (git fetch origin)
echo -e ""
echo -e "${YEL}Fetching remote repository updates [${RES}git fetch origin${YEL}]...${RES}"
echo -e ""
git fetch origin

# 05 - Atualiza a branch da sprint com as informações trazidas do remote (git pull)
echo -e ""
echo -e "${YEL}Updating sprint local branch with remote data [${RES}git pull${YEL}]...${RES}"
echo -e ""
git pull

if [ "$?" -eq 1 ]; then
	echo -e ""
	echo -e "${RED}Problem with the pull command!${RES}"
	echo -e ""
	exit $?
fi

# 06 - Injeta as atualizações da branch corrente para a branch da sprint (git merge "sua-branch-corrente")
echo -e ""
echo -e "${YEL}Merging current branch into sprint [${RES}git merge ${GRE}$__currentBranchName${YEL}]...${RES}"
echo -e ""
git merge $__currentBranchName

if [ "$?" -eq 1 ]; then
	echo -e ""
	echo -e "${RED}Problem with the merge command into sprint branch!${RES}"
	echo -e ""
	exit $?
fi

# 07 - Exibe o status corrente para verificação (git status)
echo -e ""
echo -e "${YEL}Getting status update [${RES}git status${YEL}]...${RES}"
echo -e ""
git status

# 08 - Envia para o remote as mudanças realizadas na branch da sprint (git push origin "branch-da-sprint")
echo -e ""
echo -e "${YEL}Sending updated data into remote sprint branch [${RES}git push origin ${GRE}$__sprintBranchName${YEL}]...${RES}"
echo -e ""
git push origin $__sprintBranchName

# 09 - Retorna para a branch corrente (git checkout "sua-branch-corrente")
echo -e ""
echo -e "${YEL}Going back to our working branch [${RES}git checkout ${GRE}$__currentBranchName${YEL}]...${RES}"
echo -e ""
git checkout $__currentBranchName

# 10 - Injeta na branch corrente as atualizações recebidas na branch da sprint (git merge "branch-da-sprint")
echo -e ""
echo -e "${YEL}Getting sprint updates into our working branch [${RES}git merge ${GRE}$__sprintBranchName${YEL}]...${RES}"
echo -e ""
git merge $__sprintBranchName

if [ "$?" -eq 1 ]; then
	echo -e ""
	echo -e "${RED}Problem with the merge command bringing sprint changes!${RES}"
	echo -e ""
	exit $?
fi

# 11 - Envia para o remote as mudanças aplicadas na branch corrente (git push origin "sua-branch-corrente")
echo -e ""
echo -e "${YEL}Sending updated data into working remote branch [${RES}git push origin ${GRE}$__currentBranchName${YEL}]...${RES}"
echo -e ""
git push origin $__currentBranchName

## Check if it is needed to run the git stash pop command
if [ $stashCount -gt 0 ]; then
	# 12 - Restaura as modificações pendentes da branch corrente (git stash pop)
	echo -e ""
	echo -e "${YEL}Restoring work stashed [${RES}git stash pop${YEL}]...${RES}"
	echo -e ""
	git stash pop
fi

echo -e ""
echo -e ""
echo -e "${GRE}Done!${RES}"
echo -e ""
