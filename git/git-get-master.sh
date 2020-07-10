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
# 07 - Injeta na branch corrente as atualizações recebidas na master (git rebase master)
# 08 - Envia para o remote as mudanças aplicadas na branch corrente (git push origin "sua-branch-corrente")
# 09 - Restaura as modificações pendentes da branch corrente (git stash pop)

# Definição de cores para output no console
BLD='\e[1m'    # BOLD
DIM='\e[2m'    # DIM
UND='\e[4m'    # UNDERLINE
RED='\e[1;31m' # RED
GRE='\e[1;32m' # GREEN
YEL='\e[1;33m' # YELLOW
BLU='\e[1;36m' # BLUE
DBL='\e[0;36m' # DARK BLUE
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


printf "\n${YEL}Get master updates into your branch ${GRE}$__currentBranchName${RES}?\n\n"
read -p "Confirm? (Y/N) " ans_yn
case "$ans_yn" in
 [Yy]|[Ss])
   printf "\n${RES}${YEL}Going ahead...${RES}\n";;
 *)
 printf "\n${RES}${RED}Cancelled!${RES}\n"
 exit 1;;
esac

# 02 - Salva o status corrente das modificações ainda não comitadas (git stash)

# Verifica a lista de stash antes do stash
git stash list > stashListAux1.tmp

# Realiza o stash se necessário
printf "\n${YEL}Saving actual work in progress [${RES}git stash${YEL}]...${RES}\n"
git stash

# Verifica a lista de stash apos o stash
git stash list > stashListAux2.tmp

# Verifica a diferenca entre as listas antes e apos o stash
diff stashListAux1.tmp stashListAux2.tmp > stashListAux.tmp

# Diferenca entre listas indica que um stash foi realizado e precisa ser desfeito (stash pop) ao final
if [[ -f "stashListAux.tmp" && -s "stashListAux.tmp" ]]; then
	stashCount=1
	printf "\n${YEL}Content has been stashed and will be restored after sync...${RES}\n"
else
	stashCount=0
	printf "\n${YEL}Stash does not need to be restored after sync...${RES}\n"
fi

# Remove os arquivos temporarios usados para detectar necessidade de undo stash
rm stashListAux.tmp stashListAux1.tmp stashListAux2.tmp

# 03 - Muda para a branch da master atual (git checkout master)
printf "\n${YEL}Switching to the master branch [${RES}git checkout ${GRE}master${YEL}]...${RES}\n"
git checkout master

# 04 - Baixa as atualizações existentes no remote para o repositório local (git fetch origin)
printf "\n${YEL}Fetching remote repository updates [${RES}git fetch origin${YEL}]...${RES}\n"
git fetch origin

# 05 - Atualiza a branch da master com as informações trazidas do remote (git pull)
printf "\n${YEL}Updating master local branch with remote data [${RES}git pull${YEL}]...${RES}\n"
git pull

if [ "$?" -eq 1 ]; then
	printf "\n${RED}Problem with the pull command!${RES}\n"
	exit $?
fi

# 06 - Retorna para a branch corrente (git checkout "sua-branch-corrente")
printf "\n${YEL}Going back to our working branch [${RES}git checkout ${GRE}$__currentBranchName${YEL}]...${RES}\n"
git checkout $__currentBranchName

# 07 - Injeta na branch corrente as atualizações recebidas na master (git merge master)
printf "\n${YEL}Getting master updates into our working branch [${RES}git merge ${GRE}master${YEL}]...${RES}\n"
git rebase master

if [ "$?" -eq 1 ]; then
	printf "\n${RED}Problem with the merge command bringing master changes!${RES}\n"
	exit $?
fi

# 08 - Envia para o remote as mudanças aplicadas na branch corrente (git push origin "sua-branch-corrente")
printf "\n${YEL}Sending updated data into working remote branch [${RES}git push origin ${GRE}$__currentBranchName${YEL}]...${RES}\n"
git push origin $__currentBranchName

## Check if it is needed to run the git stash pop command
if [ $stashCount -gt 0 ]; then
	# 09 - Restaura as modificações pendentes da branch corrente (git stash pop)
	printf "\n${YEL}Restoring work stashed [${RES}git stash pop${YEL}]...${RES}\n"
	git stash pop
fi

printf "\n\n${GRE}Done!${RES}\n"
