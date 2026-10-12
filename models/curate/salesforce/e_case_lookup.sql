{{ config(materialized='ephemeral') }}
SELECT id, label
FROM (VALUES
    ('0122P0000004RAiQAM', 'Member Services'),
    ('0129g0000004K97AAE', 'Onboarding'),
    ('0129g0000004KHNAA2', 'UK Support'),
    ('012OZ000002kjXHYAY', 'Salesforce Support'),
    ('012OZ000004bQhBYAU', 'Account Services')
) t(id, label)