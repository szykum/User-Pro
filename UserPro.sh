#!/bin/bash

# Author           : Szymon Kummer ( szykumme@studnet.pg.gda.pl )
# Created On       : 21-05-2016
# Last Modified By : Szymon Kummer ( szykumme@studnet.pg.gda.pl )
# Last Modified On : 24-05-2015 
# Version          : 1.0
#
# Description      : 	Program stworzony na rzecz projektu z przedmiotu Systemy Operacyjne.
# Opis		     		Program służy do dodawania, usuwania, oraz modyfikowania użytkowników 
#		    			oraz grup użytkowników w systemach linuxowych.			
#
#
#						Program that allows user to manage user accounts in linux systems.
#						It provides adding, removing and modifying accounts and user groups 
#						
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


################################################################################################ 
#wyjscie z programu
#exit

function quit {
               if zenity --question --title "Wyjście" --text "Czy na pewno chcesz wyjść"; then
		 opcja=$((opcja+1));
		fi
              }
################################################################################################ 
#funkcja usuwajaca zadanego uzytkownika ze wszystkich grup
#removing user from group

function removeFromGroups {
              	cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "listofusers.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz Użytkownika" --title "UserPro"`
		if [ $? -ne 1 ]; then 	
			if zenity --question --title "UserPro" --text "Czy na pewno chcesz usunąc użytkownika $odp2 z grup?"; then
			 sudo usermod -G "" $odp2
			 zenity --info --title "UserPro" --text "$odp2 został usuniety z grup"
			else
			 groupUser 
			fi
		fi
		groupUser
              }
################################################################################################ 
#funkcja ktora dodaje konkretnego uzytkownika do konkretnej grupy
#adding user to group

function ADDtoGR {
               cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "listofusers.txt"
		odp1=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz Użytkownika do grupy" --title "UserPro"`
		
		if [ $? -eq 1 ]; then 	
			return		
		fi

		cat /etc/group | grep "GR" | cut -d "-" -f 1 > Grupy.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "Grupy.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz grupę" --title "UserPro"`
		
		if [ $? -ne 1 ]; then 	
			sudo usermod -a -G "$odp2-GR" $odp1
			zenity --info --title "UserPro" --text "Użytkownik $odp1 został dodany do grupy $odp2" 	
		fi
		groupUser
              }
################################################################################################ 
#funkcja wyswietlajaca liste grup oraz informacje o skladzie danej grupy
#show list of groups 

function listOfGr {
		cat /etc/group | grep "GR" | cut -d "-" -f 1 > Grupy.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "Grupy.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wyświetl członków grupy:" --title "UserPro"`
		if [ $? -ne 1 ]; then 
			cat /etc/group | grep "$odp2-GR:" | cut -d ":"  -f 4 > groupMembers.txt
			Lista=$(<groupMembers.txt)
			zenity --info --title "UserPro" --width 250  --text "Do grupy $odp2 należą: \n $Lista" 
		fi
		groupUser

              }
################################################################################################ 
#funkcja dodawajaca grupe
#add group

function ADDGR {
                zenity --forms --title="UserPro" --text="Nowa Grupa"  --separator=$'\n' --add-entry="Nazwa" > newGr.txt
		if [ $? -ne 1 ]; then 
			GR=$(head -n 1 newGr.txt | tail -1)	
			sudo groupadd "$GR-GR"
			zenity --info --title "UserPro" --text "Grupa została pomyślnie dodana" 
			echo " " > newGr.txt
			cat /etc/group | grep "GR" | cut -d "-" -f 1 > Grupy.txt
		fi
		groupUser
              }
################################################################################################ 
#funkcja usuwajaca grupe
#remove group

function DELGR {
               cat /etc/group | grep "GR" | cut -d "-" -f 1 > Grupy.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "Grupy.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz grupę do skasowania" --title "UserPro"`
		if [ $? -ne 1 ]; then 
			if zenity --question --title "UserPro" --text "Czy na pewno chcesz usunąc grupę $odp2 ?"; then
				 sudo groupdel "$odp2-GR"
				 zenity --info --title "UserPro" --text "$odp2 został usuniety"
			else
				 groupUser
			fi
		fi
		cat /etc/group | grep "GR" | cut -d "-" -f 1 > Grupy.txt
		groupUser
              }
################################################################################################ 
#ustawienie wygasniecia konta
#set disable account

function dateGone {
              cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "listofusers.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz Użytkownika" --title "UserPro"`	
		if [ $? -ne 1 ]; then 	
			DATE=`zenity --calendar --width 350 --date-format=%Y-%m-%d`
			sudo usermod -e $DATE $odp2
			zenity --info --title "UserPro" --text "Data wygaśnięcia $odp2: $DATE" 			
		fi
		midifyuser
              	
              }
################################################################################################ 
#blokowanie uzytkownika
#block user

function lockUs {
              cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "listofusers.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz Użytkownika do zablokowania" --title "UserPro"`
		if [ $? -ne 1 ]; then 	
			sudo usermod -L $odp2
			zenity --info --title "UserPro" --text "Użytkownik $odp2 został zablokowany" 
		fi
		modifyUser
              }
################################################################################################ 
#odblokowywanie uzytkownika
#unblock user

function unlockUs {
              cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "listofusers.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz Użytkownika do odblokowania" --title "UserPro"`
		if [ $? -ne 1 ]; then
			sudo usermod -U $odp2
			zenity --info --title "UserPro" --text "Użytkownik $odp2 został odblokowany" 
		fi
		modifyUser
              }
################################################################################################ 
#zmiana katalogu domowego
#change home dir

function changeHomeDir {
               cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "listofusers.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz Użytkownika do zmiany katalogu domowego" --title "UserPro"`
		if [ $? -eq 1 ]; then
			return
		fi
		zenity --forms --title="UserPro" --text="Zmiana katalogu domowego"  --separator=$'\n' --add-entry="Nowy katalog domowy" > newUser.txt
		if [ $? -ne 1 ]; then
			KAT=$(head -n 1 newUser.txt | tail -1)	
			sudo usermod -m -d /home/$KAT $odp2	
			echo " " > newUser.txt
			zenity --info --title "UserPro" --text "Katalog został pomyślnie zmieniony" 
		fi
		modifyUser
              }
################################################################################################ 
#zmienianie hasla uzytkownika 
#change password

function changePasswd {
              cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "listofusers.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz Użytkownika do zmiany hasła" --title "UserPro"`
		if [ $? -ne 1 ]; then 	
			zenity --forms --title="UserPro" --text="Zmiana hasła"  --separator=$'\n' --add-password="Nowe hasło" --add-password="Potwierdz nowe hasło" > newUser.txt
			PASS1=$(head -n 1 newUser.txt | tail -1)
			PASS2=$(head -n 2 newUser.txt | tail -1)
			if [ $PASS1 != $PASS2 ]; then 
				zenity --info --title "UserPro" --text "HASŁA NIE SĄ ZGODNE!!" 
				changePasswd
			else
				sudo usermod -p `perl -e "print crypt("$PASS1","Q4")"` $odp2
				zenity --info --title "UserPro" --text "Hasło zostało pomyślnie zmienione!!" 
			fi
			echo " " > newUser.txt	
		fi
		modifyuser
              }
################################################################################################ 
#dodawanie uzytkownika
#add user

function addUser {
               	zenity --forms --title="UserPro" --text="Dodaj Nowego Użytkownika" --height 250 --width 400  --separator=$'\n' --add-entry="Imie" --add-entry="Nazwisko" --add-entry="Nazwa Użytkownika" ---add-password="Hasło" --add-password="Potwierdz Hasło" > newUser.txt
		if [ $? -ne 1 ]; then 	
			IM=$(head -n 1 newUser.txt | tail -1)
			NAZW=$(head -n 2 newUser.txt | tail -1)
			NAME=$(head -n 3 newUser.txt | tail -1)
			PASS1=$(head -n 4 newUser.txt | tail -1)
			PASS2=$(head -n 5 newUser.txt | tail -1)
		
			if [ $PASS1 != $PASS2 ]; then 
				zenity --info --title "UserPro" --text "HASŁA NIE SĄ ZGODNE!!" 
				addUser
			else
				sudo useradd -d /home/$NAME -c "$IM $NAZW" -m -p $(echo "$PASS1" | openssl passwd -1 -stdin) $NAME
				zenity --info --title "UserPro" --text "UŻYTKOWNIK $NAME ZOSTAŁ POMYSLNIE DODANY" 		
			fi	
			cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
			echo " " > newUser.txt	
  		fi  	
              }
################################################################################################ 
#usuwanie uzytkownika
#remove user

function deleteUser {
              	cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		FILE_LIST=()
		ITERATOR=0
			while IFS='' read -r line || [[ -n "$line" ]]; do
				FILE_LIST[$ITERATOR]="$line"
				ITERATOR=$(($ITERATOR+1))
			done < "listofusers.txt"
		odp2=`zenity --list --column=Menu "${FILE_LIST[@]}" --text "Wybierz Użytkownika" --title "UserPro"`
		if [ $? -ne 1 ]; then 	
			if zenity --question --title "UserPro" --text "Czy na pewno chcesz usunąc użytkownika $odp2 ?"; then
			 sudo userdel -r $odp2
			 zenity --info --title "UserPro" --text "$odp2 został usuniety"
			else
			 return 
			fi
			cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		fi
              }

################################################################################################ 
#lista uzytkownikow
#list of users

function listOfUser {
               cat /etc/passwd | grep "/home" | cut -d ":"  -f 1 > listofusers.txt
		Lista=$(<listofusers.txt)
		zenity --info --title "UserPro" --width 150  --text "Użytkownicy na tym komputerze: \n\n $Lista" 

              }
################################################################################################ 
#menu zarzadzania uzytkownikow
#menu

function modifyUser {
               	menu2=("Zmień Hasło" "Zmień Katalog Domowy" "Zablokuj Użytkownika" "Odblokuj Użytkownika" "Data Wygaśnięcia")
		odp3=`zenity --list --column=Menu "${menu2[@]}" --text "Wybierz Opcje"  --height 250 --width 300 --title "UserPro"`	
		case "$odp3" in 
			"${menu2[0]}")
				changePasswd;;
			"${menu2[1]}")
				changeHomeDir;;
			"${menu2[2]}")
				lockUs;;
			"${menu2[3]}")
				unlockUs;;
			"${menu2[4]}")
				dateGone
		esac	
		
              }
################################################################################################ 
#menu grup uzytkownikow

function groupUser {
               	menu=("Dodaj Grupę" "Usuń Grupę" "Dodaj Do Grupy" "Usuń Z Grup" "Pokaż Grupy" )
		odp=`zenity --list --column=Menu "${menu[@]}" --text "Wybierz Opcje"  --height 250 --width 300 --title "UserPro"`
		case "$odp" in 
			"${menu[0]}")
				ADDGR;;
			"${menu[1]}")
				DELGR;;
			"${menu[2]}")
				ADDtoGR;;
			"${menu[3]}")
				removeFromGroups;;	
			"${menu[4]}")
				listOfGr		
		esac
              }
################################################################################################
#getopts

while getopts :hv o
do
	case $o in
		h)
			man ./UserPro.1
			exit
			;;
		v)	
			zenity --info --title "UserPro" --width 300 --text "Witaj w programie UserPro. \n Obecna wersja programu 1.0!"
			exit
			;;
	       \?)
			zenity --info --title "UserPro" --text "Zła opcja -$OPTARG.\nMożliwe opcje: -v i -h."
			exit
			;;
	esac
done

################################################################################################
#przywitanie
#welcome

zenity --info  --title "UserPro" --text  "			
			  Witaj w UserPro.

 Program jest przeznaczony do tworzenia, usuwania, 
oraz modyfikacji kont użytkowników w systemie Fedora.

Program został stworzony jako projekt zaliczeniowy
na przedmiot 'Systemy Operacyjne'.

Od dnia 1 czerwca 2016 dostępna będzie wersja programu
UserPro Master, którą będzie można nabyć na stronie
www.extraprogramy.pl za jedyne 30zł. " 
################################################################################################ 
opcja=0
while [ $opcja -eq 0 ]; do
menu=("Dodaj Uzytkownika" "Usuń Użytkownika" "Zarządzaj Użytkownikami" "Grupy" "Lista Użytkowników" "Wyjscie" )
odp=`zenity --list --column=Menu "${menu[@]}" --text "Wybierz Opcje"  --height 300 --width 300 --title "UserPro"`

if [ $? -eq 1 ]; then 
	break
fi
################################################################################################
#menu główne
#main menu

case "$odp" in 
	"${menu[0]}")
		addUser;;

	"${menu[1]}")
		deleteUser;;

	"${menu[2]}")
		modifyUser;;

	"${menu[3]}")
		groupUser;;
	
	"${menu[4]}")
		listOfUser;;

	"${menu[5]}")
		quit
		
esac
done
################################################################################################
#pozegnanie


	zenity --info --title "UserPro" --text "Program zostanie wyłączony" 
################################################################################################ 

