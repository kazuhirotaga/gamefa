import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { userId, battleId, action, targetId, cardId } = await req.json()

    // Mock Battle Logic
    // In a real app, we would fetch battle state from a `battles` table (not yet in schema, but implied)

    // 1. Calculate Damage
    // Mock damage calculation
    const damage = Math.floor(Math.random() * 20) + 10
    const enemyDamage = Math.floor(Math.random() * 15) + 5

    // 2. Update User HP (Mock)
    // We would update the `users` table here

    // 3. Determine Outcome
    const isWin = Math.random() > 0.2 // 80% chance to win for prototype

    let rewards = {}
    if (isWin) {
      rewards = {
        exp: 50,
        coins: 100
      }
      // Update user stats
      await supabase.rpc('increment_user_stats', {
        user_uuid: userId,
        exp_gain: 50,
        coin_gain: 100
      })
    }

    return new Response(
      JSON.stringify({
        success: true,
        damageDealt: damage,
        damageTaken: enemyDamage,
        isWin: isWin,
        rewards: rewards
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
