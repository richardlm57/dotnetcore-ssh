# https://hub.docker.com/_/microsoft-dotnet-core
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnetapp/*.csproj ./aspnetapp/
RUN dotnet restore

# copy everything else and build app
COPY aspnetapp/. ./aspnetapp/
WORKDIR /source/aspnetapp
RUN dotnet publish -c release -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1

RUN apt-get update && apt-get install -y supervisor && apt-get install -y openssh-server && echo "root:Docker!" | chpasswd 

RUN mkdir -p /var/log/supervisor /run/sshd

COPY sshd_config /etc/ssh/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /app
COPY --from=build /app ./

EXPOSE 80 2222

ENTRYPOINT ["/usr/bin/supervisord"]