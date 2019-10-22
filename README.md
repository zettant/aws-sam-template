# AWS SAM (Serverless Architecture Model)の開発支援ツール

SAMを用いてAWSシステムを記述、管理する際の各種コマンド実行手順をMakefileの形にまとめ、雛形として使えるようにした。

開発を進める際にSAMのテンプレートを編集する必要があるが、書き方は[ここ](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction)と[ここ](https://d1.awsstatic.com/webinars/jp/pdf/services/20190814_AWS-Blackbelt_SAM_rev.pdf)と[ここ](https://github.com/awslabs/serverless-application-model/tree/master/examples)を参照するといい。他のところにも情報は散らばっているが、多分一番参考になる。



## 前提・想定・前準備

- AWSアカウントは、開発用と本番用で別々のアカウントにする
- ```aws configure```コマンドで、~/.awsディレクトリの下にconfigとcredentialsファイルが作成されていること
  - SAMのローカルテスト環境を動かすために、sam-localという名前のダミープロファイル（中身はなんでもいい）を作成しておくこと
    - configには、```output = json```を記載しておく
  - 開発用（DEPLOY_ENV=dev）と本番用（DEPLOY_ENV=prod）のデプロイ用のプロファイルも作成しておくこと
  - gitでコードを管理するなら、プロファイル名はチームで統一しておいた方が良い
- 現時点では、Python3とGoのLambda実行環境を想定しているが、今後Nodeのテンプレートも増やしたい



## 使い方

#### 環境整備（最初の一回だけ）

1. Python3 および Python3-virtualenvをインストールしておく

2. システム開発しているプロジェクトのディレクトリに、このリポジトリをcloneする

   ```bash
   mkdir sample_proj
   cd sample_proj
   git clone https://github.com/zettant/aws-sam-template.git
   ```

3. 下記コマンドを実行し環境を準備する

   ```bash
   cd aws-sam-template
   make
   ```

   この結果、sample_projディレクトリにMakefileが生成（コピー）され、aws-sam-template/に必要なモジュールがインストールされる。もし、すでにMakefileがsample_projに存在する場合は、既存Makefileにaws-sam-template/common_mk/Makefileの内容を手動で追記する必要がある。

   なお、**内部のツールがそのディレクトリ名を前提としているため、*aws-sam-template/*というディレクトリ名は変更してはならない。**

   

ここまでの手順の結果、以下のようなディレクトリ構成になっているはずである。

```
sample_proj/
    Makefile
    aws-sam-template/
```



4. sample_proj/Makefileの```S3_TEMPLATE_BUCKET```にSAMテンプレートをアップロードする（CloudFormationで利用する）バケット名を設定する。バケット名はS3内でユニークでなければならないため、他と重複しないものにすること。



#### stackの作成

stackとはAWS CloudFormationのstackのことで、一連の機能群のことを指す。

1. 環境準備でMakefileが生成されたディレクトリ（上記の例だとsample_proj/）で下記コマンドを実行する

   ```bash
   make stack name=sample
   ```

   このコマンドで、sample-stackという名前のstackが生成され、sample-stackディレクトリが生成される。今後このディレクトリ配下のファイルを編集していく。

   現時点では、Python3とGo1.xのLambda実行環境を想定したテンプレートが含まれている。



ここまでの手順の結果、以下のようなディレクトリ構成になっているはずである。

```
sample_proj/
    Makefile
    aws-sam-template/
    sample-stack/
```



#### パラメータの編集

作成されたstackディレクトリの下にある、mk/ディレクトリのparams.mkの中身を編集する

- ```makefile
  PROFILE_DEV=yyyyyy
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



## aws-sam-templateの構成

- Makefile
  - 環境準備（dockerコンテナの取得やMakefileのコピー）を行うための機能を提供する
- common_mk/
  - SAMおよびCloudFormationを用いたテスト、デプロイなどを行うための基本機能を記述したMakefile群を格納している
  - params.mkとcustom.mkは案件ごとに書き換えが必要（[こちら](./common_mk/README.md)を参照）
- common_mk/template_sam/
  - stack作成時のテンプレート
  - このディレクトリ配下のファイル群がコピーされ、新しいstackが作られる



## Stackごとに変更が必要なファイルたち

some-stackというスタックを作ったと仮定する。以下のファイル群を変更していくことになる。（さらなる拡張が必要であればそれ以外のファイルやディレクトリを変更する）



- some-stack/mk/params.mk
  - awsプロファイル名を設定する（PROFILE_DEVとPROFILE_PROD）
  - そのほか何かあればここに記述する
- some-stack/mk/custom.mk
  - 次に説明するMakefileが呼んでいるcommon_mkディレクトリにある共通Makefileの機能を上書きたいときに記述する
- some-stack/Makefile
  - 必要な処理を書く（案件ごとに異なるはず）
  - ただし、前半部分は変更しないこと
- some-stack/template.yaml
  - システム構成の定義ファイル
  - CloudFormationの規約に従って記述する
- some-stack/event.json
  - Lambdaのローカルテスト時の入力情報を記述したもの
  - サンプルとして置いてあるが、適宜変更、追加する必要がある
- some-stack/sample_func-python3.7/app.py
  - サンプル用なのでディレクトリ名は適宜変更すれば良い
  - app.pyにLambdaのエントリポイント（lambda_handler関数）が定義されている
    - エントリポイントはtemplate.yamlに設定されているが、特に問題がない限り変更する必要はない
- some-stack/sample_func-python3.7/requirements.txt
  - Lambda関数で使うpythonモジュール群を列挙したファイル
- some-stack/sample_func-go1.x/main.go
  - サンプル用なのでディレクトリ名は適宜変更すれば良い
  - Lambda関数で使うgoのメインソース。適宜ソースファイルは追加、修正すればよい
- some-stack/tests/unit/*_tester.py
  - ユニットテスト用のコード



Lambdaのディレクトリ（初期はsample_func/ディレクトリのみ）は幾つでも増やして良い。その場合必ずtemplate.yamlにその分のエントリを追加する必要がある。


