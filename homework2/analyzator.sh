#!/bin/bash

set -euo pipefail #Для прекращения выполнения скрипта при ошибках

function analyze() {
    current_date=$(LANG=en_us_88591; date "+%d-%b-%Y:%T"); #Текущая дата для именования файла с анализом лога
    name=$1; #Имя анализируемого лога
    name="${name//[.\/]/}"; #Удаляем ненужные символы
    analyze_file="analyze-$name-$current_date.txt" #Имя файла для анализа
    temp_file=/tmp/log_analyzer_dates.tmp; #Путь для временного файла, в котором хранится номер последней обработанной строки лога

    all_count_lines=$(cat $1 | wc -l); #Считаем полное количество строк в логе

    if [ -f $temp_file ] #Существует ли временный файл
    then
        last_analyze_line=$(cat $temp_file | awk -v name=$name '{ if($2==name){ print $1} }' | tail -n 1) #Вытаскиваем последнюю обработанную строку у нужного файла с последнего анализа
        if [[ $last_analyze_line == "" ]] #Если не пустое значение (пустое мб, когда ещё не было обработки этого файла, но анализировался другой)
        then 
            last_analyze_line=0;
        fi
    else
        last_analyze_line=0;
    fi

    if [ $all_count_lines -le $last_analyze_line ] #Если последняя обработанная строка при предыдущем анализе равна полному количеству строк, то нет данных новых
    then
        echo -e "Нет новых данных в логе!";
        exit 0;
    fi

    echo "$all_count_lines $name" >> $temp_file; #Записываем номер последней обработанной строки и имя файла
    count_needs_lines=$(($all_count_lines - $last_analyze_line)) #Сколько строк нужно обработать

    echo "Обрабатываемый временной интервал:" > $analyze_file;
    #от первой строки берём дату и от последней, для вывода временного интервала
    #берем нужное количество строк с конца файла и из них первую строку, берем 4 столбец (разделены пробелами по умолчанию), отрезаем ненужные символы
    since=$(cat $1 | tail -n $count_needs_lines | awk '{ print $4 }' | cut -c 2- | head -n 1 || true); 
    #берем нужное количество строк с конца файла и из них последнюю строку, берем 4 столбец (разделены пробелами по умолчанию), отрезаем ненужные символы
    to=$(cat $1 | tail -n $count_needs_lines | cut -d ' ' -f 4 | tail -n 1 | cut -c 2- || true);
    echo "С $since по $to" >> $analyze_file;
    echo -e "" >> $analyze_file;

    #берем нужное количество строк с конца файла, сортируем, подсчитываем количество каждой, сортируем в обратном порядке и берём первые 15 и выводим нужные данные
    echo "Топ-15 IP-адресов:" >> $analyze_file;
    cat $1 | tail -n $count_needs_lines | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | head -n 15 | sed -e 's/^[[:space:]]*//' | awk '{ print "   ",$2," - ",$1}' >> $analyze_file || true;
    echo -e "" >> $analyze_file;

    #аналогичным образом работаем по другому "столбцу" - запрашиваемый ресурс
    echo "Топ-15 запрашиваемых ресурсов:" >> $analyze_file;
    cat $1 | tail -n $count_needs_lines | cut -d ' ' -f 7 | sort | uniq -c | sort -nr | head -n 15 | sed -e 's/^[[:space:]]*//' | awk '{ print "   ",$2," - ",$1}' >> $analyze_file || true;
    echo -e "" >> $analyze_file;

    #аналогичным образом работаем по другому "столбцу" - коды возврата
    echo "Список всех кодов возврата:" >> $analyze_file;
    cat $1 | tail -n $count_needs_lines | cut -d ' ' -f 9 | sort | uniq -c | sort -nr | head -n 15 | sed -e 's/^[[:space:]]*//' | awk '{ print "   ",$2," - ",$1}'  >> $analyze_file || true;
    echo -e "" >> $analyze_file;

    #аналогичным образом работаем по другому "столбцу" - коды ошибок
    echo "Список всех кодов возврата 4xx и 5xx (ошибки):" >> $analyze_file;
    cat $1 | tail -n $count_needs_lines | cut -d ' ' -f 9 | sort | uniq -c | sort -nr | head -n 15 | sed -e 's/^[[:space:]]*//' | awk '{ if ($2 > 400 && $2 < 600) print "   ",$2," - ",$1}'  >> $analyze_file || true;
    echo -e "" >> $analyze_file;
}

function start(){
    count_coincidences=$(ps aux | grep $0 | wc -l ) #смотрим во все процессы и ищем себя
    if [[ $count_coincidences -gt 4 ]] #должно быть 3, но почему-то именно на моей машине в момент определния переменной выдаёт 4, при одновременном запуске скрипта будет 6, поэтому всё работает
    then
        printf "Обнаружен мультизапуск!\nЗавершение работы скрипта...\n";
        exit 40;
    fi
    if [[ $1 == "" ]] #Проверяем наличие параметра (пути до анализируемого файла)
    then
        printf "Не задан путь до файла!\nЗавершение работы скрипта...\n";
        exit 10;
    fi
    if [[ !(-f $1) ]] #Проверяем наличие файла
    then
        printf "Файла не существует!\nЗавершение работы скрипта...\n";
        exit 20;
    fi

    analyze $1 #запускаем функцию анализа

    exit 0;
}

start $1 
