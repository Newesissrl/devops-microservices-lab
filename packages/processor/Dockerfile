# Test stage
FROM python:3.13-alpine AS test
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN python -m pytest test_processor.py -v

# Production stage
FROM python:3.13-alpine AS production
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    pip cache purge
COPY --chown=nobody:nobody . .
RUN mkdir -p messages && chown -R nobody:nobody messages
USER nobody
CMD ["python", "processor.py"]