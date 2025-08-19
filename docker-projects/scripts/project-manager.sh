#!/bin/bash

# Docker多项目管理脚本
# 用于创建、管理和部署独立的Docker项目

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="/root/docker-projects"
PROJECTS_DIR="$PROJECT_ROOT/projects"
CONFIGS_DIR="$PROJECT_ROOT/configs"

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
    echo "Docker多项目管理器"
    echo ""
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  create <项目名>           创建新项目"
    echo "  start <项目名>            启动项目"
    echo "  stop <项目名>             停止项目"
    echo "  restart <项目名>          重启项目"
    echo "  remove <项目名>           删除项目"
    echo "  list                      列出所有项目"
    echo "  status [项目名]           查看项目状态"
    echo "  logs <项目名> [服务名]    查看项目日志"
    echo "  shell <项目名> <服务名>   进入容器shell"
    echo "  update <项目名>           更新项目镜像"
    echo "  backup <项目名>           备份项目数据"
    echo "  restore <项目名> <备份文件> 恢复项目数据"
    echo ""
    echo "全局命令:"
    echo "  start-global              启动全局服务"
    echo "  stop-global               停止全局服务"
    echo "  cleanup                   清理未使用的资源"
    echo ""
}

# 创建新项目
create_project() {
    local project_name=$1
    
    if [[ -z "$project_name" ]]; then
        log_error "请提供项目名称"
        exit 1
    fi
    
    if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "项目名称只能包含字母、数字、下划线和连字符"
        exit 1
    fi
    
    local project_dir="$PROJECTS_DIR/$project_name"
    
    if [[ -d "$project_dir" ]]; then
        log_error "项目 '$project_name' 已存在"
        exit 1
    fi
    
    log_info "创建项目: $project_name"
    
    # 创建项目目录结构
    mkdir -p "$project_dir"/{app,data,logs,configs,scripts}
    
    # 生成项目特定的网络子网
    local subnet_third=$(( ($(ls -1 "$PROJECTS_DIR" | wc -l) + 21) % 254 ))
    local project_subnet="172.$subnet_third.0.0/16"
    
    # 创建docker-compose.yml模板
    cat > "$project_dir/docker-compose.yml" << EOF
# Docker Compose配置 - 项目: $project_name
# 创建时间: $(date)

version: '3.8'

# 项目专用网络
networks:
  ${project_name}-network:
    driver: bridge
    ipam:
      config:
        - subnet: $project_subnet

# 项目数据卷
volumes:
  ${project_name}-data:
    driver: local
  ${project_name}-logs:
    driver: local

services:
  # 示例Web应用服务
  web:
    image: nginx:alpine
    container_name: ${project_name}-web
    ports:
      - "0:80"  # 动态端口分配
    volumes:
      - ./app:/usr/share/nginx/html
      - ${project_name}-logs:/var/log/nginx
    networks:
      - ${project_name}-network
    restart: unless-stopped
    environment:
      - PROJECT_NAME=$project_name
    
  # 示例数据库服务（根据需要启用）
  # database:
  #   image: mysql:8.0
  #   container_name: ${project_name}-db
  #   environment:
  #     MYSQL_ROOT_PASSWORD: your_password
  #     MYSQL_DATABASE: ${project_name}_db
  #   volumes:
  #     - ${project_name}-data:/var/lib/mysql
  #   networks:
  #     - ${project_name}-network
  #   restart: unless-stopped

# 外部网络连接（可选）
# networks:
#   default:
#     external:
#       name: shared-network
EOF

    # 创建示例应用文件
    cat > "$project_dir/app/index.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>项目: $project_name</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; }
        .info { background: #e7f3ff; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Docker项目: $project_name</h1>
        <div class="info">
            <p><strong>项目状态:</strong> 运行中</p>
            <p><strong>创建时间:</strong> $(date)</p>
            <p><strong>容器名:</strong> ${project_name}-web</p>
        </div>
        <p>欢迎使用Docker多项目管理系统！</p>
        <p>这是项目 <strong>$project_name</strong> 的默认页面。</p>
    </div>
</body>
</html>
EOF

    # 创建项目管理脚本
    cat > "$project_dir/scripts/manage.sh" << EOF
#!/bin/bash
# 项目 $project_name 管理脚本

cd "\$(dirname "\$0")/.."

case "\$1" in
    start)
        echo "启动项目 $project_name..."
        docker compose up -d
        ;;
    stop)
        echo "停止项目 $project_name..."
        docker compose down
        ;;
    restart)
        echo "重启项目 $project_name..."
        docker compose restart
        ;;
    logs)
        docker compose logs -f "\$2"
        ;;
    shell)
        docker compose exec "\$2" /bin/sh
        ;;
    *)
        echo "用法: \$0 {start|stop|restart|logs|shell}"
        exit 1
        ;;
esac
EOF

    chmod +x "$project_dir/scripts/manage.sh"
    
    # 创建项目配置文件
    cat > "$project_dir/.env" << EOF
# 项目环境变量配置
PROJECT_NAME=$project_name
PROJECT_ENV=development
PROJECT_SUBNET=$project_subnet

# 数据库配置（如果使用）
DB_HOST=${project_name}-db
DB_NAME=${project_name}_db
DB_USER=root
DB_PASSWORD=your_password

# 应用配置
APP_PORT=80
APP_DEBUG=true
EOF

    log_success "项目 '$project_name' 创建成功!"
    log_info "项目目录: $project_dir"
    log_info "启动项目: $0 start $project_name"
}

# 启动项目
start_project() {
    local project_name=$1
    local project_dir="$PROJECTS_DIR/$project_name"
    
    if [[ ! -d "$project_dir" ]]; then
        log_error "项目 '$project_name' 不存在"
        exit 1
    fi
    
    log_info "启动项目: $project_name"
    cd "$project_dir"
    docker compose up -d
    
    # 显示端口信息
    sleep 2
    local port=$(docker compose port web 80 2>/dev/null | cut -d: -f2)
    if [[ -n "$port" ]]; then
        log_success "项目已启动，访问地址: http://$(hostname -I | awk '{print $1}'):$port"
    fi
}

# 停止项目
stop_project() {
    local project_name=$1
    local project_dir="$PROJECTS_DIR/$project_name"
    
    if [[ ! -d "$project_dir" ]]; then
        log_error "项目 '$project_name' 不存在"
        exit 1
    fi
    
    log_info "停止项目: $project_name"
    cd "$project_dir"
    docker compose down
    log_success "项目 '$project_name' 已停止"
}

# 重启项目
restart_project() {
    local project_name=$1
    stop_project "$project_name"
    sleep 2
    start_project "$project_name"
}

# 删除项目
remove_project() {
    local project_name=$1
    local project_dir="$PROJECTS_DIR/$project_name"
    
    if [[ ! -d "$project_dir" ]]; then
        log_error "项目 '$project_name' 不存在"
        exit 1
    fi
    
    log_warning "即将删除项目 '$project_name' 及其所有数据!"
    read -p "确认删除? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "删除项目: $project_name"
        cd "$project_dir"
        docker compose down -v --remove-orphans
        cd ..
        rm -rf "$project_dir"
        log_success "项目 '$project_name' 已删除"
    else
        log_info "取消删除操作"
    fi
}

# 列出所有项目
list_projects() {
    log_info "Docker项目列表:"
    echo ""
    
    if [[ ! -d "$PROJECTS_DIR" ]] || [[ -z "$(ls -A "$PROJECTS_DIR" 2>/dev/null)" ]]; then
        echo "  暂无项目"
        return
    fi
    
    printf "%-20s %-15s %-10s %-30s\n" "项目名称" "状态" "容器数" "访问地址"
    echo "--------------------------------------------------------------------------------"
    
    for project_dir in "$PROJECTS_DIR"/*; do
        if [[ -d "$project_dir" ]]; then
            local project_name=$(basename "$project_dir")
            local status="停止"
            local container_count=0
            local access_url="N/A"
            
            cd "$project_dir"
            if docker compose ps -q &>/dev/null; then
                local running_containers=$(docker compose ps -q --filter "status=running" | wc -l)
                local total_containers=$(docker compose ps -q | wc -l)
                
                if [[ $running_containers -gt 0 ]]; then
                    status="运行中"
                    local port=$(docker compose port web 80 2>/dev/null | cut -d: -f2)
                    if [[ -n "$port" ]]; then
                        access_url="http://$(hostname -I | awk '{print $1}'):$port"
                    fi
                fi
                container_count="$running_containers/$total_containers"
            fi
            
            printf "%-20s %-15s %-10s %-30s\n" "$project_name" "$status" "$container_count" "$access_url"
        fi
    done
}

# 查看项目状态
show_status() {
    local project_name=$1
    
    if [[ -n "$project_name" ]]; then
        local project_dir="$PROJECTS_DIR/$project_name"
        if [[ ! -d "$project_dir" ]]; then
            log_error "项目 '$project_name' 不存在"
            exit 1
        fi
        
        log_info "项目 '$project_name' 状态:"
        cd "$project_dir"
        docker compose ps
    else
        list_projects
    fi
}

# 查看日志
show_logs() {
    local project_name=$1
    local service_name=$2
    local project_dir="$PROJECTS_DIR/$project_name"
    
    if [[ ! -d "$project_dir" ]]; then
        log_error "项目 '$project_name' 不存在"
        exit 1
    fi
    
    cd "$project_dir"
    if [[ -n "$service_name" ]]; then
        docker compose logs -f "$service_name"
    else
        docker compose logs -f
    fi
}

# 进入容器shell
enter_shell() {
    local project_name=$1
    local service_name=$2
    local project_dir="$PROJECTS_DIR/$project_name"
    
    if [[ -z "$service_name" ]]; then
        log_error "请指定服务名称"
        exit 1
    fi
    
    if [[ ! -d "$project_dir" ]]; then
        log_error "项目 '$project_name' 不存在"
        exit 1
    fi
    
    cd "$project_dir"
    docker compose exec "$service_name" /bin/sh
}

# 启动全局服务
start_global() {
    log_info "启动全局服务..."
    cd "$PROJECT_ROOT"
    docker compose -f docker-compose.global.yml up -d
    log_success "全局服务已启动"
}

# 停止全局服务
stop_global() {
    log_info "停止全局服务..."
    cd "$PROJECT_ROOT"
    docker compose -f docker-compose.global.yml down
    log_success "全局服务已停止"
}

# 清理未使用的资源
cleanup() {
    log_info "清理Docker未使用的资源..."
    docker system prune -f
    docker volume prune -f
    docker network prune -f
    log_success "清理完成"
}

# 主程序
main() {
    # 确保项目目录存在
    mkdir -p "$PROJECTS_DIR" "$CONFIGS_DIR"
    
    case "$1" in
        create)
            create_project "$2"
            ;;
        start)
            start_project "$2"
            ;;
        stop)
            stop_project "$2"
            ;;
        restart)
            restart_project "$2"
            ;;
        remove)
            remove_project "$2"
            ;;
        list)
            list_projects
            ;;
        status)
            show_status "$2"
            ;;
        logs)
            show_logs "$2" "$3"
            ;;
        shell)
            enter_shell "$2" "$3"
            ;;
        start-global)
            start_global
            ;;
        stop-global)
            stop_global
            ;;
        cleanup)
            cleanup
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
