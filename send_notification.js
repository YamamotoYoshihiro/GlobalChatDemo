const apn = require('apn');
const { getUnreadCountForUser } = require('./getUnreadCountForUser');

// APNsのオプション設定
let options = {
  token: {
    key: "/Users/yoshihiro/SwiftProjects/GlobalChatDemo/AuthKey_JB86VKR96W.p8",  // AuthKeyのフルパス
    keyId: "JB86VKR96W",       // Apple Developerポータルで確認したKey ID
    teamId: "2K5YHZRZ49"       // Apple DeveloperポータルのMembershipから確認できるTeam ID
  },
  production: false  // デバッグ用: Sandboxの場合は false、本番ビルドなら true
};

let apnProvider = new apn.Provider(options);

// ここではテスト用に環境変数または固定値でデバイストークンを指定
let deviceToken = process.env.DEVICE_TOKEN || "d78d0480ae9b7d090b375829d394e3fce1823b9a6fbea40d9d936ab1e228f0cb";

/**
 * ユーザーにプッシュ通知を送る関数
 * @param {string} userId - 通知を送るユーザーのID（未読数取得のために利用）
 * @param {string} senderName - 送信者の名前（通知タイトルに表示）
 * @param {string} messageText - 送信するメッセージ本文（通知本文に表示）
 */
function sendPushNotification(userId, senderName, messageText) {
  // Firestoreなどからユーザーの未読数を取得
  getUnreadCountForUser(userId)
    .then(unreadCount => {
      // 未読数を badge に反映した通知ペイロードを作成
      let notification = new apn.Notification();
      // アプリのBundle IDを指定。Apple Developerポータルに登録したものと一致させる必要があります。
      notification.topic = "com.Yoshihiro.GlobalChatDemo";
      // 送信者名とメッセージ本文を動的に設定
      notification.alert = {
        title: `${senderName} からメッセージです`,
        body: messageText
      };
      notification.sound = "default";
      // Firestoreから取得した未読数をバッジとして設定
      notification.badge = unreadCount;
      
      // APNsへ通知を送信
      return apnProvider.send(notification, deviceToken);
    })
    .then(result => {
      console.log("送信結果:", result);
    })
    .catch(err => {
      console.error("送信エラー:", err);
    });
}

// 例：ユーザーID "user123" に対して、"Alice" からの通知を送信
sendPushNotification("user123", "Alice", "こんにちは！新しいメッセージがあります。");
