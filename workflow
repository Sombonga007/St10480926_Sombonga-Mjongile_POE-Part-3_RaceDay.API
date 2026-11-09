name: RaceDay CI

on:
  push:
    branches: [ main, part3-mvc ]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: 8.0.x
      - name: Build API (Part 2)
        run: |
          dotnet restore RaceDay.Api/RaceDay.Api.csproj
          dotnet build RaceDay.Api/RaceDay.Api.csproj --no-restore -c Release
      - name: Build MVC web app (Part 3)
        run: |
          dotnet restore RaceDay.Web/RaceDay.Web.csproj
          dotnet build RaceDay.Web/RaceDay.Web.csproj --no-restore -c Release
      - name: Build Docker image
        run: docker build -t raceday-web .
