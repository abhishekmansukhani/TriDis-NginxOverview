FROM microsoft/aspnetcore:1.1
ARG source
WORKDIR /opt/HelloWorld
EXPOSE 80
COPY ${source:-bin/Release/PublishOutput} .
ENTRYPOINT ["dotnet", "HelloWorld.dll"]
