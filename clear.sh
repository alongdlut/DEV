#!/bin/bash

# 设置日志文件大小阈值 (默认100MB)
LOGSIZE=${1:-100M}

# 查找Docker日志文件大于指定大小的容器日志文件
find /var/lib/docker/containers/ -type f -name "*.log" -size +$LOGSIZE -exec ls -lh {} \; | awk '{ print $9 ": " $5 }' > /tmp/large_docker_logs.txt

# 检查是否找到大文件
if [ ! -s /tmp/large_docker_logs.txt ]; then
    echo "没有找到大于 $LOGSIZE 的Docker日志文件。"
    exit 0
fi

echo "找到以下大日志文件："
cat /tmp/large_docker_logs.txt

# 提示用户是否删除这些日志文件
echo -n "是否删除这些日志文件? (y/n): "
read CONFIRM

if [ "$CONFIRM" == "y" ]; then
    # 逐个删除日志文件
    while IFS= read -r line; do
        LOGFILE=$(echo $line | cut -d: -f1)
        cat /dev/null > "$LOGFILE"  # 清空日志文件内容
        echo "已清空: $LOGFILE"
    done < /tmp/large_docker_logs.txt
    echo "日志文件清空完成。"
else
    echo "日志文件未被清空。"
fi

# 清理临时文件
rm -f /tmp/large_docker_logs.txt
