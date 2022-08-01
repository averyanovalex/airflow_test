import airflow
from airflow import models, settings
from airflow.contrib.auth.backends.password_auth import PasswordUser
from sqlalchemy import create_engine
from os import getenv

AIRFLOW_ADMIN_USER = getenv('AIRFLOW_ADMIN_USER')
AIRFLOW_ADMIN_PASSWORD = getenv('AIRFLOW_ADMIN_PASSWORD')
AIRFLOW_ADMIN_EMAIL = getenv('AIRFLOW_ADMIN_HOST')
POSTGRES = getenv('AIRFLOW__CORE__SQL_ALCHEMY_CONN')

user = PasswordUser(models.User())
user.username = AIRFLOW_ADMIN_USER
user.email = AIRFLOW_ADMIN_EMAIL
user.password = AIRFLOW_ADMIN_PASSWORD
user.superuser = True

engine = create_engine(POSTGRES)
session = settings.Session(bind=engine)
session.add(user)
session.commit()
session.close()
exit()