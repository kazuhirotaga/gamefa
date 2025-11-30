
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = "https://tmrgsijuvyhzymaogbag.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmdzaWp1dnloenltYW9nYmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDUzMTYsImV4cCI6MjA3OTk4MTMxNn0.wp0LpAsqux-xk0iIBScd-u3FyFxqWKOT5z8UmboSHiI";

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function main() {
    console.log("--- Verifying Battle Action Stats Update ---");

    // 1. Login
    const { data: { user }, error: loginError } = await supabase.auth.signInWithPassword({
        email: "real.quest.test.user@gmail.com",
        password: "password123",
    });

    if (loginError) {
        console.error("Login failed:", loginError);
        return;
    }
    console.log("Logged in as:", user?.id);

    // 2. Get Initial Stats
    const { data: initialProfile, error: profileError } = await supabase
        .from("users")
        .select("exp, coins")
        .eq("id", user?.id)
        .single();

    if (profileError) {
        console.error("Failed to get profile:", profileError);
        return;
    }
    console.log("Initial Stats:", initialProfile);

    // 3. Call Battle Action (Loop until win to verify update)
    let won = false;
    let attempts = 0;

    while (!won && attempts < 10) {
        attempts++;
        console.log(`\nAttempt ${attempts}: Calling battle-action...`);

        const { data: result, error: funcError } = await supabase.functions.invoke("battle-action", {
            body: {
                userId: user?.id,
                battleId: "test-battle",
                action: "attack",
                targetId: "test-target"
            }
        });

        if (funcError) {
            console.error("Function call failed:", funcError);
            break;
        }

        console.log("Battle Result:", result.isWin ? "WIN" : "LOSE");

        if (result.isWin) {
            won = true;
            console.log("Rewards:", result.rewards);
        }
    }

    if (!won) {
        console.log("Could not trigger a win after 10 attempts. Verification inconclusive.");
        return;
    }

    // 4. Get Updated Stats
    const { data: updatedProfile, error: updatedProfileError } = await supabase
        .from("users")
        .select("exp, coins")
        .eq("id", user?.id)
        .single();

    if (updatedProfileError) {
        console.error("Failed to get updated profile:", updatedProfileError);
        return;
    }
    console.log("Updated Stats:", updatedProfile);

    // 5. Verify Increase
    const expDiff = updatedProfile.exp - initialProfile.exp;
    const coinsDiff = updatedProfile.coins - initialProfile.coins;

    console.log(`\nEXP Gained: ${expDiff}`);
    console.log(`Coins Gained: ${coinsDiff}`);

    if (expDiff === 50 && coinsDiff === 100) {
        console.log("✅ SUCCESS: Stats updated correctly.");
    } else {
        console.error("❌ FAILURE: Stats did not update as expected.");
    }
}

main();
