const functions = require("firebase-functions");
const {google} = require("googleapis");

// Cấu hình Service Account Key
// Tải file JSON lên môi trường biến của Firebase Functions
// hoặc lưu trữ trong một file tạm thời an toàn
const serviceAccountKey = {
  "type": "service_account",
  "project_id": "findmotel-299a5",
  "private_key_id": "648ebf502a392a6ece8a946ea6fd0273a4f05610",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDETKOR5UqSM7ep\nY2I9pvtFr69ffjnwPHpIt/VM8A5brlBX8IA8ZZdK111RR7Yxr07pLMFqWb8lZzQq\naqVwE6vaOFlBbZ96wmkS/di8JH8fklld6SraG6ai3LhD9Am6YT46tBoVZn26cqe/\nXonAbMtzDDRjWEMIvBPvVpCHRyeXX0G0pjUqNUJFtMVEJpiKiZfrB0HWTzHLWEM1\n08x6ztMHfXdojZQjKBQkTfhA2m3/DLeYkqGCTL1oZn+OhMBy1tKwxl1+g/FuMBJe\nF0aEvo8HCUUr9MNyKb7brULehsRWaTGNoS1+iRCCgtY5FpHXBQxkwfuHNtHnIPAA\nygkYQMPNAgMBAAECggEAPlzMsFqEbNsyU4WH3edRN6vfTrqmxHwqKzUKIMW5AgZo\nbu+whb+Op4+xDVP3fWRg8PIvhk55y/O0Hm+gHHGbbKnvLTqa6mCeChMMSoVbv5d6\nfbvISd9z+pSdk7URbB1drD+wc7EKa3PmeAUcRT4rCmNLt24AaeN6f9Rj+R4xZUSm\nkihYSELYsfKMuZOJYWjJQtaO9IfGDcwyz/nbxdYLftzVXOlUIy/0Z76a/K9fSRB7\nuGogV3D5jT6c9aBtKvpWm6gCrd4cCbpftTGtQG8PsgeRLvl72UZ37hyDFjt783k4\nCapZY3huTQRc9Ky7LJ7auwM9uP+Y2T1who0JfnDV7wKBgQDy2ZoUqx2eXc14tntE\nhW555+QV+GgEJtE5FHwnWfibFxex2I5/qtRxwziUx2FhZju6ClSaxww4DC88zLmd\nlrOq8ttM++8lOCRyQk8Gqpfs7J30BgdxgT7UQCFK0KIkBuTPHhOX8I3KWcXxAqcu\nc28pxKYFjv0j79SZXw1JoMIxWwKBgQDO7b/+VPdT+ZG50pbAiQLDhX27FaX635YQ\nO5wY+x3ABX4h9F50xM3VLQraxMwZmz9h/LUmGLzPktfTf1/MX7/DTje2Ao/0U9H6\neVjI2RurjR2Ad5eY9pm2xLtC7mpgDfFXc3oLveyYkJDaWu0TUN8LtnTvUihIf7CA\nQ8SBgOV/9wKBgFW5VliBZr0mY4d+8thnOW4y2yKeQylkAmrhvkmtysIETsrqpLKQ\nPNnDjc+G6esVyXOMffz80mVed7ZAliz4q4dmnt7395ztyn/CxF6YDXUGuWMQVcRN\nWT5XPOlJ6FJLVK1/8m6p7YNGWUcQJq+Q8+aMkgZYSSdMW4GgOfKJmsMNAoGBAJB6\nU3kCXgWV1PeHX5ZikzlstRKw1MjK333KAP04J9dwfla6xlCFMKnM3y1MBq1CRgjm\nZpyI3RuZDXQwFPUfTUbSD/fW5ifTdmKJ40GoxLcMujJ+TayRUVXZGl5rFH6ofX9v\nsyELpGwJU/oBTlIUPwdwh0ipdlLYRKXpqwQ4uQSVAoGBAMBiElohxQGg5f0Gj7Dg\nu02g5reL6tUDZRoAq+EGX898Iuo9bJFEdxXzP5bwlgT5HyuKew1zHdNPQtW0IvYL\n48hVXuvtR8sGU/kNwPk/I/i4sVQ/G//fOkfV9ZRATJwm8Ij5AaCJkdyysFjmNXD2\nbG1M65rayfZHQzBzawgzQyD6\n-----END PRIVATE KEY-----\n",
  "client_email": "find-motel@findmotel-299a5.iam.gserviceaccount.com",
  "client_id": "101578558108334719528",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/find-motel%40findmotel-299a5.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com",
};

const auth = new google.auth.GoogleAuth({
  credentials: serviceAccountKey,
  scopes: ["https://www.googleapis.com/auth/drive.readonly"],
});

exports.getDriveImages = functions.https.onCall(async (data, context) => {
  const folderId = data.folderId;

  if (!folderId) {
    throw new functions.https.HttpsError("invalid-argument", "Folder ID is required.");
  }

  try {
    const drive = google.drive({version: "v3", auth});

    // Lấy danh sách files ảnh trong folder
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
    throw new functions.https.HttpsError("unknown", "Failed to fetch images from Drive.");
  }
});
