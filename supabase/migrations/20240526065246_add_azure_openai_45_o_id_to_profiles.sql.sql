ALTER TABLE "public"."profiles" ADD column "azure_openai_45_o_id" text default ''::text;

-- PROFILES

CREATE OR REPLACE FUNCTION create_profile_and_workspace() 
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    username TEXT;
    display_name TEXT;
    image_url TEXT;
BEGIN
    -- Obtain profile details from the user data
    username := split_part(COALESCE(NEW.email, 'user' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 16)), '@', 1);
    display_name := COALESCE(NEW.raw_user_meta_data ->> 'name', '');
    image_url := COALESCE(NEW.raw_user_meta_data ->> 'picture', '');

    -- Create a profile for the new user
    INSERT INTO public.profiles(user_id, anthropic_api_key, azure_openai_35_turbo_id, azure_openai_45_o_id, azure_openai_45_turbo_id,
    azure_openai_45_vision_id, azure_openai_api_key, azure_openai_endpoint, google_gemini_api_key,
    has_onboarded, image_url, image_path, mistral_api_key, display_name, bio, openai_api_key, openai_organization_id, perplexity_api_key, profile_context, use_azure_openai, username)
    VALUES(
        NEW.id,
        '',
        '',
        'gpt-4o',
        '',
        '',
        '',
        '',
        '',
        TRUE,
        image_url,
        '',
        '',
        display_name,
        '',
        '',
        '',
        '',
        '',
        TRUE,
        username
    );

    INSERT INTO public.workspaces(user_id, is_home, name, default_context_length, default_model, default_prompt, default_temperature, description, embeddings_provider, include_profile_context, include_workspace_instructions, instructions)
    VALUES(
        NEW.id,
        TRUE,
        'Home',
        4096,
        'gpt-4o', -- Updated default model
        'You are a friendly, helpful AI assistant.',
        0.5,
        'My home workspace.',
        'AzureOpenai',
        TRUE,
        TRUE,
        ''
    );

    RETURN NEW;
END;
$$;
