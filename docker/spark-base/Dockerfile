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
ENV PATH $PATH:$HIVE_HOME/bin:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH:$HIVE_HOME/bin:$KAFKA_HOME/bin:$SCALA_HOME/bin

COPY /config/jupyter/requirements.txt /

# Ajustes e instalação dos componentes do cluster
RUN apt-get update \
    && apt-get install -y wget vim ssh openssh-server curl iputils-ping \
    python3 python3-pip python3-dev \
    build-essential libssl-dev libffi-dev libpq-dev mariadb-server libmariadb-java mariadb-client \
    && python3 -m pip install -r requirements.txt \
    && python3 -m pip install dask[bag] --upgrade \
    && python3 -m pip install --upgrade toree \
    && python3 -m bash_kernel.install \
    && python3 -c "import nltk; nltk.download('stopwords')"\
    && mkdir datasets \
    # --------------------------------------------------------------------------
    # INSTALACAO DO HADOOP
    && wget http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -O /tmp/hadoop.tar.gz \
    # && wget http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc -O /tmp/hadoop.tar.gz.asc \
    # && gpg --verify /tmp/hadoop.tar.gz.asc \
    && tar -xvf /tmp/hadoop.tar.gz -C /usr/ \
    && rm -rf /tmp/* \
    && ln -s ${HADOOP_CONF_DIR} ${HADOOP_CONF_DIR} \
    && rm -rf ${HADOOP_HOME}/share/doc \
    && chown -R root:root ${HADOOP_HOME} \
    # --------------------------------------------------------------------------
    # INSTALACAO DO SPARK
    && wget http://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MINOR_VERSION}.tgz -O /tmp/spark.tar.gz \
    && tar -xvf /tmp/spark.tar.gz -C /tmp/ \
    && mkdir ${SPARK_HOME} \
    && cp -r /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MINOR_VERSION}/* ${SPARK_HOME} \
    && rm -rf /tmp/* \
    && chmod -R 777 ${SPARK_HOME} \
    && chown -R root:root ${SPARK_HOME} \
    # --------------------------------------------------------------------------
    # INSTALACAO DO HIVE
    && wget https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz -O /tmp/hive.tar.gz \
    && tar -xvf /tmp/hive.tar.gz -C /tmp/ \
    && mkdir ${HIVE_HOME} \
    && cp -r /tmp/apache-hive-${HIVE_VERSION}-bin/* ${HIVE_HOME} \
    && cp ${HIVE_HOME}/conf/hive-env.sh.template ${HIVE_HOME}/conf/hive-env.sh \
    && echo "export HADOOP_HOME=${HADOOP_HOME}/" >> ${HIVE_HOME}/conf/hive-env.sh \
    # configurando o metastore do hive com MariaDB
    && wget https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.3/mariadb-java-client-3.3.3.jar -O /usr/share/mariadb-java-client.jar \
    && ln -s /usr/share/mariadb-java-client.jar ${HADOOP_HOME}/share/hadoop/common/lib/ \
    && ln -s /usr/share/mariadb-java-client.jar ${HIVE_HOME}/lib/mariadb-java-client.jar \
    # Criando diretório para jars externos do Hive e baixando suporte a parquet
    && wget https://repo1.maven.org/maven2/com/twitter/parquet-avro/1.6.0/parquet-avro-1.6.0.jar -P /usr/hive/aux_jars/ \
    # --------------------------------------------------------------------------
    # INSTALACAO DO ZOOKEEPER
    && wget https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -O /tmp/apache-zookeeper.tar.gz \
    && tar -xvf /tmp/apache-zookeeper.tar.gz -C /tmp/ \
    && mv /tmp/apache-zookeeper-${ZOOKEEPER_VERSION}-bin /usr/apache-zookeeper-${ZOOKEEPER_VERSION}-bin \
    && mkdir /var/lib/zookeeper \
    # --------------------------------------------------------------------------
    # INSTALACAO DO SCALA
    && wget https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz -O /tmp/scala.tgz \
    && tar -zvxf /tmp/scala.tgz -C /tmp/ \
    && mkdir ${SCALA_HOME} \
    && mv /tmp/scala-${SCALA_VERSION} ${SCALA_HOME} \
    # --------------------------------------------------------------------------
    # INSTALACAO DO KAFKA
    && wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_KAFKA_VERSION}.tgz -O /tmp/kafka.tgz \
    && tar -zvxf /tmp/kafka.tgz -C /tmp/ \
    && mkdir ${KAFKA_HOME} \
    && mv /tmp/kafka_${SCALA_KAFKA_VERSION} ${KAFKA_HOME} \
    # Configurando o JAVA_HOME para os processos localizarem a instalação do Java
    && echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/environment


# --------------------------------------------------------------------------
# Keys dos nodes. Necessarias para se comunicarem por SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys

COPY /config/config /root/.ssh
RUN chmod 600 /root/.ssh/config

COPY config/spark ${SPARK_HOME}/conf/
COPY config/hadoop/*.xml /usr/hadoop-${HADOOP_VERSION}/etc/hadoop/
COPY config/scripts /
COPY config/zookeeper ${ZOOKEEPER_HOME}/conf/
COPY config/kafka ${KAFKA_HOME}/config

EXPOSE 9000 4040 8020 22 9083 10000 10001 10002 2181 2888 3888 9092 9999

ENTRYPOINT ["/bin/bash", "bootstrap.sh"]