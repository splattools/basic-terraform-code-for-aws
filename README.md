# Basic Terraform Code for AWS

## 概要
このリポジトリは、AWSリソースをTerraformで管理するためのベーシックなコードサンプルを提供します。
各AWSリソースは独立したディレクトリで管理され、モジュール化された構造を持っています。
また、これらのリソースを組み合わせることで、完全なシステム構築も可能です。

## ディレクトリ構造
```
.
├── vpc/          # VPCネットワーク関連リソース
├── ec2/          # EC2インスタンス関連リソース
│   └── userdata/ # EC2用の初期化スクリプト
├── rds/          # RDSデータベース関連リソース
├── aurora/       # Aurora関連リソース
├── ecs/          # ECSクラスター関連リソース
├── elb/          # ロードバランサー関連リソース
├── s3/           # S3バケット関連リソース
│   └── policies/ # バケットポリシー用JSONファイル
├── sg/           # セキュリティグループ関連リソース
└── vpce/         # VPCエンドポイント関連リソース
```

## 各ディレクトリの標準構成
各リソースディレクトリは以下の標準的なファイル構成を持ちます：

- `main.tf` - プロバイダー設定とバックエンド設定
- `[resource].tf` - 各リソース固有の定義（例：vpc.tf, ec2.tf）
- `variables.tf` - 変数定義
- `terraform.tfvars` - 変数値の設定
- `.gitignore` - バージョン管理から除外するファイルの設定
- 外部ファイルディレクトリ
  - `userdata/` - EC2インスタンス用の初期化スクリプト
  - `policies/` - IAMポリシーやバケットポリシー用のJSONファイル

## コーディングルール
1. リソースの独立性と参照
   - 各ディレクトリは独立して動作可能な構成を維持
   - 他リソースの参照が必要な場合は、名前による参照を使用
   - 例：VPCのIDを参照する場合は、VPC名やタグによる参照を使用

2. リソース間の依存関係
   - 依存関係が必要な場合は、明示的に記述
   - データソース（data source）を使用して他リソースの情報を取得
   - 例：
     ```hcl
     data "aws_vpc" "selected" {
       tags = {
         Name = "main-vpc"
       }
     }
     ```

3. 変数の管理
   - すべての可変値は`variables.tf`で定義
   - 実際の値は`terraform.tfvars`で設定
   - 機密情報は`terraform.tfvars`でのみ管理（.gitignoreに含める）
   - 他リソースの参照に必要な値は変数として定義

4. 外部ファイルの管理
   - JSONファイル（ポリシー等）は専用ディレクトリで管理
     ```
     policies/
     ├── bucket-policy.json
     ├── iam-policy.json
     └── role-policy.json
     ```
   - シェルスクリプト（userdata等）は専用ディレクトリで管理
     ```
     userdata/
     ├── ec2_init.sh
     └── windows_init.ps1
     ```
   - ファイル読み込みには`file()`関数を使用
     ```hcl
     user_data = file("${path.module}/userdata/ec2_init.sh")
     ```

5. 明示的な設定管理
   - デフォルト値が存在する設定項目も明示的に指定
   - 暗黙的な設定を避け、すべての重要なパラメータを記述
   - 例：
     ```hcl
     resource "aws_instance" "example" {
       ami           = var.ami_id
       instance_type = var.instance_type
       
       # デフォルト値があっても明示的に指定
       monitoring                  = false
       disable_api_termination    = false
       instance_initiated_shutdown_behavior = "stop"
       
       root_block_device {
         # ストレージ関連も明示的に指定
         delete_on_termination = true
         encrypted            = true
         volume_size         = var.root_volume_size
         volume_type         = "gp3"
         iops               = 3000
         throughput         = 125
       }
       
       tags = var.tags
     }
     ```

6. リソース命名規則
   - すべてのリソースは適切なタグ付けを行う
   - リソース名は用途が分かる命名規則に従う
   - システム全体で一貫性のある命名規則を使用
   - 例：
     ```hcl
     tags = {
       Name = "${var.project}-${var.environment}-${var.resource_name}"
       Environment = var.environment
       Project = var.project
     }
     ```

7. セキュリティ考慮事項
   - セキュリティグループは最小権限の原則に従う
   - 機密情報はバージョン管理から除外
   - セキュリティ関連の設定は明示的に記述

## システム構築時の注意点
1. リソース間の依存関係
   - 依存関係を考慮した適用順序の管理
   - 例：VPC → セキュリティグループ → EC2/RDS の順

2. 環境別の設定
   - 環境ごとの変数値を適切に管理
   - 環境固有の設定は個別の`terraform.tfvars`で管理

## 使用方法
各ディレクトリで以下のコマンドを実行してリソースを管理します：

```bash
# 初期化
terraform init

# 実行計画の確認
terraform plan

# リソースの作成/更新
terraform apply

# リソースの削除
terraform destroy
```

## 前提条件
- Terraform >= 1.0.0
- AWS CLIのインストールと設定
- 適切なAWS認証情報の設定

## 注意事項
- 各環境（開発/ステージング/本番）に応じた`terraform.tfvars`を用意
- 本番環境への適用は十分なレビューと承認プロセスを経ること
- 定期的なコードレビューとベストプラクティスの更新を推奨
- システム全体の構築時は、リソース間の依存関係を十分に考慮すること
