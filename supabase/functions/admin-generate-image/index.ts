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
        const { prompt, referenceImage } = await req.json()

        if (!prompt) {
            throw new Error('Prompt is required')
        }

        const apiKey = Deno.env.get('GEMINI_API_KEY')
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is not set')
        }

        console.log(`Generating image with prompt: ${prompt}`)

        // Construct the API request
        // Assuming we are using the 'gemini-3-pro-image-preview' model which might be an Imagen wrapper or similar.
        // Since the exact endpoint for "gemini-3-pro-image-preview" image generation isn't standard public docs yet (it's likely Imagen 3),
        // we will try the standard Google Cloud / Vertex AI style or the AI Studio style.
        // For AI Studio (Generative Language API), image generation is often:
        // POST https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent
        // But usually image generation models have a different method.
        // Let's try the `predict` style or just assume it returns a base64 image in the content.

        // NOTE: For this prototype, if the model name implies Imagen 3, the endpoint might be different.
        // However, to ensure this works without 404s, I will implement a robust fetch that logs the response.

        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent?key=${apiKey}`;

        const body = {
            contents: [
                {
                    parts: [
                        { text: prompt }
                    ]
                }
            ],
            // If reference image is supported by this model for generation (e.g. style transfer), add it.
            // For now, we'll just send text to avoid 400s if the model doesn't support multimodal input for *generation*.
        };

        // If referenceImage is provided and we want to try sending it:
        if (referenceImage) {
            body.contents[0].parts.push({
                inline_data: {
                    mime_type: "image/jpeg", // Assuming jpeg or png
                    data: referenceImage // Base64 string
                }
            });
        }

        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });

        if (!response.ok) {
            const errText = await response.text();
            console.error('Gemini API Error:', errText);
            throw new Error(`Gemini API Error: ${response.status} ${response.statusText} - ${errText}`);
        }

        const data = await response.json();
        console.log('Gemini API Response:', JSON.stringify(data).substring(0, 200) + '...');

        // Parse the response to find the image.
        // If it's a text-to-image model, the image might be in `candidates[0].content.parts[0].inline_data` or similar.
        // Or if it returns a URL.

        let imageUrl = '';

        // Check for inline data (Base64)
        const part = data.candidates?.[0]?.content?.parts?.[0];
        const inlineData = part?.inlineData || part?.inline_data;

        if (inlineData) {
            const mimeType = inlineData.mimeType || inlineData.mime_type;
            const dataStr = inlineData.data;
            imageUrl = `data:${mimeType};base64,${dataStr}`;
        } else if (part?.text) {
            // Sometimes models return a URL in text? Unlikely for raw gen.
            // Or maybe it failed to gen image and returned text.
            console.warn('Model returned text instead of image data:', part.text);
            // Fallback or error
            throw new Error('Model returned text, not image. Check model capabilities.');
        } else {
            // Try to find "images" field if it's a different schema
            // ...
            throw new Error('No image data found in response');
        }

        return new Response(
            JSON.stringify({ success: true, imageUrl: imageUrl }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        console.error('Function Error:', error);
        // Fallback for demo if API fails (so user isn't blocked)
        const mockUrl = `https://placehold.co/600x400?text=Gen+Failed:+${encodeURIComponent(error.message.substring(0, 20))}`;

        return new Response(
            JSON.stringify({ success: false, imageUrl: mockUrl, error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } } // Return 200 so app doesn't crash, but with error msg
        )
    }
})
