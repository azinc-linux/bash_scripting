## Создание скрипта анализирующего лог 
1. process.sh  скрипт  генерирующий отчет /tmp/report.txt
2. report.txt  образец отчета 
3. access.log лог на базе которого сгенерирован отчет
4. согласно заданию в отчете представлен свод статистики по Ip адресам, кодам возврата. Также приведены записи содержащие ошибки. В качестве записей с ошибками я выбрал записи, содержащие код возврата 404
5. запись в crontab для отправления отчета на почту раз в час   

	0 * * * * /tmp/process.sh	