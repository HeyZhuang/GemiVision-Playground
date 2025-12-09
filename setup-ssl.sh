#!/bin/bash

# SSL证书配置脚本 - 为ch-love.online配置Let's Encrypt证书
# 使用方法: 在服务器上运行此脚本

DOMAIN="ch-love.online"
EMAIL="admin@ch-love.online"  # 请替换为实际邮箱

echo "开始为 $DOMAIN 配置SSL证书..."

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 更新系统包
apt update

# 安装Certbot
apt install -y certbot python3-certbot-nginx

# 获取SSL证书
certbot --nginx -d $DOMAIN -d www.$DOMAIN --email $EMAIL --agree-tos --non-interactive

# 检查证书获取是否成功
if [ $? -eq 0 ]; then
    echo "SSL证书配置成功！"
    
    # 设置自动续期
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
    
    echo "已设置证书自动续期"
    echo ""
    echo "🎉 HTTPS配置完成！"
    echo ""
    echo "网站现在可以通过以下HTTPS地址访问："
    echo "  - https://ch-love.online"
    echo "  - https://www.ch-love.online"
    echo ""
    echo "HTTP访问将自动重定向到HTTPS"
    
    # 测试Nginx配置
    nginx -t && systemctl reload nginx
    
else
    echo "SSL证书配置失败，请检查："
    echo "1. 域名DNS是否正确指向服务器IP"
    echo "2. 服务器防火墙是否开放80和443端口"
    echo "3. Nginx是否正常运行"
fi

echo ""
echo "可以使用以下命令检查证书状态："
echo "certbot certificates"
echo ""
echo "手动续期证书："
echo "certbot renew"
