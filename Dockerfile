# selection de l'image 
# - alpine est une version allégée de linux 
FROM python:3.9-alpine3.13

# indication du developpeur a contacter en cas de problème
LABEL maintainer="emendy.com"

# PYTHONUNBUFFERED :
# - redirection des outputs dans la console (screen)
ENV PYTHONUNBUFFERED 1

# copie des fichiers de la machine locale dans l'image docker
COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app

# Definition du work directory dans l'image docker
WORKDIR /app

# permettre l'accès au port sur laquelle tourne l'application
EXPOSE 8000

# Initialisation du projet 
# - création de l'environnement virtuel 
#  (optionel dans 90% des cas mais prévient les risques de conflits)
RUN python -m venv /py && \
  # mise a jour de pip
  /py/bin/pip install --upgrade pip && \
  # installation des dépendances déclarés dans /tmp/requirements.txt
  /py/bin/pip install -r /tmp/requirements.txt && \
  # suppression des fichiers temporaires
  # (allegement de l'image au maximum)
  rm -rf /tmp && \
  # /!\ ne jamais utiliser le root user /!\
  # création d'un utilisateur 
  adduser \
    --disabled-password \
    --no-create-home \
    django-user

# Mise a jour de la variable PATH
ENV PATH="/py/bin:PATH"

# /!\ ne jamais utiliser le root user /!\
# definition du user sur le container
USER django-user 