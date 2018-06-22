#!bin/bash

##############################
#
# wncアプリを起動する
#
##############################


tmp=/tmp/qa_curl-tmp


##############################
#Watson Assistant Credential
##############################
WORKSPACE_ID=`cat ./CONFIG/watson | awk 'BEGIN {FS=","} NR==3 {print $2}'`
CONVERSATION_USERNAME=`cat ./CONFIG/watson | awk 'BEGIN {FS=","} NR==4 {print $2}'`
CONVERSATION_PASSWORD=`cat ./CONFIG/watson | awk 'BEGIN {FS=","} NR==5 {print $2}'`


##############################
#このスクリプトのPIDを出力(Kill用)
##############################
echo $$ > $tmp-nodepid


##############################
#wncを起動
##############################
cd ./wnc
node bin/www $WORKSPACE_ID $CONVERSATION_USERNAME $CONVERSATION_PASSWORD


exit 0 
