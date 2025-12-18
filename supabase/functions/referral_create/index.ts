import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    // --- AUTH ---
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "No Authorization header" }), {
        status: 401,
      });
    }

    const token = authHeader.replace("Bearer ", "");
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
      { global: { headers: { Authorization: `Bearer ${token}` } } }
    );

    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: "Invalid or expired token" }), {
        status: 401,
      });
    }

    const userId = userData.user.id;

    // --- CHECK IF REFERRAL ALREADY EXISTS ---
    const { data: existing } = await supabase
      .from("referrals")
      .select("referral_code")
      .eq("user_id", userId)
      .maybeSingle();

    if (existing?.referral_code) {
      return new Response(JSON.stringify({ referral_code: existing.referral_code }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // --- GENERATE NEW UNIQUE REFERRAL CODE ---
    const newCode = crypto.randomUUID().slice(0, 8).toUpperCase();

    // --- INSERT ---
    const { error: insertError } = await supabase.from("referrals").insert({
      user_id: userId,
      referral_code: newCode,
    });

    if (insertError) {
      return new Response(JSON.stringify({ error: insertError.message }), {
        status: 500,
      });
    }

    return new Response(JSON.stringify({ referral_code: newCode }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});
