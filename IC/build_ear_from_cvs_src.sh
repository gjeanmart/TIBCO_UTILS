#!/bin/bash --

echo "INFO : build_ear_from_cvs_src.sh"

usage()
{
	echo "ERROR : Usage => build_ear_from_cvs_src.sh {version}"
}

if [ $# != 1 ]
then
	usage
	exit 2
fi


#variables ! 
WKS_HOME=/home/tibcoadmin/workspace/Argus-PFNum-BW

# CVS
CVS_SERVER=172.16.5.26
CVS_PATH=/cvs
CVS_USERNAME=gjeanmar
CVS_PASSWORD=gJ

#TIBCO
TRA_HOME=/opt/tibco/tra/5.7/bin 
TIBCO_DOMAIN_NAME=ARGUS
TIBCO_DOMAIN_USERNAME=tibco-admin
TIBCO_DOMAIN_PASSWORD=tibco-admin

#PROJET
PROJECT_NAME=Argus-ApproNum-BW
PROJECT_VERSION=$1
PROJECT_VERSION_REF=3.1.0
PROJECT_ALIAS_LIB=$WKS_HOME/alias_lib.properties
PROJECT_ARCHIVE_PATH=/Argus-ApproNum-BW/Archive/ear/Argus-ApproNum-BW.archive
PROJECT_EAR_OUTPUT=$WKS_HOME/ear/$PROJECT_NAME-$PROJECT_VERSION.ear
PROJECT_CONFIG_OUTPUT=$WKS_HOME/ear/$PROJECT_NAME-$PROJECT_VERSION.conf
PROJECT_CONFIG_REF_OUTPUT=$WKS_HOME/ear/$PROJECT_NAME-$PROJECT_VERSION_REF.conf


#SCRIPT HAWK
HAWK_SCRIPT_WAIT_TIME=20

if [ ! -f $PROJECT_CONFIG_OUTPUT ]
then
	echo "INFO : Le fichier de configuration $PROJECT_CONFIG_OUTPUT n'existe pas. Création à partir de la référence $PROJECT_CONFIG_REF_OUTPUT"
	echo "DEBUG : >> cp $PROJECT_CONFIG_REF_OUTPUT $PROJECT_CONFIG_OUTPUT"
	cp $PROJECT_CONFIG_REF_OUTPUT $PROJECT_CONFIG_OUTPUT
fi

cd $WKS_HOME/src
 
echo "INFO : Nettoyage des sources"
echo "DEBUG : >> rm -rf $WKS_HOME/src/$PROJECT_NAME/"
rm -rf $WKS_HOME/src/$PROJECT_NAME/
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 2
fi

echo "INFO : Nettoyage de l'EAR"
echo "DEBUG : >> rm -rf $PROJECT_EAR_OUTPUT"
rm -rf $PROJECT_EAR_OUTPUT
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 3
fi

echo "INFO : CVS Login"
echo "DEBUG : >> cvs -d :pserver:$CVS_USERNAME:$CVS_PASSWORD@$CVS_SERVER:$CVS_PATH login"
cvs -d :pserver:$CVS_USERNAME:$CVS_PASSWORD@$CVS_SERVER:$CVS_PATH login
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 4
fi

 
echo "INFO : CVS checkout project"
echo "DEBUG : >> cvs -d  :pserver:$CVS_USERNAME:$CVS_PASSWORD@$CVS_SERVER:$CVS_PATH checkout $PROJECT_NAME"
cvs -d  :pserver:$CVS_USERNAME:$CVS_PASSWORD@$CVS_SERVER:$CVS_PATH checkout $PROJECT_NAME
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 5
fi

 
echo "INFO : CVS update project"
echo "DEBUG : >> cvs -d :pserver:$CVS_USERNAME:$CVS_PASSWORD@$CVS_SERVER:$CVS_PATH update"
cvs -d :pserver:$CVS_USERNAME:$CVS_PASSWORD@$CVS_SERVER:$CVS_PATH update
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 6
fi

 
echo "INFO : TIBCO build ear"
cd $TRA_HOME
echo "DEBUG : >> ./buildear -x -a $PROJECT_ALIAS_LIB -v -ear $PROJECT_ARCHIVE_PATH -o $PROJECT_EAR_OUTPUT -p $WKS_HOME/src/$PROJECT_NAME/"
./buildear -x -a $PROJECT_ALIAS_LIB -v -ear $PROJECT_ARCHIVE_PATH -o $PROJECT_EAR_OUTPUT -p $WKS_HOME/src/$PROJECT_NAME/
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 7
fi


 
echo "INFO : Redemarrage de Hawk"
echo "DEBUG : >> /home/tibcoadmin/scripts/tibco_hawk.sh stop"
/home/tibcoadmin/scripts/tibco_hawk.sh stop
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 8
fi

 
echo "INFO : Attente de $HAWK_SCRIPT_WAIT_TIME secondes"
sleep $HAWK_SCRIPT_WAIT_TIME ;


echo "DEBUG : >> /home/tibcoadmin/scripts/tibco_hawk.sh start"
/home/tibcoadmin/scripts/tibco_hawk.sh start
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 10
fi

echo "INFO : Attente de $HAWK_SCRIPT_WAIT_TIME secondes"
sleep $HAWK_SCRIPT_WAIT_TIME ;

echo "INFO : TIBCO deploy ear"
echo "DEBUG : >> ./AppManage -deploy -ear $PROJECT_EAR_OUTPUT -deployconfig $PROJECT_CONFIG_OUTPUT -app Argus/$PROJECT_NAME -domain $TIBCO_DOMAIN_NAME -user $TIBCO_DOMAIN_USERNAME -pw $TIBCO_DOMAIN_PASSWORD"
./AppManage -deploy -ear $PROJECT_EAR_OUTPUT -deployconfig $PROJECT_CONFIG_OUTPUT -app Argus/$PROJECT_NAME -domain $TIBCO_DOMAIN_NAME -user $TIBCO_DOMAIN_USERNAME -pw $TIBCO_DOMAIN_PASSWORD
result=$?
if [ $result -ne 0 ]
then
	echo "ERROR : Resultat de la dernière commande $result"
	exit 11
fi

cd $WKS_HOME/src


echo "INFO : Arrêt du script"
exit
