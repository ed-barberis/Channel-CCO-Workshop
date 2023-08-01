#!/bin/bash

#
# Utility script to create assests in the AppDynamics Controller and populate controller connection details in various files.
#
# export appd_workshop_user=cnao-lab-55
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#---------------------------------------------------------------------------------------------------


# [MANDATORY] workshop grou prefix (appd, apo, cxc, etc.).
workshop_group_prefix=$(echo ${aws_eks_cluster_name} | awk -F '-' '{print tolower($1)}')

# [MANDATORY] workshop user identity.
appd_workshop_user=${workshop_group_prefix}"-teastore-cnao-lab-"${cnao_lab_number}"-"

#appd_workshop_user="cnao-lab-"${cnao_lab_number}"-"


echo ""
echo ""
echo ""
echo ""

echo "           ######################################################################################################################################################################################################################"
echo "                                                                                                                                                                                                                                 "
echo "                                                                                                                                                                                                                                 "
echo "                %%%%%%%          %%%%%%%%%%%%%%%     %%%%%%%%%%%%%%%     %%%%%%%%%%%%%%%     %%%         %%%    %%%%%      %%%          %%%%%%%          %%%           %%%    %%%        %%%%%%%%%%%        %%%%%%%%%%%          "
echo "               %%%   %%%         %%%          %%%    %%%          %%%    %%%          %%%     %%%       %%%     %%% %%     %%%         %%%   %%%         %%%%         %%%%    %%%      %%%                 %%%                   "
echo "              %%%     %%%        %%%           %%%   %%%           %%%   %%%           %%%     %%%     %%%      %%%  %%    %%%        %%%     %%%        %% %%       %% %%    %%%     %%%                   %%%                  "
echo "             %%%       %%%       %%%          %%%    %%%          %%%    %%%            %%%     %%%   %%%       %%%   %%   %%%       %%%       %%%       %%% %%     %% %%%    %%%    %%%                      %%%                "
echo "            %%%%%%%%%%%%%%%      %%%%%%%%%%%%%%%     %%%%%%%%%%%%%%%     %%%            %%%       %%%%%         %%%    %%  %%%      %%%%%%%%%%%%%%%      %%%   %%  %%  %%%    %%%    %%%                        %%%              "
echo "           %%%           %%%     %%%                 %%%                 %%%           %%%         %%%          %%%     %% %%%     %%%           %%%     %%%    %%%%   %%%    %%%     %%%                        %%%             "
echo "          %%%             %%%    %%%                 %%%                 %%%          %%%          %%%          %%%      %%%%%    %%%             %%%    %%%           %%%    %%%      %%%                       %%%             "
echo "         %%%               %%%   %%%                 %%%                 %%%%%%%%%%%%%%%           %%%          %%%       %%%%   %%%               %%%   %%%           %%%    %%%        %%%%%%%%%%%   %%%%%%%%%%%%              "
echo "                                                                                                                                                                                                                                 "
echo "                                                                                                                                                                                                                                 "
echo "#######################################################################################################################################################################################################################          "

echo ""
echo ""
echo ""
echo ""

chmod +x deploy_appdynamics_db_agent_to_kubernetes.sh
chmod +x undeploy_appdynamics_db_agent_from_kubernetes.sh

# check to see if user_id file exists and if so read in the user_id
if [ -f "./appd_workshop_user.txt" ]; then

  appd_workshop_user=$(cat ./appd_workshop_user.txt)

else
  
  # validate mandatory environment variables.

  if [ -z "$appd_workshop_user" ]; then
    echo "CloudWorkshop|ERROR| - 'appd_workshop_user' environment variable not set."
    exit 1
  fi

#  LEN=$(echo ${#appd_workshop_user})

#  if [ $LEN -lt 5 ]; then
#    echo "CloudWorkshop|ERROR| - 'appd_workshop_user' environment variable not set or is not at least five alpha characters in length."
#    exit 1
#  fi


#  if [ "$appd_workshop_user" == "<YOUR USER NAME>" ]; then
#    echo "CloudWorkshop|ERROR| - 'appd_workshop_user' environment variable not set properly. It should be at least five alpha characters in length."
#    echo "CloudWorkshop|ERROR| - 'appd_workshop_user' environment variable should not be set to <YOUR USER NAME>."
#    exit 1
#  fi


  # write the user_id to a file
  echo "$appd_workshop_user" > ./appd_workshop_user.txt

  # echo $USER = ec2-user

  # write the C9 user to a file     example:  james.schneider
  #echo "$C9_USER" > ./appd_env_user.txt

  # write the Hostname to a file   example:  ip-172-31-14-237.us-east-2.compute.internal
  #echo "$HOSTNAME" > ./appd_env_host.txt

fi	

# !!!!!!! BEGIN BIG IF BLOCK !!!!!!!
if [ -f "./appd_workshop_setup.txt" ]; then

  appd_wrkshp_last_setupstep_done=$(cat ./appd_workshop_setup.txt)

  java -DworkshopUtilsConf=./workshop-setup.yaml -DworkshopLabUserPrefix=${appd_workshop_user} -DworkshopAction=setup -DlastSetupStepDone=${appd_wrkshp_last_setupstep_done} -DshowWorkshopBanner=false -jar ./AD-Workshop-Utils.jar

else
# write last setup step file
appd_wrkshp_last_setupstep_done="100"

echo "$appd_wrkshp_last_setupstep_done" > ./appd_workshop_setup.txt

java -DworkshopUtilsConf=./workshop-setup.yaml -DworkshopLabUserPrefix=${appd_workshop_user} -DworkshopAction=setup -DlastSetupStepDone=${appd_wrkshp_last_setupstep_done} -DshowWorkshopBanner=false -jar ./AD-Workshop-Utils.jar

chmod +x deploy_appdynamics_agents_to_hybrid_kubernetes.sh
chmod +x undeploy_appdynamics_agents_from_hybrid_kubernetes.sh

fi
