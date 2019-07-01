# Extend the official Rasa SDK image
FROM rasa/rasa-sdk:1.1.0

WORKDIR /app

RUN apt-get update && \
    apt-get install -y git
   
COPY ./requirements.txt .
RUN pip install -r requirements.txt
RUN python -m spacy download en

# Don't use terminal buffering, print all to stdout / err right away
ENV PYTHONUNBUFFERED 1

COPY . .

