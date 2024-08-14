#!/bin/bash
# 设置GitLab私有访问令牌和GitLab服务器的域名
TOKEN="YOUR_ACCESS_TOKEN"
DOMAIN="YOUR_GITLAB_DOMAIN"
PAGE=1
PER_PAGE=100
OUTPUT_FILE="repositories.txt"

# 清空输出文件，确保文件是新的或者空的
> $OUTPUT_FILE

# 循环访问每一页直到没有更多的项目
while true; do
  # 获取当前页的项目信息
  RESPONSE=$(curl --silent --header "PRIVATE-TOKEN: $TOKEN" "https://IP/api/v4/projects?owned=true&simple=true&per_page=$PER_PAGE&page=$PAGE")
  
  # 使用jq解析HTTP地址并追加到文件
  echo "$RESPONSE" | jq -r '.[].http_url_to_repo' >> $OUTPUT_FILE
  
  # 检查这一页的项目数是否少于每页最大项目数，如果是，则停止循环
  if [ $(echo "$RESPONSE" | jq '. | length') -lt $PER_PAGE ]; then
    break
  fi
  
  # 递增页码以获取下一页
  ((PAGE++))
done

echo "所有仓库的HTTP地址已保存到 $OUTPUT_FILE"
