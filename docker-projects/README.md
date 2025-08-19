# Docker多项目管理系统

🐳 一个专业的Docker多项目管理解决方案，支持项目隔离、统一管理和便捷部署。

## 📋 目录结构

```
/root/docker-projects/
├── README.md                    # 使用文档
├── docker-compose.global.yml    # 全局服务配置
├── docker-env.sh               # 环境配置脚本
├── configs/                    # 配置文件目录
│   └── nginx/                  # Nginx反向代理配置
│       └── default.conf
├── scripts/                    # 管理脚本目录
│   └── project-manager.sh      # 主要管理脚本
├── projects/                   # 项目目录
│   ├── project1/              # 示例项目1
│   ├── project2/              # 示例项目2
│   └── ...
└── shared/                     # 共享资源目录
    ├── data/                   # 共享数据
    └── logs/                   # 共享日志
```

## 🚀 快速开始

### 1. 加载环境配置

```bash
# 加载Docker环境配置（建议添加到 ~/.bashrc）
source /root/docker-projects/docker-env.sh

# 或者添加到 ~/.bashrc 文件中
echo "source /root/docker-projects/docker-env.sh" >> ~/.bashrc
```

### 2. 启动全局服务

```bash
# 启动Nginx反向代理和Portainer管理界面
dpm start-global

# 查看全局服务状态
docker ps
```

### 3. 创建第一个项目

```bash
# 创建新项目
dpm create my-web-app

# 启动项目
dpm start my-web-app

# 查看项目状态
dpm status my-web-app
```

### 4. 访问项目

- **管理中心**: http://服务器IP:80
- **Portainer**: http://服务器IP:9000
- **项目访问**: http://服务器IP:项目端口

## 📚 详细使用指南

### 项目管理命令

#### 基础命令

```bash
# 创建新项目
dpm create <项目名>

# 启动项目
dpm start <项目名>

# 停止项目
dpm stop <项目名>

# 重启项目
dpm restart <项目名>

# 删除项目（谨慎操作）
dpm remove <项目名>
```

#### 查看和监控

```bash
# 列出所有项目
dpm list

# 查看项目状态
dpm status [项目名]

# 查看项目日志
dpm logs <项目名> [服务名]

# 进入容器shell
dpm shell <项目名> <服务名>
```

#### 全局管理

```bash
# 启动全局服务
dpm start-global

# 停止全局服务
dpm stop-global

# 清理未使用的资源
dpm cleanup

# 查看帮助
dpm help
```

### 项目配置详解

每个项目包含以下结构：

```
projects/my-project/
├── docker-compose.yml          # Docker Compose配置
├── .env                       # 环境变量配置
├── app/                       # 应用代码目录
│   └── index.html            # 默认首页
├── data/                      # 数据目录
├── logs/                      # 日志目录
├── configs/                   # 配置文件目录
└── scripts/                   # 项目脚本目录
    └── manage.sh             # 项目管理脚本
```

#### docker-compose.yml 配置

默认创建的项目包含：

- **独立网络**: 每个项目使用独立的Docker网络
- **数据卷**: 持久化数据存储
- **Web服务**: 基于Nginx的Web服务
- **环境变量**: 灵活的配置管理

#### 自定义项目配置

编辑项目的 `docker-compose.yml` 文件来添加服务：

```yaml
services:
  # 添加数据库服务
  database:
    image: mysql:8.0
    container_name: ${PROJECT_NAME}-db
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
    volumes:
      - ${PROJECT_NAME}-data:/var/lib/mysql
    networks:
      - ${PROJECT_NAME}-network

  # 添加Redis缓存
  redis:
    image: redis:alpine
    container_name: ${PROJECT_NAME}-redis
    networks:
      - ${PROJECT_NAME}-network
```

### 网络隔离策略

#### 项目间隔离

- 每个项目使用独立的Docker网络
- 默认情况下项目间无法直接通信
- 通过IP段自动分配（172.X.0.0/16）

#### 跨项目通信

如需项目间通信，在 `docker-compose.yml` 中添加：

```yaml
networks:
  default:
    external:
      name: shared-network
```

### 端口管理

#### 动态端口分配

- 项目启动时自动分配可用端口
- 使用 `docker-compose port` 查看端口映射
- 避免端口冲突

#### 固定端口配置

修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "8080:80"  # 固定映射到8080端口
```

### 数据持久化

#### 数据卷类型

1. **命名卷**: `项目名-data` （推荐）
2. **绑定挂载**: `./data:/app/data`
3. **共享卷**: `shared-data`

#### 备份策略

```bash
# 手动备份项目数据
docker run --rm -v 项目名-data:/data -v $(pwd):/backup alpine tar czf /backup/backup-$(date +%Y%m%d).tar.gz -C /data .

# 恢复数据
docker run --rm -v 项目名-data:/data -v $(pwd):/backup alpine tar xzf /backup/backup-file.tar.gz -C /data
```

### 反向代理配置

#### 基于子域名

编辑 `/root/docker-projects/configs/nginx/default.conf`：

```nginx
server {
    listen 80;
    server_name myapp.example.com;
    
    location / {
        proxy_pass http://myapp-web:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### 基于路径

```nginx
location /myapp/ {
    proxy_pass http://myapp-web:80/;
    proxy_set_header Host $host;
}
```

### 环境变量管理

#### 项目级环境变量

编辑项目的 `.env` 文件：

```bash
# 应用配置
APP_ENV=production
APP_DEBUG=false
APP_PORT=80

# 数据库配置
DB_HOST=myproject-db
DB_NAME=myproject_db
DB_USER=root
DB_PASSWORD=secure_password

# 自定义配置
CUSTOM_VAR=value
```

#### 全局环境变量

在 `docker-env.sh` 中添加：

```bash
export GLOBAL_VAR="value"
```

## 🔧 高级功能

### 多环境支持

为不同环境创建配置文件：

```bash
# 开发环境
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# 生产环境
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 自动化部署

创建部署脚本 `deploy.sh`：

```bash
#!/bin/bash
PROJECT_NAME=$1

# 拉取最新代码
git pull

# 构建镜像
docker-compose build

# 重启服务
dpm restart $PROJECT_NAME

# 健康检查
sleep 10
curl -f http://localhost:$(docker-compose port web 80 | cut -d: -f2) || exit 1

echo "部署完成"
```

### 监控和日志

#### 集中日志管理

使用ELK Stack或简单的日志聚合：

```yaml
logging:
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"
```

#### 健康检查

添加健康检查配置：

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### 性能优化

#### 资源限制

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

#### 镜像优化

- 使用多阶段构建
- 选择合适的基础镜像
- 定期清理不需要的镜像

## 🔒 安全最佳实践

### 网络安全

1. **网络隔离**: 使用独立网络限制容器间通信
2. **端口限制**: 只暴露必要的端口
3. **防火墙配置**: 配置iptables规则

### 数据安全

1. **敏感数据**: 使用Docker secrets管理
2. **定期备份**: 自动化数据备份
3. **访问控制**: 限制文件权限

### 镜像安全

1. **官方镜像**: 优先使用官方镜像
2. **安全扫描**: 定期扫描镜像漏洞
3. **及时更新**: 保持镜像版本更新

## 🛠️ 故障排除

### 常见问题

#### 端口冲突

```bash
# 查看端口占用
netstat -tulpn | grep :80

# 修改端口配置
vim projects/项目名/docker-compose.yml
```

#### 容器启动失败

```bash
# 查看容器日志
dpm logs 项目名

# 检查配置语法
docker-compose config
```

#### 网络问题

```bash
# 检查网络配置
docker network inspect 项目名-network

# 重建网络
docker-compose down
docker-compose up -d
```

#### 数据卷问题

```bash
# 查看数据卷
docker volume ls

# 检查数据卷内容
docker run --rm -v 项目名-data:/data alpine ls -la /data
```

### 维护命令

```bash
# 系统清理
dpm cleanup

# 重建所有容器
docker-compose up -d --force-recreate

# 查看系统资源使用
docker stats

# 查看磁盘使用
docker system df
```

## 📈 性能监控

### 资源监控

```bash
# 查看容器资源使用
docker stats --no-stream

# 查看系统资源
htop
```

### 日志分析

```bash
# 查看错误日志
dpm logs 项目名 | grep ERROR

# 统计请求量
docker logs nginx-proxy | grep -c "GET"
```

## 🔄 升级和迁移

### 系统升级

1. 备份所有项目数据
2. 更新Docker版本
3. 测试项目功能
4. 回滚（如有问题）

### 项目迁移

```bash
# 导出项目
docker-compose down
tar czf project-backup.tar.gz projects/项目名/

# 导入项目
tar xzf project-backup.tar.gz
dpm start 项目名
```

## 📞 支持与帮助

### 获取帮助

```bash
# 查看命令帮助
dpm help

# 查看Docker版本
docker --version

# 查看项目状态
dpm status
```

### 日志位置

- **系统日志**: `/var/log/docker`
- **项目日志**: `/root/docker-projects/projects/项目名/logs/`
- **全局服务日志**: `docker logs 容器名`

---

## 📄 许可证

本项目采用 MIT 许可证。

## 🤝 贡献

欢迎提交问题和改进建议！

---

**最后更新**: $(date)
**Docker版本**: 26.1.3
**维护者**: Docker多项目管理系统
