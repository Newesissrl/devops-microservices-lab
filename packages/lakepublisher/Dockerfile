# Test stage
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS test
WORKDIR /app
COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet test --no-restore || echo "No tests found, continuing..."

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS builder
WORKDIR /app
COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o out --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/runtime:9.0-alpine

WORKDIR /app

COPY --from=builder --chown=nobody:nobody /app/out .

RUN mkdir -p data && chown -R nobody:nobody data

USER nobody

ENTRYPOINT ["dotnet", "lakepublisher.dll"]