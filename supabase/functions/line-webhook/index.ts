import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Validate Signature (Mock)
    // const signature = req.headers.get('x-line-signature')
    // if (!validateSignature(signature, body)) throw new Error('Invalid signature')

    const body = await req.json()
    const events = body.events

    for (const event of events) {
      if (event.type === 'message' && event.message.type === 'text') {
        const text = event.message.text

        if (text === 'ステータス') {
          // Reply with status (Mock)
          console.log('Status requested')
        }
      }
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
