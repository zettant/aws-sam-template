Makefileたち
====

## 案件に応じてカスタマイズする必要があるもの

下記２つのファイルは、各stackディレクトリのmk/ディレクトリの下にコピーされるので、そこで編集する。

* template_sam/mk/params.mk
  - Makefile群で共通して使うパラメータ等を定義する
  - PROFILEおよびcloudformationによるデプロイに用いるS3バケット名の設定
  - このファイルは、環境に合わせて適宜編集する必要がある
* template_sam/mk/custom.mk
  - テンプレートだけでは実現できないことをやりたい時の拡張用
  - common.mkの最後に呼ばれる
  - 必要なければ編集しなくてもいい



## 共通のMakefile

common_mkディレクトリに配置される下記ファイルは、すべてのstackに共通の処理が記述されている。

* common.mk
  - Makefile群で共通して使うパラメータ等を定義する
* deploy.mk
  - aws (cloudformation) へのデプロイ機能を定義
* aws_local.mk
  - localstackを用いたローカルテスト用の機能を定義
* lambda_api.mk
  - LambdaおよびAPI Gatewayのローカルテスト用の機能を定義
* prepare.mk
  - 仮想環境など環境構築機能を定義
* test.mk
  - pytestを用いたLambda+API GWのユニットテストを行うための機能を定義
