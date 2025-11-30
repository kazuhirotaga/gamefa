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

        const { userId, latitude, longitude, facilityId, paymentAmount, receiptImage } = await req.json()

        // 1. Validate inputs
        if (!userId || !latitude || !longitude) {
            throw new Error('Missing required fields')
        }

        // 2. Verify Receipt (Mock for now, replace with Gemini API call)
        let isVerified = false
        if (paymentAmount && paymentAmount >= 3000) {
            // TODO: Call Gemini API to verify receipt
            isVerified = true
        }

        // 3. Calculate Rewards
        // Mock logic: 1 card per 1000 yen
        const cardCount = Math.floor((paymentAmount || 0) / 1000) + 1
        console.log(`Card count calculated: ${cardCount}`)

        // 4. Grant Cards (Mock logic)
        // In a real app, we would query `region_card_limits` and `card_templates`
        // Here we fetch all templates and pick random ones
        const { data: allTemplates, error: templateError } = await supabase
            .from('card_templates')
            .select('id')

        if (templateError) {
            console.error('Template fetch error:', templateError)
            throw templateError
        }
        console.log(`Found ${allTemplates?.length} templates`)

        const templates = []
        for (let i = 0; i < cardCount; i++) {
            if (allTemplates && allTemplates.length > 0) {
                const randomIndex = Math.floor(Math.random() * allTemplates.length)
                templates.push(allTemplates[randomIndex])
            }
        }
        console.log(`Selected ${templates.length} templates to grant`)

        const newCards = []
        for (const template of templates || []) {
            console.log(`Granting template: ${template.id}`)
            const { data: card, error: cardError } = await supabase
                .from('user_cards')
                .insert({
                    user_id: userId,
                    template_id: template.id,
                    obtained_location: `POINT(${longitude} ${latitude})`
                })
                .select('*, card_templates(*)')
                .single()

            if (cardError) {
                console.error('Card insert error:', cardError)
            } else {
                newCards.push(card)
            }
        }
        console.log(`Successfully granted ${newCards.length} cards`)

        // 5. Record Check-in
        const { error: checkinError } = await supabase
            .from('checkins')
            .insert({
                user_id: userId,
                facility_id: facilityId,
                location: `POINT(${longitude} ${latitude})`,
                payment_amount: paymentAmount,
                is_verified: isVerified,
                cards_obtained: newCards.map(c => c.id)
            })

        if (checkinError) throw checkinError

        return new Response(
            JSON.stringify({ success: true, cards: newCards }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }
})
