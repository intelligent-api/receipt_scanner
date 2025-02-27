import "jsr:@supabase/functions-js/edge-runtime.d.ts";

interface TokenResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
}

async function getAccessToken(): Promise<string> {
  const clientId = Deno.env.get("CLIENT_ID");
  const clientSecret = Deno.env.get("CLIENT_SECRET");
  const tokenUrl = "https://api.intelligent-api.com/v1/token";

  if (!clientId || !clientSecret) {
    throw new Error("Missing required environment variables");
  }

  const response = await fetch(tokenUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      grant_type: "client_credentials",
      client_id: clientId,
      client_secret: clientSecret,
      scope: "document.expense",
    }),
  });

  if (!response.ok) {
    throw new Error(`Failed to get token: ${response.statusText}`);
  }

  const data: TokenResponse = await response.json();
  return data.access_token;
}

Deno.serve(async (req) => {
  try {
    //TODO: Confirm the user is authenticated here before generating a token
    const accessToken = await getAccessToken();

    return new Response(JSON.stringify({ token: accessToken }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
