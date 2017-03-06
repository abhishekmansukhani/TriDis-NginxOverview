pushd .
cd HelloWorld
dotnet restore
dotnet publish -c Release -o bin/Release/PublishOutput
popd