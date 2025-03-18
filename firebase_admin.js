const admin = require('firebase-admin');

// サービスアカウントキーのパスを正しく指定してください
const serviceAccount = require('/Users/yoshihiro/SwiftProjects/GlobalChatDemo/globalchatdemo-ecd13-c2d5ee912ef8.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

module.exports = admin;
