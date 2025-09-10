const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { google } = require("googleapis");

// Truy cập secret từ environment variable
// Firebase sẽ inject secret vào process.env theo tên bạn đặt
const serviceAccountKeyJson = process.env.DRIVE_SERVICE_ACCOUNT_KEY;

if (!serviceAccountKeyJson) {
  console.error("DRIVE_SERVICE_ACCOUNT_KEY is not set!");
}

let serviceAccountKey;
try {
  serviceAccountKey = JSON.parse(serviceAccountKeyJson);
} catch (err) {
  console.error("Failed to parse DRIVE_SERVICE_ACCOUNT_KEY:", err);
}

exports.getDriveImages = onCall(async (request) => {
  const folderId = request.data.folderId;

  if (!folderId) {
    throw new HttpsError("invalid-argument", "Folder ID is required.");
  }

  try {
    const auth = new google.auth.GoogleAuth({
      credentials: serviceAccountKey,
      scopes: ["https://www.googleapis.com/auth/drive.readonly"],
    });

    const drive = google.drive({ version: "v3", auth });

    const res = await drive.files.list({
      q: `'${folderId}' in parents and mimeType contains 'image'`,
      fields: "files(id, name, webViewLink, thumbnailLink)",
    });

    const files = res.data.files;
    if (!files || files.length === 0) {
      return [];
    }

    return files.map((file) => ({
      name: file.name,
      webViewLink: file.webViewLink,
      thumbnailLink: file.thumbnailLink,
    }));
  } catch (error) {
    console.error("Error fetching images:", error);
    throw new HttpsError("unknown", "Failed to fetch images from Drive.");
  }
});
