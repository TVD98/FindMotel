#!/bin/bash
set -e

echo "👉 Kiểm tra Node version..."
NODE_VERSION=$(node -v)
echo "   Hiện tại: $NODE_VERSION"

echo "👉 Xoá node_modules + package-lock.json..."
rm -rf node_modules package-lock.json

echo "👉 Xoá cache npm..."
npm cache clean --force

echo "👉 Đảm bảo dùng registry chuẩn npmjs..."
npm config set registry https://registry.npmjs.org/

echo "👉 Cài lại firebase-functions và firebase-admin..."
# Chọn version ổn định có v2/core và defineSecret
npm install firebase-functions@5.1.1 firebase-admin@latest googleapis@latest --force

echo "👉 Kiểm tra exports v2/core..."
EXPORTS=$(node -e 'const c=require("firebase-functions/v2/core"); console.log(Object.keys(c));' || echo "error")
echo "   Exports: $EXPORTS"

HAS_SECRET=$(node -e 'const c=require("firebase-functions/v2/core"); console.log(!!c.defineSecret);')
if [[ "$HAS_SECRET" == "true" ]]; then
    echo "✅ defineSecret tồn tại trong v2/core!"
else
    echo "⚠️ defineSecret không tồn tại → fallback cài từ GitHub..."
    rm -rf node_modules/firebase-functions
    npm install github:firebase/firebase-functions --force
    echo "👉 Kiểm tra lại exports core sau khi cài GitHub..."
    node -e 'const c=require("firebase-functions/v2/core"); console.log(Object.keys(c)); console.log("defineSecret:", !!c.defineSecret);'
fi

echo "👉 Kiểm tra phiên bản firebase-functions cuối cùng..."
npm ls firebase-functions
