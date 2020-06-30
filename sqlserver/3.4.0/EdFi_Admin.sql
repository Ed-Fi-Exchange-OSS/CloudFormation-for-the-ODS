--
-- PostgreSQL database dump
--

-- Dumped from database version 11.6
-- Dumped by pg_dump version 12.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: adminapp; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA adminapp;


ALTER SCHEMA adminapp OWNER TO postgres;

--
-- Name: adminapp_hangfire; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA adminapp_hangfire;


ALTER SCHEMA adminapp_hangfire OWNER TO postgres;

--
-- Name: dbo; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dbo;


ALTER SCHEMA dbo OWNER TO postgres;

--
-- Name: getclientfortoken(uuid); Type: FUNCTION; Schema: dbo; Owner: postgres
--

CREATE FUNCTION dbo.getclientfortoken(accesstoken uuid) RETURNS TABLE(key character varying, usesandbox boolean, studentidentificationsystemdescriptor character varying, educationorganizationid integer, claimsetname character varying, namespaceprefix character varying, profilename character varying, creatorownershiptokenid smallint, ownershiptokenid smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ac.Key
        ,ac.UseSandbox
        ,ac.StudentIdentificationSystemDescriptor
        ,aeo.EducationOrganizationId
        ,app.ClaimSetName
        ,vnp.NamespacePrefix
        ,p.ProfileName
        ,ac.CreatorOwnershipTokenId_OwnershipTokenId as CreatorOwnershipTokenId
        ,acot.OwnershipToken_OwnershipTokenId as OwnershipTokenId
    FROM dbo.ClientAccessTokens cat
         INNER JOIN dbo.ApiClients ac ON
        cat.ApiClient_ApiClientId = ac.ApiClientId
        AND cat.Id = AccessToken
         INNER JOIN dbo.Applications app ON
        app.ApplicationId = ac.Application_ApplicationId
         LEFT OUTER JOIN dbo.Vendors v ON
        v.VendorId = app.Vendor_VendorId
         LEFT OUTER JOIN dbo.VendorNamespacePrefixes vnp ON
        v.VendorId = vnp.Vendor_VendorId
         -- Outer join so client key is always returned even if no EdOrgs have been enabled
         LEFT OUTER JOIN dbo.ApiClientApplicationEducationOrganizations acaeo ON
        acaeo.ApiClient_ApiClientId = cat.ApiClient_ApiClientId
         LEFT OUTER JOIN dbo.ApplicationEducationOrganizations aeo ON
        aeo.ApplicationEducationOrganizationId = acaeo.ApplicationEdOrg_ApplicationEdOrgId
			AND (cat.Scope IS NULL OR aeo.EducationOrganizationId = CAST(cat.Scope AS INTEGER))
         LEFT OUTER JOIN dbo.ProfileApplications ap ON
        ap.Application_ApplicationId = app.ApplicationId
         LEFT OUTER JOIN dbo.Profiles p ON
        p.ProfileId = ap.Profile_ProfileId
        LEFT OUTER JOIN dbo.ApiClientOwnershipTokens acot ON
        ac.ApiClientId = acot.ApiClient_ApiClientId;
END
$$;


ALTER FUNCTION dbo.getclientfortoken(accesstoken uuid) OWNER TO postgres;

SET default_tablespace = '';

--
-- Name: applicationconfigurations; Type: TABLE; Schema: adminapp; Owner: postgres
--

CREATE TABLE adminapp.applicationconfigurations (
    id integer NOT NULL,
    allowuserregistration boolean NOT NULL
);


ALTER TABLE adminapp.applicationconfigurations OWNER TO postgres;

--
-- Name: applicationconfigurations_id_seq; Type: SEQUENCE; Schema: adminapp; Owner: postgres
--

ALTER TABLE adminapp.applicationconfigurations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp.applicationconfigurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: roles; Type: TABLE; Schema: adminapp; Owner: postgres
--

CREATE TABLE adminapp.roles (
    id character varying(128) NOT NULL,
    name character varying(256) NOT NULL
);


ALTER TABLE adminapp.roles OWNER TO postgres;

--
-- Name: secretconfigurations; Type: TABLE; Schema: adminapp; Owner: postgres
--

CREATE TABLE adminapp.secretconfigurations (
    id integer NOT NULL,
    encrypteddata character varying NOT NULL
);


ALTER TABLE adminapp.secretconfigurations OWNER TO postgres;

--
-- Name: secretconfigurations_id_seq; Type: SEQUENCE; Schema: adminapp; Owner: postgres
--

ALTER TABLE adminapp.secretconfigurations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp.secretconfigurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: userclaims; Type: TABLE; Schema: adminapp; Owner: postgres
--

CREATE TABLE adminapp.userclaims (
    id integer NOT NULL,
    userid character varying(128) NOT NULL,
    claimtype character varying,
    claimvalue character varying
);


ALTER TABLE adminapp.userclaims OWNER TO postgres;

--
-- Name: userclaims_id_seq; Type: SEQUENCE; Schema: adminapp; Owner: postgres
--

ALTER TABLE adminapp.userclaims ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp.userclaims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: userlogins; Type: TABLE; Schema: adminapp; Owner: postgres
--

CREATE TABLE adminapp.userlogins (
    loginprovider character varying(128) NOT NULL,
    providerkey character varying(128) NOT NULL,
    userid character varying(128) NOT NULL
);


ALTER TABLE adminapp.userlogins OWNER TO postgres;

--
-- Name: userroles; Type: TABLE; Schema: adminapp; Owner: postgres
--

CREATE TABLE adminapp.userroles (
    userid character varying(128) NOT NULL,
    roleid character varying(128) NOT NULL
);


ALTER TABLE adminapp.userroles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: adminapp; Owner: postgres
--

CREATE TABLE adminapp.users (
    id character varying(128) NOT NULL,
    email character varying(256),
    emailconfirmed boolean NOT NULL,
    passwordhash character varying,
    securitystamp character varying,
    phonenumber character varying,
    phonenumberconfirmed boolean NOT NULL,
    twofactorenabled boolean NOT NULL,
    lockoutenddateutc timestamp without time zone,
    lockoutenabled boolean NOT NULL,
    accessfailedcount integer NOT NULL,
    username character varying(256) NOT NULL
);


ALTER TABLE adminapp.users OWNER TO postgres;

--
-- Name: counter; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.counter (
    id bigint NOT NULL,
    key character varying NOT NULL,
    value bigint NOT NULL,
    expireat timestamp without time zone
);


ALTER TABLE adminapp_hangfire.counter OWNER TO postgres;

--
-- Name: counter_id_seq; Type: SEQUENCE; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE adminapp_hangfire.counter ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp_hangfire.counter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hash; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.hash (
    id bigint NOT NULL,
    key character varying NOT NULL,
    field character varying NOT NULL,
    value character varying,
    expireat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE adminapp_hangfire.hash OWNER TO postgres;

--
-- Name: hash_id_seq; Type: SEQUENCE; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE adminapp_hangfire.hash ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp_hangfire.hash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: job; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.job (
    id bigint NOT NULL,
    stateid bigint,
    statename character varying,
    invocationdata character varying NOT NULL,
    arguments character varying NOT NULL,
    createdat timestamp without time zone NOT NULL,
    expireat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE adminapp_hangfire.job OWNER TO postgres;

--
-- Name: job_id_seq; Type: SEQUENCE; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE adminapp_hangfire.job ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp_hangfire.job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: jobparameter; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.jobparameter (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    name character varying NOT NULL,
    value character varying,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE adminapp_hangfire.jobparameter OWNER TO postgres;

--
-- Name: jobparameter_id_seq; Type: SEQUENCE; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE adminapp_hangfire.jobparameter ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp_hangfire.jobparameter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: jobqueue; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.jobqueue (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    queue character varying NOT NULL,
    fetchedat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE adminapp_hangfire.jobqueue OWNER TO postgres;

--
-- Name: jobqueue_id_seq; Type: SEQUENCE; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE adminapp_hangfire.jobqueue ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp_hangfire.jobqueue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: list; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.list (
    id bigint NOT NULL,
    key character varying NOT NULL,
    value character varying,
    expireat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE adminapp_hangfire.list OWNER TO postgres;

--
-- Name: list_id_seq; Type: SEQUENCE; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE adminapp_hangfire.list ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp_hangfire.list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: lock; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.lock (
    resource character varying NOT NULL,
    updatecount integer DEFAULT 0 NOT NULL,
    acquired timestamp without time zone
);


ALTER TABLE adminapp_hangfire.lock OWNER TO postgres;

--
-- Name: schema; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.schema (
    version integer NOT NULL
);


ALTER TABLE adminapp_hangfire.schema OWNER TO postgres;

--
-- Name: server; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.server (
    id character varying NOT NULL,
    data character varying,
    lastheartbeat timestamp without time zone NOT NULL,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE adminapp_hangfire.server OWNER TO postgres;

--
-- Name: set; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.set (
    id bigint NOT NULL,
    key character varying NOT NULL,
    score double precision NOT NULL,
    value character varying NOT NULL,
    expireat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE adminapp_hangfire.set OWNER TO postgres;

--
-- Name: set_id_seq; Type: SEQUENCE; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE adminapp_hangfire.set ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp_hangfire.set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: state; Type: TABLE; Schema: adminapp_hangfire; Owner: postgres
--

CREATE TABLE adminapp_hangfire.state (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    name character varying NOT NULL,
    reason character varying,
    createdat timestamp without time zone NOT NULL,
    data character varying,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE adminapp_hangfire.state OWNER TO postgres;

--
-- Name: state_id_seq; Type: SEQUENCE; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE adminapp_hangfire.state ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME adminapp_hangfire.state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: apiclientapplicationeducationorganizations; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.apiclientapplicationeducationorganizations (
    apiclient_apiclientid integer NOT NULL,
    applicationedorg_applicationedorgid integer NOT NULL
);


ALTER TABLE dbo.apiclientapplicationeducationorganizations OWNER TO postgres;

--
-- Name: apiclientownershiptokens; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.apiclientownershiptokens (
    apiclientownershiptokenid integer NOT NULL,
    apiclient_apiclientid integer NOT NULL,
    ownershiptoken_ownershiptokenid smallint NOT NULL
);


ALTER TABLE dbo.apiclientownershiptokens OWNER TO postgres;

--
-- Name: apiclientownershiptokens_apiclientownershiptokenid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.apiclientownershiptokens_apiclientownershiptokenid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.apiclientownershiptokens_apiclientownershiptokenid_seq OWNER TO postgres;

--
-- Name: apiclientownershiptokens_apiclientownershiptokenid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.apiclientownershiptokens_apiclientownershiptokenid_seq OWNED BY dbo.apiclientownershiptokens.apiclientownershiptokenid;


--
-- Name: apiclients; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.apiclients (
    apiclientid integer NOT NULL,
    key character varying(50) NOT NULL,
    secret character varying(100) NOT NULL,
    name character varying(50) NOT NULL,
    isapproved boolean NOT NULL,
    usesandbox boolean NOT NULL,
    sandboxtype integer NOT NULL,
    application_applicationid integer,
    user_userid integer,
    keystatus character varying,
    challengeid character varying,
    challengeexpiry timestamp without time zone,
    activationcode character varying,
    activationretried integer,
    secretishashed boolean DEFAULT false NOT NULL,
    studentidentificationsystemdescriptor character varying(306),
    creatorownershiptokenid_ownershiptokenid smallint
);


ALTER TABLE dbo.apiclients OWNER TO postgres;

--
-- Name: apiclients_apiclientid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.apiclients_apiclientid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.apiclients_apiclientid_seq OWNER TO postgres;

--
-- Name: apiclients_apiclientid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.apiclients_apiclientid_seq OWNED BY dbo.apiclients.apiclientid;


--
-- Name: applicationeducationorganizations; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.applicationeducationorganizations (
    applicationeducationorganizationid integer NOT NULL,
    educationorganizationid integer NOT NULL,
    application_applicationid integer
);


ALTER TABLE dbo.applicationeducationorganizations OWNER TO postgres;

--
-- Name: applicationeducationorganizat_applicationeducationorganizat_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.applicationeducationorganizat_applicationeducationorganizat_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.applicationeducationorganizat_applicationeducationorganizat_seq OWNER TO postgres;

--
-- Name: applicationeducationorganizat_applicationeducationorganizat_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.applicationeducationorganizat_applicationeducationorganizat_seq OWNED BY dbo.applicationeducationorganizations.applicationeducationorganizationid;


--
-- Name: applications; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.applications (
    applicationid integer NOT NULL,
    applicationname character varying,
    vendor_vendorid integer,
    claimsetname character varying(255),
    odsinstance_odsinstanceid integer,
    operationalcontexturi character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE dbo.applications OWNER TO postgres;

--
-- Name: applications_applicationid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.applications_applicationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.applications_applicationid_seq OWNER TO postgres;

--
-- Name: applications_applicationid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.applications_applicationid_seq OWNED BY dbo.applications.applicationid;


--
-- Name: clientaccesstokens; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.clientaccesstokens (
    id uuid NOT NULL,
    expiration timestamp without time zone NOT NULL,
    scope character varying,
    apiclient_apiclientid integer
);


ALTER TABLE dbo.clientaccesstokens OWNER TO postgres;

--
-- Name: odsinstancecomponents; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.odsinstancecomponents (
    odsinstancecomponentid integer NOT NULL,
    name character varying(100) NOT NULL,
    url character varying(200) NOT NULL,
    version character varying(20) NOT NULL,
    odsinstance_odsinstanceid integer NOT NULL
);


ALTER TABLE dbo.odsinstancecomponents OWNER TO postgres;

--
-- Name: odsinstancecomponents_odsinstancecomponentid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.odsinstancecomponents_odsinstancecomponentid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.odsinstancecomponents_odsinstancecomponentid_seq OWNER TO postgres;

--
-- Name: odsinstancecomponents_odsinstancecomponentid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.odsinstancecomponents_odsinstancecomponentid_seq OWNED BY dbo.odsinstancecomponents.odsinstancecomponentid;


--
-- Name: odsinstances; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.odsinstances (
    odsinstanceid integer NOT NULL,
    name character varying(100) NOT NULL,
    instancetype character varying(100) NOT NULL,
    status character varying(100) NOT NULL,
    isextended boolean NOT NULL,
    version character varying(20) NOT NULL
);


ALTER TABLE dbo.odsinstances OWNER TO postgres;

--
-- Name: odsinstances_odsinstanceid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.odsinstances_odsinstanceid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.odsinstances_odsinstanceid_seq OWNER TO postgres;

--
-- Name: odsinstances_odsinstanceid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.odsinstances_odsinstanceid_seq OWNED BY dbo.odsinstances.odsinstanceid;


--
-- Name: ownershiptokens; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.ownershiptokens (
    ownershiptokenid smallint NOT NULL,
    description character varying(50)
);


ALTER TABLE dbo.ownershiptokens OWNER TO postgres;

--
-- Name: ownershiptokens_ownershiptokenid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.ownershiptokens_ownershiptokenid_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.ownershiptokens_ownershiptokenid_seq OWNER TO postgres;

--
-- Name: ownershiptokens_ownershiptokenid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.ownershiptokens_ownershiptokenid_seq OWNED BY dbo.ownershiptokens.ownershiptokenid;


--
-- Name: profileapplications; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.profileapplications (
    profile_profileid integer NOT NULL,
    application_applicationid integer NOT NULL
);


ALTER TABLE dbo.profileapplications OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.profiles (
    profileid integer NOT NULL,
    profilename character varying NOT NULL
);


ALTER TABLE dbo.profiles OWNER TO postgres;

--
-- Name: profiles_profileid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.profiles_profileid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.profiles_profileid_seq OWNER TO postgres;

--
-- Name: profiles_profileid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.profiles_profileid_seq OWNED BY dbo.profiles.profileid;


--
-- Name: users; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.users (
    userid integer NOT NULL,
    email character varying,
    fullname character varying,
    vendor_vendorid integer
);


ALTER TABLE dbo.users OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.users_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.users_userid_seq OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.users_userid_seq OWNED BY dbo.users.userid;


--
-- Name: vendornamespaceprefixes; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.vendornamespaceprefixes (
    vendornamespaceprefixid integer NOT NULL,
    namespaceprefix character varying(255) NOT NULL,
    vendor_vendorid integer NOT NULL
);


ALTER TABLE dbo.vendornamespaceprefixes OWNER TO postgres;

--
-- Name: vendornamespaceprefixes_vendornamespaceprefixid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.vendornamespaceprefixes_vendornamespaceprefixid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.vendornamespaceprefixes_vendornamespaceprefixid_seq OWNER TO postgres;

--
-- Name: vendornamespaceprefixes_vendornamespaceprefixid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.vendornamespaceprefixes_vendornamespaceprefixid_seq OWNED BY dbo.vendornamespaceprefixes.vendornamespaceprefixid;


--
-- Name: vendors; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.vendors (
    vendorid integer NOT NULL,
    vendorname character varying
);


ALTER TABLE dbo.vendors OWNER TO postgres;

--
-- Name: vendors_vendorid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.vendors_vendorid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.vendors_vendorid_seq OWNER TO postgres;

--
-- Name: vendors_vendorid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.vendors_vendorid_seq OWNED BY dbo.vendors.vendorid;


--
-- Name: DeployJournal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DeployJournal" (
    schemaversionsid integer NOT NULL,
    scriptname character varying(255) NOT NULL,
    applied timestamp without time zone NOT NULL
);


ALTER TABLE public."DeployJournal" OWNER TO postgres;

--
-- Name: DeployJournal_schemaversionsid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."DeployJournal_schemaversionsid_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."DeployJournal_schemaversionsid_seq" OWNER TO postgres;

--
-- Name: DeployJournal_schemaversionsid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."DeployJournal_schemaversionsid_seq" OWNED BY public."DeployJournal".schemaversionsid;


--
-- Name: apiclientownershiptokens apiclientownershiptokenid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclientownershiptokens ALTER COLUMN apiclientownershiptokenid SET DEFAULT nextval('dbo.apiclientownershiptokens_apiclientownershiptokenid_seq'::regclass);


--
-- Name: apiclients apiclientid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclients ALTER COLUMN apiclientid SET DEFAULT nextval('dbo.apiclients_apiclientid_seq'::regclass);


--
-- Name: applicationeducationorganizations applicationeducationorganizationid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applicationeducationorganizations ALTER COLUMN applicationeducationorganizationid SET DEFAULT nextval('dbo.applicationeducationorganizat_applicationeducationorganizat_seq'::regclass);


--
-- Name: applications applicationid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applications ALTER COLUMN applicationid SET DEFAULT nextval('dbo.applications_applicationid_seq'::regclass);


--
-- Name: odsinstancecomponents odsinstancecomponentid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.odsinstancecomponents ALTER COLUMN odsinstancecomponentid SET DEFAULT nextval('dbo.odsinstancecomponents_odsinstancecomponentid_seq'::regclass);


--
-- Name: odsinstances odsinstanceid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.odsinstances ALTER COLUMN odsinstanceid SET DEFAULT nextval('dbo.odsinstances_odsinstanceid_seq'::regclass);


--
-- Name: ownershiptokens ownershiptokenid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.ownershiptokens ALTER COLUMN ownershiptokenid SET DEFAULT nextval('dbo.ownershiptokens_ownershiptokenid_seq'::regclass);


--
-- Name: profiles profileid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.profiles ALTER COLUMN profileid SET DEFAULT nextval('dbo.profiles_profileid_seq'::regclass);


--
-- Name: users userid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.users ALTER COLUMN userid SET DEFAULT nextval('dbo.users_userid_seq'::regclass);


--
-- Name: vendornamespaceprefixes vendornamespaceprefixid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.vendornamespaceprefixes ALTER COLUMN vendornamespaceprefixid SET DEFAULT nextval('dbo.vendornamespaceprefixes_vendornamespaceprefixid_seq'::regclass);


--
-- Name: vendors vendorid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.vendors ALTER COLUMN vendorid SET DEFAULT nextval('dbo.vendors_vendorid_seq'::regclass);


--
-- Name: DeployJournal schemaversionsid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DeployJournal" ALTER COLUMN schemaversionsid SET DEFAULT nextval('public."DeployJournal_schemaversionsid_seq"'::regclass);


--
-- Data for Name: applicationconfigurations; Type: TABLE DATA; Schema: adminapp; Owner: postgres
--

COPY adminapp.applicationconfigurations (id, allowuserregistration) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: adminapp; Owner: postgres
--

COPY adminapp.roles (id, name) FROM stdin;
\.


--
-- Data for Name: secretconfigurations; Type: TABLE DATA; Schema: adminapp; Owner: postgres
--

COPY adminapp.secretconfigurations (id, encrypteddata) FROM stdin;
\.


--
-- Data for Name: userclaims; Type: TABLE DATA; Schema: adminapp; Owner: postgres
--

COPY adminapp.userclaims (id, userid, claimtype, claimvalue) FROM stdin;
\.


--
-- Data for Name: userlogins; Type: TABLE DATA; Schema: adminapp; Owner: postgres
--

COPY adminapp.userlogins (loginprovider, providerkey, userid) FROM stdin;
\.


--
-- Data for Name: userroles; Type: TABLE DATA; Schema: adminapp; Owner: postgres
--

COPY adminapp.userroles (userid, roleid) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: adminapp; Owner: postgres
--

COPY adminapp.users (id, email, emailconfirmed, passwordhash, securitystamp, phonenumber, phonenumberconfirmed, twofactorenabled, lockoutenddateutc, lockoutenabled, accessfailedcount, username) FROM stdin;
\.


--
-- Data for Name: counter; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.counter (id, key, value, expireat) FROM stdin;
\.


--
-- Data for Name: hash; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.hash (id, key, field, value, expireat, updatecount) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.job (id, stateid, statename, invocationdata, arguments, createdat, expireat, updatecount) FROM stdin;
\.


--
-- Data for Name: jobparameter; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.jobparameter (id, jobid, name, value, updatecount) FROM stdin;
\.


--
-- Data for Name: jobqueue; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.jobqueue (id, jobid, queue, fetchedat, updatecount) FROM stdin;
\.


--
-- Data for Name: list; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.list (id, key, value, expireat, updatecount) FROM stdin;
\.


--
-- Data for Name: lock; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.lock (resource, updatecount, acquired) FROM stdin;
\.


--
-- Data for Name: schema; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.schema (version) FROM stdin;
\.


--
-- Data for Name: server; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.server (id, data, lastheartbeat, updatecount) FROM stdin;
\.


--
-- Data for Name: set; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.set (id, key, score, value, expireat, updatecount) FROM stdin;
\.


--
-- Data for Name: state; Type: TABLE DATA; Schema: adminapp_hangfire; Owner: postgres
--

COPY adminapp_hangfire.state (id, jobid, name, reason, createdat, data, updatecount) FROM stdin;
\.


--
-- Data for Name: apiclientapplicationeducationorganizations; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.apiclientapplicationeducationorganizations (apiclient_apiclientid, applicationedorg_applicationedorgid) FROM stdin;
\.


--
-- Data for Name: apiclientownershiptokens; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.apiclientownershiptokens (apiclientownershiptokenid, apiclient_apiclientid, ownershiptoken_ownershiptokenid) FROM stdin;
\.


--
-- Data for Name: apiclients; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.apiclients (apiclientid, key, secret, name, isapproved, usesandbox, sandboxtype, application_applicationid, user_userid, keystatus, challengeid, challengeexpiry, activationcode, activationretried, secretishashed, studentidentificationsystemdescriptor, creatorownershiptokenid_ownershiptokenid) FROM stdin;
\.


--
-- Data for Name: applicationeducationorganizations; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.applicationeducationorganizations (applicationeducationorganizationid, educationorganizationid, application_applicationid) FROM stdin;
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.applications (applicationid, applicationname, vendor_vendorid, claimsetname, odsinstance_odsinstanceid, operationalcontexturi) FROM stdin;
\.


--
-- Data for Name: clientaccesstokens; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.clientaccesstokens (id, expiration, scope, apiclient_apiclientid) FROM stdin;
\.


--
-- Data for Name: odsinstancecomponents; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.odsinstancecomponents (odsinstancecomponentid, name, url, version, odsinstance_odsinstanceid) FROM stdin;
\.


--
-- Data for Name: odsinstances; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.odsinstances (odsinstanceid, name, instancetype, status, isextended, version) FROM stdin;
\.


--
-- Data for Name: ownershiptokens; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.ownershiptokens (ownershiptokenid, description) FROM stdin;
\.


--
-- Data for Name: profileapplications; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.profileapplications (profile_profileid, application_applicationid) FROM stdin;
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.profiles (profileid, profilename) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.users (userid, email, fullname, vendor_vendorid) FROM stdin;
\.


--
-- Data for Name: vendornamespaceprefixes; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.vendornamespaceprefixes (vendornamespaceprefixid, namespaceprefix, vendor_vendorid) FROM stdin;
\.


--
-- Data for Name: vendors; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.vendors (vendorid, vendorname) FROM stdin;
\.


--
-- Data for Name: DeployJournal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DeployJournal" (schemaversionsid, scriptname, applied) FROM stdin;
1	Artifacts.PgSql.Structure.Admin.0010-Schemas.sql	2020-04-22 18:11:56.138217
2	Artifacts.PgSql.Structure.Admin.0020-Tables.sql	2020-04-22 18:11:56.457995
3	Artifacts.PgSql.Structure.Admin.0030-ForeignKey.sql	2020-04-22 18:11:56.484121
4	Artifacts.PgSql.Structure.Admin.0040-IdColumnIndexes.sql	2020-04-22 18:11:56.516283
5	Artifacts.PgSql.Structure.Admin.0050-StoredProcedures.sql	2020-04-22 18:11:56.765757
6	Artifacts.PgSql.Structure.Admin.0051-Rename-AccessToken-Function.sql	2020-04-22 18:11:56.769035
7	Artifacts.PgSql.Structure.Admin.0060-Add-OwnershipTokens.sql	2020-04-22 18:11:56.775623
8	Artifacts.PgSql.Structure.Admin.0061-Add-ApiClientsOwnershipTokens.sql	2020-04-22 18:11:56.78841
9	Artifacts.PgSql.Structure.Admin.0062-Add-CreatorOwnershipTokenId-To-ApiClients.sql	2020-04-22 18:11:56.794033
10	Artifacts.PgSql.Structure.Admin.0063-Update-GetClientForToken-For-Record-Level-Ownership.sql	2020-04-22 18:11:56.796448
11	Artifacts.PgSql.Structure.Admin.0065-Update-GetClientForToken-For-Scope-Support.sql	2020-04-22 18:11:56.798822
12	EdFi.Ods.AdminApp.Web.Artifacts.PgSql.Structure.Admin.202002041102-CreateAdminAppSchema.sql	2020-04-22 18:11:56.940587
13	EdFi.Ods.AdminApp.Web.Artifacts.PgSql.Structure.Admin.202002051418-CreateSecretConfigurationTable.sql	2020-04-22 18:11:56.950758
14	EdFi.Ods.AdminApp.Web.Artifacts.PgSql.Structure.Admin.202002071430-CreateAspNetIdentityTables.sql	2020-04-22 18:11:56.995137
15	EdFi.Ods.AdminApp.Web.Artifacts.PgSql.Structure.Admin.202002171310-CreateApplicationConfigurationsTable.sql	2020-04-22 18:11:57.001838
16	EdFi.Ods.AdminApp.Web.Artifacts.PgSql.Structure.Admin.202003300900-CreateHangfireSchemaAndTables.sql	2020-04-22 18:11:57.111059
\.


--
-- Name: applicationconfigurations_id_seq; Type: SEQUENCE SET; Schema: adminapp; Owner: postgres
--

SELECT pg_catalog.setval('adminapp.applicationconfigurations_id_seq', 1, false);


--
-- Name: secretconfigurations_id_seq; Type: SEQUENCE SET; Schema: adminapp; Owner: postgres
--

SELECT pg_catalog.setval('adminapp.secretconfigurations_id_seq', 1, false);


--
-- Name: userclaims_id_seq; Type: SEQUENCE SET; Schema: adminapp; Owner: postgres
--

SELECT pg_catalog.setval('adminapp.userclaims_id_seq', 1, false);


--
-- Name: counter_id_seq; Type: SEQUENCE SET; Schema: adminapp_hangfire; Owner: postgres
--

SELECT pg_catalog.setval('adminapp_hangfire.counter_id_seq', 1, false);


--
-- Name: hash_id_seq; Type: SEQUENCE SET; Schema: adminapp_hangfire; Owner: postgres
--

SELECT pg_catalog.setval('adminapp_hangfire.hash_id_seq', 1, false);


--
-- Name: job_id_seq; Type: SEQUENCE SET; Schema: adminapp_hangfire; Owner: postgres
--

SELECT pg_catalog.setval('adminapp_hangfire.job_id_seq', 1, false);


--
-- Name: jobparameter_id_seq; Type: SEQUENCE SET; Schema: adminapp_hangfire; Owner: postgres
--

SELECT pg_catalog.setval('adminapp_hangfire.jobparameter_id_seq', 1, false);


--
-- Name: jobqueue_id_seq; Type: SEQUENCE SET; Schema: adminapp_hangfire; Owner: postgres
--

SELECT pg_catalog.setval('adminapp_hangfire.jobqueue_id_seq', 1, false);


--
-- Name: list_id_seq; Type: SEQUENCE SET; Schema: adminapp_hangfire; Owner: postgres
--

SELECT pg_catalog.setval('adminapp_hangfire.list_id_seq', 1, false);


--
-- Name: set_id_seq; Type: SEQUENCE SET; Schema: adminapp_hangfire; Owner: postgres
--

SELECT pg_catalog.setval('adminapp_hangfire.set_id_seq', 1, false);


--
-- Name: state_id_seq; Type: SEQUENCE SET; Schema: adminapp_hangfire; Owner: postgres
--

SELECT pg_catalog.setval('adminapp_hangfire.state_id_seq', 1, false);


--
-- Name: apiclientownershiptokens_apiclientownershiptokenid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.apiclientownershiptokens_apiclientownershiptokenid_seq', 1, false);


--
-- Name: apiclients_apiclientid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.apiclients_apiclientid_seq', 1, false);


--
-- Name: applicationeducationorganizat_applicationeducationorganizat_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.applicationeducationorganizat_applicationeducationorganizat_seq', 1, false);


--
-- Name: applications_applicationid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.applications_applicationid_seq', 1, false);


--
-- Name: odsinstancecomponents_odsinstancecomponentid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.odsinstancecomponents_odsinstancecomponentid_seq', 1, false);


--
-- Name: odsinstances_odsinstanceid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.odsinstances_odsinstanceid_seq', 1, false);


--
-- Name: ownershiptokens_ownershiptokenid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.ownershiptokens_ownershiptokenid_seq', 1, false);


--
-- Name: profiles_profileid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.profiles_profileid_seq', 1, false);


--
-- Name: users_userid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.users_userid_seq', 1, false);


--
-- Name: vendornamespaceprefixes_vendornamespaceprefixid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.vendornamespaceprefixes_vendornamespaceprefixid_seq', 1, false);


--
-- Name: vendors_vendorid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.vendors_vendorid_seq', 1, false);


--
-- Name: DeployJournal_schemaversionsid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."DeployJournal_schemaversionsid_seq"', 16, true);


--
-- Name: applicationconfigurations pk_applicationconfigurations; Type: CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.applicationconfigurations
    ADD CONSTRAINT pk_applicationconfigurations PRIMARY KEY (id);


--
-- Name: roles pk_roles; Type: CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.roles
    ADD CONSTRAINT pk_roles PRIMARY KEY (id);


--
-- Name: secretconfigurations pk_secretconfigurations; Type: CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.secretconfigurations
    ADD CONSTRAINT pk_secretconfigurations PRIMARY KEY (id);


--
-- Name: userclaims pk_userclaims; Type: CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.userclaims
    ADD CONSTRAINT pk_userclaims PRIMARY KEY (id);


--
-- Name: userlogins pk_userlogins; Type: CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.userlogins
    ADD CONSTRAINT pk_userlogins PRIMARY KEY (loginprovider, providerkey, userid);


--
-- Name: userroles pk_userroles; Type: CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.userroles
    ADD CONSTRAINT pk_userroles PRIMARY KEY (userid, roleid);


--
-- Name: users pk_users; Type: CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.users
    ADD CONSTRAINT pk_users PRIMARY KEY (id);


--
-- Name: counter counter_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.counter
    ADD CONSTRAINT counter_pkey PRIMARY KEY (id);


--
-- Name: hash hash_key_field_key; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.hash
    ADD CONSTRAINT hash_key_field_key UNIQUE (key, field);


--
-- Name: hash hash_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.hash
    ADD CONSTRAINT hash_pkey PRIMARY KEY (id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: jobparameter jobparameter_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.jobparameter
    ADD CONSTRAINT jobparameter_pkey PRIMARY KEY (id);


--
-- Name: jobqueue jobqueue_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.jobqueue
    ADD CONSTRAINT jobqueue_pkey PRIMARY KEY (id);


--
-- Name: list list_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.list
    ADD CONSTRAINT list_pkey PRIMARY KEY (id);


--
-- Name: lock lock_resource_key; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.lock
    ADD CONSTRAINT lock_resource_key UNIQUE (resource);


--
-- Name: schema schema_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.schema
    ADD CONSTRAINT schema_pkey PRIMARY KEY (version);


--
-- Name: server server_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.server
    ADD CONSTRAINT server_pkey PRIMARY KEY (id);


--
-- Name: set set_key_value_key; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.set
    ADD CONSTRAINT set_key_value_key UNIQUE (key, value);


--
-- Name: set set_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.set
    ADD CONSTRAINT set_pkey PRIMARY KEY (id);


--
-- Name: state state_pkey; Type: CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.state
    ADD CONSTRAINT state_pkey PRIMARY KEY (id);


--
-- Name: apiclientapplicationeducationorganizations apiclientapplicationeducationorganizations_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclientapplicationeducationorganizations
    ADD CONSTRAINT apiclientapplicationeducationorganizations_pk PRIMARY KEY (apiclient_apiclientid, applicationedorg_applicationedorgid);


--
-- Name: apiclientownershiptokens apiclientownershiptokens_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclientownershiptokens
    ADD CONSTRAINT apiclientownershiptokens_pkey PRIMARY KEY (apiclientownershiptokenid);


--
-- Name: apiclients apiclients_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclients
    ADD CONSTRAINT apiclients_pk PRIMARY KEY (apiclientid);


--
-- Name: applicationeducationorganizations applicationeducationorganizations_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applicationeducationorganizations
    ADD CONSTRAINT applicationeducationorganizations_pk PRIMARY KEY (applicationeducationorganizationid);


--
-- Name: applications applications_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applications
    ADD CONSTRAINT applications_pk PRIMARY KEY (applicationid);


--
-- Name: clientaccesstokens clientaccesstokens_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.clientaccesstokens
    ADD CONSTRAINT clientaccesstokens_pk PRIMARY KEY (id);


--
-- Name: odsinstancecomponents odsinstancecomponents_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.odsinstancecomponents
    ADD CONSTRAINT odsinstancecomponents_pk PRIMARY KEY (odsinstancecomponentid);


--
-- Name: odsinstances odsinstances_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.odsinstances
    ADD CONSTRAINT odsinstances_pk PRIMARY KEY (odsinstanceid);


--
-- Name: ownershiptokens ownershiptokens_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.ownershiptokens
    ADD CONSTRAINT ownershiptokens_pkey PRIMARY KEY (ownershiptokenid);


--
-- Name: profileapplications profileapplications_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.profileapplications
    ADD CONSTRAINT profileapplications_pk PRIMARY KEY (profile_profileid, application_applicationid);


--
-- Name: profiles profiles_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.profiles
    ADD CONSTRAINT profiles_pk PRIMARY KEY (profileid);


--
-- Name: users users_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.users
    ADD CONSTRAINT users_pk PRIMARY KEY (userid);


--
-- Name: vendornamespaceprefixes vendornamespaceprefixes_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.vendornamespaceprefixes
    ADD CONSTRAINT vendornamespaceprefixes_pk PRIMARY KEY (vendornamespaceprefixid);


--
-- Name: vendors vendors_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.vendors
    ADD CONSTRAINT vendors_pk PRIMARY KEY (vendorid);


--
-- Name: DeployJournal PK_DeployJournal_Id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DeployJournal"
    ADD CONSTRAINT "PK_DeployJournal_Id" PRIMARY KEY (schemaversionsid);


--
-- Name: ix_userclaims_userid; Type: INDEX; Schema: adminapp; Owner: postgres
--

CREATE INDEX ix_userclaims_userid ON adminapp.userclaims USING btree (userid);


--
-- Name: ix_userlogins_userid; Type: INDEX; Schema: adminapp; Owner: postgres
--

CREATE INDEX ix_userlogins_userid ON adminapp.userlogins USING btree (userid);


--
-- Name: ix_userroles_roleid; Type: INDEX; Schema: adminapp; Owner: postgres
--

CREATE INDEX ix_userroles_roleid ON adminapp.userroles USING btree (roleid);


--
-- Name: ix_userroles_userid; Type: INDEX; Schema: adminapp; Owner: postgres
--

CREATE INDEX ix_userroles_userid ON adminapp.userroles USING btree (userid);


--
-- Name: uq_roles_name; Type: INDEX; Schema: adminapp; Owner: postgres
--

CREATE UNIQUE INDEX uq_roles_name ON adminapp.roles USING btree (name);


--
-- Name: uq_users_username; Type: INDEX; Schema: adminapp; Owner: postgres
--

CREATE UNIQUE INDEX uq_users_username ON adminapp.users USING btree (username);


--
-- Name: ix_hangfire_counter_expireat; Type: INDEX; Schema: adminapp_hangfire; Owner: postgres
--

CREATE INDEX ix_hangfire_counter_expireat ON adminapp_hangfire.counter USING btree (expireat);


--
-- Name: ix_hangfire_counter_key; Type: INDEX; Schema: adminapp_hangfire; Owner: postgres
--

CREATE INDEX ix_hangfire_counter_key ON adminapp_hangfire.counter USING btree (key);


--
-- Name: ix_hangfire_job_statename; Type: INDEX; Schema: adminapp_hangfire; Owner: postgres
--

CREATE INDEX ix_hangfire_job_statename ON adminapp_hangfire.job USING btree (statename);


--
-- Name: ix_hangfire_jobparameter_jobidandname; Type: INDEX; Schema: adminapp_hangfire; Owner: postgres
--

CREATE INDEX ix_hangfire_jobparameter_jobidandname ON adminapp_hangfire.jobparameter USING btree (jobid, name);


--
-- Name: ix_hangfire_jobqueue_jobidandqueue; Type: INDEX; Schema: adminapp_hangfire; Owner: postgres
--

CREATE INDEX ix_hangfire_jobqueue_jobidandqueue ON adminapp_hangfire.jobqueue USING btree (jobid, queue);


--
-- Name: ix_hangfire_jobqueue_queueandfetchedat; Type: INDEX; Schema: adminapp_hangfire; Owner: postgres
--

CREATE INDEX ix_hangfire_jobqueue_queueandfetchedat ON adminapp_hangfire.jobqueue USING btree (queue, fetchedat);


--
-- Name: ix_hangfire_state_jobid; Type: INDEX; Schema: adminapp_hangfire; Owner: postgres
--

CREATE INDEX ix_hangfire_state_jobid ON adminapp_hangfire.state USING btree (jobid);


--
-- Name: ix_apiclient_apiclientid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_apiclient_apiclientid ON dbo.apiclientapplicationeducationorganizations USING btree (apiclient_apiclientid);


--
-- Name: ix_application_applicationid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_application_applicationid ON dbo.apiclients USING btree (application_applicationid);


--
-- Name: ix_applicationedorg_applicationedorgid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_applicationedorg_applicationedorgid ON dbo.apiclientapplicationeducationorganizations USING btree (applicationedorg_applicationedorgid);


--
-- Name: ix_creatorownershiptokenid_ownershiptokenid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_creatorownershiptokenid_ownershiptokenid ON dbo.apiclients USING btree (creatorownershiptokenid_ownershiptokenid);


--
-- Name: ix_odsinstance_odsinstanceid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_odsinstance_odsinstanceid ON dbo.applications USING btree (odsinstance_odsinstanceid);


--
-- Name: ix_ownershiptoken_ownershiptokenid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_ownershiptoken_ownershiptokenid ON dbo.apiclientownershiptokens USING btree (ownershiptoken_ownershiptokenid);


--
-- Name: ix_profile_profileid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_profile_profileid ON dbo.profileapplications USING btree (profile_profileid);


--
-- Name: ix_user_userid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_user_userid ON dbo.apiclients USING btree (user_userid);


--
-- Name: ix_vendor_vendorid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_vendor_vendorid ON dbo.applications USING btree (vendor_vendorid);


--
-- Name: ux_name_instancetype; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX ux_name_instancetype ON dbo.odsinstances USING btree (name, instancetype);


--
-- Name: ux_odsinstance_odsinstanceid_name; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX ux_odsinstance_odsinstanceid_name ON dbo.odsinstancecomponents USING btree (odsinstance_odsinstanceid, name);


--
-- Name: userclaims fk_userclaims_users_id; Type: FK CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.userclaims
    ADD CONSTRAINT fk_userclaims_users_id FOREIGN KEY (userid) REFERENCES adminapp.users(id) ON DELETE CASCADE;


--
-- Name: userlogins fk_userlogins_users_id; Type: FK CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.userlogins
    ADD CONSTRAINT fk_userlogins_users_id FOREIGN KEY (userid) REFERENCES adminapp.users(id) ON DELETE CASCADE;


--
-- Name: userroles fk_userroles_roles_id; Type: FK CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.userroles
    ADD CONSTRAINT fk_userroles_roles_id FOREIGN KEY (roleid) REFERENCES adminapp.roles(id) ON DELETE CASCADE;


--
-- Name: userroles fk_userroles_users_id; Type: FK CONSTRAINT; Schema: adminapp; Owner: postgres
--

ALTER TABLE ONLY adminapp.userroles
    ADD CONSTRAINT fk_userroles_users_id FOREIGN KEY (userid) REFERENCES adminapp.users(id) ON DELETE CASCADE;


--
-- Name: jobparameter jobparameter_jobid_fkey; Type: FK CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.jobparameter
    ADD CONSTRAINT jobparameter_jobid_fkey FOREIGN KEY (jobid) REFERENCES adminapp_hangfire.job(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: state state_jobid_fkey; Type: FK CONSTRAINT; Schema: adminapp_hangfire; Owner: postgres
--

ALTER TABLE ONLY adminapp_hangfire.state
    ADD CONSTRAINT state_jobid_fkey FOREIGN KEY (jobid) REFERENCES adminapp_hangfire.job(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: apiclientapplicationeducationorganizations fk_apiclientapplicationedorg_applicationedorg; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclientapplicationeducationorganizations
    ADD CONSTRAINT fk_apiclientapplicationedorg_applicationedorg FOREIGN KEY (applicationedorg_applicationedorgid) REFERENCES dbo.applicationeducationorganizations(applicationeducationorganizationid) ON DELETE CASCADE;


--
-- Name: apiclientapplicationeducationorganizations fk_apiclientapplicationeducationorganizations_apiclients; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclientapplicationeducationorganizations
    ADD CONSTRAINT fk_apiclientapplicationeducationorganizations_apiclients FOREIGN KEY (apiclient_apiclientid) REFERENCES dbo.apiclients(apiclientid) ON DELETE CASCADE;


--
-- Name: apiclientownershiptokens fk_apiclientownershiptokens_apiclients_apiclient_apiclientid; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclientownershiptokens
    ADD CONSTRAINT fk_apiclientownershiptokens_apiclients_apiclient_apiclientid FOREIGN KEY (apiclient_apiclientid) REFERENCES dbo.apiclients(apiclientid) ON DELETE CASCADE;


--
-- Name: apiclientownershiptokens fk_apiclientownershiptokens_ownershiptokens_ownershiptoken_owne; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclientownershiptokens
    ADD CONSTRAINT fk_apiclientownershiptokens_ownershiptokens_ownershiptoken_owne FOREIGN KEY (ownershiptoken_ownershiptokenid) REFERENCES dbo.ownershiptokens(ownershiptokenid) ON DELETE CASCADE;


--
-- Name: apiclients fk_apiclients_applications; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclients
    ADD CONSTRAINT fk_apiclients_applications FOREIGN KEY (application_applicationid) REFERENCES dbo.applications(applicationid);


--
-- Name: apiclients fk_apiclients_creatorownershiptokenid_ownershiptokenid; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclients
    ADD CONSTRAINT fk_apiclients_creatorownershiptokenid_ownershiptokenid FOREIGN KEY (creatorownershiptokenid_ownershiptokenid) REFERENCES dbo.ownershiptokens(ownershiptokenid);


--
-- Name: apiclients fk_apiclients_users; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.apiclients
    ADD CONSTRAINT fk_apiclients_users FOREIGN KEY (user_userid) REFERENCES dbo.users(userid);


--
-- Name: applicationeducationorganizations fk_applicationeducationorganizations_applications; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applicationeducationorganizations
    ADD CONSTRAINT fk_applicationeducationorganizations_applications FOREIGN KEY (application_applicationid) REFERENCES dbo.applications(applicationid);


--
-- Name: applications fk_applications_odsinstances; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applications
    ADD CONSTRAINT fk_applications_odsinstances FOREIGN KEY (odsinstance_odsinstanceid) REFERENCES dbo.odsinstances(odsinstanceid);


--
-- Name: applications fk_applications_vendors; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applications
    ADD CONSTRAINT fk_applications_vendors FOREIGN KEY (vendor_vendorid) REFERENCES dbo.vendors(vendorid);


--
-- Name: clientaccesstokens fk_clientaccesstokens_apiclients; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.clientaccesstokens
    ADD CONSTRAINT fk_clientaccesstokens_apiclients FOREIGN KEY (apiclient_apiclientid) REFERENCES dbo.apiclients(apiclientid);


--
-- Name: odsinstancecomponents fk_odsinstancecomponents_odsinstances; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.odsinstancecomponents
    ADD CONSTRAINT fk_odsinstancecomponents_odsinstances FOREIGN KEY (odsinstance_odsinstanceid) REFERENCES dbo.odsinstances(odsinstanceid) ON DELETE CASCADE;


--
-- Name: profileapplications fk_profileapplications_applications; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.profileapplications
    ADD CONSTRAINT fk_profileapplications_applications FOREIGN KEY (application_applicationid) REFERENCES dbo.applications(applicationid) ON DELETE CASCADE;


--
-- Name: profileapplications fk_profileapplications_profiles; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.profileapplications
    ADD CONSTRAINT fk_profileapplications_profiles FOREIGN KEY (profile_profileid) REFERENCES dbo.profiles(profileid) ON DELETE CASCADE;


--
-- Name: users fk_users_vendors; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.users
    ADD CONSTRAINT fk_users_vendors FOREIGN KEY (vendor_vendorid) REFERENCES dbo.vendors(vendorid);


--
-- Name: vendornamespaceprefixes fk_vendornamespaceprefixes_vendors; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.vendornamespaceprefixes
    ADD CONSTRAINT fk_vendornamespaceprefixes_vendors FOREIGN KEY (vendor_vendorid) REFERENCES dbo.vendors(vendorid) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

