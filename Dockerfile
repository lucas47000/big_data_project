# Utilisez une image Python comme base pour votre environnement Docker
FROM python:3.10

#  variable d'environnement HADOOP_HOME
ENV HADOOP_HOME /usr/local/hadoop

# Installez les dépendances nécessaires
#RUN choco install nano wget openjdk8

# Téléchargez la dernière version de Spark
RUN powershell -Command "Invoke-WebRequest -Uri 'http://mirrors.sonic.net/apache/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz' -OutFile 'spark-3.0.0-bin-hadoop3.2.tgz'"

# Décompressez Spark
RUN tar xvf spark-3.0.0-bin-hadoop3.2.tgz

# Définissez les variables d'environnement pour Spark
ENV SPARK_HOME /spark-3.0.0-bin-hadoop3.2
ENV PATH $SPARK_HOME/bin:$PATH

# Installez HDFS
RUN choco install hadoop

# Configurez HDFS
RUN /usr/local/hadoop/bin/hdfs namenode -format

# Installez Dash
RUN pip install dash

# Démarrez les services Spark et HDFS
CMD net start ssh && $SPARK_HOME/sbin/start-master.sh && $HADOOP_HOME/sbin/start-dfs.sh

# Exposez les ports nécessaires pour Dash et Spark
EXPOSE 8050
EXPOSE 7077
EXPOSE 50070