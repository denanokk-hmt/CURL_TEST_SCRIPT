#!bin/bash -evx

##############################
#
# watson conversationに対して、QAログを取得するスクリプト
#
# 引数
#   $1:Qデータ(.csv)
#   $2:上記QデータのQuestionの列の位置[デフォルト1]
#
#############################

tmp=/tmp/qa_curl-tmp

################################
rm -f $tmp-*

################################
#VALIDATION
################################
if [ -z "$1" ]; then
  echo "[VAILD ERR] You do not set test filename. sample:'sh exec test_1.csv 1'"
  exit 0
fi
if [ -e "./TEST_DATA/$1" ]; then
 :
else
  echo "[VALID ERR] You do not set test data file. Please put test data in TEST_DATA FOLDER."
  exit 0
fi


################################
#Arguments
################################
TEST_FILE_NAME=$1
COL=${2:-1}


################################
#Nodeを実行するSHELLを叩く
################################
`sh ./SHELL/exec_nodejs.sh` &
sleep 2

################################
#処理終了後にKillするプロセスIDを取得
################################
#echo $$ 
PID_1=$!
echo $PID_1

PIDS=$(ps -aefw | grep "node" | grep -v " grep " | awk '{print $2}')
echo $PIDS
PID_2=$(echo $PIDS | awk '{print $NF}')
echo $PID_2

PID_3=`cat $tmp-nodepid`
echo $PID_3


################################
#Nodejs起動Waiting
################################
touch $tmp-curl-chk
echo "checking nodejs..."
COUNTER=0
while [ "$COUNTER" -lt 10 ]
do
  if [ -z "$(cat $tmp-curl-chk)" ]; then
    CHECK_RESULT=0
    echo "Not yet"
    sleep 2
    chk=$(curl -X GET localhost:8080//v1/searchers/alias/main/search-answer?text=Hello)
    echo $chk >> $tmp-curl-chk
  else
    CHECK_RESULT=1
    echo "Got it!"
    break
  fi
  let COUNTER++
done


################################
#Nodejs起動失敗
################################
if [ "$CHECK_RESULT" = 0 ]; then
  kill $PID_1
  kill $PID_2
  kill $PID_3
  echo "can't start nodejs. please call administrator."
  exit 0
fi
echo "done nodejs checking"


################################
#QA Curl test
################################
echo 'start api server on local.'

sh ./SHELL/qa_curl.sh ./TEST_DATA/${TEST_FILE_NAME} localhost ${COL} &


wait $!
echo $?

################################
#FINISH
################################
echo "Local API server shutdown..."
#COUNTER2=0
#while [ "$COUNTER2" -lt 10 ]
#do
kill $PID_1
kill $PID_2
kill $PID_3
rm -f $tmp-*
echo "Finish curl test, And shutdown API server."

exit 0 
