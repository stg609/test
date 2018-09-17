FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

#先编译
FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
#COPY 的第一个参数的目录即当前 dockerfile 所在的目录
#COPY 的第二个参数的目录为 images 中的目录，/ 代表根目录。默认为当前的 work dir
#下面这个 copy 的意思是把当前 docker file 所在目录中的 test.csproj 文件拷贝到 images 中的 src 目录中
COPY test.csproj .
#RUN /src/ 中的 test.csproj
RUN dotnet restore test.csproj
#把当前 dockerfile 所在目录中的所有东西拷贝到 images 中的 src 目录中
COPY . .
#build /src/test.csproj 并把输出放到 out 中，out 为与 src 同级别的兄弟目录
RUN dotnet build test.csproj -c Release -o /out

#再发布，生成发布的 dll
FROM build AS publish
# /appPublish 斜杠表示根目录，如果没有斜杠，则就是相对目录，相对于当前的目录，也就是 wokrdir/appPublish = /src/appPublish
RUN dotnet publish test.csproj -c Release -o appPublish 

#最后把这些 dll 拷贝到一个干净的环境进行打包
FROM base AS final
WORKDIR /app
COPY --from=publish /src/appPublish .
ENTRYPOINT ["dotnet", "test.dll"]
