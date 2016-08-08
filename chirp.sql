--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: chirps; Type: TABLE; Schema: public; Owner: tsanders
--

CREATE TABLE chirps (
    id integer NOT NULL,
    chirper_id integer NOT NULL,
    chirp_date timestamp without time zone DEFAULT now(),
    chirp character varying(140) NOT NULL
);


ALTER TABLE chirps OWNER TO tsanders;

--
-- Name: chirps_id_seq; Type: SEQUENCE; Schema: public; Owner: tsanders
--

CREATE SEQUENCE chirps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE chirps_id_seq OWNER TO tsanders;

--
-- Name: chirps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tsanders
--

ALTER SEQUENCE chirps_id_seq OWNED BY chirps.id;


--
-- Name: follows; Type: TABLE; Schema: public; Owner: tsanders
--

CREATE TABLE follows (
    id integer NOT NULL,
    follower_id integer NOT NULL,
    leader_id integer NOT NULL
);


ALTER TABLE follows OWNER TO tsanders;

--
-- Name: follows_id_seq; Type: SEQUENCE; Schema: public; Owner: tsanders
--

CREATE SEQUENCE follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE follows_id_seq OWNER TO tsanders;

--
-- Name: follows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tsanders
--

ALTER SEQUENCE follows_id_seq OWNED BY follows.id;


--
-- Name: likes; Type: TABLE; Schema: public; Owner: tsanders
--

CREATE TABLE likes (
    id integer NOT NULL,
    chirp_id integer NOT NULL,
    follow_id integer NOT NULL,
    like_date date DEFAULT now()
);


ALTER TABLE likes OWNER TO tsanders;

--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: tsanders
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE likes_id_seq OWNER TO tsanders;

--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tsanders
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: temp; Type: TABLE; Schema: public; Owner: tsanders
--

CREATE TABLE temp (
    handle character varying,
    name character varying,
    chirp character varying
);


ALTER TABLE temp OWNER TO tsanders;

--
-- Name: users; Type: TABLE; Schema: public; Owner: tsanders
--

CREATE TABLE users (
    id integer NOT NULL,
    handle character varying NOT NULL,
    fname character varying NOT NULL,
    lname character varying NOT NULL,
    "timestamp" date DEFAULT now(),
    password character varying
);


ALTER TABLE users OWNER TO tsanders;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: tsanders
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO tsanders;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tsanders
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: v_num_chirps; Type: VIEW; Schema: public; Owner: tsanders
--

CREATE VIEW v_num_chirps AS
 SELECT users.id AS user_id,
    count(*) AS num_chirps
   FROM (users
     LEFT JOIN chirps ON ((users.id = chirps.chirper_id)))
  GROUP BY users.id;


ALTER TABLE v_num_chirps OWNER TO tsanders;

--
-- Name: v_num_followees; Type: VIEW; Schema: public; Owner: tsanders
--

CREATE VIEW v_num_followees AS
 SELECT follows.leader_id,
    count(*) AS num_being_followed
   FROM follows
  GROUP BY follows.leader_id;


ALTER TABLE v_num_followees OWNER TO tsanders;

--
-- Name: v_num_follows; Type: VIEW; Schema: public; Owner: tsanders
--

CREATE VIEW v_num_follows AS
 SELECT follows.follower_id,
    count(*) AS num_following
   FROM follows
  GROUP BY follows.follower_id;


ALTER TABLE v_num_follows OWNER TO tsanders;

--
-- Name: v_chirp_follow_summary; Type: VIEW; Schema: public; Owner: tsanders
--

CREATE VIEW v_chirp_follow_summary AS
 SELECT users.id AS user_id,
    users.handle,
    users.fname,
    users.lname,
    v_num_chirps.num_chirps,
    v_num_follows.num_following,
    v_num_followees.num_being_followed
   FROM (((users
     LEFT JOIN v_num_chirps ON ((users.id = v_num_chirps.user_id)))
     LEFT JOIN v_num_follows ON ((users.id = v_num_follows.follower_id)))
     LEFT JOIN v_num_followees ON ((users.id = v_num_followees.leader_id)));


ALTER TABLE v_chirp_follow_summary OWNER TO tsanders;

--
-- Name: v_follows; Type: VIEW; Schema: public; Owner: tsanders
--

CREATE VIEW v_follows AS
 SELECT follows.follower_id,
    followers.handle AS follower_handle,
    followers.fname AS follower_fname,
    followers.lname AS follower_lname,
    follows.leader_id,
    chirpers.handle AS leader_handle,
    chirpers.fname AS leader_fname,
    chirpers.lname AS leader_lname
   FROM ((follows
     LEFT JOIN users chirpers ON ((follows.leader_id = chirpers.id)))
     LEFT JOIN users followers ON ((follows.follower_id = followers.id)));


ALTER TABLE v_follows OWNER TO tsanders;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY chirps ALTER COLUMN id SET DEFAULT nextval('chirps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY follows ALTER COLUMN id SET DEFAULT nextval('follows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Data for Name: chirps; Type: TABLE DATA; Schema: public; Owner: tsanders
--

COPY chirps (id, chirper_id, chirp_date, chirp) FROM stdin;
1	1	2016-01-06 13:16:31.548357	MongoDB rocks!
5	1	2014-11-12 13:16:31.548357	MySQL rocks!
6	1	2014-11-12 13:16:31.548357	postreSQL rocks!
7	1	2014-10-01 13:16:31.548357	MS-SQL Server sucks!
8	1	2016-01-13 13:16:31.548357	Oracle sucks!
9	4	2016-03-30 13:16:31.548357	AngularJS rocks!
10	4	2015-07-15 13:16:31.548357	node.js rocks!
11	4	2015-01-21 13:16:31.548357	JavaScript rocks!
12	5	2016-07-06 13:16:31.548357	jQuery rocks!
13	5	2014-12-17 13:16:31.548357	Functional Programming rocks!
14	5	2015-01-28 13:16:31.548357	express rocks!
15	6	2014-10-29 13:16:31.548357	mongoose rocks!
16	6	2015-12-16 13:16:31.548357	npm rocks!
17	7	2015-09-09 13:16:31.548357	LAMP Stack rocks!
18	7	2016-05-18 13:16:31.548357	MEAN rocks!
19	7	2015-11-11 13:16:31.548357	Whiteboard Challenges rock!
20	8	2015-08-19 13:16:31.548357	I love job hunting!
22	8	2015-11-11 13:16:31.548357	ATV rocks!
23	9	2016-04-06 13:16:31.548357	The breakroom has no snacks!
24	9	2014-09-24 13:16:31.548357	Free Beer?!?!
26	4	2014-11-05 13:16:31.548357	Bootstrap rocks!
27	5	2016-03-09 13:16:31.548357	animate.css rocks!
28	6	2016-07-13 13:16:31.548357	GitHub rocks!
29	7	2015-03-04 13:16:31.548357	Surge rocks!
30	8	2016-04-06 13:16:31.548357	Now rocks!
31	9	2015-04-22 13:16:31.548357	My portfolio rocks!
32	4	2015-02-11 13:16:31.548357	Atom rocks!
33	5	2015-09-30 13:16:31.548357	AJAX rocks!
34	6	2015-04-01 13:16:31.548357	Google Maps rocks
35	7	2016-06-15 13:16:31.548357	HTML5 rocks!
36	8	2015-12-16 13:16:31.548357	CSS3 rocks!
37	9	2015-06-24 13:16:31.548357	The Canvas Element rocks!
38	4	2016-07-20 13:16:31.548357	Closures rock!
39	5	2015-06-03 13:16:31.548357	Asynchronous Functions rock!
40	5	2015-02-18 13:16:31.548357	Callback Hell sucks!
41	6	2015-07-08 13:16:31.548357	Handlebars rock!
42	7	2015-10-28 13:16:31.548357	Middleware rocks!
43	8	2015-01-28 13:16:31.548357	Sessions rock!
44	9	2015-10-28 13:16:31.548357	Sessions rock!
\.


--
-- Name: chirps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tsanders
--

SELECT pg_catalog.setval('chirps_id_seq', 73, true);


--
-- Data for Name: follows; Type: TABLE DATA; Schema: public; Owner: tsanders
--

COPY follows (id, follower_id, leader_id) FROM stdin;
15	1	4
16	1	5
17	1	6
18	1	7
19	1	8
20	1	9
22	4	5
23	4	6
24	5	7
25	5	8
26	5	9
27	6	4
28	6	5
31	7	8
32	7	9
33	8	4
34	8	5
35	8	6
36	9	7
37	9	8
56	1	1
58	7	1
59	4	1
60	4	4
63	6	1
\.


--
-- Name: follows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tsanders
--

SELECT pg_catalog.setval('follows_id_seq', 71, true);


--
-- Data for Name: likes; Type: TABLE DATA; Schema: public; Owner: tsanders
--

COPY likes (id, chirp_id, follow_id, like_date) FROM stdin;
\.


--
-- Name: likes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tsanders
--

SELECT pg_catalog.setval('likes_id_seq', 1, false);


--
-- Data for Name: temp; Type: TABLE DATA; Schema: public; Owner: tsanders
--

COPY temp (handle, name, chirp) FROM stdin;
tsanders	Tim Sanders	this is a test
tsanders	Tim Sanders	this is a test
wwyatt	Will Wyatt	What is for lunch at the next chow down?
pcarlin	Peter Carlin	Welcome me to Chirp!
tsanders	Tim Sanders	this is a test
tsanders	Tim Sanders	shit happens
tsanders	Tim Sanders	shit happens
tsanders	Tim Sanders	more shit happens
tsanders	Tim Sanders	and if you can believe it, still more shit happens!
tsanders	Tim Sanders	
tsanders	Tim Sanders	what the fuck?
tsanders	Tim Sanders	
tsanders	Tim Sanders	
tsanders	Tim Sanders	
pcarlin	Peter Carlin	I want Tim to go the CostCo.
ctonkes	Cor Tonkes	Succes nog met alles regelen en pas op jezelf en op elkaar veel liefs van ons
tsanders	Tim Sanders	MongoDB rocks!
tsanders	Tim Sanders	MySQL rocks!
tsanders	Tim Sanders	postreSQL rocks!
tsanders	Tim Sanders	MS-SQL Server sucks!
tsanders	Tim Sanders	Oracle sucks!
tho	Toby Ho	AngularJS rocks!
tho	Toby Ho	JavaScript rocks!
cbarber	Cody Barber	jQuery rocks!
cbarber	Cody Barber	Functional Programming rocks!
cbarber	Cody Barber	express rocks!
dkendrick	DeeAnn Kendrick	mongoose rocks!
dkendrick	DeeAnn Kendrick	npm rocks!
kluck	Kyle Luck	LAMP Stack rocks!
kluck	Kyle Luck	MEAN rocks!
kluck	Kyle Luck	Whiteboard Challenges rock!
mbrimmer	Matt Brimmer	I love job hunting!
mbrimmer	Matt Brimmer	Toby rocks!
mbrimmer	Matt Brimmer	ATV rocks!
wwyatt	Will Wyatt	The breakroom has no snacks!
wwyatt	Will Wyatt	Free Beer?!?!
wwyatt	Will Wyatt	What is for lunch at the next chow down?
tho	Toby Ho	Bootstrap rocks!
cbarber	Cody Barber	animate.css rocks!
dkendrick	DeeAnn Kendrick	GitHub rocks!
mbrimmer	Matt Brimmer	Now rocks!
wwyatt	Will Wyatt	My portfolio rocks!
tho	Toby Ho	Atom rocks!
cbarber	Cody Barber	AJAX rocks!
dkendrick	DeeAnn Kendrick	Google Maps rocks
mbrimmer	Matt Brimmer	CSS3 rocks!
wwyatt	Will Wyatt	The Canvas Element rocks!
cbarber	Cody Barber	Asynchronous Functions rock!
cbarber	Cody Barber	Callback Hell sucks!
dkendrick	DeeAnn Kendrick	Handlebars rock!
kluck	Kyle Luck	Middleware rocks!
mbrimmer	Matt Brimmer	Sessions rock!
wwyatt	Will Wyatt	Sessions rock!
tsanders	Tim Sanders	this is a test
tsanders	Tim Sanders	this is a test
tsanders	Tim Sanders	this is a test
wwyatt	Will Wyatt	What is for lunch at the next chow down?
pcarlin	Peter Carlin	Welcome me to Chirp!
tsanders	Tim Sanders	this is a test
tsanders	Tim Sanders	shit happens
tsanders	Tim Sanders	shit happens
tsanders	Tim Sanders	more shit happens
tsanders	Tim Sanders	and if you can believe it, still more shit happens!
tsanders	Tim Sanders	
tsanders	Tim Sanders	what the fuck?
tsanders	Tim Sanders	
tsanders	Tim Sanders	
tsanders	Tim Sanders	
pcarlin	Peter Carlin	I want Tim to go the CostCo.
ctonkes	Cor Tonkes	Succes nog met alles regelen en pas op jezelf en op elkaar veel liefs van ons
tsanders	Tim Sanders	MongoDB rocks!
tsanders	Tim Sanders	MySQL rocks!
tsanders	Tim Sanders	postreSQL rocks!
tsanders	Tim Sanders	MS-SQL Server sucks!
tsanders	Tim Sanders	Oracle sucks!
tho	Toby Ho	AngularJS rocks!
tho	Toby Ho	JavaScript rocks!
cbarber	Cody Barber	jQuery rocks!
cbarber	Cody Barber	Functional Programming rocks!
cbarber	Cody Barber	express rocks!
dkendrick	DeeAnn Kendrick	mongoose rocks!
dkendrick	DeeAnn Kendrick	npm rocks!
kluck	Kyle Luck	LAMP Stack rocks!
kluck	Kyle Luck	MEAN rocks!
kluck	Kyle Luck	Whiteboard Challenges rock!
mbrimmer	Matt Brimmer	I love job hunting!
mbrimmer	Matt Brimmer	Toby rocks!
mbrimmer	Matt Brimmer	ATV rocks!
wwyatt	Will Wyatt	The breakroom has no snacks!
wwyatt	Will Wyatt	Free Beer?!?!
wwyatt	Will Wyatt	What is for lunch at the next chow down?
tho	Toby Ho	Bootstrap rocks!
cbarber	Cody Barber	animate.css rocks!
dkendrick	DeeAnn Kendrick	GitHub rocks!
mbrimmer	Matt Brimmer	Now rocks!
wwyatt	Will Wyatt	My portfolio rocks!
tho	Toby Ho	Atom rocks!
cbarber	Cody Barber	AJAX rocks!
dkendrick	DeeAnn Kendrick	Google Maps rocks
mbrimmer	Matt Brimmer	CSS3 rocks!
wwyatt	Will Wyatt	The Canvas Element rocks!
cbarber	Cody Barber	Asynchronous Functions rock!
cbarber	Cody Barber	Callback Hell sucks!
dkendrick	DeeAnn Kendrick	Handlebars rock!
kluck	Kyle Luck	Middleware rocks!
mbrimmer	Matt Brimmer	Sessions rock!
wwyatt	Will Wyatt	Sessions rock!
tsanders	Tim Sanders	this is a test
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: tsanders
--

COPY users (id, handle, fname, lname, "timestamp", password) FROM stdin;
4	tho	Toby	Ho	2016-07-26	$2b$12$BCj2d8LaowgNzrwXiRWieO1v3NfK6onnh7V0ANB/xUqUmHvBu3uXK
5	cbarber	Cody	Barber	2016-07-26	$2b$12$0P/vrqn3XaogguZks027P.dIPSHJlHTpFtYrhU3bL279P/EeqbVm2
6	dkendrick	DeeAnn	Kendrick	2016-07-26	$2b$12$XVGtdg7JkpaAo.8wVqHmjOm6KQp8.VHFeLr5cZENZEa2X5L0XzFVG
7	kluck	Kyle	Luck	2016-07-26	$2b$12$WvR9Dew0lni5RaumURDnouEH/e7LyddwK5wCmcwGB1tTcqe1vuGUa
8	mbrimmer	Matt	Brimmer	2016-07-26	$2b$12$ReBrv4FMR4bsSCWenrlreuSbBIVYDUFqrhRfOmnDQhn0hIRBTdhyG
9	wwyatt	Will	Wyatt	2016-07-26	$2b$12$nEfuPdNDZWywJFHTzT/jMeRZIIlK5bKjoA73XktCn3x6BFFc1XZ16
1	tsanders	Tim	Sanders	2016-07-26	$2b$12$HCYtwgw/x.LaESLFq.pqh.86.ZDYF9jBM4ydzIHtHHEI/clQHJfiO
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tsanders
--

SELECT pg_catalog.setval('users_id_seq', 54, true);


--
-- Name: chirps_pkey; Type: CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY chirps
    ADD CONSTRAINT chirps_pkey PRIMARY KEY (id);


--
-- Name: follows_leader_id_follower_id_key; Type: CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_leader_id_follower_id_key UNIQUE (follower_id, leader_id);


--
-- Name: follows_pkey; Type: CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: users_handle_key; Type: CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_handle_key UNIQUE (handle);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: chirps_fk1; Type: FK CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY chirps
    ADD CONSTRAINT chirps_fk1 FOREIGN KEY (chirper_id) REFERENCES users(id);


--
-- Name: follows_fk1; Type: FK CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_fk1 FOREIGN KEY (follower_id) REFERENCES users(id);


--
-- Name: follows_fk2; Type: FK CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_fk2 FOREIGN KEY (leader_id) REFERENCES users(id);


--
-- Name: likes_fk1; Type: FK CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_fk1 FOREIGN KEY (chirp_id) REFERENCES chirps(id);


--
-- Name: likes_fk2; Type: FK CONSTRAINT; Schema: public; Owner: tsanders
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_fk2 FOREIGN KEY (follow_id) REFERENCES users(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

