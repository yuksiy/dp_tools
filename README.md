# dp_tools

## 概要

Windows DiskPart を非対話的に使用するためのラッパースクリプト

## 使用方法

* 以下のコマンドはすべて「管理者として実行」した「コマンド プロンプト」から実行する必要があります。

### dp_list.bat

    ディスクの一覧を表示します。
    dp_list.bat disk

    指定したディスクのパーティションの一覧を表示します。
    dp_list.bat partition ディスク番号

    ボリュームの一覧を表示します。
    dp_list.bat volume

### dp_assign.bat

    ボリュームにドライブ文字を割り当てます。
    dp_assign.bat letter ボリュームラベル ドライブ文字

    ボリュームにマウントポイントパスを割り当てます。
    dp_assign.bat mount ボリュームラベル マウントポイントパス

### dp_remove.bat

    ボリュームからドライブ文字を削除します。
    dp_remove.bat letter ボリュームラベル ドライブ文字

    ボリュームからマウントポイントパスを削除します。
    dp_remove.bat mount ボリュームラベル マウントポイントパス

### その他

* 上記で紹介したツール、および本パッケージに含まれるその他のツールの詳細については、各ファイルのヘッダー部分を参照してください。

## 動作環境

OS:

* Windows

依存パッケージ または 依存コマンド:

* [common_bat](https://github.com/yuksiy/common_bat)

## インストール

「*.bat」ファイルを希望のインストール先ディレクトリにコピーしてください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/dp_tools>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/dp_tools/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2004-2017 Yukio Shiiya
