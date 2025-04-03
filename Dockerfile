FROM python:3.13-alpine

WORKDIR /app

COPY disk-cleanup.py .

ENTRYPOINT ["python", "disk-cleanup.py"]
