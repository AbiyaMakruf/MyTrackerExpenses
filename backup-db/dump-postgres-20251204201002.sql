--
-- PostgreSQL database dump
--

\restrict eSYsKWMSri4oLMn8ZeWzdJ8lRqt7R9aZCXPFkI2DUMKd2FDzsp9ET8m77uIPUaH

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


--
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_update_level_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budgets (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    category_id bigint,
    wallet_id bigint,
    amount numeric(20,2) NOT NULL,
    period_type character varying(191) DEFAULT 'monthly'::character varying NOT NULL,
    start_date date,
    end_date date,
    color character varying(191),
    threshold_warning numeric(5,2) DEFAULT '0'::numeric NOT NULL,
    note character varying(191),
    metadata json,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    icon_id bigint
);


--
-- Name: budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.budgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.budgets_id_seq OWNED BY public.budgets.id;


--
-- Name: cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache (
    key character varying(191) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_locks (
    key character varying(191) NOT NULL,
    owner character varying(191) NOT NULL,
    expiration integer NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    user_id bigint,
    parent_id bigint,
    name character varying(191) NOT NULL,
    type character varying(255) DEFAULT 'expense'::character varying NOT NULL,
    color character varying(191),
    is_default boolean DEFAULT false NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    icon_id bigint,
    icon_color character varying(191),
    icon_background character varying(191),
    CONSTRAINT categories_type_check CHECK (((type)::text = ANY ((ARRAY['expense'::character varying, 'income'::character varying, 'transfer'::character varying])::text[])))
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(191) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: goals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.goals (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    target_amount numeric(20,2) NOT NULL,
    current_amount numeric(20,2) DEFAULT '0'::numeric NOT NULL,
    deadline date,
    goal_wallet_id bigint,
    auto_save_amount numeric(20,2),
    auto_save_interval character varying(191),
    auto_save_next_run_at timestamp(0) without time zone,
    auto_save_enabled boolean DEFAULT false NOT NULL,
    status character varying(191) DEFAULT 'ongoing'::character varying NOT NULL,
    note character varying(191),
    metadata json,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    icon_id bigint
);


--
-- Name: goals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.goals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: goals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.goals_id_seq OWNED BY public.goals.id;


--
-- Name: icons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.icons (
    id bigint NOT NULL,
    type character varying(255) NOT NULL,
    fa_class character varying(191),
    image_path character varying(191),
    label character varying(191) NOT NULL,
    "group" character varying(191),
    created_by bigint,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    image_disk character varying(191),
    CONSTRAINT icons_type_check CHECK (((type)::text = ANY ((ARRAY['fontawesome'::character varying, 'image'::character varying])::text[])))
);


--
-- Name: icons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.icons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: icons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.icons_id_seq OWNED BY public.icons.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_batches (
    id character varying(191) NOT NULL,
    name character varying(191) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(191) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: label_transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.label_transaction (
    id bigint NOT NULL,
    transaction_id bigint NOT NULL,
    label_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: label_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.label_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: label_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.label_transaction_id_seq OWNED BY public.label_transaction.id;


--
-- Name: labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.labels (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    slug character varying(191) NOT NULL,
    color character varying(191),
    description character varying(191),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.labels_id_seq OWNED BY public.labels.id;


--
-- Name: memo_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memo_entries (
    id bigint NOT NULL,
    memo_group_id bigint NOT NULL,
    date_label character varying(191),
    content text NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    file_path character varying(191),
    file_name character varying(191),
    mime_type character varying(191)
);


--
-- Name: memo_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memo_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memo_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memo_entries_id_seq OWNED BY public.memo_entries.id;


--
-- Name: memo_folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memo_folders (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    color character varying(191) DEFAULT '#095C4A'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: memo_folders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memo_folders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memo_folders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memo_folders_id_seq OWNED BY public.memo_folders.id;


--
-- Name: memo_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memo_groups (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    memo_folder_id bigint
);


--
-- Name: memo_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memo_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memo_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memo_groups_id_seq OWNED BY public.memo_groups.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(191) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    email character varying(191) NOT NULL,
    token character varying(191) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: planned_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planned_payments (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title character varying(191) NOT NULL,
    amount numeric(20,2) NOT NULL,
    due_date date NOT NULL,
    wallet_id bigint,
    category_id bigint,
    repeat_option character varying(191) DEFAULT 'none'::character varying NOT NULL,
    is_recurring boolean DEFAULT false NOT NULL,
    status character varying(191) DEFAULT 'pending'::character varying NOT NULL,
    transaction_id bigint,
    note character varying(191),
    metadata json,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    icon_id bigint
);


--
-- Name: planned_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planned_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planned_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planned_payments_id_seq OWNED BY public.planned_payments.id;


--
-- Name: recurring_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurring_transactions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    wallet_id bigint NOT NULL,
    to_wallet_id bigint,
    category_id bigint,
    sub_category_id bigint,
    type character varying(191) DEFAULT 'expense'::character varying NOT NULL,
    amount numeric(20,2) NOT NULL,
    currency character varying(3) DEFAULT 'IDR'::character varying NOT NULL,
    payment_type character varying(191),
    "interval" character varying(191) DEFAULT 'monthly'::character varying NOT NULL,
    custom_days integer,
    next_run_at timestamp(0) without time zone NOT NULL,
    end_date date,
    auto_post boolean DEFAULT true NOT NULL,
    last_run_at timestamp(0) without time zone,
    is_active boolean DEFAULT true NOT NULL,
    note character varying(191),
    metadata json,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: recurring_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurring_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurring_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurring_transactions_id_seq OWNED BY public.recurring_transactions.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(191) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    amount numeric(20,2) NOT NULL,
    billing_cycle character varying(191) DEFAULT 'monthly'::character varying NOT NULL,
    next_billing_date date,
    wallet_id bigint,
    category_id bigint,
    status character varying(191) DEFAULT 'active'::character varying NOT NULL,
    auto_post_transaction boolean DEFAULT false NOT NULL,
    reminder_days integer DEFAULT 3 NOT NULL,
    last_billed_at timestamp(0) without time zone,
    currency character varying(3) DEFAULT 'IDR'::character varying NOT NULL,
    note character varying(191),
    metadata json,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sub_category_id bigint,
    icon_id bigint
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    wallet_id bigint NOT NULL,
    to_wallet_id bigint,
    category_id bigint,
    sub_category_id bigint,
    recurring_transaction_id bigint,
    type character varying(191) DEFAULT 'expense'::character varying NOT NULL,
    amount numeric(20,2) NOT NULL,
    currency character varying(3) DEFAULT 'IDR'::character varying NOT NULL,
    exchange_rate numeric(20,6) DEFAULT '1'::numeric NOT NULL,
    amount_converted numeric(20,2),
    payment_type character varying(191),
    transaction_date timestamp(0) without time zone NOT NULL,
    status character varying(191) DEFAULT 'posted'::character varying NOT NULL,
    note character varying(191),
    attachment_path character varying(191),
    metadata json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(191) NOT NULL,
    email character varying(191) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(191) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    role character varying(191) DEFAULT 'user'::character varying NOT NULL,
    base_currency character varying(3) DEFAULT 'IDR'::character varying NOT NULL,
    language character varying(5) DEFAULT 'en'::character varying NOT NULL,
    timezone character varying(191) DEFAULT 'Asia/Jakarta'::character varying NOT NULL,
    default_wallet_id bigint,
    settings json,
    last_active_at timestamp(0) without time zone,
    two_factor_secret text,
    two_factor_recovery_codes text,
    two_factor_confirmed_at timestamp(0) without time zone,
    profile_photo_path character varying(2048)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wallets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallets (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    type character varying(191) DEFAULT 'bank'::character varying NOT NULL,
    currency character varying(3) DEFAULT 'IDR'::character varying NOT NULL,
    initial_balance numeric(20,2) DEFAULT '0'::numeric NOT NULL,
    current_balance numeric(20,2) DEFAULT '0'::numeric NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    meta json,
    archived_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    icon_id bigint,
    icon_color character varying(191),
    icon_background character varying(191)
);


--
-- Name: wallets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wallets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wallets_id_seq OWNED BY public.wallets.id;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: budgets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets ALTER COLUMN id SET DEFAULT nextval('public.budgets_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: goals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals ALTER COLUMN id SET DEFAULT nextval('public.goals_id_seq'::regclass);


--
-- Name: icons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.icons ALTER COLUMN id SET DEFAULT nextval('public.icons_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: label_transaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.label_transaction ALTER COLUMN id SET DEFAULT nextval('public.label_transaction_id_seq'::regclass);


--
-- Name: labels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels ALTER COLUMN id SET DEFAULT nextval('public.labels_id_seq'::regclass);


--
-- Name: memo_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_entries ALTER COLUMN id SET DEFAULT nextval('public.memo_entries_id_seq'::regclass);


--
-- Name: memo_folders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_folders ALTER COLUMN id SET DEFAULT nextval('public.memo_folders_id_seq'::regclass);


--
-- Name: memo_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_groups ALTER COLUMN id SET DEFAULT nextval('public.memo_groups_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: planned_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_payments ALTER COLUMN id SET DEFAULT nextval('public.planned_payments_id_seq'::regclass);


--
-- Name: recurring_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions ALTER COLUMN id SET DEFAULT nextval('public.recurring_transactions_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wallets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets ALTER COLUMN id SET DEFAULT nextval('public.wallets_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: budgets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.budgets (id, user_id, name, category_id, wallet_id, amount, period_type, start_date, end_date, color, threshold_warning, note, metadata, deleted_at, created_at, updated_at, icon_id) FROM stdin;
1	2	Monthly Food Budget	1	1	3000000.00	monthly	2025-11-01	2025-11-30	#15B489	80.00	Try to stay within 3M for food	\N	\N	2025-11-20 02:07:40	2025-11-20 02:07:40	\N
2	3	Maksimal jajan mingguan	\N	\N	100000.00	weekly	2025-11-24	2025-12-31	\N	0.00	\N	\N	\N	2025-11-20 12:04:08	2025-11-20 12:04:08	2332
\.


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cache (key, value, expiration) FROM stdin;
my-expenses-cache-3fb363b65122fb27ad0b73cc5cd8dcd8:timer	i:1764757414;	1764757414
my-expenses-cache-3fb363b65122fb27ad0b73cc5cd8dcd8	i:1;	1764757414
my-expenses-cache-da8f597e0562cfa1acdb587f5f1e7e90:timer	i:1764764411;	1764764411
my-expenses-cache-da8f597e0562cfa1acdb587f5f1e7e90	i:1;	1764764411
my-expenses-cache-bddee70b743a21f23cad226473a67123:timer	i:1764765246;	1764765246
my-expenses-cache-bddee70b743a21f23cad226473a67123	i:1;	1764765246
my-expenses-cache-b59614a8283a066db6e733e06e8ed2fa:timer	i:1764820345;	1764820345
my-expenses-cache-b59614a8283a066db6e733e06e8ed2fa	i:1;	1764820345
my-expenses-cache-21896ee82540fd6cdb282b3ba46ac8bb:timer	i:1764843506;	1764843506
my-expenses-cache-21896ee82540fd6cdb282b3ba46ac8bb	i:1;	1764843507
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, user_id, parent_id, name, type, color, is_default, is_archived, display_order, created_at, updated_at, deleted_at, icon_id, icon_color, icon_background) FROM stdin;
1	\N	\N	Food & Beverages	expense	#F97316	t	f	1	2025-11-20 02:07:37	2025-11-20 02:07:37	\N	23	\N	#F97316
2	\N	\N	Groceries	expense	#FACC15	t	f	2	2025-11-20 02:07:37	2025-11-20 02:07:37	\N	15	\N	#FACC15
3	\N	\N	Transport	expense	#60A5FA	t	f	3	2025-11-20 02:07:37	2025-11-20 02:07:37	\N	32	\N	#60A5FA
4	\N	\N	Health & Fitness	expense	#F472B6	t	f	4	2025-11-20 02:07:37	2025-11-20 02:07:37	\N	28	\N	#F472B6
5	\N	\N	Entertainment	expense	#A855F7	t	f	5	2025-11-20 02:07:38	2025-11-20 02:07:38	\N	44	\N	#A855F7
6	\N	\N	Subscriptions	expense	#0EA5E9	t	f	6	2025-11-20 02:07:38	2025-11-20 02:07:38	\N	48	\N	#0EA5E9
7	\N	\N	Salary	income	#10B981	t	f	7	2025-11-20 02:07:38	2025-11-20 02:07:38	\N	50	\N	#10B981
8	\N	\N	Investments	income	#14B8A6	t	f	8	2025-11-20 02:07:38	2025-11-20 02:07:38	\N	51	\N	#14B8A6
9	\N	\N	Gift	income	#FB7185	t	f	9	2025-11-20 02:07:38	2025-11-20 02:07:38	\N	\N	\N	#FB7185
11	3	1	Drink	expense	\N	f	f	0	2025-11-20 10:41:33	2025-11-20 10:41:33	\N	1107	#095C4A	#F6FFFA
10	3	1	Heavy meal	expense	\N	f	f	0	2025-11-20 10:30:59	2025-11-20 10:42:04	\N	2775	#095C4A	#F6FFFA
12	3	1	Snack	expense	\N	f	f	0	2025-11-20 10:43:40	2025-11-20 10:43:40	\N	1363	#095C4A	#F6FFFA
14	3	3	Gasoline	expense	\N	f	f	0	2025-11-20 10:45:52	2025-11-20 10:45:52	\N	1640	#095C4A	#F6FFFA
16	3	6	Internet Quota	expense	\N	f	f	0	2025-11-20 10:51:02	2025-11-20 10:51:02	\N	2874	#095C4A	#F6FFFA
17	3	15	Withdraw cash	expense	\N	f	f	0	2025-11-20 10:53:16	2025-11-20 10:53:16	\N	2055	#095C4A	#F6FFFA
18	3	15	Money transfer	expense	\N	f	f	0	2025-11-20 10:55:02	2025-11-20 10:55:02	\N	2049	#095C4A	#F6FFFA
15	3	\N	Finance	expense	\N	f	f	0	2025-11-20 10:49:08	2025-11-20 10:55:51	\N	2330	#095C4A	#F6FFFA
19	3	\N	Money transfer	income	\N	f	f	0	2025-11-20 10:58:16	2025-11-20 10:58:16	\N	2049	#095C4A	#F6FFFA
20	3	15	Topup	expense	\N	f	f	0	2025-11-20 11:03:52	2025-11-20 11:03:52	\N	2817	#095C4A	#F6FFFA
21	3	7	Weekly income	income	\N	f	f	0	2025-11-20 11:07:46	2025-11-20 11:08:39	\N	2050	#095C4A	#F6FFFA
13	3	7	-	expense	\N	f	f	0	2025-11-20 10:44:58	2025-11-20 11:08:47	\N	2332	#095C4A	#F6FFFA
22	3	4	Swimming	expense	\N	f	f	0	2025-11-20 11:10:28	2025-11-20 11:10:28	\N	2180	#095C4A	#F6FFFA
23	3	5	Movie theater	expense	\N	f	f	0	2025-11-20 11:12:48	2025-11-20 11:12:48	\N	1592	#095C4A	#F6FFFA
24	3	4	Billiards	expense	\N	f	f	0	2025-11-20 11:16:20	2025-11-20 11:16:20	\N	2187	#095C4A	#F6FFFA
25	3	\N	Medicines	expense	\N	f	f	0	2025-11-20 11:17:48	2025-11-20 11:17:48	\N	1810	#095C4A	#F6FFFA
26	3	6	Netflix	expense	\N	f	f	0	2025-11-20 11:19:03	2025-11-20 11:19:03	\N	2877	#095C4A	#F6FFFA
27	3	6	Domain website	expense	\N	f	f	0	2025-11-20 11:22:44	2025-11-20 11:22:44	\N	2363	#095C4A	#F6FFFA
28	3	6	Chat GPT	expense	\N	f	f	0	2025-11-20 11:24:51	2025-11-20 11:24:51	\N	2873	#095C4A	#F6FFFA
29	3	15	Administrative fees	expense	\N	f	f	0	2025-11-20 11:26:09	2025-11-20 11:26:09	\N	1035	#095C4A	#F6FFFA
30	3	\N	University	expense	\N	f	f	0	2025-11-20 11:27:23	2025-11-20 11:27:23	\N	1144	#095C4A	#F6FFFA
31	3	6	Icloud	expense	\N	f	f	0	2025-11-20 11:53:01	2025-11-20 11:53:01	\N	2875	#095C4A	#F6FFFA
32	3	6	Apple music	expense	\N	f	f	0	2025-11-20 11:54:37	2025-11-20 11:54:37	\N	2876	#095C4A	#F6FFFA
33	3	6	Google drive	expense	\N	f	f	0	2025-11-20 11:56:44	2025-11-20 11:56:44	\N	2878	#095C4A	#F6FFFA
34	3	15	Infaq	expense	\N	f	f	0	2025-11-21 11:44:48	2025-11-21 11:44:48	\N	2063	#095C4A	#F6FFFA
35	3	\N	Personal Care	expense	\N	f	f	0	2025-11-23 12:14:54	2025-11-23 12:14:54	\N	1781	#095C4A	#F6FFFA
36	3	35	Hair/Salon	expense	\N	f	f	0	2025-11-23 12:15:42	2025-11-23 12:15:42	\N	2188	#095C4A	#F6FFFA
37	3	3	Maintenance & Repair	expense	\N	f	f	0	2025-11-23 12:17:36	2025-11-23 12:17:36	\N	2066	#095C4A	#F6FFFA
38	3	15	Balance correction	expense	\N	f	f	0	2025-11-24 15:23:03	2025-11-24 15:23:03	\N	2054	#095C4A	#F6FFFA
39	3	7	Honorary Assistant Lecturer	income	\N	f	f	0	2025-11-24 16:48:59	2025-11-24 16:48:59	\N	2721	#095C4A	#F6FFFA
40	3	\N	E-Commerce	expense	\N	f	f	0	2025-11-26 02:40:23	2025-11-26 02:40:23	\N	1212	#095C4A	#F6FFFA
41	3	40	Shopee	expense	\N	f	f	0	2025-11-26 02:40:42	2025-11-26 02:40:42	\N	2869	#095C4A	#F6FFFA
42	3	\N	Gift	expense	\N	f	f	0	2025-11-28 13:01:48	2025-11-28 13:01:48	\N	1654	#095C4A	#F6FFFA
43	3	3	Parking	expense	\N	f	f	0	2025-11-28 18:23:24	2025-11-28 18:23:24	\N	2110	#095C4A	#F6FFFA
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: goals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.goals (id, user_id, name, target_amount, current_amount, deadline, goal_wallet_id, auto_save_amount, auto_save_interval, auto_save_next_run_at, auto_save_enabled, status, note, metadata, deleted_at, created_at, updated_at, icon_id) FROM stdin;
1	2	Emergency Fund	50000000.00	15000000.00	2026-09-20	1	5000000.00	monthly	2025-12-20 02:07:40	t	ongoing	6 months of living expenses	\N	\N	2025-11-20 02:07:40	2025-11-20 02:07:40	\N
2	3	Savings	10000000.00	3500000.00	2026-01-31	12	100000.00	weekly	\N	t	ongoing		\N	\N	2025-11-20 12:05:01	2025-11-28 18:24:52	2332
\.


--
-- Data for Name: icons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.icons (id, type, fa_class, image_path, label, "group", created_by, is_active, created_at, updated_at, image_disk) FROM stdin;
1	fontawesome	fas:wallet	\N	Wallet	finance	\N	t	2025-11-20 02:04:35	2025-11-20 02:04:35	\N
2	fontawesome	fas:coins	\N	Coins	finance	\N	t	2025-11-20 02:04:35	2025-11-20 02:04:35	\N
3	fontawesome	fas:money-bill	\N	Money Bill	finance	\N	t	2025-11-20 02:04:35	2025-11-20 02:04:35	\N
5	fontawesome	fas:sack-dollar	\N	Sack Dollar	finance	\N	t	2025-11-20 02:04:35	2025-11-20 02:04:35	\N
6	fontawesome	far:credit-card	\N	Credit Card	finance	\N	t	2025-11-20 02:04:35	2025-11-20 02:04:35	\N
7	fontawesome	fas:piggy-bank	\N	Piggy Bank	finance	\N	t	2025-11-20 02:04:35	2025-11-20 02:04:35	\N
8	fontawesome	fas:banknote	\N	Banknote	finance	\N	t	2025-11-20 02:04:35	2025-11-20 02:04:35	\N
10	fontawesome	fas:cash-register	\N	Cash Register	finance	\N	t	2025-11-20 02:04:36	2025-11-20 02:04:36	\N
11	fontawesome	fas:building-columns	\N	Building Columns	banks	\N	t	2025-11-20 02:04:36	2025-11-20 02:04:36	\N
12	fontawesome	fas:bank	\N	Bank	banks	\N	t	2025-11-20 02:04:36	2025-11-20 02:04:36	\N
13	fontawesome	fas:vault	\N	Vault	banks	\N	t	2025-11-20 02:04:36	2025-11-20 02:04:36	\N
14	fontawesome	fas:cash	\N	Cash	banks	\N	t	2025-11-20 02:04:36	2025-11-20 02:04:36	\N
15	fontawesome	fas:cart-shopping	\N	Cart Shopping	shopping	\N	t	2025-11-20 02:04:36	2025-11-20 02:04:36	\N
16	fontawesome	fas:basket-shopping	\N	Basket	shopping	\N	t	2025-11-20 02:04:36	2025-11-20 02:04:36	\N
17	fontawesome	fas:store	\N	Store	shopping	\N	t	2025-11-20 02:04:37	2025-11-20 02:04:37	\N
18	fontawesome	fas:tags	\N	Tags	shopping	\N	t	2025-11-20 02:04:37	2025-11-20 02:04:37	\N
21	fontawesome	fas:utensils	\N	Utensils	food	\N	t	2025-11-20 02:04:37	2025-11-20 02:04:37	\N
22	fontawesome	fas:burger	\N	Burger	food	\N	t	2025-11-20 02:04:37	2025-11-20 02:04:37	\N
23	fontawesome	fas:mug-hot	\N	Mug Hot	food	\N	t	2025-11-20 02:04:37	2025-11-20 02:04:37	\N
24	fontawesome	fas:wine-glass	\N	Wine Glass	food	\N	t	2025-11-20 02:04:37	2025-11-20 02:04:37	\N
25	fontawesome	fas:pizza	\N	Pizza	food	\N	t	2025-11-20 02:04:38	2025-11-20 02:04:38	\N
26	fontawesome	fas:apple-alt	\N	Apple	food	\N	t	2025-11-20 02:04:38	2025-11-20 02:04:38	\N
27	fontawesome	fas:coffee	\N	Coffee	food	\N	t	2025-11-20 02:04:38	2025-11-20 02:04:38	\N
28	fontawesome	fas:heart-pulse	\N	Heart Pulse	health	\N	t	2025-11-20 02:04:38	2025-11-20 02:04:38	\N
29	fontawesome	fas:stethoscope	\N	Stethoscope	health	\N	t	2025-11-20 02:04:38	2025-11-20 02:04:38	\N
30	fontawesome	fas:hospital	\N	Hospital	health	\N	t	2025-11-20 02:04:38	2025-11-20 02:04:38	\N
31	fontawesome	fas:user-md	\N	User Doctor	health	\N	t	2025-11-20 02:04:38	2025-11-20 02:04:38	\N
32	fontawesome	fas:car	\N	Car	transport	\N	t	2025-11-20 02:04:38	2025-11-20 02:04:38	\N
33	fontawesome	fas:motorcycle	\N	Motorcycle	transport	\N	t	2025-11-20 02:04:39	2025-11-20 02:04:39	\N
34	fontawesome	fas:bus	\N	Bus	transport	\N	t	2025-11-20 02:04:39	2025-11-20 02:04:39	\N
35	fontawesome	fas:gas-pump	\N	Gas Pump	transport	\N	t	2025-11-20 02:04:39	2025-11-20 02:04:39	\N
36	fontawesome	fas:bicycle	\N	Bicycle	transport	\N	t	2025-11-20 02:04:39	2025-11-20 02:04:39	\N
37	fontawesome	fas:taxi	\N	Taxi	transport	\N	t	2025-11-20 02:04:39	2025-11-20 02:04:39	\N
38	fontawesome	fas:file-invoice	\N	Invoice	bills	\N	t	2025-11-20 02:04:39	2025-11-20 02:04:39	\N
39	fontawesome	fas:bolt	\N	Bolt	bills	\N	t	2025-11-20 02:04:39	2025-11-20 02:04:39	\N
40	fontawesome	fas:water	\N	Water	bills	\N	t	2025-11-20 02:04:39	2025-11-20 02:04:39	\N
20	fontawesome	fas:receipt	\N	Receipt	bills	\N	t	2025-11-20 02:04:37	2025-11-20 02:04:40	\N
41	fontawesome	fas:lightbulb	\N	Electricity	bills	\N	t	2025-11-20 02:04:40	2025-11-20 02:04:40	\N
42	fontawesome	fas:gas	\N	Gas	bills	\N	t	2025-11-20 02:04:40	2025-11-20 02:04:40	\N
9	fontawesome	fas:dollar-sign	\N	Dollar Sign	bills	\N	t	2025-11-20 02:04:36	2025-11-20 02:04:40	\N
43	fontawesome	fas:cloud	\N	Cloud	subscriptions	\N	t	2025-11-20 02:04:40	2025-11-20 02:04:40	\N
44	fontawesome	fas:tv	\N	TV	subscriptions	\N	t	2025-11-20 02:04:40	2025-11-20 02:04:40	\N
45	fontawesome	fab:apple	\N	Apple	subscriptions	\N	t	2025-11-20 02:04:40	2025-11-20 02:04:40	\N
46	fontawesome	fab:spotify	\N	Spotify	subscriptions	\N	t	2025-11-20 02:04:40	2025-11-20 02:04:40	\N
47	fontawesome	fab:disney	\N	Disney	subscriptions	\N	t	2025-11-20 02:04:41	2025-11-20 02:04:41	\N
48	fontawesome	fas:wifi	\N	Wifi	subscriptions	\N	t	2025-11-20 02:04:41	2025-11-20 02:04:41	\N
49	fontawesome	fas:phone	\N	Phone	subscriptions	\N	t	2025-11-20 02:04:41	2025-11-20 02:04:41	\N
50	fontawesome	fas:briefcase	\N	Briefcase	income	\N	t	2025-11-20 02:04:41	2025-11-20 02:04:41	\N
51	fontawesome	fas:chart-line	\N	Chart Line	income	\N	t	2025-11-20 02:04:41	2025-11-20 02:04:41	\N
52	fontawesome	fas:circle-dollar-to-slot	\N	Dollar Slot	income	\N	t	2025-11-20 02:04:41	2025-11-20 02:04:41	\N
4	fontawesome	fas:money-check	\N	Money Check	income	\N	t	2025-11-20 02:04:35	2025-11-20 02:04:41	\N
19	fontawesome	fas:tag	\N	Tag	general	\N	t	2025-11-20 02:04:37	2025-11-20 02:04:41	\N
53	fontawesome	fas:list	\N	List	general	\N	t	2025-11-20 02:04:42	2025-11-20 02:04:42	\N
54	fontawesome	fas:box	\N	Box	general	\N	t	2025-11-20 02:04:42	2025-11-20 02:04:42	\N
55	fontawesome	fas:circle	\N	Circle	general	\N	t	2025-11-20 02:04:42	2025-11-20 02:04:42	\N
56	fontawesome	fas:home	\N	Home	general	\N	t	2025-11-20 02:04:42	2025-11-20 02:04:42	\N
57	fontawesome	fas:calendar	\N	Calendar	general	\N	t	2025-11-20 02:04:42	2025-11-20 02:04:42	\N
58	fontawesome	fas:location-arrow	\N	Location	general	\N	t	2025-11-20 02:04:42	2025-11-20 02:04:42	\N
60	fontawesome	42-group	icons/fontawesome/brands/42-group.svg	42 Group	brands	\N	t	2025-11-20 02:04:42	2025-11-20 10:34:23	public
61	fontawesome	500px	icons/fontawesome/brands/500px.svg	500Px	brands	\N	t	2025-11-20 02:04:42	2025-11-20 10:34:23	public
62	fontawesome	accessible-icon	icons/fontawesome/brands/accessible-icon.svg	Accessible Icon	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
63	fontawesome	accusoft	icons/fontawesome/brands/accusoft.svg	Accusoft	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
64	fontawesome	adn	icons/fontawesome/brands/adn.svg	Adn	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
65	fontawesome	adversal	icons/fontawesome/brands/adversal.svg	Adversal	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
67	fontawesome	airbnb	icons/fontawesome/brands/airbnb.svg	Airbnb	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
68	fontawesome	algolia	icons/fontawesome/brands/algolia.svg	Algolia	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
69	fontawesome	alipay	icons/fontawesome/brands/alipay.svg	Alipay	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
1459	fontawesome	egg	icons/fontawesome/solid/egg.svg	Egg	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:34:23	public
1460	fontawesome	eject	icons/fontawesome/solid/eject.svg	Eject	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:34:23	public
1461	fontawesome	elevator	icons/fontawesome/solid/elevator.svg	Elevator	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:34:23	public
71	fontawesome	amazon	icons/fontawesome/brands/amazon.svg	Amazon	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:24	public
73	fontawesome	android	icons/fontawesome/brands/android.svg	Android	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:24	public
74	fontawesome	angellist	icons/fontawesome/brands/angellist.svg	Angellist	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:24	public
75	fontawesome	angrycreative	icons/fontawesome/brands/angrycreative.svg	Angrycreative	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:24	public
76	fontawesome	angular	icons/fontawesome/brands/angular.svg	Angular	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:24	public
77	fontawesome	app-store-ios	icons/fontawesome/brands/app-store-ios.svg	App Store Ios	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:24	public
78	fontawesome	app-store	icons/fontawesome/brands/app-store.svg	App Store	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
79	fontawesome	apper	icons/fontawesome/brands/apper.svg	Apper	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
80	fontawesome	apple-pay	icons/fontawesome/brands/apple-pay.svg	Apple Pay	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
81	fontawesome	apple	icons/fontawesome/brands/apple.svg	Apple	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
83	fontawesome	asymmetrik	icons/fontawesome/brands/asymmetrik.svg	Asymmetrik	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
84	fontawesome	atlassian	icons/fontawesome/brands/atlassian.svg	Atlassian	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
85	fontawesome	audible	icons/fontawesome/brands/audible.svg	Audible	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
86	fontawesome	autoprefixer	icons/fontawesome/brands/autoprefixer.svg	Autoprefixer	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
87	fontawesome	avianex	icons/fontawesome/brands/avianex.svg	Avianex	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:25	public
88	fontawesome	aviato	icons/fontawesome/brands/aviato.svg	Aviato	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:25	public
89	fontawesome	aws	icons/fontawesome/brands/aws.svg	Aws	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:25	public
90	fontawesome	bandcamp	icons/fontawesome/brands/bandcamp.svg	Bandcamp	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:25	public
91	fontawesome	battle-net	icons/fontawesome/brands/battle-net.svg	Battle Net	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:25	public
93	fontawesome	behance	icons/fontawesome/brands/behance.svg	Behance	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:25	public
94	fontawesome	bilibili	icons/fontawesome/brands/bilibili.svg	Bilibili	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:25	public
95	fontawesome	bimobject	icons/fontawesome/brands/bimobject.svg	Bimobject	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:25	public
96	fontawesome	bitbucket	icons/fontawesome/brands/bitbucket.svg	Bitbucket	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:25	public
97	fontawesome	bitcoin	icons/fontawesome/brands/bitcoin.svg	Bitcoin	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:25	public
98	fontawesome	bity	icons/fontawesome/brands/bity.svg	Bity	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:25	public
99	fontawesome	black-tie	icons/fontawesome/brands/black-tie.svg	Black Tie	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:25	public
100	fontawesome	blackberry	icons/fontawesome/brands/blackberry.svg	Blackberry	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:25	public
101	fontawesome	blogger-b	icons/fontawesome/brands/blogger-b.svg	Blogger B	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
102	fontawesome	blogger	icons/fontawesome/brands/blogger.svg	Blogger	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
103	fontawesome	bluesky	icons/fontawesome/brands/bluesky.svg	Bluesky	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
104	fontawesome	bluetooth-b	icons/fontawesome/brands/bluetooth-b.svg	Bluetooth B	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
105	fontawesome	bluetooth	icons/fontawesome/brands/bluetooth.svg	Bluetooth	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
107	fontawesome	bots	icons/fontawesome/brands/bots.svg	Bots	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
108	fontawesome	brave-reverse	icons/fontawesome/brands/brave-reverse.svg	Brave Reverse	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
109	fontawesome	brave	icons/fontawesome/brands/brave.svg	Brave	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
110	fontawesome	btc	icons/fontawesome/brands/btc.svg	Btc	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
111	fontawesome	buffer	icons/fontawesome/brands/buffer.svg	Buffer	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:26	public
112	fontawesome	buromobelexperte	icons/fontawesome/brands/buromobelexperte.svg	Buromobelexperte	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:26	public
113	fontawesome	buy-n-large	icons/fontawesome/brands/buy-n-large.svg	Buy N Large	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:26	public
114	fontawesome	buysellads	icons/fontawesome/brands/buysellads.svg	Buysellads	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:26	public
116	fontawesome	cash-app	icons/fontawesome/brands/cash-app.svg	Cash App	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
117	fontawesome	cc-amazon-pay	icons/fontawesome/brands/cc-amazon-pay.svg	Cc Amazon Pay	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
118	fontawesome	cc-amex	icons/fontawesome/brands/cc-amex.svg	Cc Amex	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
119	fontawesome	cc-apple-pay	icons/fontawesome/brands/cc-apple-pay.svg	Cc Apple Pay	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
120	fontawesome	cc-diners-club	icons/fontawesome/brands/cc-diners-club.svg	Cc Diners Club	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
121	fontawesome	cc-discover	icons/fontawesome/brands/cc-discover.svg	Cc Discover	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
122	fontawesome	cc-jcb	icons/fontawesome/brands/cc-jcb.svg	Cc Jcb	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
123	fontawesome	cc-mastercard	icons/fontawesome/brands/cc-mastercard.svg	Cc Mastercard	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
124	fontawesome	cc-paypal	icons/fontawesome/brands/cc-paypal.svg	Cc Paypal	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
125	fontawesome	cc-stripe	icons/fontawesome/brands/cc-stripe.svg	Cc Stripe	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
126	fontawesome	cc-visa	icons/fontawesome/brands/cc-visa.svg	Cc Visa	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:27	public
127	fontawesome	centercode	icons/fontawesome/brands/centercode.svg	Centercode	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:27	public
129	fontawesome	chrome	icons/fontawesome/brands/chrome.svg	Chrome	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:27	public
131	fontawesome	cloudflare	icons/fontawesome/brands/cloudflare.svg	Cloudflare	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
132	fontawesome	cloudscale	icons/fontawesome/brands/cloudscale.svg	Cloudscale	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
133	fontawesome	cloudsmith	icons/fontawesome/brands/cloudsmith.svg	Cloudsmith	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
134	fontawesome	cloudversify	icons/fontawesome/brands/cloudversify.svg	Cloudversify	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
135	fontawesome	cmplid	icons/fontawesome/brands/cmplid.svg	Cmplid	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
136	fontawesome	codepen	icons/fontawesome/brands/codepen.svg	Codepen	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
137	fontawesome	codiepie	icons/fontawesome/brands/codiepie.svg	Codiepie	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
138	fontawesome	confluence	icons/fontawesome/brands/confluence.svg	Confluence	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
140	fontawesome	contao	icons/fontawesome/brands/contao.svg	Contao	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
141	fontawesome	cotton-bureau	icons/fontawesome/brands/cotton-bureau.svg	Cotton Bureau	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:29	public
142	fontawesome	cpanel	icons/fontawesome/brands/cpanel.svg	Cpanel	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:29	public
143	fontawesome	creative-commons-by	icons/fontawesome/brands/creative-commons-by.svg	Creative Commons By	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
144	fontawesome	creative-commons-nc-eu	icons/fontawesome/brands/creative-commons-nc-eu.svg	Creative Commons Nc Eu	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
145	fontawesome	creative-commons-nc-jp	icons/fontawesome/brands/creative-commons-nc-jp.svg	Creative Commons Nc Jp	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
147	fontawesome	creative-commons-nd	icons/fontawesome/brands/creative-commons-nd.svg	Creative Commons Nd	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
148	fontawesome	creative-commons-pd-alt	icons/fontawesome/brands/creative-commons-pd-alt.svg	Creative Commons Pd Alt	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
149	fontawesome	creative-commons-pd	icons/fontawesome/brands/creative-commons-pd.svg	Creative Commons Pd	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
150	fontawesome	creative-commons-remix	icons/fontawesome/brands/creative-commons-remix.svg	Creative Commons Remix	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
151	fontawesome	creative-commons-sa	icons/fontawesome/brands/creative-commons-sa.svg	Creative Commons Sa	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
152	fontawesome	creative-commons-sampling-plus	icons/fontawesome/brands/creative-commons-sampling-plus.svg	Creative Commons Sampling Plus	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
154	fontawesome	creative-commons-share	icons/fontawesome/brands/creative-commons-share.svg	Creative Commons Share	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:30	public
155	fontawesome	creative-commons-zero	icons/fontawesome/brands/creative-commons-zero.svg	Creative Commons Zero	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:30	public
156	fontawesome	creative-commons	icons/fontawesome/brands/creative-commons.svg	Creative Commons	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:30	public
157	fontawesome	critical-role	icons/fontawesome/brands/critical-role.svg	Critical Role	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:30	public
158	fontawesome	css	icons/fontawesome/brands/css.svg	Css	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:30	public
159	fontawesome	css3-alt	icons/fontawesome/brands/css3-alt.svg	Css3 Alt	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
160	fontawesome	css3	icons/fontawesome/brands/css3.svg	Css3	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
161	fontawesome	cuttlefish	icons/fontawesome/brands/cuttlefish.svg	Cuttlefish	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
162	fontawesome	d-and-d-beyond	icons/fontawesome/brands/d-and-d-beyond.svg	D And D Beyond	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
163	fontawesome	d-and-d	icons/fontawesome/brands/d-and-d.svg	D And D	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
164	fontawesome	dailymotion	icons/fontawesome/brands/dailymotion.svg	Dailymotion	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
165	fontawesome	dart-lang	icons/fontawesome/brands/dart-lang.svg	Dart Lang	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
166	fontawesome	dashcube	icons/fontawesome/brands/dashcube.svg	Dashcube	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
167	fontawesome	debian	icons/fontawesome/brands/debian.svg	Debian	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
169	fontawesome	delicious	icons/fontawesome/brands/delicious.svg	Delicious	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
170	fontawesome	deploydog	icons/fontawesome/brands/deploydog.svg	Deploydog	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
171	fontawesome	deskpro	icons/fontawesome/brands/deskpro.svg	Deskpro	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:31	public
172	fontawesome	dev	icons/fontawesome/brands/dev.svg	Dev	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:31	public
173	fontawesome	deviantart	icons/fontawesome/brands/deviantart.svg	Deviantart	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:31	public
174	fontawesome	dhl	icons/fontawesome/brands/dhl.svg	Dhl	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:31	public
175	fontawesome	diaspora	icons/fontawesome/brands/diaspora.svg	Diaspora	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
176	fontawesome	digg	icons/fontawesome/brands/digg.svg	Digg	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
177	fontawesome	digital-ocean	icons/fontawesome/brands/digital-ocean.svg	Digital Ocean	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
178	fontawesome	discord	icons/fontawesome/brands/discord.svg	Discord	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
179	fontawesome	discourse	icons/fontawesome/brands/discourse.svg	Discourse	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
181	fontawesome	dochub	icons/fontawesome/brands/dochub.svg	Dochub	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
182	fontawesome	docker	icons/fontawesome/brands/docker.svg	Docker	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
183	fontawesome	draft2digital	icons/fontawesome/brands/draft2digital.svg	Draft2Digital	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
185	fontawesome	dribbble	icons/fontawesome/brands/dribbble.svg	Dribbble	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
186	fontawesome	dropbox	icons/fontawesome/brands/dropbox.svg	Dropbox	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
187	fontawesome	drupal	icons/fontawesome/brands/drupal.svg	Drupal	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
188	fontawesome	duolingo	icons/fontawesome/brands/duolingo.svg	Duolingo	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:32	public
189	fontawesome	dyalog	icons/fontawesome/brands/dyalog.svg	Dyalog	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:32	public
191	fontawesome	ebay	icons/fontawesome/brands/ebay.svg	Ebay	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
192	fontawesome	edge-legacy	icons/fontawesome/brands/edge-legacy.svg	Edge Legacy	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
193	fontawesome	edge	icons/fontawesome/brands/edge.svg	Edge	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
194	fontawesome	elementor	icons/fontawesome/brands/elementor.svg	Elementor	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
195	fontawesome	eleventy	icons/fontawesome/brands/eleventy.svg	Eleventy	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
196	fontawesome	ello	icons/fontawesome/brands/ello.svg	Ello	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
197	fontawesome	ember	icons/fontawesome/brands/ember.svg	Ember	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
198	fontawesome	empire	icons/fontawesome/brands/empire.svg	Empire	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
199	fontawesome	envira	icons/fontawesome/brands/envira.svg	Envira	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
200	fontawesome	erlang	icons/fontawesome/brands/erlang.svg	Erlang	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
201	fontawesome	ethereum	icons/fontawesome/brands/ethereum.svg	Ethereum	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:32	public
202	fontawesome	etsy	icons/fontawesome/brands/etsy.svg	Etsy	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:33	public
203	fontawesome	evernote	icons/fontawesome/brands/evernote.svg	Evernote	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:33	public
204	fontawesome	expeditedssl	icons/fontawesome/brands/expeditedssl.svg	Expeditedssl	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:33	public
206	fontawesome	facebook-messenger	icons/fontawesome/brands/facebook-messenger.svg	Facebook Messenger	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:33	public
207	fontawesome	facebook-square	icons/fontawesome/brands/facebook-square.svg	Facebook Square	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:33	public
208	fontawesome	facebook	icons/fontawesome/brands/facebook.svg	Facebook	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:33	public
209	fontawesome	fantasy-flight-games	icons/fontawesome/brands/fantasy-flight-games.svg	Fantasy Flight Games	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:33	public
210	fontawesome	fedex	icons/fontawesome/brands/fedex.svg	Fedex	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:33	public
211	fontawesome	fedora	icons/fontawesome/brands/fedora.svg	Fedora	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:33	public
212	fontawesome	figma	icons/fontawesome/brands/figma.svg	Figma	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:33	public
213	fontawesome	files-pinwheel	icons/fontawesome/brands/files-pinwheel.svg	Files Pinwheel	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:33	public
215	fontawesome	firefox	icons/fontawesome/brands/firefox.svg	Firefox	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:33	public
216	fontawesome	first-order-alt	icons/fontawesome/brands/first-order-alt.svg	First Order Alt	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:34	public
217	fontawesome	first-order	icons/fontawesome/brands/first-order.svg	First Order	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:34	public
218	fontawesome	firstdraft	icons/fontawesome/brands/firstdraft.svg	Firstdraft	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:34	public
219	fontawesome	flickr	icons/fontawesome/brands/flickr.svg	Flickr	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:34	public
220	fontawesome	flipboard	icons/fontawesome/brands/flipboard.svg	Flipboard	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:34	public
221	fontawesome	flutter	icons/fontawesome/brands/flutter.svg	Flutter	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:34	public
222	fontawesome	fly	icons/fontawesome/brands/fly.svg	Fly	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:34	public
223	fontawesome	font-awesome-alt	icons/fontawesome/brands/font-awesome-alt.svg	Font Awesome Alt	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:34	public
224	fontawesome	font-awesome-flag	icons/fontawesome/brands/font-awesome-flag.svg	Font Awesome Flag	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:34	public
226	fontawesome	font-awesome	icons/fontawesome/brands/font-awesome.svg	Font Awesome	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:34	public
227	fontawesome	fonticons-fi	icons/fontawesome/brands/fonticons-fi.svg	Fonticons Fi	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
228	fontawesome	fonticons	icons/fontawesome/brands/fonticons.svg	Fonticons	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
229	fontawesome	fort-awesome-alt	icons/fontawesome/brands/fort-awesome-alt.svg	Fort Awesome Alt	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
230	fontawesome	fort-awesome	icons/fontawesome/brands/fort-awesome.svg	Fort Awesome	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
231	fontawesome	forumbee	icons/fontawesome/brands/forumbee.svg	Forumbee	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
232	fontawesome	foursquare	icons/fontawesome/brands/foursquare.svg	Foursquare	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
233	fontawesome	free-code-camp	icons/fontawesome/brands/free-code-camp.svg	Free Code Camp	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
234	fontawesome	freebsd	icons/fontawesome/brands/freebsd.svg	Freebsd	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
235	fontawesome	fulcrum	icons/fontawesome/brands/fulcrum.svg	Fulcrum	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
237	fontawesome	galactic-senate	icons/fontawesome/brands/galactic-senate.svg	Galactic Senate	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:36	public
238	fontawesome	get-pocket	icons/fontawesome/brands/get-pocket.svg	Get Pocket	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:36	public
239	fontawesome	gg-circle	icons/fontawesome/brands/gg-circle.svg	Gg Circle	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:36	public
240	fontawesome	gg	icons/fontawesome/brands/gg.svg	Gg	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:36	public
242	fontawesome	git-square	icons/fontawesome/brands/git-square.svg	Git Square	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:36	public
243	fontawesome	git	icons/fontawesome/brands/git.svg	Git	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:36	public
244	fontawesome	github-alt	icons/fontawesome/brands/github-alt.svg	Github Alt	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:36	public
246	fontawesome	github	icons/fontawesome/brands/github.svg	Github	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:36	public
247	fontawesome	gitkraken	icons/fontawesome/brands/gitkraken.svg	Gitkraken	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
248	fontawesome	gitlab-square	icons/fontawesome/brands/gitlab-square.svg	Gitlab Square	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
249	fontawesome	gitlab	icons/fontawesome/brands/gitlab.svg	Gitlab	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
250	fontawesome	gitter	icons/fontawesome/brands/gitter.svg	Gitter	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
251	fontawesome	glide-g	icons/fontawesome/brands/glide-g.svg	Glide G	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
252	fontawesome	glide	icons/fontawesome/brands/glide.svg	Glide	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
253	fontawesome	gofore	icons/fontawesome/brands/gofore.svg	Gofore	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
254	fontawesome	golang	icons/fontawesome/brands/golang.svg	Golang	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
255	fontawesome	goodreads-g	icons/fontawesome/brands/goodreads-g.svg	Goodreads G	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:37	public
256	fontawesome	goodreads	icons/fontawesome/brands/goodreads.svg	Goodreads	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:37	public
258	fontawesome	google-pay	icons/fontawesome/brands/google-pay.svg	Google Pay	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
259	fontawesome	google-play	icons/fontawesome/brands/google-play.svg	Google Play	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
260	fontawesome	google-plus-g	icons/fontawesome/brands/google-plus-g.svg	Google Plus G	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
261	fontawesome	google-plus-square	icons/fontawesome/brands/google-plus-square.svg	Google Plus Square	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
262	fontawesome	google-plus	icons/fontawesome/brands/google-plus.svg	Google Plus	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
263	fontawesome	google-scholar	icons/fontawesome/brands/google-scholar.svg	Google Scholar	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
264	fontawesome	google-wallet	icons/fontawesome/brands/google-wallet.svg	Google Wallet	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
265	fontawesome	google	icons/fontawesome/brands/google.svg	Google	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
266	fontawesome	gratipay	icons/fontawesome/brands/gratipay.svg	Gratipay	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
267	fontawesome	grav	icons/fontawesome/brands/grav.svg	Grav	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
269	fontawesome	grunt	icons/fontawesome/brands/grunt.svg	Grunt	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:39	public
270	fontawesome	guilded	icons/fontawesome/brands/guilded.svg	Guilded	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:39	public
271	fontawesome	gulp	icons/fontawesome/brands/gulp.svg	Gulp	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:39	public
272	fontawesome	hacker-news-square	icons/fontawesome/brands/hacker-news-square.svg	Hacker News Square	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:39	public
273	fontawesome	hacker-news	icons/fontawesome/brands/hacker-news.svg	Hacker News	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:39	public
274	fontawesome	hackerrank	icons/fontawesome/brands/hackerrank.svg	Hackerrank	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:39	public
275	fontawesome	hashnode	icons/fontawesome/brands/hashnode.svg	Hashnode	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:39	public
276	fontawesome	hips	icons/fontawesome/brands/hips.svg	Hips	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:40	public
277	fontawesome	hire-a-helper	icons/fontawesome/brands/hire-a-helper.svg	Hire A Helper	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:40	public
278	fontawesome	hive	icons/fontawesome/brands/hive.svg	Hive	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:40	public
279	fontawesome	hooli	icons/fontawesome/brands/hooli.svg	Hooli	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:40	public
281	fontawesome	hotjar	icons/fontawesome/brands/hotjar.svg	Hotjar	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:40	public
282	fontawesome	houzz	icons/fontawesome/brands/houzz.svg	Houzz	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:40	public
283	fontawesome	html5	icons/fontawesome/brands/html5.svg	Html5	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:40	public
284	fontawesome	hubspot	icons/fontawesome/brands/hubspot.svg	Hubspot	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:41	public
285	fontawesome	ideal	icons/fontawesome/brands/ideal.svg	Ideal	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:41	public
286	fontawesome	imdb	icons/fontawesome/brands/imdb.svg	Imdb	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:41	public
287	fontawesome	innosoft	icons/fontawesome/brands/innosoft.svg	Innosoft	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:41	public
288	fontawesome	instagram-square	icons/fontawesome/brands/instagram-square.svg	Instagram Square	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
289	fontawesome	instagram	icons/fontawesome/brands/instagram.svg	Instagram	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
290	fontawesome	instalod	icons/fontawesome/brands/instalod.svg	Instalod	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
291	fontawesome	intercom	icons/fontawesome/brands/intercom.svg	Intercom	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
293	fontawesome	invision	icons/fontawesome/brands/invision.svg	Invision	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
294	fontawesome	ioxhost	icons/fontawesome/brands/ioxhost.svg	Ioxhost	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
295	fontawesome	itch-io	icons/fontawesome/brands/itch-io.svg	Itch Io	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
296	fontawesome	itunes-note	icons/fontawesome/brands/itunes-note.svg	Itunes Note	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
297	fontawesome	itunes	icons/fontawesome/brands/itunes.svg	Itunes	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:42	public
298	fontawesome	java	icons/fontawesome/brands/java.svg	Java	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:42	public
300	fontawesome	jenkins	icons/fontawesome/brands/jenkins.svg	Jenkins	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:42	public
301	fontawesome	jira	icons/fontawesome/brands/jira.svg	Jira	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:42	public
302	fontawesome	joget	icons/fontawesome/brands/joget.svg	Joget	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:42	public
303	fontawesome	joomla	icons/fontawesome/brands/joomla.svg	Joomla	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:42	public
304	fontawesome	js-square	icons/fontawesome/brands/js-square.svg	Js Square	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
305	fontawesome	js	icons/fontawesome/brands/js.svg	Js	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
306	fontawesome	jsfiddle	icons/fontawesome/brands/jsfiddle.svg	Jsfiddle	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
307	fontawesome	jxl	icons/fontawesome/brands/jxl.svg	Jxl	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
309	fontawesome	kakao-talk	icons/fontawesome/brands/kakao-talk.svg	Kakao Talk	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
310	fontawesome	keybase	icons/fontawesome/brands/keybase.svg	Keybase	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
311	fontawesome	keycdn	icons/fontawesome/brands/keycdn.svg	Keycdn	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
312	fontawesome	kickstarter-k	icons/fontawesome/brands/kickstarter-k.svg	Kickstarter K	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
313	fontawesome	kickstarter	icons/fontawesome/brands/kickstarter.svg	Kickstarter	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:43	public
314	fontawesome	korvue	icons/fontawesome/brands/korvue.svg	Korvue	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:43	public
315	fontawesome	laravel	icons/fontawesome/brands/laravel.svg	Laravel	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:43	public
317	fontawesome	lastfm	icons/fontawesome/brands/lastfm.svg	Lastfm	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:43	public
318	fontawesome	leanpub	icons/fontawesome/brands/leanpub.svg	Leanpub	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:43	public
319	fontawesome	less	icons/fontawesome/brands/less.svg	Less	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:43	public
320	fontawesome	letterboxd	icons/fontawesome/brands/letterboxd.svg	Letterboxd	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:43	public
321	fontawesome	line	icons/fontawesome/brands/line.svg	Line	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:43	public
322	fontawesome	linkedin-in	icons/fontawesome/brands/linkedin-in.svg	Linkedin In	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:43	public
323	fontawesome	linkedin	icons/fontawesome/brands/linkedin.svg	Linkedin	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:43	public
324	fontawesome	linktree	icons/fontawesome/brands/linktree.svg	Linktree	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:43	public
325	fontawesome	linode	icons/fontawesome/brands/linode.svg	Linode	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:43	public
326	fontawesome	linux	icons/fontawesome/brands/linux.svg	Linux	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:43	public
327	fontawesome	lumon-drop	icons/fontawesome/brands/lumon-drop.svg	Lumon Drop	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:43	public
328	fontawesome	lumon	icons/fontawesome/brands/lumon.svg	Lumon	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:43	public
329	fontawesome	lyft	icons/fontawesome/brands/lyft.svg	Lyft	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:44	public
330	fontawesome	magento	icons/fontawesome/brands/magento.svg	Magento	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:44	public
332	fontawesome	mandalorian	icons/fontawesome/brands/mandalorian.svg	Mandalorian	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:44	public
333	fontawesome	markdown	icons/fontawesome/brands/markdown.svg	Markdown	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:44	public
334	fontawesome	mastodon	icons/fontawesome/brands/mastodon.svg	Mastodon	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:44	public
335	fontawesome	maxcdn	icons/fontawesome/brands/maxcdn.svg	Maxcdn	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:44	public
336	fontawesome	mdb	icons/fontawesome/brands/mdb.svg	Mdb	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:44	public
337	fontawesome	medapps	icons/fontawesome/brands/medapps.svg	Medapps	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
338	fontawesome	medium-m	icons/fontawesome/brands/medium-m.svg	Medium M	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
339	fontawesome	medium	icons/fontawesome/brands/medium.svg	Medium	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
340	fontawesome	medrt	icons/fontawesome/brands/medrt.svg	Medrt	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
341	fontawesome	meetup	icons/fontawesome/brands/meetup.svg	Meetup	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
342	fontawesome	megaport	icons/fontawesome/brands/megaport.svg	Megaport	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
343	fontawesome	mendeley	icons/fontawesome/brands/mendeley.svg	Mendeley	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
344	fontawesome	meta	icons/fontawesome/brands/meta.svg	Meta	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
346	fontawesome	microsoft	icons/fontawesome/brands/microsoft.svg	Microsoft	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:45	public
347	fontawesome	mintbit	icons/fontawesome/brands/mintbit.svg	Mintbit	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:45	public
348	fontawesome	mix	icons/fontawesome/brands/mix.svg	Mix	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:45	public
349	fontawesome	mixcloud	icons/fontawesome/brands/mixcloud.svg	Mixcloud	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:45	public
350	fontawesome	mixer	icons/fontawesome/brands/mixer.svg	Mixer	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:45	public
351	fontawesome	mizuni	icons/fontawesome/brands/mizuni.svg	Mizuni	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:45	public
352	fontawesome	modx	icons/fontawesome/brands/modx.svg	Modx	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:45	public
353	fontawesome	monero	icons/fontawesome/brands/monero.svg	Monero	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:45	public
354	fontawesome	napster	icons/fontawesome/brands/napster.svg	Napster	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:45	public
355	fontawesome	neos	icons/fontawesome/brands/neos.svg	Neos	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:45	public
356	fontawesome	nfc-directional	icons/fontawesome/brands/nfc-directional.svg	Nfc Directional	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:45	public
357	fontawesome	nfc-symbol	icons/fontawesome/brands/nfc-symbol.svg	Nfc Symbol	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:45	public
359	fontawesome	node-js	icons/fontawesome/brands/node-js.svg	Node Js	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:45	public
360	fontawesome	node	icons/fontawesome/brands/node.svg	Node	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:45	public
361	fontawesome	notion	icons/fontawesome/brands/notion.svg	Notion	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:45	public
362	fontawesome	npm	icons/fontawesome/brands/npm.svg	Npm	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:46	public
363	fontawesome	ns8	icons/fontawesome/brands/ns8.svg	Ns8	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:46	public
365	fontawesome	octopus-deploy	icons/fontawesome/brands/octopus-deploy.svg	Octopus Deploy	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:46	public
366	fontawesome	odnoklassniki-square	icons/fontawesome/brands/odnoklassniki-square.svg	Odnoklassniki Square	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:46	public
367	fontawesome	odnoklassniki	icons/fontawesome/brands/odnoklassniki.svg	Odnoklassniki	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:46	public
368	fontawesome	odysee	icons/fontawesome/brands/odysee.svg	Odysee	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:46	public
369	fontawesome	old-republic	icons/fontawesome/brands/old-republic.svg	Old Republic	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:46	public
370	fontawesome	openai	icons/fontawesome/brands/openai.svg	Openai	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:46	public
371	fontawesome	opencart	icons/fontawesome/brands/opencart.svg	Opencart	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:46	public
372	fontawesome	openid	icons/fontawesome/brands/openid.svg	Openid	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:46	public
373	fontawesome	opensuse	icons/fontawesome/brands/opensuse.svg	Opensuse	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:46	public
374	fontawesome	opera	icons/fontawesome/brands/opera.svg	Opera	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
376	fontawesome	orcid	icons/fontawesome/brands/orcid.svg	Orcid	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
377	fontawesome	osi	icons/fontawesome/brands/osi.svg	Osi	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
378	fontawesome	padlet	icons/fontawesome/brands/padlet.svg	Padlet	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
379	fontawesome	page4	icons/fontawesome/brands/page4.svg	Page4	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
380	fontawesome	pagelines	icons/fontawesome/brands/pagelines.svg	Pagelines	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
381	fontawesome	palfed	icons/fontawesome/brands/palfed.svg	Palfed	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
382	fontawesome	pandora	icons/fontawesome/brands/pandora.svg	Pandora	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
383	fontawesome	patreon	icons/fontawesome/brands/patreon.svg	Patreon	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
384	fontawesome	paypal	icons/fontawesome/brands/paypal.svg	Paypal	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
385	fontawesome	perbyte	icons/fontawesome/brands/perbyte.svg	Perbyte	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:47	public
386	fontawesome	periscope	icons/fontawesome/brands/periscope.svg	Periscope	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
387	fontawesome	phabricator	icons/fontawesome/brands/phabricator.svg	Phabricator	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
389	fontawesome	phoenix-squadron	icons/fontawesome/brands/phoenix-squadron.svg	Phoenix Squadron	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
390	fontawesome	php	icons/fontawesome/brands/php.svg	Php	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
391	fontawesome	pied-piper-alt	icons/fontawesome/brands/pied-piper-alt.svg	Pied Piper Alt	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
392	fontawesome	pied-piper-hat	icons/fontawesome/brands/pied-piper-hat.svg	Pied Piper Hat	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
393	fontawesome	pied-piper-pp	icons/fontawesome/brands/pied-piper-pp.svg	Pied Piper Pp	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
394	fontawesome	pied-piper-square	icons/fontawesome/brands/pied-piper-square.svg	Pied Piper Square	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
395	fontawesome	pied-piper	icons/fontawesome/brands/pied-piper.svg	Pied Piper	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
396	fontawesome	pinterest-p	icons/fontawesome/brands/pinterest-p.svg	Pinterest P	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
397	fontawesome	pinterest-square	icons/fontawesome/brands/pinterest-square.svg	Pinterest Square	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
398	fontawesome	pinterest	icons/fontawesome/brands/pinterest.svg	Pinterest	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
399	fontawesome	pix	icons/fontawesome/brands/pix.svg	Pix	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:49	public
401	fontawesome	pixiv	icons/fontawesome/brands/pixiv.svg	Pixiv	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:49	public
402	fontawesome	playstation	icons/fontawesome/brands/playstation.svg	Playstation	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:49	public
403	fontawesome	product-hunt	icons/fontawesome/brands/product-hunt.svg	Product Hunt	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:49	public
404	fontawesome	pushed	icons/fontawesome/brands/pushed.svg	Pushed	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:49	public
405	fontawesome	python	icons/fontawesome/brands/python.svg	Python	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:49	public
406	fontawesome	qq	icons/fontawesome/brands/qq.svg	Qq	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:49	public
407	fontawesome	quinscape	icons/fontawesome/brands/quinscape.svg	Quinscape	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:49	public
408	fontawesome	quora	icons/fontawesome/brands/quora.svg	Quora	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:49	public
409	fontawesome	r-project	icons/fontawesome/brands/r-project.svg	R Project	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:49	public
410	fontawesome	raspberry-pi	icons/fontawesome/brands/raspberry-pi.svg	Raspberry Pi	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:50	public
411	fontawesome	ravelry	icons/fontawesome/brands/ravelry.svg	Ravelry	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:50	public
412	fontawesome	react	icons/fontawesome/brands/react.svg	React	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:50	public
414	fontawesome	readme	icons/fontawesome/brands/readme.svg	Readme	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:50	public
415	fontawesome	rebel	icons/fontawesome/brands/rebel.svg	Rebel	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:50	public
417	fontawesome	reddit-alien	icons/fontawesome/brands/reddit-alien.svg	Reddit Alien	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:50	public
418	fontawesome	reddit-square	icons/fontawesome/brands/reddit-square.svg	Reddit Square	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:50	public
419	fontawesome	reddit	icons/fontawesome/brands/reddit.svg	Reddit	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:51	public
420	fontawesome	redhat	icons/fontawesome/brands/redhat.svg	Redhat	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:51	public
421	fontawesome	rendact	icons/fontawesome/brands/rendact.svg	Rendact	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:51	public
422	fontawesome	renren	icons/fontawesome/brands/renren.svg	Renren	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:51	public
423	fontawesome	replyd	icons/fontawesome/brands/replyd.svg	Replyd	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:51	public
425	fontawesome	resolving	icons/fontawesome/brands/resolving.svg	Resolving	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:51	public
426	fontawesome	rev	icons/fontawesome/brands/rev.svg	Rev	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:51	public
427	fontawesome	rocketchat	icons/fontawesome/brands/rocketchat.svg	Rocketchat	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:52	public
428	fontawesome	rockrms	icons/fontawesome/brands/rockrms.svg	Rockrms	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:52	public
429	fontawesome	rust	icons/fontawesome/brands/rust.svg	Rust	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:52	public
430	fontawesome	safari	icons/fontawesome/brands/safari.svg	Safari	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:52	public
431	fontawesome	salesforce	icons/fontawesome/brands/salesforce.svg	Salesforce	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:52	public
432	fontawesome	sass	icons/fontawesome/brands/sass.svg	Sass	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:52	public
433	fontawesome	schlix	icons/fontawesome/brands/schlix.svg	Schlix	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:52	public
434	fontawesome	screenpal	icons/fontawesome/brands/screenpal.svg	Screenpal	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:52	public
435	fontawesome	scribd	icons/fontawesome/brands/scribd.svg	Scribd	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:52	public
437	fontawesome	sellcast	icons/fontawesome/brands/sellcast.svg	Sellcast	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
438	fontawesome	sellsy	icons/fontawesome/brands/sellsy.svg	Sellsy	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
439	fontawesome	servicestack	icons/fontawesome/brands/servicestack.svg	Servicestack	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
440	fontawesome	shirtsinbulk	icons/fontawesome/brands/shirtsinbulk.svg	Shirtsinbulk	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
441	fontawesome	shoelace	icons/fontawesome/brands/shoelace.svg	Shoelace	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
442	fontawesome	shopify	icons/fontawesome/brands/shopify.svg	Shopify	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
443	fontawesome	shopware	icons/fontawesome/brands/shopware.svg	Shopware	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
444	fontawesome	signal-messenger	icons/fontawesome/brands/signal-messenger.svg	Signal Messenger	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
445	fontawesome	simplybuilt	icons/fontawesome/brands/simplybuilt.svg	Simplybuilt	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
446	fontawesome	sistrix	icons/fontawesome/brands/sistrix.svg	Sistrix	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
447	fontawesome	sith	icons/fontawesome/brands/sith.svg	Sith	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
448	fontawesome	sitrox	icons/fontawesome/brands/sitrox.svg	Sitrox	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
449	fontawesome	sketch	icons/fontawesome/brands/sketch.svg	Sketch	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:54	public
451	fontawesome	skype	icons/fontawesome/brands/skype.svg	Skype	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
452	fontawesome	slack-hash	icons/fontawesome/brands/slack-hash.svg	Slack Hash	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
453	fontawesome	slack	icons/fontawesome/brands/slack.svg	Slack	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
454	fontawesome	slideshare	icons/fontawesome/brands/slideshare.svg	Slideshare	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
455	fontawesome	snapchat-ghost	icons/fontawesome/brands/snapchat-ghost.svg	Snapchat Ghost	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
456	fontawesome	snapchat-square	icons/fontawesome/brands/snapchat-square.svg	Snapchat Square	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
457	fontawesome	snapchat	icons/fontawesome/brands/snapchat.svg	Snapchat	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
458	fontawesome	soundcloud	icons/fontawesome/brands/soundcloud.svg	Soundcloud	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
460	fontawesome	space-awesome	icons/fontawesome/brands/space-awesome.svg	Space Awesome	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
461	fontawesome	speakap	icons/fontawesome/brands/speakap.svg	Speakap	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
462	fontawesome	speaker-deck	icons/fontawesome/brands/speaker-deck.svg	Speaker Deck	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
463	fontawesome	spotify	icons/fontawesome/brands/spotify.svg	Spotify	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
464	fontawesome	square-behance	icons/fontawesome/brands/square-behance.svg	Square Behance	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
465	fontawesome	square-bluesky	icons/fontawesome/brands/square-bluesky.svg	Square Bluesky	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
466	fontawesome	square-dribbble	icons/fontawesome/brands/square-dribbble.svg	Square Dribbble	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
468	fontawesome	square-figma	icons/fontawesome/brands/square-figma.svg	Square Figma	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
469	fontawesome	square-font-awesome-stroke	icons/fontawesome/brands/square-font-awesome-stroke.svg	Square Font Awesome Stroke	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
470	fontawesome	square-font-awesome	icons/fontawesome/brands/square-font-awesome.svg	Square Font Awesome	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
471	fontawesome	square-git	icons/fontawesome/brands/square-git.svg	Square Git	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
472	fontawesome	square-github	icons/fontawesome/brands/square-github.svg	Square Github	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
474	fontawesome	square-google-plus	icons/fontawesome/brands/square-google-plus.svg	Square Google Plus	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
475	fontawesome	square-hacker-news	icons/fontawesome/brands/square-hacker-news.svg	Square Hacker News	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
477	fontawesome	square-js	icons/fontawesome/brands/square-js.svg	Square Js	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
478	fontawesome	square-kickstarter	icons/fontawesome/brands/square-kickstarter.svg	Square Kickstarter	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
479	fontawesome	square-lastfm	icons/fontawesome/brands/square-lastfm.svg	Square Lastfm	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
480	fontawesome	square-letterboxd	icons/fontawesome/brands/square-letterboxd.svg	Square Letterboxd	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
481	fontawesome	square-linkedin	icons/fontawesome/brands/square-linkedin.svg	Square Linkedin	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
482	fontawesome	square-odnoklassniki	icons/fontawesome/brands/square-odnoklassniki.svg	Square Odnoklassniki	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
483	fontawesome	square-pied-piper	icons/fontawesome/brands/square-pied-piper.svg	Square Pied Piper	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
485	fontawesome	square-reddit	icons/fontawesome/brands/square-reddit.svg	Square Reddit	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
486	fontawesome	square-snapchat	icons/fontawesome/brands/square-snapchat.svg	Square Snapchat	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
487	fontawesome	square-steam	icons/fontawesome/brands/square-steam.svg	Square Steam	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
488	fontawesome	square-threads	icons/fontawesome/brands/square-threads.svg	Square Threads	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
489	fontawesome	square-tumblr	icons/fontawesome/brands/square-tumblr.svg	Square Tumblr	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
490	fontawesome	square-twitter	icons/fontawesome/brands/square-twitter.svg	Square Twitter	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
491	fontawesome	square-upwork	icons/fontawesome/brands/square-upwork.svg	Square Upwork	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
492	fontawesome	square-viadeo	icons/fontawesome/brands/square-viadeo.svg	Square Viadeo	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
493	fontawesome	square-vimeo	icons/fontawesome/brands/square-vimeo.svg	Square Vimeo	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
495	fontawesome	square-web-awesome	icons/fontawesome/brands/square-web-awesome.svg	Square Web Awesome	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
496	fontawesome	square-whatsapp	icons/fontawesome/brands/square-whatsapp.svg	Square Whatsapp	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
497	fontawesome	square-x-twitter	icons/fontawesome/brands/square-x-twitter.svg	Square X Twitter	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
498	fontawesome	square-xing	icons/fontawesome/brands/square-xing.svg	Square Xing	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:56	public
499	fontawesome	square-youtube	icons/fontawesome/brands/square-youtube.svg	Square Youtube	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
500	fontawesome	squarespace	icons/fontawesome/brands/squarespace.svg	Squarespace	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
501	fontawesome	stack-exchange	icons/fontawesome/brands/stack-exchange.svg	Stack Exchange	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
502	fontawesome	stack-overflow	icons/fontawesome/brands/stack-overflow.svg	Stack Overflow	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
503	fontawesome	stackpath	icons/fontawesome/brands/stackpath.svg	Stackpath	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
504	fontawesome	staylinked	icons/fontawesome/brands/staylinked.svg	Staylinked	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
506	fontawesome	steam-symbol	icons/fontawesome/brands/steam-symbol.svg	Steam Symbol	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
507	fontawesome	steam	icons/fontawesome/brands/steam.svg	Steam	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
508	fontawesome	sticker-mule	icons/fontawesome/brands/sticker-mule.svg	Sticker Mule	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
509	fontawesome	strava	icons/fontawesome/brands/strava.svg	Strava	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
510	fontawesome	stripe-s	icons/fontawesome/brands/stripe-s.svg	Stripe S	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
511	fontawesome	stripe	icons/fontawesome/brands/stripe.svg	Stripe	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
512	fontawesome	stubber	icons/fontawesome/brands/stubber.svg	Stubber	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
513	fontawesome	studiovinari	icons/fontawesome/brands/studiovinari.svg	Studiovinari	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:58	public
514	fontawesome	stumbleupon-circle	icons/fontawesome/brands/stumbleupon-circle.svg	Stumbleupon Circle	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:58	public
515	fontawesome	stumbleupon	icons/fontawesome/brands/stumbleupon.svg	Stumbleupon	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
517	fontawesome	supple	icons/fontawesome/brands/supple.svg	Supple	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
518	fontawesome	suse	icons/fontawesome/brands/suse.svg	Suse	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
519	fontawesome	swift	icons/fontawesome/brands/swift.svg	Swift	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
520	fontawesome	symfony	icons/fontawesome/brands/symfony.svg	Symfony	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
521	fontawesome	teamspeak	icons/fontawesome/brands/teamspeak.svg	Teamspeak	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
522	fontawesome	telegram-plane	icons/fontawesome/brands/telegram-plane.svg	Telegram Plane	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
523	fontawesome	telegram	icons/fontawesome/brands/telegram.svg	Telegram	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
524	fontawesome	tencent-weibo	icons/fontawesome/brands/tencent-weibo.svg	Tencent Weibo	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
525	fontawesome	tex	icons/fontawesome/brands/tex.svg	Tex	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
526	fontawesome	the-red-yeti	icons/fontawesome/brands/the-red-yeti.svg	The Red Yeti	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
527	fontawesome	themeco	icons/fontawesome/brands/themeco.svg	Themeco	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
529	fontawesome	think-peaks	icons/fontawesome/brands/think-peaks.svg	Think Peaks	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:59	public
530	fontawesome	threads	icons/fontawesome/brands/threads.svg	Threads	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:59	public
531	fontawesome	tidal	icons/fontawesome/brands/tidal.svg	Tidal	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
532	fontawesome	tiktok	icons/fontawesome/brands/tiktok.svg	Tiktok	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
533	fontawesome	trade-federation	icons/fontawesome/brands/trade-federation.svg	Trade Federation	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
534	fontawesome	trello	icons/fontawesome/brands/trello.svg	Trello	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
535	fontawesome	tumblr-square	icons/fontawesome/brands/tumblr-square.svg	Tumblr Square	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
536	fontawesome	tumblr	icons/fontawesome/brands/tumblr.svg	Tumblr	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
537	fontawesome	twitch	icons/fontawesome/brands/twitch.svg	Twitch	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
539	fontawesome	twitter	icons/fontawesome/brands/twitter.svg	Twitter	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
540	fontawesome	typo3	icons/fontawesome/brands/typo3.svg	Typo3	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
541	fontawesome	uber	icons/fontawesome/brands/uber.svg	Uber	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
542	fontawesome	ubuntu	icons/fontawesome/brands/ubuntu.svg	Ubuntu	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
543	fontawesome	uikit	icons/fontawesome/brands/uikit.svg	Uikit	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
544	fontawesome	umbraco	icons/fontawesome/brands/umbraco.svg	Umbraco	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
545	fontawesome	uncharted	icons/fontawesome/brands/uncharted.svg	Uncharted	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:35:00	public
546	fontawesome	uniregistry	icons/fontawesome/brands/uniregistry.svg	Uniregistry	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:35:00	public
547	fontawesome	unity	icons/fontawesome/brands/unity.svg	Unity	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:35:00	public
548	fontawesome	unsplash	icons/fontawesome/brands/unsplash.svg	Unsplash	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
549	fontawesome	untappd	icons/fontawesome/brands/untappd.svg	Untappd	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
550	fontawesome	ups	icons/fontawesome/brands/ups.svg	Ups	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
551	fontawesome	upwork	icons/fontawesome/brands/upwork.svg	Upwork	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
552	fontawesome	usb	icons/fontawesome/brands/usb.svg	Usb	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
553	fontawesome	usps	icons/fontawesome/brands/usps.svg	Usps	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
555	fontawesome	vaadin	icons/fontawesome/brands/vaadin.svg	Vaadin	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
556	fontawesome	viacoin	icons/fontawesome/brands/viacoin.svg	Viacoin	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
557	fontawesome	viadeo-square	icons/fontawesome/brands/viadeo-square.svg	Viadeo Square	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
558	fontawesome	viadeo	icons/fontawesome/brands/viadeo.svg	Viadeo	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
559	fontawesome	viber	icons/fontawesome/brands/viber.svg	Viber	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
560	fontawesome	vimeo-square	icons/fontawesome/brands/vimeo-square.svg	Vimeo Square	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
561	fontawesome	vimeo-v	icons/fontawesome/brands/vimeo-v.svg	Vimeo V	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:01	public
562	fontawesome	vimeo	icons/fontawesome/brands/vimeo.svg	Vimeo	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:01	public
563	fontawesome	vine	icons/fontawesome/brands/vine.svg	Vine	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
564	fontawesome	vk	icons/fontawesome/brands/vk.svg	Vk	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
565	fontawesome	vnv	icons/fontawesome/brands/vnv.svg	Vnv	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
566	fontawesome	vsco	icons/fontawesome/brands/vsco.svg	Vsco	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
568	fontawesome	w3c	icons/fontawesome/brands/w3c.svg	W3C	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
569	fontawesome	watchman-monitoring	icons/fontawesome/brands/watchman-monitoring.svg	Watchman Monitoring	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
570	fontawesome	waze	icons/fontawesome/brands/waze.svg	Waze	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
571	fontawesome	web-awesome	icons/fontawesome/brands/web-awesome.svg	Web Awesome	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
572	fontawesome	webflow	icons/fontawesome/brands/webflow.svg	Webflow	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
573	fontawesome	weebly	icons/fontawesome/brands/weebly.svg	Weebly	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
574	fontawesome	weibo	icons/fontawesome/brands/weibo.svg	Weibo	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
575	fontawesome	weixin	icons/fontawesome/brands/weixin.svg	Weixin	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
576	fontawesome	whatsapp-square	icons/fontawesome/brands/whatsapp-square.svg	Whatsapp Square	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:02	public
577	fontawesome	whatsapp	icons/fontawesome/brands/whatsapp.svg	Whatsapp	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:02	public
578	fontawesome	whmcs	icons/fontawesome/brands/whmcs.svg	Whmcs	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:02	public
580	fontawesome	windows	icons/fontawesome/brands/windows.svg	Windows	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
581	fontawesome	wirsindhandwerk	icons/fontawesome/brands/wirsindhandwerk.svg	Wirsindhandwerk	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
582	fontawesome	wix	icons/fontawesome/brands/wix.svg	Wix	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
583	fontawesome	wizards-of-the-coast	icons/fontawesome/brands/wizards-of-the-coast.svg	Wizards Of The Coast	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
584	fontawesome	wodu	icons/fontawesome/brands/wodu.svg	Wodu	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
585	fontawesome	wolf-pack-battalion	icons/fontawesome/brands/wolf-pack-battalion.svg	Wolf Pack Battalion	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
587	fontawesome	wordpress	icons/fontawesome/brands/wordpress.svg	Wordpress	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
589	fontawesome	wpexplorer	icons/fontawesome/brands/wpexplorer.svg	Wpexplorer	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
590	fontawesome	wpforms	icons/fontawesome/brands/wpforms.svg	Wpforms	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
591	fontawesome	wpressr	icons/fontawesome/brands/wpressr.svg	Wpressr	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
592	fontawesome	wsh	icons/fontawesome/brands/wsh.svg	Wsh	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
593	fontawesome	x-twitter	icons/fontawesome/brands/x-twitter.svg	X Twitter	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:03	public
594	fontawesome	xbox	icons/fontawesome/brands/xbox.svg	Xbox	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:03	public
595	fontawesome	xing-square	icons/fontawesome/brands/xing-square.svg	Xing Square	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
596	fontawesome	xing	icons/fontawesome/brands/xing.svg	Xing	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
597	fontawesome	y-combinator	icons/fontawesome/brands/y-combinator.svg	Y Combinator	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
598	fontawesome	yahoo	icons/fontawesome/brands/yahoo.svg	Yahoo	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
599	fontawesome	yammer	icons/fontawesome/brands/yammer.svg	Yammer	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
601	fontawesome	yandex	icons/fontawesome/brands/yandex.svg	Yandex	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
602	fontawesome	yarn	icons/fontawesome/brands/yarn.svg	Yarn	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
603	fontawesome	yelp	icons/fontawesome/brands/yelp.svg	Yelp	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
604	fontawesome	yoast	icons/fontawesome/brands/yoast.svg	Yoast	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
605	fontawesome	youtube-square	icons/fontawesome/brands/youtube-square.svg	Youtube Square	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
606	fontawesome	youtube	icons/fontawesome/brands/youtube.svg	Youtube	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
607	fontawesome	zhihu	icons/fontawesome/brands/zhihu.svg	Zhihu	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
608	fontawesome	address-book	icons/fontawesome/regular/address-book.svg	Address Book	regular	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
609	fontawesome	address-card	icons/fontawesome/regular/address-card.svg	Address Card	regular	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:04	public
610	fontawesome	alarm-clock	icons/fontawesome/regular/alarm-clock.svg	Alarm Clock	regular	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:04	public
611	fontawesome	angry	icons/fontawesome/regular/angry.svg	Angry	regular	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:04	public
612	fontawesome	arrow-alt-circle-down	icons/fontawesome/regular/arrow-alt-circle-down.svg	Arrow Alt Circle Down	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
614	fontawesome	arrow-alt-circle-right	icons/fontawesome/regular/arrow-alt-circle-right.svg	Arrow Alt Circle Right	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
615	fontawesome	arrow-alt-circle-up	icons/fontawesome/regular/arrow-alt-circle-up.svg	Arrow Alt Circle Up	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
616	fontawesome	bar-chart	icons/fontawesome/regular/bar-chart.svg	Bar Chart	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
617	fontawesome	bell-slash	icons/fontawesome/regular/bell-slash.svg	Bell Slash	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
618	fontawesome	bell	icons/fontawesome/regular/bell.svg	Bell	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
619	fontawesome	bookmark	icons/fontawesome/regular/bookmark.svg	Bookmark	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
620	fontawesome	building	icons/fontawesome/regular/building.svg	Building	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
621	fontawesome	calendar-alt	icons/fontawesome/regular/calendar-alt.svg	Calendar Alt	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
622	fontawesome	calendar-check	icons/fontawesome/regular/calendar-check.svg	Calendar Check	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
623	fontawesome	calendar-days	icons/fontawesome/regular/calendar-days.svg	Calendar Days	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
625	fontawesome	calendar-plus	icons/fontawesome/regular/calendar-plus.svg	Calendar Plus	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:05	public
626	fontawesome	calendar-times	icons/fontawesome/regular/calendar-times.svg	Calendar Times	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:05	public
627	fontawesome	calendar-xmark	icons/fontawesome/regular/calendar-xmark.svg	Calendar Xmark	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:05	public
628	fontawesome	calendar	icons/fontawesome/regular/calendar.svg	Calendar	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
629	fontawesome	camera-alt	icons/fontawesome/regular/camera-alt.svg	Camera Alt	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
630	fontawesome	camera	icons/fontawesome/regular/camera.svg	Camera	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
631	fontawesome	caret-square-down	icons/fontawesome/regular/caret-square-down.svg	Caret Square Down	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
632	fontawesome	caret-square-left	icons/fontawesome/regular/caret-square-left.svg	Caret Square Left	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
633	fontawesome	caret-square-right	icons/fontawesome/regular/caret-square-right.svg	Caret Square Right	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
635	fontawesome	chart-bar	icons/fontawesome/regular/chart-bar.svg	Chart Bar	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
636	fontawesome	check-circle	icons/fontawesome/regular/check-circle.svg	Check Circle	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
637	fontawesome	check-square	icons/fontawesome/regular/check-square.svg	Check Square	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
638	fontawesome	chess-bishop	icons/fontawesome/regular/chess-bishop.svg	Chess Bishop	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
639	fontawesome	chess-king	icons/fontawesome/regular/chess-king.svg	Chess King	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
640	fontawesome	chess-knight	icons/fontawesome/regular/chess-knight.svg	Chess Knight	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
641	fontawesome	chess-pawn	icons/fontawesome/regular/chess-pawn.svg	Chess Pawn	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
643	fontawesome	chess-rook	icons/fontawesome/regular/chess-rook.svg	Chess Rook	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:06	public
644	fontawesome	circle-check	icons/fontawesome/regular/circle-check.svg	Circle Check	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
645	fontawesome	circle-dot	icons/fontawesome/regular/circle-dot.svg	Circle Dot	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
646	fontawesome	circle-down	icons/fontawesome/regular/circle-down.svg	Circle Down	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
647	fontawesome	circle-left	icons/fontawesome/regular/circle-left.svg	Circle Left	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
649	fontawesome	circle-play	icons/fontawesome/regular/circle-play.svg	Circle Play	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
650	fontawesome	circle-question	icons/fontawesome/regular/circle-question.svg	Circle Question	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
651	fontawesome	circle-right	icons/fontawesome/regular/circle-right.svg	Circle Right	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
652	fontawesome	circle-stop	icons/fontawesome/regular/circle-stop.svg	Circle Stop	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
653	fontawesome	circle-up	icons/fontawesome/regular/circle-up.svg	Circle Up	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
654	fontawesome	circle-user	icons/fontawesome/regular/circle-user.svg	Circle User	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
655	fontawesome	circle-xmark	icons/fontawesome/regular/circle-xmark.svg	Circle Xmark	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
656	fontawesome	circle	icons/fontawesome/regular/circle.svg	Circle	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
657	fontawesome	clipboard	icons/fontawesome/regular/clipboard.svg	Clipboard	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
659	fontawesome	clock	icons/fontawesome/regular/clock.svg	Clock	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
660	fontawesome	clone	icons/fontawesome/regular/clone.svg	Clone	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
661	fontawesome	closed-captioning	icons/fontawesome/regular/closed-captioning.svg	Closed Captioning	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
662	fontawesome	cloud	icons/fontawesome/regular/cloud.svg	Cloud	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
663	fontawesome	comment-alt	icons/fontawesome/regular/comment-alt.svg	Comment Alt	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
664	fontawesome	comment-dots	icons/fontawesome/regular/comment-dots.svg	Comment Dots	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
665	fontawesome	comment	icons/fontawesome/regular/comment.svg	Comment	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
666	fontawesome	commenting	icons/fontawesome/regular/commenting.svg	Commenting	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
667	fontawesome	comments	icons/fontawesome/regular/comments.svg	Comments	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
668	fontawesome	compass	icons/fontawesome/regular/compass.svg	Compass	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
670	fontawesome	contact-card	icons/fontawesome/regular/contact-card.svg	Contact Card	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
671	fontawesome	copy	icons/fontawesome/regular/copy.svg	Copy	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:08	public
672	fontawesome	copyright	icons/fontawesome/regular/copyright.svg	Copyright	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:08	public
673	fontawesome	credit-card-alt	icons/fontawesome/regular/credit-card-alt.svg	Credit Card Alt	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:08	public
674	fontawesome	credit-card	icons/fontawesome/regular/credit-card.svg	Credit Card	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:08	public
675	fontawesome	dizzy	icons/fontawesome/regular/dizzy.svg	Dizzy	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:08	public
676	fontawesome	dot-circle	icons/fontawesome/regular/dot-circle.svg	Dot Circle	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
677	fontawesome	drivers-license	icons/fontawesome/regular/drivers-license.svg	Drivers License	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
678	fontawesome	edit	icons/fontawesome/regular/edit.svg	Edit	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
680	fontawesome	envelope	icons/fontawesome/regular/envelope.svg	Envelope	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
681	fontawesome	eye-slash	icons/fontawesome/regular/eye-slash.svg	Eye Slash	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
682	fontawesome	eye	icons/fontawesome/regular/eye.svg	Eye	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
683	fontawesome	face-angry	icons/fontawesome/regular/face-angry.svg	Face Angry	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
684	fontawesome	face-dizzy	icons/fontawesome/regular/face-dizzy.svg	Face Dizzy	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
685	fontawesome	face-flushed	icons/fontawesome/regular/face-flushed.svg	Face Flushed	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:09	public
686	fontawesome	face-frown-open	icons/fontawesome/regular/face-frown-open.svg	Face Frown Open	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:09	public
687	fontawesome	face-frown	icons/fontawesome/regular/face-frown.svg	Face Frown	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:09	public
688	fontawesome	face-grimace	icons/fontawesome/regular/face-grimace.svg	Face Grimace	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:09	public
690	fontawesome	face-grin-beam	icons/fontawesome/regular/face-grin-beam.svg	Face Grin Beam	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:09	public
691	fontawesome	face-grin-hearts	icons/fontawesome/regular/face-grin-hearts.svg	Face Grin Hearts	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:09	public
692	fontawesome	face-grin-squint-tears	icons/fontawesome/regular/face-grin-squint-tears.svg	Face Grin Squint Tears	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
693	fontawesome	face-grin-squint	icons/fontawesome/regular/face-grin-squint.svg	Face Grin Squint	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
694	fontawesome	face-grin-stars	icons/fontawesome/regular/face-grin-stars.svg	Face Grin Stars	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
695	fontawesome	face-grin-tears	icons/fontawesome/regular/face-grin-tears.svg	Face Grin Tears	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
696	fontawesome	face-grin-tongue-squint	icons/fontawesome/regular/face-grin-tongue-squint.svg	Face Grin Tongue Squint	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
698	fontawesome	face-grin-tongue	icons/fontawesome/regular/face-grin-tongue.svg	Face Grin Tongue	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
700	fontawesome	face-grin-wink	icons/fontawesome/regular/face-grin-wink.svg	Face Grin Wink	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
701	fontawesome	face-grin	icons/fontawesome/regular/face-grin.svg	Face Grin	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:10	public
702	fontawesome	face-kiss-beam	icons/fontawesome/regular/face-kiss-beam.svg	Face Kiss Beam	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:10	public
703	fontawesome	face-kiss-wink-heart	icons/fontawesome/regular/face-kiss-wink-heart.svg	Face Kiss Wink Heart	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:10	public
704	fontawesome	face-kiss	icons/fontawesome/regular/face-kiss.svg	Face Kiss	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:10	public
705	fontawesome	face-laugh-beam	icons/fontawesome/regular/face-laugh-beam.svg	Face Laugh Beam	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:10	public
706	fontawesome	face-laugh-squint	icons/fontawesome/regular/face-laugh-squint.svg	Face Laugh Squint	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:10	public
707	fontawesome	face-laugh-wink	icons/fontawesome/regular/face-laugh-wink.svg	Face Laugh Wink	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:10	public
709	fontawesome	face-meh-blank	icons/fontawesome/regular/face-meh-blank.svg	Face Meh Blank	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
710	fontawesome	face-meh	icons/fontawesome/regular/face-meh.svg	Face Meh	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
711	fontawesome	face-rolling-eyes	icons/fontawesome/regular/face-rolling-eyes.svg	Face Rolling Eyes	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
712	fontawesome	face-sad-cry	icons/fontawesome/regular/face-sad-cry.svg	Face Sad Cry	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
713	fontawesome	face-sad-tear	icons/fontawesome/regular/face-sad-tear.svg	Face Sad Tear	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
714	fontawesome	face-smile-beam	icons/fontawesome/regular/face-smile-beam.svg	Face Smile Beam	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
715	fontawesome	face-smile-wink	icons/fontawesome/regular/face-smile-wink.svg	Face Smile Wink	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
716	fontawesome	face-smile	icons/fontawesome/regular/face-smile.svg	Face Smile	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
718	fontawesome	face-tired	icons/fontawesome/regular/face-tired.svg	Face Tired	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:11	public
719	fontawesome	file-alt	icons/fontawesome/regular/file-alt.svg	File Alt	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:11	public
720	fontawesome	file-archive	icons/fontawesome/regular/file-archive.svg	File Archive	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:11	public
721	fontawesome	file-audio	icons/fontawesome/regular/file-audio.svg	File Audio	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:11	public
722	fontawesome	file-clipboard	icons/fontawesome/regular/file-clipboard.svg	File Clipboard	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:11	public
723	fontawesome	file-code	icons/fontawesome/regular/file-code.svg	File Code	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:11	public
724	fontawesome	file-excel	icons/fontawesome/regular/file-excel.svg	File Excel	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:11	public
725	fontawesome	file-image	icons/fontawesome/regular/file-image.svg	File Image	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
726	fontawesome	file-lines	icons/fontawesome/regular/file-lines.svg	File Lines	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
727	fontawesome	file-pdf	icons/fontawesome/regular/file-pdf.svg	File Pdf	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
729	fontawesome	file-text	icons/fontawesome/regular/file-text.svg	File Text	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
730	fontawesome	file-video	icons/fontawesome/regular/file-video.svg	File Video	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
731	fontawesome	file-word	icons/fontawesome/regular/file-word.svg	File Word	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
732	fontawesome	file-zipper	icons/fontawesome/regular/file-zipper.svg	File Zipper	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
733	fontawesome	file	icons/fontawesome/regular/file.svg	File	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
734	fontawesome	flag	icons/fontawesome/regular/flag.svg	Flag	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:12	public
735	fontawesome	floppy-disk	icons/fontawesome/regular/floppy-disk.svg	Floppy Disk	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:12	public
736	fontawesome	flushed	icons/fontawesome/regular/flushed.svg	Flushed	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:12	public
737	fontawesome	folder-blank	icons/fontawesome/regular/folder-blank.svg	Folder Blank	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:12	public
738	fontawesome	folder-closed	icons/fontawesome/regular/folder-closed.svg	Folder Closed	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:12	public
739	fontawesome	folder-open	icons/fontawesome/regular/folder-open.svg	Folder Open	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:12	public
740	fontawesome	folder	icons/fontawesome/regular/folder.svg	Folder	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:12	public
742	fontawesome	font-awesome-logo-full	icons/fontawesome/regular/font-awesome-logo-full.svg	Font Awesome Logo Full	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
743	fontawesome	font-awesome	icons/fontawesome/regular/font-awesome.svg	Font Awesome	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
744	fontawesome	frown-open	icons/fontawesome/regular/frown-open.svg	Frown Open	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
745	fontawesome	frown	icons/fontawesome/regular/frown.svg	Frown	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
746	fontawesome	futbol-ball	icons/fontawesome/regular/futbol-ball.svg	Futbol Ball	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
747	fontawesome	futbol	icons/fontawesome/regular/futbol.svg	Futbol	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
748	fontawesome	gem	icons/fontawesome/regular/gem.svg	Gem	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
749	fontawesome	grimace	icons/fontawesome/regular/grimace.svg	Grimace	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
750	fontawesome	grin-alt	icons/fontawesome/regular/grin-alt.svg	Grin Alt	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:13	public
751	fontawesome	grin-beam-sweat	icons/fontawesome/regular/grin-beam-sweat.svg	Grin Beam Sweat	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:13	public
754	fontawesome	grin-squint-tears	icons/fontawesome/regular/grin-squint-tears.svg	Grin Squint Tears	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:13	public
755	fontawesome	grin-squint	icons/fontawesome/regular/grin-squint.svg	Grin Squint	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:13	public
756	fontawesome	grin-stars	icons/fontawesome/regular/grin-stars.svg	Grin Stars	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:13	public
757	fontawesome	grin-tears	icons/fontawesome/regular/grin-tears.svg	Grin Tears	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
758	fontawesome	grin-tongue-squint	icons/fontawesome/regular/grin-tongue-squint.svg	Grin Tongue Squint	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
759	fontawesome	grin-tongue-wink	icons/fontawesome/regular/grin-tongue-wink.svg	Grin Tongue Wink	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
760	fontawesome	grin-tongue	icons/fontawesome/regular/grin-tongue.svg	Grin Tongue	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
761	fontawesome	grin-wink	icons/fontawesome/regular/grin-wink.svg	Grin Wink	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
762	fontawesome	grin	icons/fontawesome/regular/grin.svg	Grin	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
764	fontawesome	hand-lizard	icons/fontawesome/regular/hand-lizard.svg	Hand Lizard	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
765	fontawesome	hand-paper	icons/fontawesome/regular/hand-paper.svg	Hand Paper	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
766	fontawesome	hand-peace	icons/fontawesome/regular/hand-peace.svg	Hand Peace	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
767	fontawesome	hand-point-down	icons/fontawesome/regular/hand-point-down.svg	Hand Point Down	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:14	public
768	fontawesome	hand-point-left	icons/fontawesome/regular/hand-point-left.svg	Hand Point Left	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:14	public
769	fontawesome	hand-point-right	icons/fontawesome/regular/hand-point-right.svg	Hand Point Right	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:14	public
770	fontawesome	hand-point-up	icons/fontawesome/regular/hand-point-up.svg	Hand Point Up	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:14	public
771	fontawesome	hand-pointer	icons/fontawesome/regular/hand-pointer.svg	Hand Pointer	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:14	public
772	fontawesome	hand-rock	icons/fontawesome/regular/hand-rock.svg	Hand Rock	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
774	fontawesome	hand-spock	icons/fontawesome/regular/hand-spock.svg	Hand Spock	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
775	fontawesome	hand	icons/fontawesome/regular/hand.svg	Hand	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
776	fontawesome	handshake-alt	icons/fontawesome/regular/handshake-alt.svg	Handshake Alt	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
777	fontawesome	handshake-simple	icons/fontawesome/regular/handshake-simple.svg	Handshake Simple	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
778	fontawesome	handshake	icons/fontawesome/regular/handshake.svg	Handshake	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
779	fontawesome	hard-drive	icons/fontawesome/regular/hard-drive.svg	Hard Drive	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
780	fontawesome	hdd	icons/fontawesome/regular/hdd.svg	Hdd	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
781	fontawesome	headphones-alt	icons/fontawesome/regular/headphones-alt.svg	Headphones Alt	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
783	fontawesome	headphones	icons/fontawesome/regular/headphones.svg	Headphones	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:15	public
784	fontawesome	heart	icons/fontawesome/regular/heart.svg	Heart	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:15	public
785	fontawesome	home-alt	icons/fontawesome/regular/home-alt.svg	Home Alt	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:15	public
786	fontawesome	home-lg-alt	icons/fontawesome/regular/home-lg-alt.svg	Home Lg Alt	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:15	public
787	fontawesome	home	icons/fontawesome/regular/home.svg	Home	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:15	public
788	fontawesome	hospital-alt	icons/fontawesome/regular/hospital-alt.svg	Hospital Alt	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:15	public
789	fontawesome	hospital-wide	icons/fontawesome/regular/hospital-wide.svg	Hospital Wide	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
790	fontawesome	hospital	icons/fontawesome/regular/hospital.svg	Hospital	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
791	fontawesome	hourglass-2	icons/fontawesome/regular/hourglass-2.svg	Hourglass 2	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
792	fontawesome	hourglass-empty	icons/fontawesome/regular/hourglass-empty.svg	Hourglass Empty	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
793	fontawesome	hourglass-half	icons/fontawesome/regular/hourglass-half.svg	Hourglass Half	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
794	fontawesome	hourglass	icons/fontawesome/regular/hourglass.svg	Hourglass	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
795	fontawesome	house	icons/fontawesome/regular/house.svg	House	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
797	fontawesome	id-card	icons/fontawesome/regular/id-card.svg	Id Card	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
798	fontawesome	image	icons/fontawesome/regular/image.svg	Image	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
799	fontawesome	images	icons/fontawesome/regular/images.svg	Images	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:16	public
800	fontawesome	keyboard	icons/fontawesome/regular/keyboard.svg	Keyboard	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:16	public
801	fontawesome	kiss-beam	icons/fontawesome/regular/kiss-beam.svg	Kiss Beam	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:16	public
802	fontawesome	kiss-wink-heart	icons/fontawesome/regular/kiss-wink-heart.svg	Kiss Wink Heart	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:16	public
803	fontawesome	kiss	icons/fontawesome/regular/kiss.svg	Kiss	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:16	public
804	fontawesome	laugh-beam	icons/fontawesome/regular/laugh-beam.svg	Laugh Beam	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:16	public
805	fontawesome	laugh-squint	icons/fontawesome/regular/laugh-squint.svg	Laugh Squint	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
807	fontawesome	laugh	icons/fontawesome/regular/laugh.svg	Laugh	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
810	fontawesome	lightbulb	icons/fontawesome/regular/lightbulb.svg	Lightbulb	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
811	fontawesome	list-alt	icons/fontawesome/regular/list-alt.svg	List Alt	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
812	fontawesome	map	icons/fontawesome/regular/map.svg	Map	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
813	fontawesome	meh-blank	icons/fontawesome/regular/meh-blank.svg	Meh Blank	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
814	fontawesome	meh-rolling-eyes	icons/fontawesome/regular/meh-rolling-eyes.svg	Meh Rolling Eyes	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
815	fontawesome	meh	icons/fontawesome/regular/meh.svg	Meh	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
816	fontawesome	message	icons/fontawesome/regular/message.svg	Message	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:17	public
817	fontawesome	minus-square	icons/fontawesome/regular/minus-square.svg	Minus Square	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:17	public
819	fontawesome	money-bill-alt	icons/fontawesome/regular/money-bill-alt.svg	Money Bill Alt	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:17	public
820	fontawesome	moon	icons/fontawesome/regular/moon.svg	Moon	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:17	public
821	fontawesome	newspaper	icons/fontawesome/regular/newspaper.svg	Newspaper	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
822	fontawesome	note-sticky	icons/fontawesome/regular/note-sticky.svg	Note Sticky	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
823	fontawesome	object-group	icons/fontawesome/regular/object-group.svg	Object Group	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
824	fontawesome	object-ungroup	icons/fontawesome/regular/object-ungroup.svg	Object Ungroup	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
825	fontawesome	paper-plane	icons/fontawesome/regular/paper-plane.svg	Paper Plane	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
826	fontawesome	paste	icons/fontawesome/regular/paste.svg	Paste	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
827	fontawesome	pause-circle	icons/fontawesome/regular/pause-circle.svg	Pause Circle	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
828	fontawesome	pen-to-square	icons/fontawesome/regular/pen-to-square.svg	Pen To Square	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
830	fontawesome	plus-square	icons/fontawesome/regular/plus-square.svg	Plus Square	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
831	fontawesome	question-circle	icons/fontawesome/regular/question-circle.svg	Question Circle	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
832	fontawesome	rectangle-list	icons/fontawesome/regular/rectangle-list.svg	Rectangle List	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
833	fontawesome	rectangle-times	icons/fontawesome/regular/rectangle-times.svg	Rectangle Times	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:18	public
834	fontawesome	rectangle-xmark	icons/fontawesome/regular/rectangle-xmark.svg	Rectangle Xmark	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:18	public
835	fontawesome	registered	icons/fontawesome/regular/registered.svg	Registered	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:18	public
836	fontawesome	sad-cry	icons/fontawesome/regular/sad-cry.svg	Sad Cry	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:18	public
837	fontawesome	sad-tear	icons/fontawesome/regular/sad-tear.svg	Sad Tear	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
838	fontawesome	save	icons/fontawesome/regular/save.svg	Save	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
840	fontawesome	share-square	icons/fontawesome/regular/share-square.svg	Share Square	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
841	fontawesome	smile-beam	icons/fontawesome/regular/smile-beam.svg	Smile Beam	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
842	fontawesome	smile-wink	icons/fontawesome/regular/smile-wink.svg	Smile Wink	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
843	fontawesome	smile	icons/fontawesome/regular/smile.svg	Smile	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
844	fontawesome	snowflake	icons/fontawesome/regular/snowflake.svg	Snowflake	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
845	fontawesome	soccer-ball	icons/fontawesome/regular/soccer-ball.svg	Soccer Ball	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
846	fontawesome	square-caret-down	icons/fontawesome/regular/square-caret-down.svg	Square Caret Down	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
847	fontawesome	square-caret-left	icons/fontawesome/regular/square-caret-left.svg	Square Caret Left	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
849	fontawesome	square-caret-up	icons/fontawesome/regular/square-caret-up.svg	Square Caret Up	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:19	public
850	fontawesome	square-check	icons/fontawesome/regular/square-check.svg	Square Check	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:19	public
851	fontawesome	square-full	icons/fontawesome/regular/square-full.svg	Square Full	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:19	public
852	fontawesome	square-minus	icons/fontawesome/regular/square-minus.svg	Square Minus	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:19	public
853	fontawesome	square-plus	icons/fontawesome/regular/square-plus.svg	Square Plus	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:19	public
854	fontawesome	square	icons/fontawesome/regular/square.svg	Square	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
855	fontawesome	star-half-alt	icons/fontawesome/regular/star-half-alt.svg	Star Half Alt	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
856	fontawesome	star-half-stroke	icons/fontawesome/regular/star-half-stroke.svg	Star Half Stroke	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
857	fontawesome	star-half	icons/fontawesome/regular/star-half.svg	Star Half	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
858	fontawesome	star	icons/fontawesome/regular/star.svg	Star	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
859	fontawesome	sticky-note	icons/fontawesome/regular/sticky-note.svg	Sticky Note	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
860	fontawesome	stop-circle	icons/fontawesome/regular/stop-circle.svg	Stop Circle	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
861	fontawesome	sun	icons/fontawesome/regular/sun.svg	Sun	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
863	fontawesome	thumbs-down	icons/fontawesome/regular/thumbs-down.svg	Thumbs Down	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
866	fontawesome	times-rectangle	icons/fontawesome/regular/times-rectangle.svg	Times Rectangle	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:20	public
867	fontawesome	tired	icons/fontawesome/regular/tired.svg	Tired	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:20	public
868	fontawesome	trash-alt	icons/fontawesome/regular/trash-alt.svg	Trash Alt	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:20	public
869	fontawesome	trash-can	icons/fontawesome/regular/trash-can.svg	Trash Can	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
870	fontawesome	truck	icons/fontawesome/regular/truck.svg	Truck	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
871	fontawesome	user-alt	icons/fontawesome/regular/user-alt.svg	User Alt	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
872	fontawesome	user-circle	icons/fontawesome/regular/user-circle.svg	User Circle	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
873	fontawesome	user-large	icons/fontawesome/regular/user-large.svg	User Large	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
874	fontawesome	user	icons/fontawesome/regular/user.svg	User	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
875	fontawesome	vcard	icons/fontawesome/regular/vcard.svg	Vcard	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
877	fontawesome	window-maximize	icons/fontawesome/regular/window-maximize.svg	Window Maximize	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
878	fontawesome	window-minimize	icons/fontawesome/regular/window-minimize.svg	Window Minimize	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
879	fontawesome	window-restore	icons/fontawesome/regular/window-restore.svg	Window Restore	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
880	fontawesome	xmark-circle	icons/fontawesome/regular/xmark-circle.svg	Xmark Circle	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
881	fontawesome	0	icons/fontawesome/solid/0.svg	0	solid	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
882	fontawesome	1	icons/fontawesome/solid/1.svg	1	solid	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:21	public
883	fontawesome	2	icons/fontawesome/solid/2.svg	2	solid	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:21	public
884	fontawesome	3	icons/fontawesome/solid/3.svg	3	solid	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:21	public
885	fontawesome	4	icons/fontawesome/solid/4.svg	4	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
886	fontawesome	5	icons/fontawesome/solid/5.svg	5	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
887	fontawesome	6	icons/fontawesome/solid/6.svg	6	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
888	fontawesome	7	icons/fontawesome/solid/7.svg	7	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
889	fontawesome	8	icons/fontawesome/solid/8.svg	8	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
890	fontawesome	9	icons/fontawesome/solid/9.svg	9	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
891	fontawesome	a	icons/fontawesome/solid/a.svg	A	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
892	fontawesome	ad	icons/fontawesome/solid/ad.svg	Ad	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
893	fontawesome	add	icons/fontawesome/solid/add.svg	Add	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
895	fontawesome	address-card	icons/fontawesome/solid/address-card.svg	Address Card	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
896	fontawesome	adjust	icons/fontawesome/solid/adjust.svg	Adjust	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
897	fontawesome	air-freshener	icons/fontawesome/solid/air-freshener.svg	Air Freshener	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
898	fontawesome	alarm-clock	icons/fontawesome/solid/alarm-clock.svg	Alarm Clock	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
899	fontawesome	align-center	icons/fontawesome/solid/align-center.svg	Align Center	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:22	public
900	fontawesome	align-justify	icons/fontawesome/solid/align-justify.svg	Align Justify	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:22	public
901	fontawesome	align-left	icons/fontawesome/solid/align-left.svg	Align Left	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
902	fontawesome	align-right	icons/fontawesome/solid/align-right.svg	Align Right	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
903	fontawesome	allergies	icons/fontawesome/solid/allergies.svg	Allergies	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
904	fontawesome	ambulance	icons/fontawesome/solid/ambulance.svg	Ambulance	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
906	fontawesome	anchor-circle-check	icons/fontawesome/solid/anchor-circle-check.svg	Anchor Circle Check	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
907	fontawesome	anchor-circle-exclamation	icons/fontawesome/solid/anchor-circle-exclamation.svg	Anchor Circle Exclamation	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
908	fontawesome	anchor-circle-xmark	icons/fontawesome/solid/anchor-circle-xmark.svg	Anchor Circle Xmark	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
909	fontawesome	anchor-lock	icons/fontawesome/solid/anchor-lock.svg	Anchor Lock	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
910	fontawesome	anchor	icons/fontawesome/solid/anchor.svg	Anchor	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
911	fontawesome	angle-double-down	icons/fontawesome/solid/angle-double-down.svg	Angle Double Down	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
912	fontawesome	angle-double-left	icons/fontawesome/solid/angle-double-left.svg	Angle Double Left	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
914	fontawesome	angle-double-up	icons/fontawesome/solid/angle-double-up.svg	Angle Double Up	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
915	fontawesome	angle-down	icons/fontawesome/solid/angle-down.svg	Angle Down	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:23	public
916	fontawesome	angle-left	icons/fontawesome/solid/angle-left.svg	Angle Left	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:23	public
917	fontawesome	angle-right	icons/fontawesome/solid/angle-right.svg	Angle Right	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:23	public
918	fontawesome	angle-up	icons/fontawesome/solid/angle-up.svg	Angle Up	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
919	fontawesome	angles-down	icons/fontawesome/solid/angles-down.svg	Angles Down	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
920	fontawesome	angles-left	icons/fontawesome/solid/angles-left.svg	Angles Left	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
1086	fontawesome	bong	icons/fontawesome/solid/bong.svg	Bong	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:23	public
922	fontawesome	angles-up	icons/fontawesome/solid/angles-up.svg	Angles Up	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
923	fontawesome	angry	icons/fontawesome/solid/angry.svg	Angry	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
924	fontawesome	ankh	icons/fontawesome/solid/ankh.svg	Ankh	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
925	fontawesome	apple-alt	icons/fontawesome/solid/apple-alt.svg	Apple Alt	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
926	fontawesome	apple-whole	icons/fontawesome/solid/apple-whole.svg	Apple Whole	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
927	fontawesome	archive	icons/fontawesome/solid/archive.svg	Archive	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
928	fontawesome	archway	icons/fontawesome/solid/archway.svg	Archway	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
929	fontawesome	area-chart	icons/fontawesome/solid/area-chart.svg	Area Chart	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
931	fontawesome	arrow-alt-circle-left	icons/fontawesome/solid/arrow-alt-circle-left.svg	Arrow Alt Circle Left	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:24	public
932	fontawesome	arrow-alt-circle-right	icons/fontawesome/solid/arrow-alt-circle-right.svg	Arrow Alt Circle Right	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:24	public
933	fontawesome	arrow-alt-circle-up	icons/fontawesome/solid/arrow-alt-circle-up.svg	Arrow Alt Circle Up	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:24	public
934	fontawesome	arrow-circle-down	icons/fontawesome/solid/arrow-circle-down.svg	Arrow Circle Down	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
935	fontawesome	arrow-circle-left	icons/fontawesome/solid/arrow-circle-left.svg	Arrow Circle Left	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
936	fontawesome	arrow-circle-right	icons/fontawesome/solid/arrow-circle-right.svg	Arrow Circle Right	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
937	fontawesome	arrow-circle-up	icons/fontawesome/solid/arrow-circle-up.svg	Arrow Circle Up	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
939	fontawesome	arrow-down-9-1	icons/fontawesome/solid/arrow-down-9-1.svg	Arrow Down 9 1	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
940	fontawesome	arrow-down-a-z	icons/fontawesome/solid/arrow-down-a-z.svg	Arrow Down A Z	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
941	fontawesome	arrow-down-long	icons/fontawesome/solid/arrow-down-long.svg	Arrow Down Long	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
942	fontawesome	arrow-down-short-wide	icons/fontawesome/solid/arrow-down-short-wide.svg	Arrow Down Short Wide	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
943	fontawesome	arrow-down-up-across-line	icons/fontawesome/solid/arrow-down-up-across-line.svg	Arrow Down Up Across Line	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
944	fontawesome	arrow-down-up-lock	icons/fontawesome/solid/arrow-down-up-lock.svg	Arrow Down Up Lock	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
946	fontawesome	arrow-down-z-a	icons/fontawesome/solid/arrow-down-z-a.svg	Arrow Down Z A	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
947	fontawesome	arrow-down	icons/fontawesome/solid/arrow-down.svg	Arrow Down	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:25	public
948	fontawesome	arrow-left-long	icons/fontawesome/solid/arrow-left-long.svg	Arrow Left Long	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:25	public
949	fontawesome	arrow-left-rotate	icons/fontawesome/solid/arrow-left-rotate.svg	Arrow Left Rotate	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:25	public
950	fontawesome	arrow-left	icons/fontawesome/solid/arrow-left.svg	Arrow Left	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
951	fontawesome	arrow-pointer	icons/fontawesome/solid/arrow-pointer.svg	Arrow Pointer	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
952	fontawesome	arrow-right-arrow-left	icons/fontawesome/solid/arrow-right-arrow-left.svg	Arrow Right Arrow Left	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
954	fontawesome	arrow-right-from-file	icons/fontawesome/solid/arrow-right-from-file.svg	Arrow Right From File	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
955	fontawesome	arrow-right-long	icons/fontawesome/solid/arrow-right-long.svg	Arrow Right Long	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
956	fontawesome	arrow-right-rotate	icons/fontawesome/solid/arrow-right-rotate.svg	Arrow Right Rotate	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
957	fontawesome	arrow-right-to-bracket	icons/fontawesome/solid/arrow-right-to-bracket.svg	Arrow Right To Bracket	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
958	fontawesome	arrow-right-to-city	icons/fontawesome/solid/arrow-right-to-city.svg	Arrow Right To City	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
959	fontawesome	arrow-right-to-file	icons/fontawesome/solid/arrow-right-to-file.svg	Arrow Right To File	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
960	fontawesome	arrow-right	icons/fontawesome/solid/arrow-right.svg	Arrow Right	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
961	fontawesome	arrow-rotate-back	icons/fontawesome/solid/arrow-rotate-back.svg	Arrow Rotate Back	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
963	fontawesome	arrow-rotate-forward	icons/fontawesome/solid/arrow-rotate-forward.svg	Arrow Rotate Forward	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
964	fontawesome	arrow-rotate-left	icons/fontawesome/solid/arrow-rotate-left.svg	Arrow Rotate Left	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:26	public
965	fontawesome	arrow-rotate-right	icons/fontawesome/solid/arrow-rotate-right.svg	Arrow Rotate Right	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:26	public
966	fontawesome	arrow-trend-down	icons/fontawesome/solid/arrow-trend-down.svg	Arrow Trend Down	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
967	fontawesome	arrow-trend-up	icons/fontawesome/solid/arrow-trend-up.svg	Arrow Trend Up	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
968	fontawesome	arrow-turn-down	icons/fontawesome/solid/arrow-turn-down.svg	Arrow Turn Down	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
969	fontawesome	arrow-turn-up	icons/fontawesome/solid/arrow-turn-up.svg	Arrow Turn Up	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
970	fontawesome	arrow-up-1-9	icons/fontawesome/solid/arrow-up-1-9.svg	Arrow Up 1 9	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
971	fontawesome	arrow-up-9-1	icons/fontawesome/solid/arrow-up-9-1.svg	Arrow Up 9 1	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
972	fontawesome	arrow-up-a-z	icons/fontawesome/solid/arrow-up-a-z.svg	Arrow Up A Z	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
976	fontawesome	arrow-up-long	icons/fontawesome/solid/arrow-up-long.svg	Arrow Up Long	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
977	fontawesome	arrow-up-right-dots	icons/fontawesome/solid/arrow-up-right-dots.svg	Arrow Up Right Dots	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
978	fontawesome	arrow-up-right-from-square	icons/fontawesome/solid/arrow-up-right-from-square.svg	Arrow Up Right From Square	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
979	fontawesome	arrow-up-short-wide	icons/fontawesome/solid/arrow-up-short-wide.svg	Arrow Up Short Wide	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
980	fontawesome	arrow-up-wide-short	icons/fontawesome/solid/arrow-up-wide-short.svg	Arrow Up Wide Short	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:27	public
981	fontawesome	arrow-up-z-a	icons/fontawesome/solid/arrow-up-z-a.svg	Arrow Up Z A	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:27	public
982	fontawesome	arrow-up	icons/fontawesome/solid/arrow-up.svg	Arrow Up	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
983	fontawesome	arrows-alt-h	icons/fontawesome/solid/arrows-alt-h.svg	Arrows Alt H	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
984	fontawesome	arrows-alt-v	icons/fontawesome/solid/arrows-alt-v.svg	Arrows Alt V	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
985	fontawesome	arrows-alt	icons/fontawesome/solid/arrows-alt.svg	Arrows Alt	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
987	fontawesome	arrows-down-to-people	icons/fontawesome/solid/arrows-down-to-people.svg	Arrows Down To People	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
988	fontawesome	arrows-h	icons/fontawesome/solid/arrows-h.svg	Arrows H	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
989	fontawesome	arrows-left-right-to-line	icons/fontawesome/solid/arrows-left-right-to-line.svg	Arrows Left Right To Line	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
990	fontawesome	arrows-left-right	icons/fontawesome/solid/arrows-left-right.svg	Arrows Left Right	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
991	fontawesome	arrows-rotate	icons/fontawesome/solid/arrows-rotate.svg	Arrows Rotate	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
992	fontawesome	arrows-spin	icons/fontawesome/solid/arrows-spin.svg	Arrows Spin	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
994	fontawesome	arrows-to-circle	icons/fontawesome/solid/arrows-to-circle.svg	Arrows To Circle	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
995	fontawesome	arrows-to-dot	icons/fontawesome/solid/arrows-to-dot.svg	Arrows To Dot	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
996	fontawesome	arrows-to-eye	icons/fontawesome/solid/arrows-to-eye.svg	Arrows To Eye	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
997	fontawesome	arrows-turn-right	icons/fontawesome/solid/arrows-turn-right.svg	Arrows Turn Right	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:28	public
998	fontawesome	arrows-turn-to-dots	icons/fontawesome/solid/arrows-turn-to-dots.svg	Arrows Turn To Dots	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
999	fontawesome	arrows-up-down-left-right	icons/fontawesome/solid/arrows-up-down-left-right.svg	Arrows Up Down Left Right	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1000	fontawesome	arrows-up-down	icons/fontawesome/solid/arrows-up-down.svg	Arrows Up Down	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1001	fontawesome	arrows-up-to-line	icons/fontawesome/solid/arrows-up-to-line.svg	Arrows Up To Line	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1002	fontawesome	arrows-v	icons/fontawesome/solid/arrows-v.svg	Arrows V	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1003	fontawesome	arrows	icons/fontawesome/solid/arrows.svg	Arrows	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1005	fontawesome	assistive-listening-systems	icons/fontawesome/solid/assistive-listening-systems.svg	Assistive Listening Systems	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1006	fontawesome	asterisk	icons/fontawesome/solid/asterisk.svg	Asterisk	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1007	fontawesome	at	icons/fontawesome/solid/at.svg	At	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1008	fontawesome	atlas	icons/fontawesome/solid/atlas.svg	Atlas	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1009	fontawesome	atom	icons/fontawesome/solid/atom.svg	Atom	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1010	fontawesome	audio-description	icons/fontawesome/solid/audio-description.svg	Audio Description	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1011	fontawesome	austral-sign	icons/fontawesome/solid/austral-sign.svg	Austral Sign	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1012	fontawesome	automobile	icons/fontawesome/solid/automobile.svg	Automobile	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1013	fontawesome	award	icons/fontawesome/solid/award.svg	Award	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1014	fontawesome	b	icons/fontawesome/solid/b.svg	B	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:29	public
1015	fontawesome	baby-carriage	icons/fontawesome/solid/baby-carriage.svg	Baby Carriage	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1016	fontawesome	baby	icons/fontawesome/solid/baby.svg	Baby	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1017	fontawesome	backspace	icons/fontawesome/solid/backspace.svg	Backspace	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1019	fontawesome	backward-step	icons/fontawesome/solid/backward-step.svg	Backward Step	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1020	fontawesome	backward	icons/fontawesome/solid/backward.svg	Backward	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1021	fontawesome	bacon	icons/fontawesome/solid/bacon.svg	Bacon	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1022	fontawesome	bacteria	icons/fontawesome/solid/bacteria.svg	Bacteria	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1023	fontawesome	bacterium	icons/fontawesome/solid/bacterium.svg	Bacterium	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1024	fontawesome	bag-shopping	icons/fontawesome/solid/bag-shopping.svg	Bag Shopping	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1025	fontawesome	bahai	icons/fontawesome/solid/bahai.svg	Bahai	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1026	fontawesome	baht-sign	icons/fontawesome/solid/baht-sign.svg	Baht Sign	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1027	fontawesome	balance-scale-left	icons/fontawesome/solid/balance-scale-left.svg	Balance Scale Left	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1542	fontawesome	feather	icons/fontawesome/solid/feather.svg	Feather	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:35:29	public
1029	fontawesome	balance-scale	icons/fontawesome/solid/balance-scale.svg	Balance Scale	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:30	public
1031	fontawesome	ban	icons/fontawesome/solid/ban.svg	Ban	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1032	fontawesome	band-aid	icons/fontawesome/solid/band-aid.svg	Band Aid	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1033	fontawesome	bandage	icons/fontawesome/solid/bandage.svg	Bandage	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1034	fontawesome	bangladeshi-taka-sign	icons/fontawesome/solid/bangladeshi-taka-sign.svg	Bangladeshi Taka Sign	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1035	fontawesome	bank	icons/fontawesome/solid/bank.svg	Bank	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1036	fontawesome	bar-chart	icons/fontawesome/solid/bar-chart.svg	Bar Chart	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1037	fontawesome	barcode	icons/fontawesome/solid/barcode.svg	Barcode	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1038	fontawesome	bars-progress	icons/fontawesome/solid/bars-progress.svg	Bars Progress	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1039	fontawesome	bars-staggered	icons/fontawesome/solid/bars-staggered.svg	Bars Staggered	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1040	fontawesome	bars	icons/fontawesome/solid/bars.svg	Bars	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1042	fontawesome	baseball-bat-ball	icons/fontawesome/solid/baseball-bat-ball.svg	Baseball Bat Ball	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1043	fontawesome	baseball	icons/fontawesome/solid/baseball.svg	Baseball	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1044	fontawesome	basket-shopping	icons/fontawesome/solid/basket-shopping.svg	Basket Shopping	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1045	fontawesome	basketball-ball	icons/fontawesome/solid/basketball-ball.svg	Basketball Ball	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1046	fontawesome	basketball	icons/fontawesome/solid/basketball.svg	Basketball	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:31	public
1047	fontawesome	bath	icons/fontawesome/solid/bath.svg	Bath	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1048	fontawesome	bathtub	icons/fontawesome/solid/bathtub.svg	Bathtub	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1049	fontawesome	battery-0	icons/fontawesome/solid/battery-0.svg	Battery 0	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1050	fontawesome	battery-2	icons/fontawesome/solid/battery-2.svg	Battery 2	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1051	fontawesome	battery-3	icons/fontawesome/solid/battery-3.svg	Battery 3	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1052	fontawesome	battery-4	icons/fontawesome/solid/battery-4.svg	Battery 4	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1054	fontawesome	battery-car	icons/fontawesome/solid/battery-car.svg	Battery Car	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1055	fontawesome	battery-empty	icons/fontawesome/solid/battery-empty.svg	Battery Empty	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1056	fontawesome	battery-full	icons/fontawesome/solid/battery-full.svg	Battery Full	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1057	fontawesome	battery-half	icons/fontawesome/solid/battery-half.svg	Battery Half	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1058	fontawesome	battery-quarter	icons/fontawesome/solid/battery-quarter.svg	Battery Quarter	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1059	fontawesome	battery-three-quarters	icons/fontawesome/solid/battery-three-quarters.svg	Battery Three Quarters	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1060	fontawesome	battery	icons/fontawesome/solid/battery.svg	Battery	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1061	fontawesome	bed-pulse	icons/fontawesome/solid/bed-pulse.svg	Bed Pulse	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1062	fontawesome	bed	icons/fontawesome/solid/bed.svg	Bed	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1064	fontawesome	beer	icons/fontawesome/solid/beer.svg	Beer	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1065	fontawesome	bell-concierge	icons/fontawesome/solid/bell-concierge.svg	Bell Concierge	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1066	fontawesome	bell-slash	icons/fontawesome/solid/bell-slash.svg	Bell Slash	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1067	fontawesome	bell	icons/fontawesome/solid/bell.svg	Bell	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1068	fontawesome	bezier-curve	icons/fontawesome/solid/bezier-curve.svg	Bezier Curve	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1069	fontawesome	bible	icons/fontawesome/solid/bible.svg	Bible	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1070	fontawesome	bicycle	icons/fontawesome/solid/bicycle.svg	Bicycle	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1071	fontawesome	biking	icons/fontawesome/solid/biking.svg	Biking	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1072	fontawesome	binoculars	icons/fontawesome/solid/binoculars.svg	Binoculars	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1073	fontawesome	biohazard	icons/fontawesome/solid/biohazard.svg	Biohazard	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1074	fontawesome	birthday-cake	icons/fontawesome/solid/birthday-cake.svg	Birthday Cake	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1076	fontawesome	blackboard	icons/fontawesome/solid/blackboard.svg	Blackboard	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1077	fontawesome	blender-phone	icons/fontawesome/solid/blender-phone.svg	Blender Phone	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1078	fontawesome	blender	icons/fontawesome/solid/blender.svg	Blender	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1079	fontawesome	blind	icons/fontawesome/solid/blind.svg	Blind	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1080	fontawesome	blog	icons/fontawesome/solid/blog.svg	Blog	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1081	fontawesome	bold	icons/fontawesome/solid/bold.svg	Bold	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1082	fontawesome	bolt-lightning	icons/fontawesome/solid/bolt-lightning.svg	Bolt Lightning	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1083	fontawesome	bolt	icons/fontawesome/solid/bolt.svg	Bolt	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1084	fontawesome	bomb	icons/fontawesome/solid/bomb.svg	Bomb	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1085	fontawesome	bone	icons/fontawesome/solid/bone.svg	Bone	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1088	fontawesome	book-bible	icons/fontawesome/solid/book-bible.svg	Book Bible	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1089	fontawesome	book-bookmark	icons/fontawesome/solid/book-bookmark.svg	Book Bookmark	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1090	fontawesome	book-dead	icons/fontawesome/solid/book-dead.svg	Book Dead	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1091	fontawesome	book-journal-whills	icons/fontawesome/solid/book-journal-whills.svg	Book Journal Whills	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1092	fontawesome	book-medical	icons/fontawesome/solid/book-medical.svg	Book Medical	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1093	fontawesome	book-open-reader	icons/fontawesome/solid/book-open-reader.svg	Book Open Reader	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1094	fontawesome	book-open	icons/fontawesome/solid/book-open.svg	Book Open	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1096	fontawesome	book-reader	icons/fontawesome/solid/book-reader.svg	Book Reader	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:33	public
1097	fontawesome	book-skull	icons/fontawesome/solid/book-skull.svg	Book Skull	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1098	fontawesome	book-tanakh	icons/fontawesome/solid/book-tanakh.svg	Book Tanakh	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1099	fontawesome	book	icons/fontawesome/solid/book.svg	Book	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1100	fontawesome	bookmark	icons/fontawesome/solid/bookmark.svg	Bookmark	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1101	fontawesome	border-all	icons/fontawesome/solid/border-all.svg	Border All	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1102	fontawesome	border-none	icons/fontawesome/solid/border-none.svg	Border None	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1103	fontawesome	border-style	icons/fontawesome/solid/border-style.svg	Border Style	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1104	fontawesome	border-top-left	icons/fontawesome/solid/border-top-left.svg	Border Top Left	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1106	fontawesome	bottle-droplet	icons/fontawesome/solid/bottle-droplet.svg	Bottle Droplet	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1107	fontawesome	bottle-water	icons/fontawesome/solid/bottle-water.svg	Bottle Water	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1108	fontawesome	bowl-food	icons/fontawesome/solid/bowl-food.svg	Bowl Food	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1109	fontawesome	bowl-rice	icons/fontawesome/solid/bowl-rice.svg	Bowl Rice	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1110	fontawesome	bowling-ball	icons/fontawesome/solid/bowling-ball.svg	Bowling Ball	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1111	fontawesome	box-archive	icons/fontawesome/solid/box-archive.svg	Box Archive	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:34	public
1112	fontawesome	box-open	icons/fontawesome/solid/box-open.svg	Box Open	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:34	public
1113	fontawesome	box-tissue	icons/fontawesome/solid/box-tissue.svg	Box Tissue	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1114	fontawesome	box	icons/fontawesome/solid/box.svg	Box	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1115	fontawesome	boxes-alt	icons/fontawesome/solid/boxes-alt.svg	Boxes Alt	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1117	fontawesome	boxes-stacked	icons/fontawesome/solid/boxes-stacked.svg	Boxes Stacked	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1118	fontawesome	boxes	icons/fontawesome/solid/boxes.svg	Boxes	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1119	fontawesome	braille	icons/fontawesome/solid/braille.svg	Braille	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1120	fontawesome	brain	icons/fontawesome/solid/brain.svg	Brain	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1121	fontawesome	brazilian-real-sign	icons/fontawesome/solid/brazilian-real-sign.svg	Brazilian Real Sign	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1122	fontawesome	bread-slice	icons/fontawesome/solid/bread-slice.svg	Bread Slice	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1123	fontawesome	bridge-circle-check	icons/fontawesome/solid/bridge-circle-check.svg	Bridge Circle Check	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1125	fontawesome	bridge-circle-xmark	icons/fontawesome/solid/bridge-circle-xmark.svg	Bridge Circle Xmark	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1126	fontawesome	bridge-lock	icons/fontawesome/solid/bridge-lock.svg	Bridge Lock	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1127	fontawesome	bridge-water	icons/fontawesome/solid/bridge-water.svg	Bridge Water	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1128	fontawesome	bridge	icons/fontawesome/solid/bridge.svg	Bridge	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:35	public
1129	fontawesome	briefcase-clock	icons/fontawesome/solid/briefcase-clock.svg	Briefcase Clock	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1130	fontawesome	briefcase-medical	icons/fontawesome/solid/briefcase-medical.svg	Briefcase Medical	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1131	fontawesome	briefcase	icons/fontawesome/solid/briefcase.svg	Briefcase	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1132	fontawesome	broadcast-tower	icons/fontawesome/solid/broadcast-tower.svg	Broadcast Tower	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1133	fontawesome	broom-ball	icons/fontawesome/solid/broom-ball.svg	Broom Ball	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1134	fontawesome	broom	icons/fontawesome/solid/broom.svg	Broom	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1135	fontawesome	brush	icons/fontawesome/solid/brush.svg	Brush	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1136	fontawesome	bucket	icons/fontawesome/solid/bucket.svg	Bucket	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1138	fontawesome	bug	icons/fontawesome/solid/bug.svg	Bug	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1139	fontawesome	bugs	icons/fontawesome/solid/bugs.svg	Bugs	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1140	fontawesome	building-circle-arrow-right	icons/fontawesome/solid/building-circle-arrow-right.svg	Building Circle Arrow Right	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1141	fontawesome	building-circle-check	icons/fontawesome/solid/building-circle-check.svg	Building Circle Check	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1145	fontawesome	building-flag	icons/fontawesome/solid/building-flag.svg	Building Flag	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:36	public
1146	fontawesome	building-lock	icons/fontawesome/solid/building-lock.svg	Building Lock	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1147	fontawesome	building-ngo	icons/fontawesome/solid/building-ngo.svg	Building Ngo	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1148	fontawesome	building-shield	icons/fontawesome/solid/building-shield.svg	Building Shield	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1149	fontawesome	building-un	icons/fontawesome/solid/building-un.svg	Building Un	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1150	fontawesome	building-user	icons/fontawesome/solid/building-user.svg	Building User	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1151	fontawesome	building-wheat	icons/fontawesome/solid/building-wheat.svg	Building Wheat	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1152	fontawesome	building	icons/fontawesome/solid/building.svg	Building	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1153	fontawesome	bullhorn	icons/fontawesome/solid/bullhorn.svg	Bullhorn	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1154	fontawesome	bullseye	icons/fontawesome/solid/bullseye.svg	Bullseye	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1155	fontawesome	burger	icons/fontawesome/solid/burger.svg	Burger	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1156	fontawesome	burn	icons/fontawesome/solid/burn.svg	Burn	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1158	fontawesome	bus-alt	icons/fontawesome/solid/bus-alt.svg	Bus Alt	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1159	fontawesome	bus-side	icons/fontawesome/solid/bus-side.svg	Bus Side	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:37	public
1160	fontawesome	bus-simple	icons/fontawesome/solid/bus-simple.svg	Bus Simple	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:37	public
1161	fontawesome	bus	icons/fontawesome/solid/bus.svg	Bus	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:37	public
1162	fontawesome	business-time	icons/fontawesome/solid/business-time.svg	Business Time	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1163	fontawesome	c	icons/fontawesome/solid/c.svg	C	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1164	fontawesome	cab	icons/fontawesome/solid/cab.svg	Cab	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1165	fontawesome	cable-car	icons/fontawesome/solid/cable-car.svg	Cable Car	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1166	fontawesome	cake-candles	icons/fontawesome/solid/cake-candles.svg	Cake Candles	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1167	fontawesome	cake	icons/fontawesome/solid/cake.svg	Cake	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1169	fontawesome	calendar-alt	icons/fontawesome/solid/calendar-alt.svg	Calendar Alt	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1170	fontawesome	calendar-check	icons/fontawesome/solid/calendar-check.svg	Calendar Check	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1171	fontawesome	calendar-day	icons/fontawesome/solid/calendar-day.svg	Calendar Day	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1172	fontawesome	calendar-days	icons/fontawesome/solid/calendar-days.svg	Calendar Days	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1173	fontawesome	calendar-minus	icons/fontawesome/solid/calendar-minus.svg	Calendar Minus	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1174	fontawesome	calendar-plus	icons/fontawesome/solid/calendar-plus.svg	Calendar Plus	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1175	fontawesome	calendar-times	icons/fontawesome/solid/calendar-times.svg	Calendar Times	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1177	fontawesome	calendar-xmark	icons/fontawesome/solid/calendar-xmark.svg	Calendar Xmark	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:38	public
1178	fontawesome	calendar	icons/fontawesome/solid/calendar.svg	Calendar	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:38	public
1179	fontawesome	camera-alt	icons/fontawesome/solid/camera-alt.svg	Camera Alt	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1180	fontawesome	camera-retro	icons/fontawesome/solid/camera-retro.svg	Camera Retro	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1181	fontawesome	camera-rotate	icons/fontawesome/solid/camera-rotate.svg	Camera Rotate	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1182	fontawesome	camera	icons/fontawesome/solid/camera.svg	Camera	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1183	fontawesome	campground	icons/fontawesome/solid/campground.svg	Campground	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1184	fontawesome	cancel	icons/fontawesome/solid/cancel.svg	Cancel	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1185	fontawesome	candy-cane	icons/fontawesome/solid/candy-cane.svg	Candy Cane	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1186	fontawesome	cannabis	icons/fontawesome/solid/cannabis.svg	Cannabis	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1187	fontawesome	capsules	icons/fontawesome/solid/capsules.svg	Capsules	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1188	fontawesome	car-alt	icons/fontawesome/solid/car-alt.svg	Car Alt	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1190	fontawesome	car-burst	icons/fontawesome/solid/car-burst.svg	Car Burst	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1191	fontawesome	car-crash	icons/fontawesome/solid/car-crash.svg	Car Crash	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1192	fontawesome	car-on	icons/fontawesome/solid/car-on.svg	Car On	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:39	public
1193	fontawesome	car-rear	icons/fontawesome/solid/car-rear.svg	Car Rear	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:39	public
1194	fontawesome	car-side	icons/fontawesome/solid/car-side.svg	Car Side	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:39	public
1195	fontawesome	car-tunnel	icons/fontawesome/solid/car-tunnel.svg	Car Tunnel	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:39	public
1196	fontawesome	car	icons/fontawesome/solid/car.svg	Car	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1197	fontawesome	caravan	icons/fontawesome/solid/caravan.svg	Caravan	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1198	fontawesome	caret-down	icons/fontawesome/solid/caret-down.svg	Caret Down	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1199	fontawesome	caret-left	icons/fontawesome/solid/caret-left.svg	Caret Left	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1200	fontawesome	caret-right	icons/fontawesome/solid/caret-right.svg	Caret Right	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1202	fontawesome	caret-square-left	icons/fontawesome/solid/caret-square-left.svg	Caret Square Left	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1203	fontawesome	caret-square-right	icons/fontawesome/solid/caret-square-right.svg	Caret Square Right	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1205	fontawesome	caret-up	icons/fontawesome/solid/caret-up.svg	Caret Up	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1206	fontawesome	carriage-baby	icons/fontawesome/solid/carriage-baby.svg	Carriage Baby	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1207	fontawesome	carrot	icons/fontawesome/solid/carrot.svg	Carrot	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1208	fontawesome	cart-arrow-down	icons/fontawesome/solid/cart-arrow-down.svg	Cart Arrow Down	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:40	public
1209	fontawesome	cart-flatbed-suitcase	icons/fontawesome/solid/cart-flatbed-suitcase.svg	Cart Flatbed Suitcase	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:40	public
1210	fontawesome	cart-flatbed	icons/fontawesome/solid/cart-flatbed.svg	Cart Flatbed	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:40	public
1211	fontawesome	cart-plus	icons/fontawesome/solid/cart-plus.svg	Cart Plus	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:40	public
1212	fontawesome	cart-shopping	icons/fontawesome/solid/cart-shopping.svg	Cart Shopping	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1214	fontawesome	cat	icons/fontawesome/solid/cat.svg	Cat	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1215	fontawesome	cedi-sign	icons/fontawesome/solid/cedi-sign.svg	Cedi Sign	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1216	fontawesome	cent-sign	icons/fontawesome/solid/cent-sign.svg	Cent Sign	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1217	fontawesome	certificate	icons/fontawesome/solid/certificate.svg	Certificate	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1218	fontawesome	chain-broken	icons/fontawesome/solid/chain-broken.svg	Chain Broken	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1219	fontawesome	chain-slash	icons/fontawesome/solid/chain-slash.svg	Chain Slash	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1220	fontawesome	chain	icons/fontawesome/solid/chain.svg	Chain	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1221	fontawesome	chair	icons/fontawesome/solid/chair.svg	Chair	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1222	fontawesome	chalkboard-teacher	icons/fontawesome/solid/chalkboard-teacher.svg	Chalkboard Teacher	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1223	fontawesome	chalkboard-user	icons/fontawesome/solid/chalkboard-user.svg	Chalkboard User	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1224	fontawesome	chalkboard	icons/fontawesome/solid/chalkboard.svg	Chalkboard	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:41	public
1226	fontawesome	charging-station	icons/fontawesome/solid/charging-station.svg	Charging Station	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:41	public
1227	fontawesome	chart-area	icons/fontawesome/solid/chart-area.svg	Chart Area	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:41	public
1228	fontawesome	chart-bar	icons/fontawesome/solid/chart-bar.svg	Chart Bar	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:41	public
1229	fontawesome	chart-column	icons/fontawesome/solid/chart-column.svg	Chart Column	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1230	fontawesome	chart-diagram	icons/fontawesome/solid/chart-diagram.svg	Chart Diagram	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1231	fontawesome	chart-gantt	icons/fontawesome/solid/chart-gantt.svg	Chart Gantt	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1232	fontawesome	chart-line	icons/fontawesome/solid/chart-line.svg	Chart Line	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1233	fontawesome	chart-pie	icons/fontawesome/solid/chart-pie.svg	Chart Pie	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1234	fontawesome	chart-simple	icons/fontawesome/solid/chart-simple.svg	Chart Simple	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1235	fontawesome	check-circle	icons/fontawesome/solid/check-circle.svg	Check Circle	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1237	fontawesome	check-square	icons/fontawesome/solid/check-square.svg	Check Square	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1238	fontawesome	check-to-slot	icons/fontawesome/solid/check-to-slot.svg	Check To Slot	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1239	fontawesome	check	icons/fontawesome/solid/check.svg	Check	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1240	fontawesome	cheese	icons/fontawesome/solid/cheese.svg	Cheese	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1241	fontawesome	chess-bishop	icons/fontawesome/solid/chess-bishop.svg	Chess Bishop	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:42	public
1242	fontawesome	chess-board	icons/fontawesome/solid/chess-board.svg	Chess Board	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:42	public
1243	fontawesome	chess-king	icons/fontawesome/solid/chess-king.svg	Chess King	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:42	public
1244	fontawesome	chess-knight	icons/fontawesome/solid/chess-knight.svg	Chess Knight	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:42	public
1245	fontawesome	chess-pawn	icons/fontawesome/solid/chess-pawn.svg	Chess Pawn	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1246	fontawesome	chess-queen	icons/fontawesome/solid/chess-queen.svg	Chess Queen	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1247	fontawesome	chess-rook	icons/fontawesome/solid/chess-rook.svg	Chess Rook	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1249	fontawesome	chevron-circle-down	icons/fontawesome/solid/chevron-circle-down.svg	Chevron Circle Down	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1250	fontawesome	chevron-circle-left	icons/fontawesome/solid/chevron-circle-left.svg	Chevron Circle Left	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1251	fontawesome	chevron-circle-right	icons/fontawesome/solid/chevron-circle-right.svg	Chevron Circle Right	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1252	fontawesome	chevron-circle-up	icons/fontawesome/solid/chevron-circle-up.svg	Chevron Circle Up	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1253	fontawesome	chevron-down	icons/fontawesome/solid/chevron-down.svg	Chevron Down	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1254	fontawesome	chevron-left	icons/fontawesome/solid/chevron-left.svg	Chevron Left	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1256	fontawesome	chevron-up	icons/fontawesome/solid/chevron-up.svg	Chevron Up	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1259	fontawesome	child-reaching	icons/fontawesome/solid/child-reaching.svg	Child Reaching	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:43	public
1260	fontawesome	child-rifle	icons/fontawesome/solid/child-rifle.svg	Child Rifle	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:43	public
1261	fontawesome	child	icons/fontawesome/solid/child.svg	Child	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:43	public
1262	fontawesome	children	icons/fontawesome/solid/children.svg	Children	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1263	fontawesome	church	icons/fontawesome/solid/church.svg	Church	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1264	fontawesome	circle-arrow-down	icons/fontawesome/solid/circle-arrow-down.svg	Circle Arrow Down	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1265	fontawesome	circle-arrow-left	icons/fontawesome/solid/circle-arrow-left.svg	Circle Arrow Left	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1267	fontawesome	circle-arrow-up	icons/fontawesome/solid/circle-arrow-up.svg	Circle Arrow Up	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1268	fontawesome	circle-check	icons/fontawesome/solid/circle-check.svg	Circle Check	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1269	fontawesome	circle-chevron-down	icons/fontawesome/solid/circle-chevron-down.svg	Circle Chevron Down	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1270	fontawesome	circle-chevron-left	icons/fontawesome/solid/circle-chevron-left.svg	Circle Chevron Left	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1271	fontawesome	circle-chevron-right	icons/fontawesome/solid/circle-chevron-right.svg	Circle Chevron Right	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1272	fontawesome	circle-chevron-up	icons/fontawesome/solid/circle-chevron-up.svg	Circle Chevron Up	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:44	public
1273	fontawesome	circle-dollar-to-slot	icons/fontawesome/solid/circle-dollar-to-slot.svg	Circle Dollar To Slot	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:44	public
1274	fontawesome	circle-dot	icons/fontawesome/solid/circle-dot.svg	Circle Dot	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:44	public
1276	fontawesome	circle-exclamation	icons/fontawesome/solid/circle-exclamation.svg	Circle Exclamation	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:44	public
1277	fontawesome	circle-h	icons/fontawesome/solid/circle-h.svg	Circle H	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:44	public
1278	fontawesome	circle-half-stroke	icons/fontawesome/solid/circle-half-stroke.svg	Circle Half Stroke	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:44	public
1279	fontawesome	circle-info	icons/fontawesome/solid/circle-info.svg	Circle Info	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1280	fontawesome	circle-left	icons/fontawesome/solid/circle-left.svg	Circle Left	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1281	fontawesome	circle-minus	icons/fontawesome/solid/circle-minus.svg	Circle Minus	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1282	fontawesome	circle-nodes	icons/fontawesome/solid/circle-nodes.svg	Circle Nodes	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1283	fontawesome	circle-notch	icons/fontawesome/solid/circle-notch.svg	Circle Notch	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1284	fontawesome	circle-pause	icons/fontawesome/solid/circle-pause.svg	Circle Pause	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1286	fontawesome	circle-plus	icons/fontawesome/solid/circle-plus.svg	Circle Plus	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1287	fontawesome	circle-question	icons/fontawesome/solid/circle-question.svg	Circle Question	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1288	fontawesome	circle-radiation	icons/fontawesome/solid/circle-radiation.svg	Circle Radiation	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:45	public
1289	fontawesome	circle-right	icons/fontawesome/solid/circle-right.svg	Circle Right	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:45	public
1290	fontawesome	circle-stop	icons/fontawesome/solid/circle-stop.svg	Circle Stop	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:45	public
1291	fontawesome	circle-up	icons/fontawesome/solid/circle-up.svg	Circle Up	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:45	public
1292	fontawesome	circle-user	icons/fontawesome/solid/circle-user.svg	Circle User	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:45	public
1293	fontawesome	circle-xmark	icons/fontawesome/solid/circle-xmark.svg	Circle Xmark	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:45	public
1294	fontawesome	circle	icons/fontawesome/solid/circle.svg	Circle	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:45	public
1295	fontawesome	city	icons/fontawesome/solid/city.svg	City	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1297	fontawesome	clinic-medical	icons/fontawesome/solid/clinic-medical.svg	Clinic Medical	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1298	fontawesome	clipboard-check	icons/fontawesome/solid/clipboard-check.svg	Clipboard Check	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1299	fontawesome	clipboard-list	icons/fontawesome/solid/clipboard-list.svg	Clipboard List	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1300	fontawesome	clipboard-question	icons/fontawesome/solid/clipboard-question.svg	Clipboard Question	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1301	fontawesome	clipboard-user	icons/fontawesome/solid/clipboard-user.svg	Clipboard User	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1302	fontawesome	clipboard	icons/fontawesome/solid/clipboard.svg	Clipboard	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1303	fontawesome	clock-four	icons/fontawesome/solid/clock-four.svg	Clock Four	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1305	fontawesome	clock	icons/fontawesome/solid/clock.svg	Clock	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:46	public
1306	fontawesome	clone	icons/fontawesome/solid/clone.svg	Clone	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:46	public
1307	fontawesome	close	icons/fontawesome/solid/close.svg	Close	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:46	public
1308	fontawesome	closed-captioning	icons/fontawesome/solid/closed-captioning.svg	Closed Captioning	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:46	public
1309	fontawesome	cloud-arrow-down	icons/fontawesome/solid/cloud-arrow-down.svg	Cloud Arrow Down	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:46	public
1310	fontawesome	cloud-arrow-up	icons/fontawesome/solid/cloud-arrow-up.svg	Cloud Arrow Up	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:46	public
1311	fontawesome	cloud-bolt	icons/fontawesome/solid/cloud-bolt.svg	Cloud Bolt	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1543	fontawesome	feed	icons/fontawesome/solid/feed.svg	Feed	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:35:47	public
1313	fontawesome	cloud-download	icons/fontawesome/solid/cloud-download.svg	Cloud Download	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1314	fontawesome	cloud-meatball	icons/fontawesome/solid/cloud-meatball.svg	Cloud Meatball	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1315	fontawesome	cloud-moon-rain	icons/fontawesome/solid/cloud-moon-rain.svg	Cloud Moon Rain	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1316	fontawesome	cloud-moon	icons/fontawesome/solid/cloud-moon.svg	Cloud Moon	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1317	fontawesome	cloud-rain	icons/fontawesome/solid/cloud-rain.svg	Cloud Rain	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1319	fontawesome	cloud-showers-water	icons/fontawesome/solid/cloud-showers-water.svg	Cloud Showers Water	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1320	fontawesome	cloud-sun-rain	icons/fontawesome/solid/cloud-sun-rain.svg	Cloud Sun Rain	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1321	fontawesome	cloud-sun	icons/fontawesome/solid/cloud-sun.svg	Cloud Sun	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:47	public
1322	fontawesome	cloud-upload-alt	icons/fontawesome/solid/cloud-upload-alt.svg	Cloud Upload Alt	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:47	public
1323	fontawesome	cloud-upload	icons/fontawesome/solid/cloud-upload.svg	Cloud Upload	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:47	public
1324	fontawesome	cloud	icons/fontawesome/solid/cloud.svg	Cloud	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:47	public
1325	fontawesome	clover	icons/fontawesome/solid/clover.svg	Clover	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:47	public
1326	fontawesome	cny	icons/fontawesome/solid/cny.svg	Cny	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:47	public
1327	fontawesome	cocktail	icons/fontawesome/solid/cocktail.svg	Cocktail	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1328	fontawesome	code-branch	icons/fontawesome/solid/code-branch.svg	Code Branch	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1330	fontawesome	code-compare	icons/fontawesome/solid/code-compare.svg	Code Compare	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1331	fontawesome	code-fork	icons/fontawesome/solid/code-fork.svg	Code Fork	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1332	fontawesome	code-merge	icons/fontawesome/solid/code-merge.svg	Code Merge	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1333	fontawesome	code-pull-request	icons/fontawesome/solid/code-pull-request.svg	Code Pull Request	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1334	fontawesome	code	icons/fontawesome/solid/code.svg	Code	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1335	fontawesome	coffee	icons/fontawesome/solid/coffee.svg	Coffee	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1336	fontawesome	cog	icons/fontawesome/solid/cog.svg	Cog	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1337	fontawesome	cogs	icons/fontawesome/solid/cogs.svg	Cogs	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:48	public
1338	fontawesome	coins	icons/fontawesome/solid/coins.svg	Coins	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:48	public
1339	fontawesome	colon-sign	icons/fontawesome/solid/colon-sign.svg	Colon Sign	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:48	public
1340	fontawesome	columns	icons/fontawesome/solid/columns.svg	Columns	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:48	public
1342	fontawesome	comment-dollar	icons/fontawesome/solid/comment-dollar.svg	Comment Dollar	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:48	public
1343	fontawesome	comment-dots	icons/fontawesome/solid/comment-dots.svg	Comment Dots	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1344	fontawesome	comment-medical	icons/fontawesome/solid/comment-medical.svg	Comment Medical	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1345	fontawesome	comment-nodes	icons/fontawesome/solid/comment-nodes.svg	Comment Nodes	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1346	fontawesome	comment-slash	icons/fontawesome/solid/comment-slash.svg	Comment Slash	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1347	fontawesome	comment-sms	icons/fontawesome/solid/comment-sms.svg	Comment Sms	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1348	fontawesome	comment	icons/fontawesome/solid/comment.svg	Comment	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1349	fontawesome	commenting	icons/fontawesome/solid/commenting.svg	Commenting	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1351	fontawesome	comments	icons/fontawesome/solid/comments.svg	Comments	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1352	fontawesome	compact-disc	icons/fontawesome/solid/compact-disc.svg	Compact Disc	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1353	fontawesome	compass-drafting	icons/fontawesome/solid/compass-drafting.svg	Compass Drafting	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1354	fontawesome	compass	icons/fontawesome/solid/compass.svg	Compass	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:49	public
1355	fontawesome	compress-alt	icons/fontawesome/solid/compress-alt.svg	Compress Alt	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:49	public
1356	fontawesome	compress-arrows-alt	icons/fontawesome/solid/compress-arrows-alt.svg	Compress Arrows Alt	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:49	public
1357	fontawesome	compress	icons/fontawesome/solid/compress.svg	Compress	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:49	public
1358	fontawesome	computer-mouse	icons/fontawesome/solid/computer-mouse.svg	Computer Mouse	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:49	public
1359	fontawesome	computer	icons/fontawesome/solid/computer.svg	Computer	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:49	public
1361	fontawesome	contact-book	icons/fontawesome/solid/contact-book.svg	Contact Book	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1362	fontawesome	contact-card	icons/fontawesome/solid/contact-card.svg	Contact Card	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1363	fontawesome	cookie-bite	icons/fontawesome/solid/cookie-bite.svg	Cookie Bite	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1364	fontawesome	cookie	icons/fontawesome/solid/cookie.svg	Cookie	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1365	fontawesome	copy	icons/fontawesome/solid/copy.svg	Copy	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1366	fontawesome	copyright	icons/fontawesome/solid/copyright.svg	Copyright	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1367	fontawesome	couch	icons/fontawesome/solid/couch.svg	Couch	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1368	fontawesome	cow	icons/fontawesome/solid/cow.svg	Cow	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1370	fontawesome	credit-card	icons/fontawesome/solid/credit-card.svg	Credit Card	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:50	public
1371	fontawesome	crop-alt	icons/fontawesome/solid/crop-alt.svg	Crop Alt	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:50	public
1373	fontawesome	crop	icons/fontawesome/solid/crop.svg	Crop	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:50	public
1374	fontawesome	cross	icons/fontawesome/solid/cross.svg	Cross	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:50	public
1375	fontawesome	crosshairs	icons/fontawesome/solid/crosshairs.svg	Crosshairs	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:50	public
1376	fontawesome	crow	icons/fontawesome/solid/crow.svg	Crow	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1377	fontawesome	crown	icons/fontawesome/solid/crown.svg	Crown	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1378	fontawesome	crutch	icons/fontawesome/solid/crutch.svg	Crutch	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1379	fontawesome	cruzeiro-sign	icons/fontawesome/solid/cruzeiro-sign.svg	Cruzeiro Sign	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1380	fontawesome	cube	icons/fontawesome/solid/cube.svg	Cube	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1381	fontawesome	cubes-stacked	icons/fontawesome/solid/cubes-stacked.svg	Cubes Stacked	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1382	fontawesome	cubes	icons/fontawesome/solid/cubes.svg	Cubes	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1383	fontawesome	cut	icons/fontawesome/solid/cut.svg	Cut	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1384	fontawesome	cutlery	icons/fontawesome/solid/cutlery.svg	Cutlery	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:51	public
1385	fontawesome	d	icons/fontawesome/solid/d.svg	D	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:51	public
1387	fontawesome	database	icons/fontawesome/solid/database.svg	Database	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:51	public
1388	fontawesome	deaf	icons/fontawesome/solid/deaf.svg	Deaf	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:51	public
1389	fontawesome	deafness	icons/fontawesome/solid/deafness.svg	Deafness	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:51	public
1390	fontawesome	dedent	icons/fontawesome/solid/dedent.svg	Dedent	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:51	public
1391	fontawesome	delete-left	icons/fontawesome/solid/delete-left.svg	Delete Left	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:51	public
1392	fontawesome	democrat	icons/fontawesome/solid/democrat.svg	Democrat	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:51	public
1393	fontawesome	desktop-alt	icons/fontawesome/solid/desktop-alt.svg	Desktop Alt	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1394	fontawesome	desktop	icons/fontawesome/solid/desktop.svg	Desktop	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1395	fontawesome	dharmachakra	icons/fontawesome/solid/dharmachakra.svg	Dharmachakra	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1396	fontawesome	diagnoses	icons/fontawesome/solid/diagnoses.svg	Diagnoses	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1398	fontawesome	diagram-predecessor	icons/fontawesome/solid/diagram-predecessor.svg	Diagram Predecessor	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1399	fontawesome	diagram-project	icons/fontawesome/solid/diagram-project.svg	Diagram Project	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1400	fontawesome	diagram-successor	icons/fontawesome/solid/diagram-successor.svg	Diagram Successor	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1401	fontawesome	diamond-turn-right	icons/fontawesome/solid/diamond-turn-right.svg	Diamond Turn Right	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1402	fontawesome	diamond	icons/fontawesome/solid/diamond.svg	Diamond	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:52	public
1403	fontawesome	dice-d20	icons/fontawesome/solid/dice-d20.svg	Dice D20	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:52	public
1404	fontawesome	dice-d6	icons/fontawesome/solid/dice-d6.svg	Dice D6	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:52	public
1405	fontawesome	dice-five	icons/fontawesome/solid/dice-five.svg	Dice Five	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:52	public
1406	fontawesome	dice-four	icons/fontawesome/solid/dice-four.svg	Dice Four	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:52	public
1408	fontawesome	dice-six	icons/fontawesome/solid/dice-six.svg	Dice Six	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:52	public
1409	fontawesome	dice-three	icons/fontawesome/solid/dice-three.svg	Dice Three	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:52	public
1410	fontawesome	dice-two	icons/fontawesome/solid/dice-two.svg	Dice Two	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:53	public
1411	fontawesome	dice	icons/fontawesome/solid/dice.svg	Dice	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:53	public
1412	fontawesome	digging	icons/fontawesome/solid/digging.svg	Digging	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:53	public
1413	fontawesome	digital-tachograph	icons/fontawesome/solid/digital-tachograph.svg	Digital Tachograph	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:53	public
1414	fontawesome	directions	icons/fontawesome/solid/directions.svg	Directions	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:53	public
1415	fontawesome	disease	icons/fontawesome/solid/disease.svg	Disease	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:53	public
1416	fontawesome	display	icons/fontawesome/solid/display.svg	Display	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:53	public
1417	fontawesome	divide	icons/fontawesome/solid/divide.svg	Divide	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:53	public
1418	fontawesome	dizzy	icons/fontawesome/solid/dizzy.svg	Dizzy	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:53	public
1419	fontawesome	dna	icons/fontawesome/solid/dna.svg	Dna	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:53	public
1420	fontawesome	dog	icons/fontawesome/solid/dog.svg	Dog	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:53	public
1422	fontawesome	dollar	icons/fontawesome/solid/dollar.svg	Dollar	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:53	public
1423	fontawesome	dolly-box	icons/fontawesome/solid/dolly-box.svg	Dolly Box	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:53	public
1424	fontawesome	dolly-flatbed	icons/fontawesome/solid/dolly-flatbed.svg	Dolly Flatbed	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:53	public
1425	fontawesome	dolly	icons/fontawesome/solid/dolly.svg	Dolly	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:53	public
1426	fontawesome	donate	icons/fontawesome/solid/donate.svg	Donate	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:54	public
1427	fontawesome	dong-sign	icons/fontawesome/solid/dong-sign.svg	Dong Sign	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:54	public
1429	fontawesome	door-open	icons/fontawesome/solid/door-open.svg	Door Open	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:54	public
1431	fontawesome	dove	icons/fontawesome/solid/dove.svg	Dove	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:54	public
1432	fontawesome	down-left-and-up-right-to-center	icons/fontawesome/solid/down-left-and-up-right-to-center.svg	Down Left And Up Right To Center	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:54	public
1433	fontawesome	down-long	icons/fontawesome/solid/down-long.svg	Down Long	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:54	public
1434	fontawesome	download	icons/fontawesome/solid/download.svg	Download	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1435	fontawesome	drafting-compass	icons/fontawesome/solid/drafting-compass.svg	Drafting Compass	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1436	fontawesome	dragon	icons/fontawesome/solid/dragon.svg	Dragon	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1437	fontawesome	draw-polygon	icons/fontawesome/solid/draw-polygon.svg	Draw Polygon	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1438	fontawesome	drivers-license	icons/fontawesome/solid/drivers-license.svg	Drivers License	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1440	fontawesome	droplet	icons/fontawesome/solid/droplet.svg	Droplet	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1441	fontawesome	drum-steelpan	icons/fontawesome/solid/drum-steelpan.svg	Drum Steelpan	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1442	fontawesome	drum	icons/fontawesome/solid/drum.svg	Drum	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1443	fontawesome	drumstick-bite	icons/fontawesome/solid/drumstick-bite.svg	Drumstick Bite	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:55	public
1444	fontawesome	dumbbell	icons/fontawesome/solid/dumbbell.svg	Dumbbell	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:55	public
1445	fontawesome	dumpster-fire	icons/fontawesome/solid/dumpster-fire.svg	Dumpster Fire	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:55	public
1446	fontawesome	dumpster	icons/fontawesome/solid/dumpster.svg	Dumpster	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:55	public
1447	fontawesome	dungeon	icons/fontawesome/solid/dungeon.svg	Dungeon	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:55	public
1448	fontawesome	e	icons/fontawesome/solid/e.svg	E	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:55	public
1449	fontawesome	ear-deaf	icons/fontawesome/solid/ear-deaf.svg	Ear Deaf	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:55	public
1450	fontawesome	ear-listen	icons/fontawesome/solid/ear-listen.svg	Ear Listen	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:55	public
1451	fontawesome	earth-africa	icons/fontawesome/solid/earth-africa.svg	Earth Africa	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:55	public
1453	fontawesome	earth-americas	icons/fontawesome/solid/earth-americas.svg	Earth Americas	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:55	public
1454	fontawesome	earth-asia	icons/fontawesome/solid/earth-asia.svg	Earth Asia	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:55	public
1455	fontawesome	earth-europe	icons/fontawesome/solid/earth-europe.svg	Earth Europe	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:55	public
1456	fontawesome	earth-oceania	icons/fontawesome/solid/earth-oceania.svg	Earth Oceania	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:55	public
1457	fontawesome	earth	icons/fontawesome/solid/earth.svg	Earth	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:55	public
1458	fontawesome	edit	icons/fontawesome/solid/edit.svg	Edit	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:55	public
1462	fontawesome	ellipsis-h	icons/fontawesome/solid/ellipsis-h.svg	Ellipsis H	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:56	public
1463	fontawesome	ellipsis-v	icons/fontawesome/solid/ellipsis-v.svg	Ellipsis V	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:56	public
1464	fontawesome	ellipsis-vertical	icons/fontawesome/solid/ellipsis-vertical.svg	Ellipsis Vertical	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:56	public
1465	fontawesome	ellipsis	icons/fontawesome/solid/ellipsis.svg	Ellipsis	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:56	public
1467	fontawesome	envelope-open-text	icons/fontawesome/solid/envelope-open-text.svg	Envelope Open Text	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1468	fontawesome	envelope-open	icons/fontawesome/solid/envelope-open.svg	Envelope Open	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1469	fontawesome	envelope-square	icons/fontawesome/solid/envelope-square.svg	Envelope Square	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1470	fontawesome	envelope	icons/fontawesome/solid/envelope.svg	Envelope	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1471	fontawesome	envelopes-bulk	icons/fontawesome/solid/envelopes-bulk.svg	Envelopes Bulk	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1472	fontawesome	equals	icons/fontawesome/solid/equals.svg	Equals	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1473	fontawesome	eraser	icons/fontawesome/solid/eraser.svg	Eraser	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1474	fontawesome	ethernet	icons/fontawesome/solid/ethernet.svg	Ethernet	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1475	fontawesome	eur	icons/fontawesome/solid/eur.svg	Eur	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1476	fontawesome	euro-sign	icons/fontawesome/solid/euro-sign.svg	Euro Sign	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1477	fontawesome	euro	icons/fontawesome/solid/euro.svg	Euro	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1478	fontawesome	exchange-alt	icons/fontawesome/solid/exchange-alt.svg	Exchange Alt	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1480	fontawesome	exclamation-circle	icons/fontawesome/solid/exclamation-circle.svg	Exclamation Circle	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:57	public
1481	fontawesome	exclamation-triangle	icons/fontawesome/solid/exclamation-triangle.svg	Exclamation Triangle	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:57	public
1482	fontawesome	exclamation	icons/fontawesome/solid/exclamation.svg	Exclamation	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1483	fontawesome	expand-alt	icons/fontawesome/solid/expand-alt.svg	Expand Alt	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1484	fontawesome	expand-arrows-alt	icons/fontawesome/solid/expand-arrows-alt.svg	Expand Arrows Alt	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1485	fontawesome	expand	icons/fontawesome/solid/expand.svg	Expand	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1486	fontawesome	explosion	icons/fontawesome/solid/explosion.svg	Explosion	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1544	fontawesome	female	icons/fontawesome/solid/female.svg	Female	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:35:57	public
1488	fontawesome	external-link-square-alt	icons/fontawesome/solid/external-link-square-alt.svg	External Link Square Alt	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1489	fontawesome	external-link-square	icons/fontawesome/solid/external-link-square.svg	External Link Square	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1490	fontawesome	external-link	icons/fontawesome/solid/external-link.svg	External Link	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1492	fontawesome	eye-dropper	icons/fontawesome/solid/eye-dropper.svg	Eye Dropper	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1493	fontawesome	eye-low-vision	icons/fontawesome/solid/eye-low-vision.svg	Eye Low Vision	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1494	fontawesome	eye-slash	icons/fontawesome/solid/eye-slash.svg	Eye Slash	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1495	fontawesome	eye	icons/fontawesome/solid/eye.svg	Eye	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:58	public
1496	fontawesome	eyedropper	icons/fontawesome/solid/eyedropper.svg	Eyedropper	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:58	public
1497	fontawesome	f	icons/fontawesome/solid/f.svg	F	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:58	public
1498	fontawesome	face-angry	icons/fontawesome/solid/face-angry.svg	Face Angry	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1499	fontawesome	face-dizzy	icons/fontawesome/solid/face-dizzy.svg	Face Dizzy	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1500	fontawesome	face-flushed	icons/fontawesome/solid/face-flushed.svg	Face Flushed	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1501	fontawesome	face-frown-open	icons/fontawesome/solid/face-frown-open.svg	Face Frown Open	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1502	fontawesome	face-frown	icons/fontawesome/solid/face-frown.svg	Face Frown	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1503	fontawesome	face-grimace	icons/fontawesome/solid/face-grimace.svg	Face Grimace	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1505	fontawesome	face-grin-beam	icons/fontawesome/solid/face-grin-beam.svg	Face Grin Beam	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1506	fontawesome	face-grin-hearts	icons/fontawesome/solid/face-grin-hearts.svg	Face Grin Hearts	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1507	fontawesome	face-grin-squint-tears	icons/fontawesome/solid/face-grin-squint-tears.svg	Face Grin Squint Tears	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1508	fontawesome	face-grin-squint	icons/fontawesome/solid/face-grin-squint.svg	Face Grin Squint	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1509	fontawesome	face-grin-stars	icons/fontawesome/solid/face-grin-stars.svg	Face Grin Stars	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1510	fontawesome	face-grin-tears	icons/fontawesome/solid/face-grin-tears.svg	Face Grin Tears	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1512	fontawesome	face-grin-tongue-wink	icons/fontawesome/solid/face-grin-tongue-wink.svg	Face Grin Tongue Wink	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:59	public
1513	fontawesome	face-grin-tongue	icons/fontawesome/solid/face-grin-tongue.svg	Face Grin Tongue	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:59	public
1514	fontawesome	face-grin-wide	icons/fontawesome/solid/face-grin-wide.svg	Face Grin Wide	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:59	public
1515	fontawesome	face-grin-wink	icons/fontawesome/solid/face-grin-wink.svg	Face Grin Wink	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1516	fontawesome	face-grin	icons/fontawesome/solid/face-grin.svg	Face Grin	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1517	fontawesome	face-kiss-beam	icons/fontawesome/solid/face-kiss-beam.svg	Face Kiss Beam	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1518	fontawesome	face-kiss-wink-heart	icons/fontawesome/solid/face-kiss-wink-heart.svg	Face Kiss Wink Heart	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1519	fontawesome	face-kiss	icons/fontawesome/solid/face-kiss.svg	Face Kiss	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1520	fontawesome	face-laugh-beam	icons/fontawesome/solid/face-laugh-beam.svg	Face Laugh Beam	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1521	fontawesome	face-laugh-squint	icons/fontawesome/solid/face-laugh-squint.svg	Face Laugh Squint	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1523	fontawesome	face-laugh	icons/fontawesome/solid/face-laugh.svg	Face Laugh	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1524	fontawesome	face-meh-blank	icons/fontawesome/solid/face-meh-blank.svg	Face Meh Blank	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1525	fontawesome	face-meh	icons/fontawesome/solid/face-meh.svg	Face Meh	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1526	fontawesome	face-rolling-eyes	icons/fontawesome/solid/face-rolling-eyes.svg	Face Rolling Eyes	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1527	fontawesome	face-sad-cry	icons/fontawesome/solid/face-sad-cry.svg	Face Sad Cry	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1528	fontawesome	face-sad-tear	icons/fontawesome/solid/face-sad-tear.svg	Face Sad Tear	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:36:00	public
1529	fontawesome	face-smile-beam	icons/fontawesome/solid/face-smile-beam.svg	Face Smile Beam	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:36:00	public
1530	fontawesome	face-smile-wink	icons/fontawesome/solid/face-smile-wink.svg	Face Smile Wink	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:36:00	public
1531	fontawesome	face-smile	icons/fontawesome/solid/face-smile.svg	Face Smile	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1533	fontawesome	face-tired	icons/fontawesome/solid/face-tired.svg	Face Tired	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1534	fontawesome	fan	icons/fontawesome/solid/fan.svg	Fan	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1535	fontawesome	fast-backward	icons/fontawesome/solid/fast-backward.svg	Fast Backward	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1536	fontawesome	fast-forward	icons/fontawesome/solid/fast-forward.svg	Fast Forward	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1537	fontawesome	faucet-drip	icons/fontawesome/solid/faucet-drip.svg	Faucet Drip	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1538	fontawesome	faucet	icons/fontawesome/solid/faucet.svg	Faucet	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1539	fontawesome	fax	icons/fontawesome/solid/fax.svg	Fax	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1540	fontawesome	feather-alt	icons/fontawesome/solid/feather-alt.svg	Feather Alt	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1541	fontawesome	feather-pointed	icons/fontawesome/solid/feather-pointed.svg	Feather Pointed	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1547	fontawesome	file-alt	icons/fontawesome/solid/file-alt.svg	File Alt	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1548	fontawesome	file-archive	icons/fontawesome/solid/file-archive.svg	File Archive	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1549	fontawesome	file-arrow-down	icons/fontawesome/solid/file-arrow-down.svg	File Arrow Down	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1550	fontawesome	file-arrow-up	icons/fontawesome/solid/file-arrow-up.svg	File Arrow Up	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1551	fontawesome	file-audio	icons/fontawesome/solid/file-audio.svg	File Audio	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1552	fontawesome	file-circle-check	icons/fontawesome/solid/file-circle-check.svg	File Circle Check	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1553	fontawesome	file-circle-exclamation	icons/fontawesome/solid/file-circle-exclamation.svg	File Circle Exclamation	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1555	fontawesome	file-circle-plus	icons/fontawesome/solid/file-circle-plus.svg	File Circle Plus	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1556	fontawesome	file-circle-question	icons/fontawesome/solid/file-circle-question.svg	File Circle Question	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1557	fontawesome	file-circle-xmark	icons/fontawesome/solid/file-circle-xmark.svg	File Circle Xmark	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1558	fontawesome	file-clipboard	icons/fontawesome/solid/file-clipboard.svg	File Clipboard	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1559	fontawesome	file-code	icons/fontawesome/solid/file-code.svg	File Code	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1560	fontawesome	file-contract	icons/fontawesome/solid/file-contract.svg	File Contract	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1561	fontawesome	file-csv	icons/fontawesome/solid/file-csv.svg	File Csv	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1562	fontawesome	file-download	icons/fontawesome/solid/file-download.svg	File Download	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:01	public
1563	fontawesome	file-edit	icons/fontawesome/solid/file-edit.svg	File Edit	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:01	public
1564	fontawesome	file-excel	icons/fontawesome/solid/file-excel.svg	File Excel	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1566	fontawesome	file-fragment	icons/fontawesome/solid/file-fragment.svg	File Fragment	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1567	fontawesome	file-half-dashed	icons/fontawesome/solid/file-half-dashed.svg	File Half Dashed	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1568	fontawesome	file-image	icons/fontawesome/solid/file-image.svg	File Image	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1569	fontawesome	file-import	icons/fontawesome/solid/file-import.svg	File Import	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1570	fontawesome	file-invoice-dollar	icons/fontawesome/solid/file-invoice-dollar.svg	File Invoice Dollar	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1571	fontawesome	file-invoice	icons/fontawesome/solid/file-invoice.svg	File Invoice	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1572	fontawesome	file-lines	icons/fontawesome/solid/file-lines.svg	File Lines	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1574	fontawesome	file-medical	icons/fontawesome/solid/file-medical.svg	File Medical	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1575	fontawesome	file-pdf	icons/fontawesome/solid/file-pdf.svg	File Pdf	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1576	fontawesome	file-pen	icons/fontawesome/solid/file-pen.svg	File Pen	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1577	fontawesome	file-powerpoint	icons/fontawesome/solid/file-powerpoint.svg	File Powerpoint	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1578	fontawesome	file-prescription	icons/fontawesome/solid/file-prescription.svg	File Prescription	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1579	fontawesome	file-shield	icons/fontawesome/solid/file-shield.svg	File Shield	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:02	public
1580	fontawesome	file-signature	icons/fontawesome/solid/file-signature.svg	File Signature	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1581	fontawesome	file-text	icons/fontawesome/solid/file-text.svg	File Text	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1582	fontawesome	file-upload	icons/fontawesome/solid/file-upload.svg	File Upload	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1583	fontawesome	file-video	icons/fontawesome/solid/file-video.svg	File Video	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1585	fontawesome	file-word	icons/fontawesome/solid/file-word.svg	File Word	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1586	fontawesome	file-zipper	icons/fontawesome/solid/file-zipper.svg	File Zipper	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1587	fontawesome	file	icons/fontawesome/solid/file.svg	File	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1588	fontawesome	fill-drip	icons/fontawesome/solid/fill-drip.svg	Fill Drip	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1589	fontawesome	fill	icons/fontawesome/solid/fill.svg	Fill	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1590	fontawesome	film-alt	icons/fontawesome/solid/film-alt.svg	Film Alt	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1591	fontawesome	film-simple	icons/fontawesome/solid/film-simple.svg	Film Simple	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1592	fontawesome	film	icons/fontawesome/solid/film.svg	Film	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1593	fontawesome	filter-circle-dollar	icons/fontawesome/solid/filter-circle-dollar.svg	Filter Circle Dollar	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1594	fontawesome	filter-circle-xmark	icons/fontawesome/solid/filter-circle-xmark.svg	Filter Circle Xmark	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1595	fontawesome	filter	icons/fontawesome/solid/filter.svg	Filter	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:03	public
1597	fontawesome	fire-alt	icons/fontawesome/solid/fire-alt.svg	Fire Alt	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1598	fontawesome	fire-burner	icons/fontawesome/solid/fire-burner.svg	Fire Burner	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1599	fontawesome	fire-extinguisher	icons/fontawesome/solid/fire-extinguisher.svg	Fire Extinguisher	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1600	fontawesome	fire-flame-curved	icons/fontawesome/solid/fire-flame-curved.svg	Fire Flame Curved	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1602	fontawesome	fire	icons/fontawesome/solid/fire.svg	Fire	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1603	fontawesome	first-aid	icons/fontawesome/solid/first-aid.svg	First Aid	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1604	fontawesome	fish-fins	icons/fontawesome/solid/fish-fins.svg	Fish Fins	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1605	fontawesome	fish	icons/fontawesome/solid/fish.svg	Fish	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1606	fontawesome	fist-raised	icons/fontawesome/solid/fist-raised.svg	Fist Raised	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1608	fontawesome	flag-usa	icons/fontawesome/solid/flag-usa.svg	Flag Usa	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1609	fontawesome	flag	icons/fontawesome/solid/flag.svg	Flag	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1610	fontawesome	flask-vial	icons/fontawesome/solid/flask-vial.svg	Flask Vial	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1611	fontawesome	flask	icons/fontawesome/solid/flask.svg	Flask	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1612	fontawesome	floppy-disk	icons/fontawesome/solid/floppy-disk.svg	Floppy Disk	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:04	public
1613	fontawesome	florin-sign	icons/fontawesome/solid/florin-sign.svg	Florin Sign	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:04	public
1614	fontawesome	flushed	icons/fontawesome/solid/flushed.svg	Flushed	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1615	fontawesome	folder-blank	icons/fontawesome/solid/folder-blank.svg	Folder Blank	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1616	fontawesome	folder-closed	icons/fontawesome/solid/folder-closed.svg	Folder Closed	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1617	fontawesome	folder-minus	icons/fontawesome/solid/folder-minus.svg	Folder Minus	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1618	fontawesome	folder-open	icons/fontawesome/solid/folder-open.svg	Folder Open	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1620	fontawesome	folder-tree	icons/fontawesome/solid/folder-tree.svg	Folder Tree	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1621	fontawesome	folder	icons/fontawesome/solid/folder.svg	Folder	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1622	fontawesome	font-awesome-flag	icons/fontawesome/solid/font-awesome-flag.svg	Font Awesome Flag	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1623	fontawesome	font-awesome-logo-full	icons/fontawesome/solid/font-awesome-logo-full.svg	Font Awesome Logo Full	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1624	fontawesome	font-awesome	icons/fontawesome/solid/font-awesome.svg	Font Awesome	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1625	fontawesome	font	icons/fontawesome/solid/font.svg	Font	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1626	fontawesome	football-ball	icons/fontawesome/solid/football-ball.svg	Football Ball	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1627	fontawesome	football	icons/fontawesome/solid/football.svg	Football	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1629	fontawesome	forward-step	icons/fontawesome/solid/forward-step.svg	Forward Step	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:05	public
1630	fontawesome	forward	icons/fontawesome/solid/forward.svg	Forward	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1631	fontawesome	franc-sign	icons/fontawesome/solid/franc-sign.svg	Franc Sign	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1632	fontawesome	frog	icons/fontawesome/solid/frog.svg	Frog	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1633	fontawesome	frown-open	icons/fontawesome/solid/frown-open.svg	Frown Open	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1634	fontawesome	frown	icons/fontawesome/solid/frown.svg	Frown	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1635	fontawesome	funnel-dollar	icons/fontawesome/solid/funnel-dollar.svg	Funnel Dollar	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1636	fontawesome	futbol-ball	icons/fontawesome/solid/futbol-ball.svg	Futbol Ball	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1637	fontawesome	futbol	icons/fontawesome/solid/futbol.svg	Futbol	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1638	fontawesome	g	icons/fontawesome/solid/g.svg	G	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1639	fontawesome	gamepad	icons/fontawesome/solid/gamepad.svg	Gamepad	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1640	fontawesome	gas-pump	icons/fontawesome/solid/gas-pump.svg	Gas Pump	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1642	fontawesome	gauge-med	icons/fontawesome/solid/gauge-med.svg	Gauge Med	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1643	fontawesome	gauge-simple-high	icons/fontawesome/solid/gauge-simple-high.svg	Gauge Simple High	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1644	fontawesome	gauge-simple-med	icons/fontawesome/solid/gauge-simple-med.svg	Gauge Simple Med	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:06	public
1645	fontawesome	gauge-simple	icons/fontawesome/solid/gauge-simple.svg	Gauge Simple	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:06	public
1646	fontawesome	gauge	icons/fontawesome/solid/gauge.svg	Gauge	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:06	public
1647	fontawesome	gavel	icons/fontawesome/solid/gavel.svg	Gavel	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1648	fontawesome	gbp	icons/fontawesome/solid/gbp.svg	Gbp	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1649	fontawesome	gear	icons/fontawesome/solid/gear.svg	Gear	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1650	fontawesome	gears	icons/fontawesome/solid/gears.svg	Gears	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1651	fontawesome	gem	icons/fontawesome/solid/gem.svg	Gem	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1652	fontawesome	genderless	icons/fontawesome/solid/genderless.svg	Genderless	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1653	fontawesome	ghost	icons/fontawesome/solid/ghost.svg	Ghost	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1655	fontawesome	gifts	icons/fontawesome/solid/gifts.svg	Gifts	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1656	fontawesome	glass-cheers	icons/fontawesome/solid/glass-cheers.svg	Glass Cheers	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1657	fontawesome	glass-martini-alt	icons/fontawesome/solid/glass-martini-alt.svg	Glass Martini Alt	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1658	fontawesome	glass-martini	icons/fontawesome/solid/glass-martini.svg	Glass Martini	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1660	fontawesome	glass-water	icons/fontawesome/solid/glass-water.svg	Glass Water	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:07	public
1661	fontawesome	glass-whiskey	icons/fontawesome/solid/glass-whiskey.svg	Glass Whiskey	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:07	public
1662	fontawesome	glasses	icons/fontawesome/solid/glasses.svg	Glasses	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:07	public
1663	fontawesome	globe-africa	icons/fontawesome/solid/globe-africa.svg	Globe Africa	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1665	fontawesome	globe-asia	icons/fontawesome/solid/globe-asia.svg	Globe Asia	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1666	fontawesome	globe-europe	icons/fontawesome/solid/globe-europe.svg	Globe Europe	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1667	fontawesome	globe-oceania	icons/fontawesome/solid/globe-oceania.svg	Globe Oceania	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1668	fontawesome	globe	icons/fontawesome/solid/globe.svg	Globe	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1669	fontawesome	golf-ball-tee	icons/fontawesome/solid/golf-ball-tee.svg	Golf Ball Tee	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1670	fontawesome	golf-ball	icons/fontawesome/solid/golf-ball.svg	Golf Ball	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1671	fontawesome	gopuram	icons/fontawesome/solid/gopuram.svg	Gopuram	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1672	fontawesome	graduation-cap	icons/fontawesome/solid/graduation-cap.svg	Graduation Cap	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1673	fontawesome	greater-than-equal	icons/fontawesome/solid/greater-than-equal.svg	Greater Than Equal	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1674	fontawesome	greater-than	icons/fontawesome/solid/greater-than.svg	Greater Than	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1676	fontawesome	grid-vertical	icons/fontawesome/solid/grid-vertical.svg	Grid Vertical	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:08	public
1677	fontawesome	grimace	icons/fontawesome/solid/grimace.svg	Grimace	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:08	public
1678	fontawesome	grin-alt	icons/fontawesome/solid/grin-alt.svg	Grin Alt	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:08	public
1679	fontawesome	grin-beam-sweat	icons/fontawesome/solid/grin-beam-sweat.svg	Grin Beam Sweat	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:08	public
1680	fontawesome	grin-beam	icons/fontawesome/solid/grin-beam.svg	Grin Beam	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1681	fontawesome	grin-hearts	icons/fontawesome/solid/grin-hearts.svg	Grin Hearts	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1682	fontawesome	grin-squint-tears	icons/fontawesome/solid/grin-squint-tears.svg	Grin Squint Tears	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1683	fontawesome	grin-squint	icons/fontawesome/solid/grin-squint.svg	Grin Squint	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1684	fontawesome	grin-stars	icons/fontawesome/solid/grin-stars.svg	Grin Stars	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1685	fontawesome	grin-tears	icons/fontawesome/solid/grin-tears.svg	Grin Tears	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1687	fontawesome	grin-tongue-wink	icons/fontawesome/solid/grin-tongue-wink.svg	Grin Tongue Wink	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1688	fontawesome	grin-tongue	icons/fontawesome/solid/grin-tongue.svg	Grin Tongue	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1689	fontawesome	grin-wink	icons/fontawesome/solid/grin-wink.svg	Grin Wink	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1690	fontawesome	grin	icons/fontawesome/solid/grin.svg	Grin	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1691	fontawesome	grip-horizontal	icons/fontawesome/solid/grip-horizontal.svg	Grip Horizontal	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1692	fontawesome	grip-lines-vertical	icons/fontawesome/solid/grip-lines-vertical.svg	Grip Lines Vertical	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:09	public
1693	fontawesome	grip-lines	icons/fontawesome/solid/grip-lines.svg	Grip Lines	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:09	public
1694	fontawesome	grip-vertical	icons/fontawesome/solid/grip-vertical.svg	Grip Vertical	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:09	public
1695	fontawesome	grip	icons/fontawesome/solid/grip.svg	Grip	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:09	public
1697	fontawesome	guarani-sign	icons/fontawesome/solid/guarani-sign.svg	Guarani Sign	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1698	fontawesome	guitar	icons/fontawesome/solid/guitar.svg	Guitar	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1699	fontawesome	gun	icons/fontawesome/solid/gun.svg	Gun	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1700	fontawesome	h-square	icons/fontawesome/solid/h-square.svg	H Square	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1701	fontawesome	h	icons/fontawesome/solid/h.svg	H	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1702	fontawesome	hamburger	icons/fontawesome/solid/hamburger.svg	Hamburger	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1703	fontawesome	hammer	icons/fontawesome/solid/hammer.svg	Hammer	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1704	fontawesome	hamsa	icons/fontawesome/solid/hamsa.svg	Hamsa	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1705	fontawesome	hand-back-fist	icons/fontawesome/solid/hand-back-fist.svg	Hand Back Fist	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1706	fontawesome	hand-dots	icons/fontawesome/solid/hand-dots.svg	Hand Dots	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1707	fontawesome	hand-fist	icons/fontawesome/solid/hand-fist.svg	Hand Fist	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1709	fontawesome	hand-holding-droplet	icons/fontawesome/solid/hand-holding-droplet.svg	Hand Holding Droplet	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:10	public
1710	fontawesome	hand-holding-hand	icons/fontawesome/solid/hand-holding-hand.svg	Hand Holding Hand	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:10	public
1711	fontawesome	hand-holding-heart	icons/fontawesome/solid/hand-holding-heart.svg	Hand Holding Heart	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:10	public
1712	fontawesome	hand-holding-medical	icons/fontawesome/solid/hand-holding-medical.svg	Hand Holding Medical	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:10	public
1713	fontawesome	hand-holding-usd	icons/fontawesome/solid/hand-holding-usd.svg	Hand Holding Usd	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1714	fontawesome	hand-holding-water	icons/fontawesome/solid/hand-holding-water.svg	Hand Holding Water	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1716	fontawesome	hand-lizard	icons/fontawesome/solid/hand-lizard.svg	Hand Lizard	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1717	fontawesome	hand-middle-finger	icons/fontawesome/solid/hand-middle-finger.svg	Hand Middle Finger	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1718	fontawesome	hand-paper	icons/fontawesome/solid/hand-paper.svg	Hand Paper	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1719	fontawesome	hand-peace	icons/fontawesome/solid/hand-peace.svg	Hand Peace	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1720	fontawesome	hand-point-down	icons/fontawesome/solid/hand-point-down.svg	Hand Point Down	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1721	fontawesome	hand-point-left	icons/fontawesome/solid/hand-point-left.svg	Hand Point Left	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1723	fontawesome	hand-point-up	icons/fontawesome/solid/hand-point-up.svg	Hand Point Up	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1724	fontawesome	hand-pointer	icons/fontawesome/solid/hand-pointer.svg	Hand Pointer	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1725	fontawesome	hand-rock	icons/fontawesome/solid/hand-rock.svg	Hand Rock	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:11	public
1726	fontawesome	hand-scissors	icons/fontawesome/solid/hand-scissors.svg	Hand Scissors	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:11	public
1727	fontawesome	hand-sparkles	icons/fontawesome/solid/hand-sparkles.svg	Hand Sparkles	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:11	public
1728	fontawesome	hand-spock	icons/fontawesome/solid/hand-spock.svg	Hand Spock	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:11	public
1729	fontawesome	hand	icons/fontawesome/solid/hand.svg	Hand	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1730	fontawesome	handcuffs	icons/fontawesome/solid/handcuffs.svg	Handcuffs	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1732	fontawesome	hands-asl-interpreting	icons/fontawesome/solid/hands-asl-interpreting.svg	Hands Asl Interpreting	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1733	fontawesome	hands-bound	icons/fontawesome/solid/hands-bound.svg	Hands Bound	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1734	fontawesome	hands-bubbles	icons/fontawesome/solid/hands-bubbles.svg	Hands Bubbles	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1735	fontawesome	hands-clapping	icons/fontawesome/solid/hands-clapping.svg	Hands Clapping	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1736	fontawesome	hands-helping	icons/fontawesome/solid/hands-helping.svg	Hands Helping	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1737	fontawesome	hands-holding-child	icons/fontawesome/solid/hands-holding-child.svg	Hands Holding Child	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1738	fontawesome	hands-holding-circle	icons/fontawesome/solid/hands-holding-circle.svg	Hands Holding Circle	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1739	fontawesome	hands-holding	icons/fontawesome/solid/hands-holding.svg	Hands Holding	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1740	fontawesome	hands-praying	icons/fontawesome/solid/hands-praying.svg	Hands Praying	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1741	fontawesome	hands-wash	icons/fontawesome/solid/hands-wash.svg	Hands Wash	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:12	public
1742	fontawesome	hands	icons/fontawesome/solid/hands.svg	Hands	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:12	public
1744	fontawesome	handshake-alt	icons/fontawesome/solid/handshake-alt.svg	Handshake Alt	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:12	public
1745	fontawesome	handshake-angle	icons/fontawesome/solid/handshake-angle.svg	Handshake Angle	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:12	public
1746	fontawesome	handshake-simple-slash	icons/fontawesome/solid/handshake-simple-slash.svg	Handshake Simple Slash	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1747	fontawesome	handshake-simple	icons/fontawesome/solid/handshake-simple.svg	Handshake Simple	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1748	fontawesome	handshake-slash	icons/fontawesome/solid/handshake-slash.svg	Handshake Slash	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1749	fontawesome	handshake	icons/fontawesome/solid/handshake.svg	Handshake	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1750	fontawesome	hanukiah	icons/fontawesome/solid/hanukiah.svg	Hanukiah	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1751	fontawesome	hard-drive	icons/fontawesome/solid/hard-drive.svg	Hard Drive	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1752	fontawesome	hard-hat	icons/fontawesome/solid/hard-hat.svg	Hard Hat	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1753	fontawesome	hard-of-hearing	icons/fontawesome/solid/hard-of-hearing.svg	Hard Of Hearing	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1754	fontawesome	hashtag	icons/fontawesome/solid/hashtag.svg	Hashtag	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1756	fontawesome	hat-cowboy	icons/fontawesome/solid/hat-cowboy.svg	Hat Cowboy	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1757	fontawesome	hat-hard	icons/fontawesome/solid/hat-hard.svg	Hat Hard	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:13	public
1758	fontawesome	hat-wizard	icons/fontawesome/solid/hat-wizard.svg	Hat Wizard	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:13	public
1759	fontawesome	haykal	icons/fontawesome/solid/haykal.svg	Haykal	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:13	public
1760	fontawesome	hdd	icons/fontawesome/solid/hdd.svg	Hdd	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:13	public
1761	fontawesome	head-side-cough-slash	icons/fontawesome/solid/head-side-cough-slash.svg	Head Side Cough Slash	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:13	public
1762	fontawesome	head-side-cough	icons/fontawesome/solid/head-side-cough.svg	Head Side Cough	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:13	public
1763	fontawesome	head-side-mask	icons/fontawesome/solid/head-side-mask.svg	Head Side Mask	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1765	fontawesome	header	icons/fontawesome/solid/header.svg	Header	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1766	fontawesome	heading	icons/fontawesome/solid/heading.svg	Heading	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1767	fontawesome	headphones-alt	icons/fontawesome/solid/headphones-alt.svg	Headphones Alt	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1768	fontawesome	headphones-simple	icons/fontawesome/solid/headphones-simple.svg	Headphones Simple	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1769	fontawesome	headphones	icons/fontawesome/solid/headphones.svg	Headphones	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1771	fontawesome	heart-broken	icons/fontawesome/solid/heart-broken.svg	Heart Broken	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1772	fontawesome	heart-circle-bolt	icons/fontawesome/solid/heart-circle-bolt.svg	Heart Circle Bolt	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:14	public
1773	fontawesome	heart-circle-check	icons/fontawesome/solid/heart-circle-check.svg	Heart Circle Check	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:14	public
1775	fontawesome	heart-circle-minus	icons/fontawesome/solid/heart-circle-minus.svg	Heart Circle Minus	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:14	public
1776	fontawesome	heart-circle-plus	icons/fontawesome/solid/heart-circle-plus.svg	Heart Circle Plus	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:14	public
1777	fontawesome	heart-circle-xmark	icons/fontawesome/solid/heart-circle-xmark.svg	Heart Circle Xmark	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:14	public
1778	fontawesome	heart-crack	icons/fontawesome/solid/heart-crack.svg	Heart Crack	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:14	public
1779	fontawesome	heart-music-camera-bolt	icons/fontawesome/solid/heart-music-camera-bolt.svg	Heart Music Camera Bolt	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1780	fontawesome	heart-pulse	icons/fontawesome/solid/heart-pulse.svg	Heart Pulse	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1781	fontawesome	heart	icons/fontawesome/solid/heart.svg	Heart	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1782	fontawesome	heartbeat	icons/fontawesome/solid/heartbeat.svg	Heartbeat	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1783	fontawesome	helicopter-symbol	icons/fontawesome/solid/helicopter-symbol.svg	Helicopter Symbol	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1784	fontawesome	helicopter	icons/fontawesome/solid/helicopter.svg	Helicopter	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1786	fontawesome	helmet-un	icons/fontawesome/solid/helmet-un.svg	Helmet Un	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1787	fontawesome	heptagon	icons/fontawesome/solid/heptagon.svg	Heptagon	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1788	fontawesome	hexagon-nodes-bolt	icons/fontawesome/solid/hexagon-nodes-bolt.svg	Hexagon Nodes Bolt	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:15	public
1789	fontawesome	hexagon-nodes	icons/fontawesome/solid/hexagon-nodes.svg	Hexagon Nodes	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:15	public
1790	fontawesome	hexagon	icons/fontawesome/solid/hexagon.svg	Hexagon	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:15	public
1791	fontawesome	highlighter	icons/fontawesome/solid/highlighter.svg	Highlighter	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:15	public
1792	fontawesome	hiking	icons/fontawesome/solid/hiking.svg	Hiking	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:15	public
1793	fontawesome	hill-avalanche	icons/fontawesome/solid/hill-avalanche.svg	Hill Avalanche	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:15	public
1794	fontawesome	hill-rockslide	icons/fontawesome/solid/hill-rockslide.svg	Hill Rockslide	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:15	public
1795	fontawesome	hippo	icons/fontawesome/solid/hippo.svg	Hippo	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:15	public
1797	fontawesome	hockey-puck	icons/fontawesome/solid/hockey-puck.svg	Hockey Puck	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1798	fontawesome	holly-berry	icons/fontawesome/solid/holly-berry.svg	Holly Berry	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1799	fontawesome	home-alt	icons/fontawesome/solid/home-alt.svg	Home Alt	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1800	fontawesome	home-lg-alt	icons/fontawesome/solid/home-lg-alt.svg	Home Lg Alt	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1801	fontawesome	home-lg	icons/fontawesome/solid/home-lg.svg	Home Lg	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1802	fontawesome	home-user	icons/fontawesome/solid/home-user.svg	Home User	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1803	fontawesome	home	icons/fontawesome/solid/home.svg	Home	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1804	fontawesome	horse-head	icons/fontawesome/solid/horse-head.svg	Horse Head	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1805	fontawesome	horse	icons/fontawesome/solid/horse.svg	Horse	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:16	public
1807	fontawesome	hospital-symbol	icons/fontawesome/solid/hospital-symbol.svg	Hospital Symbol	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:16	public
1808	fontawesome	hospital-user	icons/fontawesome/solid/hospital-user.svg	Hospital User	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:16	public
1809	fontawesome	hospital-wide	icons/fontawesome/solid/hospital-wide.svg	Hospital Wide	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:16	public
1810	fontawesome	hospital	icons/fontawesome/solid/hospital.svg	Hospital	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:16	public
1811	fontawesome	hot-tub-person	icons/fontawesome/solid/hot-tub-person.svg	Hot Tub Person	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:16	public
1812	fontawesome	hot-tub	icons/fontawesome/solid/hot-tub.svg	Hot Tub	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1813	fontawesome	hotdog	icons/fontawesome/solid/hotdog.svg	Hotdog	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1814	fontawesome	hotel	icons/fontawesome/solid/hotel.svg	Hotel	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1816	fontawesome	hourglass-2	icons/fontawesome/solid/hourglass-2.svg	Hourglass 2	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1817	fontawesome	hourglass-3	icons/fontawesome/solid/hourglass-3.svg	Hourglass 3	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1818	fontawesome	hourglass-empty	icons/fontawesome/solid/hourglass-empty.svg	Hourglass Empty	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1819	fontawesome	hourglass-end	icons/fontawesome/solid/hourglass-end.svg	Hourglass End	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1820	fontawesome	hourglass-half	icons/fontawesome/solid/hourglass-half.svg	Hourglass Half	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1821	fontawesome	hourglass-start	icons/fontawesome/solid/hourglass-start.svg	Hourglass Start	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:17	public
1822	fontawesome	hourglass	icons/fontawesome/solid/hourglass.svg	Hourglass	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:17	public
1824	fontawesome	house-chimney-medical	icons/fontawesome/solid/house-chimney-medical.svg	House Chimney Medical	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:17	public
1825	fontawesome	house-chimney-user	icons/fontawesome/solid/house-chimney-user.svg	House Chimney User	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:17	public
1827	fontawesome	house-chimney	icons/fontawesome/solid/house-chimney.svg	House Chimney	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:17	public
1828	fontawesome	house-circle-check	icons/fontawesome/solid/house-circle-check.svg	House Circle Check	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:17	public
1829	fontawesome	house-circle-exclamation	icons/fontawesome/solid/house-circle-exclamation.svg	House Circle Exclamation	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:18	public
1830	fontawesome	house-circle-xmark	icons/fontawesome/solid/house-circle-xmark.svg	House Circle Xmark	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:18	public
1831	fontawesome	house-crack	icons/fontawesome/solid/house-crack.svg	House Crack	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:18	public
1832	fontawesome	house-damage	icons/fontawesome/solid/house-damage.svg	House Damage	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:18	public
1833	fontawesome	house-fire	icons/fontawesome/solid/house-fire.svg	House Fire	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:18	public
1834	fontawesome	house-flag	icons/fontawesome/solid/house-flag.svg	House Flag	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:18	public
1836	fontawesome	house-flood-water	icons/fontawesome/solid/house-flood-water.svg	House Flood Water	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:18	public
1837	fontawesome	house-laptop	icons/fontawesome/solid/house-laptop.svg	House Laptop	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:18	public
1838	fontawesome	house-lock	icons/fontawesome/solid/house-lock.svg	House Lock	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:18	public
1839	fontawesome	house-medical-circle-check	icons/fontawesome/solid/house-medical-circle-check.svg	House Medical Circle Check	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:18	public
1840	fontawesome	house-medical-circle-exclamation	icons/fontawesome/solid/house-medical-circle-exclamation.svg	House Medical Circle Exclamation	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:18	public
1841	fontawesome	house-medical-circle-xmark	icons/fontawesome/solid/house-medical-circle-xmark.svg	House Medical Circle Xmark	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:18	public
1842	fontawesome	house-medical-flag	icons/fontawesome/solid/house-medical-flag.svg	House Medical Flag	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:18	public
1843	fontawesome	house-medical	icons/fontawesome/solid/house-medical.svg	House Medical	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:18	public
1845	fontawesome	house-tsunami	icons/fontawesome/solid/house-tsunami.svg	House Tsunami	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:19	public
1846	fontawesome	house-user	icons/fontawesome/solid/house-user.svg	House User	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:19	public
1847	fontawesome	house	icons/fontawesome/solid/house.svg	House	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:19	public
1848	fontawesome	hryvnia-sign	icons/fontawesome/solid/hryvnia-sign.svg	Hryvnia Sign	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:19	public
1849	fontawesome	hryvnia	icons/fontawesome/solid/hryvnia.svg	Hryvnia	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:19	public
1850	fontawesome	hurricane	icons/fontawesome/solid/hurricane.svg	Hurricane	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:19	public
1851	fontawesome	i-cursor	icons/fontawesome/solid/i-cursor.svg	I Cursor	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:19	public
1852	fontawesome	i	icons/fontawesome/solid/i.svg	I	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:19	public
1853	fontawesome	ice-cream	icons/fontawesome/solid/ice-cream.svg	Ice Cream	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:19	public
1854	fontawesome	icicles	icons/fontawesome/solid/icicles.svg	Icicles	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:19	public
1855	fontawesome	icons	icons/fontawesome/solid/icons.svg	Icons	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:19	public
1856	fontawesome	id-badge	icons/fontawesome/solid/id-badge.svg	Id Badge	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:19	public
1858	fontawesome	id-card-clip	icons/fontawesome/solid/id-card-clip.svg	Id Card Clip	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:19	public
1859	fontawesome	id-card	icons/fontawesome/solid/id-card.svg	Id Card	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:19	public
1860	fontawesome	igloo	icons/fontawesome/solid/igloo.svg	Igloo	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:19	public
1861	fontawesome	ils	icons/fontawesome/solid/ils.svg	Ils	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:20	public
1862	fontawesome	image-portrait	icons/fontawesome/solid/image-portrait.svg	Image Portrait	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:20	public
1863	fontawesome	image	icons/fontawesome/solid/image.svg	Image	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:20	public
1864	fontawesome	images	icons/fontawesome/solid/images.svg	Images	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:20	public
1865	fontawesome	inbox	icons/fontawesome/solid/inbox.svg	Inbox	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:20	public
1866	fontawesome	indent	icons/fontawesome/solid/indent.svg	Indent	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:20	public
1867	fontawesome	indian-rupee-sign	icons/fontawesome/solid/indian-rupee-sign.svg	Indian Rupee Sign	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:20	public
1869	fontawesome	industry	icons/fontawesome/solid/industry.svg	Industry	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1870	fontawesome	infinity	icons/fontawesome/solid/infinity.svg	Infinity	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1871	fontawesome	info-circle	icons/fontawesome/solid/info-circle.svg	Info Circle	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1872	fontawesome	info	icons/fontawesome/solid/info.svg	Info	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1873	fontawesome	inr	icons/fontawesome/solid/inr.svg	Inr	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1874	fontawesome	institution	icons/fontawesome/solid/institution.svg	Institution	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1875	fontawesome	italic	icons/fontawesome/solid/italic.svg	Italic	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1876	fontawesome	j	icons/fontawesome/solid/j.svg	J	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1877	fontawesome	jar-wheat	icons/fontawesome/solid/jar-wheat.svg	Jar Wheat	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1878	fontawesome	jar	icons/fontawesome/solid/jar.svg	Jar	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:21	public
1879	fontawesome	jedi	icons/fontawesome/solid/jedi.svg	Jedi	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:21	public
1880	fontawesome	jet-fighter-up	icons/fontawesome/solid/jet-fighter-up.svg	Jet Fighter Up	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:21	public
1883	fontawesome	journal-whills	icons/fontawesome/solid/journal-whills.svg	Journal Whills	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:21	public
1884	fontawesome	jpy	icons/fontawesome/solid/jpy.svg	Jpy	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:21	public
1885	fontawesome	jug-detergent	icons/fontawesome/solid/jug-detergent.svg	Jug Detergent	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1886	fontawesome	k	icons/fontawesome/solid/k.svg	K	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1887	fontawesome	kaaba	icons/fontawesome/solid/kaaba.svg	Kaaba	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1888	fontawesome	key	icons/fontawesome/solid/key.svg	Key	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1890	fontawesome	khanda	icons/fontawesome/solid/khanda.svg	Khanda	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1891	fontawesome	kip-sign	icons/fontawesome/solid/kip-sign.svg	Kip Sign	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1892	fontawesome	kiss-beam	icons/fontawesome/solid/kiss-beam.svg	Kiss Beam	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1893	fontawesome	kiss-wink-heart	icons/fontawesome/solid/kiss-wink-heart.svg	Kiss Wink Heart	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1894	fontawesome	kiss	icons/fontawesome/solid/kiss.svg	Kiss	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1895	fontawesome	kit-medical	icons/fontawesome/solid/kit-medical.svg	Kit Medical	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:22	public
1896	fontawesome	kitchen-set	icons/fontawesome/solid/kitchen-set.svg	Kitchen Set	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:22	public
1897	fontawesome	kiwi-bird	icons/fontawesome/solid/kiwi-bird.svg	Kiwi Bird	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:22	public
1898	fontawesome	krw	icons/fontawesome/solid/krw.svg	Krw	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:22	public
1899	fontawesome	l	icons/fontawesome/solid/l.svg	L	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:22	public
1901	fontawesome	land-mine-on	icons/fontawesome/solid/land-mine-on.svg	Land Mine On	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1902	fontawesome	landmark-alt	icons/fontawesome/solid/landmark-alt.svg	Landmark Alt	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1903	fontawesome	landmark-dome	icons/fontawesome/solid/landmark-dome.svg	Landmark Dome	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1904	fontawesome	landmark-flag	icons/fontawesome/solid/landmark-flag.svg	Landmark Flag	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1905	fontawesome	landmark	icons/fontawesome/solid/landmark.svg	Landmark	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1906	fontawesome	language	icons/fontawesome/solid/language.svg	Language	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1907	fontawesome	laptop-code	icons/fontawesome/solid/laptop-code.svg	Laptop Code	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1908	fontawesome	laptop-file	icons/fontawesome/solid/laptop-file.svg	Laptop File	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1909	fontawesome	laptop-house	icons/fontawesome/solid/laptop-house.svg	Laptop House	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1911	fontawesome	laptop	icons/fontawesome/solid/laptop.svg	Laptop	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:23	public
1912	fontawesome	lari-sign	icons/fontawesome/solid/lari-sign.svg	Lari Sign	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:23	public
1913	fontawesome	laugh-beam	icons/fontawesome/solid/laugh-beam.svg	Laugh Beam	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:23	public
1914	fontawesome	laugh-squint	icons/fontawesome/solid/laugh-squint.svg	Laugh Squint	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:23	public
1915	fontawesome	laugh-wink	icons/fontawesome/solid/laugh-wink.svg	Laugh Wink	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:23	public
1916	fontawesome	laugh	icons/fontawesome/solid/laugh.svg	Laugh	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:23	public
1917	fontawesome	layer-group	icons/fontawesome/solid/layer-group.svg	Layer Group	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1918	fontawesome	leaf	icons/fontawesome/solid/leaf.svg	Leaf	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1919	fontawesome	left-long	icons/fontawesome/solid/left-long.svg	Left Long	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1920	fontawesome	left-right	icons/fontawesome/solid/left-right.svg	Left Right	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1921	fontawesome	legal	icons/fontawesome/solid/legal.svg	Legal	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1922	fontawesome	lemon	icons/fontawesome/solid/lemon.svg	Lemon	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1924	fontawesome	less-than	icons/fontawesome/solid/less-than.svg	Less Than	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1925	fontawesome	level-down-alt	icons/fontawesome/solid/level-down-alt.svg	Level Down Alt	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1926	fontawesome	level-down	icons/fontawesome/solid/level-down.svg	Level Down	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1927	fontawesome	level-up-alt	icons/fontawesome/solid/level-up-alt.svg	Level Up Alt	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1928	fontawesome	level-up	icons/fontawesome/solid/level-up.svg	Level Up	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:24	public
1929	fontawesome	life-ring	icons/fontawesome/solid/life-ring.svg	Life Ring	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:24	public
1930	fontawesome	lightbulb	icons/fontawesome/solid/lightbulb.svg	Lightbulb	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:24	public
1931	fontawesome	line-chart	icons/fontawesome/solid/line-chart.svg	Line Chart	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:24	public
1932	fontawesome	lines-leaning	icons/fontawesome/solid/lines-leaning.svg	Lines Leaning	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:24	public
1933	fontawesome	link-slash	icons/fontawesome/solid/link-slash.svg	Link Slash	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1934	fontawesome	link	icons/fontawesome/solid/link.svg	Link	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1935	fontawesome	lira-sign	icons/fontawesome/solid/lira-sign.svg	Lira Sign	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1937	fontawesome	list-alt	icons/fontawesome/solid/list-alt.svg	List Alt	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1938	fontawesome	list-check	icons/fontawesome/solid/list-check.svg	List Check	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1939	fontawesome	list-dots	icons/fontawesome/solid/list-dots.svg	List Dots	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1941	fontawesome	list-ol	icons/fontawesome/solid/list-ol.svg	List Ol	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1942	fontawesome	list-squares	icons/fontawesome/solid/list-squares.svg	List Squares	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1943	fontawesome	list-ul	icons/fontawesome/solid/list-ul.svg	List Ul	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1944	fontawesome	list	icons/fontawesome/solid/list.svg	List	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:25	public
1945	fontawesome	litecoin-sign	icons/fontawesome/solid/litecoin-sign.svg	Litecoin Sign	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:25	public
1946	fontawesome	location-arrow	icons/fontawesome/solid/location-arrow.svg	Location Arrow	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:25	public
1948	fontawesome	location-dot	icons/fontawesome/solid/location-dot.svg	Location Dot	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:25	public
1949	fontawesome	location-pin-lock	icons/fontawesome/solid/location-pin-lock.svg	Location Pin Lock	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1950	fontawesome	location-pin	icons/fontawesome/solid/location-pin.svg	Location Pin	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1951	fontawesome	location	icons/fontawesome/solid/location.svg	Location	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1952	fontawesome	lock-open	icons/fontawesome/solid/lock-open.svg	Lock Open	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1953	fontawesome	lock	icons/fontawesome/solid/lock.svg	Lock	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1954	fontawesome	locust	icons/fontawesome/solid/locust.svg	Locust	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1955	fontawesome	long-arrow-alt-down	icons/fontawesome/solid/long-arrow-alt-down.svg	Long Arrow Alt Down	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1956	fontawesome	long-arrow-alt-left	icons/fontawesome/solid/long-arrow-alt-left.svg	Long Arrow Alt Left	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1957	fontawesome	long-arrow-alt-right	icons/fontawesome/solid/long-arrow-alt-right.svg	Long Arrow Alt Right	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1959	fontawesome	long-arrow-down	icons/fontawesome/solid/long-arrow-down.svg	Long Arrow Down	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1960	fontawesome	long-arrow-left	icons/fontawesome/solid/long-arrow-left.svg	Long Arrow Left	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1961	fontawesome	long-arrow-right	icons/fontawesome/solid/long-arrow-right.svg	Long Arrow Right	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:26	public
1962	fontawesome	long-arrow-up	icons/fontawesome/solid/long-arrow-up.svg	Long Arrow Up	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:26	public
1963	fontawesome	low-vision	icons/fontawesome/solid/low-vision.svg	Low Vision	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:26	public
1964	fontawesome	luggage-cart	icons/fontawesome/solid/luggage-cart.svg	Luggage Cart	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1965	fontawesome	lungs-virus	icons/fontawesome/solid/lungs-virus.svg	Lungs Virus	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1966	fontawesome	lungs	icons/fontawesome/solid/lungs.svg	Lungs	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1967	fontawesome	m	icons/fontawesome/solid/m.svg	M	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1969	fontawesome	magic	icons/fontawesome/solid/magic.svg	Magic	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1970	fontawesome	magnet	icons/fontawesome/solid/magnet.svg	Magnet	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1971	fontawesome	magnifying-glass-arrow-right	icons/fontawesome/solid/magnifying-glass-arrow-right.svg	Magnifying Glass Arrow Right	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1972	fontawesome	magnifying-glass-chart	icons/fontawesome/solid/magnifying-glass-chart.svg	Magnifying Glass Chart	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1973	fontawesome	magnifying-glass-dollar	icons/fontawesome/solid/magnifying-glass-dollar.svg	Magnifying Glass Dollar	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1974	fontawesome	magnifying-glass-location	icons/fontawesome/solid/magnifying-glass-location.svg	Magnifying Glass Location	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1975	fontawesome	magnifying-glass-minus	icons/fontawesome/solid/magnifying-glass-minus.svg	Magnifying Glass Minus	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1977	fontawesome	magnifying-glass	icons/fontawesome/solid/magnifying-glass.svg	Magnifying Glass	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:27	public
1978	fontawesome	mail-bulk	icons/fontawesome/solid/mail-bulk.svg	Mail Bulk	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:27	public
1979	fontawesome	mail-forward	icons/fontawesome/solid/mail-forward.svg	Mail Forward	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:27	public
1980	fontawesome	mail-reply-all	icons/fontawesome/solid/mail-reply-all.svg	Mail Reply All	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:27	public
1981	fontawesome	mail-reply	icons/fontawesome/solid/mail-reply.svg	Mail Reply	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1982	fontawesome	male	icons/fontawesome/solid/male.svg	Male	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1983	fontawesome	manat-sign	icons/fontawesome/solid/manat-sign.svg	Manat Sign	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1984	fontawesome	map-location-dot	icons/fontawesome/solid/map-location-dot.svg	Map Location Dot	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1985	fontawesome	map-location	icons/fontawesome/solid/map-location.svg	Map Location	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1986	fontawesome	map-marked-alt	icons/fontawesome/solid/map-marked-alt.svg	Map Marked Alt	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1987	fontawesome	map-marked	icons/fontawesome/solid/map-marked.svg	Map Marked	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1988	fontawesome	map-marker-alt	icons/fontawesome/solid/map-marker-alt.svg	Map Marker Alt	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1989	fontawesome	map-marker	icons/fontawesome/solid/map-marker.svg	Map Marker	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1991	fontawesome	map-signs	icons/fontawesome/solid/map-signs.svg	Map Signs	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1992	fontawesome	map	icons/fontawesome/solid/map.svg	Map	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1993	fontawesome	marker	icons/fontawesome/solid/marker.svg	Marker	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1994	fontawesome	mars-and-venus-burst	icons/fontawesome/solid/mars-and-venus-burst.svg	Mars And Venus Burst	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:28	public
1996	fontawesome	mars-double	icons/fontawesome/solid/mars-double.svg	Mars Double	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:28	public
1997	fontawesome	mars-stroke-h	icons/fontawesome/solid/mars-stroke-h.svg	Mars Stroke H	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
1999	fontawesome	mars-stroke-up	icons/fontawesome/solid/mars-stroke-up.svg	Mars Stroke Up	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2000	fontawesome	mars-stroke-v	icons/fontawesome/solid/mars-stroke-v.svg	Mars Stroke V	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2001	fontawesome	mars-stroke	icons/fontawesome/solid/mars-stroke.svg	Mars Stroke	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2002	fontawesome	mars	icons/fontawesome/solid/mars.svg	Mars	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2003	fontawesome	martini-glass-citrus	icons/fontawesome/solid/martini-glass-citrus.svg	Martini Glass Citrus	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2004	fontawesome	martini-glass-empty	icons/fontawesome/solid/martini-glass-empty.svg	Martini Glass Empty	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2005	fontawesome	martini-glass	icons/fontawesome/solid/martini-glass.svg	Martini Glass	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2006	fontawesome	mask-face	icons/fontawesome/solid/mask-face.svg	Mask Face	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2008	fontawesome	mask	icons/fontawesome/solid/mask.svg	Mask	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2009	fontawesome	masks-theater	icons/fontawesome/solid/masks-theater.svg	Masks Theater	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2010	fontawesome	mattress-pillow	icons/fontawesome/solid/mattress-pillow.svg	Mattress Pillow	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:29	public
2011	fontawesome	maximize	icons/fontawesome/solid/maximize.svg	Maximize	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:29	public
2012	fontawesome	medal	icons/fontawesome/solid/medal.svg	Medal	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:29	public
2013	fontawesome	medkit	icons/fontawesome/solid/medkit.svg	Medkit	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2014	fontawesome	meh-blank	icons/fontawesome/solid/meh-blank.svg	Meh Blank	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2015	fontawesome	meh-rolling-eyes	icons/fontawesome/solid/meh-rolling-eyes.svg	Meh Rolling Eyes	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2016	fontawesome	meh	icons/fontawesome/solid/meh.svg	Meh	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2017	fontawesome	memory	icons/fontawesome/solid/memory.svg	Memory	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2018	fontawesome	menorah	icons/fontawesome/solid/menorah.svg	Menorah	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2019	fontawesome	mercury	icons/fontawesome/solid/mercury.svg	Mercury	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2020	fontawesome	message	icons/fontawesome/solid/message.svg	Message	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2022	fontawesome	microchip	icons/fontawesome/solid/microchip.svg	Microchip	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2023	fontawesome	microphone-alt-slash	icons/fontawesome/solid/microphone-alt-slash.svg	Microphone Alt Slash	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2024	fontawesome	microphone-alt	icons/fontawesome/solid/microphone-alt.svg	Microphone Alt	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2025	fontawesome	microphone-lines-slash	icons/fontawesome/solid/microphone-lines-slash.svg	Microphone Lines Slash	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2026	fontawesome	microphone-lines	icons/fontawesome/solid/microphone-lines.svg	Microphone Lines	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2028	fontawesome	microphone	icons/fontawesome/solid/microphone.svg	Microphone	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:30	public
2029	fontawesome	microscope	icons/fontawesome/solid/microscope.svg	Microscope	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2030	fontawesome	mill-sign	icons/fontawesome/solid/mill-sign.svg	Mill Sign	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2031	fontawesome	minimize	icons/fontawesome/solid/minimize.svg	Minimize	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2032	fontawesome	minus-circle	icons/fontawesome/solid/minus-circle.svg	Minus Circle	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2033	fontawesome	minus-square	icons/fontawesome/solid/minus-square.svg	Minus Square	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2034	fontawesome	minus	icons/fontawesome/solid/minus.svg	Minus	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2035	fontawesome	mitten	icons/fontawesome/solid/mitten.svg	Mitten	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2036	fontawesome	mobile-alt	icons/fontawesome/solid/mobile-alt.svg	Mobile Alt	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2037	fontawesome	mobile-android-alt	icons/fontawesome/solid/mobile-android-alt.svg	Mobile Android Alt	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2038	fontawesome	mobile-android	icons/fontawesome/solid/mobile-android.svg	Mobile Android	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2039	fontawesome	mobile-button	icons/fontawesome/solid/mobile-button.svg	Mobile Button	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2041	fontawesome	mobile-retro	icons/fontawesome/solid/mobile-retro.svg	Mobile Retro	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2042	fontawesome	mobile-screen-button	icons/fontawesome/solid/mobile-screen-button.svg	Mobile Screen Button	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2043	fontawesome	mobile-screen	icons/fontawesome/solid/mobile-screen.svg	Mobile Screen	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:31	public
2044	fontawesome	mobile-vibrate	icons/fontawesome/solid/mobile-vibrate.svg	Mobile Vibrate	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:31	public
2045	fontawesome	mobile	icons/fontawesome/solid/mobile.svg	Mobile	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2046	fontawesome	money-bill-1-wave	icons/fontawesome/solid/money-bill-1-wave.svg	Money Bill 1 Wave	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2047	fontawesome	money-bill-1	icons/fontawesome/solid/money-bill-1.svg	Money Bill 1	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2048	fontawesome	money-bill-alt	icons/fontawesome/solid/money-bill-alt.svg	Money Bill Alt	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2050	fontawesome	money-bill-trend-up	icons/fontawesome/solid/money-bill-trend-up.svg	Money Bill Trend Up	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2052	fontawesome	money-bill-wave	icons/fontawesome/solid/money-bill-wave.svg	Money Bill Wave	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2053	fontawesome	money-bill-wheat	icons/fontawesome/solid/money-bill-wheat.svg	Money Bill Wheat	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2054	fontawesome	money-bill	icons/fontawesome/solid/money-bill.svg	Money Bill	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2055	fontawesome	money-bills	icons/fontawesome/solid/money-bills.svg	Money Bills	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2056	fontawesome	money-check-alt	icons/fontawesome/solid/money-check-alt.svg	Money Check Alt	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2058	fontawesome	money-check	icons/fontawesome/solid/money-check.svg	Money Check	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2059	fontawesome	monument	icons/fontawesome/solid/monument.svg	Monument	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2060	fontawesome	moon	icons/fontawesome/solid/moon.svg	Moon	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2061	fontawesome	mortar-board	icons/fontawesome/solid/mortar-board.svg	Mortar Board	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2062	fontawesome	mortar-pestle	icons/fontawesome/solid/mortar-pestle.svg	Mortar Pestle	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2063	fontawesome	mosque	icons/fontawesome/solid/mosque.svg	Mosque	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2064	fontawesome	mosquito-net	icons/fontawesome/solid/mosquito-net.svg	Mosquito Net	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2065	fontawesome	mosquito	icons/fontawesome/solid/mosquito.svg	Mosquito	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2066	fontawesome	motorcycle	icons/fontawesome/solid/motorcycle.svg	Motorcycle	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2067	fontawesome	mound	icons/fontawesome/solid/mound.svg	Mound	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2068	fontawesome	mountain-city	icons/fontawesome/solid/mountain-city.svg	Mountain City	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2070	fontawesome	mountain	icons/fontawesome/solid/mountain.svg	Mountain	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2071	fontawesome	mouse-pointer	icons/fontawesome/solid/mouse-pointer.svg	Mouse Pointer	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2072	fontawesome	mouse	icons/fontawesome/solid/mouse.svg	Mouse	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2073	fontawesome	mug-hot	icons/fontawesome/solid/mug-hot.svg	Mug Hot	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2074	fontawesome	mug-saucer	icons/fontawesome/solid/mug-saucer.svg	Mug Saucer	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2075	fontawesome	multiply	icons/fontawesome/solid/multiply.svg	Multiply	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2076	fontawesome	museum	icons/fontawesome/solid/museum.svg	Museum	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2077	fontawesome	music	icons/fontawesome/solid/music.svg	Music	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2078	fontawesome	n	icons/fontawesome/solid/n.svg	N	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2079	fontawesome	naira-sign	icons/fontawesome/solid/naira-sign.svg	Naira Sign	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2080	fontawesome	navicon	icons/fontawesome/solid/navicon.svg	Navicon	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2081	fontawesome	network-wired	icons/fontawesome/solid/network-wired.svg	Network Wired	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2082	fontawesome	neuter	icons/fontawesome/solid/neuter.svg	Neuter	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2084	fontawesome	non-binary	icons/fontawesome/solid/non-binary.svg	Non Binary	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2085	fontawesome	not-equal	icons/fontawesome/solid/not-equal.svg	Not Equal	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2086	fontawesome	notdef	icons/fontawesome/solid/notdef.svg	Notdef	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2087	fontawesome	note-sticky	icons/fontawesome/solid/note-sticky.svg	Note Sticky	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2088	fontawesome	notes-medical	icons/fontawesome/solid/notes-medical.svg	Notes Medical	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2089	fontawesome	o	icons/fontawesome/solid/o.svg	O	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2090	fontawesome	object-group	icons/fontawesome/solid/object-group.svg	Object Group	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2091	fontawesome	object-ungroup	icons/fontawesome/solid/object-ungroup.svg	Object Ungroup	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2092	fontawesome	octagon	icons/fontawesome/solid/octagon.svg	Octagon	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2093	fontawesome	oil-can	icons/fontawesome/solid/oil-can.svg	Oil Can	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2095	fontawesome	om	icons/fontawesome/solid/om.svg	Om	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2096	fontawesome	otter	icons/fontawesome/solid/otter.svg	Otter	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2097	fontawesome	outdent	icons/fontawesome/solid/outdent.svg	Outdent	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2098	fontawesome	p	icons/fontawesome/solid/p.svg	P	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2099	fontawesome	pager	icons/fontawesome/solid/pager.svg	Pager	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2100	fontawesome	paint-brush	icons/fontawesome/solid/paint-brush.svg	Paint Brush	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2101	fontawesome	paint-roller	icons/fontawesome/solid/paint-roller.svg	Paint Roller	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2102	fontawesome	paintbrush	icons/fontawesome/solid/paintbrush.svg	Paintbrush	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2103	fontawesome	palette	icons/fontawesome/solid/palette.svg	Palette	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2104	fontawesome	pallet	icons/fontawesome/solid/pallet.svg	Pallet	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2105	fontawesome	panorama	icons/fontawesome/solid/panorama.svg	Panorama	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2107	fontawesome	paperclip	icons/fontawesome/solid/paperclip.svg	Paperclip	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2108	fontawesome	parachute-box	icons/fontawesome/solid/parachute-box.svg	Parachute Box	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2110	fontawesome	parking	icons/fontawesome/solid/parking.svg	Parking	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2111	fontawesome	passport	icons/fontawesome/solid/passport.svg	Passport	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2112	fontawesome	pastafarianism	icons/fontawesome/solid/pastafarianism.svg	Pastafarianism	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2113	fontawesome	paste	icons/fontawesome/solid/paste.svg	Paste	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2114	fontawesome	pause-circle	icons/fontawesome/solid/pause-circle.svg	Pause Circle	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2115	fontawesome	pause	icons/fontawesome/solid/pause.svg	Pause	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2116	fontawesome	paw	icons/fontawesome/solid/paw.svg	Paw	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2118	fontawesome	pen-alt	icons/fontawesome/solid/pen-alt.svg	Pen Alt	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2119	fontawesome	pen-clip	icons/fontawesome/solid/pen-clip.svg	Pen Clip	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2120	fontawesome	pen-fancy	icons/fontawesome/solid/pen-fancy.svg	Pen Fancy	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2121	fontawesome	pen-nib	icons/fontawesome/solid/pen-nib.svg	Pen Nib	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2122	fontawesome	pen-ruler	icons/fontawesome/solid/pen-ruler.svg	Pen Ruler	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2123	fontawesome	pen-square	icons/fontawesome/solid/pen-square.svg	Pen Square	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2124	fontawesome	pen-to-square	icons/fontawesome/solid/pen-to-square.svg	Pen To Square	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2125	fontawesome	pen	icons/fontawesome/solid/pen.svg	Pen	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:35	public
2126	fontawesome	pencil-alt	icons/fontawesome/solid/pencil-alt.svg	Pencil Alt	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:35	public
2128	fontawesome	pencil-square	icons/fontawesome/solid/pencil-square.svg	Pencil Square	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2129	fontawesome	pencil	icons/fontawesome/solid/pencil.svg	Pencil	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2130	fontawesome	pentagon	icons/fontawesome/solid/pentagon.svg	Pentagon	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2131	fontawesome	people-arrows-left-right	icons/fontawesome/solid/people-arrows-left-right.svg	People Arrows Left Right	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2132	fontawesome	people-arrows	icons/fontawesome/solid/people-arrows.svg	People Arrows	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2133	fontawesome	people-carry-box	icons/fontawesome/solid/people-carry-box.svg	People Carry Box	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2134	fontawesome	people-carry	icons/fontawesome/solid/people-carry.svg	People Carry	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2135	fontawesome	people-group	icons/fontawesome/solid/people-group.svg	People Group	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2136	fontawesome	people-line	icons/fontawesome/solid/people-line.svg	People Line	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2138	fontawesome	people-robbery	icons/fontawesome/solid/people-robbery.svg	People Robbery	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2139	fontawesome	people-roof	icons/fontawesome/solid/people-roof.svg	People Roof	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2140	fontawesome	pepper-hot	icons/fontawesome/solid/pepper-hot.svg	Pepper Hot	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2141	fontawesome	percent	icons/fontawesome/solid/percent.svg	Percent	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:36	public
2142	fontawesome	percentage	icons/fontawesome/solid/percentage.svg	Percentage	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:36	public
2143	fontawesome	person-arrow-down-to-line	icons/fontawesome/solid/person-arrow-down-to-line.svg	Person Arrow Down To Line	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2145	fontawesome	person-biking	icons/fontawesome/solid/person-biking.svg	Person Biking	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2146	fontawesome	person-booth	icons/fontawesome/solid/person-booth.svg	Person Booth	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2147	fontawesome	person-breastfeeding	icons/fontawesome/solid/person-breastfeeding.svg	Person Breastfeeding	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2148	fontawesome	person-burst	icons/fontawesome/solid/person-burst.svg	Person Burst	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2149	fontawesome	person-cane	icons/fontawesome/solid/person-cane.svg	Person Cane	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2150	fontawesome	person-chalkboard	icons/fontawesome/solid/person-chalkboard.svg	Person Chalkboard	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2151	fontawesome	person-circle-check	icons/fontawesome/solid/person-circle-check.svg	Person Circle Check	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2152	fontawesome	person-circle-exclamation	icons/fontawesome/solid/person-circle-exclamation.svg	Person Circle Exclamation	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2153	fontawesome	person-circle-minus	icons/fontawesome/solid/person-circle-minus.svg	Person Circle Minus	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2155	fontawesome	person-circle-question	icons/fontawesome/solid/person-circle-question.svg	Person Circle Question	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2156	fontawesome	person-circle-xmark	icons/fontawesome/solid/person-circle-xmark.svg	Person Circle Xmark	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2157	fontawesome	person-digging	icons/fontawesome/solid/person-digging.svg	Person Digging	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:37	public
2158	fontawesome	person-dots-from-line	icons/fontawesome/solid/person-dots-from-line.svg	Person Dots From Line	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:37	public
2159	fontawesome	person-dress-burst	icons/fontawesome/solid/person-dress-burst.svg	Person Dress Burst	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:37	public
2160	fontawesome	person-dress	icons/fontawesome/solid/person-dress.svg	Person Dress	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2161	fontawesome	person-drowning	icons/fontawesome/solid/person-drowning.svg	Person Drowning	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2163	fontawesome	person-falling	icons/fontawesome/solid/person-falling.svg	Person Falling	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2165	fontawesome	person-harassing	icons/fontawesome/solid/person-harassing.svg	Person Harassing	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2166	fontawesome	person-hiking	icons/fontawesome/solid/person-hiking.svg	Person Hiking	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2168	fontawesome	person-military-rifle	icons/fontawesome/solid/person-military-rifle.svg	Person Military Rifle	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2169	fontawesome	person-military-to-person	icons/fontawesome/solid/person-military-to-person.svg	Person Military To Person	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2170	fontawesome	person-praying	icons/fontawesome/solid/person-praying.svg	Person Praying	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2171	fontawesome	person-pregnant	icons/fontawesome/solid/person-pregnant.svg	Person Pregnant	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2172	fontawesome	person-rays	icons/fontawesome/solid/person-rays.svg	Person Rays	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:38	public
2173	fontawesome	person-rifle	icons/fontawesome/solid/person-rifle.svg	Person Rifle	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:38	public
2174	fontawesome	person-running	icons/fontawesome/solid/person-running.svg	Person Running	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:38	public
2175	fontawesome	person-shelter	icons/fontawesome/solid/person-shelter.svg	Person Shelter	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:38	public
2177	fontawesome	person-skiing-nordic	icons/fontawesome/solid/person-skiing-nordic.svg	Person Skiing Nordic	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2178	fontawesome	person-skiing	icons/fontawesome/solid/person-skiing.svg	Person Skiing	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2179	fontawesome	person-snowboarding	icons/fontawesome/solid/person-snowboarding.svg	Person Snowboarding	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2180	fontawesome	person-swimming	icons/fontawesome/solid/person-swimming.svg	Person Swimming	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2181	fontawesome	person-through-window	icons/fontawesome/solid/person-through-window.svg	Person Through Window	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2183	fontawesome	person-walking-arrow-right	icons/fontawesome/solid/person-walking-arrow-right.svg	Person Walking Arrow Right	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2184	fontawesome	person-walking-dashed-line-arrow-right	icons/fontawesome/solid/person-walking-dashed-line-arrow-right.svg	Person Walking Dashed Line Arrow Right	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2185	fontawesome	person-walking-luggage	icons/fontawesome/solid/person-walking-luggage.svg	Person Walking Luggage	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2186	fontawesome	person-walking-with-cane	icons/fontawesome/solid/person-walking-with-cane.svg	Person Walking With Cane	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2187	fontawesome	person-walking	icons/fontawesome/solid/person-walking.svg	Person Walking	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2188	fontawesome	person	icons/fontawesome/solid/person.svg	Person	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:39	public
2189	fontawesome	peseta-sign	icons/fontawesome/solid/peseta-sign.svg	Peseta Sign	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:39	public
2190	fontawesome	peso-sign	icons/fontawesome/solid/peso-sign.svg	Peso Sign	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:39	public
2191	fontawesome	phone-alt	icons/fontawesome/solid/phone-alt.svg	Phone Alt	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:39	public
2192	fontawesome	phone-flip	icons/fontawesome/solid/phone-flip.svg	Phone Flip	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:39	public
2194	fontawesome	phone-square-alt	icons/fontawesome/solid/phone-square-alt.svg	Phone Square Alt	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2195	fontawesome	phone-square	icons/fontawesome/solid/phone-square.svg	Phone Square	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2196	fontawesome	phone-volume	icons/fontawesome/solid/phone-volume.svg	Phone Volume	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2197	fontawesome	phone	icons/fontawesome/solid/phone.svg	Phone	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2198	fontawesome	photo-film	icons/fontawesome/solid/photo-film.svg	Photo Film	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2199	fontawesome	photo-video	icons/fontawesome/solid/photo-video.svg	Photo Video	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2200	fontawesome	pie-chart	icons/fontawesome/solid/pie-chart.svg	Pie Chart	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2201	fontawesome	piggy-bank	icons/fontawesome/solid/piggy-bank.svg	Piggy Bank	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2202	fontawesome	pills	icons/fontawesome/solid/pills.svg	Pills	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2204	fontawesome	pizza-slice	icons/fontawesome/solid/pizza-slice.svg	Pizza Slice	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2205	fontawesome	place-of-worship	icons/fontawesome/solid/place-of-worship.svg	Place Of Worship	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:40	public
2206	fontawesome	plane-arrival	icons/fontawesome/solid/plane-arrival.svg	Plane Arrival	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:40	public
2207	fontawesome	plane-circle-check	icons/fontawesome/solid/plane-circle-check.svg	Plane Circle Check	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:40	public
2208	fontawesome	plane-circle-exclamation	icons/fontawesome/solid/plane-circle-exclamation.svg	Plane Circle Exclamation	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:40	public
2209	fontawesome	plane-circle-xmark	icons/fontawesome/solid/plane-circle-xmark.svg	Plane Circle Xmark	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:40	public
2210	fontawesome	plane-departure	icons/fontawesome/solid/plane-departure.svg	Plane Departure	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:40	public
2211	fontawesome	plane-lock	icons/fontawesome/solid/plane-lock.svg	Plane Lock	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2213	fontawesome	plane-up	icons/fontawesome/solid/plane-up.svg	Plane Up	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2214	fontawesome	plane	icons/fontawesome/solid/plane.svg	Plane	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2215	fontawesome	plant-wilt	icons/fontawesome/solid/plant-wilt.svg	Plant Wilt	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2216	fontawesome	plate-wheat	icons/fontawesome/solid/plate-wheat.svg	Plate Wheat	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2217	fontawesome	play-circle	icons/fontawesome/solid/play-circle.svg	Play Circle	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2219	fontawesome	plug-circle-bolt	icons/fontawesome/solid/plug-circle-bolt.svg	Plug Circle Bolt	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2221	fontawesome	plug-circle-exclamation	icons/fontawesome/solid/plug-circle-exclamation.svg	Plug Circle Exclamation	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:41	public
2222	fontawesome	plug-circle-minus	icons/fontawesome/solid/plug-circle-minus.svg	Plug Circle Minus	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:41	public
2223	fontawesome	plug-circle-plus	icons/fontawesome/solid/plug-circle-plus.svg	Plug Circle Plus	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:41	public
2224	fontawesome	plug-circle-xmark	icons/fontawesome/solid/plug-circle-xmark.svg	Plug Circle Xmark	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:41	public
2225	fontawesome	plug	icons/fontawesome/solid/plug.svg	Plug	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:41	public
2226	fontawesome	plus-circle	icons/fontawesome/solid/plus-circle.svg	Plus Circle	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:41	public
2227	fontawesome	plus-minus	icons/fontawesome/solid/plus-minus.svg	Plus Minus	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2228	fontawesome	plus-square	icons/fontawesome/solid/plus-square.svg	Plus Square	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2229	fontawesome	plus	icons/fontawesome/solid/plus.svg	Plus	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2230	fontawesome	podcast	icons/fontawesome/solid/podcast.svg	Podcast	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2231	fontawesome	poll-h	icons/fontawesome/solid/poll-h.svg	Poll H	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2232	fontawesome	poll	icons/fontawesome/solid/poll.svg	Poll	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2234	fontawesome	poo-storm	icons/fontawesome/solid/poo-storm.svg	Poo Storm	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2235	fontawesome	poo	icons/fontawesome/solid/poo.svg	Poo	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2236	fontawesome	poop	icons/fontawesome/solid/poop.svg	Poop	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2237	fontawesome	portrait	icons/fontawesome/solid/portrait.svg	Portrait	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:42	public
2238	fontawesome	pound-sign	icons/fontawesome/solid/pound-sign.svg	Pound Sign	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:42	public
2239	fontawesome	power-off	icons/fontawesome/solid/power-off.svg	Power Off	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:42	public
2240	fontawesome	pray	icons/fontawesome/solid/pray.svg	Pray	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:42	public
2241	fontawesome	praying-hands	icons/fontawesome/solid/praying-hands.svg	Praying Hands	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:42	public
2243	fontawesome	prescription-bottle-medical	icons/fontawesome/solid/prescription-bottle-medical.svg	Prescription Bottle Medical	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:42	public
2244	fontawesome	prescription-bottle	icons/fontawesome/solid/prescription-bottle.svg	Prescription Bottle	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2245	fontawesome	prescription	icons/fontawesome/solid/prescription.svg	Prescription	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2246	fontawesome	print	icons/fontawesome/solid/print.svg	Print	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2247	fontawesome	procedures	icons/fontawesome/solid/procedures.svg	Procedures	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2248	fontawesome	project-diagram	icons/fontawesome/solid/project-diagram.svg	Project Diagram	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2249	fontawesome	pump-medical	icons/fontawesome/solid/pump-medical.svg	Pump Medical	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2250	fontawesome	pump-soap	icons/fontawesome/solid/pump-soap.svg	Pump Soap	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2251	fontawesome	puzzle-piece	icons/fontawesome/solid/puzzle-piece.svg	Puzzle Piece	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2252	fontawesome	q	icons/fontawesome/solid/q.svg	Q	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:43	public
2253	fontawesome	qrcode	icons/fontawesome/solid/qrcode.svg	Qrcode	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:43	public
2254	fontawesome	question-circle	icons/fontawesome/solid/question-circle.svg	Question Circle	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:43	public
2256	fontawesome	quidditch-broom-ball	icons/fontawesome/solid/quidditch-broom-ball.svg	Quidditch Broom Ball	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:43	public
2257	fontawesome	quidditch	icons/fontawesome/solid/quidditch.svg	Quidditch	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:43	public
2258	fontawesome	quote-left-alt	icons/fontawesome/solid/quote-left-alt.svg	Quote Left Alt	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:43	public
2259	fontawesome	quote-left	icons/fontawesome/solid/quote-left.svg	Quote Left	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:43	public
2260	fontawesome	quote-right-alt	icons/fontawesome/solid/quote-right-alt.svg	Quote Right Alt	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:43	public
2261	fontawesome	quote-right	icons/fontawesome/solid/quote-right.svg	Quote Right	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:44	public
2262	fontawesome	quran	icons/fontawesome/solid/quran.svg	Quran	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:44	public
2263	fontawesome	r	icons/fontawesome/solid/r.svg	R	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:44	public
2265	fontawesome	radiation	icons/fontawesome/solid/radiation.svg	Radiation	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:44	public
2266	fontawesome	radio	icons/fontawesome/solid/radio.svg	Radio	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:44	public
2267	fontawesome	rainbow	icons/fontawesome/solid/rainbow.svg	Rainbow	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:44	public
2268	fontawesome	random	icons/fontawesome/solid/random.svg	Random	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:44	public
2269	fontawesome	ranking-star	icons/fontawesome/solid/ranking-star.svg	Ranking Star	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2270	fontawesome	receipt	icons/fontawesome/solid/receipt.svg	Receipt	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2271	fontawesome	record-vinyl	icons/fontawesome/solid/record-vinyl.svg	Record Vinyl	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2272	fontawesome	rectangle-ad	icons/fontawesome/solid/rectangle-ad.svg	Rectangle Ad	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2273	fontawesome	rectangle-list	icons/fontawesome/solid/rectangle-list.svg	Rectangle List	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2274	fontawesome	rectangle-times	icons/fontawesome/solid/rectangle-times.svg	Rectangle Times	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2276	fontawesome	recycle	icons/fontawesome/solid/recycle.svg	Recycle	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2277	fontawesome	redo-alt	icons/fontawesome/solid/redo-alt.svg	Redo Alt	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2278	fontawesome	redo	icons/fontawesome/solid/redo.svg	Redo	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:45	public
2279	fontawesome	refresh	icons/fontawesome/solid/refresh.svg	Refresh	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:45	public
2280	fontawesome	registered	icons/fontawesome/solid/registered.svg	Registered	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:45	public
2281	fontawesome	remove-format	icons/fontawesome/solid/remove-format.svg	Remove Format	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:45	public
2282	fontawesome	remove	icons/fontawesome/solid/remove.svg	Remove	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:45	public
2283	fontawesome	reorder	icons/fontawesome/solid/reorder.svg	Reorder	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:45	public
2284	fontawesome	repeat	icons/fontawesome/solid/repeat.svg	Repeat	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:45	public
2285	fontawesome	reply-all	icons/fontawesome/solid/reply-all.svg	Reply All	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2287	fontawesome	republican	icons/fontawesome/solid/republican.svg	Republican	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2288	fontawesome	restroom	icons/fontawesome/solid/restroom.svg	Restroom	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2289	fontawesome	retweet	icons/fontawesome/solid/retweet.svg	Retweet	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2290	fontawesome	ribbon	icons/fontawesome/solid/ribbon.svg	Ribbon	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2291	fontawesome	right-from-bracket	icons/fontawesome/solid/right-from-bracket.svg	Right From Bracket	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2292	fontawesome	right-left	icons/fontawesome/solid/right-left.svg	Right Left	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2293	fontawesome	right-long	icons/fontawesome/solid/right-long.svg	Right Long	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2294	fontawesome	right-to-bracket	icons/fontawesome/solid/right-to-bracket.svg	Right To Bracket	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:46	public
2295	fontawesome	ring	icons/fontawesome/solid/ring.svg	Ring	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:46	public
2296	fontawesome	rmb	icons/fontawesome/solid/rmb.svg	Rmb	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:46	public
2298	fontawesome	road-bridge	icons/fontawesome/solid/road-bridge.svg	Road Bridge	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:46	public
2299	fontawesome	road-circle-check	icons/fontawesome/solid/road-circle-check.svg	Road Circle Check	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:46	public
2300	fontawesome	road-circle-exclamation	icons/fontawesome/solid/road-circle-exclamation.svg	Road Circle Exclamation	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:46	public
2301	fontawesome	road-circle-xmark	icons/fontawesome/solid/road-circle-xmark.svg	Road Circle Xmark	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2302	fontawesome	road-lock	icons/fontawesome/solid/road-lock.svg	Road Lock	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2303	fontawesome	road-spikes	icons/fontawesome/solid/road-spikes.svg	Road Spikes	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2304	fontawesome	road	icons/fontawesome/solid/road.svg	Road	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2305	fontawesome	robot	icons/fontawesome/solid/robot.svg	Robot	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2306	fontawesome	rocket	icons/fontawesome/solid/rocket.svg	Rocket	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2308	fontawesome	rod-snake	icons/fontawesome/solid/rod-snake.svg	Rod Snake	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2309	fontawesome	rotate-back	icons/fontawesome/solid/rotate-back.svg	Rotate Back	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2310	fontawesome	rotate-backward	icons/fontawesome/solid/rotate-backward.svg	Rotate Backward	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2311	fontawesome	rotate-forward	icons/fontawesome/solid/rotate-forward.svg	Rotate Forward	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:47	public
2312	fontawesome	rotate-left	icons/fontawesome/solid/rotate-left.svg	Rotate Left	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:47	public
2313	fontawesome	rotate-right	icons/fontawesome/solid/rotate-right.svg	Rotate Right	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:47	public
2314	fontawesome	rotate	icons/fontawesome/solid/rotate.svg	Rotate	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:47	public
2315	fontawesome	rouble	icons/fontawesome/solid/rouble.svg	Rouble	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:47	public
2316	fontawesome	route	icons/fontawesome/solid/route.svg	Route	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:47	public
2318	fontawesome	rss	icons/fontawesome/solid/rss.svg	Rss	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2319	fontawesome	rub	icons/fontawesome/solid/rub.svg	Rub	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2320	fontawesome	ruble-sign	icons/fontawesome/solid/ruble-sign.svg	Ruble Sign	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2321	fontawesome	ruble	icons/fontawesome/solid/ruble.svg	Ruble	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2322	fontawesome	rug	icons/fontawesome/solid/rug.svg	Rug	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2323	fontawesome	ruler-combined	icons/fontawesome/solid/ruler-combined.svg	Ruler Combined	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2324	fontawesome	ruler-horizontal	icons/fontawesome/solid/ruler-horizontal.svg	Ruler Horizontal	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2325	fontawesome	ruler-vertical	icons/fontawesome/solid/ruler-vertical.svg	Ruler Vertical	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2326	fontawesome	ruler	icons/fontawesome/solid/ruler.svg	Ruler	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2327	fontawesome	running	icons/fontawesome/solid/running.svg	Running	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2329	fontawesome	rupee	icons/fontawesome/solid/rupee.svg	Rupee	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:48	public
2330	fontawesome	rupiah-sign	icons/fontawesome/solid/rupiah-sign.svg	Rupiah Sign	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:48	public
2331	fontawesome	s	icons/fontawesome/solid/s.svg	S	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:48	public
2332	fontawesome	sack-dollar	icons/fontawesome/solid/sack-dollar.svg	Sack Dollar	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:48	public
2334	fontawesome	sad-cry	icons/fontawesome/solid/sad-cry.svg	Sad Cry	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2335	fontawesome	sad-tear	icons/fontawesome/solid/sad-tear.svg	Sad Tear	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2336	fontawesome	sailboat	icons/fontawesome/solid/sailboat.svg	Sailboat	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2338	fontawesome	satellite	icons/fontawesome/solid/satellite.svg	Satellite	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2339	fontawesome	save	icons/fontawesome/solid/save.svg	Save	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2340	fontawesome	scale-balanced	icons/fontawesome/solid/scale-balanced.svg	Scale Balanced	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2341	fontawesome	scale-unbalanced-flip	icons/fontawesome/solid/scale-unbalanced-flip.svg	Scale Unbalanced Flip	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2342	fontawesome	scale-unbalanced	icons/fontawesome/solid/scale-unbalanced.svg	Scale Unbalanced	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2343	fontawesome	school-circle-check	icons/fontawesome/solid/school-circle-check.svg	School Circle Check	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2345	fontawesome	school-circle-xmark	icons/fontawesome/solid/school-circle-xmark.svg	School Circle Xmark	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:49	public
2346	fontawesome	school-flag	icons/fontawesome/solid/school-flag.svg	School Flag	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:49	public
2347	fontawesome	school-lock	icons/fontawesome/solid/school-lock.svg	School Lock	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:49	public
2348	fontawesome	school	icons/fontawesome/solid/school.svg	School	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:49	public
2349	fontawesome	scissors	icons/fontawesome/solid/scissors.svg	Scissors	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2350	fontawesome	screwdriver-wrench	icons/fontawesome/solid/screwdriver-wrench.svg	Screwdriver Wrench	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2351	fontawesome	screwdriver	icons/fontawesome/solid/screwdriver.svg	Screwdriver	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2352	fontawesome	scroll-torah	icons/fontawesome/solid/scroll-torah.svg	Scroll Torah	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2353	fontawesome	scroll	icons/fontawesome/solid/scroll.svg	Scroll	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2354	fontawesome	sd-card	icons/fontawesome/solid/sd-card.svg	Sd Card	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2355	fontawesome	search-dollar	icons/fontawesome/solid/search-dollar.svg	Search Dollar	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2356	fontawesome	search-location	icons/fontawesome/solid/search-location.svg	Search Location	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2358	fontawesome	search-plus	icons/fontawesome/solid/search-plus.svg	Search Plus	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2359	fontawesome	search	icons/fontawesome/solid/search.svg	Search	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2360	fontawesome	section	icons/fontawesome/solid/section.svg	Section	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2361	fontawesome	seedling	icons/fontawesome/solid/seedling.svg	Seedling	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:50	public
2362	fontawesome	septagon	icons/fontawesome/solid/septagon.svg	Septagon	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:50	public
2363	fontawesome	server	icons/fontawesome/solid/server.svg	Server	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:50	public
2364	fontawesome	shapes	icons/fontawesome/solid/shapes.svg	Shapes	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2365	fontawesome	share-alt-square	icons/fontawesome/solid/share-alt-square.svg	Share Alt Square	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2366	fontawesome	share-alt	icons/fontawesome/solid/share-alt.svg	Share Alt	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2368	fontawesome	share-nodes	icons/fontawesome/solid/share-nodes.svg	Share Nodes	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2369	fontawesome	share-square	icons/fontawesome/solid/share-square.svg	Share Square	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2370	fontawesome	share	icons/fontawesome/solid/share.svg	Share	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2371	fontawesome	sheet-plastic	icons/fontawesome/solid/sheet-plastic.svg	Sheet Plastic	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2372	fontawesome	shekel-sign	icons/fontawesome/solid/shekel-sign.svg	Shekel Sign	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2373	fontawesome	shekel	icons/fontawesome/solid/shekel.svg	Shekel	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2374	fontawesome	sheqel-sign	icons/fontawesome/solid/sheqel-sign.svg	Sheqel Sign	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2375	fontawesome	sheqel	icons/fontawesome/solid/sheqel.svg	Sheqel	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2376	fontawesome	shield-alt	icons/fontawesome/solid/shield-alt.svg	Shield Alt	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2377	fontawesome	shield-blank	icons/fontawesome/solid/shield-blank.svg	Shield Blank	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2378	fontawesome	shield-cat	icons/fontawesome/solid/shield-cat.svg	Shield Cat	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:51	public
2379	fontawesome	shield-dog	icons/fontawesome/solid/shield-dog.svg	Shield Dog	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:51	public
2381	fontawesome	shield-heart	icons/fontawesome/solid/shield-heart.svg	Shield Heart	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2382	fontawesome	shield-virus	icons/fontawesome/solid/shield-virus.svg	Shield Virus	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2383	fontawesome	shield	icons/fontawesome/solid/shield.svg	Shield	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2384	fontawesome	ship	icons/fontawesome/solid/ship.svg	Ship	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2385	fontawesome	shipping-fast	icons/fontawesome/solid/shipping-fast.svg	Shipping Fast	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2386	fontawesome	shirt	icons/fontawesome/solid/shirt.svg	Shirt	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2387	fontawesome	shoe-prints	icons/fontawesome/solid/shoe-prints.svg	Shoe Prints	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2388	fontawesome	shop-lock	icons/fontawesome/solid/shop-lock.svg	Shop Lock	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2389	fontawesome	shop-slash	icons/fontawesome/solid/shop-slash.svg	Shop Slash	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2391	fontawesome	shopping-bag	icons/fontawesome/solid/shopping-bag.svg	Shopping Bag	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2393	fontawesome	shopping-cart	icons/fontawesome/solid/shopping-cart.svg	Shopping Cart	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2394	fontawesome	shower	icons/fontawesome/solid/shower.svg	Shower	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2395	fontawesome	shrimp	icons/fontawesome/solid/shrimp.svg	Shrimp	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:52	public
2396	fontawesome	shuffle	icons/fontawesome/solid/shuffle.svg	Shuffle	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:52	public
2397	fontawesome	shuttle-space	icons/fontawesome/solid/shuttle-space.svg	Shuttle Space	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2398	fontawesome	shuttle-van	icons/fontawesome/solid/shuttle-van.svg	Shuttle Van	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2399	fontawesome	sign-hanging	icons/fontawesome/solid/sign-hanging.svg	Sign Hanging	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2400	fontawesome	sign-in-alt	icons/fontawesome/solid/sign-in-alt.svg	Sign In Alt	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2401	fontawesome	sign-in	icons/fontawesome/solid/sign-in.svg	Sign In	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2403	fontawesome	sign-out-alt	icons/fontawesome/solid/sign-out-alt.svg	Sign Out Alt	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2404	fontawesome	sign-out	icons/fontawesome/solid/sign-out.svg	Sign Out	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2405	fontawesome	sign	icons/fontawesome/solid/sign.svg	Sign	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2406	fontawesome	signal-5	icons/fontawesome/solid/signal-5.svg	Signal 5	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2407	fontawesome	signal-perfect	icons/fontawesome/solid/signal-perfect.svg	Signal Perfect	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2408	fontawesome	signal	icons/fontawesome/solid/signal.svg	Signal	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2409	fontawesome	signature	icons/fontawesome/solid/signature.svg	Signature	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2410	fontawesome	signing	icons/fontawesome/solid/signing.svg	Signing	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2411	fontawesome	signs-post	icons/fontawesome/solid/signs-post.svg	Signs Post	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2412	fontawesome	sim-card	icons/fontawesome/solid/sim-card.svg	Sim Card	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:53	public
2413	fontawesome	single-quote-left	icons/fontawesome/solid/single-quote-left.svg	Single Quote Left	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2415	fontawesome	sink	icons/fontawesome/solid/sink.svg	Sink	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2416	fontawesome	sitemap	icons/fontawesome/solid/sitemap.svg	Sitemap	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2417	fontawesome	skating	icons/fontawesome/solid/skating.svg	Skating	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2418	fontawesome	skiing-nordic	icons/fontawesome/solid/skiing-nordic.svg	Skiing Nordic	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2419	fontawesome	skiing	icons/fontawesome/solid/skiing.svg	Skiing	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2420	fontawesome	skull-crossbones	icons/fontawesome/solid/skull-crossbones.svg	Skull Crossbones	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2421	fontawesome	skull	icons/fontawesome/solid/skull.svg	Skull	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2422	fontawesome	slash	icons/fontawesome/solid/slash.svg	Slash	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2423	fontawesome	sleigh	icons/fontawesome/solid/sleigh.svg	Sleigh	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2424	fontawesome	sliders-h	icons/fontawesome/solid/sliders-h.svg	Sliders H	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2425	fontawesome	sliders	icons/fontawesome/solid/sliders.svg	Sliders	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2426	fontawesome	smile-beam	icons/fontawesome/solid/smile-beam.svg	Smile Beam	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2427	fontawesome	smile-wink	icons/fontawesome/solid/smile-wink.svg	Smile Wink	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2428	fontawesome	smile	icons/fontawesome/solid/smile.svg	Smile	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:54	public
2429	fontawesome	smog	icons/fontawesome/solid/smog.svg	Smog	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:54	public
2431	fontawesome	smoking	icons/fontawesome/solid/smoking.svg	Smoking	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2432	fontawesome	sms	icons/fontawesome/solid/sms.svg	Sms	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2433	fontawesome	snowboarding	icons/fontawesome/solid/snowboarding.svg	Snowboarding	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2434	fontawesome	snowflake	icons/fontawesome/solid/snowflake.svg	Snowflake	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2435	fontawesome	snowman	icons/fontawesome/solid/snowman.svg	Snowman	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2436	fontawesome	snowplow	icons/fontawesome/solid/snowplow.svg	Snowplow	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2437	fontawesome	soap	icons/fontawesome/solid/soap.svg	Soap	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2438	fontawesome	soccer-ball	icons/fontawesome/solid/soccer-ball.svg	Soccer Ball	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2439	fontawesome	socks	icons/fontawesome/solid/socks.svg	Socks	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2440	fontawesome	solar-panel	icons/fontawesome/solid/solar-panel.svg	Solar Panel	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2442	fontawesome	sort-alpha-desc	icons/fontawesome/solid/sort-alpha-desc.svg	Sort Alpha Desc	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2443	fontawesome	sort-alpha-down-alt	icons/fontawesome/solid/sort-alpha-down-alt.svg	Sort Alpha Down Alt	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2444	fontawesome	sort-alpha-down	icons/fontawesome/solid/sort-alpha-down.svg	Sort Alpha Down	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2445	fontawesome	sort-alpha-up-alt	icons/fontawesome/solid/sort-alpha-up-alt.svg	Sort Alpha Up Alt	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:55	public
2446	fontawesome	sort-alpha-up	icons/fontawesome/solid/sort-alpha-up.svg	Sort Alpha Up	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2447	fontawesome	sort-amount-asc	icons/fontawesome/solid/sort-amount-asc.svg	Sort Amount Asc	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2449	fontawesome	sort-amount-down-alt	icons/fontawesome/solid/sort-amount-down-alt.svg	Sort Amount Down Alt	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2451	fontawesome	sort-amount-up-alt	icons/fontawesome/solid/sort-amount-up-alt.svg	Sort Amount Up Alt	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2452	fontawesome	sort-amount-up	icons/fontawesome/solid/sort-amount-up.svg	Sort Amount Up	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2453	fontawesome	sort-asc	icons/fontawesome/solid/sort-asc.svg	Sort Asc	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2454	fontawesome	sort-desc	icons/fontawesome/solid/sort-desc.svg	Sort Desc	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2455	fontawesome	sort-down	icons/fontawesome/solid/sort-down.svg	Sort Down	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2456	fontawesome	sort-numeric-asc	icons/fontawesome/solid/sort-numeric-asc.svg	Sort Numeric Asc	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2457	fontawesome	sort-numeric-desc	icons/fontawesome/solid/sort-numeric-desc.svg	Sort Numeric Desc	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2458	fontawesome	sort-numeric-down-alt	icons/fontawesome/solid/sort-numeric-down-alt.svg	Sort Numeric Down Alt	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2460	fontawesome	sort-numeric-up-alt	icons/fontawesome/solid/sort-numeric-up-alt.svg	Sort Numeric Up Alt	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2461	fontawesome	sort-numeric-up	icons/fontawesome/solid/sort-numeric-up.svg	Sort Numeric Up	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:55	public
2462	fontawesome	sort-up	icons/fontawesome/solid/sort-up.svg	Sort Up	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2463	fontawesome	sort	icons/fontawesome/solid/sort.svg	Sort	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2464	fontawesome	spa	icons/fontawesome/solid/spa.svg	Spa	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2465	fontawesome	space-shuttle	icons/fontawesome/solid/space-shuttle.svg	Space Shuttle	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2466	fontawesome	spaghetti-monster-flying	icons/fontawesome/solid/spaghetti-monster-flying.svg	Spaghetti Monster Flying	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2467	fontawesome	spell-check	icons/fontawesome/solid/spell-check.svg	Spell Check	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2468	fontawesome	spider	icons/fontawesome/solid/spider.svg	Spider	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2469	fontawesome	spinner	icons/fontawesome/solid/spinner.svg	Spinner	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2470	fontawesome	spiral	icons/fontawesome/solid/spiral.svg	Spiral	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2471	fontawesome	splotch	icons/fontawesome/solid/splotch.svg	Splotch	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2473	fontawesome	spray-can-sparkles	icons/fontawesome/solid/spray-can-sparkles.svg	Spray Can Sparkles	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2474	fontawesome	spray-can	icons/fontawesome/solid/spray-can.svg	Spray Can	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2475	fontawesome	sprout	icons/fontawesome/solid/sprout.svg	Sprout	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2476	fontawesome	square-arrow-up-right	icons/fontawesome/solid/square-arrow-up-right.svg	Square Arrow Up Right	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2477	fontawesome	square-binary	icons/fontawesome/solid/square-binary.svg	Square Binary	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:56	public
2479	fontawesome	square-caret-left	icons/fontawesome/solid/square-caret-left.svg	Square Caret Left	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2480	fontawesome	square-caret-right	icons/fontawesome/solid/square-caret-right.svg	Square Caret Right	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2481	fontawesome	square-caret-up	icons/fontawesome/solid/square-caret-up.svg	Square Caret Up	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2482	fontawesome	square-check	icons/fontawesome/solid/square-check.svg	Square Check	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2483	fontawesome	square-envelope	icons/fontawesome/solid/square-envelope.svg	Square Envelope	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2484	fontawesome	square-full	icons/fontawesome/solid/square-full.svg	Square Full	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2485	fontawesome	square-h	icons/fontawesome/solid/square-h.svg	Square H	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2486	fontawesome	square-minus	icons/fontawesome/solid/square-minus.svg	Square Minus	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2487	fontawesome	square-nfi	icons/fontawesome/solid/square-nfi.svg	Square Nfi	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2488	fontawesome	square-parking	icons/fontawesome/solid/square-parking.svg	Square Parking	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2489	fontawesome	square-pen	icons/fontawesome/solid/square-pen.svg	Square Pen	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2491	fontawesome	square-phone-flip	icons/fontawesome/solid/square-phone-flip.svg	Square Phone Flip	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2492	fontawesome	square-phone	icons/fontawesome/solid/square-phone.svg	Square Phone	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2493	fontawesome	square-plus	icons/fontawesome/solid/square-plus.svg	Square Plus	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:57	public
2494	fontawesome	square-poll-horizontal	icons/fontawesome/solid/square-poll-horizontal.svg	Square Poll Horizontal	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:57	public
2495	fontawesome	square-poll-vertical	icons/fontawesome/solid/square-poll-vertical.svg	Square Poll Vertical	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2496	fontawesome	square-root-alt	icons/fontawesome/solid/square-root-alt.svg	Square Root Alt	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2498	fontawesome	square-rss	icons/fontawesome/solid/square-rss.svg	Square Rss	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2499	fontawesome	square-share-nodes	icons/fontawesome/solid/square-share-nodes.svg	Square Share Nodes	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2500	fontawesome	square-up-right	icons/fontawesome/solid/square-up-right.svg	Square Up Right	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2501	fontawesome	square-virus	icons/fontawesome/solid/square-virus.svg	Square Virus	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2502	fontawesome	square-xmark	icons/fontawesome/solid/square-xmark.svg	Square Xmark	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2505	fontawesome	staff-snake	icons/fontawesome/solid/staff-snake.svg	Staff Snake	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2506	fontawesome	stairs	icons/fontawesome/solid/stairs.svg	Stairs	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2507	fontawesome	stamp	icons/fontawesome/solid/stamp.svg	Stamp	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2508	fontawesome	stapler	icons/fontawesome/solid/stapler.svg	Stapler	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2509	fontawesome	star-and-crescent	icons/fontawesome/solid/star-and-crescent.svg	Star And Crescent	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:58	public
2510	fontawesome	star-half-alt	icons/fontawesome/solid/star-half-alt.svg	Star Half Alt	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:58	public
2511	fontawesome	star-half-stroke	icons/fontawesome/solid/star-half-stroke.svg	Star Half Stroke	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:58	public
2512	fontawesome	star-half	icons/fontawesome/solid/star-half.svg	Star Half	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2513	fontawesome	star-of-david	icons/fontawesome/solid/star-of-david.svg	Star Of David	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2514	fontawesome	star-of-life	icons/fontawesome/solid/star-of-life.svg	Star Of Life	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2515	fontawesome	star	icons/fontawesome/solid/star.svg	Star	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2517	fontawesome	step-forward	icons/fontawesome/solid/step-forward.svg	Step Forward	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2518	fontawesome	sterling-sign	icons/fontawesome/solid/sterling-sign.svg	Sterling Sign	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2519	fontawesome	stethoscope	icons/fontawesome/solid/stethoscope.svg	Stethoscope	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2520	fontawesome	sticky-note	icons/fontawesome/solid/sticky-note.svg	Sticky Note	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2521	fontawesome	stop-circle	icons/fontawesome/solid/stop-circle.svg	Stop Circle	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2522	fontawesome	stop	icons/fontawesome/solid/stop.svg	Stop	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2523	fontawesome	stopwatch-20	icons/fontawesome/solid/stopwatch-20.svg	Stopwatch 20	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2524	fontawesome	stopwatch	icons/fontawesome/solid/stopwatch.svg	Stopwatch	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2525	fontawesome	store-alt-slash	icons/fontawesome/solid/store-alt-slash.svg	Store Alt Slash	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:36:59	public
2526	fontawesome	store-alt	icons/fontawesome/solid/store-alt.svg	Store Alt	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:36:59	public
2528	fontawesome	store	icons/fontawesome/solid/store.svg	Store	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:36:59	public
2529	fontawesome	stream	icons/fontawesome/solid/stream.svg	Stream	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2530	fontawesome	street-view	icons/fontawesome/solid/street-view.svg	Street View	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2531	fontawesome	strikethrough	icons/fontawesome/solid/strikethrough.svg	Strikethrough	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2532	fontawesome	stroopwafel	icons/fontawesome/solid/stroopwafel.svg	Stroopwafel	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2533	fontawesome	subscript	icons/fontawesome/solid/subscript.svg	Subscript	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2534	fontawesome	subtract	icons/fontawesome/solid/subtract.svg	Subtract	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2535	fontawesome	subway	icons/fontawesome/solid/subway.svg	Subway	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2537	fontawesome	suitcase-rolling	icons/fontawesome/solid/suitcase-rolling.svg	Suitcase Rolling	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2538	fontawesome	suitcase	icons/fontawesome/solid/suitcase.svg	Suitcase	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2539	fontawesome	sun-plant-wilt	icons/fontawesome/solid/sun-plant-wilt.svg	Sun Plant Wilt	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2540	fontawesome	sun	icons/fontawesome/solid/sun.svg	Sun	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2541	fontawesome	superscript	icons/fontawesome/solid/superscript.svg	Superscript	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:00	public
2542	fontawesome	surprise	icons/fontawesome/solid/surprise.svg	Surprise	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:00	public
2543	fontawesome	swatchbook	icons/fontawesome/solid/swatchbook.svg	Swatchbook	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:00	public
2544	fontawesome	swimmer	icons/fontawesome/solid/swimmer.svg	Swimmer	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:00	public
2545	fontawesome	swimming-pool	icons/fontawesome/solid/swimming-pool.svg	Swimming Pool	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2546	fontawesome	synagogue	icons/fontawesome/solid/synagogue.svg	Synagogue	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2547	fontawesome	sync-alt	icons/fontawesome/solid/sync-alt.svg	Sync Alt	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2548	fontawesome	sync	icons/fontawesome/solid/sync.svg	Sync	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2550	fontawesome	t-shirt	icons/fontawesome/solid/t-shirt.svg	T Shirt	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2551	fontawesome	t	icons/fontawesome/solid/t.svg	T	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2552	fontawesome	table-cells-column-lock	icons/fontawesome/solid/table-cells-column-lock.svg	Table Cells Column Lock	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2553	fontawesome	table-cells-large	icons/fontawesome/solid/table-cells-large.svg	Table Cells Large	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2554	fontawesome	table-cells-row-lock	icons/fontawesome/solid/table-cells-row-lock.svg	Table Cells Row Lock	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2556	fontawesome	table-cells	icons/fontawesome/solid/table-cells.svg	Table Cells	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2557	fontawesome	table-columns	icons/fontawesome/solid/table-columns.svg	Table Columns	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:01	public
2558	fontawesome	table-list	icons/fontawesome/solid/table-list.svg	Table List	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:01	public
2559	fontawesome	table-tennis-paddle-ball	icons/fontawesome/solid/table-tennis-paddle-ball.svg	Table Tennis Paddle Ball	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:01	public
2561	fontawesome	table	icons/fontawesome/solid/table.svg	Table	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:01	public
2562	fontawesome	tablet-alt	icons/fontawesome/solid/tablet-alt.svg	Tablet Alt	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2563	fontawesome	tablet-android	icons/fontawesome/solid/tablet-android.svg	Tablet Android	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2564	fontawesome	tablet-button	icons/fontawesome/solid/tablet-button.svg	Tablet Button	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2565	fontawesome	tablet-screen-button	icons/fontawesome/solid/tablet-screen-button.svg	Tablet Screen Button	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2566	fontawesome	tablet	icons/fontawesome/solid/tablet.svg	Tablet	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2567	fontawesome	tablets	icons/fontawesome/solid/tablets.svg	Tablets	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2569	fontawesome	tachometer-alt-average	icons/fontawesome/solid/tachometer-alt-average.svg	Tachometer Alt Average	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2570	fontawesome	tachometer-alt-fast	icons/fontawesome/solid/tachometer-alt-fast.svg	Tachometer Alt Fast	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2571	fontawesome	tachometer-alt	icons/fontawesome/solid/tachometer-alt.svg	Tachometer Alt	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2572	fontawesome	tachometer-average	icons/fontawesome/solid/tachometer-average.svg	Tachometer Average	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:02	public
2573	fontawesome	tachometer-fast	icons/fontawesome/solid/tachometer-fast.svg	Tachometer Fast	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:02	public
2574	fontawesome	tachometer	icons/fontawesome/solid/tachometer.svg	Tachometer	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:02	public
2575	fontawesome	tag	icons/fontawesome/solid/tag.svg	Tag	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:02	public
2576	fontawesome	tags	icons/fontawesome/solid/tags.svg	Tags	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:02	public
2577	fontawesome	tanakh	icons/fontawesome/solid/tanakh.svg	Tanakh	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:02	public
2578	fontawesome	tape	icons/fontawesome/solid/tape.svg	Tape	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:02	public
2580	fontawesome	tarp	icons/fontawesome/solid/tarp.svg	Tarp	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2581	fontawesome	tasks-alt	icons/fontawesome/solid/tasks-alt.svg	Tasks Alt	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2582	fontawesome	tasks	icons/fontawesome/solid/tasks.svg	Tasks	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2583	fontawesome	taxi	icons/fontawesome/solid/taxi.svg	Taxi	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2584	fontawesome	teeth-open	icons/fontawesome/solid/teeth-open.svg	Teeth Open	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2585	fontawesome	teeth	icons/fontawesome/solid/teeth.svg	Teeth	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2586	fontawesome	teletype	icons/fontawesome/solid/teletype.svg	Teletype	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2587	fontawesome	television	icons/fontawesome/solid/television.svg	Television	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2588	fontawesome	temperature-0	icons/fontawesome/solid/temperature-0.svg	Temperature 0	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2589	fontawesome	temperature-1	icons/fontawesome/solid/temperature-1.svg	Temperature 1	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:03	public
2590	fontawesome	temperature-2	icons/fontawesome/solid/temperature-2.svg	Temperature 2	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:03	public
2592	fontawesome	temperature-4	icons/fontawesome/solid/temperature-4.svg	Temperature 4	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:03	public
2593	fontawesome	temperature-arrow-down	icons/fontawesome/solid/temperature-arrow-down.svg	Temperature Arrow Down	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:03	public
2594	fontawesome	temperature-arrow-up	icons/fontawesome/solid/temperature-arrow-up.svg	Temperature Arrow Up	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:03	public
2595	fontawesome	temperature-down	icons/fontawesome/solid/temperature-down.svg	Temperature Down	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:03	public
2596	fontawesome	temperature-empty	icons/fontawesome/solid/temperature-empty.svg	Temperature Empty	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2597	fontawesome	temperature-full	icons/fontawesome/solid/temperature-full.svg	Temperature Full	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2598	fontawesome	temperature-half	icons/fontawesome/solid/temperature-half.svg	Temperature Half	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2600	fontawesome	temperature-low	icons/fontawesome/solid/temperature-low.svg	Temperature Low	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2601	fontawesome	temperature-quarter	icons/fontawesome/solid/temperature-quarter.svg	Temperature Quarter	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2602	fontawesome	temperature-three-quarters	icons/fontawesome/solid/temperature-three-quarters.svg	Temperature Three Quarters	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2603	fontawesome	temperature-up	icons/fontawesome/solid/temperature-up.svg	Temperature Up	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2604	fontawesome	tenge-sign	icons/fontawesome/solid/tenge-sign.svg	Tenge Sign	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2605	fontawesome	tenge	icons/fontawesome/solid/tenge.svg	Tenge	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:04	public
2607	fontawesome	tent-arrow-left-right	icons/fontawesome/solid/tent-arrow-left-right.svg	Tent Arrow Left Right	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:04	public
2608	fontawesome	tent-arrow-turn-left	icons/fontawesome/solid/tent-arrow-turn-left.svg	Tent Arrow Turn Left	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:04	public
2609	fontawesome	tent-arrows-down	icons/fontawesome/solid/tent-arrows-down.svg	Tent Arrows Down	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:04	public
2610	fontawesome	tent	icons/fontawesome/solid/tent.svg	Tent	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:04	public
2611	fontawesome	tents	icons/fontawesome/solid/tents.svg	Tents	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:04	public
2612	fontawesome	terminal	icons/fontawesome/solid/terminal.svg	Terminal	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2613	fontawesome	text-height	icons/fontawesome/solid/text-height.svg	Text Height	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2614	fontawesome	text-slash	icons/fontawesome/solid/text-slash.svg	Text Slash	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2616	fontawesome	th-large	icons/fontawesome/solid/th-large.svg	Th Large	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2617	fontawesome	th-list	icons/fontawesome/solid/th-list.svg	Th List	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2618	fontawesome	th	icons/fontawesome/solid/th.svg	Th	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2619	fontawesome	theater-masks	icons/fontawesome/solid/theater-masks.svg	Theater Masks	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2620	fontawesome	thermometer-0	icons/fontawesome/solid/thermometer-0.svg	Thermometer 0	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2621	fontawesome	thermometer-1	icons/fontawesome/solid/thermometer-1.svg	Thermometer 1	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:05	public
2622	fontawesome	thermometer-2	icons/fontawesome/solid/thermometer-2.svg	Thermometer 2	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:05	public
2624	fontawesome	thermometer-4	icons/fontawesome/solid/thermometer-4.svg	Thermometer 4	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:05	public
2625	fontawesome	thermometer-empty	icons/fontawesome/solid/thermometer-empty.svg	Thermometer Empty	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:05	public
2626	fontawesome	thermometer-full	icons/fontawesome/solid/thermometer-full.svg	Thermometer Full	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:05	public
2627	fontawesome	thermometer-half	icons/fontawesome/solid/thermometer-half.svg	Thermometer Half	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:05	public
2628	fontawesome	thermometer-quarter	icons/fontawesome/solid/thermometer-quarter.svg	Thermometer Quarter	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:05	public
2630	fontawesome	thermometer	icons/fontawesome/solid/thermometer.svg	Thermometer	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:06	public
2631	fontawesome	thumb-tack-slash	icons/fontawesome/solid/thumb-tack-slash.svg	Thumb Tack Slash	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:06	public
2632	fontawesome	thumb-tack	icons/fontawesome/solid/thumb-tack.svg	Thumb Tack	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:06	public
2633	fontawesome	thumbs-down	icons/fontawesome/solid/thumbs-down.svg	Thumbs Down	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:06	public
2634	fontawesome	thumbs-up	icons/fontawesome/solid/thumbs-up.svg	Thumbs Up	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:06	public
2635	fontawesome	thumbtack-slash	icons/fontawesome/solid/thumbtack-slash.svg	Thumbtack Slash	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:06	public
2636	fontawesome	thumbtack	icons/fontawesome/solid/thumbtack.svg	Thumbtack	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:06	public
2637	fontawesome	thunderstorm	icons/fontawesome/solid/thunderstorm.svg	Thunderstorm	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2638	fontawesome	ticket-alt	icons/fontawesome/solid/ticket-alt.svg	Ticket Alt	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2639	fontawesome	ticket-simple	icons/fontawesome/solid/ticket-simple.svg	Ticket Simple	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2640	fontawesome	ticket	icons/fontawesome/solid/ticket.svg	Ticket	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2641	fontawesome	timeline	icons/fontawesome/solid/timeline.svg	Timeline	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2642	fontawesome	times-circle	icons/fontawesome/solid/times-circle.svg	Times Circle	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2643	fontawesome	times-rectangle	icons/fontawesome/solid/times-rectangle.svg	Times Rectangle	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2645	fontawesome	times	icons/fontawesome/solid/times.svg	Times	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2646	fontawesome	tint-slash	icons/fontawesome/solid/tint-slash.svg	Tint Slash	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:07	public
2647	fontawesome	tint	icons/fontawesome/solid/tint.svg	Tint	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:07	public
2648	fontawesome	tired	icons/fontawesome/solid/tired.svg	Tired	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:07	public
2649	fontawesome	toggle-off	icons/fontawesome/solid/toggle-off.svg	Toggle Off	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:07	public
2650	fontawesome	toggle-on	icons/fontawesome/solid/toggle-on.svg	Toggle On	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:07	public
2651	fontawesome	toilet-paper-alt	icons/fontawesome/solid/toilet-paper-alt.svg	Toilet Paper Alt	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:07	public
2652	fontawesome	toilet-paper-blank	icons/fontawesome/solid/toilet-paper-blank.svg	Toilet Paper Blank	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:07	public
2653	fontawesome	toilet-paper-slash	icons/fontawesome/solid/toilet-paper-slash.svg	Toilet Paper Slash	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2654	fontawesome	toilet-paper	icons/fontawesome/solid/toilet-paper.svg	Toilet Paper	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2656	fontawesome	toilet	icons/fontawesome/solid/toilet.svg	Toilet	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2657	fontawesome	toilets-portable	icons/fontawesome/solid/toilets-portable.svg	Toilets Portable	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2658	fontawesome	toolbox	icons/fontawesome/solid/toolbox.svg	Toolbox	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2659	fontawesome	tools	icons/fontawesome/solid/tools.svg	Tools	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2660	fontawesome	tooth	icons/fontawesome/solid/tooth.svg	Tooth	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2661	fontawesome	torah	icons/fontawesome/solid/torah.svg	Torah	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2662	fontawesome	torii-gate	icons/fontawesome/solid/torii-gate.svg	Torii Gate	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2663	fontawesome	tornado	icons/fontawesome/solid/tornado.svg	Tornado	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:08	public
2664	fontawesome	tower-broadcast	icons/fontawesome/solid/tower-broadcast.svg	Tower Broadcast	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:08	public
2665	fontawesome	tower-cell	icons/fontawesome/solid/tower-cell.svg	Tower Cell	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:08	public
2667	fontawesome	tractor	icons/fontawesome/solid/tractor.svg	Tractor	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:08	public
2668	fontawesome	trademark	icons/fontawesome/solid/trademark.svg	Trademark	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2669	fontawesome	traffic-light	icons/fontawesome/solid/traffic-light.svg	Traffic Light	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2670	fontawesome	trailer	icons/fontawesome/solid/trailer.svg	Trailer	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2672	fontawesome	train-tram	icons/fontawesome/solid/train-tram.svg	Train Tram	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2673	fontawesome	train	icons/fontawesome/solid/train.svg	Train	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2674	fontawesome	tram	icons/fontawesome/solid/tram.svg	Tram	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2675	fontawesome	transgender-alt	icons/fontawesome/solid/transgender-alt.svg	Transgender Alt	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2676	fontawesome	transgender	icons/fontawesome/solid/transgender.svg	Transgender	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2677	fontawesome	trash-alt	icons/fontawesome/solid/trash-alt.svg	Trash Alt	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2679	fontawesome	trash-can-arrow-up	icons/fontawesome/solid/trash-can-arrow-up.svg	Trash Can Arrow Up	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:09	public
2680	fontawesome	trash-can	icons/fontawesome/solid/trash-can.svg	Trash Can	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:09	public
2681	fontawesome	trash-restore-alt	icons/fontawesome/solid/trash-restore-alt.svg	Trash Restore Alt	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:09	public
2682	fontawesome	trash-restore	icons/fontawesome/solid/trash-restore.svg	Trash Restore	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:09	public
2683	fontawesome	trash	icons/fontawesome/solid/trash.svg	Trash	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:09	public
2684	fontawesome	tree-city	icons/fontawesome/solid/tree-city.svg	Tree City	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2685	fontawesome	tree	icons/fontawesome/solid/tree.svg	Tree	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2686	fontawesome	triangle-circle-square	icons/fontawesome/solid/triangle-circle-square.svg	Triangle Circle Square	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2688	fontawesome	trophy	icons/fontawesome/solid/trophy.svg	Trophy	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2689	fontawesome	trowel-bricks	icons/fontawesome/solid/trowel-bricks.svg	Trowel Bricks	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2690	fontawesome	trowel	icons/fontawesome/solid/trowel.svg	Trowel	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2691	fontawesome	truck-arrow-right	icons/fontawesome/solid/truck-arrow-right.svg	Truck Arrow Right	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2692	fontawesome	truck-droplet	icons/fontawesome/solid/truck-droplet.svg	Truck Droplet	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2693	fontawesome	truck-fast	icons/fontawesome/solid/truck-fast.svg	Truck Fast	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2694	fontawesome	truck-field-un	icons/fontawesome/solid/truck-field-un.svg	Truck Field Un	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2695	fontawesome	truck-field	icons/fontawesome/solid/truck-field.svg	Truck Field	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2696	fontawesome	truck-front	icons/fontawesome/solid/truck-front.svg	Truck Front	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:10	public
2697	fontawesome	truck-loading	icons/fontawesome/solid/truck-loading.svg	Truck Loading	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:10	public
2699	fontawesome	truck-monster	icons/fontawesome/solid/truck-monster.svg	Truck Monster	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:10	public
2700	fontawesome	truck-moving	icons/fontawesome/solid/truck-moving.svg	Truck Moving	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2701	fontawesome	truck-pickup	icons/fontawesome/solid/truck-pickup.svg	Truck Pickup	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2702	fontawesome	truck-plane	icons/fontawesome/solid/truck-plane.svg	Truck Plane	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2703	fontawesome	truck-ramp-box	icons/fontawesome/solid/truck-ramp-box.svg	Truck Ramp Box	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2704	fontawesome	truck	icons/fontawesome/solid/truck.svg	Truck	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2705	fontawesome	try	icons/fontawesome/solid/try.svg	Try	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2706	fontawesome	tshirt	icons/fontawesome/solid/tshirt.svg	Tshirt	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2707	fontawesome	tty	icons/fontawesome/solid/tty.svg	Tty	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2709	fontawesome	turkish-lira	icons/fontawesome/solid/turkish-lira.svg	Turkish Lira	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2710	fontawesome	turn-down	icons/fontawesome/solid/turn-down.svg	Turn Down	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2711	fontawesome	turn-up	icons/fontawesome/solid/turn-up.svg	Turn Up	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2712	fontawesome	tv-alt	icons/fontawesome/solid/tv-alt.svg	Tv Alt	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2713	fontawesome	tv	icons/fontawesome/solid/tv.svg	Tv	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:11	public
2714	fontawesome	u	icons/fontawesome/solid/u.svg	U	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:11	public
2715	fontawesome	umbrella-beach	icons/fontawesome/solid/umbrella-beach.svg	Umbrella Beach	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:11	public
2716	fontawesome	umbrella	icons/fontawesome/solid/umbrella.svg	Umbrella	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:11	public
2717	fontawesome	underline	icons/fontawesome/solid/underline.svg	Underline	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2718	fontawesome	undo-alt	icons/fontawesome/solid/undo-alt.svg	Undo Alt	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2719	fontawesome	undo	icons/fontawesome/solid/undo.svg	Undo	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2720	fontawesome	universal-access	icons/fontawesome/solid/universal-access.svg	Universal Access	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2721	fontawesome	university	icons/fontawesome/solid/university.svg	University	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2722	fontawesome	unlink	icons/fontawesome/solid/unlink.svg	Unlink	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2723	fontawesome	unlock-alt	icons/fontawesome/solid/unlock-alt.svg	Unlock Alt	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2725	fontawesome	unlock	icons/fontawesome/solid/unlock.svg	Unlock	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2726	fontawesome	unsorted	icons/fontawesome/solid/unsorted.svg	Unsorted	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2727	fontawesome	up-down-left-right	icons/fontawesome/solid/up-down-left-right.svg	Up Down Left Right	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2729	fontawesome	up-long	icons/fontawesome/solid/up-long.svg	Up Long	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2731	fontawesome	up-right-from-square	icons/fontawesome/solid/up-right-from-square.svg	Up Right From Square	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:12	public
2732	fontawesome	upload	icons/fontawesome/solid/upload.svg	Upload	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:12	public
2733	fontawesome	usd	icons/fontawesome/solid/usd.svg	Usd	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2734	fontawesome	user-alt-slash	icons/fontawesome/solid/user-alt-slash.svg	User Alt Slash	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2735	fontawesome	user-alt	icons/fontawesome/solid/user-alt.svg	User Alt	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2736	fontawesome	user-astronaut	icons/fontawesome/solid/user-astronaut.svg	User Astronaut	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2737	fontawesome	user-check	icons/fontawesome/solid/user-check.svg	User Check	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2738	fontawesome	user-circle	icons/fontawesome/solid/user-circle.svg	User Circle	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2739	fontawesome	user-clock	icons/fontawesome/solid/user-clock.svg	User Clock	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2740	fontawesome	user-cog	icons/fontawesome/solid/user-cog.svg	User Cog	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2741	fontawesome	user-doctor	icons/fontawesome/solid/user-doctor.svg	User Doctor	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2742	fontawesome	user-edit	icons/fontawesome/solid/user-edit.svg	User Edit	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2743	fontawesome	user-friends	icons/fontawesome/solid/user-friends.svg	User Friends	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2744	fontawesome	user-gear	icons/fontawesome/solid/user-gear.svg	User Gear	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2745	fontawesome	user-graduate	icons/fontawesome/solid/user-graduate.svg	User Graduate	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:12	public
2746	fontawesome	user-group	icons/fontawesome/solid/user-group.svg	User Group	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:13	public
2748	fontawesome	user-large-slash	icons/fontawesome/solid/user-large-slash.svg	User Large Slash	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:13	public
2749	fontawesome	user-large	icons/fontawesome/solid/user-large.svg	User Large	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2750	fontawesome	user-lock	icons/fontawesome/solid/user-lock.svg	User Lock	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2751	fontawesome	user-md	icons/fontawesome/solid/user-md.svg	User Md	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2752	fontawesome	user-minus	icons/fontawesome/solid/user-minus.svg	User Minus	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2753	fontawesome	user-ninja	icons/fontawesome/solid/user-ninja.svg	User Ninja	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2754	fontawesome	user-nurse	icons/fontawesome/solid/user-nurse.svg	User Nurse	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2755	fontawesome	user-pen	icons/fontawesome/solid/user-pen.svg	User Pen	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2756	fontawesome	user-plus	icons/fontawesome/solid/user-plus.svg	User Plus	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2757	fontawesome	user-secret	icons/fontawesome/solid/user-secret.svg	User Secret	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2758	fontawesome	user-shield	icons/fontawesome/solid/user-shield.svg	User Shield	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2760	fontawesome	user-tag	icons/fontawesome/solid/user-tag.svg	User Tag	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2761	fontawesome	user-tie	icons/fontawesome/solid/user-tie.svg	User Tie	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2762	fontawesome	user-times	icons/fontawesome/solid/user-times.svg	User Times	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2763	fontawesome	user-xmark	icons/fontawesome/solid/user-xmark.svg	User Xmark	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:14	public
2764	fontawesome	user	icons/fontawesome/solid/user.svg	User	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2765	fontawesome	users-between-lines	icons/fontawesome/solid/users-between-lines.svg	Users Between Lines	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2766	fontawesome	users-cog	icons/fontawesome/solid/users-cog.svg	Users Cog	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2767	fontawesome	users-gear	icons/fontawesome/solid/users-gear.svg	Users Gear	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2768	fontawesome	users-line	icons/fontawesome/solid/users-line.svg	Users Line	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2769	fontawesome	users-rays	icons/fontawesome/solid/users-rays.svg	Users Rays	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2771	fontawesome	users-slash	icons/fontawesome/solid/users-slash.svg	Users Slash	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2772	fontawesome	users-viewfinder	icons/fontawesome/solid/users-viewfinder.svg	Users Viewfinder	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2773	fontawesome	users	icons/fontawesome/solid/users.svg	Users	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2774	fontawesome	utensil-spoon	icons/fontawesome/solid/utensil-spoon.svg	Utensil Spoon	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2775	fontawesome	utensils	icons/fontawesome/solid/utensils.svg	Utensils	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2776	fontawesome	v	icons/fontawesome/solid/v.svg	V	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2777	fontawesome	van-shuttle	icons/fontawesome/solid/van-shuttle.svg	Van Shuttle	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2778	fontawesome	vault	icons/fontawesome/solid/vault.svg	Vault	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2779	fontawesome	vcard	icons/fontawesome/solid/vcard.svg	Vcard	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2781	fontawesome	venus-double	icons/fontawesome/solid/venus-double.svg	Venus Double	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2782	fontawesome	venus-mars	icons/fontawesome/solid/venus-mars.svg	Venus Mars	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2783	fontawesome	venus	icons/fontawesome/solid/venus.svg	Venus	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2784	fontawesome	vest-patches	icons/fontawesome/solid/vest-patches.svg	Vest Patches	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2786	fontawesome	vial-circle-check	icons/fontawesome/solid/vial-circle-check.svg	Vial Circle Check	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2787	fontawesome	vial-virus	icons/fontawesome/solid/vial-virus.svg	Vial Virus	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2788	fontawesome	vial	icons/fontawesome/solid/vial.svg	Vial	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2789	fontawesome	vials	icons/fontawesome/solid/vials.svg	Vials	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2790	fontawesome	video-camera	icons/fontawesome/solid/video-camera.svg	Video Camera	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2791	fontawesome	video-slash	icons/fontawesome/solid/video-slash.svg	Video Slash	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2792	fontawesome	video	icons/fontawesome/solid/video.svg	Video	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2793	fontawesome	vihara	icons/fontawesome/solid/vihara.svg	Vihara	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2795	fontawesome	virus-covid	icons/fontawesome/solid/virus-covid.svg	Virus Covid	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2796	fontawesome	virus-slash	icons/fontawesome/solid/virus-slash.svg	Virus Slash	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2797	fontawesome	virus	icons/fontawesome/solid/virus.svg	Virus	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2798	fontawesome	viruses	icons/fontawesome/solid/viruses.svg	Viruses	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2799	fontawesome	voicemail	icons/fontawesome/solid/voicemail.svg	Voicemail	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2800	fontawesome	volcano	icons/fontawesome/solid/volcano.svg	Volcano	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2801	fontawesome	volleyball-ball	icons/fontawesome/solid/volleyball-ball.svg	Volleyball Ball	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2802	fontawesome	volleyball	icons/fontawesome/solid/volleyball.svg	Volleyball	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2804	fontawesome	volume-down	icons/fontawesome/solid/volume-down.svg	Volume Down	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2805	fontawesome	volume-high	icons/fontawesome/solid/volume-high.svg	Volume High	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2806	fontawesome	volume-low	icons/fontawesome/solid/volume-low.svg	Volume Low	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2807	fontawesome	volume-mute	icons/fontawesome/solid/volume-mute.svg	Volume Mute	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2808	fontawesome	volume-off	icons/fontawesome/solid/volume-off.svg	Volume Off	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2809	fontawesome	volume-times	icons/fontawesome/solid/volume-times.svg	Volume Times	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2810	fontawesome	volume-up	icons/fontawesome/solid/volume-up.svg	Volume Up	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2811	fontawesome	volume-xmark	icons/fontawesome/solid/volume-xmark.svg	Volume Xmark	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2812	fontawesome	vote-yea	icons/fontawesome/solid/vote-yea.svg	Vote Yea	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2813	fontawesome	vr-cardboard	icons/fontawesome/solid/vr-cardboard.svg	Vr Cardboard	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:16	public
2814	fontawesome	w	icons/fontawesome/solid/w.svg	W	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2815	fontawesome	walkie-talkie	icons/fontawesome/solid/walkie-talkie.svg	Walkie Talkie	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2816	fontawesome	walking	icons/fontawesome/solid/walking.svg	Walking	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2817	fontawesome	wallet	icons/fontawesome/solid/wallet.svg	Wallet	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2819	fontawesome	wand-magic	icons/fontawesome/solid/wand-magic.svg	Wand Magic	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2820	fontawesome	wand-sparkles	icons/fontawesome/solid/wand-sparkles.svg	Wand Sparkles	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2821	fontawesome	warehouse	icons/fontawesome/solid/warehouse.svg	Warehouse	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2822	fontawesome	warning	icons/fontawesome/solid/warning.svg	Warning	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2823	fontawesome	water-ladder	icons/fontawesome/solid/water-ladder.svg	Water Ladder	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2824	fontawesome	water	icons/fontawesome/solid/water.svg	Water	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2825	fontawesome	wave-square	icons/fontawesome/solid/wave-square.svg	Wave Square	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2826	fontawesome	web-awesome	icons/fontawesome/solid/web-awesome.svg	Web Awesome	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2827	fontawesome	weight-hanging	icons/fontawesome/solid/weight-hanging.svg	Weight Hanging	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2829	fontawesome	weight	icons/fontawesome/solid/weight.svg	Weight	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:17	public
2830	fontawesome	wheat-alt	icons/fontawesome/solid/wheat-alt.svg	Wheat Alt	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2831	fontawesome	wheat-awn-circle-exclamation	icons/fontawesome/solid/wheat-awn-circle-exclamation.svg	Wheat Awn Circle Exclamation	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2832	fontawesome	wheat-awn	icons/fontawesome/solid/wheat-awn.svg	Wheat Awn	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2833	fontawesome	wheelchair-alt	icons/fontawesome/solid/wheelchair-alt.svg	Wheelchair Alt	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2834	fontawesome	wheelchair-move	icons/fontawesome/solid/wheelchair-move.svg	Wheelchair Move	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2835	fontawesome	wheelchair	icons/fontawesome/solid/wheelchair.svg	Wheelchair	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2836	fontawesome	whiskey-glass	icons/fontawesome/solid/whiskey-glass.svg	Whiskey Glass	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2837	fontawesome	wifi-3	icons/fontawesome/solid/wifi-3.svg	Wifi 3	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2839	fontawesome	wifi	icons/fontawesome/solid/wifi.svg	Wifi	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2840	fontawesome	wind	icons/fontawesome/solid/wind.svg	Wind	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2841	fontawesome	window-close	icons/fontawesome/solid/window-close.svg	Window Close	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2865	image	\N	icons/custom/39fa8977-1901-47c7-8aea-e3c2b5ddafe2.png	BCA	bank	1	t	2025-11-20 09:42:50	2025-11-20 09:42:50	gcs
2867	image	\N	icons/custom/2d7371b1-4cb9-4261-8ce6-1e28468dde61.png	MANDIRI	bank	1	t	2025-11-20 09:44:25	2025-11-20 09:44:25	gcs
2868	image	\N	icons/custom/a67ea09a-a95e-4ddd-92dd-98ebed42b4a0.png	GOPAY	e-wallet	1	t	2025-11-20 09:45:43	2025-11-20 09:45:43	gcs
2869	image	\N	icons/custom/81df5ad3-7bca-43bb-8b04-fd2c2008f002.png	SHOPEE PAY	e-wallet	1	t	2025-11-20 09:46:54	2025-11-20 09:46:54	gcs
2870	image	\N	icons/custom/efcbcc68-0356-43c5-9153-9e4aba31e2c8.png	DANA	e-wallet	1	t	2025-11-20 09:49:01	2025-11-20 09:49:01	gcs
2871	image	\N	icons/custom/2fd632ad-5d65-47ea-955e-3371121504ac.png	OVO	e-wallet	1	t	2025-11-20 09:49:38	2025-11-20 09:49:38	gcs
2872	image	\N	icons/custom/91ca996f-eb62-4489-9d89-264a890b2c4e.png	Flazz	e-money	1	t	2025-11-20 09:50:22	2025-11-20 09:50:22	gcs
2873	image	\N	icons/custom/e8e713ae-5966-4048-8386-9bd9f7a78725.png	CHAT GPT	subscription	1	t	2025-11-20 09:51:28	2025-11-20 09:51:28	gcs
2874	image	\N	icons/custom/eff94b2e-931c-44ac-943c-1c29c533b0c1.png	TELKOMSEL	subscription	1	t	2025-11-20 09:52:44	2025-11-20 09:52:44	gcs
2875	image	\N	icons/custom/2698c14e-b3be-4feb-a268-5dcd6b323401.png	ICLOUD	subscription	1	t	2025-11-20 09:53:12	2025-11-20 09:53:12	gcs
2876	image	\N	icons/custom/e86e7597-b406-4840-8949-57b65420aea2.png	APPLE MUSIC	subscription	1	t	2025-11-20 09:53:40	2025-11-20 09:53:40	gcs
2877	image	\N	icons/custom/bcf178ae-448a-4bf8-b2f1-5d71aea8aabb.png	NETFLIX	subscription	1	t	2025-11-20 09:54:17	2025-11-20 09:54:17	gcs
2878	image	\N	icons/custom/f0aaa498-3f34-4c03-b6f7-16545f782ddd.png	GOOGLE DRIVE	subscription	1	t	2025-11-20 09:54:44	2025-11-20 09:54:44	gcs
59	fontawesome	11ty	icons/fontawesome/brands/11ty.svg	11Ty	brands	\N	t	2025-11-20 02:04:42	2025-11-20 10:34:23	public
66	fontawesome	affiliatetheme	icons/fontawesome/brands/affiliatetheme.svg	Affiliatetheme	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
70	fontawesome	amazon-pay	icons/fontawesome/brands/amazon-pay.svg	Amazon Pay	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:23	public
72	fontawesome	amilia	icons/fontawesome/brands/amilia.svg	Amilia	brands	\N	t	2025-11-20 02:04:43	2025-11-20 10:34:24	public
82	fontawesome	artstation	icons/fontawesome/brands/artstation.svg	Artstation	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:24	public
92	fontawesome	behance-square	icons/fontawesome/brands/behance-square.svg	Behance Square	brands	\N	t	2025-11-20 02:04:44	2025-11-20 10:34:25	public
106	fontawesome	bootstrap	icons/fontawesome/brands/bootstrap.svg	Bootstrap	brands	\N	t	2025-11-20 02:04:45	2025-11-20 10:34:26	public
115	fontawesome	canadian-maple-leaf	icons/fontawesome/brands/canadian-maple-leaf.svg	Canadian Maple Leaf	brands	\N	t	2025-11-20 02:04:46	2025-11-20 10:34:26	public
128	fontawesome	centos	icons/fontawesome/brands/centos.svg	Centos	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:27	public
130	fontawesome	chromecast	icons/fontawesome/brands/chromecast.svg	Chromecast	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
139	fontawesome	connectdevelop	icons/fontawesome/brands/connectdevelop.svg	Connectdevelop	brands	\N	t	2025-11-20 02:04:47	2025-11-20 10:34:28	public
146	fontawesome	creative-commons-nc	icons/fontawesome/brands/creative-commons-nc.svg	Creative Commons Nc	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
153	fontawesome	creative-commons-sampling	icons/fontawesome/brands/creative-commons-sampling.svg	Creative Commons Sampling	brands	\N	t	2025-11-20 02:04:48	2025-11-20 10:34:29	public
168	fontawesome	deezer	icons/fontawesome/brands/deezer.svg	Deezer	brands	\N	t	2025-11-20 02:04:49	2025-11-20 10:34:30	public
180	fontawesome	disqus	icons/fontawesome/brands/disqus.svg	Disqus	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
184	fontawesome	dribbble-square	icons/fontawesome/brands/dribbble-square.svg	Dribbble Square	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:31	public
2842	fontawesome	window-maximize	icons/fontawesome/solid/window-maximize.svg	Window Maximize	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2843	fontawesome	window-minimize	icons/fontawesome/solid/window-minimize.svg	Window Minimize	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2844	fontawesome	window-restore	icons/fontawesome/solid/window-restore.svg	Window Restore	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2845	fontawesome	wine-bottle	icons/fontawesome/solid/wine-bottle.svg	Wine Bottle	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:18	public
2846	fontawesome	wine-glass-alt	icons/fontawesome/solid/wine-glass-alt.svg	Wine Glass Alt	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:18	public
2847	fontawesome	wine-glass-empty	icons/fontawesome/solid/wine-glass-empty.svg	Wine Glass Empty	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2848	fontawesome	wine-glass	icons/fontawesome/solid/wine-glass.svg	Wine Glass	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2849	fontawesome	won-sign	icons/fontawesome/solid/won-sign.svg	Won Sign	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2850	fontawesome	won	icons/fontawesome/solid/won.svg	Won	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2851	fontawesome	worm	icons/fontawesome/solid/worm.svg	Worm	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2852	fontawesome	wrench	icons/fontawesome/solid/wrench.svg	Wrench	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2854	fontawesome	x	icons/fontawesome/solid/x.svg	X	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2855	fontawesome	xmark-circle	icons/fontawesome/solid/xmark-circle.svg	Xmark Circle	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2856	fontawesome	xmark-square	icons/fontawesome/solid/xmark-square.svg	Xmark Square	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2857	fontawesome	xmark	icons/fontawesome/solid/xmark.svg	Xmark	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2858	fontawesome	xmarks-lines	icons/fontawesome/solid/xmarks-lines.svg	Xmarks Lines	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2859	fontawesome	y	icons/fontawesome/solid/y.svg	Y	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
2860	fontawesome	yen-sign	icons/fontawesome/solid/yen-sign.svg	Yen Sign	solid	\N	t	2025-11-20 02:07:37	2025-11-20 10:37:19	public
2861	fontawesome	yen	icons/fontawesome/solid/yen.svg	Yen	solid	\N	t	2025-11-20 02:07:37	2025-11-20 10:37:19	public
2862	fontawesome	yin-yang	icons/fontawesome/solid/yin-yang.svg	Yin Yang	solid	\N	t	2025-11-20 02:07:37	2025-11-20 10:37:19	public
2863	fontawesome	z	icons/fontawesome/solid/z.svg	Z	solid	\N	t	2025-11-20 02:07:37	2025-11-20 10:37:19	public
2864	fontawesome	zap	icons/fontawesome/solid/zap.svg	Zap	solid	\N	t	2025-11-20 02:07:37	2025-11-20 10:37:20	public
190	fontawesome	earlybirds	icons/fontawesome/brands/earlybirds.svg	Earlybirds	brands	\N	t	2025-11-20 02:04:50	2025-11-20 10:34:32	public
205	fontawesome	facebook-f	icons/fontawesome/brands/facebook-f.svg	Facebook F	brands	\N	t	2025-11-20 02:04:51	2025-11-20 10:34:33	public
214	fontawesome	firefox-browser	icons/fontawesome/brands/firefox-browser.svg	Firefox Browser	brands	\N	t	2025-11-20 02:04:52	2025-11-20 10:34:33	public
225	fontawesome	font-awesome-logo-full	icons/fontawesome/brands/font-awesome-logo-full.svg	Font Awesome Logo Full	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:34	public
236	fontawesome	galactic-republic	icons/fontawesome/brands/galactic-republic.svg	Galactic Republic	brands	\N	t	2025-11-20 02:04:53	2025-11-20 10:34:35	public
241	fontawesome	git-alt	icons/fontawesome/brands/git-alt.svg	Git Alt	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:36	public
245	fontawesome	github-square	icons/fontawesome/brands/github-square.svg	Github Square	brands	\N	t	2025-11-20 02:04:54	2025-11-20 10:34:36	public
257	fontawesome	google-drive	icons/fontawesome/brands/google-drive.svg	Google Drive	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:38	public
268	fontawesome	gripfire	icons/fontawesome/brands/gripfire.svg	Gripfire	brands	\N	t	2025-11-20 02:04:55	2025-11-20 10:34:39	public
280	fontawesome	hornbill	icons/fontawesome/brands/hornbill.svg	Hornbill	brands	\N	t	2025-11-20 02:04:56	2025-11-20 10:34:40	public
292	fontawesome	internet-explorer	icons/fontawesome/brands/internet-explorer.svg	Internet Explorer	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:41	public
299	fontawesome	jedi-order	icons/fontawesome/brands/jedi-order.svg	Jedi Order	brands	\N	t	2025-11-20 02:04:57	2025-11-20 10:34:42	public
308	fontawesome	kaggle	icons/fontawesome/brands/kaggle.svg	Kaggle	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:42	public
316	fontawesome	lastfm-square	icons/fontawesome/brands/lastfm-square.svg	Lastfm Square	brands	\N	t	2025-11-20 02:04:58	2025-11-20 10:34:43	public
331	fontawesome	mailchimp	icons/fontawesome/brands/mailchimp.svg	Mailchimp	brands	\N	t	2025-11-20 02:04:59	2025-11-20 10:34:44	public
345	fontawesome	microblog	icons/fontawesome/brands/microblog.svg	Microblog	brands	\N	t	2025-11-20 02:05:00	2025-11-20 10:34:44	public
358	fontawesome	nimblr	icons/fontawesome/brands/nimblr.svg	Nimblr	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:45	public
364	fontawesome	nutritionix	icons/fontawesome/brands/nutritionix.svg	Nutritionix	brands	\N	t	2025-11-20 02:05:01	2025-11-20 10:34:46	public
375	fontawesome	optin-monster	icons/fontawesome/brands/optin-monster.svg	Optin Monster	brands	\N	t	2025-11-20 02:05:02	2025-11-20 10:34:47	public
388	fontawesome	phoenix-framework	icons/fontawesome/brands/phoenix-framework.svg	Phoenix Framework	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:48	public
400	fontawesome	pixelfed	icons/fontawesome/brands/pixelfed.svg	Pixelfed	brands	\N	t	2025-11-20 02:05:03	2025-11-20 10:34:49	public
413	fontawesome	reacteurope	icons/fontawesome/brands/reacteurope.svg	Reacteurope	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:50	public
416	fontawesome	red-river	icons/fontawesome/brands/red-river.svg	Red River	brands	\N	t	2025-11-20 02:05:04	2025-11-20 10:34:50	public
424	fontawesome	researchgate	icons/fontawesome/brands/researchgate.svg	Researchgate	brands	\N	t	2025-11-20 02:05:05	2025-11-20 10:34:51	public
436	fontawesome	searchengin	icons/fontawesome/brands/searchengin.svg	Searchengin	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:53	public
450	fontawesome	skyatlas	icons/fontawesome/brands/skyatlas.svg	Skyatlas	brands	\N	t	2025-11-20 02:05:06	2025-11-20 10:34:54	public
459	fontawesome	sourcetree	icons/fontawesome/brands/sourcetree.svg	Sourcetree	brands	\N	t	2025-11-20 02:05:07	2025-11-20 10:34:54	public
467	fontawesome	square-facebook	icons/fontawesome/brands/square-facebook.svg	Square Facebook	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
473	fontawesome	square-gitlab	icons/fontawesome/brands/square-gitlab.svg	Square Gitlab	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
476	fontawesome	square-instagram	icons/fontawesome/brands/square-instagram.svg	Square Instagram	brands	\N	t	2025-11-20 02:05:08	2025-11-20 10:34:55	public
484	fontawesome	square-pinterest	icons/fontawesome/brands/square-pinterest.svg	Square Pinterest	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
494	fontawesome	square-web-awesome-stroke	icons/fontawesome/brands/square-web-awesome-stroke.svg	Square Web Awesome Stroke	brands	\N	t	2025-11-20 02:05:09	2025-11-20 10:34:56	public
505	fontawesome	steam-square	icons/fontawesome/brands/steam-square.svg	Steam Square	brands	\N	t	2025-11-20 02:05:10	2025-11-20 10:34:57	public
516	fontawesome	superpowers	icons/fontawesome/brands/superpowers.svg	Superpowers	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
528	fontawesome	themeisle	icons/fontawesome/brands/themeisle.svg	Themeisle	brands	\N	t	2025-11-20 02:05:11	2025-11-20 10:34:58	public
538	fontawesome	twitter-square	icons/fontawesome/brands/twitter-square.svg	Twitter Square	brands	\N	t	2025-11-20 02:05:12	2025-11-20 10:34:59	public
554	fontawesome	ussunnah	icons/fontawesome/brands/ussunnah.svg	Ussunnah	brands	\N	t	2025-11-20 02:05:13	2025-11-20 10:35:00	public
567	fontawesome	vuejs	icons/fontawesome/brands/vuejs.svg	Vuejs	brands	\N	t	2025-11-20 02:05:14	2025-11-20 10:35:01	public
579	fontawesome	wikipedia-w	icons/fontawesome/brands/wikipedia-w.svg	Wikipedia W	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
586	fontawesome	wordpress-simple	icons/fontawesome/brands/wordpress-simple.svg	Wordpress Simple	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
588	fontawesome	wpbeginner	icons/fontawesome/brands/wpbeginner.svg	Wpbeginner	brands	\N	t	2025-11-20 02:05:15	2025-11-20 10:35:02	public
600	fontawesome	yandex-international	icons/fontawesome/brands/yandex-international.svg	Yandex International	brands	\N	t	2025-11-20 02:05:16	2025-11-20 10:35:03	public
613	fontawesome	arrow-alt-circle-left	icons/fontawesome/regular/arrow-alt-circle-left.svg	Arrow Alt Circle Left	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
624	fontawesome	calendar-minus	icons/fontawesome/regular/calendar-minus.svg	Calendar Minus	regular	\N	t	2025-11-20 02:05:17	2025-11-20 10:35:04	public
634	fontawesome	caret-square-up	icons/fontawesome/regular/caret-square-up.svg	Caret Square Up	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:05	public
642	fontawesome	chess-queen	icons/fontawesome/regular/chess-queen.svg	Chess Queen	regular	\N	t	2025-11-20 02:05:18	2025-11-20 10:35:06	public
648	fontawesome	circle-pause	icons/fontawesome/regular/circle-pause.svg	Circle Pause	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:06	public
658	fontawesome	clock-four	icons/fontawesome/regular/clock-four.svg	Clock Four	regular	\N	t	2025-11-20 02:05:19	2025-11-20 10:35:07	public
669	fontawesome	contact-book	icons/fontawesome/regular/contact-book.svg	Contact Book	regular	\N	t	2025-11-20 02:05:20	2025-11-20 10:35:07	public
679	fontawesome	envelope-open	icons/fontawesome/regular/envelope-open.svg	Envelope Open	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:08	public
689	fontawesome	face-grin-beam-sweat	icons/fontawesome/regular/face-grin-beam-sweat.svg	Face Grin Beam Sweat	regular	\N	t	2025-11-20 02:05:21	2025-11-20 10:35:09	public
697	fontawesome	face-grin-tongue-wink	icons/fontawesome/regular/face-grin-tongue-wink.svg	Face Grin Tongue Wink	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
699	fontawesome	face-grin-wide	icons/fontawesome/regular/face-grin-wide.svg	Face Grin Wide	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:09	public
708	fontawesome	face-laugh	icons/fontawesome/regular/face-laugh.svg	Face Laugh	regular	\N	t	2025-11-20 02:05:22	2025-11-20 10:35:10	public
717	fontawesome	face-surprise	icons/fontawesome/regular/face-surprise.svg	Face Surprise	regular	\N	t	2025-11-20 02:05:23	2025-11-20 10:35:10	public
728	fontawesome	file-powerpoint	icons/fontawesome/regular/file-powerpoint.svg	File Powerpoint	regular	\N	t	2025-11-20 02:05:24	2025-11-20 10:35:11	public
741	fontawesome	font-awesome-flag	icons/fontawesome/regular/font-awesome-flag.svg	Font Awesome Flag	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:12	public
752	fontawesome	grin-beam	icons/fontawesome/regular/grin-beam.svg	Grin Beam	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:13	public
753	fontawesome	grin-hearts	icons/fontawesome/regular/grin-hearts.svg	Grin Hearts	regular	\N	t	2025-11-20 02:05:25	2025-11-20 10:35:13	public
763	fontawesome	hand-back-fist	icons/fontawesome/regular/hand-back-fist.svg	Hand Back Fist	regular	\N	t	2025-11-20 02:05:26	2025-11-20 10:35:13	public
773	fontawesome	hand-scissors	icons/fontawesome/regular/hand-scissors.svg	Hand Scissors	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
782	fontawesome	headphones-simple	icons/fontawesome/regular/headphones-simple.svg	Headphones Simple	regular	\N	t	2025-11-20 02:05:27	2025-11-20 10:35:14	public
796	fontawesome	id-badge	icons/fontawesome/regular/id-badge.svg	Id Badge	regular	\N	t	2025-11-20 02:05:28	2025-11-20 10:35:15	public
806	fontawesome	laugh-wink	icons/fontawesome/regular/laugh-wink.svg	Laugh Wink	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
808	fontawesome	lemon	icons/fontawesome/regular/lemon.svg	Lemon	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
809	fontawesome	life-ring	icons/fontawesome/regular/life-ring.svg	Life Ring	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:16	public
818	fontawesome	money-bill-1	icons/fontawesome/regular/money-bill-1.svg	Money Bill 1	regular	\N	t	2025-11-20 02:05:29	2025-11-20 10:35:17	public
829	fontawesome	play-circle	icons/fontawesome/regular/play-circle.svg	Play Circle	regular	\N	t	2025-11-20 02:05:30	2025-11-20 10:35:17	public
839	fontawesome	share-from-square	icons/fontawesome/regular/share-from-square.svg	Share From Square	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
848	fontawesome	square-caret-right	icons/fontawesome/regular/square-caret-right.svg	Square Caret Right	regular	\N	t	2025-11-20 02:05:31	2025-11-20 10:35:18	public
862	fontawesome	surprise	icons/fontawesome/regular/surprise.svg	Surprise	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
864	fontawesome	thumbs-up	icons/fontawesome/regular/thumbs-up.svg	Thumbs Up	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
865	fontawesome	times-circle	icons/fontawesome/regular/times-circle.svg	Times Circle	regular	\N	t	2025-11-20 02:05:32	2025-11-20 10:35:19	public
876	fontawesome	window-close	icons/fontawesome/regular/window-close.svg	Window Close	regular	\N	t	2025-11-20 02:05:33	2025-11-20 10:35:20	public
894	fontawesome	address-book	icons/fontawesome/solid/address-book.svg	Address Book	solid	\N	t	2025-11-20 02:05:34	2025-11-20 10:35:21	public
905	fontawesome	american-sign-language-interpreting	icons/fontawesome/solid/american-sign-language-interpreting.svg	American Sign Language Interpreting	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
913	fontawesome	angle-double-right	icons/fontawesome/solid/angle-double-right.svg	Angle Double Right	solid	\N	t	2025-11-20 02:05:35	2025-11-20 10:35:22	public
921	fontawesome	angles-right	icons/fontawesome/solid/angles-right.svg	Angles Right	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
930	fontawesome	arrow-alt-circle-down	icons/fontawesome/solid/arrow-alt-circle-down.svg	Arrow Alt Circle Down	solid	\N	t	2025-11-20 02:05:36	2025-11-20 10:35:23	public
938	fontawesome	arrow-down-1-9	icons/fontawesome/solid/arrow-down-1-9.svg	Arrow Down 1 9	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
945	fontawesome	arrow-down-wide-short	icons/fontawesome/solid/arrow-down-wide-short.svg	Arrow Down Wide Short	solid	\N	t	2025-11-20 02:05:37	2025-11-20 10:35:24	public
953	fontawesome	arrow-right-from-bracket	icons/fontawesome/solid/arrow-right-from-bracket.svg	Arrow Right From Bracket	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
962	fontawesome	arrow-rotate-backward	icons/fontawesome/solid/arrow-rotate-backward.svg	Arrow Rotate Backward	solid	\N	t	2025-11-20 02:05:38	2025-11-20 10:35:25	public
973	fontawesome	arrow-up-from-bracket	icons/fontawesome/solid/arrow-up-from-bracket.svg	Arrow Up From Bracket	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
974	fontawesome	arrow-up-from-ground-water	icons/fontawesome/solid/arrow-up-from-ground-water.svg	Arrow Up From Ground Water	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
975	fontawesome	arrow-up-from-water-pump	icons/fontawesome/solid/arrow-up-from-water-pump.svg	Arrow Up From Water Pump	solid	\N	t	2025-11-20 02:05:39	2025-11-20 10:35:26	public
986	fontawesome	arrows-down-to-line	icons/fontawesome/solid/arrows-down-to-line.svg	Arrows Down To Line	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
993	fontawesome	arrows-split-up-and-left	icons/fontawesome/solid/arrows-split-up-and-left.svg	Arrows Split Up And Left	solid	\N	t	2025-11-20 02:05:40	2025-11-20 10:35:27	public
1004	fontawesome	asl-interpreting	icons/fontawesome/solid/asl-interpreting.svg	Asl Interpreting	solid	\N	t	2025-11-20 02:05:41	2025-11-20 10:35:28	public
1018	fontawesome	backward-fast	icons/fontawesome/solid/backward-fast.svg	Backward Fast	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1028	fontawesome	balance-scale-right	icons/fontawesome/solid/balance-scale-right.svg	Balance Scale Right	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:29	public
1030	fontawesome	ban-smoking	icons/fontawesome/solid/ban-smoking.svg	Ban Smoking	solid	\N	t	2025-11-20 02:05:42	2025-11-20 10:35:30	public
1041	fontawesome	baseball-ball	icons/fontawesome/solid/baseball-ball.svg	Baseball Ball	solid	\N	t	2025-11-20 02:05:43	2025-11-20 10:35:30	public
1053	fontawesome	battery-5	icons/fontawesome/solid/battery-5.svg	Battery 5	solid	\N	t	2025-11-20 02:05:44	2025-11-20 10:35:31	public
1063	fontawesome	beer-mug-empty	icons/fontawesome/solid/beer-mug-empty.svg	Beer Mug Empty	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1075	fontawesome	bitcoin-sign	icons/fontawesome/solid/bitcoin-sign.svg	Bitcoin Sign	solid	\N	t	2025-11-20 02:05:45	2025-11-20 10:35:32	public
1087	fontawesome	book-atlas	icons/fontawesome/solid/book-atlas.svg	Book Atlas	solid	\N	t	2025-11-20 02:05:46	2025-11-20 10:35:33	public
1095	fontawesome	book-quran	icons/fontawesome/solid/book-quran.svg	Book Quran	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:33	public
1105	fontawesome	bore-hole	icons/fontawesome/solid/bore-hole.svg	Bore Hole	solid	\N	t	2025-11-20 02:05:47	2025-11-20 10:35:34	public
1116	fontawesome	boxes-packing	icons/fontawesome/solid/boxes-packing.svg	Boxes Packing	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1124	fontawesome	bridge-circle-exclamation	icons/fontawesome/solid/bridge-circle-exclamation.svg	Bridge Circle Exclamation	solid	\N	t	2025-11-20 02:05:48	2025-11-20 10:35:35	public
1137	fontawesome	bug-slash	icons/fontawesome/solid/bug-slash.svg	Bug Slash	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1142	fontawesome	building-circle-exclamation	icons/fontawesome/solid/building-circle-exclamation.svg	Building Circle Exclamation	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1143	fontawesome	building-circle-xmark	icons/fontawesome/solid/building-circle-xmark.svg	Building Circle Xmark	solid	\N	t	2025-11-20 02:05:49	2025-11-20 10:35:36	public
1144	fontawesome	building-columns	icons/fontawesome/solid/building-columns.svg	Building Columns	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:36	public
1157	fontawesome	burst	icons/fontawesome/solid/burst.svg	Burst	solid	\N	t	2025-11-20 02:05:50	2025-11-20 10:35:37	public
1168	fontawesome	calculator	icons/fontawesome/solid/calculator.svg	Calculator	solid	\N	t	2025-11-20 02:05:51	2025-11-20 10:35:38	public
1176	fontawesome	calendar-week	icons/fontawesome/solid/calendar-week.svg	Calendar Week	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:38	public
1189	fontawesome	car-battery	icons/fontawesome/solid/car-battery.svg	Car Battery	solid	\N	t	2025-11-20 02:05:52	2025-11-20 10:35:39	public
1201	fontawesome	caret-square-down	icons/fontawesome/solid/caret-square-down.svg	Caret Square Down	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1204	fontawesome	caret-square-up	icons/fontawesome/solid/caret-square-up.svg	Caret Square Up	solid	\N	t	2025-11-20 02:05:53	2025-11-20 10:35:40	public
1213	fontawesome	cash-register	icons/fontawesome/solid/cash-register.svg	Cash Register	solid	\N	t	2025-11-20 02:05:54	2025-11-20 10:35:41	public
1225	fontawesome	champagne-glasses	icons/fontawesome/solid/champagne-glasses.svg	Champagne Glasses	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:41	public
1236	fontawesome	check-double	icons/fontawesome/solid/check-double.svg	Check Double	solid	\N	t	2025-11-20 02:05:55	2025-11-20 10:35:42	public
1248	fontawesome	chess	icons/fontawesome/solid/chess.svg	Chess	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1255	fontawesome	chevron-right	icons/fontawesome/solid/chevron-right.svg	Chevron Right	solid	\N	t	2025-11-20 02:05:56	2025-11-20 10:35:43	public
1257	fontawesome	child-combatant	icons/fontawesome/solid/child-combatant.svg	Child Combatant	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:43	public
1258	fontawesome	child-dress	icons/fontawesome/solid/child-dress.svg	Child Dress	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:43	public
1266	fontawesome	circle-arrow-right	icons/fontawesome/solid/circle-arrow-right.svg	Circle Arrow Right	solid	\N	t	2025-11-20 02:05:57	2025-11-20 10:35:44	public
1275	fontawesome	circle-down	icons/fontawesome/solid/circle-down.svg	Circle Down	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:44	public
1285	fontawesome	circle-play	icons/fontawesome/solid/circle-play.svg	Circle Play	solid	\N	t	2025-11-20 02:05:58	2025-11-20 10:35:45	public
1296	fontawesome	clapperboard	icons/fontawesome/solid/clapperboard.svg	Clapperboard	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1304	fontawesome	clock-rotate-left	icons/fontawesome/solid/clock-rotate-left.svg	Clock Rotate Left	solid	\N	t	2025-11-20 02:05:59	2025-11-20 10:35:46	public
1312	fontawesome	cloud-download-alt	icons/fontawesome/solid/cloud-download-alt.svg	Cloud Download Alt	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1318	fontawesome	cloud-showers-heavy	icons/fontawesome/solid/cloud-showers-heavy.svg	Cloud Showers Heavy	solid	\N	t	2025-11-20 02:06:00	2025-11-20 10:35:47	public
1329	fontawesome	code-commit	icons/fontawesome/solid/code-commit.svg	Code Commit	solid	\N	t	2025-11-20 02:06:01	2025-11-20 10:35:48	public
1341	fontawesome	comment-alt	icons/fontawesome/solid/comment-alt.svg	Comment Alt	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:48	public
1350	fontawesome	comments-dollar	icons/fontawesome/solid/comments-dollar.svg	Comments Dollar	solid	\N	t	2025-11-20 02:06:02	2025-11-20 10:35:49	public
1360	fontawesome	concierge-bell	icons/fontawesome/solid/concierge-bell.svg	Concierge Bell	solid	\N	t	2025-11-20 02:06:03	2025-11-20 10:35:50	public
1369	fontawesome	credit-card-alt	icons/fontawesome/solid/credit-card-alt.svg	Credit Card Alt	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:50	public
1372	fontawesome	crop-simple	icons/fontawesome/solid/crop-simple.svg	Crop Simple	solid	\N	t	2025-11-20 02:06:04	2025-11-20 10:35:50	public
1386	fontawesome	dashboard	icons/fontawesome/solid/dashboard.svg	Dashboard	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:51	public
1397	fontawesome	diagram-next	icons/fontawesome/solid/diagram-next.svg	Diagram Next	solid	\N	t	2025-11-20 02:06:05	2025-11-20 10:35:52	public
1407	fontawesome	dice-one	icons/fontawesome/solid/dice-one.svg	Dice One	solid	\N	t	2025-11-20 02:06:06	2025-11-20 10:35:52	public
1421	fontawesome	dollar-sign	icons/fontawesome/solid/dollar-sign.svg	Dollar Sign	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:53	public
1428	fontawesome	door-closed	icons/fontawesome/solid/door-closed.svg	Door Closed	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:54	public
1430	fontawesome	dot-circle	icons/fontawesome/solid/dot-circle.svg	Dot Circle	solid	\N	t	2025-11-20 02:06:07	2025-11-20 10:35:54	public
1439	fontawesome	droplet-slash	icons/fontawesome/solid/droplet-slash.svg	Droplet Slash	solid	\N	t	2025-11-20 02:06:08	2025-11-20 10:35:54	public
1452	fontawesome	earth-america	icons/fontawesome/solid/earth-america.svg	Earth America	solid	\N	t	2025-11-20 02:06:09	2025-11-20 10:35:55	public
1466	fontawesome	envelope-circle-check	icons/fontawesome/solid/envelope-circle-check.svg	Envelope Circle Check	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:56	public
1479	fontawesome	exchange	icons/fontawesome/solid/exchange.svg	Exchange	solid	\N	t	2025-11-20 02:06:10	2025-11-20 10:35:57	public
1487	fontawesome	external-link-alt	icons/fontawesome/solid/external-link-alt.svg	External Link Alt	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1491	fontawesome	eye-dropper-empty	icons/fontawesome/solid/eye-dropper-empty.svg	Eye Dropper Empty	solid	\N	t	2025-11-20 02:06:11	2025-11-20 10:35:57	public
1504	fontawesome	face-grin-beam-sweat	icons/fontawesome/solid/face-grin-beam-sweat.svg	Face Grin Beam Sweat	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:58	public
1511	fontawesome	face-grin-tongue-squint	icons/fontawesome/solid/face-grin-tongue-squint.svg	Face Grin Tongue Squint	solid	\N	t	2025-11-20 02:06:12	2025-11-20 10:35:59	public
1522	fontawesome	face-laugh-wink	icons/fontawesome/solid/face-laugh-wink.svg	Face Laugh Wink	solid	\N	t	2025-11-20 02:06:13	2025-11-20 10:35:59	public
1532	fontawesome	face-surprise	icons/fontawesome/solid/face-surprise.svg	Face Surprise	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1545	fontawesome	ferry	icons/fontawesome/solid/ferry.svg	Ferry	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1546	fontawesome	fighter-jet	icons/fontawesome/solid/fighter-jet.svg	Fighter Jet	solid	\N	t	2025-11-20 02:06:14	2025-11-20 10:36:00	public
1554	fontawesome	file-circle-minus	icons/fontawesome/solid/file-circle-minus.svg	File Circle Minus	solid	\N	t	2025-11-20 02:06:15	2025-11-20 10:36:01	public
1565	fontawesome	file-export	icons/fontawesome/solid/file-export.svg	File Export	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1573	fontawesome	file-medical-alt	icons/fontawesome/solid/file-medical-alt.svg	File Medical Alt	solid	\N	t	2025-11-20 02:06:16	2025-11-20 10:36:02	public
1584	fontawesome	file-waveform	icons/fontawesome/solid/file-waveform.svg	File Waveform	solid	\N	t	2025-11-20 02:06:17	2025-11-20 10:36:03	public
1596	fontawesome	fingerprint	icons/fontawesome/solid/fingerprint.svg	Fingerprint	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:03	public
1601	fontawesome	fire-flame-simple	icons/fontawesome/solid/fire-flame-simple.svg	Fire Flame Simple	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1607	fontawesome	flag-checkered	icons/fontawesome/solid/flag-checkered.svg	Flag Checkered	solid	\N	t	2025-11-20 02:06:18	2025-11-20 10:36:04	public
1619	fontawesome	folder-plus	icons/fontawesome/solid/folder-plus.svg	Folder Plus	solid	\N	t	2025-11-20 02:06:19	2025-11-20 10:36:05	public
1628	fontawesome	forward-fast	icons/fontawesome/solid/forward-fast.svg	Forward Fast	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:05	public
1641	fontawesome	gauge-high	icons/fontawesome/solid/gauge-high.svg	Gauge High	solid	\N	t	2025-11-20 02:06:20	2025-11-20 10:36:06	public
1654	fontawesome	gift	icons/fontawesome/solid/gift.svg	Gift	solid	\N	t	2025-11-20 02:06:21	2025-11-20 10:36:07	public
1659	fontawesome	glass-water-droplet	icons/fontawesome/solid/glass-water-droplet.svg	Glass Water Droplet	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:07	public
1664	fontawesome	globe-americas	icons/fontawesome/solid/globe-americas.svg	Globe Americas	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1675	fontawesome	grid-horizontal	icons/fontawesome/solid/grid-horizontal.svg	Grid Horizontal	solid	\N	t	2025-11-20 02:06:22	2025-11-20 10:36:08	public
1686	fontawesome	grin-tongue-squint	icons/fontawesome/solid/grin-tongue-squint.svg	Grin Tongue Squint	solid	\N	t	2025-11-20 02:06:23	2025-11-20 10:36:09	public
1696	fontawesome	group-arrows-rotate	icons/fontawesome/solid/group-arrows-rotate.svg	Group Arrows Rotate	solid	\N	t	2025-11-20 02:06:24	2025-11-20 10:36:10	public
1708	fontawesome	hand-holding-dollar	icons/fontawesome/solid/hand-holding-dollar.svg	Hand Holding Dollar	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:10	public
1715	fontawesome	hand-holding	icons/fontawesome/solid/hand-holding.svg	Hand Holding	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1722	fontawesome	hand-point-right	icons/fontawesome/solid/hand-point-right.svg	Hand Point Right	solid	\N	t	2025-11-20 02:06:25	2025-11-20 10:36:11	public
1731	fontawesome	hands-american-sign-language-interpreting	icons/fontawesome/solid/hands-american-sign-language-interpreting.svg	Hands American Sign Language Interpreting	solid	\N	t	2025-11-20 02:06:26	2025-11-20 10:36:12	public
1743	fontawesome	handshake-alt-slash	icons/fontawesome/solid/handshake-alt-slash.svg	Handshake Alt Slash	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:12	public
1755	fontawesome	hat-cowboy-side	icons/fontawesome/solid/hat-cowboy-side.svg	Hat Cowboy Side	solid	\N	t	2025-11-20 02:06:27	2025-11-20 10:36:13	public
1764	fontawesome	head-side-virus	icons/fontawesome/solid/head-side-virus.svg	Head Side Virus	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1770	fontawesome	headset	icons/fontawesome/solid/headset.svg	Headset	solid	\N	t	2025-11-20 02:06:28	2025-11-20 10:36:14	public
1774	fontawesome	heart-circle-exclamation	icons/fontawesome/solid/heart-circle-exclamation.svg	Heart Circle Exclamation	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:14	public
1785	fontawesome	helmet-safety	icons/fontawesome/solid/helmet-safety.svg	Helmet Safety	solid	\N	t	2025-11-20 02:06:29	2025-11-20 10:36:15	public
1796	fontawesome	history	icons/fontawesome/solid/history.svg	History	solid	\N	t	2025-11-20 02:06:30	2025-11-20 10:36:16	public
1806	fontawesome	hospital-alt	icons/fontawesome/solid/hospital-alt.svg	Hospital Alt	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:16	public
1815	fontawesome	hourglass-1	icons/fontawesome/solid/hourglass-1.svg	Hourglass 1	solid	\N	t	2025-11-20 02:06:31	2025-11-20 10:36:17	public
1823	fontawesome	house-chimney-crack	icons/fontawesome/solid/house-chimney-crack.svg	House Chimney Crack	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:17	public
1826	fontawesome	house-chimney-window	icons/fontawesome/solid/house-chimney-window.svg	House Chimney Window	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:17	public
1835	fontawesome	house-flood-water-circle-arrow-right	icons/fontawesome/solid/house-flood-water-circle-arrow-right.svg	House Flood Water Circle Arrow Right	solid	\N	t	2025-11-20 02:06:32	2025-11-20 10:36:18	public
1844	fontawesome	house-signal	icons/fontawesome/solid/house-signal.svg	House Signal	solid	\N	t	2025-11-20 02:06:33	2025-11-20 10:36:18	public
1857	fontawesome	id-card-alt	icons/fontawesome/solid/id-card-alt.svg	Id Card Alt	solid	\N	t	2025-11-20 02:06:34	2025-11-20 10:36:19	public
1868	fontawesome	indian-rupee	icons/fontawesome/solid/indian-rupee.svg	Indian Rupee	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:20	public
1881	fontawesome	jet-fighter	icons/fontawesome/solid/jet-fighter.svg	Jet Fighter	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:21	public
1882	fontawesome	joint	icons/fontawesome/solid/joint.svg	Joint	solid	\N	t	2025-11-20 02:06:35	2025-11-20 10:36:21	public
1889	fontawesome	keyboard	icons/fontawesome/solid/keyboard.svg	Keyboard	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:21	public
1900	fontawesome	ladder-water	icons/fontawesome/solid/ladder-water.svg	Ladder Water	solid	\N	t	2025-11-20 02:06:36	2025-11-20 10:36:22	public
1910	fontawesome	laptop-medical	icons/fontawesome/solid/laptop-medical.svg	Laptop Medical	solid	\N	t	2025-11-20 02:06:37	2025-11-20 10:36:22	public
1923	fontawesome	less-than-equal	icons/fontawesome/solid/less-than-equal.svg	Less Than Equal	solid	\N	t	2025-11-20 02:06:38	2025-11-20 10:36:23	public
1936	fontawesome	list-1-2	icons/fontawesome/solid/list-1-2.svg	List 1 2	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1940	fontawesome	list-numeric	icons/fontawesome/solid/list-numeric.svg	List Numeric	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:24	public
1947	fontawesome	location-crosshairs	icons/fontawesome/solid/location-crosshairs.svg	Location Crosshairs	solid	\N	t	2025-11-20 02:06:39	2025-11-20 10:36:25	public
1958	fontawesome	long-arrow-alt-up	icons/fontawesome/solid/long-arrow-alt-up.svg	Long Arrow Alt Up	solid	\N	t	2025-11-20 02:06:40	2025-11-20 10:36:25	public
1968	fontawesome	magic-wand-sparkles	icons/fontawesome/solid/magic-wand-sparkles.svg	Magic Wand Sparkles	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1976	fontawesome	magnifying-glass-plus	icons/fontawesome/solid/magnifying-glass-plus.svg	Magnifying Glass Plus	solid	\N	t	2025-11-20 02:06:41	2025-11-20 10:36:26	public
1990	fontawesome	map-pin	icons/fontawesome/solid/map-pin.svg	Map Pin	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:27	public
1995	fontawesome	mars-and-venus	icons/fontawesome/solid/mars-and-venus.svg	Mars And Venus	solid	\N	t	2025-11-20 02:06:42	2025-11-20 10:36:28	public
1998	fontawesome	mars-stroke-right	icons/fontawesome/solid/mars-stroke-right.svg	Mars Stroke Right	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2007	fontawesome	mask-ventilator	icons/fontawesome/solid/mask-ventilator.svg	Mask Ventilator	solid	\N	t	2025-11-20 02:06:43	2025-11-20 10:36:28	public
2021	fontawesome	meteor	icons/fontawesome/solid/meteor.svg	Meteor	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:29	public
2027	fontawesome	microphone-slash	icons/fontawesome/solid/microphone-slash.svg	Microphone Slash	solid	\N	t	2025-11-20 02:06:44	2025-11-20 10:36:30	public
2040	fontawesome	mobile-phone	icons/fontawesome/solid/mobile-phone.svg	Mobile Phone	solid	\N	t	2025-11-20 02:06:45	2025-11-20 10:36:30	public
2049	fontawesome	money-bill-transfer	icons/fontawesome/solid/money-bill-transfer.svg	Money Bill Transfer	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2051	fontawesome	money-bill-wave-alt	icons/fontawesome/solid/money-bill-wave-alt.svg	Money Bill Wave Alt	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2057	fontawesome	money-check-dollar	icons/fontawesome/solid/money-check-dollar.svg	Money Check Dollar	solid	\N	t	2025-11-20 02:06:46	2025-11-20 10:36:31	public
2069	fontawesome	mountain-sun	icons/fontawesome/solid/mountain-sun.svg	Mountain Sun	solid	\N	t	2025-11-20 02:06:47	2025-11-20 10:36:32	public
2083	fontawesome	newspaper	icons/fontawesome/solid/newspaper.svg	Newspaper	solid	\N	t	2025-11-20 02:06:48	2025-11-20 10:36:33	public
2094	fontawesome	oil-well	icons/fontawesome/solid/oil-well.svg	Oil Well	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2106	fontawesome	paper-plane	icons/fontawesome/solid/paper-plane.svg	Paper Plane	solid	\N	t	2025-11-20 02:06:49	2025-11-20 10:36:34	public
2109	fontawesome	paragraph	icons/fontawesome/solid/paragraph.svg	Paragraph	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:34	public
2117	fontawesome	peace	icons/fontawesome/solid/peace.svg	Peace	solid	\N	t	2025-11-20 02:06:50	2025-11-20 10:36:35	public
2127	fontawesome	pencil-ruler	icons/fontawesome/solid/pencil-ruler.svg	Pencil Ruler	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2137	fontawesome	people-pulling	icons/fontawesome/solid/people-pulling.svg	People Pulling	solid	\N	t	2025-11-20 02:06:51	2025-11-20 10:36:36	public
2144	fontawesome	person-arrow-up-from-line	icons/fontawesome/solid/person-arrow-up-from-line.svg	Person Arrow Up From Line	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2154	fontawesome	person-circle-plus	icons/fontawesome/solid/person-circle-plus.svg	Person Circle Plus	solid	\N	t	2025-11-20 02:06:52	2025-11-20 10:36:37	public
2162	fontawesome	person-falling-burst	icons/fontawesome/solid/person-falling-burst.svg	Person Falling Burst	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2164	fontawesome	person-half-dress	icons/fontawesome/solid/person-half-dress.svg	Person Half Dress	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2167	fontawesome	person-military-pointing	icons/fontawesome/solid/person-military-pointing.svg	Person Military Pointing	solid	\N	t	2025-11-20 02:06:53	2025-11-20 10:36:38	public
2176	fontawesome	person-skating	icons/fontawesome/solid/person-skating.svg	Person Skating	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:38	public
2182	fontawesome	person-walking-arrow-loop-left	icons/fontawesome/solid/person-walking-arrow-loop-left.svg	Person Walking Arrow Loop Left	solid	\N	t	2025-11-20 02:06:54	2025-11-20 10:36:39	public
2193	fontawesome	phone-slash	icons/fontawesome/solid/phone-slash.svg	Phone Slash	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:39	public
2203	fontawesome	ping-pong-paddle-ball	icons/fontawesome/solid/ping-pong-paddle-ball.svg	Ping Pong Paddle Ball	solid	\N	t	2025-11-20 02:06:55	2025-11-20 10:36:40	public
2212	fontawesome	plane-slash	icons/fontawesome/solid/plane-slash.svg	Plane Slash	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2218	fontawesome	play	icons/fontawesome/solid/play.svg	Play	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2220	fontawesome	plug-circle-check	icons/fontawesome/solid/plug-circle-check.svg	Plug Circle Check	solid	\N	t	2025-11-20 02:06:56	2025-11-20 10:36:41	public
2233	fontawesome	poo-bolt	icons/fontawesome/solid/poo-bolt.svg	Poo Bolt	solid	\N	t	2025-11-20 02:06:57	2025-11-20 10:36:42	public
2242	fontawesome	prescription-bottle-alt	icons/fontawesome/solid/prescription-bottle-alt.svg	Prescription Bottle Alt	solid	\N	t	2025-11-20 02:06:58	2025-11-20 10:36:42	public
2255	fontawesome	question	icons/fontawesome/solid/question.svg	Question	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:43	public
2264	fontawesome	radiation-alt	icons/fontawesome/solid/radiation-alt.svg	Radiation Alt	solid	\N	t	2025-11-20 02:06:59	2025-11-20 10:36:44	public
2275	fontawesome	rectangle-xmark	icons/fontawesome/solid/rectangle-xmark.svg	Rectangle Xmark	solid	\N	t	2025-11-20 02:07:00	2025-11-20 10:36:44	public
2286	fontawesome	reply	icons/fontawesome/solid/reply.svg	Reply	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:45	public
2297	fontawesome	road-barrier	icons/fontawesome/solid/road-barrier.svg	Road Barrier	solid	\N	t	2025-11-20 02:07:01	2025-11-20 10:36:46	public
2307	fontawesome	rod-asclepius	icons/fontawesome/solid/rod-asclepius.svg	Rod Asclepius	solid	\N	t	2025-11-20 02:07:02	2025-11-20 10:36:46	public
2317	fontawesome	rss-square	icons/fontawesome/solid/rss-square.svg	Rss Square	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:47	public
2328	fontawesome	rupee-sign	icons/fontawesome/solid/rupee-sign.svg	Rupee Sign	solid	\N	t	2025-11-20 02:07:03	2025-11-20 10:36:48	public
2333	fontawesome	sack-xmark	icons/fontawesome/solid/sack-xmark.svg	Sack Xmark	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2337	fontawesome	satellite-dish	icons/fontawesome/solid/satellite-dish.svg	Satellite Dish	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2344	fontawesome	school-circle-exclamation	icons/fontawesome/solid/school-circle-exclamation.svg	School Circle Exclamation	solid	\N	t	2025-11-20 02:07:04	2025-11-20 10:36:48	public
2357	fontawesome	search-minus	icons/fontawesome/solid/search-minus.svg	Search Minus	solid	\N	t	2025-11-20 02:07:05	2025-11-20 10:36:49	public
2367	fontawesome	share-from-square	icons/fontawesome/solid/share-from-square.svg	Share From Square	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:50	public
2380	fontawesome	shield-halved	icons/fontawesome/solid/shield-halved.svg	Shield Halved	solid	\N	t	2025-11-20 02:07:06	2025-11-20 10:36:51	public
2390	fontawesome	shop	icons/fontawesome/solid/shop.svg	Shop	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2392	fontawesome	shopping-basket	icons/fontawesome/solid/shopping-basket.svg	Shopping Basket	solid	\N	t	2025-11-20 02:07:07	2025-11-20 10:36:51	public
2402	fontawesome	sign-language	icons/fontawesome/solid/sign-language.svg	Sign Language	solid	\N	t	2025-11-20 02:07:08	2025-11-20 10:36:52	public
2414	fontawesome	single-quote-right	icons/fontawesome/solid/single-quote-right.svg	Single Quote Right	solid	\N	t	2025-11-20 02:07:09	2025-11-20 10:36:53	public
2430	fontawesome	smoking-ban	icons/fontawesome/solid/smoking-ban.svg	Smoking Ban	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2441	fontawesome	sort-alpha-asc	icons/fontawesome/solid/sort-alpha-asc.svg	Sort Alpha Asc	solid	\N	t	2025-11-20 02:07:10	2025-11-20 10:36:54	public
2448	fontawesome	sort-amount-desc	icons/fontawesome/solid/sort-amount-desc.svg	Sort Amount Desc	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2450	fontawesome	sort-amount-down	icons/fontawesome/solid/sort-amount-down.svg	Sort Amount Down	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2459	fontawesome	sort-numeric-down	icons/fontawesome/solid/sort-numeric-down.svg	Sort Numeric Down	solid	\N	t	2025-11-20 02:07:11	2025-11-20 10:36:55	public
2472	fontawesome	spoon	icons/fontawesome/solid/spoon.svg	Spoon	solid	\N	t	2025-11-20 02:07:12	2025-11-20 10:36:56	public
2478	fontawesome	square-caret-down	icons/fontawesome/solid/square-caret-down.svg	Square Caret Down	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:56	public
2490	fontawesome	square-person-confined	icons/fontawesome/solid/square-person-confined.svg	Square Person Confined	solid	\N	t	2025-11-20 02:07:13	2025-11-20 10:36:57	public
2497	fontawesome	square-root-variable	icons/fontawesome/solid/square-root-variable.svg	Square Root Variable	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2503	fontawesome	square	icons/fontawesome/solid/square.svg	Square	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2504	fontawesome	staff-aesculapius	icons/fontawesome/solid/staff-aesculapius.svg	Staff Aesculapius	solid	\N	t	2025-11-20 02:07:14	2025-11-20 10:36:58	public
2516	fontawesome	step-backward	icons/fontawesome/solid/step-backward.svg	Step Backward	solid	\N	t	2025-11-20 02:07:15	2025-11-20 10:36:59	public
2527	fontawesome	store-slash	icons/fontawesome/solid/store-slash.svg	Store Slash	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:36:59	public
2536	fontawesome	suitcase-medical	icons/fontawesome/solid/suitcase-medical.svg	Suitcase Medical	solid	\N	t	2025-11-20 02:07:16	2025-11-20 10:37:00	public
2549	fontawesome	syringe	icons/fontawesome/solid/syringe.svg	Syringe	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2555	fontawesome	table-cells-row-unlock	icons/fontawesome/solid/table-cells-row-unlock.svg	Table Cells Row Unlock	solid	\N	t	2025-11-20 02:07:17	2025-11-20 10:37:01	public
2560	fontawesome	table-tennis	icons/fontawesome/solid/table-tennis.svg	Table Tennis	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:01	public
2568	fontawesome	tachograph-digital	icons/fontawesome/solid/tachograph-digital.svg	Tachograph Digital	solid	\N	t	2025-11-20 02:07:18	2025-11-20 10:37:02	public
2579	fontawesome	tarp-droplet	icons/fontawesome/solid/tarp-droplet.svg	Tarp Droplet	solid	\N	t	2025-11-20 02:07:19	2025-11-20 10:37:03	public
2591	fontawesome	temperature-3	icons/fontawesome/solid/temperature-3.svg	Temperature 3	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:03	public
2599	fontawesome	temperature-high	icons/fontawesome/solid/temperature-high.svg	Temperature High	solid	\N	t	2025-11-20 02:07:20	2025-11-20 10:37:04	public
2606	fontawesome	tent-arrow-down-to-line	icons/fontawesome/solid/tent-arrow-down-to-line.svg	Tent Arrow Down To Line	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:04	public
2615	fontawesome	text-width	icons/fontawesome/solid/text-width.svg	Text Width	solid	\N	t	2025-11-20 02:07:21	2025-11-20 10:37:05	public
2623	fontawesome	thermometer-3	icons/fontawesome/solid/thermometer-3.svg	Thermometer 3	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:05	public
2629	fontawesome	thermometer-three-quarters	icons/fontawesome/solid/thermometer-three-quarters.svg	Thermometer Three Quarters	solid	\N	t	2025-11-20 02:07:22	2025-11-20 10:37:06	public
2644	fontawesome	times-square	icons/fontawesome/solid/times-square.svg	Times Square	solid	\N	t	2025-11-20 02:07:23	2025-11-20 10:37:06	public
2655	fontawesome	toilet-portable	icons/fontawesome/solid/toilet-portable.svg	Toilet Portable	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:07	public
2666	fontawesome	tower-observation	icons/fontawesome/solid/tower-observation.svg	Tower Observation	solid	\N	t	2025-11-20 02:07:24	2025-11-20 10:37:08	public
2671	fontawesome	train-subway	icons/fontawesome/solid/train-subway.svg	Train Subway	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2678	fontawesome	trash-arrow-up	icons/fontawesome/solid/trash-arrow-up.svg	Trash Arrow Up	solid	\N	t	2025-11-20 02:07:25	2025-11-20 10:37:08	public
2687	fontawesome	triangle-exclamation	icons/fontawesome/solid/triangle-exclamation.svg	Triangle Exclamation	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:09	public
2698	fontawesome	truck-medical	icons/fontawesome/solid/truck-medical.svg	Truck Medical	solid	\N	t	2025-11-20 02:07:26	2025-11-20 10:37:10	public
2708	fontawesome	turkish-lira-sign	icons/fontawesome/solid/turkish-lira-sign.svg	Turkish Lira Sign	solid	\N	t	2025-11-20 02:07:27	2025-11-20 10:37:10	public
2724	fontawesome	unlock-keyhole	icons/fontawesome/solid/unlock-keyhole.svg	Unlock Keyhole	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2728	fontawesome	up-down	icons/fontawesome/solid/up-down.svg	Up Down	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:11	public
2730	fontawesome	up-right-and-down-left-from-center	icons/fontawesome/solid/up-right-and-down-left-from-center.svg	Up Right And Down Left From Center	solid	\N	t	2025-11-20 02:07:28	2025-11-20 10:37:12	public
2747	fontawesome	user-injured	icons/fontawesome/solid/user-injured.svg	User Injured	solid	\N	t	2025-11-20 02:07:29	2025-11-20 10:37:13	public
2759	fontawesome	user-slash	icons/fontawesome/solid/user-slash.svg	User Slash	solid	\N	t	2025-11-20 02:07:30	2025-11-20 10:37:13	public
2770	fontawesome	users-rectangle	icons/fontawesome/solid/users-rectangle.svg	Users Rectangle	solid	\N	t	2025-11-20 02:07:31	2025-11-20 10:37:14	public
2780	fontawesome	vector-polygon	icons/fontawesome/solid/vector-polygon.svg	Vector Polygon	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2785	fontawesome	vest	icons/fontawesome/solid/vest.svg	Vest	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2794	fontawesome	virus-covid-slash	icons/fontawesome/solid/virus-covid-slash.svg	Virus Covid Slash	solid	\N	t	2025-11-20 02:07:32	2025-11-20 10:37:15	public
2803	fontawesome	volume-control-phone	icons/fontawesome/solid/volume-control-phone.svg	Volume Control Phone	solid	\N	t	2025-11-20 02:07:33	2025-11-20 10:37:16	public
2818	fontawesome	wand-magic-sparkles	icons/fontawesome/solid/wand-magic-sparkles.svg	Wand Magic Sparkles	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2828	fontawesome	weight-scale	icons/fontawesome/solid/weight-scale.svg	Weight Scale	solid	\N	t	2025-11-20 02:07:34	2025-11-20 10:37:17	public
2838	fontawesome	wifi-strong	icons/fontawesome/solid/wifi-strong.svg	Wifi Strong	solid	\N	t	2025-11-20 02:07:35	2025-11-20 10:37:18	public
2853	fontawesome	x-ray	icons/fontawesome/solid/x-ray.svg	X Ray	solid	\N	t	2025-11-20 02:07:36	2025-11-20 10:37:19	public
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: label_transaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.label_transaction (id, transaction_id, label_id, created_at, updated_at) FROM stdin;
1	1	2	2025-11-20 02:07:39	2025-11-20 02:07:39
2	2	3	2025-11-20 02:07:40	2025-11-20 02:07:40
3	3	1	2025-11-20 02:07:40	2025-11-20 02:07:40
4	4	2	2025-11-20 02:07:40	2025-11-20 02:07:40
5	28	4	2025-11-20 11:20:27	2025-11-20 11:20:27
6	29	4	2025-11-20 11:20:44	2025-11-20 11:20:44
7	30	4	2025-11-20 11:21:46	2025-11-20 11:21:46
8	31	4	2025-11-20 11:23:15	2025-11-20 11:23:15
9	37	4	2025-11-20 11:30:43	2025-11-20 11:30:43
10	75	4	2025-11-28 13:58:52	2025-11-28 13:58:52
\.


--
-- Data for Name: labels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.labels (id, user_id, name, slug, color, description, created_at, updated_at) FROM stdin;
1	2	Business	business	#b8606e	\N	2025-11-20 02:07:39	2025-11-20 02:07:39
2	2	Personal	personal	#09cd1b	\N	2025-11-20 02:07:39	2025-11-20 02:07:39
3	2	Recurring	recurring	#ac25dc	\N	2025-11-20 02:07:39	2025-11-20 02:07:39
4	3	University 	university	#DC2626	\N	2025-11-20 10:16:31	2025-11-20 10:16:31
\.


--
-- Data for Name: memo_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.memo_entries (id, memo_group_id, date_label, content, created_at, updated_at, file_path, file_name, mime_type) FROM stdin;
1	1	15 November 2024	Ganti oli mesin, oli garda, kampas rem belakang	2025-11-20 11:58:43	2025-11-20 11:58:43	\N	\N	\N
2	1	15 Maret 2025	Ganti oli	2025-11-20 11:58:56	2025-11-20 11:58:56	\N	\N	\N
3	1	1 Agustus 2025	Service, Ganti oli, Ganti rem depan	2025-11-20 11:59:17	2025-11-20 11:59:17	\N	\N	\N
4	2	15 November 2024	Ganti oli mesin dan transmisi	2025-11-20 11:59:38	2025-11-20 11:59:38	\N	\N	\N
5	2	10 April 2025	Ganti filter dan benerin power window	2025-11-20 11:59:57	2025-11-20 11:59:57	\N	\N	\N
6	3	26 November 2024	Cuci AC	2025-11-20 12:00:10	2025-11-20 12:00:10	\N	\N	\N
7	3	19 November 2025	Cuci AC	2025-11-20 12:00:32	2025-11-20 12:00:32	\N	\N	\N
8	4	26 November 2024	Cuci AC	2025-11-20 12:00:48	2025-11-20 12:00:48	\N	\N	\N
9	4	19 November 2025	Cuci AC	2025-11-20 12:00:59	2025-11-20 12:00:59	\N	\N	\N
10	5	10 Desember 2024	-	2025-11-20 12:01:15	2025-11-20 12:01:15	\N	\N	\N
11	5	24 Januari 2025	-	2025-11-20 12:01:25	2025-11-20 12:01:25	\N	\N	\N
12	5	13 April 2025	-	2025-11-20 12:01:34	2025-11-20 12:01:34	\N	\N	\N
13	5	7 Juni 2025	-	2025-11-20 12:01:42	2025-11-20 12:01:42	\N	\N	\N
14	5	14 September 2025	-	2025-11-20 12:01:51	2025-11-20 12:01:51	\N	\N	\N
15	6	14 September 2025	-	2025-11-20 12:02:22	2025-11-20 12:02:22	\N	\N	\N
16	7	16 Novemebr 2025	-	2025-11-20 12:02:41	2025-11-20 12:02:41	\N	\N	\N
19	10	Test	Test	2025-11-22 07:29:50	2025-11-22 07:29:50	\N	\N	\N
20	10	Test	Test	2025-11-22 08:13:19	2025-11-22 08:13:19	\N	\N	\N
41	24	#1 	Selasa/07-10-2025	2025-11-29 18:56:21	2025-11-29 18:56:21	\N	\N	\N
21	10	Test 123	-	2025-11-22 08:13:40	2025-11-22 08:14:14	http://127.0.0.1:8000/storage/memos/2/iheELQ4MkvFD1eJF4RyHtDnjwCnOjJyAVV1cyl7Y.png	google drive.png	image/png
22	10	Test	Test	2025-11-22 08:14:34	2025-11-22 08:15:00	http://127.0.0.1:8000/storage/memos/2/UEIwPPRhg1c0FDgUQWyNz86roRUFKhflXlw6MUYP.pdf	transactions-20251120012452.pdf	application/pdf
42	24	#2	Rabu/29-10-2025	2025-11-29 18:56:35	2025-11-29 18:56:35	\N	\N	\N
26	19	Test	Test	2025-11-22 09:42:33	2025-11-22 09:42:33	\N	\N	\N
27	13	T	T	2025-11-22 10:17:23	2025-11-22 10:17:23	\N	\N	\N
28	18	Tes	Test	2025-11-22 10:22:18	2025-11-22 10:22:18	http://127.0.0.1:8000/storage/memos/2/gpkTARHysr6g39n0wW2xsXs1ZeS6M4sCBchRRFHP.png	google drive.png	image/png
29	18	Tes	TEst	2025-11-22 10:24:23	2025-11-22 10:24:23	http://127.0.0.1:8000/storage/memos/2/JnVzuQjbuA9YLuLEpcp85g4yOeM5mFIgSr9IHJoZ.png	Flazz.png	image/png
43	24	#3 	Jumat/21-11-2025	2025-11-29 18:56:46	2025-11-29 18:57:05	\N	\N	\N
30	18	Test Baru	Test	2025-11-22 10:29:30	2025-11-22 10:33:44	http://127.0.0.1:8000/storage/memos/2/594HLUlzCquZNABjF2Sh4zYElN0njNFoMi0ozCdV.png	Screenshot 2025-09-22 230105.png	image/png
34	5	23 November 2025	Captain Barber shop Cimahi (85K)	2025-11-23 12:18:32	2025-11-23 12:18:32	https://storage.googleapis.com/tracker-expenses/memos/3/LIqoaQoJDHoaoGEOEV4I7aFt0ia8Xa1yUucff979.jpg	WhatsApp Image 2025-11-23 at 12.16.14_6e66b53a.jpg	image/jpeg
45	25	Jam minimum responsi	16 Jam (8x Pertemuan)	2025-11-29 18:58:20	2025-11-29 18:58:20	\N	\N	\N
35	21	Prodi IT	CT 4x, WEBPRO IT03 1x, WEBPRO IT04 1x, PBO 1x\n	2025-11-25 22:11:50	2025-11-25 22:14:14	https://storage.googleapis.com/tracker-expenses/memos/3/1SmdZ7GtTyCNZwSuKNH9BYxTxw5pZaeuFdHV8IRE.jpeg	27eb43bf-4055-499d-81af-1b31bd2ae1b7.jpeg	image/jpeg
36	21	Prodi SE	PPB SE02 1x, PPB SE04 1x	2025-11-25 22:14:50	2025-11-25 22:14:50	https://storage.googleapis.com/tracker-expenses/memos/3/mn1Eo88rr9oanYGoc5ftk17UNKfkcRW0427Tppfc.jpeg	6af5e483-6992-41e4-b044-c01a266ad4e7.jpeg	image/jpeg
37	21	Prodi IF	IMPAL 1x	2025-11-25 22:15:35	2025-11-25 22:15:35	https://storage.googleapis.com/tracker-expenses/memos/3/QII23ved9w2aiyFnLAxAzpYipOkWWLRpplQrBa1X.jpeg	2099f92b-06fa-44fd-8205-dd2039dfb258.jpeg	image/jpeg
38	22	Prodi IF	IMPAL 1x	2025-11-25 22:16:39	2025-11-25 22:16:39	https://storage.googleapis.com/tracker-expenses/memos/3/zbiTtjoW2pvz8h1HQqPpwyEVYdoMm4AAp6gXF22w.jpeg	ee78ab95-4e1b-4889-8241-8caba185d0b3.jpeg	image/jpeg
40	24	Jam minimum responsi 	8 Jam (4x Pertemuan)	2025-11-29 18:56:03	2025-11-29 18:56:03	\N	\N	\N
47	25	#1 	Rabu/29-10-2025	2025-11-29 19:01:49	2025-11-29 19:01:49	\N	\N	\N
48	25	#2 	Rabu/19-11-2025 & Kamis/20-11-2025	2025-11-29 19:02:45	2025-11-29 19:02:45	\N	\N	\N
58	26	#3	Rencana Minggu 14 (Untuk Tubes)	2025-11-29 19:09:01	2025-12-01 09:13:06	\N	\N	\N
61	27	#2	Rabu/26-11-2025 (Dipakai menilai UTS)	2025-11-29 19:10:32	2025-12-03 12:08:22	\N	\N	\N
53	25	#7	Rencana Minggu 15 (Untuk Tubes)	2025-11-29 19:03:39	2025-12-01 09:14:05	\N	\N	\N
54	25	#8	Rencana Minggu 16 (Untuk Tubes)	2025-11-29 19:03:45	2025-12-01 09:14:17	\N	\N	\N
50	25	#4	Rencana Minggu 13 (Untuk yang ingin konsultasi sudah siap maju atau belum)	2025-11-29 19:03:05	2025-12-01 09:15:10	\N	\N	\N
62	27	#3	Kamis/27-11-2025\n(Dipakai menilai UTS)	2025-11-29 19:10:41	2025-12-03 12:08:39	\N	\N	\N
56	26	#1	Selasa/28-10-2025	2025-11-29 19:08:42	2025-11-29 19:08:42	\N	\N	\N
59	27	Jam minimum responsi	6 Jam (3x Pertemuan)	2025-11-29 19:09:39	2025-11-29 19:09:39	\N	\N	\N
55	26	Jam minimum responsi	6 Jam (3x Pertemuan)	2025-11-29 19:07:12	2025-11-29 19:09:49	\N	\N	\N
60	27	#1 	Kamis/30-10-2025	2025-11-29 19:10:21	2025-11-29 19:10:21	\N	\N	\N
63	28	Jam minimum responsi	32 Jam (16x Pertemuan)	2025-11-29 19:11:37	2025-11-29 19:11:37	\N	\N	\N
64	28	#1	Rabu/22-10-2025 (Dipakai menilai assesmen 1)	2025-11-29 19:12:18	2025-11-29 19:12:18	\N	\N	\N
65	28	#2	Jumat/31-10-2025	2025-11-29 19:12:35	2025-11-29 19:12:35	\N	\N	\N
66	28	#3	Jumat/14-11-2025	2025-11-29 19:12:50	2025-11-29 19:12:50	\N	\N	\N
67	28	#4	Sabtu/15-11-2025	2025-11-29 19:13:01	2025-11-29 19:13:01	\N	\N	\N
68	28	#5	Jumat/21-11-2025	2025-11-29 19:13:13	2025-11-29 19:13:13	\N	\N	\N
69	28	#6	Sabtu/22-11-2025	2025-11-29 19:13:24	2025-11-29 19:13:24	\N	\N	\N
70	28	#7	Jumat/28-11-2025 (Dipakai menilai assesmen 2)	2025-11-29 19:13:39	2025-11-29 19:14:24	\N	\N	\N
71	28	#8	Sabtu/29-11-2025 (Dipakai menilai assesmen 2)	2025-11-29 19:14:21	2025-11-29 19:14:30	\N	\N	\N
74	28	#11	Rencana Minggu 13	2025-11-29 19:15:03	2025-11-29 19:15:03	\N	\N	\N
75	28	#12	Rencana Minggu 13	2025-11-29 19:15:07	2025-11-29 19:15:07	\N	\N	\N
76	28	#13	Rencana Minggu 14	2025-11-29 19:15:19	2025-11-29 19:15:19	\N	\N	\N
57	26	#2	Rencana Minggu 13	2025-11-29 19:08:52	2025-11-30 15:10:24	\N	\N	\N
72	28	#9	Jumat/05-12-2025	2025-11-29 19:14:47	2025-12-01 08:32:34	\N	\N	\N
73	28	#10	Sabtu/06-12-2025	2025-11-29 19:14:52	2025-12-01 08:32:43	\N	\N	\N
49	25	#3	Kamis/04-12-2025 & Sabtu/06-12-2025	2025-11-29 19:02:59	2025-12-01 08:33:11	\N	\N	\N
77	28	#14	Rencana Minggu 14	2025-11-29 19:15:24	2025-11-29 19:15:24	\N	\N	\N
80	27	Sudah habis tidak perlu responsi	-	2025-11-29 19:16:16	2025-11-29 19:16:16	\N	\N	\N
44	24	#4 	Rencana Minggu 13	2025-11-29 18:56:59	2025-11-29 19:16:38	\N	\N	\N
81	29	30/11/2025	Day 1	2025-11-30 15:40:09	2025-11-30 15:40:09	\N	\N	\N
78	28	#15	Rencana Minggu 15 (Untuk Tubes)	2025-11-29 19:15:30	2025-12-01 09:12:46	\N	\N	\N
79	28	#16	Rencana Minggu 15 (Untuk Tubes)	2025-11-29 19:15:36	2025-12-01 09:12:51	\N	\N	\N
52	25	#6	Rencana Minggu 15 (Untuk Tubes)	2025-11-29 19:03:29	2025-12-01 09:14:02	\N	\N	\N
51	25	#5	Rencana Minggu 14 (Final keputusan sudah siap maju atau belum)	2025-11-29 19:03:12	2025-12-01 09:15:27	\N	\N	\N
\.


--
-- Data for Name: memo_folders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.memo_folders (id, user_id, name, color, created_at, updated_at) FROM stdin;
1	2	Test	#095C4A	2025-11-22 07:16:40	2025-11-22 07:16:40
2	2	Test	#ff0000	2025-11-22 07:16:59	2025-11-22 07:16:59
3	2	Test	#6366F1	2025-11-22 07:28:14	2025-11-22 07:28:14
4	2	Test 123	#EC4899	2025-11-22 08:33:08	2025-11-22 08:33:08
7	3	ASDOS	#F97316	2025-11-22 20:39:23	2025-11-22 20:39:23
8	3	MELY	#EC4899	2025-11-30 15:39:50	2025-11-30 15:39:50
\.


--
-- Data for Name: memo_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.memo_groups (id, user_id, name, created_at, updated_at, memo_folder_id) FROM stdin;
2	3	Service mobil	2025-11-20 11:57:41	2025-11-20 11:57:41	\N
1	3	Service motor	2025-11-20 11:57:32	2025-11-20 11:57:53	\N
3	3	Service AC Abiya	2025-11-20 11:58:02	2025-11-20 11:58:02	\N
4	3	Service AC Gading	2025-11-20 11:58:06	2025-11-20 11:58:06	\N
5	3	Cukur rambut	2025-11-20 11:58:12	2025-11-20 11:58:12	\N
7	3	Obat	2025-11-20 11:58:26	2025-11-20 11:58:26	\N
10	2	Test	2025-11-22 07:16:37	2025-11-22 07:16:37	\N
13	2	sadsa	2025-11-22 08:21:52	2025-11-22 08:21:52	\N
14	2	asda	2025-11-22 08:25:38	2025-11-22 08:25:38	\N
18	2	Abiya Makruf	2025-11-22 09:34:22	2025-11-22 09:34:22	\N
16	2	Abiya Dari Folder	2025-11-22 08:33:19	2025-11-22 09:49:50	\N
19	2	Test Folder ID	2025-11-22 09:42:07	2025-11-22 10:26:39	\N
17	2	Hasil move dari dalem folder	2025-11-22 09:32:13	2025-11-22 10:27:18	1
6	3	Mandi Ivy	2025-11-20 11:58:15	2025-11-23 12:18:58	\N
22	3	Honor September - Oktober (78.000)	2025-11-25 22:16:17	2025-11-25 22:16:17	7
21	3	Honor Oktober - November (771.300)	2025-11-25 22:08:07	2025-11-25 22:17:04	7
25	3	PPB SE-02 & SE-04	2025-11-29 18:57:56	2025-11-29 18:57:56	7
26	3	WEBPRO IT-03 & IT-04	2025-11-29 19:06:39	2025-11-29 19:08:13	7
24	3	IMPAL IF-10	2025-11-29 18:55:38	2025-11-29 19:10:52	7
27	3	PBO IT-05	2025-11-29 19:09:16	2025-11-29 19:11:00	7
28	3	CT IT-03	2025-11-29 19:11:17	2025-11-29 19:11:17	7
29	3	Jadwal M	2025-11-30 15:39:57	2025-11-30 15:39:57	8
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2024_04_24_000100_create_category_icons_table	1
5	2024_04_24_000200_create_categories_table	1
6	2024_04_24_000300_create_wallets_table	1
7	2024_04_24_000400_create_labels_table	1
8	2024_04_24_000450_create_recurring_transactions_table	1
9	2024_04_24_000500_create_transactions_table	1
10	2024_04_24_000600_create_budgets_table	1
11	2024_04_24_000700_create_planned_payments_table	1
12	2024_04_24_000800_create_goals_table	1
13	2024_04_24_000900_create_subscriptions_table	1
14	2024_04_24_001100_add_profile_fields_to_users_table	1
15	2024_04_24_001200_add_sub_category_to_subscriptions_table	1
16	2024_04_24_001210_create_wallet_icons_table	1
17	2024_04_24_002000_create_icons_table	1
18	2024_04_24_002010_update_wallets_for_icons	1
19	2024_04_24_002020_update_categories_for_icons	1
20	2024_04_24_002030_drop_legacy_icon_tables	1
21	2024_04_25_000000_add_image_disk_to_icons_table	1
22	2025_09_02_075243_add_two_factor_columns_to_users_table	1
23	2025_11_19_182415_add_icon_id_to_planning_tables	1
24	2025_11_19_212241_create_memos_tables	1
25	2025_11_22_064931_add_image_path_to_memo_entries_table	2
26	2025_11_22_070723_update_memos_structure_for_folders_and_files	3
27	2025_11_22_105350_add_profile_photo_path_to_users_table	4
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: planned_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.planned_payments (id, user_id, title, amount, due_date, wallet_id, category_id, repeat_option, is_recurring, status, transaction_id, note, metadata, deleted_at, created_at, updated_at, icon_id) FROM stdin;
1	2	Electricity Bill	500000.00	2025-11-27	1	6	monthly	t	pending	\N	PLN monthly payment	\N	\N	2025-11-20 02:07:40	2025-11-20 02:07:40	\N
\.


--
-- Data for Name: recurring_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recurring_transactions (id, user_id, wallet_id, to_wallet_id, category_id, sub_category_id, type, amount, currency, payment_type, "interval", custom_days, next_run_at, end_date, auto_post, last_run_at, is_active, note, metadata, deleted_at, created_at, updated_at) FROM stdin;
1	2	1	\N	7	\N	income	15000000.00	IDR	transfer	monthly	\N	2025-12-20 02:07:40	\N	t	\N	t	Monthly salary auto record	\N	\N	2025-11-20 02:07:40	2025-11-20 02:07:40
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
NIaukoIMHbqqamxyWLy2OibRHuAFUz5BnOVOl8OG	3	2404:c0:a701:7e36:d900:f280:a7ba:1024	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Mobile/15E148 Safari/604.1	YTo1OntzOjY6Il90b2tlbiI7czo0MDoiemNpMlVxTXZXckVoRUQ5SXZJclh0a2libVE4MExjaDhsNzRwS09kOCI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjM4OiJodHRwczovL3RyYWNrZXItZXhwZW5zZXMuYWJpeWFtZi5teS5pZCI7czo1OiJyb3V0ZSI7czo3OiJ3ZWxjb21lIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6Mzt9	1764764454
IvMLT5OnaDKoAzjQmFBmSbzI8amiMfy5efZqUH7a	\N	2404:c0:a701:7e36:d900:f280:a7ba:1024	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Mobile/15E148 Safari/604.1	YTozOntzOjY6Il90b2tlbiI7czo0MDoiV3FZZ2VlMkNYYWh4dzF6eDloZG5FUkRNTnlqb2xhWTM3OEtiWHlSZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDQ6Imh0dHBzOi8vdHJhY2tlci1leHBlbnNlcy5hYml5YW1mLm15LmlkL2xvZ2luIjtzOjU6InJvdXRlIjtzOjU6ImxvZ2luIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1764764551
Pa4HAyONNjFuLIar5MemFNJoKWbH4jPnoAfzup68	3	2404:c0:a701:7e36:ad42:f32c:db6c:d818	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	YTo0OntzOjY6Il90b2tlbiI7czo0MDoiQlRRVW9XaGlldkFIUXhoM1lNcnNzc09YeWNaZEFQYWtkUmZTWGluYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzg6Imh0dHBzOi8vdHJhY2tlci1leHBlbnNlcy5hYml5YW1mLm15LmlkIjtzOjU6InJvdXRlIjtzOjc6IndlbGNvbWUiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aTozO30=	1764764853
56832Oupa8oxHh0hgRBtjFN61W8bSTixRYL5IWNW	3	2404:c0:2d10::40:abd	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Mobile/15E148 Safari/604.1	YTo1OntzOjY6Il90b2tlbiI7czo0MDoiaXZLMlFPbHpwa2M1VkNJSkZGdHB5bUM4b3VEQlNhUHRZTWpDN1A1YSI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjUwOiJodHRwczovL3RyYWNrZXItZXhwZW5zZXMuYWJpeWFtZi5teS5pZC9yZWNvcmRzL2FkZCI7czo1OiJyb3V0ZSI7czoxMToicmVjb3Jkcy5hZGQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YToxOntpOjA7czo2OiJzdGF0dXMiO31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjM7fQ==	1764765203
vyYBEdIXblPbqs185f2WkaNDNVhjgiiQwhUL39Ij	3	2404:c0:a701:7e36:6cfb:578f:acbf:4c14	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Mobile/15E148 Safari/604.1	YTo1OntzOjY6Il90b2tlbiI7czo0MDoiM1gyNFRCb0M4aU5oTnVydWNiWjByT3Z2TmVrdXhNR1dwOEVud3hETSI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjQ4OiJodHRwczovL3RyYWNrZXItZXhwZW5zZXMuYWJpeWFtZi5teS5pZC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6Mzt9	1764786625
tXB1TWHIm8u1MJUUONYIyty8NTF3sq0m2BQllr3h	3	2404:c0:a701:7e36:6cfb:578f:acbf:4c14	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Mobile/15E148 Safari/604.1	YTo0OntzOjY6Il90b2tlbiI7czo0MDoiQzY0SExtaVoxWDVBYlUzUWNGR0dpYUhlY21OcE9mRTVqVEhCemRJTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vdHJhY2tlci1leHBlbnNlcy5hYml5YW1mLm15LmlkL3JlY29yZHMvYWRkIjtzOjU6InJvdXRlIjtzOjExOiJyZWNvcmRzLmFkZCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjE6e2k6MDtzOjY6InN0YXR1cyI7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6Mzt9	1764820318
8LFC9Ya2BJK6x4SZP5JQRyvIdF8d43IVsd1gj5sy	3	182.10.129.134	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Mobile/15E148 Safari/604.1	YTo1OntzOjY6Il90b2tlbiI7czo0MDoic0V4OHNFYUJybWxhRDdJajI4dENrQWxsT2s2b2l0aW1BN0FrM1NRMyI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjQ0OiJodHRwczovL3RyYWNrZXItZXhwZW5zZXMuYWJpeWFtZi5teS5pZC9tZW1vcyI7czo1OiJyb3V0ZSI7czo1OiJtZW1vcyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjM7fQ==	1764843459
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscriptions (id, user_id, name, amount, billing_cycle, next_billing_date, wallet_id, category_id, status, auto_post_transaction, reminder_days, last_billed_at, currency, note, metadata, deleted_at, created_at, updated_at, sub_category_id, icon_id) FROM stdin;
1	2	Spotify Premium	54990.00	monthly	2025-12-02	1	6	active	t	3	\N	IDR	\N	\N	\N	2025-11-20 02:07:40	2025-11-20 02:07:40	\N	\N
2	3	Chat GPT	378000.00	monthly	2025-12-19	4	6	active	f	1	\N	IDR	Langganan Chat GPT	\N	\N	2025-11-20 11:49:18	2025-11-20 11:49:18	28	2873
3	3	Internet Quota	70000.00	monthly	2025-12-13	4	6	active	f	1	\N	IDR	Perpanjangan kuota internet	\N	\N	2025-11-20 11:51:21	2025-11-20 11:51:21	16	2874
4	3	Icloud	15000.00	monthly	2025-11-22	6	6	active	f	1	\N	IDR	Langganan Icloud	\N	\N	2025-11-20 11:53:18	2025-11-20 11:53:18	31	2875
5	3	Apple Music	21250.00	monthly	2025-12-09	4	6	active	f	1	\N	IDR	Langganan Apple music	\N	\N	2025-11-20 11:54:57	2025-11-20 11:54:57	32	2876
6	3	Netflix	187000.00	monthly	2025-12-17	7	6	active	f	1	\N	IDR	Langganan Netflix	\N	\N	2025-11-20 11:55:39	2025-11-20 11:55:39	26	2877
7	3	Google Drive	25000.00	monthly	2026-08-22	6	6	active	f	1	\N	IDR	Perpanjangan langganan google drive	\N	\N	2025-11-20 11:57:14	2025-11-20 11:57:14	33	2878
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (id, user_id, wallet_id, to_wallet_id, category_id, sub_category_id, recurring_transaction_id, type, amount, currency, exchange_rate, amount_converted, payment_type, transaction_date, status, note, attachment_path, metadata, created_at, updated_at, deleted_at) FROM stdin;
1	2	1	\N	1	\N	\N	expense	150000.00	IDR	1.000000	\N	transfer	2025-11-20 02:07:39	posted	Brunch with family	\N	\N	2025-11-20 02:07:39	2025-11-20 02:07:39	\N
2	2	1	\N	6	\N	\N	expense	89000.00	IDR	1.000000	\N	transfer	2025-11-11 02:07:39	posted	Netflix subscription	\N	\N	2025-11-20 02:07:39	2025-11-20 02:07:39	\N
3	2	1	\N	7	\N	\N	income	15000000.00	IDR	1.000000	\N	transfer	2025-11-16 02:07:39	posted	Monthly salary	\N	\N	2025-11-20 02:07:40	2025-11-20 02:07:40	\N
4	2	2	\N	3	\N	\N	expense	35000.00	IDR	1.000000	\N	transfer	2025-11-16 02:07:39	posted	Taxi ride	\N	\N	2025-11-20 02:07:40	2025-11-20 02:07:40	\N
5	3	4	\N	1	12	\N	expense	5000.00	IDR	1.000000	\N	qris	2025-11-11 10:46:00	posted	Jajan di warung oma	\N	\N	2025-11-20 10:47:45	2025-11-20 10:47:45	\N
7	3	4	\N	1	10	\N	expense	13500.00	IDR	1.000000	\N	transfer	2025-11-11 10:49:00	posted	Bayar makan indomie di warkop ke Rafly	\N	\N	2025-11-20 10:50:20	2025-11-20 10:50:20	\N
9	3	4	\N	15	17	\N	expense	150000.00	IDR	1.000000	\N	debit_card	2025-11-13 10:51:00	posted	Tarik uang tunai untuk pegangan cash dan tabungan	\N	\N	2025-11-20 10:54:00	2025-11-20 10:54:00	\N
8	3	4	\N	6	16	\N	expense	70000.00	IDR	1.000000	\N	virtual_account	2025-11-13 10:50:00	posted	Membeli kuota bulanan	\N	\N	2025-11-20 10:51:35	2025-11-20 10:54:21	\N
6	3	4	\N	15	\N	\N	expense	1000000.00	IDR	1.000000	\N	transfer	2025-11-11 10:47:00	posted	Trasnfer uang ke ibu	\N	\N	2025-11-20 10:49:26	2025-11-20 10:57:13	2025-11-20 10:57:13
10	3	4	\N	19	\N	\N	income	1000000.00	IDR	1.000000	\N	transfer	2025-11-11 10:57:00	posted	Transfer uang masuk dari ibu	\N	\N	2025-11-20 10:58:39	2025-11-20 10:59:34	\N
11	3	4	\N	1	12	\N	expense	29500.00	IDR	1.000000	\N	qris	2025-11-13 11:00:00	posted	Jajan chikuro di Ciwalk	\N	\N	2025-11-20 11:00:38	2025-11-20 11:00:38	\N
12	3	4	\N	15	20	\N	expense	20000.00	IDR	1.000000	\N	transfer	2025-11-14 11:03:00	posted	Topup kartu Flazz	\N	\N	2025-11-20 11:04:22	2025-11-20 11:04:22	\N
13	3	4	\N	1	12	\N	expense	6500.00	IDR	1.000000	\N	qris	2025-11-14 11:04:00	posted	Jajan di warung oma	\N	\N	2025-11-20 11:04:53	2025-11-20 11:04:53	\N
14	3	4	\N	15	20	\N	expense	18000.00	IDR	1.000000	\N	transfer	2025-11-14 11:04:00	posted	Topup robux buat Mely	\N	\N	2025-11-20 11:05:25	2025-11-20 11:05:25	\N
15	3	4	\N	7	21	\N	income	600000.00	IDR	1.000000	\N	transfer	2025-11-15 11:06:00	posted	Uang mingguan	\N	\N	2025-11-20 11:09:11	2025-11-20 11:09:11	\N
16	3	4	\N	4	22	\N	expense	600000.00	IDR	1.000000	\N	qris	2025-11-15 11:09:00	posted	Tiket masuk kolam renang oasis siliwangi	\N	\N	2025-11-20 11:11:01	2025-11-20 11:11:01	\N
17	3	4	\N	1	12	\N	expense	25050.00	IDR	1.000000	\N	qris	2025-11-15 11:11:00	posted	Jajan di kolam renang	\N	\N	2025-11-20 11:11:32	2025-11-20 11:11:32	\N
18	3	4	\N	1	12	\N	expense	15025.00	IDR	1.000000	\N	qris	2025-11-15 11:11:00	posted	Jajan di kolam renang	\N	\N	2025-11-20 11:11:47	2025-11-20 11:11:47	\N
19	3	4	\N	5	23	\N	expense	200000.00	IDR	1.000000	\N	qris	2025-11-15 11:11:00	posted	Tiket bioskop	\N	\N	2025-11-20 11:13:08	2025-11-20 11:13:28	\N
20	3	4	\N	1	12	\N	expense	258000.00	IDR	1.000000	\N	qris	2025-11-15 11:13:00	posted	Jajan popcorn dan minuman di bioskop	\N	\N	2025-11-20 11:13:58	2025-11-20 11:13:58	\N
21	3	4	\N	1	10	\N	expense	394570.00	IDR	1.000000	\N	qris	2025-11-16 11:13:00	posted	Makan bersama keluarga di Ta Wan	\N	\N	2025-11-20 11:14:42	2025-11-20 11:14:42	\N
22	3	4	\N	4	24	\N	expense	145000.00	IDR	1.000000	\N	qris	2025-11-16 11:14:00	posted	Billiard bersama ayah di MOD EL CAPO	\N	\N	2025-11-20 11:16:37	2025-11-20 11:16:37	\N
23	3	4	\N	1	12	\N	expense	2500.00	IDR	1.000000	\N	qris	2025-11-16 11:16:00	posted	Jajan di warung oma	\N	\N	2025-11-20 11:16:57	2025-11-20 11:16:57	\N
24	3	4	\N	25	\N	\N	expense	298659.00	IDR	1.000000	\N	qris	2025-11-16 11:16:00	posted	Membeli obat nasonex	\N	\N	2025-11-20 11:18:13	2025-11-20 11:18:13	\N
25	3	4	\N	1	10	\N	expense	188000.00	IDR	1.000000	\N	qris	2025-11-16 11:18:00	posted	Makan di marugame udon bersama ibu	\N	\N	2025-11-20 11:18:39	2025-11-20 11:18:39	\N
26	3	4	\N	6	26	\N	expense	187000.00	IDR	1.000000	\N	virtual_account	2025-11-17 11:18:00	posted	Perpanjang langganan Netflix	\N	\N	2025-11-20 11:19:28	2025-11-20 11:19:28	\N
27	3	4	\N	19	\N	\N	income	163000.00	IDR	1.000000	\N	transfer	2025-11-17 11:19:00	posted	Uang masuk dari ibu	\N	\N	2025-11-20 11:19:57	2025-11-20 11:19:57	\N
28	3	4	\N	1	12	\N	expense	5000.00	IDR	1.000000	\N	qris	2025-11-18 11:19:00	posted	Jajan batagor	\N	\N	2025-11-20 11:20:26	2025-11-20 11:20:26	\N
29	3	4	\N	1	12	\N	expense	7000.00	IDR	1.000000	\N	qris	2025-11-18 11:20:00	posted	Jajan leker	\N	\N	2025-11-20 11:20:44	2025-11-20 11:20:44	\N
30	3	4	\N	1	11	\N	expense	6500.00	IDR	1.000000	\N	qris	2025-11-18 11:20:00	posted	Beli air mineral	\N	\N	2025-11-20 11:21:46	2025-11-20 11:21:46	\N
31	3	4	\N	6	27	\N	expense	56633.00	IDR	1.000000	\N	qris	2025-11-19 11:21:00	posted	Membeli domain website selama 2 tahun	\N	\N	2025-11-20 11:23:15	2025-11-20 11:23:15	\N
32	3	4	\N	19	\N	\N	income	1857645.00	IDR	1.000000	\N	transfer	2025-11-19 11:23:00	posted	Uang transfer dari ayah untuk mengganti pengeluaran selama jalan jalan	\N	\N	2025-11-20 11:23:57	2025-11-20 11:23:57	\N
33	3	4	\N	15	18	\N	expense	33000.00	IDR	1.000000	\N	transfer	2025-11-19 11:23:00	posted	Transfer uang ke ibu menggantikan uang ibu membeli bala bala di oasis siliwangi	\N	\N	2025-11-20 11:24:25	2025-11-20 11:24:25	\N
34	3	4	\N	6	28	\N	expense	377089.00	IDR	1.000000	\N	virtual_account	2025-11-19 11:24:00	posted	Perpanjangan langganan Chat GPT	\N	\N	2025-11-20 11:25:19	2025-11-20 11:25:19	\N
35	3	5	\N	15	29	\N	expense	3500.00	IDR	1.000000	\N	transfer	2025-11-14 11:25:00	posted	Biaya administrasi	\N	\N	2025-11-20 11:26:36	2025-11-20 11:26:36	\N
36	3	5	\N	25	\N	\N	expense	150000.00	IDR	1.000000	\N	transfer	2025-11-14 11:26:00	posted	Pembayaran test EPRT	\N	\N	2025-11-20 11:27:50	2025-11-20 11:27:50	\N
37	3	11	\N	1	12	\N	expense	17000.00	IDR	1.000000	\N	cash	2025-11-19 11:30:00	posted	Jajan di Indomaret	\N	\N	2025-11-20 11:30:43	2025-11-20 11:30:43	\N
38	3	11	\N	15	34	\N	expense	10000.00	IDR	1.000000	\N	cash	2025-11-21 11:44:00	posted	Infaq masjid jumatan	\N	\N	2025-11-21 11:45:18	2025-11-21 11:49:50	\N
39	3	4	\N	1	12	\N	expense	13000.00	IDR	1.000000	\N	qris	2025-11-21 20:27:00	posted	Jajan di warung oma	\N	\N	2025-11-21 20:28:06	2025-11-21 20:28:06	\N
40	3	4	\N	15	29	\N	expense	10000.00	IDR	1.000000	\N	transfer	2025-11-22 06:31:00	posted	Biaya administrasi	\N	\N	2025-11-22 06:32:21	2025-11-22 06:32:21	\N
41	3	4	\N	19	\N	\N	income	300000.00	IDR	1.000000	\N	transfer	2025-11-22 18:02:00	posted	Ayah ganti uang beli obat	\N	\N	2025-11-22 18:03:17	2025-11-22 18:03:17	\N
42	3	4	\N	7	21	\N	income	450000.00	IDR	1.000000	\N	transfer	2025-11-22 18:03:00	posted	Uang mingguan	https://storage.googleapis.com/tracker-expenses/receipts/IT0XqTFB0ICs9PNyEGwuMdsGTmlR0r4LB6y3Og9q.jpeg	\N	2025-11-22 18:03:45	2025-11-22 18:03:45	\N
43	3	6	\N	6	31	\N	expense	15000.00	IDR	1.000000	\N	virtual_account	2025-11-22 18:12:00	posted	Langganan icloud	\N	\N	2025-11-22 18:12:33	2025-11-22 18:12:33	\N
44	3	4	12	\N	\N	\N	transfer	100000.00	IDR	1.000000	\N	\N	2025-11-22 20:35:00	posted	Tabungan mingguan	\N	\N	2025-11-22 20:35:52	2025-11-22 20:35:52	\N
45	3	4	\N	19	\N	\N	income	63000.00	IDR	1.000000	\N	transfer	2025-11-23 00:05:00	posted	Irvan bayar langganan GPT	\N	\N	2025-11-23 00:06:15	2025-11-23 00:06:15	\N
46	3	4	\N	35	36	\N	expense	85000.00	IDR	1.000000	\N	qris	2025-11-23 12:12:00	posted	Cukur rambut	https://storage.googleapis.com/tracker-expenses/receipts/79OcfRXQKxjbCGfBQ4aLuUeVqTnqSearT3dTfrOE.jpg	\N	2025-11-23 12:16:29	2025-11-23 12:16:29	\N
47	3	11	\N	3	37	\N	expense	4000.00	IDR	1.000000	\N	cash	2025-11-23 12:16:00	posted	Tambah angin ban depan dan belakang	\N	\N	2025-11-23 12:17:52	2025-11-23 12:17:52	\N
48	3	4	\N	1	12	\N	expense	11000.00	IDR	1.000000	\N	qris	2025-11-23 19:47:00	posted	Jajan di warung oma	\N	\N	2025-11-23 19:47:21	2025-11-23 19:47:21	\N
49	3	4	\N	19	\N	\N	income	63000.00	IDR	1.000000	\N	transfer	2025-11-23 20:25:00	posted	Rafly bayar langganan chatgpt	https://storage.googleapis.com/tracker-expenses/receipts/C06m87tm3OOHsTdh3NPYFyAJZc5BUkDbk7wwLPHK.jpeg	\N	2025-11-23 20:26:51	2025-11-23 20:26:51	\N
50	3	5	\N	19	\N	\N	income	63000.00	IDR	1.000000	\N	transfer	2025-11-23 20:26:00	posted	Nugroho bayar langganan chatgpt	https://storage.googleapis.com/tracker-expenses/receipts/j2XG3IojdPKP58b5UbUb0b4eXg40FvvVXzXGD12f.jpeg	\N	2025-11-23 20:27:34	2025-11-23 20:27:34	\N
51	3	11	\N	1	11	\N	expense	8000.00	IDR	1.000000	\N	cash	2025-11-24 13:29:00	posted	Es Goyobod	\N	\N	2025-11-24 13:29:25	2025-11-24 13:29:25	\N
52	3	4	\N	15	17	\N	expense	100000.00	IDR	1.000000	\N	transfer	2025-11-24 13:29:00	posted	Tarik tunai di borma	\N	\N	2025-11-24 13:29:51	2025-11-24 13:29:51	\N
53	3	4	\N	1	11	\N	expense	10000.00	IDR	1.000000	\N	qris	2025-11-24 13:29:00	posted	Tong Tji Borma Dakota	\N	\N	2025-11-24 13:30:15	2025-11-24 13:30:15	\N
54	3	11	\N	19	\N	\N	income	100000.00	IDR	1.000000	\N	cash	2025-11-24 13:48:00	posted	Tarik tunai	\N	\N	2025-11-24 13:48:58	2025-11-24 13:48:58	\N
55	3	11	\N	1	11	\N	expense	2000.00	IDR	1.000000	\N	cash	2025-11-24 13:48:00	posted	Bayar ibu beli es kelapa jeruk	\N	\N	2025-11-24 13:49:23	2025-11-24 13:49:23	\N
56	3	11	\N	15	38	\N	expense	3000.00	IDR	1.000000	\N	cash	2025-11-24 15:23:00	posted	Koreksi uang cash	\N	\N	2025-11-24 15:23:26	2025-11-24 15:23:26	\N
57	3	4	\N	7	39	\N	income	771300.00	IDR	1.000000	\N	transfer	2025-11-24 16:49:00	posted	Honor dosen 10 kelas bulan 21 Oktober - 10 November. CT 4x, PPB SE02 1x, PPB SE04 1x, WEBPRO IT03 1x, WEBPRO IT04 1x, PBO 1x, IMPAL 1x.	https://storage.googleapis.com/tracker-expenses/receipts/OlA5K2FiwWKcic4jARDKpY9jHInd5JUpRjlRNwbe.jpg	\N	2025-11-24 16:53:11	2025-11-24 16:53:11	\N
58	3	5	\N	15	29	\N	expense	6000.00	IDR	1.000000	\N	transfer	2025-11-24 10:09:00	posted	Biaya administrasi bank	\N	\N	2025-11-25 10:09:43	2025-11-25 10:09:43	\N
59	3	4	\N	1	10	\N	expense	171000.00	IDR	1.000000	\N	qris	2025-11-25 16:42:00	posted	Takeaway MCD abi, ibu, gading	\N	\N	2025-11-25 16:42:42	2025-11-25 16:42:42	\N
60	3	4	\N	40	41	\N	expense	44182.00	IDR	1.000000	\N	virtual_account	2025-11-26 02:39:00	posted	Membelikan bantal panas untuk ibu	\N	\N	2025-11-26 02:41:05	2025-11-26 02:41:05	\N
61	3	5	\N	19	\N	\N	income	63000.00	IDR	1.000000	\N	transfer	2025-11-26 12:32:00	posted	Rizal bayar chat gpt	\N	\N	2025-11-26 12:33:08	2025-11-26 12:33:08	\N
62	3	4	\N	19	\N	\N	income	63000.00	IDR	1.000000	\N	transfer	2025-11-26 12:33:00	posted	Akif bayar chat gpt	\N	\N	2025-11-26 12:33:33	2025-11-26 12:33:33	\N
63	3	4	\N	19	\N	\N	income	171000.00	IDR	1.000000	\N	transfer	2025-11-26 12:55:00	posted	Ibu bayar mcd	\N	\N	2025-11-26 12:56:04	2025-11-26 12:56:04	\N
64	3	11	\N	1	11	\N	expense	32000.00	IDR	1.000000	\N	cash	2025-11-27 13:51:00	posted	Jajan es goyobod	\N	\N	2025-11-27 13:52:28	2025-11-27 13:52:28	\N
65	3	4	\N	15	17	\N	expense	400000.00	IDR	1.000000	\N	cash	2025-11-27 13:52:00	posted	Tarik uang tunai untuk tabungan	\N	\N	2025-11-27 13:53:11	2025-11-27 13:53:11	\N
66	3	4	\N	15	18	\N	expense	250000.00	IDR	1.000000	\N	transfer	2025-11-27 13:53:00	posted	Traktir Mely	\N	\N	2025-11-27 13:53:40	2025-11-27 13:53:40	\N
67	3	4	\N	19	\N	\N	income	32000.00	IDR	1.000000	\N	transfer	2025-11-27 13:53:00	posted	Ibu bayar uang beli es goyobod	\N	\N	2025-11-27 13:54:03	2025-11-27 13:54:03	\N
68	3	12	\N	8	\N	\N	income	400000.00	IDR	1.000000	\N	cash	2025-11-27 13:54:00	posted	Tambahan uang tabungan	\N	\N	2025-11-27 13:54:33	2025-11-27 13:54:33	\N
69	3	4	\N	19	\N	\N	income	100000.00	IDR	1.000000	\N	transfer	2025-11-27 20:43:00	posted	Falah joki tugas visi komputer lanjut	\N	\N	2025-11-27 20:44:19	2025-11-27 20:44:19	\N
70	3	5	\N	15	18	\N	expense	45000.00	IDR	1.000000	\N	transfer	2025-11-28 12:55:00	posted	Bayar bunga 15K, Rafly nitip 30K	\N	\N	2025-11-28 12:58:13	2025-11-28 12:58:13	\N
71	3	4	\N	42	\N	\N	expense	60000.00	IDR	1.000000	\N	qris	2025-11-28 13:01:00	posted	Beli bunga untuk mely	\N	\N	2025-11-28 13:02:13	2025-11-28 13:02:13	\N
72	3	12	11	\N	\N	\N	transfer	100000.00	IDR	1.000000	\N	\N	2025-11-28 13:04:00	posted	Pinjam untuk beli bensin	\N	\N	2025-11-28 13:04:50	2025-11-28 13:04:50	\N
73	3	11	\N	3	14	\N	expense	84000.00	IDR	1.000000	\N	cash	2025-11-28 13:04:00	posted	Beli bensin	\N	\N	2025-11-28 13:05:11	2025-11-28 13:05:11	\N
74	3	4	\N	1	11	\N	expense	4500.00	IDR	1.000000	\N	qris	2025-11-28 13:05:00	posted	Jajan teh kotak di gate 4	\N	\N	2025-11-28 13:05:47	2025-11-28 13:05:47	\N
75	3	4	\N	1	10	\N	expense	61100.00	IDR	1.000000	\N	qris	2025-11-28 13:58:00	posted	Makan berat richeese	\N	\N	2025-11-28 13:58:52	2025-11-28 13:58:52	\N
76	3	4	\N	19	\N	\N	income	30000.00	IDR	1.000000	\N	transfer	2025-11-28 13:59:00	posted	Rafly nitip bayar ke nug	\N	\N	2025-11-28 13:59:51	2025-11-28 13:59:51	\N
77	3	11	\N	3	43	\N	expense	3000.00	IDR	1.000000	\N	cash	2025-11-28 18:22:00	posted	Bayar parkir di transmart	\N	\N	2025-11-28 18:23:41	2025-11-28 18:23:41	\N
78	3	6	\N	42	\N	\N	expense	36000.00	IDR	1.000000	\N	virtual_account	2025-11-28 21:32:00	posted	Beli robux	\N	\N	2025-11-28 21:33:01	2025-11-28 21:33:01	\N
79	3	4	\N	1	12	\N	expense	13000.00	IDR	1.000000	\N	qris	2025-11-29 14:03:00	posted	Jajan di warung oma	\N	\N	2025-11-29 14:03:55	2025-11-29 14:03:55	\N
80	3	4	\N	42	\N	\N	expense	36000.00	IDR	1.000000	\N	transfer	2025-11-29 21:40:00	posted	Beliin Mely robux	\N	\N	2025-11-29 21:41:01	2025-11-29 21:41:01	\N
81	3	4	\N	7	21	\N	income	450000.00	IDR	1.000000	\N	transfer	2025-11-30 12:14:00	posted	Uang mingguan	\N	\N	2025-11-30 12:15:00	2025-11-30 12:15:00	\N
82	3	4	\N	15	17	\N	expense	200000.00	IDR	1.000000	\N	cash	2025-11-30 18:07:00	posted	Tarik tunai 200rb. 100rb ibu 100rb tabung.	\N	\N	2025-11-30 18:08:02	2025-11-30 18:08:02	\N
83	3	12	\N	19	\N	\N	income	100000.00	IDR	1.000000	\N	cash	2025-11-30 18:08:00	posted	Tabungan	\N	\N	2025-11-30 18:08:17	2025-11-30 18:08:17	\N
84	3	4	\N	1	12	\N	expense	30100.00	IDR	1.000000	\N	qris	2025-11-30 18:08:00	posted	Jajan di indomaret	\N	\N	2025-11-30 18:08:39	2025-11-30 18:08:39	\N
85	3	11	\N	1	12	\N	expense	5000.00	IDR	1.000000	\N	cash	2025-11-30 18:08:00	posted	Jajan cilor	\N	\N	2025-11-30 18:08:56	2025-11-30 18:08:56	\N
86	3	11	\N	1	10	\N	expense	16000.00	IDR	1.000000	\N	cash	2025-11-30 18:08:00	posted	Ibu nitip kwetiau	\N	\N	2025-11-30 18:09:19	2025-11-30 18:09:19	\N
87	3	4	\N	6	32	\N	expense	42500.00	IDR	1.000000	\N	transfer	2025-11-30 19:08:00	posted	Bayar apple music 2 bulan (oktober november) ke Galih.	\N	\N	2025-11-30 19:08:38	2025-11-30 19:08:38	\N
88	3	4	\N	19	\N	\N	income	116000.00	IDR	1.000000	\N	transfer	2025-11-30 20:58:00	posted	Ibu transfer uang tarik tunai dan kwetiau	\N	\N	2025-11-30 20:59:12	2025-11-30 20:59:12	\N
89	3	4	\N	9	\N	\N	income	146.00	IDR	1.000000	\N	transfer	2025-12-01 20:29:00	posted	Bunga	\N	\N	2025-12-01 20:29:39	2025-12-01 20:29:39	\N
90	3	4	\N	1	10	\N	expense	177000.00	IDR	1.000000	\N	qris	2025-12-01 20:29:00	posted	Daging Agro Meatshop	\N	\N	2025-12-01 20:30:11	2025-12-01 20:30:11	\N
91	3	4	\N	2	\N	\N	expense	151030.00	IDR	1.000000	\N	qris	2025-12-01 20:30:00	posted	Belanja Indomaret	\N	\N	2025-12-01 20:30:33	2025-12-01 20:30:33	\N
92	3	4	\N	15	17	\N	expense	50000.00	IDR	1.000000	\N	cash	2025-12-01 20:30:00	posted	Tarik tunai	\N	\N	2025-12-01 20:30:52	2025-12-01 20:30:52	\N
93	3	4	\N	1	10	\N	expense	53500.00	IDR	1.000000	\N	qris	2025-12-01 20:30:00	posted	Beli kentang dan sosis	\N	\N	2025-12-01 20:31:12	2025-12-01 20:31:12	\N
94	3	4	\N	4	24	\N	expense	158000.00	IDR	1.000000	\N	qris	2025-12-01 22:21:00	posted	Billiard MOD ELCAPO sama rafly nug	\N	\N	2025-12-01 22:21:54	2025-12-01 22:21:54	\N
95	3	11	\N	1	12	\N	expense	6000.00	IDR	1.000000	\N	cash	2025-12-01 22:21:00	posted	Jajan pukis	\N	\N	2025-12-01 22:22:20	2025-12-01 22:22:20	\N
96	3	11	\N	3	43	\N	expense	1500.00	IDR	1.000000	\N	cash	2025-12-01 22:22:00	posted	Parkir di superindo	\N	\N	2025-12-01 22:22:38	2025-12-01 22:22:38	\N
97	3	11	\N	19	\N	\N	income	50000.00	IDR	1.000000	\N	cash	2025-12-01 22:24:00	posted	Tarik tunai	\N	\N	2025-12-01 22:24:53	2025-12-01 22:24:53	\N
98	3	11	\N	3	37	\N	expense	2000.00	IDR	1.000000	\N	cash	2025-12-01 22:26:00	posted	Tambah angin	\N	\N	2025-12-01 22:27:19	2025-12-01 22:27:19	\N
99	3	11	\N	15	38	\N	expense	500.00	IDR	1.000000	\N	cash	2025-12-01 22:27:00	posted	\N	\N	\N	2025-12-01 22:27:36	2025-12-01 22:27:36	\N
100	3	5	\N	15	29	\N	expense	5000.00	IDR	1.000000	\N	transfer	2025-12-01 22:28:00	posted	\N	\N	\N	2025-12-01 22:29:05	2025-12-01 22:29:05	\N
101	3	5	\N	15	20	\N	expense	20000.00	IDR	1.000000	\N	transfer	2025-12-02 00:17:00	posted	Topup e momey	\N	\N	2025-12-02 00:18:08	2025-12-02 00:18:08	\N
102	3	4	\N	1	11	\N	expense	4500.00	IDR	1.000000	\N	qris	2025-12-02 12:34:00	posted	Jajan teh pucuk di ged a	\N	\N	2025-12-02 12:35:03	2025-12-02 12:35:03	\N
103	3	4	\N	15	34	\N	expense	10000.00	IDR	1.000000	\N	qris	2025-12-03 17:22:00	posted	Infaq	\N	\N	2025-12-03 17:23:05	2025-12-03 17:23:05	\N
104	3	4	\N	15	38	\N	expense	70.00	IDR	1.000000	\N	qris	2025-12-03 17:23:00	posted	Qris fee	\N	\N	2025-12-03 17:23:21	2025-12-03 17:23:21	\N
105	3	4	\N	1	12	\N	expense	13500.00	IDR	1.000000	\N	qris	2025-12-03 19:33:00	posted	Jajan di warung oma	\N	\N	2025-12-03 19:33:23	2025-12-03 19:33:23	\N
106	3	11	\N	15	18	\N	expense	6000.00	IDR	1.000000	\N	cash	2025-12-04 10:51:00	posted	Ibu pinjam 6K	\N	\N	2025-12-04 10:51:58	2025-12-04 10:51:58	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, role, base_currency, language, timezone, default_wallet_id, settings, last_active_at, two_factor_secret, two_factor_recovery_codes, two_factor_confirmed_at, profile_photo_path) FROM stdin;
4	Dian Irdi	dianidhink15@gmail.com	\N	$2y$12$KXiku/9RxuEEspb3d.5SQe0UNCO/zDndmlf.bO4N7wWJVn.Bi/Y3a	\N	2025-11-20 17:55:10	2025-11-20 17:55:10	user	IDR	en	Asia/Jakarta	\N	\N	\N	\N	\N	\N	\N
3	Muhammad Abiya Makruf	aabbiiyyaa@gmail.com	\N	$2y$12$jWz6ZP9DIDicsgS07IShCuGobwYEMedBrtYOEv55LgZMFvK10bvUC	\N	2025-11-20 02:12:47	2025-11-20 20:29:41	user	IDR	id	Asia/Jakarta	\N	\N	\N	\N	\N	\N	\N
2	Demo User	demo@myexpenses.test	2025-11-20 02:07:39	$2y$12$oT87RCER5jOICL2izGfV4./6IgaMkrn9HLqpYW5vSmvK98OHGven.	4wmGY7oXUIcvlb3S8cZkcnAulsrVmlsvcMFepKlS58BhzDU8PjqjZJJW7JiI	2025-11-20 02:07:39	2025-11-22 10:57:36	user	IDR	en	Asia/Jakarta	1	\N	\N	\N	\N	\N	http://127.0.0.1:8000/storage/profile-photos/d2zioIBJEOfjASMe1sh1Bir10ItrxU7JsD9M0XwC.jpg
1	Admin	admin@abiya	2025-11-20 02:07:38	$2y$12$DdOE08CNOTPM1xrb29fIN.HFBduY5DkZwOQKLo0yo910ordf.XkQu	G989OboLmhZHIwMxM0uRqq9fpZp1hB8ujsz8uHX9cw3nl7fjDq9VaTmNhRkk	2025-11-20 02:07:38	2025-11-20 02:07:38	admin	IDR	en	Asia/Jakarta	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: wallets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wallets (id, user_id, name, type, currency, initial_balance, current_balance, is_default, meta, archived_at, deleted_at, created_at, updated_at, icon_id, icon_color, icon_background) FROM stdin;
1	2	Main Wallet	bank	IDR	5000000.00	5000000.00	t	\N	\N	\N	2025-11-20 02:07:39	2025-11-20 02:07:39	1	#095C4A	#D2F9E7
2	2	Cash	cash	IDR	1000000.00	750000.00	f	\N	\N	\N	2025-11-20 02:07:39	2025-11-20 02:07:39	3	#F97316	#FFF7ED
3	1	BCA	bank	IDR	10000.00	10000.00	f	\N	\N	2025-11-20 09:55:55	2025-11-20 02:09:45	2025-11-20 09:55:55	894	#ff0000	#ff0000
7	3	GOPAY	e-wallet	IDR	2701.00	2701.00	f	\N	\N	\N	2025-11-20 10:11:39	2025-11-20 10:11:39	2868	#095C4A	#D2F9E7
8	3	Shopee Pay	e-wallet	IDR	4429.00	4429.00	f	\N	\N	\N	2025-11-20 10:12:00	2025-11-20 10:12:00	2869	#095C4A	#D2F9E7
9	3	OVO	e-wallet	IDR	5701.00	5701.00	f	\N	\N	\N	2025-11-20 10:12:19	2025-11-20 10:12:19	2871	#095C4A	#D2F9E7
10	3	Flazz	e-wallet	IDR	25500.00	25500.00	f	\N	\N	\N	2025-11-20 10:13:23	2025-11-20 10:13:23	2872	#095C4A	#D2F9E7
5	3	Mandiri	bank	IDR	316004.00	212504.00	f	\N	\N	\N	2025-11-20 10:09:44	2025-12-02 00:18:08	2867	#095C4A	#D2F9E7
4	3	BCA	bank	IDR	5182034.00	6041617.00	f	\N	\N	\N	2025-11-20 10:02:48	2025-12-03 19:33:23	2865	#095C4A	#D2F9E7
11	3	Cash	cash	IDR	50000.00	100000.00	f	\N	\N	\N	2025-11-20 10:14:04	2025-12-04 10:51:58	3	#095C4A	#D2F9E7
6	3	DANA	e-wallet	IDR	60320.00	9320.00	f	\N	\N	\N	2025-11-20 10:10:56	2025-11-28 21:33:01	2870	#095C4A	#D2F9E7
12	3	Savings	investment	IDR	3000000.00	3500000.00	f	\N	\N	\N	2025-11-20 10:15:01	2025-11-30 18:08:17	7	#095C4A	#D2F9E7
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-11-17 03:48:20
20211116045059	2025-11-17 03:48:20
20211116050929	2025-11-17 03:48:20
20211116051442	2025-11-17 03:48:20
20211116212300	2025-11-17 03:48:20
20211116213355	2025-11-17 03:48:20
20211116213934	2025-11-17 03:48:20
20211116214523	2025-11-17 03:48:20
20211122062447	2025-11-17 03:48:20
20211124070109	2025-11-17 03:48:20
20211202204204	2025-11-17 03:48:20
20211202204605	2025-11-17 03:48:20
20211210212804	2025-11-17 03:48:20
20211228014915	2025-11-17 03:48:20
20220107221237	2025-11-17 03:48:20
20220228202821	2025-11-17 03:48:20
20220312004840	2025-11-17 03:48:20
20220603231003	2025-11-17 03:48:21
20220603232444	2025-11-17 03:48:21
20220615214548	2025-11-17 03:48:21
20220712093339	2025-11-17 03:48:21
20220908172859	2025-11-17 03:48:21
20220916233421	2025-11-17 03:48:21
20230119133233	2025-11-17 03:48:21
20230128025114	2025-11-17 03:48:21
20230128025212	2025-11-17 03:48:21
20230227211149	2025-11-17 03:48:21
20230228184745	2025-11-17 03:48:21
20230308225145	2025-11-17 03:48:21
20230328144023	2025-11-17 03:48:21
20231018144023	2025-11-17 03:48:21
20231204144023	2025-11-17 03:48:21
20231204144024	2025-11-17 03:48:21
20231204144025	2025-11-17 03:48:21
20240108234812	2025-11-17 03:48:21
20240109165339	2025-11-17 03:48:21
20240227174441	2025-11-17 03:48:21
20240311171622	2025-11-17 03:48:21
20240321100241	2025-11-17 03:48:21
20240401105812	2025-11-17 03:48:21
20240418121054	2025-11-17 03:48:21
20240523004032	2025-11-17 03:48:21
20240618124746	2025-11-17 03:48:21
20240801235015	2025-11-17 03:48:21
20240805133720	2025-11-17 03:48:21
20240827160934	2025-11-17 03:48:21
20240919163303	2025-11-17 03:48:21
20240919163305	2025-11-17 03:48:21
20241019105805	2025-11-17 03:48:21
20241030150047	2025-11-17 03:48:21
20241108114728	2025-11-17 03:48:21
20241121104152	2025-11-17 03:48:21
20241130184212	2025-11-17 03:48:21
20241220035512	2025-11-17 03:48:21
20241220123912	2025-11-17 03:48:21
20241224161212	2025-11-17 03:48:21
20250107150512	2025-11-17 03:48:21
20250110162412	2025-11-17 03:48:21
20250123174212	2025-11-17 03:48:21
20250128220012	2025-11-17 03:48:21
20250506224012	2025-11-17 03:48:21
20250523164012	2025-11-17 03:48:21
20250714121412	2025-11-17 03:48:21
20250905041441	2025-11-17 03:48:21
20251103001201	2025-11-17 03:48:21
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-11-17 03:48:19.739439
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-11-17 03:48:19.754782
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-11-17 03:48:19.765323
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-11-17 03:48:19.817005
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-11-17 03:48:20.022731
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-11-17 03:48:20.030221
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-11-17 03:48:20.047243
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-11-17 03:48:20.054117
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-11-17 03:48:20.059912
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-11-17 03:48:20.066677
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-11-17 03:48:20.075554
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-11-17 03:48:20.083237
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-11-17 03:48:20.094024
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-11-17 03:48:20.10917
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-11-17 03:48:20.11584
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-11-17 03:48:20.150149
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-11-17 03:48:20.157597
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-11-17 03:48:20.164013
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-11-17 03:48:20.172665
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-11-17 03:48:20.186028
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-11-17 03:48:20.193925
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-11-17 03:48:20.204318
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-11-17 03:48:20.23338
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-11-17 03:48:20.247882
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-11-17 03:48:20.256189
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-11-17 03:48:20.264746
26	objects-prefixes	ef3f7871121cdc47a65308e6702519e853422ae2	2025-11-17 03:48:20.27167
27	search-v2	33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2	2025-11-17 03:48:20.292455
28	object-bucket-name-sorting	ba85ec41b62c6a30a3f136788227ee47f311c436	2025-11-17 03:48:20.725973
29	create-prefixes	a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b	2025-11-17 03:48:20.73409
30	update-object-levels	6c6f6cc9430d570f26284a24cf7b210599032db7	2025-11-17 03:48:20.740893
31	objects-level-index	33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8	2025-11-17 03:48:20.757076
32	backward-compatible-index-on-objects	2d51eeb437a96868b36fcdfb1ddefdf13bef1647	2025-11-17 03:48:20.767145
33	backward-compatible-index-on-prefixes	fe473390e1b8c407434c0e470655945b110507bf	2025-11-17 03:48:20.785033
34	optimize-search-function-v1	82b0e469a00e8ebce495e29bfa70a0797f7ebd2c	2025-11-17 03:48:20.78755
35	add-insert-trigger-prefixes	63bb9fd05deb3dc5e9fa66c83e82b152f0caf589	2025-11-17 03:48:20.803368
36	optimise-existing-functions	81cf92eb0c36612865a18016a38496c530443899	2025-11-17 03:48:20.810879
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-11-17 03:48:20.820018
38	iceberg-catalog-flag-on-buckets	19a8bd89d5dfa69af7f222a46c726b7c41e462c5	2025-11-17 03:48:20.826781
39	add-search-v2-sort-support	39cf7d1e6bf515f4b02e41237aba845a7b492853	2025-11-17 03:48:20.843682
40	fix-prefix-race-conditions-optimized	fd02297e1c67df25a9fc110bf8c8a9af7fb06d1f	2025-11-17 03:48:20.854431
41	add-object-level-update-trigger	44c22478bf01744b2129efc480cd2edc9a7d60e9	2025-11-17 03:48:20.874445
42	rollback-prefix-triggers	f2ab4f526ab7f979541082992593938c05ee4b47	2025-11-17 03:48:20.884294
43	fix-object-level	ab837ad8f1c7d00cc0b7310e989a23388ff29fc6	2025-11-17 03:48:20.896401
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2025-11-19 18:05:19.377783
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2025-11-19 18:05:19.390371
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2025-11-19 18:05:19.408786
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2025-11-19 18:05:19.413184
48	iceberg-catalog-ids	2666dff93346e5d04e0a878416be1d5fec345d6f	2025-11-19 18:05:19.417259
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.prefixes (bucket_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: budgets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.budgets_id_seq', 2, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 43, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: goals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.goals_id_seq', 2, true);


--
-- Name: icons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.icons_id_seq', 2878, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: label_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.label_transaction_id_seq', 10, true);


--
-- Name: labels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.labels_id_seq', 4, true);


--
-- Name: memo_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.memo_entries_id_seq', 82, true);


--
-- Name: memo_folders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.memo_folders_id_seq', 8, true);


--
-- Name: memo_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.memo_groups_id_seq', 29, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 27, true);


--
-- Name: planned_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.planned_payments_id_seq', 1, true);


--
-- Name: recurring_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recurring_transactions_id_seq', 1, true);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subscriptions_id_seq', 7, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transactions_id_seq', 106, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: wallets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wallets_id_seq', 12, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: budgets budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: goals goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_pkey PRIMARY KEY (id);


--
-- Name: icons icons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.icons
    ADD CONSTRAINT icons_pkey PRIMARY KEY (id);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: label_transaction label_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.label_transaction
    ADD CONSTRAINT label_transaction_pkey PRIMARY KEY (id);


--
-- Name: label_transaction label_transaction_transaction_id_label_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.label_transaction
    ADD CONSTRAINT label_transaction_transaction_id_label_id_unique UNIQUE (transaction_id, label_id);


--
-- Name: labels labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: labels labels_user_id_slug_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_user_id_slug_unique UNIQUE (user_id, slug);


--
-- Name: memo_entries memo_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_entries
    ADD CONSTRAINT memo_entries_pkey PRIMARY KEY (id);


--
-- Name: memo_folders memo_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_folders
    ADD CONSTRAINT memo_folders_pkey PRIMARY KEY (id);


--
-- Name: memo_groups memo_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_groups
    ADD CONSTRAINT memo_groups_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: planned_payments planned_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_payments
    ADD CONSTRAINT planned_payments_pkey PRIMARY KEY (id);


--
-- Name: recurring_transactions recurring_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: budgets budgets_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: budgets budgets_icon_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_icon_id_foreign FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON DELETE SET NULL;


--
-- Name: budgets budgets_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: budgets budgets_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_wallet_id_foreign FOREIGN KEY (wallet_id) REFERENCES public.wallets(id) ON DELETE SET NULL;


--
-- Name: categories categories_icon_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_icon_id_foreign FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON DELETE SET NULL;


--
-- Name: categories categories_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: categories categories_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: goals goals_goal_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_goal_wallet_id_foreign FOREIGN KEY (goal_wallet_id) REFERENCES public.wallets(id) ON DELETE SET NULL;


--
-- Name: goals goals_icon_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_icon_id_foreign FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON DELETE SET NULL;


--
-- Name: goals goals_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: icons icons_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.icons
    ADD CONSTRAINT icons_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: label_transaction label_transaction_label_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.label_transaction
    ADD CONSTRAINT label_transaction_label_id_foreign FOREIGN KEY (label_id) REFERENCES public.labels(id) ON DELETE CASCADE;


--
-- Name: label_transaction label_transaction_transaction_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.label_transaction
    ADD CONSTRAINT label_transaction_transaction_id_foreign FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- Name: labels labels_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: memo_entries memo_entries_memo_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_entries
    ADD CONSTRAINT memo_entries_memo_group_id_foreign FOREIGN KEY (memo_group_id) REFERENCES public.memo_groups(id) ON DELETE CASCADE;


--
-- Name: memo_folders memo_folders_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_folders
    ADD CONSTRAINT memo_folders_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: memo_groups memo_groups_memo_folder_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_groups
    ADD CONSTRAINT memo_groups_memo_folder_id_foreign FOREIGN KEY (memo_folder_id) REFERENCES public.memo_folders(id) ON DELETE CASCADE;


--
-- Name: memo_groups memo_groups_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memo_groups
    ADD CONSTRAINT memo_groups_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: planned_payments planned_payments_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_payments
    ADD CONSTRAINT planned_payments_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: planned_payments planned_payments_icon_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_payments
    ADD CONSTRAINT planned_payments_icon_id_foreign FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON DELETE SET NULL;


--
-- Name: planned_payments planned_payments_transaction_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_payments
    ADD CONSTRAINT planned_payments_transaction_id_foreign FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: planned_payments planned_payments_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_payments
    ADD CONSTRAINT planned_payments_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: planned_payments planned_payments_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planned_payments
    ADD CONSTRAINT planned_payments_wallet_id_foreign FOREIGN KEY (wallet_id) REFERENCES public.wallets(id) ON DELETE SET NULL;


--
-- Name: recurring_transactions recurring_transactions_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: recurring_transactions recurring_transactions_sub_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_sub_category_id_foreign FOREIGN KEY (sub_category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: recurring_transactions recurring_transactions_to_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_to_wallet_id_foreign FOREIGN KEY (to_wallet_id) REFERENCES public.wallets(id) ON DELETE SET NULL;


--
-- Name: recurring_transactions recurring_transactions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: recurring_transactions recurring_transactions_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_wallet_id_foreign FOREIGN KEY (wallet_id) REFERENCES public.wallets(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_icon_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_icon_id_foreign FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_sub_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_sub_category_id_foreign FOREIGN KEY (sub_category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_wallet_id_foreign FOREIGN KEY (wallet_id) REFERENCES public.wallets(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_recurring_transaction_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_recurring_transaction_id_foreign FOREIGN KEY (recurring_transaction_id) REFERENCES public.recurring_transactions(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_sub_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_sub_category_id_foreign FOREIGN KEY (sub_category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_to_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_to_wallet_id_foreign FOREIGN KEY (to_wallet_id) REFERENCES public.wallets(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_wallet_id_foreign FOREIGN KEY (wallet_id) REFERENCES public.wallets(id) ON DELETE CASCADE;


--
-- Name: users users_default_wallet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_default_wallet_id_foreign FOREIGN KEY (default_wallet_id) REFERENCES public.wallets(id) ON DELETE SET NULL;


--
-- Name: wallets wallets_icon_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_icon_id_foreign FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON DELETE SET NULL;


--
-- Name: wallets wallets_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict eSYsKWMSri4oLMn8ZeWzdJ8lRqt7R9aZCXPFkI2DUMKd2FDzsp9ET8m77uIPUaH

