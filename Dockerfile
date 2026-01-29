FROM python:3.12-slim
WORKDIR /app
RUN apt-get update && apt-get install -y sshpass openssh-client && rm -rf /var/lib/apt/lists/*
RUN pip install python-telegram-bot --upgrade
COPY bot.py /app/
CMD ["python", "bot.py"]
