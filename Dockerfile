# Stage 1: Build Stage
ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION} as builder

WORKDIR /app
COPY . .

# Stage 2: Run Stage
FROM python:${PYTHON_VERSION} as run

WORKDIR /app

ENV PYTHONUNBUFFERED=1

COPY --from=builder /app .

# Update and install dependencies with cleanup to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --upgrade pip \
    && pip install mysqlclient \
    && pip install -r requirements.txt

EXPOSE 8080

COPY wait-for-it.sh /app/wait-for-it.sh
RUN chmod +x /app/wait-for-it.sh

ENTRYPOINT ["sh", "-c", "./wait-for-it.sh mysql:3306 -- python manage.py migrate && python manage.py runserver 0.0.0.0:8080"]