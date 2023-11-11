FROM --platform=linux/amd64 ubuntu:latest
RUN apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y python3 \
  build-essential \
  git \
  wget \
  python3-pip \

# COPY . .

# RUN pip install -r backend/requirements.txt
# ENV FLASK_APP=/backend/api.py
# EXPOSE 8080
# WORKDIR /backend
# CMD ["gunicorn" , "-b", "0.0.0.0:8080",   "api:app"]