# !/bin/sh
# The file can be run in Linux/Mac System
# INIT_PATH=/home/${ACCOUNT}
INIT_PATH=/home
# TEST_IOTDB_PATH=${INIT_PATH}/2023-IoTDB-Flush/apache-iotdb-1.3.0-SNAPSHOT-bin-all
TEST_IOTDB_BENCHMARK_PATH=${INIT_PATH}/iot-benchmark-iotdb-1.1-0730/
TEST_IOTDB_PATH=${INIT_PATH}/apache-iotdb-1.3.1-SNAPSHOT-all-bin/
DATASET_PATH=${INIT_PATH}/datasets/

# DATASETS=(0 "BotIoT.csv_BigBatch_0.csv" "Samsung.csv_BigBatch_0.csv" "E5.csv_BigBatch_0.csv" "E5.csv_BigBatch_0.csv" "E5.csv_BigBatch_0.csv" "W2.csv_BigBatch_0.csv")
DATASETS=(0 "BigBatch_absn6_m1s0.csv" "BigBatch_absn6_m1s1.csv" "BigBatch_absn6_m1s4.csv" "BigBatch_absn6_m1s16.csv" "BigBatch_BotIoT.csv" "BigBatch_Samsung.csv" "BigBatch_E10.csv" "BigBatch_W2.csv")

OPERATION_PROPORTIONS=(0 "1:0:0:0:0:0:0:0:0:0:0" "0:0:1:0:0:0:0:0:0:0:0")
BENCHMARK_WORK_MODES=(0 "verificationWriteMode" "verificationQueryMode")
LOG_FILES=(0 "m1s0" "m1s1" "m1s4" "m1s16" "BotIoT" "Samsung" "E5" "W2")

KAPPAS=(0 "0" "16" "64" "128" "256" "512" "1024")
KAPPAS=(0 "0" "16" "32" "64" "128" "256" "512" "1024" "2048" "4096")

################### test operation ###################
test_operation() {
  # test for 10 times
  for ((loop = 1; loop <= 10; loop++)); do
    # test different kappa values
    for ((k = 1; k <= 10; k++)) do
      KAPPA=${KAPPAS[${k}]}
      # cd ${TEST_IOTDB_PATH}
      echo "Start testing KAPPA=${KAPPA}"
      bash ${TEST_IOTDB_PATH}/sbin/stop-all.sh 2>&1
      sleep 4
      rm -rf "${TEST_IOTDB_PATH}/data/"
      rm -rf "${TEST_IOTDB_PATH}/logs/"
      sleep 4
      ## the next 4 lines can be used to check whether the confignode and datanode is killed
      # PID_VERIFY=$(ps ax | grep -i 'ConfigNode' | grep java | grep -v grep | awk '{print $1}')
      # echo "After Stop ConfigNode PID_VERIFY=${PID_VERIFY}"
      # PID_VERIFY=$(ps ax | grep -i 'DataNode' | grep java | grep -v grep | awk '{print $1}')
      # echo "After Stop DataNode PID_VERIFY=${PID_VERIFY}"
      # set the kappa value in the iotdb config file
      sed -i "" "s/^seq_memtable_topk_size=.*$/seq_memtable_topk_size=${KAPPA}/g" ${TEST_IOTDB_PATH}/conf/iotdb-common.properties
      # cd ${TEST_IOTDB_PATH}
      bash ${TEST_IOTDB_PATH}sbin/start-all.sh 2>&1 
      sleep 4
      datanode_process=$(jps | grep "DataNode")
      echo "datanode_process=${datanode_process}"
      if [ -n "$datanode_process" ]; then
        echo "2. DataNode is running，启动IoTDB：KAPPA=${KAPPA}"
        sleep 10
      else
        k=$((k-1))
        echo "2. DataNode does not start, try again"
        continue
      fi

      for ((j = 1; j <= 8; j++)); do
        DATASET=${DATASETS[${j}]}

        rm -rf "${TEST_IOTDB_BENCHMARK_PATH}/data/test/d_0/"
        mkdir "${TEST_IOTDB_BENCHMARK_PATH}/data/test/d_0/"
        cp "${DATASET_PATH}/${DATASET}" "${TEST_IOTDB_BENCHMARK_PATH}/data/test/d_0/"

        OPERATION_PROPORTION=${OPERATION_PROPORTIONS[1]}
        BENCHMARK_WORK_MODE=${BENCHMARK_WORK_MODES[1]}
        echo "Test Config：dataset=${DATASET}, operation proportion=${OPERATION_PROPORTION} test node=${BENCHMARK_WORK_MODE}"
        sed -i "" "s/^OPERATION_PROPORTION=.*$/OPERATION_PROPORTION=${OPERATION_PROPORTION}/g" ${TEST_IOTDB_BENCHMARK_PATH}/conf/config.properties
        sed -i "" "s/^BENCHMARK_WORK_MODE=.*$/BENCHMARK_WORK_MODE=${BENCHMARK_WORK_MODE}/g" ${TEST_IOTDB_BENCHMARK_PATH}/conf/config.properties
        # start test
        cd ${TEST_IOTDB_BENCHMARK_PATH}
        mkdir "${TEST_IOTDB_BENCHMARK_PATH}/data/logs/${KAPPA}/"
        bash benchmark.sh 2>&1 | tee ${TEST_IOTDB_BENCHMARK_PATH}/data/logs/${KAPPA}/${DATASET}_${LOG_FILES[${j}]}_${loop}_${BENCHMARK_WORK_MODE}.log >/dev/null
        sleep 5
        echo "Test finished：dataset=${DATASET}, operation proportion=${OPERATION_PROPORTION} test node=${BENCHMARK_WORK_MODE}"
        
        OPERATION_PROPORTION=${OPERATION_PROPORTIONS[2]}
        BENCHMARK_WORK_MODE=${BENCHMARK_WORK_MODES[2]}
        echo "Test Config：dataset=${DATASET}, operation proportion=${OPERATION_PROPORTION} test node=${BENCHMARK_WORK_MODE}"
        sed -i "" "s/^OPERATION_PROPORTION=.*$/OPERATION_PROPORTION=${OPERATION_PROPORTION}/g" ${TEST_IOTDB_BENCHMARK_PATH}/conf/config.properties
        sed -i "" "s/^BENCHMARK_WORK_MODE=.*$/BENCHMARK_WORK_MODE=${BENCHMARK_WORK_MODE}/g" ${TEST_IOTDB_BENCHMARK_PATH}/conf/config.properties
        # start test
        cd ${TEST_IOTDB_BENCHMARK_PATH}
        bash benchmark.sh 2>&1 | tee ${TEST_IOTDB_BENCHMARK_PATH}/data/logs/${KAPPA}/${DATASET}_${LOG_FILES[${j}]}_${loop}_${BENCHMARK_WORK_MODE}.log >/dev/null
        sleep 5
        echo "Test finished：dataset=${DATASET}, operation proportion=${OPERATION_PROPORTION} test node=${BENCHMARK_WORK_MODE}"
      done
    done
  done
}

###############################普通时间序列###############################
start_time=$(date +"%m-%d-%H-%M-%S")
echo "${start_time}开始测试！"
test_operation
end_time=$(date +"%m-%d-%H-%M-%S")
echo "${end_time}测试结束！"
