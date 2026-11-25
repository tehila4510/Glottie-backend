FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Restore first (cached layer unless a .csproj changes)
COPY MyProject.slnx ./
COPY Common/Common.csproj Common/
COPY Repository/Repository.csproj Repository/
COPY DataContext/DataContext.csproj DataContext/
COPY Services/Services.csproj Services/
COPY MyProject/MyProject.csproj MyProject/
RUN dotnet restore MyProject/MyProject.csproj

COPY . .
RUN dotnet publish MyProject/MyProject.csproj -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app .

# Program.cs serves files from these folders; the app crashes at startup if ProfileImages is missing
RUN mkdir -p ProfileImages QuestionImages

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "MyProject.dll"]
