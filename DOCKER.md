# Docker Deployment Guide

## Quick Start

### Production Deployment
```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Development Mode
```bash
# Start with development overrides (hot reload)
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

# Rebuild specific service
docker-compose build backend
```

### Run Lake Publisher (Batch Job)
```bash
# Run the batch job once
docker-compose --profile batch run --rm lakepublisher

# Or run as scheduled job
docker-compose --profile batch up lakepublisher
```

## Service Access

- **Frontend**: http://localhost:3030
- **Backend API**: http://localhost:3000
- **RabbitMQ Management**: http://localhost:15672 (admin/admin123)
- **MongoDB**: localhost:27017

## Data Persistence

All data is persisted in Docker volumes:
- `mongodb_data` - Database storage
- `rabbitmq_data` - Message queue data
- `backend_uploads` - File attachments
- `processor_messages` - Processed messages
- `lakepublisher_data` - Exported Parquet files

## Troubleshooting

### View service logs
```bash
docker-compose logs backend
docker-compose logs frontend
docker-compose logs processor
```

### Restart specific service
```bash
docker-compose restart backend
```

### Clean rebuild
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Access service shell
```bash
docker-compose exec backend sh
docker-compose exec processor sh
```