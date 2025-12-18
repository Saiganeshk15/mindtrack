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
      {
        global: { headers: { Authorization: `Bearer ${token}` } }
      }
    );

    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: "Invalid or expired token" }), {
        status: 401,
      });
    }

    const userId = userData.user.id;

    // --- FETCH ALL REFERRAL USES ---
    const { data: uses, error: usesError } = await supabase
      .from("referral_uses")
      .select("id, referee_id, validated")
      .eq("referrer_id", userId);

    if (usesError) {
      return new Response(JSON.stringify({ error: usesError.message }), {
        status: 500,
      });
    }

    let validatedCount = 0;
    let pendingCount = 0;

    // For updating validated statuses
    const validatedIds: string[] = [];

    // --- PROCESS EACH REFERRAL ---
    for (const u of uses) {
      if (u.validated) {
        validatedCount++;
        continue;
      }

      // --- CHECK IF REFEREE HAS 7 VALID JOURNALS ---
      const { data: journals } = await supabase
        .from("journals")
        .select("id, word_count, created_at")
        .eq("user_id", u.referee_id)
        .gte("created_at", new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());

      if (journals && journals.length >= 7) {
        const allValid = journals.every(j => j.word_count >= 20);

        if (allValid) {
          validatedIds.push(u.id);
          validatedCount++;
          continue;
        }
      }

      pendingCount++;
    }

    // --- UPDATE VALIDATED REFERRALS ---
    if (validatedIds.length > 0) {
      await supabase
        .from("referral_uses")
        .update({ validated: true, validated_at: new Date().toISOString() })
        .in("id", validatedIds);
    }

    const total = validatedCount + pendingCount;

    // --- PREMIUM ELIGIBILITY ---
    const eligibleForPremium = validatedCount >= 10;

    return new Response(
      JSON.stringify({
        total_referrals: total,
        validated_referrals: validatedCount,
        pending_referrals: pendingCount,
        eligible_for_premium: eligibleForPremium,
      }),
      { headers: { "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});
