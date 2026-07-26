import assert from "node:assert/strict";
import test from "node:test";
import { convertAmountToMga } from "./currency_normalization.ts";

test("converts USD extracted by the AI to MGA", () => {
  const amount = convertAmountToMga(1000, "USD", {
    base: "MGA",
    rates: { USD: 0.0002 },
  });

  assert.equal(amount, 5000000);
});

test("keeps MGA amounts unchanged", () => {
  const amount = convertAmountToMga(1000, "MGA", {
    base: "MGA",
    rates: { USD: 0.0002 },
  });

  assert.equal(amount, 1000);
});

test("supports exchange-rate tables with a non-MGA base", () => {
  const amount = convertAmountToMga(1000, "USD", {
    base: "USD",
    rates: { MGA: 5000 },
  });

  assert.equal(amount, 5000000);
});

test("rejects currencies missing from the latest rates", () => {
  assert.throws(
    () => convertAmountToMga(1000, "EUR", {
      base: "MGA",
      rates: { USD: 0.0002 },
    }),
    (error: unknown) =>
      error instanceof Error &&
      error.message === "The exchange rate for EUR is currently unavailable.",
  );
});
