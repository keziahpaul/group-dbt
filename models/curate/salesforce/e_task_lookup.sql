{{ config(materialized='ephemeral') }}
SELECT id, label
FROM (VALUES
    ('0124a0000004N8HAAU', 'Financial Institution Task'),
    ('0129g0000004IjwAAE', 'Member Support Task'),
    ('0122P0000004QyZQAU', 'PEXA UK Task'),
    ('0124a0000004N8IAAU', 'Practitioner Task'),
    ('0122P0000004QyaQAE', 'Regulatory Affairs Task')
) t(id, label)