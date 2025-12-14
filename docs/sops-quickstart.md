# SOPS + Age クイックスタート

## 1. インストール

```bash
# miseを使う場合
mise use sops@latest age@latest

# Homebrewを使う場合
brew install sops age
```

## 2. Age鍵の生成

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

出力例:
```
Public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

この公開鍵をメモしておく。

> **注意**: 既に鍵が存在する場合はエラーになる。
> 既存の鍵を確認: `cat ~/.config/sops/age/keys.txt`
> 新しく作り直す場合: `rm ~/.config/sops/age/keys.txt` してから再実行

## 3. 公開鍵と秘密鍵について

```
~/.config/sops/age/keys.txt の中身:

# created: 2024-12-14T12:00:00+09:00
# public key: age1xxxxxxxxxx...    ← 公開鍵（コミットOK）
AGE-SECRET-KEY-1XXXXXXXXXX...      ← 秘密鍵（絶対にコミットNG）
```

| 鍵の種類 | 形式 | 用途 | Gitにコミット |
|---------|------|------|--------------|
| 公開鍵 | `age1...` | 暗号化 | OK |
| 秘密鍵 | `AGE-SECRET-KEY-...` | 復号化 | **絶対NG** |

## 4. 環境変数の設定

```bash
echo 'export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"' >> ~/.zshrc
source ~/.zshrc
```

## 5. SOPS設定ファイルの作成

```bash
cat > .sops.yaml << 'EOF'
creation_rules:
  - path_regex: .*\.yaml$
    age: <ここに公開鍵を貼り付け>
EOF
```

> **`.sops.yaml` はコミットしてOK** - 公開鍵しか含まれていない

## 6. 暗号化を試す

```bash
# 平文ファイルを作成
cat > secrets.yaml << 'EOF'
api:
  key: my_secret_api_key
database:
  password: super_secret
EOF

# 暗号化
sops encrypt secrets.yaml > secrets.sops.yaml

# 確認
cat secrets.sops.yaml

# 復号化
sops decrypt secrets.sops.yaml

# 編集（復号→編集→暗号化を自動で行う）
sops secrets.sops.yaml
```

## 7. クリーンアップ

```bash
rm secrets.yaml
echo "secrets.yaml" >> .gitignore
```

## 8. CI/CD（GitHub Actions）

> **警告: 以下のワークフローはデモ・テスト用です**
>
> 本番環境では以下のパターンを使用しないでください:
> - CI/CDビルド中に秘密情報を復号化しない
> - 復号化したファイルをビルド成果物に含めない
> - 本番ではランタイム時の秘密情報注入を検討してください
>
> SOPSは主に「秘密情報をGitで安全に管理する」ためのツールです。
> アプリへの秘密情報の注入は、環境変数やSecrets Managerの利用を推奨します。

### 秘密鍵をGitHub Secretsに登録

1. `cat ~/.config/sops/age/keys.txt` で内容を確認
2. GitHubリポジトリ → Settings → Secrets and variables → Actions
3. New repository secret → Name: `SOPS_AGE_KEY` → Value: keys.txtの内容

### ワークフロー例

```yaml
name: Build

on:
  push:
    branches: [main]

env:
  SOPS_VERSION: "3.9.2"
  SOPS_SHA256: "8d939bb53fe3f05b12ba4bec85c562e843b7fccba9a867cbfa626caa06a39eed"
  AGE_VERSION: "1.2.0"
  AGE_SHA256: "2ae71cb3ea761118937a944083f057cfd42f0ef11d197ce72fc2b8780d50c4ef"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install SOPS
        run: |
          curl -LO "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"
          echo "${SOPS_SHA256}  sops-v${SOPS_VERSION}.linux.amd64" | sha256sum -c -
          sudo mv "sops-v${SOPS_VERSION}.linux.amd64" /usr/local/bin/sops
          sudo chmod +x /usr/local/bin/sops

      - name: Install Age
        run: |
          curl -LO "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz"
          echo "${AGE_SHA256}  age-v${AGE_VERSION}-linux-amd64.tar.gz" | sha256sum -c -
          tar xf "age-v${AGE_VERSION}-linux-amd64.tar.gz"
          sudo mv age/age /usr/local/bin/

      - name: Setup SOPS key
        run: |
          mkdir -p ~/.config/sops/age
          echo "${{ secrets.SOPS_AGE_KEY }}" > ~/.config/sops/age/keys.txt
          chmod 600 ~/.config/sops/age/keys.txt

      - name: Decrypt secrets
        run: |
          export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
          mkdir -p assets/config
          sops decrypt secrets.sops.yaml > assets/config/secrets.yaml

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'

      - run: flutter pub get
      - run: flutter build web

      - name: Cleanup
        if: always()
        run: |
          rm -f ~/.config/sops/age/keys.txt
          rm -f assets/config/secrets.yaml
```

## ファイル構成

```
project/
├── .sops.yaml              # SOPS設定（コミットOK）
├── secrets.sops.yaml       # 暗号化ファイル（コミットOK）
├── .github/workflows/
├── assets/config/          # 復号化先
├── lib/config/app_config.dart
└── .gitignore
```

## .gitignore

```gitignore
secrets.yaml
assets/config/secrets.yaml
keys.txt
```
