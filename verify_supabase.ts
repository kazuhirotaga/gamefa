import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = 'https://tmrgsijuvyhzymaogbag.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmdzaWp1dnloenltYW9nYmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDUzMTYsImV4cCI6MjA3OTk4MTMxNn0.wp0LpAsqux-xk0iIBScd-u3FyFxqWKOT5z8UmboSHiI';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function runTest() {
    console.log("--- Starting Supabase Verification ---");

    const email = `test_user_${Date.now()}@example.com`; // Unique email
    const password = 'password123';

    // 1. Test create-test-user Edge Function
    console.log(`\n1. Testing create-test-user with ${email}...`);
    const { data: createData, error: createError } = await supabase.functions.invoke('create-test-user', {
        body: { email, password }
    });

    if (createError) {
        console.error("❌ create-test-user failed:", createError);
        return;
    }
    console.log("✅ create-test-user success:", createData);

    // 2. Test Login
    console.log("\n2. Testing Login...");
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password
    });

    if (authError) {
        console.error("❌ Login failed:", authError);
        return;
    }
    console.log("✅ Login success. User ID:", authData.user.id);

    // 3. Test DB Sync (Upsert to public.users)
    console.log("\n3. Testing DB Sync (Upsert to public.users)...");
    const { error: upsertError } = await supabase.from('users').upsert({
        id: authData.user.id,
        display_name: 'Test User',
        email: email
    });

    if (upsertError) {
        console.error("❌ DB Upsert failed:", upsertError);
        // Don't return, try to read anyway
    } else {
        console.log("✅ DB Upsert success");
    }

    // 4. Test DB Read
    console.log("\n4. Testing DB Read...");
    const { data: userData, error: readError } = await supabase
        .from('users')
        .select('*')
        .eq('id', authData.user.id)
        .single();

    if (readError) {
        console.error("❌ DB Read failed:", readError);
    } else {
        console.log("✅ DB Read success:", userData);
        if (userData.email === email) {
            console.log("   (Email column verified)");
        } else {
            console.warn("   ⚠️ Email column mismatch or missing");
        }
    }

    // 5. Test Check-in Edge Function
    console.log("\n5. Testing Check-in Edge Function...");
    const { data: checkinData, error: checkinError } = await supabase.functions.invoke('checkin', {
        body: {
            userId: authData.user.id,
            latitude: 35.6895,
            longitude: 139.6917,
            facilityId: 'test-facility'
        }
    });

    if (checkinError) {
        console.error("❌ Check-in failed:", checkinError);
    } else {
        console.log("✅ Check-in success:", checkinData);
    }

    console.log("\n--- Verification Complete ---");
}

runTest();
