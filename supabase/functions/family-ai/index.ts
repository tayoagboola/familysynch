import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Anthropic from "npm:@anthropic-ai/sdk@0.24.3";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const anthropic = new Anthropic({
  apiKey: Deno.env.get("ANTHROPIC_API_KEY") ?? "",
});

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { message, history, activeContext, householdId, userId } =
      await req.json();

    // Build Supabase client with the user's auth token
    const authHeader = req.headers.get("Authorization") ?? "";
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    // ── Fetch family context ───────────────────────────────────────────────────
    const contextParts: string[] = [];

    const contexts = new Set<string>(activeContext ?? []);

    if (contexts.has("calendar")) {
      const { data: events } = await supabase
        .from("calendar_events")
        .select("title, start_time, end_time, assigned_to")
        .eq("household_id", householdId)
        .gte("start_time", new Date().toISOString())
        .order("start_time")
        .limit(20);

      if (events && events.length > 0) {
        const lines = events.map(
          (e: Record<string, string>) =>
            `- ${e.title} at ${new Date(e.start_time).toLocaleString()}`
        );
        contextParts.push(`UPCOMING CALENDAR EVENTS:\n${lines.join("\n")}`);
      }
    }

    if (contexts.has("tasks")) {
      const { data: tasks } = await supabase
        .from("tasks")
        .select("title, completed, due_date, priority, assigned_to")
        .eq("household_id", householdId)
        .eq("completed", false)
        .order("due_date", { ascending: true })
        .limit(20);

      if (tasks && tasks.length > 0) {
        const lines = tasks.map(
          (t: Record<string, string | boolean>) =>
            `- [${t.priority ?? "normal"}] ${t.title}${t.due_date ? ` (due ${new Date(t.due_date as string).toLocaleDateString()})` : ""}`
        );
        contextParts.push(`OPEN TASKS:\n${lines.join("\n")}`);
      }
    }

    if (contexts.has("grocery")) {
      const { data: items } = await supabase
        .from("grocery_items")
        .select("name, quantity, category")
        .eq("household_id", householdId)
        .eq("checked", false)
        .limit(30);

      if (items && items.length > 0) {
        const lines = items.map(
          (i: Record<string, string>) =>
            `- ${i.name}${i.quantity ? ` (${i.quantity})` : ""}${i.category ? ` [${i.category}]` : ""}`
        );
        contextParts.push(`GROCERY LIST:\n${lines.join("\n")}`);
      }
    }

    if (contexts.has("members")) {
      const { data: members } = await supabase
        .from("household_members")
        .select("display_name, role")
        .eq("household_id", householdId);

      if (members && members.length > 0) {
        const lines = members.map(
          (m: Record<string, string>) => `- ${m.display_name} (${m.role})`
        );
        contextParts.push(`HOUSEHOLD MEMBERS:\n${lines.join("\n")}`);
      }
    }

    // ── Build system prompt ───────────────────────────────────────────────────
    const systemPrompt = [
      "You are FamilyAI, a friendly and helpful AI assistant for a family household app called FamilySync.",
      "You help families stay organized, manage schedules, track tasks, and coordinate their daily lives.",
      "Be warm, concise, and practical. Use emojis sparingly but naturally.",
      "When referencing specific data from the family's context, be specific and helpful.",
      "If asked to add items or make changes, explain that you can suggest actions but the user needs to confirm them in the app.",
      "",
      contextParts.length > 0
        ? `Here is the current family data:\n\n${contextParts.join("\n\n")}`
        : "No family data context is currently active.",
    ].join("\n");

    // ── Build message history for Claude ─────────────────────────────────────
    type MessageRole = "user" | "assistant";
    interface HistoryMessage {
      role: MessageRole;
      content: string;
    }
    const claudeMessages: Anthropic.MessageParam[] = [
      ...(history as HistoryMessage[]).map((h) => ({
        role: h.role as MessageRole,
        content: h.content,
      })),
      { role: "user" as const, content: message },
    ];

    // ── Call Claude ───────────────────────────────────────────────────────────
    const response = await anthropic.messages.create({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 1024,
      system: systemPrompt,
      messages: claudeMessages,
    });

    const aiResponse =
      response.content[0].type === "text"
        ? response.content[0].text
        : "I couldn't process that. Please try again.";

    return new Response(JSON.stringify({ response: aiResponse }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("family-ai error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
