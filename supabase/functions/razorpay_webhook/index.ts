import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

async function verifySignature(body: string, signature: string, secret: string) {
  const encoder = new TextEncoder();

  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signatureBytes = encoder.encode(signature);
  const signed = await crypto.subtle.sign("HMAC", key, encoder.encode(body));

  // Convert ArrayBuffer to hex string
  const signedHex = Array.from(new Uint8Array(signed))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  return signedHex === signature;
}

Deno.serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const webhookSecret = Deno.env.get("RAZORPAY_WEBHOOK_SECRET")!;
    const signature = req.headers.get("X-Razorpay-Signature");
    const body = await req.text();

    if (!signature) {
      return new Response("Missing signature", { status: 400 });
    }

    // --- VERIFY SIGNATURE ---
    const valid = await verifySignature(body, signature, webhookSecret);

    if (!valid) {
      return new Response("Invalid signature", { status: 400 });
    }

    // Parse Razorpay payload
    const payload = JSON.parse(body);
    const event = payload.event;

    if (event !== "payment.captured" && event !== "payment.authorized") {
      return new Response("Event ignored", { status: 200 });
    }

    const payment = payload.payload.payment.entity;

    const userId = payment.notes?.user_id;
    const months = Number(payment.notes?.months ?? 1);

    if (!userId) {
      return new Response("No user_id in payment notes", { status: 400 });
    }

    const now = new Date();

    // Check existing subscription
    const { data: existing } = await supabase
      .from("subscriptions")
      .select("period_end")
      .eq("user_id", userId)
      .eq("status", "active")
      .maybeSingle();

    let newExpiry: Date;

    if (existing && existing.period_end && new Date(existing.period_end) > now) {
      // Extend existing subscription
      const currentExpiry = new Date(existing.period_end);
      newExpiry = new Date(currentExpiry.getTime() + months * 30 * 24 * 60 * 60 * 1000);
    } else {
      // Start new subscription
      newExpiry = new Date(now.getTime() + months * 30 * 24 * 60 * 60 * 1000);
    }

    // Upsert subscription
    await supabase.from("subscriptions").upsert({
      user_id: userId,
      status: "active",
      period_start: now.toISOString(),
      period_end: newExpiry.toISOString(),
    });

    return new Response("Webhook processed", { status: 200 });

  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});
