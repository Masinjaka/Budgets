export const jsonResponse = (
  status: number,
  body: Record<string, unknown>,
) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });

export const errorResponse = (
  status: number,
  code: string,
  message: string,
) => jsonResponse(status, { error: { code, message } });
