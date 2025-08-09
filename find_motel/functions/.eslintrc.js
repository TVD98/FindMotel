module.exports = {
  root: true,
  env: {
    es6: true, // Thêm dòng này để hỗ trợ ES6+
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "quotes": ["error", "double"],
    "max-len": "off",
  },
  // Thêm phần parserOptions này
  parserOptions: {
    ecmaVersion: 2017,
  },
};
