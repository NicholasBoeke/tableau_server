/* 
get site admins (site_role_id=0) 
along with user_login (for security match)
and the list of sites they should see (i.e. any sites where site_role=0) 

all tables described in tableau's dictionary for the WORKGROUP repository
https://help.tableau.com/current/server/en-us/data_dictionary.htm
https://tableau.github.io/tableau-data-dictionary/2021.4/data_dictionary.htm
*/

-- site admin list
with sa as (
select su.id as sa_system_user_id,
    su.name as sa_user_login, 
    su.friendly_name as sa_friendly_name, 
    su.email as sa_email, 
    --su.admin_level,           -- 10=SysAdmin; don't need this  
    u.id as sa_user_id,
    u.site_id
from public.system_users su,    -- system_user table has identifying info on people   
    public.users u              -- user table relates system users to sites via 1 user_id per site
where u.site_role_id=0          -- 0=SiteAdmin
    and u.system_user_id=su.id
),

-- pick up site names and site status
s as (
select id as site_id, 
    name as site_name,
    status as site_status,
    url_namespace as site_url
from public.sites
)

-- outer join to keep sites having no SA assigned
select sa_system_user_id,
    sa_user_login,
    sa_friendly_name,
    sa_email,
    sa_user_id,
    s.site_id, --this one has all sites
    s.site_name,
    s.site_status,
    s.site_url
from sa full outer join s on sa.site_id = s.site_id
