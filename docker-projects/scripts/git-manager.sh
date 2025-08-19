#!/bin/bash

# Git版本管理脚本 - Docker多项目管理系统
# 提供便捷的版本控制操作

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="/root/docker-projects"

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
    echo "Git版本管理器 - Docker多项目管理系统"
    echo ""
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  status                    查看Git状态"
    echo "  save <消息>               快速保存更改"
    echo "  backup                    创建系统备份"
    echo "  restore <备份文件>        恢复系统备份"
    echo "  log [数量]                查看提交历史"
    echo "  diff [文件]               查看文件差异"
    echo "  reset <提交ID>            重置到指定提交"
    echo "  branch <分支名>           创建新分支"
    echo "  switch <分支名>           切换分支"
    echo "  merge <分支名>            合并分支"
    echo "  tag <标签名> [消息]       创建标签"
    echo "  clean                     清理未跟踪文件"
    echo "  export <目录>             导出项目"
    echo ""
}

# 查看Git状态
show_status() {
    log_info "Git仓库状态:"
    cd "$PROJECT_ROOT"
    git status --short
    echo ""
    git log --oneline -5
}

# 快速保存更改
quick_save() {
    local message="$1"
    
    if [[ -z "$message" ]]; then
        log_error "请提供提交消息"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    
    # 检查是否有更改
    if git diff-index --quiet HEAD --; then
        log_warning "没有需要提交的更改"
        return 0
    fi
    
    log_info "添加所有更改..."
    git add .
    
    # 生成详细的提交消息
    local detailed_message="$message

📊 更改统计:
$(git diff --cached --stat)

🕐 提交时间: $(date)
👤 提交者: $(git config user.name)"
    
    log_info "提交更改..."
    git commit -m "$detailed_message"
    
    log_success "更改已成功提交"
}

# 创建系统备份
create_backup() {
    local backup_dir="/root/docker-projects-backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/docker-projects-$timestamp.tar.gz"
    
    mkdir -p "$backup_dir"
    
    log_info "创建系统备份..."
    cd "$PROJECT_ROOT"
    
    # 停止所有运行的项目
    log_info "停止运行中的项目..."
    for project_dir in projects/*/; do
        if [[ -d "$project_dir" ]]; then
            local project_name=$(basename "$project_dir")
            if docker compose -f "$project_dir/docker-compose.yml" ps -q &>/dev/null; then
                log_info "停止项目: $project_name"
                cd "$project_dir"
                docker compose down
                cd "$PROJECT_ROOT"
            fi
        fi
    done
    
    # 创建备份
    tar czf "$backup_file" \
        --exclude='.git' \
        --exclude='projects/*/data' \
        --exclude='projects/*/logs' \
        --exclude='shared/data' \
        --exclude='shared/logs' \
        .
    
    # 创建Git包
    git bundle create "$backup_dir/docker-projects-git-$timestamp.bundle" --all
    
    log_success "备份创建完成:"
    log_info "文件备份: $backup_file"
    log_info "Git备份: $backup_dir/docker-projects-git-$timestamp.bundle"
    
    # 重启项目
    log_info "重启项目..."
    source scripts/project-manager.sh start-global
}

# 查看提交历史
show_log() {
    local count=${1:-10}
    cd "$PROJECT_ROOT"
    git log --oneline --graph --decorate -n "$count"
}

# 查看文件差异
show_diff() {
    local file="$1"
    cd "$PROJECT_ROOT"
    
    if [[ -n "$file" ]]; then
        git diff "$file"
    else
        git diff
    fi
}

# 重置到指定提交
reset_to_commit() {
    local commit="$1"
    
    if [[ -z "$commit" ]]; then
        log_error "请提供提交ID"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    
    log_warning "即将重置到提交: $commit"
    read -p "确认重置? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git reset --hard "$commit"
        log_success "已重置到提交: $commit"
    else
        log_info "取消重置操作"
    fi
}

# 创建新分支
create_branch() {
    local branch_name="$1"
    
    if [[ -z "$branch_name" ]]; then
        log_error "请提供分支名称"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    git checkout -b "$branch_name"
    log_success "已创建并切换到分支: $branch_name"
}

# 切换分支
switch_branch() {
    local branch_name="$1"
    
    if [[ -z "$branch_name" ]]; then
        log_error "请提供分支名称"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    git checkout "$branch_name"
    log_success "已切换到分支: $branch_name"
}

# 合并分支
merge_branch() {
    local branch_name="$1"
    
    if [[ -z "$branch_name" ]]; then
        log_error "请提供要合并的分支名称"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    git merge "$branch_name"
    log_success "已合并分支: $branch_name"
}

# 创建标签
create_tag() {
    local tag_name="$1"
    local tag_message="$2"
    
    if [[ -z "$tag_name" ]]; then
        log_error "请提供标签名称"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    
    if [[ -n "$tag_message" ]]; then
        git tag -a "$tag_name" -m "$tag_message"
    else
        git tag "$tag_name"
    fi
    
    log_success "已创建标签: $tag_name"
}

# 清理未跟踪文件
clean_untracked() {
    cd "$PROJECT_ROOT"
    
    log_warning "即将删除所有未跟踪的文件"
    git clean -n
    echo ""
    read -p "确认删除? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git clean -f
        log_success "已清理未跟踪文件"
    else
        log_info "取消清理操作"
    fi
}

# 导出项目
export_project() {
    local export_dir="$1"
    
    if [[ -z "$export_dir" ]]; then
        log_error "请提供导出目录"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    
    log_info "导出项目到: $export_dir"
    mkdir -p "$export_dir"
    
    # 使用git archive导出
    git archive --format=tar.gz --output="$export_dir/docker-projects-export-$(date +%Y%m%d_%H%M%S).tar.gz" HEAD
    
    log_success "项目已导出完成"
}

# 主程序
main() {
    cd "$PROJECT_ROOT" || {
        log_error "无法访问项目目录: $PROJECT_ROOT"
        exit 1
    }
    
    case "$1" in
        status)
            show_status
            ;;
        save)
            quick_save "$2"
            ;;
        backup)
            create_backup
            ;;
        log)
            show_log "$2"
            ;;
        diff)
            show_diff "$2"
            ;;
        reset)
            reset_to_commit "$2"
            ;;
        branch)
            create_branch "$2"
            ;;
        switch)
            switch_branch "$2"
            ;;
        merge)
            merge_branch "$2"
            ;;
        tag)
            create_tag "$2" "$3"
            ;;
        clean)
            clean_untracked
            ;;
        export)
            export_project "$2"
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
