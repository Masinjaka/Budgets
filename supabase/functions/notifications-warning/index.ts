import { SignJWT, importPKCS8 } from "npm:jose@5.2.2";

type WarningPayload = {
  user_id: string;
  tokens: string[];
  level: "warning" | "exceeded";
  category?: string | null;
  amount?: string | null;
  amount_spent?: string | null;
};

const PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") ?? "";
const CLIENT_EMAIL = Deno.env.get("FIREBASE_CLIENT_EMAIL") ?? "";
const PRIVATE_KEY = (Deno.env.get("FIREBASE_PRIVATE_KEY") ?? "").replace(
  /\\n/g,
  "\n",
);
const CRON_SECRET = Deno.env.get("CRON_SECRET") ?? "";

async function getAccessToken(): Promise<string> {
  if (!PROJECT_ID || !CLIENT_EMAIL || !PRIVATE_KEY) {
    throw new Error("Missing Firebase service account environment variables.");
  }

  const now = Math.floor(Date.now() / 1000);
  const key = await importPKCS8(PRIVATE_KEY, "RS256");
  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(CLIENT_EMAIL)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`OAuth token error: ${response.status} ${errorText}`);
  }

  const data = await response.json();
  return data.access_token as string;
}

async function sendMessage(
  accessToken: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<Response> {
  return fetch(
    `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`,
    {
      method: "POST",
      headers: {
        authorization: `Bearer ${accessToken}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
        },
      }),
    },
  );
}

Deno.serve(async (req: Request) => {
  if (CRON_SECRET) {
    const providedSecret = req.headers.get("x-cron-secret");
    if (providedSecret !== CRON_SECRET) {
      return new Response("Unauthorized", { status: 401 });
    }
  }

  const payload = (await req.json()) as WarningPayload;
  if (!payload?.tokens?.length) {
    return new Response(JSON.stringify({ sent: 0 }), {
      headers: { "content-type": "application/json" },
    });
  }

  const accessToken = await getAccessToken();
  const category = payload.category ?? "un budget";
  const title =
    payload.level === "exceeded"
      ? "Budget dépassé"
      : "Budget bientôt épuisé";
  const body =
    payload.level === "exceeded"
      ? `Vous avez dépassé ${category}.`
      : `Vous êtes proche de dépasser ${category}.`;

  let sent = 0;
  for (const token of payload.tokens) {
    const response = await sendMessage(accessToken, token, title, body, {
      type: "warning",
      level: payload.level,
      category: payload.category ?? "",
      amount: payload.amount ?? "",
      amount_spent: payload.amount_spent ?? "",
    });
    if (response.ok) {
      sent += 1;
    }
  }

  return new Response(JSON.stringify({ sent }), {
    headers: { "content-type": "application/json" },
  });
});
