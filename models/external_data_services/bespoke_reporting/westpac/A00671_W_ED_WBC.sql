WITH users AS (
    SELECT
        u.user_id,
        u.subscriber_id
    FROM {{ source('exchange_share', 'vw_users') }} AS u
    WHERE u.subscriber_id IN (621)
),

workgroups AS (
    SELECT DISTINCT
        w.name,
        'Workgroups' AS type
    FROM users AS u
    INNER JOIN
        {{ source('exchange_share', 'vw_workgroup_users') }} AS wu
        ON u.user_id = wu.user_id
    INNER JOIN
        {{ source('exchange_share', 'vw_workgroups') }} AS w
        ON wu.workgroup_id = w.workgroup_id
),

permissions AS (
    SELECT DISTINCT
        p.description,
        'Permissions' AS type
    FROM users AS u
    INNER JOIN
        {{ source('exchange_share', 'vw_user_permissions') }} AS up
        ON u.user_id = up.user_id
    INNER JOIN
        {{ source('exchange_share', 'vw_permissions') }} AS p
        ON up.permission_id = p.permission_id
),

derived_workgroups AS(
    SELECT
    1 AS "0",
    x.name AS "Group Name",
    x.type AS "Type",
    CASE
        WHEN x.name = 'Signer - Settlement' THEN '7'
        WHEN x.name = 'Signer - Documents' THEN '6'
        WHEN x.name = 'Corrective Payment' THEN '5'
        WHEN x.name LIKE 'Signer%Corrective Payment' THEN '4'
        WHEN x.name = 'Management Reporting' THEN '3'
        WHEN x.name NOT IN (
            'Discharges NSW - Please use WHOS Discharges',
            'Mortgages NSW -_Please use WHOS Mortgages',
            'Discharges QLD-Please use WHOS Discharges',
            'Mortgages QLD-Please use WHOS Mortgages'
        )
        AND (
            x.name LIKE 'Discharges%Please use WHOS Discharges'
            OR x.name LIKE 'Mortgages%Please use WHOS Mortgages'
        ) THEN '2'
        WHEN x.name LIKE 'Pilot WES' THEN '2'
        ELSE '1'
    END AS derived_Desc
FROM (
    SELECT * FROM workgroups
    UNION ALL
    SELECT * FROM permissions
) AS x 
)
select 
"0",
"Group Name",
case when derived_Desc = '7'
				then 'Allows a user to authorise a financial settlement statement'
	when derived_Desc = '6'
				then 'Allows the selected user to sign documents in a Workspace'
	when derived_Desc = '5'
				then  'Allows the user to view and edit corrective changes'
	when derived_Desc = '4'
				then 'Allows the user to view, edit, and sign off on corrective changes'
	 when derived_Desc ='3'
				then 'Enables the user to generate PEXA management reports for any workgroup'
	 when derived_Desc = '2'
				then 'Not include in IIQ'
	 else 'Workgroups are structured in line with your business process and requirements. A PEXA User can belong to one or more PEXA Workgroups and will have access to all the individual PEXA Workspaces that belong to the Workgroup. Workgroups enable you to structure how the workload will flow within your business'
end as "Description",
"Type",
from derived_workgroups
