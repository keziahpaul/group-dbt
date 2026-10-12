
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_user') %}  
 {% set pk = 'Id'%} 
 
     select  
              id as id
            ,  username as username
            ,  lastname as last_name
            ,  firstname as first_name
            ,  middlename as middle_name
            ,  suffix as suffix
            ,  name as name
            ,  companyname as company_name
            ,  division as division
            ,  department as department
            ,  title as title
            ,  street as street
            ,  city as city
            ,  state as state
            ,  postalcode as postal_code
            ,  country as country
            ,  statecode as state_code
            ,  countrycode as country_code
            ,  CAST(latitude as FLOAT) as latitude
            ,  CAST(longitude as FLOAT) as longitude
            ,  geocodeaccuracy as geocode_accuracy
            ,  address as address
            ,  email as email
            ,  CAST(emailpreferencesautobcc as BOOLEAN) as email_preferences_auto_bcc
            ,  CAST(emailpreferencesautobccstayintouch as BOOLEAN) as email_preferences_auto_bcc_stay_in_touch
            ,  CAST(emailpreferencesstayintouchreminder as BOOLEAN) as email_preferences_stay_in_touch_reminder
            ,  senderemail as sender_email
            ,  sendername as sender_name
            ,  signature as signature
            ,  stayintouchsubject as stay_in_touch_subject
            ,  stayintouchsignature as stay_in_touch_signature
            ,  stayintouchnote as stay_in_touch_note
            ,  phone as phone
            ,  fax as fax
            ,  mobilephone as mobile_phone
            ,  alias as alias
            ,  communitynickname as community_nickname
            ,  badgetext as badge_text
            ,  CAST(isactive as BOOLEAN) as is_active
            ,  timezonesidkey as time_zone_sid_key
            ,  userroleid as user_role_id
            ,  localesidkey as locale_sid_key
            ,  CAST(receivesinfoemails as BOOLEAN) as receives_info_emails
            ,  CAST(receivesadmininfoemails as BOOLEAN) as receives_admin_info_emails
            ,  emailencodingkey as email_encoding_key
            ,  profileid as profile_id
            ,  usertype as user_type
            ,  startday as start_day
            ,  endday as end_day
            ,  languagelocalekey as language_locale_key
            ,  employeenumber as employee_number
            ,  delegatedapproverid as delegated_approver_id
            ,  managerid as manager_id
            ,  to_timestamp_tz(lastlogindate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_login_date
            ,  to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,  createdbyid as created_by_id
            ,  to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,  lastmodifiedbyid as last_modified_by_id
            ,  to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,  to_timestamp_tz(passwordexpirationdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as password_expiration_date
            ,  suaccessexpirationdate as suaccess_expiration_date
            ,  to_timestamp_tz(offlinetrialexpirationdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as offline_trial_expiration_date
            ,  to_timestamp_tz(offlinepdatrialexpirationdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as offline_pda_trial_expiration_date
            ,  CAST(userpermissionsmarketinguser as BOOLEAN) as user_permissions_marketing_user
            ,  CAST(userpermissionsofflineuser as BOOLEAN) as user_permissions_offline_user
            ,  CAST(userpermissionsavantgouser as BOOLEAN) as user_permissions_avantgo_user
            ,  CAST(userpermissionscallcenterautologin as BOOLEAN) as user_permissions_call_center_auto_login
            ,  CAST(userpermissionssfcontentuser as BOOLEAN) as user_permissions_sfcontent_user
            ,  CAST(userpermissionsknowledgeuser as BOOLEAN) as user_permissions_knowledge_user
            ,  CAST(userpermissionsinteractionuser as BOOLEAN) as user_permissions_interaction_user
            ,  CAST(userpermissionssupportuser as BOOLEAN) as user_permissions_support_user
            ,  CAST(userpermissionsliveagentuser as BOOLEAN) as user_permissions_live_agent_user
            ,  CAST(forecastenabled as BOOLEAN) as forecast_enabled
            ,  CAST(userpreferencesactivityreminderspopup as BOOLEAN) as user_preferences_activity_reminders_popup
            ,  CAST(userpreferenceseventreminderscheckboxdefault as BOOLEAN) as user_preferences_event_reminders_checkbox_default
            ,  CAST(userpreferencestaskreminderscheckboxdefault as BOOLEAN) as user_preferences_task_reminders_checkbox_default
            ,  CAST(userpreferencesremindersoundoff as BOOLEAN) as user_preferences_reminder_sound_off
            ,  CAST(userpreferencesdisableallfeedsemail as BOOLEAN) as user_preferences_disable_all_feeds_email
            ,  CAST(userpreferencesdisablefollowersemail as BOOLEAN) as user_preferences_disable_followers_email
            ,  CAST(userpreferencesdisableprofilepostemail as BOOLEAN) as user_preferences_disable_profile_post_email
            ,  CAST(userpreferencesdisablechangecommentemail as BOOLEAN) as user_preferences_disable_change_comment_email
            ,  CAST(userpreferencesdisablelatercommentemail as BOOLEAN) as user_preferences_disable_later_comment_email
            ,  CAST(userpreferencesdisprofpostcommentemail as BOOLEAN) as user_preferences_dis_prof_post_comment_email
            ,  CAST(userpreferencescontentnoemail as BOOLEAN) as user_preferences_content_no_email
            ,  CAST(userpreferencescontentemailasandwhen as BOOLEAN) as user_preferences_content_email_as_and_when
            ,  CAST(userpreferencesapexpagesdevelopermode as BOOLEAN) as user_preferences_apex_pages_developer_mode
            ,  CAST(userpreferencesreceivenonotificationsasapprover as BOOLEAN) as user_preferences_receive_no_notifications_as_approver
            ,  CAST(userpreferencesreceivenotificationsasdelegatedapprover as BOOLEAN) as user_preferences_receive_notifications_as_delegated_approver
            ,  CAST(userpreferenceshidecsngetchattermobiletask as BOOLEAN) as user_preferences_hide_csnget_chatter_mobile_task
            ,  CAST(userpreferencesdisablementionspostemail as BOOLEAN) as user_preferences_disable_mentions_post_email
            ,  CAST(userpreferencesdismentionscommentemail as BOOLEAN) as user_preferences_dis_mentions_comment_email
            ,  CAST(userpreferenceshidecsndesktoptask as BOOLEAN) as user_preferences_hide_csndesktop_task
            ,  CAST(userpreferenceshidechatteronboardingsplash as BOOLEAN) as user_preferences_hide_chatter_onboarding_splash
            ,  CAST(userpreferenceshidesecondchatteronboardingsplash as BOOLEAN) as user_preferences_hide_second_chatter_onboarding_splash
            ,  CAST(userpreferencesdiscommentafterlikeemail as BOOLEAN) as user_preferences_dis_comment_after_like_email
            ,  CAST(userpreferencesdisablelikeemail as BOOLEAN) as user_preferences_disable_like_email
            ,  CAST(userpreferencessortfeedbycomment as BOOLEAN) as user_preferences_sort_feed_by_comment
            ,  CAST(userpreferencesdisablemessageemail as BOOLEAN) as user_preferences_disable_message_email
            ,  CAST(userpreferencesdisablebookmarkemail as BOOLEAN) as user_preferences_disable_bookmark_email
            ,  CAST(userpreferencesdisablesharepostemail as BOOLEAN) as user_preferences_disable_share_post_email
            ,  CAST(userpreferencesenableautosubforfeeds as BOOLEAN) as user_preferences_enable_auto_sub_for_feeds
            ,  CAST(userpreferencesdisablefilesharenotificationsforapi as BOOLEAN) as user_preferences_disable_file_share_notifications_for_api
            ,  CAST(userpreferencesshowtitletoexternalusers as BOOLEAN) as user_preferences_show_title_to_external_users
            ,  CAST(userpreferencesshowmanagertoexternalusers as BOOLEAN) as user_preferences_show_manager_to_external_users
            ,  CAST(userpreferencesshowemailtoexternalusers as BOOLEAN) as user_preferences_show_email_to_external_users
            ,  CAST(userpreferencesshowworkphonetoexternalusers as BOOLEAN) as user_preferences_show_work_phone_to_external_users
            ,  CAST(userpreferencesshowmobilephonetoexternalusers as BOOLEAN) as user_preferences_show_mobile_phone_to_external_users
            ,  CAST(userpreferencesshowfaxtoexternalusers as BOOLEAN) as user_preferences_show_fax_to_external_users
            ,  CAST(userpreferencesshowstreetaddresstoexternalusers as BOOLEAN) as user_preferences_show_street_address_to_external_users
            ,  CAST(userpreferencesshowcitytoexternalusers as BOOLEAN) as user_preferences_show_city_to_external_users
            ,  CAST(userpreferencesshowstatetoexternalusers as BOOLEAN) as user_preferences_show_state_to_external_users
            ,  CAST(userpreferencesshowpostalcodetoexternalusers as BOOLEAN) as user_preferences_show_postal_code_to_external_users
            ,  CAST(userpreferencesshowcountrytoexternalusers as BOOLEAN) as user_preferences_show_country_to_external_users
            ,  CAST(userpreferencesshowprofilepictoguestusers as BOOLEAN) as user_preferences_show_profile_pic_to_guest_users
            ,  CAST(userpreferencesshowtitletoguestusers as BOOLEAN) as user_preferences_show_title_to_guest_users
            ,  CAST(userpreferencesshowcitytoguestusers as BOOLEAN) as user_preferences_show_city_to_guest_users
            ,  CAST(userpreferencesshowstatetoguestusers as BOOLEAN) as user_preferences_show_state_to_guest_users
            ,  CAST(userpreferencesshowpostalcodetoguestusers as BOOLEAN) as user_preferences_show_postal_code_to_guest_users
            ,  CAST(userpreferencesshowcountrytoguestusers as BOOLEAN) as user_preferences_show_country_to_guest_users
            ,  CAST(userpreferencesshowforecastingchangesignals as BOOLEAN) as user_preferences_show_forecasting_change_signals
            ,  CAST(userpreferenceshides1browserui as BOOLEAN) as user_preferences_hide_s_1_browser_ui
            ,  CAST(userpreferencesdisableendorsementemail as BOOLEAN) as user_preferences_disable_endorsement_email
            ,  CAST(userpreferencespathassistantcollapsed as BOOLEAN) as user_preferences_path_assistant_collapsed
            ,  CAST(userpreferencescachediagnostics as BOOLEAN) as user_preferences_cache_diagnostics
            ,  CAST(userpreferencesshowemailtoguestusers as BOOLEAN) as user_preferences_show_email_to_guest_users
            ,  CAST(userpreferencesshowmanagertoguestusers as BOOLEAN) as user_preferences_show_manager_to_guest_users
            ,  CAST(userpreferencesshowworkphonetoguestusers as BOOLEAN) as user_preferences_show_work_phone_to_guest_users
            ,  CAST(userpreferencesshowmobilephonetoguestusers as BOOLEAN) as user_preferences_show_mobile_phone_to_guest_users
            ,  CAST(userpreferencesshowfaxtoguestusers as BOOLEAN) as user_preferences_show_fax_to_guest_users
            ,  CAST(userpreferencesshowstreetaddresstoguestusers as BOOLEAN) as user_preferences_show_street_address_to_guest_users
            ,  CAST(userpreferenceslightningexperiencepreferred as BOOLEAN) as user_preferences_lightning_experience_preferred
            ,  CAST(userpreferenceshideenduseronboardingassistantmodal as BOOLEAN) as user_preferences_hide_end_user_onboarding_assistant_modal
            ,  CAST(userpreferenceshidelightningmigrationmodal as BOOLEAN) as user_preferences_hide_lightning_migration_modal
            ,  CAST(userpreferenceshidesfxwelcomemat as BOOLEAN) as user_preferences_hide_sfx_welcome_mat
            ,  CAST(userpreferenceshidebiggerphotocallout as BOOLEAN) as user_preferences_hide_bigger_photo_callout
            ,  CAST(userpreferencesglobalnavbarwtshown as BOOLEAN) as user_preferences_global_nav_bar_wtshown
            ,  CAST(userpreferencesglobalnavgridmenuwtshown as BOOLEAN) as user_preferences_global_nav_grid_menu_wtshown
            ,  CAST(userpreferencescreatelexappswtshown as BOOLEAN) as user_preferences_create_lexapps_wtshown
            ,  CAST(userpreferencesfavoriteswtshown as BOOLEAN) as user_preferences_favorites_wtshown
            ,  CAST(userpreferencesrecordhomesectioncollapsewtshown as BOOLEAN) as user_preferences_record_home_section_collapse_wtshown
            ,  CAST(userpreferencesrecordhomereservedwtshown as BOOLEAN) as user_preferences_record_home_reserved_wtshown
            ,  CAST(userpreferencesfavoritesshowtopfavorites as BOOLEAN) as user_preferences_favorites_show_top_favorites
            ,  CAST(userpreferencesexcludemailappattachments as BOOLEAN) as user_preferences_exclude_mail_app_attachments
            ,  CAST(userpreferencessuppresstasksfxreminders as BOOLEAN) as user_preferences_suppress_task_sfxreminders
            ,  CAST(userpreferencessuppresseventsfxreminders as BOOLEAN) as user_preferences_suppress_event_sfxreminders
            ,  CAST(userpreferencespreviewcustomtheme as BOOLEAN) as user_preferences_preview_custom_theme
            ,  CAST(userpreferenceshascelebrationbadge as BOOLEAN) as user_preferences_has_celebration_badge
            ,  CAST(userpreferencesuserdebugmodepref as BOOLEAN) as user_preferences_user_debug_mode_pref
            ,  CAST(userpreferencessrhoverrideactivities as BOOLEAN) as user_preferences_srhoverride_activities
            ,  CAST(userpreferencesreverseopenactivitiesview as BOOLEAN) as user_preferences_reverse_open_activities_view
            ,  CAST(userpreferenceshassentwarningemail as BOOLEAN) as user_preferences_has_sent_warning_email
            ,  CAST(userpreferenceshassentwarningemail238 as BOOLEAN) as user_preferences_has_sent_warning_email_238
            ,  CAST(userpreferenceshassentwarningemail240 as BOOLEAN) as user_preferences_has_sent_warning_email_240
            ,  CAST(userpreferenceshidebrowseproductredirectconfirmation as BOOLEAN) as user_preferences_hide_browse_product_redirect_confirmation
            ,  CAST(userpreferenceshideonlinesalesappwelcomemat as BOOLEAN) as user_preferences_hide_online_sales_app_welcome_mat
            ,  contactid as contact_id
            ,  accountid as account_id
            ,  callcenterid as call_center_id
            ,  extension as extension
            ,  portalrole as portal_role
            ,  CAST(isportalenabled as BOOLEAN) as is_portal_enabled
            ,  federationidentifier as federation_identifier
            ,  aboutme as about_me
            ,  fullphotourl as full_photo_url
            ,  smallphotourl as small_photo_url
            ,  CAST(isextindicatorvisible as BOOLEAN) as is_ext_indicator_visible
            ,  outofofficemessage as out_of_office_message
            ,  mediumphotourl as medium_photo_url
            ,  digestfrequency as digest_frequency
            ,  defaultgroupnotificationfrequency as default_group_notification_frequency
            ,  to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,  to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,  bannerphotourl as banner_photo_url
            ,  smallbannerphotourl as small_banner_photo_url
            ,  mediumbannerphotourl as medium_banner_photo_url
            ,  CAST(isprofilephotoactive as BOOLEAN) as is_profile_photo_active
            -- ,  INDIVIDUALID as INDIVIDUAL_ID. -- NOT readable from salesforce
            ,  {{ var('inserted_at' ) }} as inserted_at 
     from  {{ src_view_name }} 
    
{% if is_incremental() %}
    where metadata_filename in {{ daily_refresh_stage(this,src_view_name) }}
{% endif %}