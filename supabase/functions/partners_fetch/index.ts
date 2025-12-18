// supabase/functions/partners_fetch/index.ts

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    const url = new URL(req.url);
    const lastUpdatedAt = url.searchParams.get("lastUpdatedAt");

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    let query = supabase
      .from("partners")
      .select("*")
      .order("sponsor_level", { ascending: false });

    if (lastUpdatedAt) {
      query = query.gt("updated_at", lastUpdatedAt);
    }

    const { data, error } = await query;

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
      });
    }

    return new Response(JSON.stringify({ partners: data }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});
