#!/bin/bash

PS3='VPNWALL Services Linux Script: Choisissez '
options=("Installer" "Modifier Compte Utilisateur" "Se Connecter au VPN" "Deconnexion" "Quitter")
select opt in "${options[@]}"
do
	case $opt in
		"Installer")
			echo "Installation en cours"
			cd /tmp/
			wget http://www.softether-download.com/files/softether/v4.22-9634-beta-2016.11.27-tree/Linux/SoftEther_VPN_Client/64bit_-_Intel_x64_or_AMD64/softether-vpnclient-v4.22-9634-beta-2016.11.27-linux-x64-64bit.tar.gz --no-clobber
			apt-get update ; apt-get install make gcc libncurses5-dev -y --force-yes
			tar xf /tmp/softether-vpnclient-*.tar.gz
			mv /tmp/vpnclient /opt
			cd /opt/vpnclient
			export CCFLAGS="gcc -fPIC"
			export CXXFLAGS="g++ -fPIC"
			make distclean ; make clean
			make
			./vpnclient start
			echo "Paramétrage Compte"
			echo "Veuillez entrez vos identifiants"
			echo "Nom d'utilisateur : "
			read username
			echo "Mot de passe : "
			read password
			./vpncmd /CLIENT 127.0.0.1 /CMD NicCreate vpnwall
			./vpncmd /CLIENT 127.0.0.1 /CMD AccountCreate "VPNWALL Services" /SERVER:"vpnwall.xyz:8080" /HUB:"vpnwall.xyz" /USERNAME:"$username" /NICNAME:vpnwall
			./vpncmd /CLIENT 127.0.0.1 /CMD AccountPasswordSet "VPNWALL Services" /PASSWORD:"$password" /TYPE:standard
			exit
			;;
		"Modifier Compte Utilisateur")
			cd /opt/vpnclient
			echo "Paramétrage Compte"
			echo "Veuillez entrez vos identifiants"
			echo "Nom d'utilisateur : "
			read username
			echo "Mot de passe : "
			read password
			./vpncmd /CLIENT 127.0.0.1 /CMD AccountDelete "VPNWALL Services"
			./vpncmd /CLIENT 127.0.0.1 /CMD AccountCreate "VPNWALL Services" /SERVER:"vpnwall.xyz:8080" /HUB:"vpnwall.xyz" /USERNAME:"$username" /NICNAME:vpnwall
			./vpncmd /CLIENT 127.0.0.1 /CMD AccountPasswordSet "VPNWALL Services" /PASSWORD:"$password" /TYPE:standard
			exit
			;;
		"Se Connecter au VPN")
			cd /opt/vpnclient
			./vpncmd /CLIENT 127.0.0.1 /CMD AccountConnect "VPNWALL Services"
			dhclient vpn_vpnwall
			;;
		"Deconnexion")
			cd /opt/vpnclient
			./vpncmd /CLIENT 127.0.0.1 /CMD AccountDisconnect "VPNWALL Services"
			;;
		"Quitter")
			break
			;;
		*) echo "Option invalide";;
	esac
done
