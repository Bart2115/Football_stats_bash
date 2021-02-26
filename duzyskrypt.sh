#!/bin/bash
# Author           : Bartłomiej Buklewski ( email )
# Created On       : data
# Last Modified By : Imie Nazwisko ( email )
# Last Modified On : data 
# Version          : wersja
#
# Description      :
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#help(){};
TrybTekstowy=0;
Opcja=0;
Opcja2=0;
Menu1=("1. Premier League" "2. La Liga" "3. Bundesliga" "4. Serie A" "5. Ligue 1");
Menu2=("1. Tabela ligowa" "2. Ostatnia kolejka" "3. Klasyfikacja strzelców" "4. Najnowsze transfery" "5. Zmień ligę" "6. Wyłącz program");
echo "0" > tmp.txt
zenity --list --height=400 --width=500 --column=Menu "${Menu1[@]}" >> tmp.txt
if [[ $? -eq 1 ]]; then
Opcja=1;
else
Opcja=$(cut -d '.' -f 1 tmp.txt | grep -v "0")
fi
rm tmp.txt
clear
#echo "1. Premier League";
#echo "2. La Liga";
#echo "3. Bundesliga";
#echo "4. Serie A";
#echo "5. Ligue 1";
#read Opcja;
#clear
while [ 0 ]; do 
    Lista=( );
    echo "0" > tmp.txt
    zenity --list --height=400 --width=500 --column=Menu "${Menu2[@]}" >> tmp.txt
    if [[ $? -eq 1 ]]; then
    Opcja2=6;
    else
    Opcja2=$(cut -d '.' -f 1 tmp.txt | grep -v "0")
    fi
    rm tmp.txt
    #echo " ";
    #echo "1. Tabela ligowa";
    #echo "2. Ostatnia kolejka";
    #echo "3. Klasyfikacja strzelców";
    #echo "4. Najnowsze transfery"; 
    #echo "5. Zmień ligę";
    #echo "6. Wyłącz program";
    #read Opcja2;
    if [ $Opcja2 -eq 1 ]; then
        mkdir tmp;
        #pobierz stronę
        if [ $Opcja -eq 1 ]; then
            wget -q -O tabela https://www.transfermarkt.pl/premier-league/tabelle/wettbewerb/GB1;
        elif [ $Opcja -eq 2 ]; then
            wget -q -O tabela https://www.transfermarkt.pl/primera-division/tabelle/wettbewerb/ES1;
        elif [ $Opcja -eq 3 ]; then
            wget -q -O tabela https://www.transfermarkt.pl/1-bundesliga/tabelle/wettbewerb/L1;
        elif [ $Opcja -eq 4 ]; then
            wget -q -O tabela https://www.transfermarkt.pl/serie-a/tabelle/wettbewerb/IT1;
        elif [ $Opcja -eq 5 ]; then
            wget -q -O tabela https://www.transfermarkt.pl/ligue-1/tabelle/wettbewerb/FR1;
        fi
        #Znalezienie nazw klubów
        grep "class=\"zentriert\"><a title=" tabela | cut -d '"' -f 4 | uniq > tmp/tmpNazwyKlubow.txt
        #Znalezienie w htmlu ilości meczy, wygrane, remisy, przegrane
        grep "class=\"zentriert\"><a title=" tabela | cut -d '"' -f 11 | cut -d '>' -f 2 | cut -d '<' -f 1 > tmp/tmpMecze.txt
        #Znalezienie w htmlu bilansu meczowego
        grep "class=\"zentriert\">" tabela | cut -d '>' -f 2 | cut -d '<' -f 1 | grep ":" > tmp/tmpBilans.txt        
        if [ $TrybTekstowy -eq 1 ]; then
            #Zmiana koloru na zielony
            tput setaf 2; 
            printf "Lp. %-25s   Ilość meczy  Wygrane  Remis  Przegrane  Br. zdobyte  Br. stracone  Bilans  Punkty\n" "Nazwa Klubu";
            #Reset koloru na biały
            tput sgr0;
        fi         
        LiczbaKlubow=$(wc -l tmp/tmpNazwyKlubow.txt | cut -d ' ' -f 1);
        for (( INDEKS=1; INDEKS<=LiczbaKlubow; INDEKS++ ))
        do
            #Pobranie nazwy klubu
            Klub=$(cat tmp/tmpNazwyKlubow.txt | head -$INDEKS | tail -1);
            #Jeśli nazwa klubu zawiera amp w języku html zamieniam go na zwykły ampersand    
            ZnakAnd="&";    
            Klub=${Klub/"&amp;"/$ZnakAnd};
            #Zmienna do "headu", skok co 4
            IndeksHead=$(((INDEKS)*4));
            #Pobranie reszty danych
            IloscMeczy=$(cat tmp/tmpMecze.txt | head -$IndeksHead | tail -4 | sed -n '1p');
            Wygrane=$(cat tmp/tmpMecze.txt | head -$IndeksHead | tail -4 | sed -n '2p');
            Remis=$(cat tmp/tmpMecze.txt | head -$IndeksHead | tail -4 | sed -n '3p');
            Przegrane=$(cat tmp/tmpMecze.txt | head -$IndeksHead | tail -4 | sed -n '4p');
            BramkiZdobyte=$(cat tmp/tmpBilans.txt | head -$INDEKS | tail -1 | cut -d ':' -f 1);
            BramkiStracone=$(cat tmp/tmpBilans.txt | head -$INDEKS | tail -1 | cut -d ':' -f 2);
            #Obliczanie bilansu i punktów    
            Bilans=$((BramkiZdobyte-BramkiStracone));
            Bilans=$( printf '%03d' $Bilans);
            Punkty=$((((Wygrane)*3)+$Remis));
            if [ $TrybTekstowy -eq 1 ]; then 
                printf "%2d. %-25s \t%-12d %-8d %-6d %-11d%-12d %-13d %-8d%-12d\n" $INDEKS "$Klub" $IloscMeczy $Wygrane $Remis $Przegrane $BramkiZdobyte $BramkiStracone $Bilans $Punkty;
            else
            Lista+=("$INDEKS. $Klub");
            Lista+=("$IloscMeczy");
            Lista+=("$Wygrane");
            Lista+=("$Remis");
            Lista+=("$Przegrane");
            Lista+=("$BramkiZdobyte");
            Lista+=("$BramkiStracone");
            Lista+=("$Punkty");
            fi
        done
        if [ $TrybTekstowy -eq 0 ]; then
            zenity --list --column="Klub" --column="Ilość meczy" --column="Wygrane" --column="Remis" --column="Przegrane" --column="Zdobyte bramki" --column="Stracone bramki" --column="Punkty" --height=600 --width=1000 "${Lista[@]}";
        fi
        rm tabela
        rm -R tmp


    elif [ $Opcja2 -eq 2 ]; then
        mkdir tmp;
        if [ $Opcja -eq 1 ]; then
            wget -q -O kolejka https://www.transfermarkt.pl/premier-league/spieltagtabelle/wettbewerb/GB1/saison_id/2019;
        elif [ $Opcja -eq 2 ]; then
            wget -q -O kolejka https://www.transfermarkt.pl/primera-division/spieltagtabelle/wettbewerb/ES1/saison_id/2019;
        elif [ $Opcja -eq 3 ]; then
            wget -q -O kolejka https://www.transfermarkt.pl/1-bundesliga/spieltagtabelle/wettbewerb/L1/saison_id/2019;
        elif [ $Opcja -eq 4 ]; then
            wget -q -O kolejka https://www.transfermarkt.pl/serie-a/spieltagtabelle/wettbewerb/IT1/saison_id/2019;
        elif [ $Opcja -eq 5 ]; then
            wget -q -O kolejka https://www.transfermarkt.pl/ligue-1/spieltagtabelle/wettbewerb/FR1/saison_id/2019;
        fi
        
        grep "<a class=\"vereinprofil_tooltip" kolejka | cut -d ">" -f 2 | cut -d "<" -f 1 > tmp/tmpKolejka.txt;
        grep "class=\"matchresult finished" kolejka | cut -d ">" -f 4 | cut -d "<" -f 1 > tmp/tmpKolejkaWyniki.txt;
        for (( INDEKS=1;INDEKS<=10;INDEKS++ ))
        do  
            IndeksHead=$(((INDEKS)*6));
            if [[ $Opcja -eq 3  && INDEKS -eq 9 ]];then
                break;
            fi
            Klub1=$(cat tmp/tmpKolejka.txt | head -$IndeksHead | tail -6 | sed -n '2p');
            Klub2=$(cat tmp/tmpKolejka.txt | head -$IndeksHead | tail -6 | sed -n '6p');
            Wynik=$(cat tmp/tmpKolejkaWyniki.txt | head -$INDEKS | tail -1 );
            if [ -z "$Wynik" ]; then
                Wynik="-";
            fi
            if [ $TrybTekstowy -eq 1 ]; then 
                printf "%-25s\t%-5s\t\t%-25s\n" "$Klub1" $Wynik "$Klub2";
            else
                Lista+=("$Klub1");
                Lista+=("$Wynik");
                Lista+=("$Klub2");
            fi
        done
        if [ $TrybTekstowy -eq 0 ]; then
            zenity --list --column="Klub" --column="Wynik" --column="Klub" --height=400 --width=600 "${Lista[@]}"
        fi 
        rm -R tmp;
        rm kolejka


    elif [ $Opcja2 -eq 3 ]; then
        mkdir tmp;
        if [ $Opcja -eq 1 ]; then
            wget -q -O statystyki https://www.transfermarkt.pl/premier-league/torschuetzenliste/wettbewerb/GB1/saison_id/2019
            grep "saison/2019/wettbewerb/GB1\">" statystyki | sed '0,/*GB1/ s/^.*GB1//' | cut -d '>' -f 2 | cut -d '<' -f 1 > tmp/tmpPilkarzeGole.txt;
        elif [ $Opcja -eq 2 ]; then
            wget -q -O statystyki https://www.transfermarkt.pl/primera-division/torschuetzenliste/wettbewerb/ES1/saison_id/2019;
            grep "saison/2019/wettbewerb/ES1\">" statystyki | sed '0,/*ES1/ s/^.*ES1//' | cut -d '>' -f 2 | cut -d '<' -f 1 > tmp/tmpPilkarzeGole.txt;
        elif [ $Opcja -eq 3 ]; then
            wget -q -O statystyki https://www.transfermarkt.pl/1-bundesliga/torschuetzenliste/wettbewerb/L1/saison_id/2019;
            grep "saison/2019/wettbewerb/L1\">" statystyki | sed '0,/*L1/ s/^.*L1//' | cut -d '>' -f 2 | cut -d '<' -f 1 > tmp/tmpPilkarzeGole.txt;
        elif [ $Opcja -eq 4 ]; then
            wget -q -O statystyki https://www.transfermarkt.pl/serie-a/torschuetzenliste/wettbewerb/IT1/saison_id/2019;
            grep "saison/2019/wettbewerb/IT1\">" statystyki | sed '0,/*IT1/ s/^.*IT1//' | cut -d '>' -f 2 | cut -d '<' -f 1 > tmp/tmpPilkarzeGole.txt;
        elif [ $Opcja -eq 5 ]; then
            wget -q -O statystyki https://www.transfermarkt.pl/ligue-1/torschuetzenliste/wettbewerb/FR1/saison_id/2019;
            grep "saison/2019/wettbewerb/FR1\">" statystyki | sed '0,/*FR1/ s/^.*FR1//' | cut -d '>' -f 2 | cut -d '<' -f 1 > tmp/tmpPilkarzeGole.txt;
        fi  
        grep "spielprofil_tooltip" statystyki | cut -d '>' -f 2 | cut -d '<' -f 1 > tmp/tmpPilkarze.txt;
        for (( INDEKS=1; INDEKS<=25; INDEKS++ ))                 
        do
            Pilkarz=$(cat tmp/tmpPilkarze.txt | head -$((INDEKS+1)) | tail -1 );
            Gole=$(cat tmp/tmpPilkarzeGole.txt | head -$INDEKS | tail -1 );
            if [ $TrybTekstowy -eq 1 ]; then       
                printf "%-30s\tgole: %d\n" "$Pilkarz" $Gole;   
            else
                Lista+=("$Pilkarz");
                Lista+=("$Gole");           
            fi     
        done
        if [ $TrybTekstowy -eq 0 ]; then
            zenity --list --column="Piłkarz" --height=400 --width=300 "${Lista[@]}" --column="Liczba goli";
        fi        
        rm -R tmp;
        rm statystyki;


    elif [ $Opcja2 -eq 4 ]; then
        mkdir tmp;
        if [ $Opcja -eq 1 ]; then
            wget -q -O transfery https://www.transfermarkt.pl/premier-league/letztetransfers/wettbewerb/GB1;
        elif [ $Opcja -eq 2 ]; then
            wget -q -O transfery https://www.transfermarkt.pl/primera-division/letztetransfers/wettbewerb/ES1/saison_id/2019;
        elif [ $Opcja -eq 3 ]; then
            wget -q -O transfery https://www.transfermarkt.pl/1-bundesliga/letztetransfers/wettbewerb/L1/saison_id/2019;
        elif [ $Opcja -eq 4 ]; then
            wget -q -O transfery https://www.transfermarkt.pl/serie-a/letztetransfers/wettbewerb/IT1/saison_id/2019;
        elif [ $Opcja -eq 5 ]; then
            wget -q -O transfery https://www.transfermarkt.pl/ligue-1/letztetransfers/wettbewerb/FR1/saison_id/2019;
        fi
        
        grep "<a class=\"vereinprofil_tooltip\"" transfery | cut -d '"' -f 6 > tmp/tmpPilkarzeTransfer.txt;
        grep "<a class=\"vereinprofil_tooltip\"" transfery | cut -d '"' -f 32 > tmp/tmpKlubOddajacy.txt;
        grep "<a class=\"vereinprofil_tooltip\"" transfery | cut -d '"' -f 52 > tmp/tmpKlubPozyskujacy.txt;
        grep "<a class=\"vereinprofil_tooltip\"" transfery | cut -d '"' -f 63 | cut -d '>' -f 2 | cut -d '<' -f 1 > tmp/tmpRodzajTransferu.txt;
        if [ $TrybTekstowy -eq 1 ]; then
            #Zmiana koloru na zielony
            tput setaf 2; 
            printf "%-30s\t%-30s\t%-30s\t%-30s\n" "Piłkarz" "Klub Oddający" "Klub Pozyskujący" "Rodzaj transferu";
            #Reset koloru na biały
            tput sgr0;
        fi        
        for (( INDEKS=1; INDEKS<=30; INDEKS++ ))
        do
            Pilkarz=$(cat tmp/tmpPilkarzeTransfer.txt | head -$INDEKS | tail -1 );
            KlubOddajacy=$(cat tmp/tmpKlubOddajacy.txt | head -$INDEKS | tail -1 );
            if [ "$KlubOddajacy" = "Bez klubu" ]; then
                continue;
            fi  
            KlubPozyskujacy=$(cat tmp/tmpKlubPozyskujacy.txt | head -$INDEKS | tail -1);
            Rodzaj=$(cat tmp/tmpRodzajTransferu.txt | head -$INDEKS | tail -1);
            Rodzaj=${Rodzaj/"-"/"Bez odstępnego"};
            Rodzaj=${Rodzaj/"href="/"Bez odstępnego"};
            if [ $TrybTekstowy -eq 1 ]; then
                printf "%-30s\t%-30s\t%-30s\t%-30s\n" "$Pilkarz" "$KlubOddajacy" "$KlubPozyskujacy" "$Rodzaj";
            else
                Lista+=("$Pilkarz");
                Lista+=("$KlubOddajacy");
                Lista+=("$KlubPozyskujacy");
                Lista+=("$Rodzaj");
            fi
        done
        if [ $TrybTekstowy -eq 0 ]; then
            zenity --list --column="Piłkarz" --column="Klub oddający" --column="Klub pozyskujący" --column="Rodzaj transferu" --height=400 --width=800 "${Lista[@]}";
        fi
        rm transfery;
        rm -R tmp;


    elif [ $Opcja2 -eq 5 ]; then
        if [ $TrybTekstowy -eq 1 ]; then
            clear
            echo "1. Premier League";
            echo "2. La Liga";
            echo "3. Bundesliga";
            echo "4. Serie A";
            echo "5. Ligue 1";
            read Opcja;
        else
            echo "0" > tmp.txt
            zenity --list --height=400 --width=500 --column=Menu "${Menu1[@]}" >> tmp.txt
            if [[ $? -eq 1 ]]; then
            Opcja=1;
            else
            Opcja=$(cut -d '.' -f 1 tmp.txt | grep -v "0")
            fi
            rm tmp.txt
        fi
    elif [ $Opcja2 -eq 6 ]; then
        return;
    fi
done
