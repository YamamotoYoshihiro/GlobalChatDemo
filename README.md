<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
</head>
<body>
  <h1>GlobalChatDemo</h1>
  <p>
    GlobalChatDemo は、Firebase Firestore を利用した簡単な双方向チャット機能を実装したサンプルプロジェクトです。<br>
    このプロジェクトでは、各端末が固有の識別子 (<code>UIDevice.current.identifierForVendor</code>) を用いて送信者を自動判別し、1対1の会話ルームを動的に作成・管理する仕組みを実現しています。
  </p>

  <h2>主な機能</h2>
  <ul>
    <li><strong>双方向チャット:</strong> 送信メッセージは右側、受信メッセージは左側に表示。各メッセージには送信時刻が表示されます。</li>
    <li><strong>会話ルームの管理:</strong> 各チャットルームは参加者の識別子に基づき自動生成され、動的に管理可能です。例: 端末AとB、AとC、AとD、BとC など。</li>
    <li><strong>Firestore との連携:</strong> リアルタイム更新機能により、複数端末間でのメッセージ同期を実現。</li>
    <li><strong>デバイスIDによる送信者識別:</strong> ログイン機能は使用せず、各端末のデバイスIDで送信メッセージと受信メッセージを自動振り分け。</li>
  </ul>

  <h2>プロジェクト構成</h2>
  <ul>
    <li><strong>GlobalChatDemoApp.swift:</strong> アプリのエントリーポイント。Firebase の初期化を行います。</li>
    <li><strong>ContentView.swift:</strong> チャット画面 (ChatView) への入口ビュー。</li>
    <li><strong>ConversationsListView.swift:</strong> 端末が参加している会話ルームの一覧表示と、新規会話作成機能（1対1チャット）を実装。</li>
    <li><strong>ChatViewModel.swift:</strong> Firestore の「conversations」コレクション内の各チャットルームの「messages」サブコレクションを監視し、メッセージの送受信を管理。</li>
    <li><strong>ChatView.swift:</strong> 選択された会話ルームのチャット画面。メッセージの表示、入力、送信を実装。</li>
    <li><strong>ChatMessageView.swift:</strong> 個々のメッセージ表示用ビュー。送信者によって左右に配置し、タイムスタンプも表示。</li>
  </ul>

  <h2>セットアップ方法</h2>
  <h2>1. iOS アプリの登録</h2>
  <ul>
    <li>
      Firebase コンソールで iOS アプリを追加し、バンドルID（<code>com.Yoshihiro.GlobalChatDemo</code>）を設定します。
    </li>
  </ul>
  
  <h2>2. Firebase SDK の導入</h2>
  <ul>
    <li>
      Xcode の「File &gt; Add Packages...」を選択し、以下の URL を入力します：
      <br><code>https://github.com/firebase/firebase-ios-sdk</code>
    </li>
    <li>
      Firestore など、必要な Firebase 製品を選択してプロジェクトに追加してください。
    </li>
  </ul>
  
  <h2>3. アプリのビルド</h2>
  <ul>
    <li>
      <code>GlobalChatDemoApp.swift</code> 内で <code>FirebaseApp.configure()</code> が呼ばれているため、そのままビルド・実行すると同一の Firebase プロジェクトに接続されます。
    </li>
  </ul>
  
  <h2>4. アプリの設定</h2>
  <ul>
    <li>
      アプリ起動後、設定画面 (Settings) で自分のユーザー名を登録してください。これにより、あなたのユーザー名が <code>UserDefaults</code> に保存されます。
    </li>
    <li>
      チャットルーム作成時には、相手のユーザー名 (<strong>Partner User Name</strong>) と会話タイトル (<strong>Conversation Title</strong>) を入力します。
    </li>
    <li>
      <strong>Partner User Name</strong>に山本と入力いただければ、作成者と会話できます。入力された情報をもとに、内部ではたとえば「山本_ユーザー名」などのチャットルームIDが生成され、異なるユーザー間で同じチャットルームが共有されます。
    </li>
  </ul>
  
  <h2>5. プロジェクトの共有</h2>
  <ul>
    <li>
      このプロジェクトは GitHub に公開されています。以下の URL を用いてクローンしてください：
      <br><a href="https://github.com/YamamotoYoshihiro/GlobalChatDemo.git" target="_blank">https://github.com/YamamotoYoshihiro/GlobalChatDemo.git</a>
    </li>
    <li>
      クローン後、Xcodeでプロジェクトを開いてビルドすれば、チャットアプリが利用可能になります。
    </li>
    <li>
      使い方の説明が必要な場合は、オンラインミーティングで画面共有のデモも可能です。
    </li>
  </ul>

  <h2>動作確認</h2>
  <ul>
    <li>1対1チャット: 端末Aと端末B、または端末Aと端末Cなど、各端末で自動判別により同一の会話ルームでチャットが行えます。</li>
    <li>会話ルームの自動生成: 両者のデバイスIDを辞書順にソートして連結することで、同じ会話IDが生成されます。</li>
  </ul>

  <h2>今後の拡張</h2>
  <ul>
    <li>ユーザー認証機能の追加 (Firebase Authentication など)</li>
    <li>グループチャット機能の実装</li>
    <li>ペアリングやQRコード読み取りによる動的な相手取得</li>
    <li>プッシュ通知、既読管理、メッセージ編集・削除などの機能拡張</li>
  </ul>

  <h2>お問い合わせ</h2>
  <p>
    ご質問やフィードバックがありましたら、Issue または Pull Request をご利用ください。
  </p>
</body>
</html>
