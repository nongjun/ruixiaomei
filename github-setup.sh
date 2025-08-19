#!/bin/bash

# GitHub仓库管理脚本
# 用于管理服务器的GitHub集成

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub配置
GITHUB_USER="nongjun"
MAIN_REPO="ruixiaomei"
DOCKER_REPO="docker-projects"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "GitHub仓库管理脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  status              查看GitHub仓库状态"
    echo "  sync                同步到GitHub"
    echo "  pull                从GitHub拉取更新"
    echo "  setup-docker        设置Docker项目仓库"
    echo "  create-docker-repo  创建Docker项目独立仓库"
    echo "  backup-to-github    备份到GitHub"
    echo "  clone-fresh         重新克隆仓库"
    echo ""
}

# 查看GitHub状态
show_status() {
    log_info "GitHub仓库状态:"
    echo ""
    
    # 主仓库状态
    log_info "主仓库 (/root):"
    cd /root
    if git remote -v | grep -q origin; then
        echo "  远程仓库: $(git remote get-url origin)"
        echo "  当前分支: $(git branch --show-current)"
        echo "  最新提交: $(git log --oneline -1)"
        
        # 检查是否有未推送的提交
        if git status --porcelain | grep -q .; then
            log_warning "  有未提交的更改"
        fi
        
        if git log --oneline origin/master..HEAD 2>/dev/null | grep -q .; then
            log_warning "  有未推送的提交"
        fi
    else
        log_error "  未配置远程仓库"
    fi
    
    echo ""
    
    # Docker项目状态
    log_info "Docker项目 (/root/docker-projects):"
    cd /root/docker-projects
    if git remote -v | grep -q origin; then
        echo "  远程仓库: $(git remote get-url origin)"
        echo "  当前分支: $(git branch --show-current)"
        echo "  最新提交: $(git log --oneline -1)"
    else
        log_warning "  未配置远程仓库"
    fi
}

# 同步到GitHub
sync_to_github() {
    log_info "同步到GitHub..."
    
    # 同步主仓库
    log_info "同步主仓库..."
    cd /root
    
    # 提交当前更改
    if git status --porcelain | grep -q .; then
        git add .
        git commit -m "🔄 自动同步 - $(date)"
    fi
    
    # 推送到GitHub
    git push origin master
    log_success "主仓库同步完成"
    
    # 同步Docker项目（如果有远程仓库）
    cd /root/docker-projects
    if git remote -v | grep -q origin; then
        log_info "同步Docker项目..."
        
        if git status --porcelain | grep -q .; then
            git add .
            git commit -m "🔄 自动同步 - $(date)"
        fi
        
        git push origin master
        log_success "Docker项目同步完成"
    else
        log_warning "Docker项目未配置远程仓库，跳过同步"
    fi
}

# 从GitHub拉取更新
pull_from_github() {
    log_info "从GitHub拉取更新..."
    
    # 拉取主仓库
    log_info "拉取主仓库更新..."
    cd /root
    git pull origin master
    log_success "主仓库更新完成"
    
    # 拉取Docker项目
    cd /root/docker-projects
    if git remote -v | grep -q origin; then
        log_info "拉取Docker项目更新..."
        git pull origin master
        log_success "Docker项目更新完成"
    else
        log_warning "Docker项目未配置远程仓库，跳过拉取"
    fi
}

# 设置Docker项目仓库
setup_docker_repo() {
    log_info "设置Docker项目GitHub仓库..."
    
    cd /root/docker-projects
    
    # 检查是否已有远程仓库
    if git remote -v | grep -q origin; then
        log_warning "已配置远程仓库: $(git remote get-url origin)"
        return 0
    fi
    
    # 添加远程仓库
    git remote add origin "https://github.com/$GITHUB_USER/$DOCKER_REPO.git"
    
    # 尝试推送
    if git push -u origin master 2>/dev/null; then
        log_success "Docker项目仓库设置完成"
    else
        log_error "推送失败，仓库可能不存在"
        log_info "请先在GitHub创建仓库: $GITHUB_USER/$DOCKER_REPO"
        git remote remove origin
    fi
}

# 备份到GitHub
backup_to_github() {
    log_info "创建完整备份到GitHub..."
    
    # 创建备份分支
    cd /root
    local backup_branch="backup-$(date +%Y%m%d_%H%M%S)"
    
    git checkout -b "$backup_branch"
    
    # 添加所有文件（包括通常被忽略的）
    git add -f .
    git commit -m "🗄️ 完整系统备份 - $(date)"
    
    # 推送备份分支
    git push origin "$backup_branch"
    
    # 返回主分支
    git checkout master
    
    log_success "备份完成，分支: $backup_branch"
}

# 检查网络连接
check_connection() {
    if ! ping -c 1 github.com >/dev/null 2>&1; then
        log_error "无法连接到GitHub"
        exit 1
    fi
}

# 主程序
main() {
    # 检查网络连接
    check_connection
    
    case "$1" in
        status)
            show_status
            ;;
        sync)
            sync_to_github
            ;;
        pull)
            pull_from_github
            ;;
        setup-docker)
            setup_docker_repo
            ;;
        backup)
            backup_to_github
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主程序
main "$@"
