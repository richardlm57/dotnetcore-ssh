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


# Felipe, esta é a seccão que adicioné ao Dockerfile
# Aqui incluimos SSH e Supervisor, que permitirá rodar dois processos no mesmo entrypoint
RUN apt-get update && apt-get install -y supervisor && apt-get install -y openssh-server && echo "root:Docker!" | chpasswd 
RUN mkdir -p /var/log/supervisor /run/sshd

# Aqui estamos copiando los arquivos de configuração necessários par cada processo
COPY sshd_config /etc/ssh/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY inotify.sh /app/

WORKDIR /app
COPY --from=build /app ./


EXPOSE 80 2222

# E aqui estamos definiendo nosso novo entrypoint
ENTRYPOINT ["/usr/bin/supervisord"]