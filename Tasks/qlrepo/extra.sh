#!/usr/bin/env bash

## 添加你需要重启自动执行的任意命令，比如 ql repo
# cp /ql/sample/package.json /ql/scripts
bash -c "apk add --no-cache build-base g++ cairo-dev pango-dev giflib-dev && cd scripts && npm install canvas --build-from-source && npm install ts-node -g --save  --unsafe-perm=true --allow-root && npm install typescript && npm install fs && npm install axios && npm i ts-md5 && npm i -S png-js && npm i -S cheerio"

#jxcfd_ts(){
#cd /ql/scripts/
#ql repo https://github.com/JDHelloWorld/jd_scripts.git "
#jd_|jx_|getJDCookie" "activity|backUp|Coupon|enen" "^jd[^_]|USER"
#cp /ql/repo/JDHelloWorld_jd_scripts/package.json .
#npm i
#npm i -g ts-node typescript @types/node date-fns axios
#tsc JDHelloWorld_jd_scripts_jd_cfd.ts
#task JDHelloWorld_jd_scripts_jd_cfd.js now
#}

#jxcfd_ts &