FROM openjdk:11

# Variaveis de ambiente do Hadoop
ENV HADOOP_VERSION 3.4.0
ENV HADOOP_MINOR_VERSION 3
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Variaveis de ambiente do Hive
ENV HIVE_VERSION 4.0.0
ENV HIVE_HOME=/usr/hive
ENV HIVE_PORT 10000

# Variaveis de ambiente do Scala
ENV SCALA_VERSION 2.11.2
ENV SCALA_HOME=/usr/scala
ENV PATH=$PATH:$SCALA_HOME/bin

# Variaveis de ambiente do Zookeeper
ENV ZOOKEEPER_VERSION 3.9.2
ENV ZOOKEEPER_HOME /usr/apache-zookeeper-$ZOOKEEPER_VERSION-bin

# Variaveis de ambiente do Kafka
ENV SCALA_KAFKA_VERSION 2.13-3.7.0
ENV KAFKA_VERSION 3.7.0
ENV KAFKA_HOME=/usr/kafka

# Classpath para localizar os jars com as classes necessarias
ENV CLASSPATH=$HIVE_HOME/lib:$SCALA_HOME/lib:$KAFKA_HOME/libs

# Variaveis de ambiente do Spark
ENV SPARK_VERSION 3.5.1
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"

# Configuracoes do pyspark
ENV PYSPARK_PYTHON python3

# Usar python3 para modo cluster
ENV PYSPARK_DRIVER_PYTHON=python3

# e jupyter + configuracao de PYSPARK_DRIVER_PYTHON_OPTS='notebook' para modo interativo
# ENV PYSPARK_DRIVER_PYTHON=jupyter
# ENV PYSPARK_DRIVER_PYTHON_OPTS='notebook'

# Adicao de valores aos paths abaixo para que os componentes os localizem
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:/usr/bin/python3
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH:$HIVE_HOME/bin:$KAFKA_HOME/bin:$SCALA_HOME/bin

COPY /config/jupyter/requirements.txt /

# Ajustes e instalação dos componentes do cluster
RUN apt-get update \
    && apt-get install -y wget vim ssh openssh-server curl iputils-ping \
    python3 python3-pip python3-dev \
    build-essential libssl-dev libffi-dev libpq-dev mariadb-server libmariadb-java \
    && python3 -m pip install -r requirements.txt \
    && python3 -m pip install dask[bag] --upgrade \
    && python3 -m pip install --upgrade toree \
    && python3 -m bash_kernel.install \
    && python3 -c "import nltk; nltk.download('stopwords')"\
    && mkdir datasets \
    # --------------------------------------------------------------------------
    # INSTALACAO DO HADOOP
    && wget http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -O /tmp/hadoop.tar.gz \
    && wget http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc -O /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc \
    && tar -xvf /tmp/hadoop.tar.gz -C /usr/ \
    && rm /tmp/hadoop.tar.gz* \
    && ln -s ${HADOOP_CONF_DIR} ${HADOOP_CONF_DIR} \
    && rm -rf ${HADOOP_HOME}/share/doc \
    && chown -R root:root ${HADOOP_HOME} \
    # --------------------------------------------------------------------------
    # INSTALACAO DO SPARK
    && wget http://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MINOR_VERSION}.tgz -O /tmp/spark.tar.gz \
    && wget http://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MINOR_VERSION}.tgz.asc -O /tmp/spark.tar.gz.asc \
    && gpg --verify /tmp/spark.tar.gz.asc \
    && tar -xvf /tmp/spark.tar.gz -C /tmp/ \
    && mkdir ${SPARK_HOME} \
    && cp -r /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MINOR_VERSION}/* -C /tmp/${SPARK_HOME} \
    && rm -rf /tmp/spark* \
    && chmod -R 777 ${SPARK_HOME} \
    && chown -R root:root ${SPARK_HOME}