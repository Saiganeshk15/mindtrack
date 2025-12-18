import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    // --- AUTH ---
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
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
    let isPremium = false;
    let premiumSource = "none";
    let premiumExpiry: string | null = null;

    // --- CHECK PAID SUBSCRIPTIONS ---
    const nowISO = new Date().toISOString();

    const { data: sub } = await supabase
      .from("subscriptions")
      .select("status, period_end")
      .eq("user_id", userId)
      .eq("status", "active")
      .maybeSingle();

    if (sub && sub.period_end && sub.period_end > nowISO) {
      // Paid subscription active
      isPremium = true;
      premiumSource = "paid_subscription";
      premiumExpiry = sub.period_end;
    }

    // --- CHECK REFERRAL PREMIUM IF NO PAID PREMIUM ---
    if (!isPremium) {
      // Count validated referrals
      const { data: validatedRefs } = await supabase
        .from("referral_uses")
        .select("id, validated, validated_at")
        .eq("referrer_id", userId)
        .eq("validated", true);

      const validatedCount = validatedRefs?.length || 0;

      if (validatedCount >= 10) {
        // Referral premium starts from date of 10th validation
        const sorted = validatedRefs.sort(
          (a, b) => new Date(a.validated_at).getTime() - new Date(b.validated_at).getTime()
        );

        const tenth = sorted[9]; // 10th validated referral

        if (tenth) {
          const start = new Date(tenth.validated_at);
          const end = new Date(start.getTime() + 30 * 24 * 60 * 60 * 1000); // +30 days
          const endISO = end.toISOString();

          if (endISO > nowISO) {
            isPremium = true;
            premiumSource = "referral";
            premiumExpiry = endISO;
          }
        }
      }
    }

    return new Response(
      JSON.stringify({
        is_premium: isPremium,
        source: premiumSource,
        expires_at: premiumExpiry,
      }),
      { headers: { "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});
