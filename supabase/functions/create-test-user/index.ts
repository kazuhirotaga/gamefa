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
        const supabaseAdmin = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
            {
                auth: {
                    autoRefreshToken: false,
                    persistSession: false
                }
            }
        )

        const { email, password } = await req.json()

        // Check if user exists first to avoid error
        // Actually admin.createUser throws if exists?
        // Let's just try to create.

        const { data, error } = await supabaseAdmin.auth.admin.createUser({
            email: email,
            password: password,
            email_confirm: true
        })

        if (error) {
            // If user exists, try to update confirmation
            if (error.message.includes("already been registered")) {
                // Find user by email
                const { data: { users }, error: listError } = await supabaseAdmin.auth.admin.listUsers()

                if (listError) throw listError

                const existingUser = users.find(u => u.email === email)

                if (existingUser) {
                    const { data: updateData, error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
                        existingUser.id,
                        { email_confirm: true, password: password }
                    )
                    if (updateError) throw updateError

                    return new Response(
                        JSON.stringify(updateData),
                        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                    )
                }
            }
            throw error
        }

        return new Response(
            JSON.stringify(data),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }
})
