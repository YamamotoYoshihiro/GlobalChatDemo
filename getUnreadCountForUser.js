const admin = require('./firebase_admin');

/**
 * Firestore を使って、指定ユーザーの未読メッセージ数を取得する
 * @param {string} userId - ユーザーID
 * @returns {Promise<number>} - 未読数
 */
function getUnreadCountForUser(userId) {
  return admin.firestore().collection('messages')
    .where('toUser', '==', userId)
    .where('isRead', '==', false)
    .get()
    .then(snapshot => snapshot.size)
    .catch(err => {
      console.error("Firestore query error:", err);
      return 0;
    });
}

module.exports = { getUnreadCountForUser };
