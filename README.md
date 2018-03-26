# FadeScrollView
uGUIのScrollViewに於ける要素の透過処理

![fade](https://user-images.githubusercontent.com/17098415/37928624-591f90f4-3178-11e8-996f-b60da7d71b7a.gif)

※Unity2017.3.1p2で実装



# サンプルについて

- [Sample.unity](https://github.com/mao-test-h/FadeScrollView/blob/master/Assets/_MyContents/Scenes/Sample.unity)を参照



# 実装について

- 実装としてはScrollRectの要素側に設定されているシェーダーで対応している。
    - 該当するコードとしては[UI-FadeColumn.shader](https://github.com/mao-test-h/FadeScrollView/blob/master/Assets/_MyContents/Shaders/UI-FadeColumn.shader)を参照すること。

- なお、サンプルの方は要素にあるImageコンポーネントとTextコンポーネントでマテリアルを分ける形で実装してある。
    - 理由としてはImageとTextで同じマテリアルを用いると、思ったよりもTextが薄くなってしまったので見掛け調整のためにパラメータを分けてある。
