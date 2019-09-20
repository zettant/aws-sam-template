AWS SAM (Serverless Architecture Model)の開発支援ツール
====

SAMを用いてAWSシステムを記述、管理する際の各種コマンド実行手順をMakefileの形にまとめ、雛形として使えるようにした。



## 前提・想定・前準備

* AWSアカウントは、開発用と本番用で別々のアカウントにする
* ```aws configure```コマンドで、~/.awsディレクトリの下にconfigとcredentialsファイルが作成されていること
  * SAMのローカルテスト環境を動かすために、sam-localという名前のダミープロファイル（中身はなんでもいい）を作成しておくこと
  * 開発用（DEPLOY_ENV=dev）と本番用（DEPLOY_ENV=prod）のデプロイ用のプロファイルも作成しておくこと
  * gitでコードを管理するなら、プロファイル名はチームで統一しておいた方が良い
* 現時点では、Python3のLambda実行環境のみを想定しているが、今後NodeやGoのテンプレートも増やしたい



## 使い方

#### 環境整備（最初の一回だけ）

1. Python3 および Python3-virtualenvをインストールしておく

2. 下記コマンドを実行し環境を準備する

   ```bash
   make prepare
   ```



#### stackの作成

stackとはAWS CloudFormationのstackのことで、一連の機能群のことを指す。

1. 下記コマンドを実行する

   ```
   make stack name=sample runtime=python3.7
   ```

   このコマンドで、sample-stackという名前のstackが生成され、sample-stackディレクトリが生成される。今後このディレクトリ配下のファイルを編集していく。
   
   現時点では、Python3のLambda実行環境のみを想定しているが、今後NodeやGoのテンプレートも増やしたい。



#### パラメータの編集

作成されたstackディレクトリの下にある、mk/ディレクトリのparams.mkの中身を編集する

* ```makefile
  PROFILE_DEV=zettantdev
  PROFILE_PROD=xxxxxx
  PROFILE_LOCAL=sam-local
  ```

PROFILE_DEV、PROFILE_PRODはそれぞれ開発用、本番用のawsプロファイル名である。PROFILE_LOCALは変更する必要はない（ダミープロファイル名を変更したいなら変更する）



#### 構成ファイル（template.yaml）の編集とコードの開発

SAM (CloudFormation)の規約に従って編集し、コードを開発する。



## 環境変数とaws profile

環境変数DEPLOY_DEV=dev, prod, local  （環境変数設定を省略するとlocalになる）

common_mk/params.mkとenv.jsonで環境変数DEPLOY_DEVの値とawsプロファイル名を紐づける。

なお、awsプロファイルは、```aws configure```コマンドで作成でき、~/.aws/config および~/.aws/credentialsに設定が書き込まれる。



## 構成

* Makefile

  * 環境準備、stack作成などの機能を提供する

* common_mk/

  * SAMを用いたテスト、デプロイなどを行うための基本機能を記述したMakefile群を格納している
  * params.mkとcustom.mkは案件ごとに書き換えが必要（[こちら](./common_mk/README.md)を参照）

* common_mk/template_sam/

  * stack作成時のテンプレート
  * このディレクトリ配下のファイル群がコピーされ、新しいstackが作られる




## Stackごとに変更が必要なファイルたち
some-stackというスタックを作ったと仮定する。以下のファイル群を変更していくことになる。（さらなる拡張が必要であればそれ以外のファイルやディレクトリを変更する）



* some-stack/mk/params.mk
  * awsプロファイル名を設定する（PROFILE_DEVとPROFILE_PROD）
  * そのほか何かあればここに記述する
* some-stack/mk/custom.mk
  - 次に説明するMakefileが呼んでいるcommon_mkディレクトリにある共通Makefileの機能を上書きたいときに記述する
* some-stack/Makefile
  * 必要な処理を書く（案件ごとに異なるはず）
  * ただし、前半部分は変更しないこと
* some-stack/template.yaml
  - システム構成の定義ファイル
  - CloudFormationの規約に従って記述する
* some-stack/event.json
  * Lambdaのローカルテスト時の入力情報を記述したもの
  * サンプルとして置いてあるが、適宜変更、追加する必要がある
* some-stack/sample_func-xxx/app.py
* sample_funcのディレクトリはLambda用のディレクトリで、xxxのところは、python3.7/go1.x/nodejs10.xのいずれかが入り、runtimeの種類を表している。サンプル用なのでディレクトリ名は適宜変更すれば良い
  * app.pyにLambdaのエントリポイント（lambda_handler関数）が定義されている
    * エントリポイントはtemplate.yamlに設定されているが、特に問題がない限り変更する必要はない
* some-stack/sample_func-python3.7/requirements.txt
  - Lambda関数で使うpythonモジュール群を列挙したファイル (runtimeがpythonの場合のみ)
* some-stack/tests/unit/*_tester.py
  * ユニットテスト用のコード



Lambdaのディレクトリ（初期はsample_func/ディレクトリのみ）は幾つでも増やして良い。その場合必ずtemplate.yamlにその分のエントリを追加する必要がある。



