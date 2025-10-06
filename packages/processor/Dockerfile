FROM python:3.13-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=nobody:nobody . .

RUN mkdir -p messages && chown -R nobody:nobody messages

USER nobody

CMD ["python", "processor.py"]