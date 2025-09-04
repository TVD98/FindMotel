const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/v2/core");
const { google } = require("googleapis");

// Đặt tên secret giống với tên bạn đã lưu trên Firebase
const googleDriveApiKeySecret = defineSecret("DRIVE_SERVICE_ACCOUNT_KEY");

exports.getDriveImages = onCall(
  { secrets: [googleDriveApiKeySecret] },
  async (request) => {
    // Truy cập secret bằng tên biến môi trường đã định nghĩa
    const serviceAccountKey = JSON.parse(process.env.DRIVE_SERVICE_ACCOUNT_KEY);

    const auth = new google.auth.GoogleAuth({
      credentials: serviceAccountKey,
      scopes: ["https://www.googleapis.com/auth/drive.readonly"],
    });

    const folderId = request.data.folderId;

    if (!folderId) {
      throw new HttpsError("invalid-argument", "Folder ID is required.");
    }

    try {
      const drive = google.drive({ version: "v3", auth });

      const res = await drive.files.list({
        q: `'${folderId}' in parents and mimeType contains 'image'`,
        fields: "files(id, name, webViewLink, thumbnailLink)",
      });

      const files = res.data.files;
      if (!files || files.length === 0) {
        return [];
      }

      const imageLinks = files.map((file) => ({
        name: file.name,
        webViewLink: file.webViewLink,
        thumbnailLink: file.thumbnailLink,
      }));

      return imageLinks;
    } catch (error) {
      console.error("Error fetching images:", error);
      throw new HttpsError("unknown", "Failed to fetch images from Drive.");
    }
  }
);