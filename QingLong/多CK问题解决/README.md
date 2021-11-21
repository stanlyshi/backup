## 目录
- [目录](#目录)
- [太长不读](#太长不读)
- [最初](#最初)
- [当ck到一定数目后](#当ck到一定数目后)
- [排查定位](#排查定位)
- [现有解决方案](#现有解决方案)
- [新的解决思路](#新的解决思路)
- [最终方案](#最终方案)
- [核心改动代码](#核心改动代码)
  - [shell中设置参数](#shell中设置参数)
  - [nodejs中实际处理](#nodejs中实际处理)
- [效果](#效果)

## 太长不读
### 青龙v2.10.8及以后
复制 code.sh、task_before.sh 到/ql/config目录，用法与 https://t.me/update_help/45 中所述完全一致

复制 jdCookie.js 到 /ql/deps 目录，确保更新脚本库后，魔改版本会被覆盖过去
> 注意把映射目录增加 ./data/deps:/ql/deps

### 青龙v2.10.8以前
复制 code.sh、task_before.sh 、jdCookie.js 到/ql/config目录，用法与 https://t.me/update_help/45 中所述完全一致

如果你的青龙在此版本之前，则尚还没有覆盖自定义的依赖到脚本库的功能，需要自行实现，具体方式如下

将下面这段shell代码复制到 task_before.sh的末尾，从而实现覆盖魔改版。

默认的方案是以 shufflewzc/faker2 和 cdle/carry 为基准的，如果你是其他仓库，需要在task_before.sh末尾增加上同步jdCookie.js到你对应的仓库脚本目录
```shell
# 在实际执行任务前，确保集合仓库的脚本目录中的jdCookie.js是修改版的内容
echo 开始复制魔改版jdCookie.js ...
cp /ql/config/jdCookie.js /ql/scripts/shufflewzc_faker2/jdCookie.js
cp /ql/config/jdCookie.js /ql/scripts/cdle_carry/jdCookie.js

# 在这里加上你实际的仓库，比如说是xxx/yyy这个仓库，则是
# cp /ql/config/jdCookie.js /ql/scripts/xxx_yyy/jdCookie.js

echo 复制完毕
```


## 最初
之前使用的互助码脚本 task_before.sh 和 code.sh 是从 互助研究院电报群 获取的 
> https://t.me/update_help/41
> https://t.me/update_help/45

在cookie数目较少的情况下，一直运行良好，这里先感谢大佬的无私奉献。

## 当ck到一定数目后
但是，在我拉了更多人一起挂青龙，ck到达89个时，很多脚本开始报 Argument list too long 错误，而且是一些系统命令，比如 timeout、date、cat等报的错，看的我一脸懵逼。
![image](https://user-images.githubusercontent.com/13483212/142473975-5ea3ba0b-08f3-4f91-8e08-e3453edeb641.png)

## 排查定位
于是昨晚在青龙容器里对shell下断点，各种调试，也是一直毫无头绪，后来，在搜到下面这个帖子时，终于明白了这个报错的起因。
> https://stackoverflow.com/a/28865503

task_before.sh在shell环境中设置了一个很大的环境变量，其大小大概为 总ck数目 * 未被屏蔽的ck数目 * 单个互助码的大小，部分活动的互助码大小约为40。
此时如果有80个ck，且全部启用，则大小将是 80 * 80 * 40 = 256000，而系统默认的参数列表大小（包含环境变量）为 $(getconf ARG_MAX) = 131072，
可见远远超出该值。因此后续调用任何系统命令，都将会报出 Argument list too long 而导致后续流程无法正常进行。

## 现有解决方案
昨晚搜了下现有的做法，基本都是分多个青龙容器，每个保持在45个（这样大小约为81000），确保不会报错。这个方法很简洁，但是会带来维护上的麻烦，本来只要部署一套qinglong容器，现在需要维护多套，比较费心力。

## 新的解决思路
昨天最初准备按这套走了，流程都构思完了。后来突然想到一个新思路，现在的问题是shell中设置的env太大了，导致其他流程不能正常执行。那么如果我把设置env的流程挪到nodejs中，不再经由shell的环境，那么shell中执行的其他命令就不会报错了。
有了思路后，问题就简单了。这下只需要把原先task_before.js中执行的解析互助码文件和转换后放入shell环境变量的流程换到nodejs中即可，这样这几十MB的环境变量就不再是作为参数传入了。

## 最终方案
一番处理后，最终就有了下面的流程
task_before.sh 不再直接设置环境变量，而是设置要处理的活动名称和对应互助码文件名称

接下来需要在nodejs中某个地方去接收这两个参数来实际生成。如果仓库完全自己管控，那么直接新增一个模块，在模块内处理后塞入process.env，然后各个脚本中引入即可，与之前表现完全一致。
但是显然这样沟通成本有点高，这里可以取巧，观察可以发现，几乎每个脚本中都有下面这句
```javascript
const jdCookieNode = $.isNode() ? require('./jdCookie.js') : '';
```

所以，我们可以魔改 jdCookie.js 这个文件，自己从基准仓库中复制一份，然后将我们的处理互助码的逻辑加到后面即可，这样就可以实现每个脚本自动调用我们的新流程了。

所以最终就有了下面三个文件
code.sh             原版，负责在 /ql/log/.ShareCode 生成互助码的文件
task_before.sh      魔改版，负责确认当前活动是否需要互助码，若需要，则设置 活动名称ShareCodeConfigName 和 环境变量名称ShareCodeEnvName 这两个环境变量
jdCookie.js         魔改版，判断前面两个环境变量是否存在，若存在，则解析对应活动的互助码文件，按照task_before.sh原有的逻辑转换后放入对应环境变量key中

前两个按原有教程操作即可，魔改版的jdCookie.js需要执行任务前确保覆盖到对应目录。

### 青龙v2.10.8及以后
复制 jdCookie.js 到 /ql/deps 目录，确保更新脚本库后，魔改版本会被覆盖过去

### 青龙v2.10.8以前
如果你的青龙在此版本之前，则尚还没有覆盖自定义的依赖到脚本库的功能，需要自行实现，具体方式如下
由于目前青龙会在定时任务完成前执行 task_before.sh ，所以我们可以在 task_before.sh 末尾加入以下内容，来实现这一目的
默认的方案是以 shufflewzc/faker2 和 cdle/carry 为基准的，如果你是其他仓库，需要在task_before.sh末尾增加上同步jdCookie.js到你对应的仓库脚本目录
```shell
# 在实际执行任务前，确保集合仓库的脚本目录中的jdCookie.js是修改版的内容
echo 开始复制魔改版jdCookie.js ...
cp /ql/config/jdCookie.js /ql/scripts/shufflewzc_faker2/jdCookie.js
cp /ql/config/jdCookie.js /ql/scripts/cdle_carry/jdCookie.js

# 在这里加上你实际的仓库，比如说是xxx/yyy这个仓库，则是
# cp /ql/config/jdCookie.js /ql/scripts/xxx_yyy/jdCookie.js

echo 复制完毕
```

## 核心改动代码
### shell中设置参数
```shell
## 正常依次运行时，组合互助码格式化为全局变量
combine_only() {
    for ((i = 0; i < ${#env_name[*]}; i++)); do
        case $1 in
            *${name_js[i]}*.js | *${name_js[i]}*.ts)
	            if [[ -f $dir_log/.ShareCode/${name_config[i]}.log ]]; then
                    . $dir_log/.ShareCode/${name_config[i]}.log
                    result=$(combine_sub ${var_name[i]})
                    if [[ $result ]]; then
                        # 魔改说明：直接设置在ck超过45时，会导致env过大，部分系统命令无法执行，导致脚本执行失败
                        #   这里改成设置一个标记，在nodejs中去实际设置环境变量
                        # export ${env_name[i]}=$result
                        export ShareCodeConfigName=${name_config[i]}
                        export ShareCodeEnvName=${env_name[i]}
                        echo "设置环境变量标记 ShareCodeConfigName=${ShareCodeConfigName} ShareCodeEnvName=${ShareCodeEnvName}, 供nodejs去实际生成互助码环境变量"
                    fi
                fi
                ;;
           *)
                export ${env_name[i]}=""
                ;;
        esac
    done
}

# ...........................

# 青龙v2.10.8以前 启用这段代码
# # 在实际执行任务前，确保集合仓库的脚本目录中的jdCookie.js是修改版的内容
# echo 开始复制魔改版jdCookie.js ...
# cp /ql/config/jdCookie.js /ql/scripts/shufflewzc_faker2/jdCookie.js
# cp /ql/config/jdCookie.js /ql/scripts/cdle_carry/jdCookie.js
# echo 复制完毕
```

### nodejs中实际处理
```javascript
// 若在task_before.sh 中设置了要设置互助码环境变量的活动名称和环境变量名称信息，则在nodejs中处理，供活动使用
let nameConfig = process.env.ShareCodeConfigName
let envName = process.env.ShareCodeEnvName
if (nameConfig && envName) {
    SetShareCodesEnv(nameConfig, envName)
} else {
    console.debug(`【风之凌殇】 友情提示：当前未设置 ShareCodeConfigName 或 ShareCodeEnvName 环境变量，将不会尝试在nodejs中生成互助码的环境变量。ps: 两个值目前分别为 ${nameConfig} ${envName}`)
}
```

## 效果
自此，即使你的ck很多，也不再用看到下面这一幕了。
![image](https://user-images.githubusercontent.com/13483212/142474215-af41b6c1-acdf-410f-985a-90ebe749103e.png)

而是会看到
![image](https://user-images.githubusercontent.com/13483212/142474100-1c97d031-c49a-44e1-acf6-ac87d8aafdeb.png)
