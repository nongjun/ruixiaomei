# 服务器管理 - Git仓库说明

## 🖥️ 服务器信息

- **IP地址**: 120.79.242.43
- **系统**: Linux + Docker 26.1.3
- **管理框架**: Docker多项目管理系统
- **GitHub仓库**: https://github.com/nongjun/ruixiaomei

## 📁 Git仓库结构

本服务器使用**统一Git仓库**结构进行版本控制：

### 主仓库 (`/root/`)
- **GitHub地址**: https://github.com/nongjun/ruixiaomei
- **用途**: 完整的服务器管理和Docker项目系统
- **包含内容**:
  - **系统配置**: Cursor IDE配置、Bash环境配置、系统级配置文件
  - **Docker项目系统**: (`docker-projects/`) 完整的多项目管理框架
    - 项目管理脚本 (`scripts/`)
    - Docker Compose配置 (`configs/`)
    - Nginx反向代理配置
    - 项目模板和文档
    - Git版本控制工具

## 🔧 管理命令

### 统一Git操作
```bash
cd /root
git status                    # 查看整个系统状态
git add .                     # 添加所有更改
git commit -m "更新说明"      # 提交更改
git push origin master       # 推送到GitHub

# 使用GitHub管理脚本
./github-setup.sh status     # 查看GitHub状态
./github-setup.sh sync       # 快速同步到GitHub
./github-setup.sh backup     # 创建完整备份
```

### Docker项目管理
```bash
cd /root/docker-projects
source docker-env.sh         # 加载环境配置
dpm list                     # 列出所有项目
dpm create my-project        # 创建新项目
dpm start my-project         # 启动项目
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

- ✅ 统一Git仓库已初始化并连接GitHub
- ✅ Docker项目管理系统已集成
- ✅ Cursor IDE后台agent完全支持
- ✅ GitHub远程仓库: https://github.com/nongjun/ruixiaomei
- ✅ 所有功能正常运行

## 📞 管理工具

- **项目管理**: `dpm help`
- **Git管理**: `dpm-git help`
- **Web界面**: http://120.79.242.43:9000 (Portainer)
- **代理入口**: http://120.79.242.43:80 (Nginx)

---

**维护**: 服务器管理系统  
**更新时间**: $(date)  
**Git结构**: 双层仓库管理
