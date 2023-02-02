import subprocess
import requests
from pyspark.sql import SparkSession

url = "https://raw.githubusercontent.com/datasets/covid-19/master/data/countries-aggregated.csv"
file_name = "covid_19_data.csv"
response = requests.get(url)
with open(file_name, "wb") as f:
    f.write(response.content)

print("Le fichier a été téléchargé avec succès sous le nom : " + file_name)

# Initialise SparkSession avec la configuration pour HDFS
spark = SparkSession.builder.appName("Covid19DataAnalysis").config("spark.hadoop.fs.defaultFS", "hdfs://localhost:9000").getOrCreate()

# Copie le fichier CSV téléchargé dans HDFS
subprocess.run(["hdfs", "dfs", "-put", "covid_19_data.csv", "/"])

# 3. Lis le fichier CSV à partir de HDFS
df = spark.read.csv("hdfs://localhost:9000/covid_19_data.csv", header=True, inferSchema=True)

# Extrait et affiche le nombre de cas total par pays
total_cases = df.groupBy("Country").agg({"Confirmed": "sum"})
print("nombre de cas total par pays : ")
total_cases.show()

# Affiche le nombre total de morts pour chaque pays
total_deaths = df.groupBy("Country").agg({"Deaths": "sum"})
print("Total Deaths by Country:")
total_deaths.show()

# Affiche le nombre total de cas confirmés et de morts pour chaque pays
total_cases_and_deaths = df.groupBy("Country").agg({"Confirmed": "sum", "Deaths": "sum"})
print("Total Confirmed Cases and Deaths by Country:")
total_cases_and_deaths.show()

# Affiche le taux de mortalité moyen pour chaque pays (en pourcentage)
average_mortality_rate = df.groupBy("Country").agg({"Deaths": "avg", "Confirmed": "avg"})
average_mortality_rate = average_mortality_rate.withColumn("Mortality Rate", average_mortality_rate["avg(Deaths)"] / average_mortality_rate["avg(Confirmed)"] * 100)
average_mortality_rate = average_mortality_rate.drop("avg(Deaths)", "avg(Confirmed)")
print("Average Mortality Rate by Country:")
average_mortality_rate.show()
