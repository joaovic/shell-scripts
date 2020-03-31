
# hurry-checkout

Checkout de uma feature branch enquanto o pull request da feature atual não é aprovado pelo time.

Indicado para a situação onde a branch atual ainda não foi entregue na master devido demora na aprovação do pull request.

Nesse caso, a partir da branch cuja feature está em processo de aprovação, invocamos o script passando como argumento o nome desejado para a nova branch. O script vai então adicionar ao nome informado o sufixo '-tmp' para indicar que se trata de uma branch temporária.

Assim que o pull request da feature anterior for aprovado e a branch correspondente for entregue na master devemos, desta vez, a partir da master, invocar o script passando o mesmo nome informado anteriormente.
Fazendo isso, o script vai identificar que existe uma branch temporária associada e vai trazer todas alterações realizadas por lá para esta nova branch.

- Importante 1: A convenção do nome da branch é importante para controlar o funcionamento deste script. A branch temporária deve ter o sufixo '-tmp', por isso não altere o criado pelo script.

- Importante 2: Se precisar de mais de umm nível de feature sem aprovação de PR, não apague as branchs temporárias criadas pelo script.

OBS: Caso a branch corrente seja a master e não exista uma branch temporária correspondente, a branch é criada normalmente.


## Utilização:
```
> hurry-checkout -b=nome-branch
```

## Argumentos:
```
-b  ou --branchname  O nome da branch a ser criada. (obrigatório)
-wd ou --withdelete  Permite apagar a branch temporária ao final do processo. (default: no delete)
-nc ou --noconfirm   Permite não pedir confirmação do usuário para iniciar o processo. (default: confirm)
-nu ou --noupdate    Permite não atualizar a master local com base na remota antes de iniciar o processo. (default: update)
-wp ou --withpause   Uma pausa antes execução de cada comando. (default: no pause)
-h  ou --help        Exibe esta ajuda.
```

