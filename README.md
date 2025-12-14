# Flutter + SOPS デモ

SOPSを使った秘密情報管理のデモリポジトリです。

---

## ⚠️ 警告

**このリポジトリはデモ・学習目的です。**

- CI/CDワークフローで**復号化した秘密情報がログに出力されます**
- 本番環境で使用する場合は、必ず該当箇所を削除してください

### 本番で使用する前に削除すべき箇所

1. **`.github/workflows/build.yml`** の復号化ステップ
   ```yaml
   # この部分を削除または修正
   - name: Decrypt secrets (デモ用 - 内容がログに出力されます)
     run: |
       sops decrypt secrets.sops.yaml  # ← ログに出力される
   ```

2. **`secrets.sops.yaml`** をダミーデータから実際の秘密情報に置き換え

---

## セットアップ

詳細は [docs/sops-quickstart.md](docs/sops-quickstart.md) を参照

```bash
# 1. ツールをインストール
mise use sops@latest age@latest

# 2. 鍵を生成
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# 3. 環境変数を設定
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# 4. 復号化
sops decrypt secrets.sops.yaml
```

## CI/CD

GitHub Secretsに `SOPS_AGE_KEY` を設定してください：

```bash
cat ~/.config/sops/age/keys.txt
# この内容をGitHub Secretsに登録
```

---

## ⚠️ 再度警告

**このリポジトリのCI/CDは復号化した内容をログに出力します。**

本番利用時は必ず修正してください。
