# GitHub Pages 部署说明

## 问题排查

如果访问时出现 404 错误，请按以下步骤检查：

### 1. 确认 GitHub Pages 已启用

1. 访问仓库设置：https://github.com/fqcwork2017/fqcwork20217.github.io/settings/pages
2. 在 "Source" 部分选择分支（通常是 `main` 或 `master`）
3. 点击 "Save" 保存设置

### 2. 访问地址

对于仓库名 `fqcwork20217.github.io`，访问地址应该是：
- **https://fqcwork20217.github.io/** （如果仓库是用户名.github.io格式）
- **https://fqcwork2017.github.io/fqcwork20217.github.io/** （如果是普通仓库）

### 3. 权限问题

如果遇到权限错误，请：

**方案 A：检查 SSH 密钥**
```bash
ssh -T git@github.com
```

**方案 B：使用 HTTPS 方式（需要 Personal Access Token）**
```bash
git remote set-url origin https://github.com/fqcwork2017/fqcwork20217.github.io.git
```

**方案 C：确认仓库协作者权限**
- 前往仓库设置 → Collaborators
- 确保你的 GitHub 账户有写入权限

### 4. 手动部署步骤

如果自动部署脚本失败，可以手动执行：

```bash
# 1. 构建应用
flutter build web --release

# 2. 克隆仓库
git clone git@github.com:fqcwork2017/fqcwork20217.github.io.git deploy_temp

# 3. 复制文件
cd deploy_temp
cp -r ../build/web/* .

# 4. 添加 .nojekyll 文件（重要！）
touch .nojekyll

# 5. 提交并推送
git add -A
git commit -m "Deploy Flutter Web app"
git push -u origin main
```

### 5. 验证部署

部署成功后：
1. 等待几分钟让 GitHub Pages 构建完成
2. 访问：https://fqcwork20217.github.io/
3. 如果还是 404，检查仓库的 Pages 设置是否正确

## 重要文件

- `.nojekyll` - 告诉 GitHub Pages 不要使用 Jekyll 处理
- `index.html` - 应用的入口文件
- base href 应该设置为 "/"（对于 username.github.io 格式）

## 故障排除

- **404 错误**：检查 GitHub Pages 是否已启用，分支选择是否正确
- **权限错误**：确认 SSH 密钥或使用 HTTPS + Personal Access Token
- **资源加载失败**：检查 base href 配置是否正确

