-- Function to add expense and update budget atomically
-- logic adapted from add_expenses validation and subcategory handling

CREATE OR REPLACE FUNCTION add_expense_with_budget_check(
    amount text, 
    description text, 
    category_name text, 
    tr_type text,
    subcategories_amount jsonb DEFAULT NULL
)
RETURNS TABLE (success boolean, error_message text) AS $$
DECLARE
    main_category_id uuid;
    user_uuid uuid;
    expense_id uuid;
    subcategory_record RECORD;
    subcategory_id uuid;
    v_amount_numeric numeric;
BEGIN
    -- Retrieve user uuid based on the authenticated user
    user_uuid := auth.uid();

    -- Validate input
    IF user_uuid IS NULL THEN
        RETURN QUERY SELECT false, 'No authenticated user found';
    END IF;

    IF amount IS NULL OR TRIM(amount) = '' THEN
        RETURN QUERY SELECT false, 'Amount cannot be null or empty';
    END IF;

    IF category_name IS NULL OR TRIM(category_name) = '' THEN
        RETURN QUERY SELECT false, 'Category name cannot be null or empty';
    END IF;

    -- Parse amount
    BEGIN
        v_amount_numeric := CAST(amount AS numeric);
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Invalid amount format';
    END;

    -- Get the category id (assume it exists)
    SELECT id INTO main_category_id 
    FROM public.categories 
    WHERE name = category_name AND user_id = user_uuid
    LIMIT 1;

    -- Check if category was found
    IF main_category_id IS NULL THEN
        RETURN QUERY SELECT false, 'Category ' || COALESCE(category_name, 'NULL') || ' not found';
    END IF;

    -- Insert the main transaction
    INSERT INTO public.transaction(
        user_id, 
        description, 
        amount, 
        date, 
        category_id,
        transaction_type
    ) VALUES (
        user_uuid, 
        description, 
        v_amount_numeric, 
        NOW(), 
        main_category_id,
        tr_type::TransactionType
    ) RETURNING id INTO expense_id;

    -- *** BUDGET UPDATE LOGIC ***
    -- Check if a budget exists for this category and user, and update it
    -- explicitly cast amount_spent to numeric for addition since it is stored as text
    UPDATE public.budgets 
    SET amount_spent = (COALESCE(CAST(amount_spent AS numeric), 0) + v_amount_numeric)::text
    WHERE category = main_category_id 
      AND user_id = user_uuid;
    -- ***************************

    -- Handle subcategories if provided
    IF subcategories_amount IS NOT NULL THEN
        -- Iterate through the subcategories
        FOR subcategory_record IN 
            SELECT key AS subcategory_name, value AS subcategory_amount 
            FROM jsonb_each_text(subcategories_amount)
        LOOP
            -- Check if subcategory exists
            SELECT id INTO subcategory_id 
            FROM public.subcategories 
            WHERE name = subcategory_record.subcategory_name 
              AND category_id = main_category_id 
            LIMIT 1;

            -- If subcategory does not exist, create it
            IF subcategory_id IS NULL THEN
                INSERT INTO public.subcategories(name, category_id)
                VALUES (subcategory_record.subcategory_name, main_category_id)
                RETURNING id INTO subcategory_id;
            END IF;

            -- Insert into subcategory_expenses
            INSERT INTO public.subcategory_expenses(
                transaction_id, 
                sub_id, 
                amount
            ) VALUES (
                expense_id, 
                subcategory_id, 
                CAST(subcategory_record.subcategory_amount AS numeric)
            );
        END LOOP;
    END IF;

    RETURN QUERY SELECT true, NULL::text;

EXCEPTION 
    WHEN OTHERS THEN 
        RETURN QUERY 
        SELECT 
            false, 
            'Error: ' || SQLERRM || 
            ' (SQLState: ' || SQLSTATE || ')';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
