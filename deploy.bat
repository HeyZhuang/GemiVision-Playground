@echo off
chcp 65001 >nul
echo ========================================
echo 圣诞树项目部署脚本 (Windows版本)
echo ========================================
echo.

set SERVER_IP=117.72.146.138
set DOMAIN=ch-love.online
set REMOTE_PATH=/var/www/html

echo 服务器IP: %SERVER_IP%
echo 域名: %DOMAIN%
echo.

REM 检查必要文件
if not exist "index.html" (
    echo 错误: index.html 文件不存在
    pause
    exit /b 1
)

if not exist "picture" (
    echo 错误: picture 目录不存在
    pause
    exit /b 1
)

echo 文件检查完成！
echo.

REM 检查是否安装了必要工具
where scp >nul 2>nul
if %errorlevel% neq 0 (
    echo 警告: 未找到 scp 命令
    echo 请安装 OpenSSH 客户端或使用 Git Bash
    echo.
    echo 可选方案：
    echo 1. 安装 Git for Windows (包含 Git Bash)
    echo 2. 启用 Windows OpenSSH 功能
    echo 3. 使用 FileZilla 等 FTP 工具手动上传
    echo.
    pause
    exit /b 1
)

echo 开始上传文件到服务器...
echo.

REM 上传 index.html
echo 上传 index.html...
scp index.html root@%SERVER_IP%:%REMOTE_PATH%/
if %errorlevel% neq 0 (
    echo 上传 index.html 失败
    pause
    exit /b 1
)

REM 上传 picture 目录
echo 上传 picture 目录...
scp -r picture root@%SERVER_IP%:%REMOTE_PATH%/
if %errorlevel% neq 0 (
    echo 上传 picture 目录失败
    pause
    exit /b 1
)

echo.
echo 文件上传完成！
echo.

echo 正在配置服务器...
echo 请在弹出的 SSH 会话中执行以下命令：
echo.
echo ----------------------------------------
echo # 设置权限
echo sudo chown -R www-data:www-data /var/www/html
echo sudo chmod -R 755 /var/www/html
echo.
echo # 创建 Nginx 配置
echo sudo nano /etc/nginx/sites-available/ch-love.online
echo.
echo # 然后粘贴配置内容（见部署说明.md）
echo.
echo # 启用站点
echo sudo ln -sf /etc/nginx/sites-available/ch-love.online /etc/nginx/sites-enabled/
echo sudo rm -f /etc/nginx/sites-enabled/default
echo sudo nginx -t
echo sudo systemctl reload nginx
echo.
echo # 配置防火墙
echo sudo ufw allow 'Nginx Full'
echo ----------------------------------------
echo.

REM 打开 SSH 连接
echo 正在连接到服务器...
ssh root@%SERVER_IP%

echo.
echo ========================================
echo 部署完成！
echo.
echo 网站访问地址：
echo   - http://ch-love.online
echo   - http://www.ch-love.online  
echo   - http://%SERVER_IP%
echo.
echo 如需帮助，请查看 部署说明.md 文件
echo ========================================
pause
