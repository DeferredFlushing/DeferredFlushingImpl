# Overview

- **Paper**: Deferred Flushing for Out-of-Order Arrivals in Apache IoTDB.(TBA)
- **Implementation**: The code for deffered strategy can be found in the repository of Apache IoTDB, https://github.com/apache/iotdb/tree/research/deferred_strategy
- **Datasets**: All datasets used in the paper are list in the datasets
- **Evaluation**: The benchmark will execute the test in the default verifyWrite and verifyQuery mode, the code can be found in the repository of IoT-Benchmark https://github.com/thulab/iot-benchmark/tree/research/deferred_strategy
___ 
 
## Prerequisites

Clone this Apache IoTDB repository of [`deferred_strategy`](https://github.com/apache/iotdb/tree/research/deferred_strategy), to use IoTDB, you need to have:
- Java >= 1.8 (1.8, 11 to 17 are verified. Please make sure the environment path has been set accordingly).
- Maven >= 3.6 (If you want to compile and install IoTDB from source code).

Clone this IoT-Benchmark repository of [IoT-Benchmark](https://github.com/thulab/iot-benchmark)
the prerequisites is the same as Apach IoTDB.
___

## 1. Build

Build IoTDB from source
Under the root path of iotdb:
```
> mvn clean package -pl distribution -am -DskipTests
```
After being built, the IoTDB distribution is located at the folder: "distribution/target".

Build iot-benchmark from source:
```
> mvn clean package -Dmaven.test.skip=true
```

## 2. Datasets

Run `generateDataMode` in the IoT-Benchmark to generate the synthetic datasets with other configs. Then the datasets will shown in the `data/test` folder 
shown with `d_0` folder with info.txt and schema.txt

Move the dataset in the `Datasets` into the `d_0` folder, which is shown in the `run_benchmark.sh`
```
rm -rf "${TEST_IOTDB_BENCHMARK_PATH}/data/test/d_0/"
mkdir "${TEST_IOTDB_BENCHMARK_PATH}/data/test/d_0/"
```
## 3. Execution

The details about exectution can be seen in the `run_benchmark.sh`. It shows the configurations about the Apache IoTDB and the IoT-Benchmark.
Following the comments in `run_benchmark.sh`, we can directly run the bash

```
bash run_benchmark.sh
```

If you want to run the experiments manually, you can run as following:

#### Server configuration
Get into the folder "conf", and modify the `seq_memtable_topk_size` 

the important configuration is as follows:
```
seq_memtable_topk_size=?
avg_series_point_number_threshold=10000
enable_mem_control=true
```

then get into the folder "sbin", run the following command to start server.

```bash
bash sbin/start-confignode.sh
bash sbin/start-datanode.sh
```
#### Client configuration
After configuring the settings in the "conf" folder, and upload the datasets in the "data/test/d_0" folder,
you can begin to do testing.

Get into the folder "sbin", run the following command to start the test.