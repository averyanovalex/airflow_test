from airflow import DAG
from datetime import timedelta
from airflow.utils.dates import days_ago
from airflow.operators.bash_operator import BashOperator
 
# Создадим объект класса DAG
dag =  DAG('test_dag_bash',schedule_interval=timedelta(days=1), start_date=days_ago(1))

# Создадим несколько шагов, которые будут параллельно исполнять bash команды
t1 = BashOperator(task_id='echo_1', bash_command='echo 1',dag=dag)
t2 = BashOperator(task_id='echo_2', bash_command='echo 2',dag=dag)