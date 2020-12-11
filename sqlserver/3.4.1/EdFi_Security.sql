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
-- Name: dbo; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dbo;


ALTER SCHEMA dbo OWNER TO postgres;

SET default_tablespace = '';

--
-- Name: actions; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.actions (
    actionid integer NOT NULL,
    actionname character varying(255) NOT NULL,
    actionuri character varying(2048) NOT NULL
);


ALTER TABLE dbo.actions OWNER TO postgres;

--
-- Name: actions_actionid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.actions_actionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.actions_actionid_seq OWNER TO postgres;

--
-- Name: actions_actionid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.actions_actionid_seq OWNED BY dbo.actions.actionid;


--
-- Name: applications; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.applications (
    applicationid integer NOT NULL,
    applicationname character varying
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
-- Name: authorizationstrategies; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.authorizationstrategies (
    authorizationstrategyid integer NOT NULL,
    displayname character varying(255) NOT NULL,
    authorizationstrategyname character varying(255) NOT NULL,
    application_applicationid integer NOT NULL
);


ALTER TABLE dbo.authorizationstrategies OWNER TO postgres;

--
-- Name: authorizationstrategies_authorizationstrategyid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.authorizationstrategies_authorizationstrategyid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.authorizationstrategies_authorizationstrategyid_seq OWNER TO postgres;

--
-- Name: authorizationstrategies_authorizationstrategyid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.authorizationstrategies_authorizationstrategyid_seq OWNED BY dbo.authorizationstrategies.authorizationstrategyid;


--
-- Name: claimsetresourceclaims; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.claimsetresourceclaims (
    claimsetresourceclaimid integer NOT NULL,
    action_actionid integer NOT NULL,
    claimset_claimsetid integer NOT NULL,
    resourceclaim_resourceclaimid integer NOT NULL,
    authorizationstrategyoverride_authorizationstrategyid integer,
    validationrulesetnameoverride character varying(255)
);


ALTER TABLE dbo.claimsetresourceclaims OWNER TO postgres;

--
-- Name: claimsetresourceclaims_claimsetresourceclaimid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.claimsetresourceclaims_claimsetresourceclaimid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.claimsetresourceclaims_claimsetresourceclaimid_seq OWNER TO postgres;

--
-- Name: claimsetresourceclaims_claimsetresourceclaimid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.claimsetresourceclaims_claimsetresourceclaimid_seq OWNED BY dbo.claimsetresourceclaims.claimsetresourceclaimid;


--
-- Name: claimsets; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.claimsets (
    claimsetid integer NOT NULL,
    claimsetname character varying(255) NOT NULL,
    application_applicationid integer NOT NULL
);


ALTER TABLE dbo.claimsets OWNER TO postgres;

--
-- Name: claimsets_claimsetid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.claimsets_claimsetid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.claimsets_claimsetid_seq OWNER TO postgres;

--
-- Name: claimsets_claimsetid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.claimsets_claimsetid_seq OWNED BY dbo.claimsets.claimsetid;


--
-- Name: resourceclaimauthorizationmetadatas; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.resourceclaimauthorizationmetadatas (
    resourceclaimauthorizationstrategyid integer NOT NULL,
    action_actionid integer NOT NULL,
    authorizationstrategy_authorizationstrategyid integer,
    resourceclaim_resourceclaimid integer NOT NULL,
    validationrulesetname character varying(255)
);


ALTER TABLE dbo.resourceclaimauthorizationmetadatas OWNER TO postgres;

--
-- Name: resourceclaimauthorizationmet_resourceclaimauthorizationstr_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.resourceclaimauthorizationmet_resourceclaimauthorizationstr_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.resourceclaimauthorizationmet_resourceclaimauthorizationstr_seq OWNER TO postgres;

--
-- Name: resourceclaimauthorizationmet_resourceclaimauthorizationstr_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.resourceclaimauthorizationmet_resourceclaimauthorizationstr_seq OWNED BY dbo.resourceclaimauthorizationmetadatas.resourceclaimauthorizationstrategyid;


--
-- Name: resourceclaims; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.resourceclaims (
    resourceclaimid integer NOT NULL,
    displayname character varying(255) NOT NULL,
    resourcename character varying(2048) NOT NULL,
    claimname character varying(2048) NOT NULL,
    parentresourceclaimid integer,
    application_applicationid integer NOT NULL
);


ALTER TABLE dbo.resourceclaims OWNER TO postgres;

--
-- Name: resourceclaims_resourceclaimid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.resourceclaims_resourceclaimid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.resourceclaims_resourceclaimid_seq OWNER TO postgres;

--
-- Name: resourceclaims_resourceclaimid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.resourceclaims_resourceclaimid_seq OWNED BY dbo.resourceclaims.resourceclaimid;


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
-- Name: actions actionid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.actions ALTER COLUMN actionid SET DEFAULT nextval('dbo.actions_actionid_seq'::regclass);


--
-- Name: applications applicationid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applications ALTER COLUMN applicationid SET DEFAULT nextval('dbo.applications_applicationid_seq'::regclass);


--
-- Name: authorizationstrategies authorizationstrategyid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.authorizationstrategies ALTER COLUMN authorizationstrategyid SET DEFAULT nextval('dbo.authorizationstrategies_authorizationstrategyid_seq'::regclass);


--
-- Name: claimsetresourceclaims claimsetresourceclaimid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsetresourceclaims ALTER COLUMN claimsetresourceclaimid SET DEFAULT nextval('dbo.claimsetresourceclaims_claimsetresourceclaimid_seq'::regclass);


--
-- Name: claimsets claimsetid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsets ALTER COLUMN claimsetid SET DEFAULT nextval('dbo.claimsets_claimsetid_seq'::regclass);


--
-- Name: resourceclaimauthorizationmetadatas resourceclaimauthorizationstrategyid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaimauthorizationmetadatas ALTER COLUMN resourceclaimauthorizationstrategyid SET DEFAULT nextval('dbo.resourceclaimauthorizationmet_resourceclaimauthorizationstr_seq'::regclass);


--
-- Name: resourceclaims resourceclaimid; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaims ALTER COLUMN resourceclaimid SET DEFAULT nextval('dbo.resourceclaims_resourceclaimid_seq'::regclass);


--
-- Name: DeployJournal schemaversionsid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DeployJournal" ALTER COLUMN schemaversionsid SET DEFAULT nextval('public."DeployJournal_schemaversionsid_seq"'::regclass);


--
-- Data for Name: actions; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.actions (actionid, actionname, actionuri) FROM stdin;
1	Create	http://ed-fi.org/odsapi/actions/create
2	Read	http://ed-fi.org/odsapi/actions/read
3	Update	http://ed-fi.org/odsapi/actions/update
4	Delete	http://ed-fi.org/odsapi/actions/delete
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.applications (applicationid, applicationname) FROM stdin;
1	Ed-Fi ODS API
\.


--
-- Data for Name: authorizationstrategies; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.authorizationstrategies (authorizationstrategyid, displayname, authorizationstrategyname, application_applicationid) FROM stdin;
1	No Further Authorization Required	NoFurtherAuthorizationRequired	1
2	Relationships with Education Organizations and People	RelationshipsWithEdOrgsAndPeople	1
3	Relationships with Education Organizations only	RelationshipsWithEdOrgsOnly	1
4	Namespace Based	NamespaceBased	1
5	Relationships with People only	RelationshipsWithPeopleOnly	1
6	Relationships with Students only	RelationshipsWithStudentsOnly	1
7	Relationships with Students only (through StudentEducationOrganizationAssociation)	RelationshipsWithStudentsOnlyThroughEdOrgAssociation	1
\.


--
-- Data for Name: claimsetresourceclaims; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.claimsetresourceclaims (claimsetresourceclaimid, action_actionid, claimset_claimsetid, resourceclaim_resourceclaimid, authorizationstrategyoverride_authorizationstrategyid, validationrulesetnameoverride) FROM stdin;
1	1	1	10	\N	\N
2	3	1	9	\N	\N
3	2	1	6	\N	\N
4	2	1	10	\N	\N
5	4	1	6	\N	\N
6	1	1	9	\N	\N
7	2	1	5	\N	\N
8	1	1	97	\N	\N
9	1	1	7	\N	\N
10	4	1	11	\N	\N
11	3	1	11	\N	\N
12	3	1	7	\N	\N
13	4	1	7	\N	\N
14	4	1	9	\N	\N
15	2	1	1	\N	\N
16	2	1	3	\N	\N
17	1	1	6	\N	\N
18	1	1	3	\N	\N
19	3	1	6	\N	\N
20	3	1	3	\N	\N
21	3	1	10	\N	\N
22	2	1	4	\N	\N
23	2	1	2	\N	\N
24	3	1	97	\N	\N
25	4	1	5	\N	\N
26	4	1	3	\N	\N
27	4	1	97	\N	\N
28	2	1	11	\N	\N
29	3	1	5	\N	\N
30	2	1	97	\N	\N
31	4	1	10	\N	\N
32	2	1	7	\N	\N
33	2	1	9	\N	\N
34	1	1	11	\N	\N
35	1	1	5	\N	\N
36	1	2	4	\N	\N
37	2	2	4	\N	\N
38	4	2	6	\N	\N
39	2	2	8	\N	\N
40	4	2	4	\N	\N
41	3	2	2	\N	\N
42	1	2	11	\N	\N
43	3	2	9	\N	\N
44	4	2	5	\N	\N
45	3	2	10	\N	\N
46	1	2	3	\N	\N
47	1	2	10	\N	\N
48	3	2	4	\N	\N
49	3	2	8	\N	\N
50	1	2	6	\N	\N
51	4	2	3	\N	\N
52	3	2	97	\N	\N
53	2	2	6	\N	\N
54	4	2	11	\N	\N
55	2	2	10	\N	\N
56	4	2	10	\N	\N
57	3	2	5	\N	\N
58	4	2	7	\N	\N
59	1	2	9	\N	\N
60	4	2	2	\N	\N
61	2	2	5	\N	\N
62	1	2	5	\N	\N
63	3	2	3	\N	\N
64	1	2	2	\N	\N
65	1	2	97	\N	\N
66	3	2	11	\N	\N
67	2	2	11	\N	\N
68	1	2	8	\N	\N
69	2	2	9	\N	\N
70	2	2	3	\N	\N
71	3	2	6	\N	\N
72	3	2	7	\N	\N
73	1	2	7	\N	\N
74	2	2	2	\N	\N
75	2	2	7	\N	\N
76	4	2	97	\N	\N
77	4	2	9	\N	\N
78	2	2	1	\N	\N
79	2	2	97	\N	\N
80	1	2	59	1	\N
81	2	2	59	1	\N
82	3	2	59	1	\N
83	4	2	59	1	\N
84	2	3	4	\N	\N
85	2	3	51	\N	\N
86	2	3	68	\N	\N
87	2	3	74	\N	\N
88	2	3	152	\N	\N
89	2	3	213	\N	\N
90	2	3	219	\N	\N
91	2	3	223	\N	\N
92	2	3	228	\N	\N
93	2	3	236	\N	\N
94	2	3	239	\N	\N
95	2	3	262	\N	\N
96	2	3	265	\N	\N
104	2	5	7	\N	\N
105	2	5	139	\N	\N
106	2	5	140	\N	\N
107	2	5	239	\N	\N
108	1	6	2	1	\N
109	1	6	3	1	\N
110	1	6	4	1	\N
111	1	6	21	1	\N
112	1	6	51	1	\N
113	1	6	57	1	\N
114	1	6	58	1	\N
115	1	6	59	1	\N
116	1	6	68	1	\N
117	1	6	101	1	\N
118	1	6	102	1	\N
119	1	6	103	1	\N
120	1	6	105	1	\N
121	1	6	112	1	\N
122	1	6	139	1	\N
123	1	6	140	1	\N
124	1	6	142	1	\N
125	1	6	150	1	\N
126	1	6	152	1	\N
127	1	6	178	1	\N
128	1	6	181	1	\N
129	1	6	207	1	\N
130	1	6	238	1	\N
131	2	7	1	\N	\N
132	2	7	2	\N	\N
133	1	7	3	\N	\N
134	2	7	3	\N	\N
135	3	7	3	\N	\N
136	4	7	3	\N	\N
137	2	7	4	\N	\N
138	1	7	5	\N	\N
139	2	7	5	\N	\N
140	3	7	5	\N	\N
141	4	7	5	\N	\N
142	1	7	6	\N	\N
143	2	7	6	\N	\N
144	3	7	6	\N	\N
145	4	7	6	\N	\N
146	1	7	7	\N	\N
147	2	7	7	\N	\N
148	3	7	7	\N	\N
149	4	7	7	\N	\N
150	1	7	9	\N	\N
151	2	7	9	\N	\N
152	3	7	9	\N	\N
153	4	7	9	\N	\N
154	1	7	10	\N	\N
155	2	7	10	\N	\N
156	3	7	10	\N	\N
157	4	7	10	\N	\N
158	1	7	11	\N	\N
159	2	7	11	\N	\N
160	3	7	11	\N	\N
161	4	7	11	\N	\N
162	1	7	97	\N	\N
163	2	7	97	\N	\N
164	3	7	97	\N	\N
165	4	7	97	\N	\N
166	1	7	207	\N	\N
167	2	7	207	\N	\N
168	3	7	207	\N	\N
169	4	7	207	\N	\N
170	2	7	150	\N	\N
171	3	7	150	\N	\N
172	1	4	17	\N	\N
173	2	4	17	\N	\N
174	3	4	17	\N	\N
175	4	4	17	\N	\N
176	1	4	7	\N	\N
177	2	4	7	\N	\N
178	3	4	7	\N	\N
179	4	4	7	\N	\N
180	1	4	139	\N	\N
181	2	4	139	\N	\N
182	3	4	139	\N	\N
183	4	4	139	\N	\N
184	2	4	140	\N	\N
185	1	4	3	\N	\N
186	2	4	3	\N	\N
187	3	4	3	\N	\N
188	4	4	3	\N	\N
189	2	4	239	\N	\N
190	2	4	2	\N	\N
191	2	4	1	\N	\N
\.


--
-- Data for Name: claimsets; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.claimsets (claimsetid, claimsetname, application_applicationid) FROM stdin;
1	SIS Vendor	1
2	Ed-Fi Sandbox	1
3	Roster Vendor	1
4	Assessment Vendor	1
5	Assessment Read	1
6	Bootstrap Descriptors and EdOrgs	1
7	District Hosted SIS Vendor	1
\.


--
-- Data for Name: resourceclaimauthorizationmetadatas; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.resourceclaimauthorizationmetadatas (resourceclaimauthorizationstrategyid, action_actionid, authorizationstrategy_authorizationstrategyid, resourceclaim_resourceclaimid, validationrulesetname) FROM stdin;
1	1	1	77	\N
2	2	1	11	\N
3	3	1	4	\N
4	1	1	11	\N
5	2	1	1	\N
6	1	1	5	\N
7	3	1	77	\N
8	2	1	68	\N
9	4	1	77	\N
10	2	1	4	\N
11	4	1	5	\N
12	3	1	11	\N
13	1	1	8	\N
14	2	1	8	\N
15	2	1	3	\N
16	4	1	4	\N
17	3	1	8	\N
18	1	1	4	\N
19	2	1	77	\N
20	2	1	2	\N
21	3	4	9	\N
22	3	4	97	\N
23	4	4	3	\N
24	2	4	9	\N
25	3	4	3	\N
26	2	4	7	\N
27	3	4	7	\N
28	1	4	7	\N
29	1	4	2	\N
30	2	4	97	\N
31	4	4	2	\N
32	4	4	7	\N
33	3	4	2	\N
34	1	4	9	\N
35	1	4	97	\N
36	4	4	9	\N
37	4	4	97	\N
38	1	4	3	\N
39	2	2	10	\N
40	2	2	5	\N
41	3	2	258	\N
42	3	2	6	\N
43	1	2	6	\N
44	2	2	258	\N
45	4	2	258	\N
46	4	2	6	\N
47	3	2	10	\N
48	3	2	5	\N
49	4	2	10	\N
50	2	2	6	\N
51	1	6	258	\N
52	1	3	10	\N
\.


--
-- Data for Name: resourceclaims; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.resourceclaims (resourceclaimid, displayname, resourcename, claimname, parentresourceclaimid, application_applicationid) FROM stdin;
1	types	types	http://ed-fi.org/ods/identity/claims/domains/edFiTypes	\N	1
2	systemDescriptors	systemDescriptors	http://ed-fi.org/ods/identity/claims/domains/systemDescriptors	\N	1
3	managedDescriptors	managedDescriptors	http://ed-fi.org/ods/identity/claims/domains/managedDescriptors	\N	1
4	educationOrganizations	educationOrganizations	http://ed-fi.org/ods/identity/claims/domains/educationOrganizations	\N	1
5	people	people	http://ed-fi.org/ods/identity/claims/domains/people	\N	1
6	relationshipBasedData	relationshipBasedData	http://ed-fi.org/ods/identity/claims/domains/relationshipBasedData	\N	1
7	assessmentMetadata	assessmentMetadata	http://ed-fi.org/ods/identity/claims/domains/assessmentMetadata	\N	1
8	identity	identity	http://ed-fi.org/ods/identity/claims/domains/identity	\N	1
9	educationStandards	educationStandards	http://ed-fi.org/ods/identity/claims/domains/educationStandards	\N	1
10	primaryRelationships	primaryRelationships	http://ed-fi.org/ods/identity/claims/domains/primaryRelationships	\N	1
11	bulk	bulk	http://ed-fi.org/ods/identity/claims/domains/bulk	\N	1
12	bulkOperation	bulkOperation	http://ed-fi.org/ods/identity/claims/domains/bulkOperation	11	1
13	bulkOperationException	bulkOperationException	http://ed-fi.org/ods/identity/claims/domains/bulkOperationException	11	1
14	upload	upload	http://ed-fi.org/ods/identity/claims/domains/upload	11	1
15	absenceEventCategoryDescriptor	absenceEventCategoryDescriptor	http://ed-fi.org/ods/identity/claims/absenceEventCategoryDescriptor	2	1
16	academicHonorCategoryDescriptor	academicHonorCategoryDescriptor	http://ed-fi.org/ods/identity/claims/academicHonorCategoryDescriptor	2	1
17	academicSubjectDescriptor	academicSubjectDescriptor	http://ed-fi.org/ods/identity/claims/academicSubjectDescriptor	2	1
18	academicWeek	academicWeek	http://ed-fi.org/ods/identity/claims/academicWeek	6	1
19	accommodationDescriptor	accommodationDescriptor	http://ed-fi.org/ods/identity/claims/accommodationDescriptor	3	1
20	account	account	http://ed-fi.org/ods/identity/claims/account	6	1
21	accountabilityRating	accountabilityRating	http://ed-fi.org/ods/identity/claims/accountabilityRating	6	1
22	accountClassificationDescriptor	accountClassificationDescriptor	http://ed-fi.org/ods/identity/claims/accountClassificationDescriptor	2	1
23	accountCode	accountCode	http://ed-fi.org/ods/identity/claims/accountCode	6	1
24	achievementCategoryDescriptor	achievementCategoryDescriptor	http://ed-fi.org/ods/identity/claims/achievementCategoryDescriptor	2	1
25	actual	actual	http://ed-fi.org/ods/identity/claims/actual	6	1
26	additionalCreditTypeDescriptor	additionalCreditTypeDescriptor	http://ed-fi.org/ods/identity/claims/additionalCreditTypeDescriptor	2	1
27	addressTypeDescriptor	addressTypeDescriptor	http://ed-fi.org/ods/identity/claims/addressTypeDescriptor	2	1
28	administrationEnvironmentDescriptor	administrationEnvironmentDescriptor	http://ed-fi.org/ods/identity/claims/administrationEnvironmentDescriptor	2	1
29	administrativeFundingControlDescriptor	administrativeFundingControlDescriptor	http://ed-fi.org/ods/identity/claims/administrativeFundingControlDescriptor	2	1
30	assessment	assessment	http://ed-fi.org/ods/identity/claims/assessment	7	1
31	assessmentCategoryDescriptor	assessmentCategoryDescriptor	http://ed-fi.org/ods/identity/claims/assessmentCategoryDescriptor	2	1
32	assessmentIdentificationSystemDescriptor	assessmentIdentificationSystemDescriptor	http://ed-fi.org/ods/identity/claims/assessmentIdentificationSystemDescriptor	2	1
33	assessmentItem	assessmentItem	http://ed-fi.org/ods/identity/claims/assessmentItem	7	1
34	assessmentItemCategoryDescriptor	assessmentItemCategoryDescriptor	http://ed-fi.org/ods/identity/claims/assessmentItemCategoryDescriptor	2	1
35	assessmentItemResultDescriptor	assessmentItemResultDescriptor	http://ed-fi.org/ods/identity/claims/assessmentItemResultDescriptor	2	1
36	assessmentPeriodDescriptor	assessmentPeriodDescriptor	http://ed-fi.org/ods/identity/claims/assessmentPeriodDescriptor	3	1
37	assessmentReportingMethodDescriptor	assessmentReportingMethodDescriptor	http://ed-fi.org/ods/identity/claims/assessmentReportingMethodDescriptor	3	1
38	attemptStatusDescriptor	attemptStatusDescriptor	http://ed-fi.org/ods/identity/claims/attemptStatusDescriptor	2	1
39	attendanceEventCategoryDescriptor	attendanceEventCategoryDescriptor	http://ed-fi.org/ods/identity/claims/attendanceEventCategoryDescriptor	2	1
40	behaviorDescriptor	behaviorDescriptor	http://ed-fi.org/ods/identity/claims/behaviorDescriptor	2	1
41	bellSchedule	bellSchedule	http://ed-fi.org/ods/identity/claims/bellSchedule	6	1
42	budget	budget	http://ed-fi.org/ods/identity/claims/budget	6	1
43	calendar	calendar	http://ed-fi.org/ods/identity/claims/calendar	6	1
44	calendarDate	calendarDate	http://ed-fi.org/ods/identity/claims/calendarDate	6	1
45	calendarEventDescriptor	calendarEventDescriptor	http://ed-fi.org/ods/identity/claims/calendarEventDescriptor	2	1
46	calendarTypeDescriptor	calendarTypeDescriptor	http://ed-fi.org/ods/identity/claims/calendarTypeDescriptor	2	1
47	careerPathwayDescriptor	careerPathwayDescriptor	http://ed-fi.org/ods/identity/claims/careerPathwayDescriptor	2	1
48	charterApprovalAgencyTypeDescriptor	charterApprovalAgencyTypeDescriptor	http://ed-fi.org/ods/identity/claims/charterApprovalAgencyTypeDescriptor	2	1
49	charterStatusDescriptor	charterStatusDescriptor	http://ed-fi.org/ods/identity/claims/charterStatusDescriptor	2	1
50	citizenshipStatusDescriptor	citizenshipStatusDescriptor	http://ed-fi.org/ods/identity/claims/citizenshipStatusDescriptor	2	1
51	classPeriod	classPeriod	http://ed-fi.org/ods/identity/claims/classPeriod	6	1
52	classroomPositionDescriptor	classroomPositionDescriptor	http://ed-fi.org/ods/identity/claims/classroomPositionDescriptor	2	1
53	cohort	cohort	http://ed-fi.org/ods/identity/claims/cohort	6	1
54	cohortScopeDescriptor	cohortScopeDescriptor	http://ed-fi.org/ods/identity/claims/cohortScopeDescriptor	2	1
55	cohortTypeDescriptor	cohortTypeDescriptor	http://ed-fi.org/ods/identity/claims/cohortTypeDescriptor	2	1
56	cohortYearTypeDescriptor	cohortYearTypeDescriptor	http://ed-fi.org/ods/identity/claims/cohortYearTypeDescriptor	2	1
57	communityOrganization	communityOrganization	http://ed-fi.org/ods/identity/claims/communityOrganization	4	1
58	communityProvider	communityProvider	http://ed-fi.org/ods/identity/claims/communityProvider	4	1
59	communityProviderLicense	communityProviderLicense	http://ed-fi.org/ods/identity/claims/communityProviderLicense	6	1
60	competencyLevelDescriptor	competencyLevelDescriptor	http://ed-fi.org/ods/identity/claims/competencyLevelDescriptor	2	1
61	competencyObjective	competencyObjective	http://ed-fi.org/ods/identity/claims/competencyObjective	6	1
62	contactTypeDescriptor	contactTypeDescriptor	http://ed-fi.org/ods/identity/claims/contactTypeDescriptor	2	1
63	contentClassDescriptor	contentClassDescriptor	http://ed-fi.org/ods/identity/claims/contentClassDescriptor	2	1
64	continuationOfServicesReasonDescriptor	continuationOfServicesReasonDescriptor	http://ed-fi.org/ods/identity/claims/continuationOfServicesReasonDescriptor	2	1
65	contractedStaff	contractedStaff	http://ed-fi.org/ods/identity/claims/contractedStaff	6	1
66	costRateDescriptor	costRateDescriptor	http://ed-fi.org/ods/identity/claims/costRateDescriptor	2	1
67	countryDescriptor	countryDescriptor	http://ed-fi.org/ods/identity/claims/countryDescriptor	2	1
68	course	course	http://ed-fi.org/ods/identity/claims/course	6	1
69	courseAttemptResultDescriptor	courseAttemptResultDescriptor	http://ed-fi.org/ods/identity/claims/courseAttemptResultDescriptor	2	1
70	courseDefinedByDescriptor	courseDefinedByDescriptor	http://ed-fi.org/ods/identity/claims/courseDefinedByDescriptor	2	1
71	courseGPAApplicabilityDescriptor	courseGPAApplicabilityDescriptor	http://ed-fi.org/ods/identity/claims/courseGPAApplicabilityDescriptor	2	1
72	courseIdentificationSystemDescriptor	courseIdentificationSystemDescriptor	http://ed-fi.org/ods/identity/claims/courseIdentificationSystemDescriptor	2	1
73	courseLevelCharacteristicDescriptor	courseLevelCharacteristicDescriptor	http://ed-fi.org/ods/identity/claims/courseLevelCharacteristicDescriptor	2	1
74	courseOffering	courseOffering	http://ed-fi.org/ods/identity/claims/courseOffering	6	1
75	courseRepeatCodeDescriptor	courseRepeatCodeDescriptor	http://ed-fi.org/ods/identity/claims/courseRepeatCodeDescriptor	2	1
76	courseTranscript	courseTranscript	http://ed-fi.org/ods/identity/claims/courseTranscript	6	1
77	credential	credential	http://ed-fi.org/ods/identity/claims/credential	9	1
78	credentialFieldDescriptor	credentialFieldDescriptor	http://ed-fi.org/ods/identity/claims/credentialFieldDescriptor	2	1
79	credentialTypeDescriptor	credentialTypeDescriptor	http://ed-fi.org/ods/identity/claims/credentialTypeDescriptor	2	1
80	creditCategoryDescriptor	creditCategoryDescriptor	http://ed-fi.org/ods/identity/claims/creditCategoryDescriptor	2	1
81	creditTypeDescriptor	creditTypeDescriptor	http://ed-fi.org/ods/identity/claims/creditTypeDescriptor	2	1
82	cteProgramServiceDescriptor	cteProgramServiceDescriptor	http://ed-fi.org/ods/identity/claims/cteProgramServiceDescriptor	2	1
83	curriculumUsedDescriptor	curriculumUsedDescriptor	http://ed-fi.org/ods/identity/claims/curriculumUsedDescriptor	2	1
84	deliveryMethodDescriptor	deliveryMethodDescriptor	http://ed-fi.org/ods/identity/claims/deliveryMethodDescriptor	2	1
85	diagnosisDescriptor	diagnosisDescriptor	http://ed-fi.org/ods/identity/claims/diagnosisDescriptor	2	1
86	diplomaLevelDescriptor	diplomaLevelDescriptor	http://ed-fi.org/ods/identity/claims/diplomaLevelDescriptor	2	1
87	diplomaTypeDescriptor	diplomaTypeDescriptor	http://ed-fi.org/ods/identity/claims/diplomaTypeDescriptor	2	1
88	disabilityDescriptor	disabilityDescriptor	http://ed-fi.org/ods/identity/claims/disabilityDescriptor	2	1
89	disabilityDesignationDescriptor	disabilityDesignationDescriptor	http://ed-fi.org/ods/identity/claims/disabilityDesignationDescriptor	2	1
90	disabilityDeterminationSourceTypeDescriptor	disabilityDeterminationSourceTypeDescriptor	http://ed-fi.org/ods/identity/claims/disabilityDeterminationSourceTypeDescriptor	2	1
91	disciplineAction	disciplineAction	http://ed-fi.org/ods/identity/claims/disciplineAction	6	1
92	disciplineActionLengthDifferenceReasonDescriptor	disciplineActionLengthDifferenceReasonDescriptor	http://ed-fi.org/ods/identity/claims/disciplineActionLengthDifferenceReasonDescriptor	2	1
93	disciplineDescriptor	disciplineDescriptor	http://ed-fi.org/ods/identity/claims/disciplineDescriptor	2	1
94	disciplineIncident	disciplineIncident	http://ed-fi.org/ods/identity/claims/disciplineIncident	6	1
95	disciplineIncidentParticipationCodeDescriptor	disciplineIncidentParticipationCodeDescriptor	http://ed-fi.org/ods/identity/claims/disciplineIncidentParticipationCodeDescriptor	2	1
96	educationalEnvironmentDescriptor	educationalEnvironmentDescriptor	http://ed-fi.org/ods/identity/claims/educationalEnvironmentDescriptor	2	1
97	educationContent	educationContent	http://ed-fi.org/ods/identity/claims/educationContent	\N	1
98	educationOrganizationCategoryDescriptor	educationOrganizationCategoryDescriptor	http://ed-fi.org/ods/identity/claims/educationOrganizationCategoryDescriptor	2	1
99	educationOrganizationIdentificationSystemDescriptor	educationOrganizationIdentificationSystemDescriptor	http://ed-fi.org/ods/identity/claims/educationOrganizationIdentificationSystemDescriptor	2	1
100	educationOrganizationInterventionPrescriptionAssociation	educationOrganizationInterventionPrescriptionAssociation	http://ed-fi.org/ods/identity/claims/educationOrganizationInterventionPrescriptionAssociation	6	1
101	educationOrganizationNetwork	educationOrganizationNetwork	http://ed-fi.org/ods/identity/claims/educationOrganizationNetwork	4	1
102	educationOrganizationNetworkAssociation	educationOrganizationNetworkAssociation	http://ed-fi.org/ods/identity/claims/educationOrganizationNetworkAssociation	4	1
103	educationOrganizationPeerAssociation	educationOrganizationPeerAssociation	http://ed-fi.org/ods/identity/claims/educationOrganizationPeerAssociation	6	1
104	educationPlanDescriptor	educationPlanDescriptor	http://ed-fi.org/ods/identity/claims/educationPlanDescriptor	2	1
105	educationServiceCenter	educationServiceCenter	http://ed-fi.org/ods/identity/claims/educationServiceCenter	4	1
106	electronicMailTypeDescriptor	electronicMailTypeDescriptor	http://ed-fi.org/ods/identity/claims/electronicMailTypeDescriptor	2	1
107	employmentStatusDescriptor	employmentStatusDescriptor	http://ed-fi.org/ods/identity/claims/employmentStatusDescriptor	2	1
108	entryGradeLevelReasonDescriptor	entryGradeLevelReasonDescriptor	http://ed-fi.org/ods/identity/claims/entryGradeLevelReasonDescriptor	2	1
109	entryTypeDescriptor	entryTypeDescriptor	http://ed-fi.org/ods/identity/claims/entryTypeDescriptor	2	1
110	eventCircumstanceDescriptor	eventCircumstanceDescriptor	http://ed-fi.org/ods/identity/claims/eventCircumstanceDescriptor	2	1
111	exitWithdrawTypeDescriptor	exitWithdrawTypeDescriptor	http://ed-fi.org/ods/identity/claims/exitWithdrawTypeDescriptor	2	1
112	feederSchoolAssociation	feederSchoolAssociation	http://ed-fi.org/ods/identity/claims/feederSchoolAssociation	6	1
113	grade	grade	http://ed-fi.org/ods/identity/claims/grade	6	1
114	gradebookEntry	gradebookEntry	http://ed-fi.org/ods/identity/claims/gradebookEntry	6	1
115	gradebookEntryTypeDescriptor	gradebookEntryTypeDescriptor	http://ed-fi.org/ods/identity/claims/gradebookEntryTypeDescriptor	2	1
116	gradeLevelDescriptor	gradeLevelDescriptor	http://ed-fi.org/ods/identity/claims/gradeLevelDescriptor	2	1
117	gradePointAverageTypeDescriptor	gradePointAverageTypeDescriptor	http://ed-fi.org/ods/identity/claims/gradePointAverageTypeDescriptor	2	1
118	gradeTypeDescriptor	gradeTypeDescriptor	http://ed-fi.org/ods/identity/claims/gradeTypeDescriptor	2	1
119	gradingPeriod	gradingPeriod	http://ed-fi.org/ods/identity/claims/gradingPeriod	6	1
120	gradingPeriodDescriptor	gradingPeriodDescriptor	http://ed-fi.org/ods/identity/claims/gradingPeriodDescriptor	2	1
121	graduationPlan	graduationPlan	http://ed-fi.org/ods/identity/claims/graduationPlan	6	1
122	graduationPlanTypeDescriptor	graduationPlanTypeDescriptor	http://ed-fi.org/ods/identity/claims/graduationPlanTypeDescriptor	2	1
123	gunFreeSchoolsActReportingStatusDescriptor	gunFreeSchoolsActReportingStatusDescriptor	http://ed-fi.org/ods/identity/claims/gunFreeSchoolsActReportingStatusDescriptor	2	1
124	homelessPrimaryNighttimeResidenceDescriptor	homelessPrimaryNighttimeResidenceDescriptor	http://ed-fi.org/ods/identity/claims/homelessPrimaryNighttimeResidenceDescriptor	2	1
125	homelessProgramServiceDescriptor	homelessProgramServiceDescriptor	http://ed-fi.org/ods/identity/claims/homelessProgramServiceDescriptor	2	1
126	identificationDocumentUseDescriptor	identificationDocumentUseDescriptor	http://ed-fi.org/ods/identity/claims/identificationDocumentUseDescriptor	2	1
127	incidentLocationDescriptor	incidentLocationDescriptor	http://ed-fi.org/ods/identity/claims/incidentLocationDescriptor	2	1
128	institutionTelephoneNumberTypeDescriptor	institutionTelephoneNumberTypeDescriptor	http://ed-fi.org/ods/identity/claims/institutionTelephoneNumberTypeDescriptor	2	1
129	interactivityStyleDescriptor	interactivityStyleDescriptor	http://ed-fi.org/ods/identity/claims/interactivityStyleDescriptor	2	1
130	internetAccessDescriptor	internetAccessDescriptor	http://ed-fi.org/ods/identity/claims/internetAccessDescriptor	2	1
131	intervention	intervention	http://ed-fi.org/ods/identity/claims/intervention	6	1
132	interventionClassDescriptor	interventionClassDescriptor	http://ed-fi.org/ods/identity/claims/interventionClassDescriptor	2	1
133	interventionEffectivenessRatingDescriptor	interventionEffectivenessRatingDescriptor	http://ed-fi.org/ods/identity/claims/interventionEffectivenessRatingDescriptor	2	1
134	interventionPrescription	interventionPrescription	http://ed-fi.org/ods/identity/claims/interventionPrescription	6	1
135	interventionStudy	interventionStudy	http://ed-fi.org/ods/identity/claims/interventionStudy	6	1
136	languageDescriptor	languageDescriptor	http://ed-fi.org/ods/identity/claims/languageDescriptor	2	1
137	languageInstructionProgramServiceDescriptor	languageInstructionProgramServiceDescriptor	http://ed-fi.org/ods/identity/claims/languageInstructionProgramServiceDescriptor	2	1
138	languageUseDescriptor	languageUseDescriptor	http://ed-fi.org/ods/identity/claims/languageUseDescriptor	2	1
139	learningObjective	learningObjective	http://ed-fi.org/ods/identity/claims/learningObjective	9	1
140	learningStandard	learningStandard	http://ed-fi.org/ods/identity/claims/learningStandard	9	1
141	learningStandardCategoryDescriptor	learningStandardCategoryDescriptor	http://ed-fi.org/ods/identity/claims/learningStandardCategoryDescriptor	2	1
142	learningStandardEquivalenceAssociation	learningStandardEquivalenceAssociation	http://ed-fi.org/ods/identity/claims/learningStandardEquivalenceAssociation	9	1
143	learningStandardEquivalenceStrengthDescriptor	learningStandardEquivalenceStrengthDescriptor	http://ed-fi.org/ods/identity/claims/learningStandardEquivalenceStrengthDescriptor	2	1
144	learningStandardScopeDescriptor	learningStandardScopeDescriptor	http://ed-fi.org/ods/identity/claims/learningStandardScopeDescriptor	2	1
145	levelOfEducationDescriptor	levelOfEducationDescriptor	http://ed-fi.org/ods/identity/claims/levelOfEducationDescriptor	2	1
146	licenseStatusDescriptor	licenseStatusDescriptor	http://ed-fi.org/ods/identity/claims/licenseStatusDescriptor	2	1
147	licenseTypeDescriptor	licenseTypeDescriptor	http://ed-fi.org/ods/identity/claims/licenseTypeDescriptor	2	1
148	limitedEnglishProficiencyDescriptor	limitedEnglishProficiencyDescriptor	http://ed-fi.org/ods/identity/claims/limitedEnglishProficiencyDescriptor	2	1
149	localeDescriptor	localeDescriptor	http://ed-fi.org/ods/identity/claims/localeDescriptor	2	1
150	localEducationAgency	localEducationAgency	http://ed-fi.org/ods/identity/claims/localEducationAgency	4	1
151	localEducationAgencyCategoryDescriptor	localEducationAgencyCategoryDescriptor	http://ed-fi.org/ods/identity/claims/localEducationAgencyCategoryDescriptor	2	1
152	location	location	http://ed-fi.org/ods/identity/claims/location	6	1
153	magnetSpecialProgramEmphasisSchoolDescriptor	magnetSpecialProgramEmphasisSchoolDescriptor	http://ed-fi.org/ods/identity/claims/magnetSpecialProgramEmphasisSchoolDescriptor	2	1
154	mediumOfInstructionDescriptor	mediumOfInstructionDescriptor	http://ed-fi.org/ods/identity/claims/mediumOfInstructionDescriptor	2	1
155	methodCreditEarnedDescriptor	methodCreditEarnedDescriptor	http://ed-fi.org/ods/identity/claims/methodCreditEarnedDescriptor	2	1
156	migrantEducationProgramServiceDescriptor	migrantEducationProgramServiceDescriptor	http://ed-fi.org/ods/identity/claims/migrantEducationProgramServiceDescriptor	2	1
157	monitoredDescriptor	monitoredDescriptor	http://ed-fi.org/ods/identity/claims/monitoredDescriptor	2	1
158	neglectedOrDelinquentProgramDescriptor	neglectedOrDelinquentProgramDescriptor	http://ed-fi.org/ods/identity/claims/neglectedOrDelinquentProgramDescriptor	2	1
159	neglectedOrDelinquentProgramServiceDescriptor	neglectedOrDelinquentProgramServiceDescriptor	http://ed-fi.org/ods/identity/claims/neglectedOrDelinquentProgramServiceDescriptor	2	1
160	networkPurposeDescriptor	networkPurposeDescriptor	http://ed-fi.org/ods/identity/claims/networkPurposeDescriptor	2	1
161	objectiveAssessment	objectiveAssessment	http://ed-fi.org/ods/identity/claims/objectiveAssessment	7	1
162	oldEthnicityDescriptor	oldEthnicityDescriptor	http://ed-fi.org/ods/identity/claims/oldEthnicityDescriptor	2	1
163	openStaffPosition	openStaffPosition	http://ed-fi.org/ods/identity/claims/openStaffPosition	6	1
164	operationalStatusDescriptor	operationalStatusDescriptor	http://ed-fi.org/ods/identity/claims/operationalStatusDescriptor	2	1
165	otherNameTypeDescriptor	otherNameTypeDescriptor	http://ed-fi.org/ods/identity/claims/otherNameTypeDescriptor	2	1
166	parent	parent	http://ed-fi.org/ods/identity/claims/parent	5	1
167	participationDescriptor	participationDescriptor	http://ed-fi.org/ods/identity/claims/participationDescriptor	2	1
168	participationStatusDescriptor	participationStatusDescriptor	http://ed-fi.org/ods/identity/claims/participationStatusDescriptor	2	1
169	payroll	payroll	http://ed-fi.org/ods/identity/claims/payroll	6	1
170	performanceBaseConversionDescriptor	performanceBaseConversionDescriptor	http://ed-fi.org/ods/identity/claims/performanceBaseConversionDescriptor	2	1
171	performanceLevelDescriptor	performanceLevelDescriptor	http://ed-fi.org/ods/identity/claims/performanceLevelDescriptor	3	1
172	personalInformationVerificationDescriptor	personalInformationVerificationDescriptor	http://ed-fi.org/ods/identity/claims/personalInformationVerificationDescriptor	2	1
173	platformTypeDescriptor	platformTypeDescriptor	http://ed-fi.org/ods/identity/claims/platformTypeDescriptor	2	1
174	populationServedDescriptor	populationServedDescriptor	http://ed-fi.org/ods/identity/claims/populationServedDescriptor	2	1
175	postingResultDescriptor	postingResultDescriptor	http://ed-fi.org/ods/identity/claims/postingResultDescriptor	2	1
176	postSecondaryEvent	postSecondaryEvent	http://ed-fi.org/ods/identity/claims/postSecondaryEvent	6	1
177	postSecondaryEventCategoryDescriptor	postSecondaryEventCategoryDescriptor	http://ed-fi.org/ods/identity/claims/postSecondaryEventCategoryDescriptor	2	1
178	postSecondaryInstitution	postSecondaryInstitution	http://ed-fi.org/ods/identity/claims/postSecondaryInstitution	4	1
179	postSecondaryInstitutionLevelDescriptor	postSecondaryInstitutionLevelDescriptor	http://ed-fi.org/ods/identity/claims/postSecondaryInstitutionLevelDescriptor	2	1
180	proficiencyDescriptor	proficiencyDescriptor	http://ed-fi.org/ods/identity/claims/proficiencyDescriptor	2	1
181	program	program	http://ed-fi.org/ods/identity/claims/program	6	1
182	programAssignmentDescriptor	programAssignmentDescriptor	http://ed-fi.org/ods/identity/claims/programAssignmentDescriptor	2	1
183	programCharacteristicDescriptor	programCharacteristicDescriptor	http://ed-fi.org/ods/identity/claims/programCharacteristicDescriptor	2	1
184	programSponsorDescriptor	programSponsorDescriptor	http://ed-fi.org/ods/identity/claims/programSponsorDescriptor	2	1
185	programTypeDescriptor	programTypeDescriptor	http://ed-fi.org/ods/identity/claims/programTypeDescriptor	2	1
186	progressDescriptor	progressDescriptor	http://ed-fi.org/ods/identity/claims/progressDescriptor	2	1
187	progressLevelDescriptor	progressLevelDescriptor	http://ed-fi.org/ods/identity/claims/progressLevelDescriptor	2	1
188	providerCategoryDescriptor	providerCategoryDescriptor	http://ed-fi.org/ods/identity/claims/providerCategoryDescriptor	2	1
189	providerProfitabilityDescriptor	providerProfitabilityDescriptor	http://ed-fi.org/ods/identity/claims/providerProfitabilityDescriptor	2	1
190	providerStatusDescriptor	providerStatusDescriptor	http://ed-fi.org/ods/identity/claims/providerStatusDescriptor	2	1
191	publicationStatusDescriptor	publicationStatusDescriptor	http://ed-fi.org/ods/identity/claims/publicationStatusDescriptor	2	1
192	raceDescriptor	raceDescriptor	http://ed-fi.org/ods/identity/claims/raceDescriptor	2	1
193	reasonExitedDescriptor	reasonExitedDescriptor	http://ed-fi.org/ods/identity/claims/reasonExitedDescriptor	2	1
194	reasonNotTestedDescriptor	reasonNotTestedDescriptor	http://ed-fi.org/ods/identity/claims/reasonNotTestedDescriptor	2	1
195	recognitionTypeDescriptor	recognitionTypeDescriptor	http://ed-fi.org/ods/identity/claims/recognitionTypeDescriptor	2	1
196	relationDescriptor	relationDescriptor	http://ed-fi.org/ods/identity/claims/relationDescriptor	2	1
197	repeatIdentifierDescriptor	repeatIdentifierDescriptor	http://ed-fi.org/ods/identity/claims/repeatIdentifierDescriptor	2	1
198	reportCard	reportCard	http://ed-fi.org/ods/identity/claims/reportCard	6	1
199	reporterDescriptionDescriptor	reporterDescriptionDescriptor	http://ed-fi.org/ods/identity/claims/reporterDescriptionDescriptor	2	1
200	residencyStatusDescriptor	residencyStatusDescriptor	http://ed-fi.org/ods/identity/claims/residencyStatusDescriptor	2	1
201	responseIndicatorDescriptor	responseIndicatorDescriptor	http://ed-fi.org/ods/identity/claims/responseIndicatorDescriptor	2	1
202	responsibilityDescriptor	responsibilityDescriptor	http://ed-fi.org/ods/identity/claims/responsibilityDescriptor	2	1
203	restraintEvent	restraintEvent	http://ed-fi.org/ods/identity/claims/restraintEvent	6	1
204	restraintEventReasonDescriptor	restraintEventReasonDescriptor	http://ed-fi.org/ods/identity/claims/restraintEventReasonDescriptor	2	1
205	resultDatatypeTypeDescriptor	resultDatatypeTypeDescriptor	http://ed-fi.org/ods/identity/claims/resultDatatypeTypeDescriptor	2	1
206	retestIndicatorDescriptor	retestIndicatorDescriptor	http://ed-fi.org/ods/identity/claims/retestIndicatorDescriptor	2	1
207	school	school	http://ed-fi.org/ods/identity/claims/school	4	1
208	schoolCategoryDescriptor	schoolCategoryDescriptor	http://ed-fi.org/ods/identity/claims/schoolCategoryDescriptor	2	1
209	schoolChoiceImplementStatusDescriptor	schoolChoiceImplementStatusDescriptor	http://ed-fi.org/ods/identity/claims/schoolChoiceImplementStatusDescriptor	2	1
210	schoolFoodServiceProgramServiceDescriptor	schoolFoodServiceProgramServiceDescriptor	http://ed-fi.org/ods/identity/claims/schoolFoodServiceProgramServiceDescriptor	2	1
211	schoolTypeDescriptor	schoolTypeDescriptor	http://ed-fi.org/ods/identity/claims/schoolTypeDescriptor	2	1
212	schoolYearType	schoolYearType	http://ed-fi.org/ods/identity/claims/schoolYearType	1	1
213	section	section	http://ed-fi.org/ods/identity/claims/section	6	1
214	sectionAttendanceTakenEvent	sectionAttendanceTakenEvent	http://ed-fi.org/ods/identity/claims/sectionAttendanceTakenEvent	6	1
215	sectionCharacteristicDescriptor	sectionCharacteristicDescriptor	http://ed-fi.org/ods/identity/claims/sectionCharacteristicDescriptor	2	1
216	separationDescriptor	separationDescriptor	http://ed-fi.org/ods/identity/claims/separationDescriptor	2	1
217	separationReasonDescriptor	separationReasonDescriptor	http://ed-fi.org/ods/identity/claims/separationReasonDescriptor	2	1
218	serviceDescriptor	serviceDescriptor	http://ed-fi.org/ods/identity/claims/serviceDescriptor	2	1
219	session	session	http://ed-fi.org/ods/identity/claims/session	6	1
220	sexDescriptor	sexDescriptor	http://ed-fi.org/ods/identity/claims/sexDescriptor	2	1
221	specialEducationProgramServiceDescriptor	specialEducationProgramServiceDescriptor	http://ed-fi.org/ods/identity/claims/specialEducationProgramServiceDescriptor	2	1
222	specialEducationSettingDescriptor	specialEducationSettingDescriptor	http://ed-fi.org/ods/identity/claims/specialEducationSettingDescriptor	2	1
223	staff	staff	http://ed-fi.org/ods/identity/claims/staff	5	1
224	staffAbsenceEvent	staffAbsenceEvent	http://ed-fi.org/ods/identity/claims/staffAbsenceEvent	6	1
225	staffClassificationDescriptor	staffClassificationDescriptor	http://ed-fi.org/ods/identity/claims/staffClassificationDescriptor	2	1
226	staffCohortAssociation	staffCohortAssociation	http://ed-fi.org/ods/identity/claims/staffCohortAssociation	6	1
227	staffDisciplineIncidentAssociation	staffDisciplineIncidentAssociation	http://ed-fi.org/ods/identity/claims/staffDisciplineIncidentAssociation	6	1
228	staffEducationOrganizationAssignmentAssociation	staffEducationOrganizationAssignmentAssociation	http://ed-fi.org/ods/identity/claims/staffEducationOrganizationAssignmentAssociation	10	1
229	staffEducationOrganizationContactAssociation	staffEducationOrganizationContactAssociation	http://ed-fi.org/ods/identity/claims/staffEducationOrganizationContactAssociation	6	1
230	staffEducationOrganizationEmploymentAssociation	staffEducationOrganizationEmploymentAssociation	http://ed-fi.org/ods/identity/claims/staffEducationOrganizationEmploymentAssociation	10	1
231	staffIdentificationSystemDescriptor	staffIdentificationSystemDescriptor	http://ed-fi.org/ods/identity/claims/staffIdentificationSystemDescriptor	2	1
232	staffLeave	staffLeave	http://ed-fi.org/ods/identity/claims/staffLeave	6	1
233	staffLeaveEventCategoryDescriptor	staffLeaveEventCategoryDescriptor	http://ed-fi.org/ods/identity/claims/staffLeaveEventCategoryDescriptor	2	1
234	staffProgramAssociation	staffProgramAssociation	http://ed-fi.org/ods/identity/claims/staffProgramAssociation	6	1
235	staffSchoolAssociation	staffSchoolAssociation	http://ed-fi.org/ods/identity/claims/staffSchoolAssociation	6	1
236	staffSectionAssociation	staffSectionAssociation	http://ed-fi.org/ods/identity/claims/staffSectionAssociation	6	1
237	stateAbbreviationDescriptor	stateAbbreviationDescriptor	http://ed-fi.org/ods/identity/claims/stateAbbreviationDescriptor	2	1
238	stateEducationAgency	stateEducationAgency	http://ed-fi.org/ods/identity/claims/stateEducationAgency	4	1
239	student	student	http://ed-fi.org/ods/identity/claims/student	5	1
240	studentAcademicRecord	studentAcademicRecord	http://ed-fi.org/ods/identity/claims/studentAcademicRecord	6	1
241	studentAssessment	studentAssessment	http://ed-fi.org/ods/identity/claims/studentAssessment	7	1
242	studentCharacteristicDescriptor	studentCharacteristicDescriptor	http://ed-fi.org/ods/identity/claims/studentCharacteristicDescriptor	2	1
243	studentCohortAssociation	studentCohortAssociation	http://ed-fi.org/ods/identity/claims/studentCohortAssociation	6	1
244	studentCompetencyObjective	studentCompetencyObjective	http://ed-fi.org/ods/identity/claims/studentCompetencyObjective	6	1
245	studentCTEProgramAssociation	studentCTEProgramAssociation	http://ed-fi.org/ods/identity/claims/studentCTEProgramAssociation	6	1
246	studentDisciplineIncidentAssociation	studentDisciplineIncidentAssociation	http://ed-fi.org/ods/identity/claims/studentDisciplineIncidentAssociation	6	1
247	studentEducationOrganizationAssociation	studentEducationOrganizationAssociation	http://ed-fi.org/ods/identity/claims/studentEducationOrganizationAssociation	6	1
248	studentEducationOrganizationResponsibilityAssociation	studentEducationOrganizationResponsibilityAssociation	http://ed-fi.org/ods/identity/claims/studentEducationOrganizationResponsibilityAssociation	6	1
249	studentGradebookEntry	studentGradebookEntry	http://ed-fi.org/ods/identity/claims/studentGradebookEntry	6	1
250	studentHomelessProgramAssociation	studentHomelessProgramAssociation	http://ed-fi.org/ods/identity/claims/studentHomelessProgramAssociation	6	1
251	studentIdentificationSystemDescriptor	studentIdentificationSystemDescriptor	http://ed-fi.org/ods/identity/claims/studentIdentificationSystemDescriptor	2	1
252	studentInterventionAssociation	studentInterventionAssociation	http://ed-fi.org/ods/identity/claims/studentInterventionAssociation	6	1
253	studentInterventionAttendanceEvent	studentInterventionAttendanceEvent	http://ed-fi.org/ods/identity/claims/studentInterventionAttendanceEvent	6	1
254	studentLanguageInstructionProgramAssociation	studentLanguageInstructionProgramAssociation	http://ed-fi.org/ods/identity/claims/studentLanguageInstructionProgramAssociation	6	1
255	studentLearningObjective	studentLearningObjective	http://ed-fi.org/ods/identity/claims/studentLearningObjective	6	1
256	studentMigrantEducationProgramAssociation	studentMigrantEducationProgramAssociation	http://ed-fi.org/ods/identity/claims/studentMigrantEducationProgramAssociation	6	1
257	studentNeglectedOrDelinquentProgramAssociation	studentNeglectedOrDelinquentProgramAssociation	http://ed-fi.org/ods/identity/claims/studentNeglectedOrDelinquentProgramAssociation	6	1
258	studentParentAssociation	studentParentAssociation	http://ed-fi.org/ods/identity/claims/studentParentAssociation	6	1
259	studentParticipationCodeDescriptor	studentParticipationCodeDescriptor	http://ed-fi.org/ods/identity/claims/studentParticipationCodeDescriptor	2	1
260	studentProgramAssociation	studentProgramAssociation	http://ed-fi.org/ods/identity/claims/studentProgramAssociation	6	1
261	studentProgramAttendanceEvent	studentProgramAttendanceEvent	http://ed-fi.org/ods/identity/claims/studentProgramAttendanceEvent	6	1
262	studentSchoolAssociation	studentSchoolAssociation	http://ed-fi.org/ods/identity/claims/studentSchoolAssociation	10	1
263	studentSchoolAttendanceEvent	studentSchoolAttendanceEvent	http://ed-fi.org/ods/identity/claims/studentSchoolAttendanceEvent	6	1
264	studentSchoolFoodServiceProgramAssociation	studentSchoolFoodServiceProgramAssociation	http://ed-fi.org/ods/identity/claims/studentSchoolFoodServiceProgramAssociation	6	1
265	studentSectionAssociation	studentSectionAssociation	http://ed-fi.org/ods/identity/claims/studentSectionAssociation	6	1
266	studentSectionAttendanceEvent	studentSectionAttendanceEvent	http://ed-fi.org/ods/identity/claims/studentSectionAttendanceEvent	6	1
267	studentSpecialEducationProgramAssociation	studentSpecialEducationProgramAssociation	http://ed-fi.org/ods/identity/claims/studentSpecialEducationProgramAssociation	6	1
268	studentTitleIPartAProgramAssociation	studentTitleIPartAProgramAssociation	http://ed-fi.org/ods/identity/claims/studentTitleIPartAProgramAssociation	6	1
269	teachingCredentialBasisDescriptor	teachingCredentialBasisDescriptor	http://ed-fi.org/ods/identity/claims/teachingCredentialBasisDescriptor	2	1
270	teachingCredentialDescriptor	teachingCredentialDescriptor	http://ed-fi.org/ods/identity/claims/teachingCredentialDescriptor	2	1
271	technicalSkillsAssessmentDescriptor	technicalSkillsAssessmentDescriptor	http://ed-fi.org/ods/identity/claims/technicalSkillsAssessmentDescriptor	2	1
272	telephoneNumberTypeDescriptor	telephoneNumberTypeDescriptor	http://ed-fi.org/ods/identity/claims/telephoneNumberTypeDescriptor	2	1
273	termDescriptor	termDescriptor	http://ed-fi.org/ods/identity/claims/termDescriptor	2	1
274	titleIPartAParticipantDescriptor	titleIPartAParticipantDescriptor	http://ed-fi.org/ods/identity/claims/titleIPartAParticipantDescriptor	2	1
275	titleIPartAProgramServiceDescriptor	titleIPartAProgramServiceDescriptor	http://ed-fi.org/ods/identity/claims/titleIPartAProgramServiceDescriptor	2	1
276	titleIPartASchoolDesignationDescriptor	titleIPartASchoolDesignationDescriptor	http://ed-fi.org/ods/identity/claims/titleIPartASchoolDesignationDescriptor	2	1
277	tribalAffiliationDescriptor	tribalAffiliationDescriptor	http://ed-fi.org/ods/identity/claims/tribalAffiliationDescriptor	2	1
278	visaDescriptor	visaDescriptor	http://ed-fi.org/ods/identity/claims/visaDescriptor	2	1
279	weaponDescriptor	weaponDescriptor	http://ed-fi.org/ods/identity/claims/weaponDescriptor	2	1
\.


--
-- Data for Name: DeployJournal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DeployJournal" (schemaversionsid, scriptname, applied) FROM stdin;
1	Artifacts.PgSql.Structure.Security.0010-Schemas.sql	2020-04-22 18:12:00.18225
2	Artifacts.PgSql.Structure.Security.0020-Tables.sql	2020-04-22 18:12:00.240659
3	Artifacts.PgSql.Structure.Security.0030-ForeignKeys.sql	2020-04-22 18:12:00.266861
4	Artifacts.PgSql.Structure.Security.0040-Indexes.sql	2020-04-22 18:12:00.312101
5	Artifacts.PgSql.Data.Security.0001-ResourceClaimMetadata_generated.sql	2020-04-22 18:12:00.494888
6	Artifacts.PgSql.Data.Security.1000-CreateDistrictHostedSISClaimSet.sql	2020-04-22 18:12:00.503956
7	Artifacts.PgSql.Data.Security.1010-AssessmentVendorClaimSetUpdatePerformanceLevels.sql	2020-04-22 18:12:00.511245
8	Artifacts.PgSql.Data.Security.1019-AddSandboxClaimset.sql	2020-04-22 18:12:00.51303
9	Artifacts.PgSql.Data.Security.1020-DataStandard3.2b-ResourceClaimMetadata.sql	2020-04-22 18:12:00.515149
\.


--
-- Name: actions_actionid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.actions_actionid_seq', 4, true);


--
-- Name: applications_applicationid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.applications_applicationid_seq', 1, true);


--
-- Name: authorizationstrategies_authorizationstrategyid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.authorizationstrategies_authorizationstrategyid_seq', 7, true);


--
-- Name: claimsetresourceclaims_claimsetresourceclaimid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.claimsetresourceclaims_claimsetresourceclaimid_seq', 191, true);


--
-- Name: claimsets_claimsetid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.claimsets_claimsetid_seq', 7, true);


--
-- Name: resourceclaimauthorizationmet_resourceclaimauthorizationstr_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.resourceclaimauthorizationmet_resourceclaimauthorizationstr_seq', 52, true);


--
-- Name: resourceclaims_resourceclaimid_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.resourceclaims_resourceclaimid_seq', 279, true);


--
-- Name: DeployJournal_schemaversionsid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."DeployJournal_schemaversionsid_seq"', 9, true);


--
-- Name: actions actions_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.actions
    ADD CONSTRAINT actions_pk PRIMARY KEY (actionid);


--
-- Name: applications applications_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.applications
    ADD CONSTRAINT applications_pk PRIMARY KEY (applicationid);


--
-- Name: authorizationstrategies authorizationstrategies_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.authorizationstrategies
    ADD CONSTRAINT authorizationstrategies_pk PRIMARY KEY (authorizationstrategyid);


--
-- Name: claimsetresourceclaims claimsetresourceclaims_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsetresourceclaims
    ADD CONSTRAINT claimsetresourceclaims_pk PRIMARY KEY (claimsetresourceclaimid);


--
-- Name: claimsets claimsets_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsets
    ADD CONSTRAINT claimsets_pk PRIMARY KEY (claimsetid);


--
-- Name: resourceclaimauthorizationmetadatas resourceclaimauthorizationmetadatas_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaimauthorizationmetadatas
    ADD CONSTRAINT resourceclaimauthorizationmetadatas_pk PRIMARY KEY (resourceclaimauthorizationstrategyid);


--
-- Name: resourceclaims resourceclaims_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaims
    ADD CONSTRAINT resourceclaims_pk PRIMARY KEY (resourceclaimid);


--
-- Name: DeployJournal PK_DeployJournal_Id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DeployJournal"
    ADD CONSTRAINT "PK_DeployJournal_Id" PRIMARY KEY (schemaversionsid);


--
-- Name: ix_authorizationstrategies_application_applicationid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_authorizationstrategies_application_applicationid ON dbo.authorizationstrategies USING btree (application_applicationid);


--
-- Name: ix_claimsetresourceclaims_action_actionid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_claimsetresourceclaims_action_actionid ON dbo.claimsetresourceclaims USING btree (action_actionid);


--
-- Name: ix_claimsetresourceclaims_authstratover_authstratid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_claimsetresourceclaims_authstratover_authstratid ON dbo.claimsetresourceclaims USING btree (authorizationstrategyoverride_authorizationstrategyid);


--
-- Name: ix_claimsetresourceclaims_claimset_claimsetid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_claimsetresourceclaims_claimset_claimsetid ON dbo.claimsetresourceclaims USING btree (claimset_claimsetid);


--
-- Name: ix_claimsetresourceclaims_resourceclaim_resourceclaimid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_claimsetresourceclaims_resourceclaim_resourceclaimid ON dbo.claimsetresourceclaims USING btree (resourceclaim_resourceclaimid);


--
-- Name: ix_claimsets_application_applicationid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_claimsets_application_applicationid ON dbo.claimsets USING btree (application_applicationid);


--
-- Name: ix_resourceclaimauthorizationmetadatas_action_actionid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_resourceclaimauthorizationmetadatas_action_actionid ON dbo.resourceclaimauthorizationmetadatas USING btree (action_actionid);


--
-- Name: ix_resourceclaimauthorizationmetadatas_authstrat_authstratid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_resourceclaimauthorizationmetadatas_authstrat_authstratid ON dbo.resourceclaimauthorizationmetadatas USING btree (authorizationstrategy_authorizationstrategyid);


--
-- Name: ix_resourceclaimauthorizationmetadatas_rescla_resclaid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_resourceclaimauthorizationmetadatas_rescla_resclaid ON dbo.resourceclaimauthorizationmetadatas USING btree (resourceclaim_resourceclaimid);


--
-- Name: ix_resourceclaims_application_applicationid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_resourceclaims_application_applicationid ON dbo.resourceclaims USING btree (application_applicationid);


--
-- Name: ix_resourceclaims_parentresourceclaimid; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE INDEX ix_resourceclaims_parentresourceclaimid ON dbo.resourceclaims USING btree (parentresourceclaimid);


--
-- Name: authorizationstrategies fk_authorizationstrategies_applications; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.authorizationstrategies
    ADD CONSTRAINT fk_authorizationstrategies_applications FOREIGN KEY (application_applicationid) REFERENCES dbo.applications(applicationid) ON DELETE CASCADE;


--
-- Name: claimsetresourceclaims fk_claimsetresourceclaims_actions; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsetresourceclaims
    ADD CONSTRAINT fk_claimsetresourceclaims_actions FOREIGN KEY (action_actionid) REFERENCES dbo.actions(actionid) ON DELETE CASCADE;


--
-- Name: claimsetresourceclaims fk_claimsetresourceclaims_authorizationstrategies; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsetresourceclaims
    ADD CONSTRAINT fk_claimsetresourceclaims_authorizationstrategies FOREIGN KEY (authorizationstrategyoverride_authorizationstrategyid) REFERENCES dbo.authorizationstrategies(authorizationstrategyid);


--
-- Name: claimsetresourceclaims fk_claimsetresourceclaims_claimsets; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsetresourceclaims
    ADD CONSTRAINT fk_claimsetresourceclaims_claimsets FOREIGN KEY (claimset_claimsetid) REFERENCES dbo.claimsets(claimsetid) ON DELETE CASCADE;


--
-- Name: claimsetresourceclaims fk_claimsetresourceclaims_resourceclaims; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsetresourceclaims
    ADD CONSTRAINT fk_claimsetresourceclaims_resourceclaims FOREIGN KEY (resourceclaim_resourceclaimid) REFERENCES dbo.resourceclaims(resourceclaimid);


--
-- Name: claimsets fk_claimsets_applications; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.claimsets
    ADD CONSTRAINT fk_claimsets_applications FOREIGN KEY (application_applicationid) REFERENCES dbo.applications(applicationid) ON DELETE CASCADE;


--
-- Name: resourceclaimauthorizationmetadatas fk_resourceclaimauthorizationstrategies_actions; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaimauthorizationmetadatas
    ADD CONSTRAINT fk_resourceclaimauthorizationstrategies_actions FOREIGN KEY (action_actionid) REFERENCES dbo.actions(actionid) ON DELETE CASCADE;


--
-- Name: resourceclaimauthorizationmetadatas fk_resourceclaimauthorizationstrategies_authorizationstrategies; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaimauthorizationmetadatas
    ADD CONSTRAINT fk_resourceclaimauthorizationstrategies_authorizationstrategies FOREIGN KEY (authorizationstrategy_authorizationstrategyid) REFERENCES dbo.authorizationstrategies(authorizationstrategyid);


--
-- Name: resourceclaimauthorizationmetadatas fk_resourceclaimauthorizationstrategies_resourceclaims; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaimauthorizationmetadatas
    ADD CONSTRAINT fk_resourceclaimauthorizationstrategies_resourceclaims FOREIGN KEY (resourceclaim_resourceclaimid) REFERENCES dbo.resourceclaims(resourceclaimid);


--
-- Name: resourceclaims fk_resourceclaims_applications; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaims
    ADD CONSTRAINT fk_resourceclaims_applications FOREIGN KEY (application_applicationid) REFERENCES dbo.applications(applicationid) ON DELETE CASCADE;


--
-- Name: resourceclaims fk_resourceclaims_resourceclaims; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.resourceclaims
    ADD CONSTRAINT fk_resourceclaims_resourceclaims FOREIGN KEY (parentresourceclaimid) REFERENCES dbo.resourceclaims(resourceclaimid);


--
-- PostgreSQL database dump complete
--

