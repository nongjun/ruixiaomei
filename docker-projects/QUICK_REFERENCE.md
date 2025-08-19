# Docker多项目管理系统 - 快速参考

## 🎉 系统已成功部署！

您的Docker多项目管理系统已经完全配置并运行中。

### 📊 当前状态

- ✅ **Docker版本**: 26.1.3 (with Compose v2.27.0)
- ✅ **管理脚本**: `/root/docker-projects/scripts/project-manager.sh`
- ✅ **全局服务**: Nginx代理 + Portainer管理界面
- ✅ **演示项目**: demo-project 已运行
- ✅ **环境配置**: 已自动加载到 `~/.bashrc`

### 🌐 访问地址

- **管理中心**: http://服务器IP:80
- **Portainer**: http://服务器IP:9000
- **演示项目**: http://服务器IP:32768
- **健康检查**: http://服务器IP:80/health

### ⚡ 常用命令

```bash
# 项目管理
dpm create my-project        # 创建新项目
dpm start my-project         # 启动项目
dpm stop my-project          # 停止项目
dpm list                     # 列出所有项目
dpm status                   # 查看项目状态

# 全局服务
dpm start-global             # 启动全局服务
dpm stop-global              # 停止全局服务

# 系统维护
dpm cleanup                  # 清理无用资源
dpm help                     # 查看完整帮助
```

### 🗂️ 目录结构

```
/root/docker-projects/
├── README.md                    # 完整文档
├── QUICK_REFERENCE.md           # 快速参考（本文件）
├── docker-compose.global.yml    # 全局服务配置
├── docker-env.sh               # 环境配置
├── configs/nginx/               # Nginx配置
├── scripts/project-manager.sh  # 主管理脚本
├── projects/                   # 项目目录
│   └── demo-project/           # 演示项目
└── shared/                     # 共享资源
```

### 🔧 项目特性

#### ✨ 核心特性
- **项目隔离**: 每个项目独立网络和数据卷
- **自动端口**: 动态分配可用端口，避免冲突
- **统一管理**: 一键创建、启动、停止项目
- **反向代理**: Nginx统一入口和负载均衡
- **可视化管理**: Portainer Web界面
- **健康监控**: 内置健康检查和状态监控

#### 🛡️ 安全特性
- **网络隔离**: 项目间默认无法直接通信
- **数据持久化**: 自动创建和管理数据卷
- **配置管理**: 环境变量和配置文件分离
- **日志管理**: 统一日志收集和轮转

#### 🚀 扩展特性
- **多环境支持**: 开发/测试/生产环境配置
- **自动化部署**: 支持CI/CD集成
- **监控告警**: 可集成监控系统
- **备份恢复**: 数据备份和恢复机制

### 📝 使用示例

#### 创建新的Web应用项目

```bash
# 1. 创建项目
dpm create my-webapp

# 2. 编辑项目配置（可选）
vim /root/docker-projects/projects/my-webapp/docker-compose.yml

# 3. 启动项目
dpm start my-webapp

# 4. 查看访问地址
dpm list
```

#### 添加数据库服务

编辑项目的 `docker-compose.yml`：

```yaml
services:
  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: secure_password
      MYSQL_DATABASE: myapp_db
    volumes:
      - ${PROJECT_NAME}-data:/var/lib/mysql
    networks:
      - ${PROJECT_NAME}-network
```

#### 配置域名访问

编辑 `/root/docker-projects/configs/nginx/default.conf`：

```nginx
server {
    listen 80;
    server_name myapp.yourdomain.com;
    location / {
        proxy_pass http://my-webapp-web:80;
        proxy_set_header Host $host;
    }
}
```

### 🐛 故障排除

#### 常见问题及解决方案

**问题**: 项目启动失败
```bash
# 查看错误日志
dpm logs project-name

# 检查配置语法
cd /root/docker-projects/projects/project-name
docker compose config
```

**问题**: 端口被占用
```bash
# 查看端口占用
netstat -tulpn | grep :端口号

# 停止占用进程或修改项目端口配置
```

**问题**: 网络连接问题
```bash
# 检查网络状态
docker network ls
docker network inspect project-name-network

# 重建网络
dpm restart project-name
```

### 📈 性能优化

#### 资源限制
在项目的 `docker-compose.yml` 中添加：

```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
```

#### 镜像优化
- 使用Alpine Linux基础镜像
- 启用多阶段构建
- 定期清理无用镜像

```bash
# 清理系统资源
dpm cleanup
```

### 🔒 安全建议

1. **定期更新镜像**: `docker images` 查看并更新
2. **限制网络访问**: 配置防火墙规则
3. **备份数据**: 定期备份项目数据和配置
4. **监控日志**: 定期查看系统和应用日志
5. **访问控制**: 为Portainer设置强密码

### 📚 扩展阅读

- [Docker官方文档](https://docs.docker.com/)
- [Docker Compose文档](https://docs.docker.com/compose/)
- [Nginx配置指南](https://nginx.org/en/docs/)
- [Portainer文档](https://docs.portainer.io/)

### 🆘 获取帮助

```bash
# 查看完整命令帮助
dpm help

# 查看系统状态
docker ps
docker system df

# 查看项目详情
dpm status project-name
```

---

**系统版本**: Docker 26.1.3 + Compose v2.27.0  
**部署时间**: $(date)  
**维护**: Docker多项目管理系统

🎯 **下一步**: 访问 http://服务器IP:80 开始使用您的项目管理系统！
