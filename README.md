# 服务器管理 - Git仓库说明

## 🖥️ 服务器信息

- **IP地址**: 120.79.242.43
- **系统**: Linux + Docker 26.1.3
- **管理框架**: Docker多项目管理系统
- **GitHub仓库**: https://github.com/nongjun/ruixiaomei

## 📁 Git仓库结构

本服务器使用**双层Git仓库**结构进行版本控制：

### 1. 根目录仓库 (`/root/`)
- **用途**: 服务器系统配置和环境管理
- **包含内容**:
  - Cursor IDE配置 (`.cursor/`)
  - Bash环境配置 (`.bashrc`)
  - 系统级配置文件
  - Git忽略规则

### 2. Docker项目仓库 (`/root/docker-projects/`)
- **用途**: Docker多项目管理系统
- **包含内容**:
  - 项目管理脚本
  - Docker Compose配置
  - Nginx反向代理配置
  - 项目模板和文档
  - Git版本控制工具

## 🔧 管理命令

### 根目录Git操作
```bash
cd /root
git status                    # 查看系统配置状态
git add .cursor/ .bashrc      # 添加配置文件
git commit -m "更新系统配置"   # 提交更改
```

### Docker项目Git操作
```bash
cd /root/docker-projects
dpm-git status               # 查看项目状态
dpm-git save "更新说明"      # 快速保存更改
dpm-git backup               # 创建系统备份
```

## 🛡️ 安全配置

- **敏感文件保护**: SSH密钥、证书、密码文件已排除
- **运行时数据隔离**: 容器数据和日志不进入版本控制
- **配置分离**: 系统配置与项目配置独立管理

## 🚀 快速开始

1. **环境加载**:
   ```bash
   source /root/docker-projects/docker-env.sh
   ```

2. **查看项目状态**:
   ```bash
   dpm list
   ```

3. **Git状态检查**:
   ```bash
   # 系统配置Git状态
   cd /root && git status
   
   # Docker项目Git状态
   dpm-git status
   ```

## 📊 当前状态

- ✅ 根目录Git仓库已初始化
- ✅ Docker项目Git仓库已配置
- ✅ Cursor IDE后台agent支持
- ✅ 双层版本控制结构

## 📞 管理工具

- **项目管理**: `dpm help`
- **Git管理**: `dpm-git help`
- **Web界面**: http://120.79.242.43:9000 (Portainer)
- **代理入口**: http://120.79.242.43:80 (Nginx)

---

**维护**: 服务器管理系统  
**更新时间**: $(date)  
**Git结构**: 双层仓库管理
