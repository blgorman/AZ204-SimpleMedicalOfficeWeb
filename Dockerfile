FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["SimpleMedicalOfficeWeb/SimpleMedicalOfficeWeb.csproj", "SimpleMedicalOfficeWeb/"]
RUN dotnet restore "./SimpleMedicalOfficeWeb/SimpleMedicalOfficeWeb.csproj"
COPY . .
WORKDIR "/src/SimpleMedicalOfficeWeb"
RUN dotnet build "./SimpleMedicalOfficeWeb.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./SimpleMedicalOfficeWeb.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SimpleMedicalOfficeWeb.dll"]