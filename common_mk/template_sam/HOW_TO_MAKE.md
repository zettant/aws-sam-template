# Makefileの使い方

このディレクトリに含まれているMakefileを用いれば、環境構築、テスト、デプロイが簡単に実施できる。基本機能は、../common_mk/に実装されているが、案件ごとに独自の処理が必要になるため、Makefileを適宜編集する。また必要に応じて、../common_mk/の下にある**params.mk**および**custom.mk** も編集しておく必要がある。



このMakefileは、同じディレクトリに設置されるtemplate.yaml（SAMの設定ファイル）に基づいて機能する。したがって、まずはstackの内容をtemplate.yamlに記述する必要がある。



## 環境構築とprofile名の設定

最初の一回だけ実施する。

stack内に複数のlambdaを設置する場合はそれぞれの環境を構築するように、prepareの中を編集する。

テストに必要なモジュールもインストールする。

```bash
make prepare
```

構築した環境をすべて削除するには以下のようにする。

```bash
make dist-clean
```

awsプロファイル名をmk/params.mkに記載する。デフォルトでは下記のようになっているので、dev（開発用）、prod（本番用）のawsアカウントに対応するプロファイル名を記載する。

```makefile
PROFILE_DEV=yyyyy
PROFILE_PROD=xxxxxx
PROFILE_LOCAL=sam-local
```

なお、local (ローカルテスト用）のsam-localは、ダミーのawsプロファイルである（これも```aws configure``で作成しておくこと。



## Lambdaを単独でローカルテストする

Lambda単体のテストを行うためには、event.jsonも編集する（入力を与えるための設定ファイル）

```bash
make lambda-test
```

なお、Makefile内の```make lambda-local-test func=XXXX```のXXXXの部分をtemplate.yamlのResource名にすればそのLambdaをテストできる。



## localstackを立ち上げる

ローカルでのテストのために、localstackのDockerコンテナを起動する。この時にtemplate.yamlに従ってDynamoDBのテーブルも作成する。

```bash
make start-localstack
```

Dockerコンテナを終了する場合は、以下のようにする。

```bash
make stop-localstack
```

S3を使いたい場合は、別途S3バケットをlocalstack上に作成する必要がある。以下のコマンドで作成できる。

```bash
make create-s3bucket-local bucket=<BUCKET_NAME>
```



## API GW+Lambdaをローカルに立ち上げる

専用のDockerコンテナを立ち上げる。フォアグラウンドで立ち上がるようになっているので、別ターミナルで実行する。localstackが立っているので無駄ではあるが、samの枠組みを利用した方が簡単である。

```bash
make start-api
```



## テストコード（pytest）を実行する

tests/unit/の下のテストコード群を実行する。（実行したい項目を追加したければ、本Makefileのapi-testのところに追記する）

```bash
make api-test
```



## パッケージ作成とデプロイ

実環境にデプロイするためには、パッケージ作成とデプロイのコマンドを、環境変数(DEPLOY_ENV)付きで実行する。なお標準では、環境変数の取りうる値は"prod"と"dev"であり、この環境変数の値に応じてawsのプロファイル（Makefile内でのPROFILE変数）が決まる。

なお、CloudFormationのstack名には、ディレクトリ名が適用される。



#### パッケージ作成

```bash
DEPLOY_ENV=dev make package
```

パッケージは、S3にアップロードされる。この後に実行するデプロイでは、CloudFormationがS3からパッケージを取得して、各機能をデプロイする。

※ localstackはCloudFormationも模擬できるはずなのだが、うまく動かない。（S3へのパッケージのアップロードで失敗してしまう）



#### デプロイ

```bash
DEPLOY_ENV=dev make deploy
```

コマンドは終了してもデプロイ完了までに少し時間がかかる。AWSコンソールのCloudFormationの画面を見れば、デプロイの結果が表示される。



#### テストコード（pytest）を実行する

ローカルのテストと同じtests/unit/の下のテストコード群を、aws環境向けに実行する。

```bash
DEPLOY_ENV=dev make api-test
```



## 削除デプロイ

危険なので、DEPLOY_ENV=prodでは使えないようにしているが（common_mk/deploy.mk）、stackの全機能をawsから削除することもできる。

```bash
DEPLOY_ENV=dev make delete-stack
```

