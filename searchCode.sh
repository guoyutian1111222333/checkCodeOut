#!/bin/bash

# 关键字
keyword=$1

# 用户名和密码（固定值）
username=""
password=""

# 仓库地址文件
repos_file="repos.txt"

# 输出结果的文件夹
output_dir="/home/zyb/checkGit/search_results"
mkdir -p $output_dir

# 创建临时目录
temp_dir=$(mktemp -d)

# 函数：搜索一个仓库中的所有分支
search_in_repo() {
    repo_url=$1
    repo_name=$(basename -s .git $repo_url)
    repo_url_with_auth=$(echo $repo_url | sed "s#http://#http://$username:$password@#")

    echo "Cloning repository: $repo_url_with_auth"
    git clone --quiet $repo_url_with_auth $temp_dir/$repo_name
   

    cd $temp_dir/$repo_name

    # 获取所有分支的列表
    branches=$(git branch -r | grep -v '\->')

    # 遍历每一个分支
    for branch in $branches; do
        branch_name=$(echo $branch | sed 's/origin\///')
        output_file="${output_dir}/${repo_name}_${branch_name}.txt"
        # 检出分支
        git checkout --quiet $branch
        # 在分支中搜索关键字并临时保存结果
        git grep -n "$keyword" > temp_output.txt
        echo "正在查找 repository: $repo_url $branch_name"
        if [ -s temp_output.txt ]; then
            mv temp_output.txt $output_file
            echo "输出结果文件 $output_file"
        else
            rm temp_output.txt
        fi
    done

    # 返回上一层目录
    cd - > /dev/null
}

# 读取仓库地址文件并遍历每个地址
while IFS= read -r repo_url; do
    if [ ! -z "$repo_url" ]; then
        echo $repo_url
        search_in_repo $repo_url
    fi
done < "$repos_file"

# 删除临时目录
rm -rf $temp_dir

echo "Search completed. Results are in the $output_dir directory."
