#!/bin/bash
#
# versao 0.1
#
# NOME
#   check_server_X_dominios.sh
#
# DESCRICAO
#   Testa se o domínio existe em cada servidor listado em servidores.txt, compatível com WHM.
#
# NOTA
#   Para recuperar a lista de domínios este script exige conexão direta ao servidores via ssh com chave, caso contrário vai pedir senha
#   em cada servidor   
#   Um arquivo chamado servidores.txt na mesma pasta do script precisa conter o IP do servidor e a porta 
#   separados por ; Ex:  200.215.34.18;2222
#                        177.53.231.19;2229
#
#
#  DESENVOLVIDO_POR
#  Valdenir Luíz Mezadri Junior			- valdenirmezadri@live.com
#
#  MODIFICADO_POR		(DD/MM/YYYY)
#  Valdenir Luíz Mezadri Junior	16/08/2017	- Criado script
#  Valdenir Luíz Mezadri Junior 17/08/2017      - Se não existir porta ele apenas testa o servidor, adicionado teste: onde esta www e mail 
#
#########################################################################################################################################

{ while IFS=';' read h p 
  do
 if [[ ! -z $p  ]];then	  
    rsync -zuva -e"ssh -p $p" root@$h:/etc/trueuserdomains . 1> /dev/null 2> /dev/null
    mv trueuserdomains $h  1> /dev/null 2> /dev/null
    RESULT+=`cat $h | sed 's/:.*//g'`
    RESULT+=$'\n'
 fi   
done
} < servidores.txt
RESULT1=`echo "$RESULT" | sort | uniq`
echo "Domínio;Existe em;E-mail em;www em"
SRV=`cat servidores.txt | sed 's/;.*//g'`
for i in $RESULT1
  do
	unset PINGWWW
	unset PINGMAIL
	PINGWWW=`ping -c1 www.$i | head -1 | awk '{print $3}' | sed 's/[()]//g'`   2> /dev/null
	PINGMAIL=`ping -c1 mail.$i | head -1 | awk '{print $3}' | sed 's/[()]//g'` 2> /dev/null
	unset STATUS
	for y in $SRV
	  do
	  nslookup $i $y 1> /dev/null 2> /dev/null
	  if [ $? -eq 0 ]; then
	    STATUS+="$y "
	  fi
	done
	STATUS+=";$PINGMAIL;$PINGWWW"
	echo "$i;$STATUS"
        	
done
