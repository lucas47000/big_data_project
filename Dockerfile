FROM microsoft/windowsservercore

#  variable d'environnement HADOOP_HOME goatesque
ENV HADOOP_HOME /usr/local/hadoop

# Installez les dépendances nécessaires
RUN choco install nano wget openjdk8

# Téléchargez la dernière version de Spark
RUN powershell -Command "Invoke-WebRequest -Uri 'http://mirrors.sonic.net/apache/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz' -OutFile 'spark-3.0.0-bin-hadoop3.2.tgz'"

# Décompressez Spark
RUN powershell -Command "Expand-Archive spark-3.0.0-bin-hadoop3.2.tgz -DestinationPath C:\"

# Définissez les variables d'environnement pour Spark
ENV SPARK_HOME C:\spark-3.0.0-bin-hadoop3.2
ENV PATH %SPARK_HOME%\bin;%PATH%

# Installez HDFS
RUN choco install hadoop

# Configurez HDFS
RUN powershell -Command "& 'C:\Hadoop\bin\hdfs.cmd' namenode -format"

# Installez Dash
RUN choco install python
RUN powershell -Command "& python -m pip install dash"

# Démarrez les services Spark et HDFS
CMD powershell -Command "& '%SPARK_HOME%\sbin\start-master.cmd'"

# Exposez les ports nécessaires pour Dash et Spark
EXPOSE 8050
EXPOSE 7077
EXPOSE 50070