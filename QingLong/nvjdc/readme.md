### 群晖安装 nolan jdc 的方法：

1、安装 Git Server 套件并部署，自行百度，不详述；
2、共享文件夹 docker 下新建路径 nolanjdc。查看其详情，获取绝对路径，比如

```
/volume1/docker/nolanjdc；
```

3、定位到nuolanjdc文件夹；

```
cd /volume1/docker/nolanjdc
```

4、拉取源码；

4.1、拉源码 国内

```
git clone https://ghproxy.com/https://github.com/NolanHzy/nvjdcdocker.git /root/nolanjdc
```

4.2、拉远码国外

```
git clone https://github.com/NolanHzy/nvjdcdocker.git /root/nolanjdc
```

5、创建配置文件夹并定位到该文件夹；

```
mkdir -p  Config && cd Config
```

6、下载原始配置模板；

6.1、国内(地址已失效，点击直达 (https://t.me/update_help/246)文件)

```
wget -O Config.json   https://ghproxy.com/https://raw.githubusercontent.com/NolanHzy/nvjdc/main/Config.json
```

6.2、国外(地址已失效，点击直达 (https://t.me/update_help/246)文件)

```
wget -O Config.json  https://raw.githubusercontent.com/NolanHzy/nvjdc/main/Config.json
```

7、修改配置文件；
主要修改四处

      //青龙地址
      "QLurl": "http://192.168.2.4:5700",  //青龙的 IP 地址或公网域名:端口号，最后千万不要带/。
      //青龙2,9 OpenApi Client ID
      "QL_CLIENTID": "填你的 OpenApi Client ID",  //青龙的系统设置-应用设置中创建一个应用，赋予权限后生成
      //青龙2,9 OpenApi Client Secret
      "QL_SECRET": "填你的 OpenApi Client Secret", //同上
      //CK最大数量
      "QL_CAPACITY": 200, //默认 100 ，自己账号多的话可以修改。

8、定位到nuolanjdc文件夹，创建 chromium 驱动文件夹、；

```
cd /volume1/docker/nolanjdc && mkdir -p  .local-chromium/Linux-884014 && cd .local-chromium/Linux-884014
```

9、下载 chromium 驱动包，解压后将 chrome-linux 文件夹整体上传至 /volume1/docker/nolanjdc/.local-chromium/Linux-884014
chromium 驱动包下载地址：
https://mirrors.huaweicloud.com/chromium-browser-snapshots/Linux_x64/884014/chrome-linux.zip

10、拉取 Docker 注册表并创建、启动容器；

```
docker run -d \
-p 5701:80 \
--name nolanjdc \
--privileged=true \
-v /volume1/docker/nolanjdc:/app:ro \
nolanhzy/nvjdc:latest
```

11、之后就可以通过“群晖的地址:5701”访问 nuolanjdc 了。据说第一次会卡一下，忍一下后面就好了。
