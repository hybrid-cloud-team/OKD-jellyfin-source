# 1. 빌드 스테이지
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# 소스 전체 복사 (루트의 .dockerignore가 불필요한 파일은 걸러줍니다)
COPY . .

# 종속성 복원 및 빌드 (Jellyfin.Server 프로젝트 기준)
RUN dotnet publish Jellyfin.Server/Jellyfin.Server.csproj -c Release -o /app/publish

# 2. 실행 스테이지
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# 실행에 필요한 시스템 라이브러리 설치 (젤리핀 미디어 변환용)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libfontconfig1 \
    libfreetype6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

# 젤리핀 기본 포트
EXPOSE 8096

# 실행 명령
ENTRYPOINT ["dotnet", "Jellyfin.Server.dll"]
