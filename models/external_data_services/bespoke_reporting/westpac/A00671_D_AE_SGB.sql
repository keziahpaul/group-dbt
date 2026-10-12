
WITH last_login AS (
  SELECT 
    be.user_id,
    MAX(created_date) AS last_login
  FROM {{ source('exchange_share', 'vw_business_event') }} be
  WHERE business_event_type_id = 43 -- USER_AUTHENTICATED (Logged in)
    AND be.created_date > date_trunc('day',
    (date_trunc('month', {{var('local_current_time_ntz')}}) + INTERVAL '1 month'- INTERVAL '1 day' + INTERVAL '1 day' )
    - INTERVAL '7 month')
  GROUP BY be.user_id
),
users AS (
  SELECT 
    u.user_id,
    u.first_name,
    u.middle_name,
    u.last_name,
    u.EMAIL_ADDRESS1,
    u.phone_number,
    u.JOB_TITLE,
    u.CREATED,
    u.status,
    u.subscriber_id
  FROM {{ source('exchange_share', 'vw_users') }} u
  WHERE u.subscriber_id IN (1079)
    AND u.username NOT LIKE '%first%'
    AND u.status NOT IN ('DELETED', 'ARCHIVED')
),
permissions AS (
  SELECT 
    u.USER_ID,
    LISTAGG(p.Description, ', ') WITHIN GROUP (ORDER BY u.USER_ID) AS permission
  FROM {{ source('exchange_share', 'vw_users') }} u
  INNER JOIN {{ source('exchange_share', 'vw_user_permissions') }} up ON up.USER_ID = u.USER_ID
  INNER JOIN {{ source('exchange_share', 'vw_permissions') }} p ON up.PERMISSION_ID = p.PERMISSION_ID
  WHERE u.SUBSCRIBER_ID IN (1079)
  GROUP BY u.USER_ID
),
workgroups AS (
  SELECT
    u.USER_ID,
    LISTAGG(w.NAME, ', ') WITHIN GROUP (ORDER BY u.USER_ID) AS workgroup
  FROM {{ source('exchange_share', 'vw_users') }} u
  INNER JOIN {{ source('exchange_share', 'vw_workgroup_users') }} wu ON wu.USER_ID = u.USER_ID
  INNER JOIN {{ source('exchange_share', 'vw_workgroups') }} w ON w.WORKGROUP_ID = wu.WORKGROUP_ID
  WHERE u.SUBSCRIBER_ID IN (1079)
  GROUP BY u.USER_ID
)
SELECT
  1 AS "0",
  ar.description AS "Subscriber User Type",
  u.first_name AS "First Name",
  u.middle_name AS "Middle Name",
  u.last_name AS "Last Name",
  u.EMAIL_ADDRESS1 AS "Email",
  u.phone_number AS "Phone",
  u.JOB_TITLE AS "Salary ID",
  NULL AS " ",
  wg.workgroup AS "Workgroup(s)",
  pm.permission AS "Permission(s)",
  DATE_TRUNC('DAY', u.CREATED)::date AS "Created On",
  DATE_TRUNC('DAY', lg.last_login)::date AS "Last Active",
  u.status AS "Status"
FROM users u
INNER JOIN {{ source('exchange_share', 'vw_user_application_roles') }} uar ON uar.user_id = u.user_id
INNER JOIN {{ source('exchange_share', 'vw_application_roles') }} ar ON ar.application_role_id = uar.application_role_id AND uar.application_role_id = ar.application_role_id
LEFT JOIN last_login lg ON lg.user_id = u.user_id
LEFT JOIN permissions pm ON pm.user_id = u.user_id
LEFT JOIN workgroups wg ON wg.user_id = u.user_id
