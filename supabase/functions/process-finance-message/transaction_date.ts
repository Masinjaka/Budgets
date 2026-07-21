import type { ModelResult } from "./types.ts";

export function anchorTransactionsToDate(
  result: ModelResult,
  targetDate: string,
  timezoneOffsetMinutes: number,
): ModelResult {
  const [year, month, day] = targetDate.split("-").map(Number);
  const offsetMilliseconds = timezoneOffsetMinutes * 60_000;
  return {
    ...result,
    extraction: {
      ...result.extraction,
      transactions: result.extraction.transactions.map((transaction) => {
        const source = new Date(transaction.occurred_at);
        const localClock = new Date(source.getTime() + offsetMilliseconds);
        const anchoredUtc = Date.UTC(
          year,
          month - 1,
          day,
          localClock.getUTCHours(),
          localClock.getUTCMinutes(),
          localClock.getUTCSeconds(),
          localClock.getUTCMilliseconds(),
        ) - offsetMilliseconds;
        return {
          ...transaction,
          occurred_at: new Date(anchoredUtc).toISOString(),
        };
      }),
      transfers: result.extraction.transfers.map((transfer) => ({
        ...transfer,
        occurred_at: anchoredDate(
          transfer.occurred_at,
          year,
          month,
          day,
          offsetMilliseconds,
        ),
      })),
    },
  };
}

function anchoredDate(
  occurredAt: string,
  year: number,
  month: number,
  day: number,
  offsetMilliseconds: number,
): string {
  const localClock = new Date(
    new Date(occurredAt).getTime() + offsetMilliseconds,
  );
  const value = Date.UTC(
    year,
    month - 1,
    day,
    localClock.getUTCHours(),
    localClock.getUTCMinutes(),
    localClock.getUTCSeconds(),
    localClock.getUTCMilliseconds(),
  ) - offsetMilliseconds;
  return new Date(value).toISOString();
}
