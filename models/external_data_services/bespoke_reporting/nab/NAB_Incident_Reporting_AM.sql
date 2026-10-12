/*
Note: NAB_Incident_Reporting_AM is referencing a live view which contains all data at any given time
*/

select * from {{ ref('NAB_Incident_Reporting_Live') }}