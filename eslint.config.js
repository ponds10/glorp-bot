import js from "@eslint/js";
import eslintConfigPrettier from "eslint-config-prettier/flat";

export default [
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: "latest",
    },
    rules: {
      curly: ["error", "multi-line", "consistent"],
      "handle-callback-err": "off",
      "max-nested-callbacks": ["error", { max: 4 }],
      "max-statements-per-line": ["error", { max: 2 }],
      "no-console": "off",
      "no-empty-function": "error",
      "no-inline-comments": "error",
      "no-lonely-if": "error",
      "no-shadow": ["error", { allow: ["err", "resolve", "reject"] }],
      "no-var": "error",
      "no-undef": "off",
      "prefer-const": "error",
      yoda: "error",
    },
  },
  eslintConfigPrettier,
];
