export type TransactionType = "expense" | "income";

export type ExtractedTransaction = {
  title: string;
  description: string;
  amount: number;
  transaction_type: TransactionType;
  category_name: string;
  occurred_at: string;
  currency_code: string;
};

export type ExtractedCategory = {
  name: string;
  transaction_type: TransactionType;
  emoji: string;
  color: string;
};

export type ExtractedTransfer = {
  from_wallet_name: string;
  to_wallet_name: string;
  amount: number;
  occurred_at: string;
  currency_code: string;
  description: string;
};

export type ExtractionResult = {
  transactions: ExtractedTransaction[];
  transfers: ExtractedTransfer[];
  categories_to_create: ExtractedCategory[];
  message: string;
};

export type ModelResult = {
  extraction: ExtractionResult;
  raw: Record<string, unknown>;
  inputTokens?: number;
  outputTokens?: number;
  provider: string;
  model: string;
  billingTier: string;
};

export type AiContext = {
  currencyCode: string;
  categories: Record<string, unknown>[];
  presets: Record<string, unknown>[];
  history: Record<string, unknown>[];
  wallets: Record<string, unknown>[];
};

export const extractionSchema = {
  type: "object",
  properties: {
    transactions: {
      type: "array",
      items: {
        type: "object",
        properties: {
          title: { type: "string" },
          description: { type: "string" },
          amount: { type: "number" },
          transaction_type: {
            type: "string",
            enum: ["expense", "income"],
          },
          category_name: { type: "string" },
          occurred_at: { type: "string" },
          currency_code: { type: "string" },
        },
        required: [
          "title",
          "description",
          "amount",
          "transaction_type",
          "category_name",
          "occurred_at",
          "currency_code",
        ],
      },
    },
    categories_to_create: {
      type: "array",
      items: {
        type: "object",
        properties: {
          name: { type: "string" },
          transaction_type: {
            type: "string",
            enum: ["expense", "income"],
          },
          emoji: { type: "string" },
          color: { type: "string" },
        },
        required: ["name", "transaction_type", "emoji", "color"],
      },
    },
    transfers: {
      type: "array",
      items: {
        type: "object",
        properties: {
          from_wallet_name: { type: "string" },
          to_wallet_name: { type: "string" },
          amount: { type: "number" },
          occurred_at: { type: "string" },
          currency_code: { type: "string" },
          description: { type: "string" },
        },
        required: [
          "from_wallet_name",
          "to_wallet_name",
          "amount",
          "occurred_at",
          "currency_code",
          "description",
        ],
      },
    },
    message: { type: "string" },
  },
  required: ["transactions", "transfers", "categories_to_create", "message"],
} as const;
