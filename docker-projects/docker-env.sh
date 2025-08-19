#!/bin/bash

# Docker多项目环境配置脚本
# 用于设置命令别名和环境变量

# 项目根目录
export DOCKER_PROJECTS_ROOT="/root/docker-projects"
export DOCKER_PROJECTS_DIR="$DOCKER_PROJECTS_ROOT/projects"

# 添加到PATH
export PATH="$DOCKER_PROJECTS_ROOT/scripts:$PATH"

# 创建便捷命令别名
alias dpm='project-manager.sh'
alias dpm-git='git-manager.sh'
alias docker-projects='project-manager.sh list'
alias dpm-create='project-manager.sh create'
alias dpm-start='project-manager.sh start'
alias dpm-stop='project-manager.sh stop'
alias dpm-restart='project-manager.sh restart'
alias dpm-remove='project-manager.sh remove'
alias dpm-status='project-manager.sh status'
alias dpm-logs='project-manager.sh logs'
alias dpm-shell='project-manager.sh shell'
alias dpm-global-start='project-manager.sh start-global'
alias dpm-global-stop='project-manager.sh stop-global'
alias dpm-cleanup='project-manager.sh cleanup'

# Docker常用命令别名
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dn='docker network ls'
alias dv='docker volume ls'
alias dc='docker compose'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'

# 显示欢迎信息
echo "🐳 Docker多项目管理环境已加载"
echo ""
echo "常用命令："
echo "  dpm create <项目名>     - 创建新项目"
echo "  dpm start <项目名>      - 启动项目"
echo "  dpm list               - 列出所有项目"
echo "  dpm status             - 查看项目状态"
echo "  dpm help               - 查看完整帮助"
echo ""
echo "Git版本控制："
echo "  dpm-git status         - 查看Git状态"
echo "  dpm-git save <消息>    - 快速保存更改"
echo "  dpm-git backup         - 创建系统备份"
echo "  dpm-git help           - Git管理帮助"
echo ""
echo "项目目录: $DOCKER_PROJECTS_ROOT"
echo ""
