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

    const refereeId = userData.user.id;

    // --- GET REFERRAL CODE FROM BODY ---
    const body = await req.json();
    const referralCode = body?.referral_code?.trim();

    if (!referralCode) {
      return new Response(JSON.stringify({ error: "Referral code is required" }), {
        status: 400,
      });
    }

    // --- CHECK REFERRAL CODE EXISTS ---
    const { data: referrerData, error: referrerError } = await supabase
      .from("referrals")
      .select("user_id")
      .eq("referral_code", referralCode)
      .maybeSingle();

    if (referrerError || !referrerData) {
      return new Response(JSON.stringify({ error: "Invalid referral code" }), {
        status: 404,
      });
    }

    const referrerId = referrerData.user_id;

    // --- PREVENT SELF REFERRAL ---
    if (referrerId === refereeId) {
      return new Response(JSON.stringify({ error: "You cannot refer yourself" }), {
        status: 400,
      });
    }

    // --- CHECK IF USER ALREADY USED A REFERRAL ---
    const { data: existingUse } = await supabase
      .from("referral_uses")
      .select("id")
      .eq("referee_id", refereeId)
      .maybeSingle();

    if (existingUse) {
      return new Response(JSON.stringify({ error: "Referral code already used" }), {
        status: 400,
      });
    }

    // --- CREATE REFERRAL PENDING VALIDATION ---
    const { error: insertError } = await supabase.from("referral_uses").insert({
      referrer_id: referrerId,
      referee_id: refereeId,
      validated: false,
    });

    if (insertError) {
      return new Response(JSON.stringify({ error: insertError.message }), {
        status: 500,
      });
    }

    return new Response(JSON.stringify({ 
      message: "Referral registered successfully. Pending validation after journaling." 
    }), {
      headers: { "Content-Type": "application/json" },
    });

  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});
