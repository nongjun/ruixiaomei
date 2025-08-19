#!/bin/bash
# 项目 demo-project 管理脚本

cd "$(dirname "$0")/.."

case "$1" in
    start)
        echo "启动项目 demo-project..."
        docker-compose up -d
        ;;
    stop)
        echo "停止项目 demo-project..."
        docker-compose down
        ;;
    restart)
        echo "重启项目 demo-project..."
        docker-compose restart
        ;;
    logs)
        docker-compose logs -f "$2"
        ;;
    shell)
        docker-compose exec "$2" /bin/sh
        ;;
    *)
        echo "用法: $0 {start|stop|restart|logs|shell}"
        exit 1
        ;;
esac
