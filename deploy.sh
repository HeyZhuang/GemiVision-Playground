#!/bin/bash

# 圣诞树项目部署脚本
# 服务器信息
SERVER_IP="117.72.146.138"
DOMAIN="ch-love.online"
LOCAL_PATH="."
REMOTE_PATH="/var/www/html"

echo "开始部署圣诞树项目到服务器..."
echo "服务器IP: $SERVER_IP"
echo "域名: $DOMAIN"

# 检查必要文件是否存在
if [ ! -f "index.html" ]; then
    echo "错误: index.html 文件不存在"
    exit 1
fi

if [ ! -d "picture" ]; then
    echo "错误: picture 目录不存在"
    exit 1
fi

echo "文件检查完成，开始上传..."

# 使用rsync同步文件到服务器
# 注意：需要先配置SSH密钥或输入密码
rsync -avz --progress \
    --exclude='.git' \
    --exclude='*.sh' \
    --exclude='christmas_tree_touch&gesture.html' \
    --exclude='README.md' \
    $LOCAL_PATH/ root@$SERVER_IP:$REMOTE_PATH/

if [ $? -eq 0 ]; then
    echo "文件上传成功！"
    echo "正在配置Nginx..."
    
    # 创建Nginx配置
    ssh root@$SERVER_IP << 'EOF'
# 创建网站目录（如果不存在）
mkdir -p /var/www/html

# 设置正确的权限
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# 创建Nginx配置文件
cat > /etc/nginx/sites-available/ch-love.online << 'NGINX_CONFIG'
server {
    listen 80;
    server_name ch-love.online www.ch-love.online 117.72.146.138;
    
    root /var/www/html;
    index index.html index.htm;
    
    # 启用gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # 主页面
    location / {
        try_files $uri $uri/ =404;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
    }
    
    # 错误页面
    error_page 404 /index.html;
}
NGINX_CONFIG

# 启用站点
ln -sf /etc/nginx/sites-available/ch-love.online /etc/nginx/sites-enabled/

# 删除默认站点（如果存在）
rm -f /etc/nginx/sites-enabled/default

# 测试Nginx配置
nginx -t

if [ $? -eq 0 ]; then
    # 重启Nginx
    systemctl reload nginx
    systemctl enable nginx
    echo "Nginx配置成功！"
else
    echo "Nginx配置错误，请检查配置文件"
    exit 1
fi

# 检查防火墙设置
ufw allow 'Nginx Full'
ufw allow ssh

echo "部署完成！"
echo "网站可以通过以下地址访问："
echo "http://ch-love.online"
echo "http://www.ch-love.online"
echo "http://117.72.146.138"
EOF

    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 部署成功！"
        echo ""
        echo "网站访问地址："
        echo "  - http://ch-love.online"
        echo "  - http://www.ch-love.online"
        echo "  - http://117.72.146.138"
        echo ""
        echo "建议后续配置SSL证书以启用HTTPS访问"
    else
        echo "服务器配置过程中出现错误"
        exit 1
    fi
else
    echo "文件上传失败，请检查网络连接和服务器配置"
    exit 1
fi
