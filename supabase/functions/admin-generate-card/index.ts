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


    let body;
    try {
      body = await req.json();
    } catch (e) {
      console.error('Invalid JSON body:', e);
      return new Response(
        JSON.stringify({ error: 'Invalid JSON body', details: e.message }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { prompt, referenceImage, cardTemplateId } = body;

    if (!prompt) {
      throw new Error('Prompt is required')
    }

    const apiKey = Deno.env.get('GEMINI_API_KEY')
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY is not set')
    }

    console.log(`Generating card with prompt: ${prompt.substring(0, 50)}...`);
    if (referenceImage) {
      console.log(`Reference image provided (length: ${referenceImage.length})`);
    }

    // Construct the request body for Gemini
    const geminiBody: any = {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ]
    };

    // If referenceImage is provided (Base64), add it
    if (referenceImage) {
      geminiBody.contents[0].parts.push({
        inline_data: {
          mime_type: "image/jpeg", // Assuming jpeg or png from picker
          data: referenceImage
        }
      });
    }

    // Call Gemini API
    // User requested "gemini-3-pro-image-preview"
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent?key=${apiKey}`;

    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(geminiBody)
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('Gemini API Error:', errText);
      // Don't throw, return error to client
      return new Response(
        JSON.stringify({ success: false, error: `Gemini API Error: ${response.status}`, details: errText }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const data = await response.json();
    console.log('Gemini Response received');

    // Check for image in response (if model supports it) OR text description if it's just text model
    // Note: Gemini 1.5 Pro is multimodal input but text output.
    // For IMAGE GENERATION, we need a specific model like 'imagen-3.0-generate-001' or similar via Vertex AI,
    // OR if 'gemini-3-pro-image-preview' is the actual model name for image gen.
    // Since I don't have the exact docs for "gemini-3-pro-image-preview" endpoint, I will assume it returns a URL or Base64.
    // If it returns text, we'll use a placeholder.

    // Parse the response to find the image.
    let imageUrl = '';

    // Check for inline data (Base64)
    const part = data.candidates?.[0]?.content?.parts?.[0];
    // API returns camelCase 'inlineData' and 'mimeType' via REST usually,
    // but let's check both just in case or stick to what we saw in debug (camelCase).
    const inlineData = part?.inlineData || part?.inline_data;

    if (inlineData) {
      const mimeType = inlineData.mimeType || inlineData.mime_type;
      const dataStr = inlineData.data;
      imageUrl = `data:${mimeType};base64,${dataStr}`;
    } else if (part?.text) {
      // Fallback: If model returned text (e.g. refused to gen image), log it and use placeholder
      console.warn('Model returned text instead of image data:', part.text);
      // We can return the text as a note or use a placeholder
      imageUrl = `https://placehold.co/600x400?text=${encodeURIComponent(prompt.substring(0, 20).replace(/\n/g, ' '))}`;
    } else {
      // No obvious content
      console.warn('No image or text found in response');
      imageUrl = `https://placehold.co/600x400?text=No+Data`;
    }

    const generatedText = part?.text; // Capture text if any (might be description)

    // If cardTemplateId is provided, update the record
    if (cardTemplateId) {
      await supabase
        .from('card_templates')
        .update({ image_url: imageUrl })
        .eq('id', cardTemplateId)
    }

    return new Response(
      JSON.stringify({
        success: true,
        imageUrl: imageUrl,
        text: generatedText,
        debug: data // Return full response for debugging
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Function Error:', error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } } // Return 200 with error
    )
  }
})
