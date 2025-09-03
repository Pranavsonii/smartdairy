--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Ubuntu 14.18-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 17.0

-- Started on 2025-09-02 01:49:42

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

DROP DATABASE milk_delivery_db;
--
-- TOC entry 3483 (class 1262 OID 16385)
-- Name: milk_delivery_db; Type: DATABASE; Schema: -; Owner: admin
--

CREATE DATABASE milk_delivery_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';


ALTER DATABASE milk_delivery_db OWNER TO admin;

\connect milk_delivery_db

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 209 (class 1259 OID 16386)
-- Name: customers; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    name character varying(255) NOT NULL,
    location character varying(255),
    phone character varying(20) NOT NULL,
    address text,
    stop_loss numeric(10,2),
    points integer DEFAULT 0,
    status character varying(20) DEFAULT 'active'::character varying,
    default_quantity integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    photo character varying(255)
);


ALTER TABLE public.customers OWNER TO admin;

--
-- TOC entry 210 (class 1259 OID 16396)
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_customer_id_seq OWNER TO admin;

--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 210
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- TOC entry 211 (class 1259 OID 16397)
-- Name: delivery_guys; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.delivery_guys (
    delivery_guy_id integer NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(15) NOT NULL,
    address text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.delivery_guys OWNER TO admin;

--
-- TOC entry 212 (class 1259 OID 16404)
-- Name: delivery_guys_delivery_guy_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.delivery_guys_delivery_guy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.delivery_guys_delivery_guy_id_seq OWNER TO admin;

--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 212
-- Name: delivery_guys_delivery_guy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.delivery_guys_delivery_guy_id_seq OWNED BY public.delivery_guys.delivery_guy_id;


--
-- TOC entry 213 (class 1259 OID 16405)
-- Name: drive_customers_sales; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.drive_customers_sales (
    id integer NOT NULL,
    qr_id integer,
    drive_id integer,
    customer_id integer,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    sms_sent boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.drive_customers_sales OWNER TO admin;

--
-- TOC entry 214 (class 1259 OID 16411)
-- Name: drive_customers_sales_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.drive_customers_sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drive_customers_sales_id_seq OWNER TO admin;

--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 214
-- Name: drive_customers_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.drive_customers_sales_id_seq OWNED BY public.drive_customers_sales.id;


--
-- TOC entry 215 (class 1259 OID 16412)
-- Name: drive_locations_log; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.drive_locations_log (
    drive_location_id integer NOT NULL,
    drive_id integer,
    "time" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    longitude character varying,
    latitude character varying
);


ALTER TABLE public.drive_locations_log OWNER TO admin;

--
-- TOC entry 216 (class 1259 OID 16418)
-- Name: drive_locations_log_drive_location_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.drive_locations_log_drive_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drive_locations_log_drive_location_id_seq OWNER TO admin;

--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 216
-- Name: drive_locations_log_drive_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.drive_locations_log_drive_location_id_seq OWNED BY public.drive_locations_log.drive_location_id;


--
-- TOC entry 217 (class 1259 OID 16419)
-- Name: drives; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.drives (
    drive_id integer NOT NULL,
    delivery_guy_id integer,
    route_id integer,
    stock integer NOT NULL,
    sold integer DEFAULT 0,
    returned integer DEFAULT 0,
    remarks text,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    total_amount numeric(10,2) DEFAULT 0,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    name character varying
);


ALTER TABLE public.drives OWNER TO admin;

--
-- TOC entry 218 (class 1259 OID 16430)
-- Name: drives_drive_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.drives_drive_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drives_drive_id_seq OWNER TO admin;

--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 218
-- Name: drives_drive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.drives_drive_id_seq OWNED BY public.drives.drive_id;


--
-- TOC entry 219 (class 1259 OID 16431)
-- Name: outlets; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.outlets (
    outlet_id integer NOT NULL,
    name character varying(255) NOT NULL,
    address text,
    phone character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    coordinates character varying
);


ALTER TABLE public.outlets OWNER TO admin;

--
-- TOC entry 220 (class 1259 OID 16438)
-- Name: outlets_outlet_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.outlets_outlet_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.outlets_outlet_id_seq OWNER TO admin;

--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 220
-- Name: outlets_outlet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.outlets_outlet_id_seq OWNED BY public.outlets.outlet_id;


--
-- TOC entry 221 (class 1259 OID 16439)
-- Name: payment_logs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.payment_logs (
    payment_id integer NOT NULL,
    customer_id integer,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    amount numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'completed'::character varying,
    mode character varying(20) NOT NULL,
    remarks text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payment_logs OWNER TO admin;

--
-- TOC entry 222 (class 1259 OID 16448)
-- Name: payment_logs_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.payment_logs_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_logs_payment_id_seq OWNER TO admin;

--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 222
-- Name: payment_logs_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.payment_logs_payment_id_seq OWNED BY public.payment_logs.payment_id;


--
-- TOC entry 231 (class 1259 OID 16697)
-- Name: point_transactions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.point_transactions (
    transaction_id integer NOT NULL,
    customer_id integer,
    transaction_type character varying(20) NOT NULL,
    points integer NOT NULL,
    previous_balance integer NOT NULL,
    new_balance integer NOT NULL,
    reason character varying(255),
    performed_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    date character varying
);


ALTER TABLE public.point_transactions OWNER TO admin;

--
-- TOC entry 230 (class 1259 OID 16696)
-- Name: point_transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.point_transactions_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.point_transactions_transaction_id_seq OWNER TO admin;

--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 230
-- Name: point_transactions_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.point_transactions_transaction_id_seq OWNED BY public.point_transactions.transaction_id;


--
-- TOC entry 223 (class 1259 OID 16449)
-- Name: qr_codes; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.qr_codes (
    qr_id integer NOT NULL,
    code character varying(255) NOT NULL,
    customer_id integer,
    status character varying(20) DEFAULT 'active'::character varying,
    activated_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.qr_codes OWNER TO admin;

--
-- TOC entry 224 (class 1259 OID 16455)
-- Name: qr_codes_qr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.qr_codes_qr_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.qr_codes_qr_id_seq OWNER TO admin;

--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 224
-- Name: qr_codes_qr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.qr_codes_qr_id_seq OWNED BY public.qr_codes.qr_id;


--
-- TOC entry 225 (class 1259 OID 16456)
-- Name: route_customers; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.route_customers (
    route_id integer NOT NULL,
    customer_id integer NOT NULL,
    "position" integer NOT NULL
);


ALTER TABLE public.route_customers OWNER TO admin;

--
-- TOC entry 226 (class 1259 OID 16459)
-- Name: routes; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.routes (
    route_id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    description text,
    route json
);


ALTER TABLE public.routes OWNER TO admin;

--
-- TOC entry 227 (class 1259 OID 16466)
-- Name: routes_route_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.routes_route_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.routes_route_id_seq OWNER TO admin;

--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 227
-- Name: routes_route_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.routes_route_id_seq OWNED BY public.routes.route_id;


--
-- TOC entry 228 (class 1259 OID 16467)
-- Name: users; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    delivery_guy_id integer,
    outlet_id integer,
    phone character varying(15) NOT NULL,
    password character varying(100) NOT NULL,
    role character varying(20) DEFAULT 'delivery'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO admin;

--
-- TOC entry 229 (class 1259 OID 16473)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO admin;

--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 229
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- TOC entry 3225 (class 2604 OID 16474)
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- TOC entry 3231 (class 2604 OID 16475)
-- Name: delivery_guys delivery_guy_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.delivery_guys ALTER COLUMN delivery_guy_id SET DEFAULT nextval('public.delivery_guys_delivery_guy_id_seq'::regclass);


--
-- TOC entry 3234 (class 2604 OID 16476)
-- Name: drive_customers_sales id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drive_customers_sales ALTER COLUMN id SET DEFAULT nextval('public.drive_customers_sales_id_seq'::regclass);


--
-- TOC entry 3238 (class 2604 OID 16477)
-- Name: drive_locations_log drive_location_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drive_locations_log ALTER COLUMN drive_location_id SET DEFAULT nextval('public.drive_locations_log_drive_location_id_seq'::regclass);


--
-- TOC entry 3242 (class 2604 OID 16478)
-- Name: drives drive_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drives ALTER COLUMN drive_id SET DEFAULT nextval('public.drives_drive_id_seq'::regclass);


--
-- TOC entry 3249 (class 2604 OID 16479)
-- Name: outlets outlet_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.outlets ALTER COLUMN outlet_id SET DEFAULT nextval('public.outlets_outlet_id_seq'::regclass);


--
-- TOC entry 3252 (class 2604 OID 16480)
-- Name: payment_logs payment_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payment_logs ALTER COLUMN payment_id SET DEFAULT nextval('public.payment_logs_payment_id_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 16700)
-- Name: point_transactions transaction_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.point_transactions ALTER COLUMN transaction_id SET DEFAULT nextval('public.point_transactions_transaction_id_seq'::regclass);


--
-- TOC entry 3257 (class 2604 OID 16481)
-- Name: qr_codes qr_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.qr_codes ALTER COLUMN qr_id SET DEFAULT nextval('public.qr_codes_qr_id_seq'::regclass);


--
-- TOC entry 3261 (class 2604 OID 16482)
-- Name: routes route_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.routes ALTER COLUMN route_id SET DEFAULT nextval('public.routes_route_id_seq'::regclass);


--
-- TOC entry 3264 (class 2604 OID 16483)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- TOC entry 3455 (class 0 OID 16386)
-- Dependencies: 209
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.customers VALUES (47, 'Nikki bhai ', '{"lat":"0","lng":"0"}', '7976976525', 'Dukan', 6000.00, -3608, 'active', 1, '2025-08-02 12:42:36.121278', '2025-08-25 12:57:58.598554', NULL);
INSERT INTO public.customers VALUES (31, 'Firoz khan', '{"lat":"0","lng":"0"}', '7906621019', 'Dukan', 0.00, 0, 'active', 1, '2025-07-31 15:01:07.33079', '2025-07-31 15:01:07.33079', NULL);
INSERT INTO public.customers VALUES (64, 'Sajjad hussain', '{"lat":"0","lng":"0"}', '9680589819', 'Dukan', 5000.00, 0, 'active', 1, '2025-08-31 12:10:30.442085', '2025-08-31 12:10:30.442085', NULL);
INSERT INTO public.customers VALUES (34, 'Yusuf bhai ', '{"lat":"0","lng":"0"}', '9929997439', 'Dukan', 5000.00, -60, 'active', 1, '2025-08-01 13:45:08.617536', '2025-08-01 13:45:08.617536', NULL);
INSERT INTO public.customers VALUES (35, 'Monu bhai patel circle', '{"lat":"0","lng":"0"}', '8949408707', 'Dukan', 6000.00, -2670, 'active', 1, '2025-08-01 14:34:10.40508', '2025-08-01 14:34:10.40508', NULL);
INSERT INTO public.customers VALUES (38, 'Rehan pintu bhai ', '{"lat":"0","lng":"0"}', '9999999999', 'Dukan', 2000.00, -590, 'active', 1, '2025-08-01 18:32:24.012062', '2025-08-28 13:19:20.223338', NULL);
INSERT INTO public.customers VALUES (50, 'Rubina baji', '{"lat":"0","lng":"0"}', '9252444894', 'Dukan', 10000.00, -8030, 'active', 1, '2025-08-05 13:43:13.901489', '2025-08-05 13:43:13.901489', NULL);
INSERT INTO public.customers VALUES (43, 'Irshad hussain raza nagar ', '{"lat":"0","lng":"0"}', '9950289133', 'Dukan', 16000.00, -12550, 'active', 1, '2025-08-02 03:27:31.859256', '2025-08-02 03:27:31.859256', NULL);
INSERT INTO public.customers VALUES (56, 'Rauf bhai ', '{"lat":"0","lng":"0"}', '6350086265', 'Dukan', 0.00, 0, 'active', 1, '2025-08-10 11:51:23.666689', '2025-08-10 11:51:23.666689', NULL);
INSERT INTO public.customers VALUES (41, 'Tahira aapa', '{"lat":"0","lng":"0"}', '9829682143', 'Dukan', 21000.00, -14850, 'active', 1, '2025-08-02 03:22:18.68851', '2025-08-16 14:44:02.908337', NULL);
INSERT INTO public.customers VALUES (42, 'Mo hussain raja nagar gali', '{"lat":"0","lng":"0"}', '9829976487', 'Dukan', 10000.00, -5432, 'active', 1, '2025-08-02 03:25:00.228257', '2025-08-02 04:17:29.484', NULL);
INSERT INTO public.customers VALUES (46, 'Tasneem bohra', '{"lat":"24.581696","lng":"73.684884"}', '9696969696', 'Otc colony ambamata', 800.00, -2500, 'active', 1, '2025-08-02 04:20:08.452766', '2025-08-02 04:20:08.452766', NULL);
INSERT INTO public.customers VALUES (59, 'Irfan attari sa', '{"lat":"0","lng":"0"}', '9982964351', 'Dukan', 600.00, -330, 'active', 1, '2025-08-26 05:40:13.504431', '2025-08-26 05:40:13.504431', NULL);
INSERT INTO public.customers VALUES (33, 'Makbool khanam', '{"lat":"0","lng":"0"}', '8107136685', 'Dukan', 5000.00, -4220, 'active', 1, '2025-08-01 13:34:02.293202', '2025-08-02 04:13:26.457', NULL);
INSERT INTO public.customers VALUES (48, 'Samir bhai amool ', '{"lat":"0","lng":"0"}', '7976685156', 'Dukan', 10000.00, -6423, 'active', 1, '2025-08-02 12:47:26.215111', '2025-08-19 17:22:22.634633', NULL);
INSERT INTO public.customers VALUES (61, 'Test customer 12', '{"lat":"0","lng":"0"}', '8834567522', 'Home', 200.00, -100, 'active', 1, '2025-08-28 20:15:59.770733', '2025-08-28 20:15:59.770733', NULL);
INSERT INTO public.customers VALUES (32, 'Aslam bhai ', '{"lat":"0","lng":"0"}', '7073242099', 'Dukan', 1000.00, -60, 'active', 1, '2025-08-01 13:24:38.283721', '2025-08-27 09:29:16.918445', NULL);
INSERT INTO public.customers VALUES (53, 'Mahin', '{"lat":"0","lng":"0"}', '9024441700', 'Dukan', 5000.00, 0, 'active', 1, '2025-08-06 12:24:24.756949', '2025-08-06 12:24:24.756949', NULL);
INSERT INTO public.customers VALUES (62, 'Test Cust 45', '{"lat":"0","lng":"0"}', '8845454545', 'Home 1', 200.00, -100, 'active', 1, '2025-08-28 20:18:57.283117', '2025-08-28 20:18:57.283117', NULL);
INSERT INTO public.customers VALUES (36, 'Shokat bhai ', '{"lat":"0","lng":"0"}', '9785107184', 'Dukan', 5000.00, -3720, 'active', 1, '2025-08-01 15:30:26.817359', '2025-08-01 15:30:26.817359', NULL);
INSERT INTO public.customers VALUES (58, 'Wasim bhai gali no 6', '{"lat":"0","lng":"0"}', '9929665403', 'Dukan ', 1000.00, -690, 'active', 1, '2025-08-25 15:34:22.044684', '2025-08-31 15:39:47.165', NULL);
INSERT INTO public.customers VALUES (45, 'Firoz mansuri sahab ', '{"lat":"0","lng":"0"}', '9587453636', 'Dukan', 6000.00, -2370, 'active', 1, '2025-08-02 03:30:37.335233', '2025-08-08 04:27:23.256999', NULL);
INSERT INTO public.customers VALUES (65, 'Liyakat ali', '{"lat":"0","lng":"0"}', '9079242546', 'Dukan', 8000.00, -95, 'active', 1, '2025-09-01 15:03:14.149892', '2025-09-01 15:03:14.149892', NULL);
INSERT INTO public.customers VALUES (57, 'Wajid bhai ', '{"lat":"0","lng":"0"}', '9636481759', 'Dukan', 3000.00, -860, 'active', 1, '2025-08-14 13:58:08.982799', '2025-08-14 13:58:08.982799', NULL);
INSERT INTO public.customers VALUES (49, 'Kalu khan sa', '{"lat":"0","lng":"0"}', '9001180030', 'Dukan', 1900.00, -830, 'active', 1, '2025-08-02 13:26:34.878289', '2025-08-02 13:26:34.878289', NULL);
INSERT INTO public.customers VALUES (51, 'Wasim attari sa ', '{"lat":"0","lng":"0"}', '8890855786', 'Dukan', 20000.00, -9619, 'active', 1, '2025-08-05 16:37:37.675955', '2025-08-16 17:17:37.539796', NULL);
INSERT INTO public.customers VALUES (40, 'Munnan bhai auto ', '{"lat":"0","lng":"0"}', '9784732135', 'Dukan', 6000.00, -3923, 'active', 1, '2025-08-01 18:37:47.811812', '2025-08-01 18:37:47.811812', NULL);
INSERT INTO public.customers VALUES (60, 'Ahmed bhai dream event', '{"lat":"0","lng":"0"}', '8949479455', 'Dukan', 10000.00, -2385, 'active', 1, '2025-08-27 16:33:08.201657', '2025-08-27 16:33:08.201657', NULL);
INSERT INTO public.customers VALUES (37, 'Shahid sa patel circle ', '{"lat":"0","lng":"0"}', '6378553608', 'Dukan', 6000.00, -3725, 'active', 1, '2025-08-01 18:29:23.70657', '2025-08-05 15:48:21.786391', NULL);
INSERT INTO public.customers VALUES (39, 'Firoz khan kishanpole ', '{"lat":"0","lng":"0"}', '9111111111', 'Dukan', 8000.00, -2535, 'active', 1, '2025-08-01 18:36:07.65733', '2025-08-03 13:35:19.072244', NULL);
INSERT INTO public.customers VALUES (52, 'Firoz bhai govt press', '{"lat":"0","lng":"0"}', '9122222222', 'Dukan', 2000.00, -1920, 'active', 1, '2025-08-05 16:58:50.545517', '2025-08-05 16:58:50.545517', NULL);
INSERT INTO public.customers VALUES (30, 'Test', '{"lat":"24.5683875","lng":"73.6912878"}', '7615876735', 'National Dairy, Govt Press Road, near Fitness Plus Gym, Kishanpole, Jawahar Nagar, Khanjipeer, Udaipur, Rajasthan', 10000.00, -4875, 'active', 1, '2025-07-31 14:12:10.222986', '2025-07-31 14:12:10.222986', NULL);
INSERT INTO public.customers VALUES (54, 'Jahid bhai govt press ', '{"lat":"0","lng":"0"}', '9079195399', 'Dukan', 6000.00, -2310, 'active', 1, '2025-08-08 03:58:42.155016', '2025-08-08 03:58:42.155016', NULL);
INSERT INTO public.customers VALUES (44, 'Ram ji gym', '{"lat":"0","lng":"0"}', '9352351729', 'Dukan', 5000.00, -543, 'active', 1, '2025-08-02 03:29:03.360568', '2025-08-31 11:43:10.418757', NULL);
INSERT INTO public.customers VALUES (55, 'Kavish ji', '{"lat":"0","lng":"0"}', '6350137847', 'Dukan', 1500.00, -189, 'active', 1, '2025-08-10 06:30:36.89589', '2025-08-10 06:31:26.792127', NULL);
INSERT INTO public.customers VALUES (73, 'Aaaaaaa', '{"lat":"0","lng":"0"}', '9494949949', 'Bsbsb', 15000.00, -6055, 'active', 1, '2025-09-01 19:31:53.559605', '2025-09-01 19:39:41.052786', NULL);


--
-- TOC entry 3457 (class 0 OID 16397)
-- Dependencies: 211
-- Data for Name: delivery_guys; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.delivery_guys VALUES (4, 'Sonu', '9461180798', 'National dairy', '2025-06-19 13:28:10.904517', '2025-06-19 13:28:10.904517');
INSERT INTO public.delivery_guys VALUES (5, 'Me', '9999999999', 'Ma', '2025-06-25 07:46:40.227177', '2025-06-25 07:46:40.227177');
INSERT INTO public.delivery_guys VALUES (6, 'A35', '7732867338', 'Bhuwana', '2025-07-11 09:07:30.883096', '2025-07-11 09:07:30.883096');


--
-- TOC entry 3459 (class 0 OID 16405)
-- Dependencies: 213
-- Data for Name: drive_customers_sales; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3461 (class 0 OID 16412)
-- Dependencies: 215
-- Data for Name: drive_locations_log; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3463 (class 0 OID 16419)
-- Dependencies: 217
-- Data for Name: drives; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3465 (class 0 OID 16431)
-- Dependencies: 219
-- Data for Name: outlets; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.outlets VALUES (1, 'Main Outlet', 'National Dairy, Khanjipeer', '1234567890', '2025-05-09 01:42:23.272691', '2025-05-09 01:42:23.272691', '24.568407, 73.691330');


--
-- TOC entry 3467 (class 0 OID 16439)
-- Dependencies: 221
-- Data for Name: payment_logs; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.payment_logs VALUES (13, 32, '2025-08-01 00:00:00', 110.00, 'completed', 'cash', NULL, '2025-08-01 13:46:17.726881', '2025-08-01 13:46:17.726881');
INSERT INTO public.payment_logs VALUES (14, 39, '2025-08-03 00:00:00', 4780.00, 'completed', 'card', NULL, '2025-08-03 13:35:19.072244', '2025-08-03 13:35:19.072244');
INSERT INTO public.payment_logs VALUES (15, 37, '2025-08-05 00:00:00', 2500.00, 'completed', 'cash', NULL, '2025-08-05 15:48:21.786391', '2025-08-05 15:48:21.786391');
INSERT INTO public.payment_logs VALUES (16, 45, '2025-08-08 00:00:00', 1200.00, 'completed', 'cash', NULL, '2025-08-08 04:27:23.256999', '2025-08-08 04:27:23.256999');
INSERT INTO public.payment_logs VALUES (17, 55, '2025-08-10 00:00:00', 2000.00, 'completed', 'card', NULL, '2025-08-10 06:31:26.792127', '2025-08-10 06:31:26.792127');
INSERT INTO public.payment_logs VALUES (18, 47, '2025-08-14 00:00:00', 500.00, 'completed', 'cash', NULL, '2025-08-14 11:28:32.656242', '2025-08-14 11:28:32.656242');
INSERT INTO public.payment_logs VALUES (19, 41, '2025-08-16 00:00:00', 3975.00, 'completed', 'upi', NULL, '2025-08-16 14:44:02.908337', '2025-08-16 14:44:02.908337');
INSERT INTO public.payment_logs VALUES (20, 51, '2025-08-16 00:00:00', 6000.00, 'completed', 'upi', NULL, '2025-08-16 17:17:37.539796', '2025-08-16 17:17:37.539796');
INSERT INTO public.payment_logs VALUES (21, 48, '2025-08-19 00:00:00', 2000.00, 'completed', 'cash', NULL, '2025-08-19 17:22:22.634633', '2025-08-19 17:22:22.634633');
INSERT INTO public.payment_logs VALUES (22, 47, '2025-08-25 00:00:00', 500.00, 'completed', 'cash', NULL, '2025-08-25 12:57:58.598554', '2025-08-25 12:57:58.598554');
INSERT INTO public.payment_logs VALUES (23, 32, '2025-08-27 00:00:00', 390.00, 'completed', 'cash', NULL, '2025-08-27 09:29:16.918445', '2025-08-27 09:29:16.918445');
INSERT INTO public.payment_logs VALUES (24, 38, '2025-08-28 00:00:00', 490.00, 'completed', 'cash', NULL, '2025-08-28 13:19:20.223338', '2025-08-28 13:19:20.223338');
INSERT INTO public.payment_logs VALUES (25, 44, '2025-08-31 00:00:00', 1480.00, 'completed', 'cash', 'Mummy ko', '2025-08-31 11:43:10.418757', '2025-08-31 11:43:10.418757');
INSERT INTO public.payment_logs VALUES (27, 73, '2025-09-02 00:00:00', 5000.00, 'completed', 'cash', 'Hsbsb', '2025-09-01 19:32:23.951071', '2025-09-01 19:32:23.951071');
INSERT INTO public.payment_logs VALUES (28, 73, '2025-09-02 00:00:00', 100.00, 'completed', 'card', 'Hbv', '2025-09-01 19:39:41.052786', '2025-09-01 19:39:41.052786');


--
-- TOC entry 3477 (class 0 OID 16697)
-- Dependencies: 231
-- Data for Name: point_transactions; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.point_transactions VALUES (22, 30, 'debit', 50, -5800, -5850, NULL, 4, '2025-07-31 15:46:29.324855', NULL);
INSERT INTO public.point_transactions VALUES (24, 32, 'debit', 30, -80, -110, NULL, 4, '2025-08-01 13:24:58.065314', NULL);
INSERT INTO public.point_transactions VALUES (25, 34, 'debit', 60, 0, -60, NULL, 4, '2025-08-01 13:45:26.181814', NULL);
INSERT INTO public.point_transactions VALUES (27, 35, 'debit', 75, -2595, -2670, NULL, 4, '2025-08-01 14:34:31.767883', NULL);
INSERT INTO public.point_transactions VALUES (28, 36, 'debit', 120, 0, -120, NULL, 4, '2025-08-01 15:30:44.510506', NULL);
INSERT INTO public.point_transactions VALUES (38, 45, 'debit', 40, -2810, -2850, NULL, 4, '2025-08-02 04:15:19.80653', NULL);
INSERT INTO public.point_transactions VALUES (40, 33, 'debit', 150, 0, -150, NULL, 4, '2025-08-02 11:59:29.033666', NULL);
INSERT INTO public.point_transactions VALUES (41, 33, 'debit', 125, -150, -275, NULL, 4, '2025-08-02 12:00:11.342243', NULL);
INSERT INTO public.point_transactions VALUES (42, 45, 'debit', 30, -2850, -2880, NULL, 4, '2025-08-02 12:02:04.388374', NULL);
INSERT INTO public.point_transactions VALUES (43, 38, 'debit', 20, -480, -500, NULL, 4, '2025-08-02 12:02:44.608573', NULL);
INSERT INTO public.point_transactions VALUES (44, 39, 'debit', 50, -4780, -4830, NULL, 4, '2025-08-02 12:03:01.2008', NULL);
INSERT INTO public.point_transactions VALUES (45, 39, 'debit', 60, -4830, -4890, NULL, 4, '2025-08-02 12:03:14.460381', NULL);
INSERT INTO public.point_transactions VALUES (46, 40, 'debit', 40, -2320, -2360, NULL, 4, '2025-08-02 12:04:09.751708', NULL);
INSERT INTO public.point_transactions VALUES (47, 40, 'debit', 40, -2360, -2400, NULL, 4, '2025-08-02 12:04:28.285702', NULL);
INSERT INTO public.point_transactions VALUES (48, 41, 'debit', 125, -14750, -14875, NULL, 4, '2025-08-02 12:04:46.803143', NULL);
INSERT INTO public.point_transactions VALUES (50, 47, 'debit', 75, -3633, -3708, NULL, 4, '2025-08-02 12:42:55.332705', NULL);
INSERT INTO public.point_transactions VALUES (51, 47, 'debit', 50, -3708, -3758, NULL, 4, '2025-08-02 12:43:08.43045', NULL);
INSERT INTO public.point_transactions VALUES (53, 49, 'debit', 30, 0, -30, NULL, 4, '2025-08-02 13:27:25.350259', NULL);
INSERT INTO public.point_transactions VALUES (54, 49, 'debit', 30, -30, -60, NULL, 4, '2025-08-02 13:27:36.380744', NULL);
INSERT INTO public.point_transactions VALUES (55, 37, 'debit', 125, -2980, -3105, NULL, 4, '2025-08-02 15:48:56.481258', NULL);
INSERT INTO public.point_transactions VALUES (56, 37, 'debit', 125, -3105, -3230, NULL, 4, '2025-08-02 15:49:20.669404', NULL);
INSERT INTO public.point_transactions VALUES (57, 36, 'debit', 120, -120, -240, NULL, 4, '2025-08-02 16:22:54.754947', NULL);
INSERT INTO public.point_transactions VALUES (58, 40, 'debit', 40, -2400, -2440, NULL, 4, '2025-08-03 01:42:31.351274', NULL);
INSERT INTO public.point_transactions VALUES (59, 39, 'debit', 60, -4890, -4950, NULL, 4, '2025-08-03 01:56:41.330426', NULL);
INSERT INTO public.point_transactions VALUES (60, 47, 'debit', 50, -3758, -3808, NULL, 4, '2025-08-03 02:35:54.059174', NULL);
INSERT INTO public.point_transactions VALUES (61, 49, 'debit', 30, -60, -90, NULL, 4, '2025-08-03 04:26:02.564008', NULL);
INSERT INTO public.point_transactions VALUES (62, 33, 'debit', 170, -275, -445, NULL, 4, '2025-08-03 11:18:59.236516', NULL);
INSERT INTO public.point_transactions VALUES (63, 37, 'debit', 335, -3230, -3565, NULL, 4, '2025-08-03 13:06:19.715236', NULL);
INSERT INTO public.point_transactions VALUES (64, 32, 'debit', 30, 0, -30, NULL, 4, '2025-08-03 14:07:17.357199', NULL);
INSERT INTO public.point_transactions VALUES (65, 36, 'debit', 120, -240, -360, NULL, 4, '2025-08-03 15:00:13.373292', NULL);
INSERT INTO public.point_transactions VALUES (66, 45, 'debit', 30, -2880, -2910, NULL, 4, '2025-08-03 15:11:56.140673', NULL);
INSERT INTO public.point_transactions VALUES (67, 41, 'debit', 125, -14875, -15000, NULL, 4, '2025-08-03 16:30:18.457774', NULL);
INSERT INTO public.point_transactions VALUES (68, 49, 'debit', 30, -90, -120, NULL, 4, '2025-08-04 01:59:12.956177', NULL);
INSERT INTO public.point_transactions VALUES (69, 39, 'debit', 260, -170, -430, NULL, 4, '2025-08-04 02:06:14.230705', NULL);
INSERT INTO public.point_transactions VALUES (70, 44, 'debit', 55, -1480, -1535, NULL, 4, '2025-08-04 09:28:52.296388', NULL);
INSERT INTO public.point_transactions VALUES (71, 38, 'debit', 40, -500, -540, NULL, 4, '2025-08-04 12:58:17.54474', NULL);
INSERT INTO public.point_transactions VALUES (72, 33, 'debit', 125, -445, -570, NULL, 4, '2025-08-04 13:36:05.365749', NULL);
INSERT INTO public.point_transactions VALUES (73, 41, 'debit', 125, -15000, -15125, NULL, 4, '2025-08-04 14:45:37.061439', NULL);
INSERT INTO public.point_transactions VALUES (74, 36, 'debit', 120, -360, -480, NULL, 4, '2025-08-04 15:15:33.491658', NULL);
INSERT INTO public.point_transactions VALUES (75, 45, 'debit', 30, -2910, -2940, NULL, 4, '2025-08-04 16:07:39.25771', NULL);
INSERT INTO public.point_transactions VALUES (76, 40, 'debit', 40, -2440, -2480, NULL, 4, '2025-08-04 16:29:14.208133', NULL);
INSERT INTO public.point_transactions VALUES (77, 40, 'debit', 30, -2480, -2510, NULL, 4, '2025-08-04 16:29:20.968', NULL);
INSERT INTO public.point_transactions VALUES (78, 39, 'debit', 60, -430, -490, NULL, 4, '2025-08-05 02:06:23.677051', NULL);
INSERT INTO public.point_transactions VALUES (79, 49, 'debit', 30, -120, -150, NULL, 4, '2025-08-05 03:08:31.962022', NULL);
INSERT INTO public.point_transactions VALUES (80, 30, 'debit', 25, -5850, -5875, NULL, 6, '2025-08-05 07:50:28.602635', '2025-08-2');
INSERT INTO public.point_transactions VALUES (81, 38, 'debit', 20, -540, -560, NULL, 4, '2025-08-05 12:58:37.235485', NULL);
INSERT INTO public.point_transactions VALUES (82, 48, 'debit', 55, -6893, -6948, NULL, 4, '2025-08-05 12:59:43.059372', NULL);
INSERT INTO public.point_transactions VALUES (84, 50, 'debit', 90, -6050, -6140, NULL, 4, '2025-08-05 13:43:47.437897', NULL);
INSERT INTO public.point_transactions VALUES (85, 33, 'debit', 125, -570, -695, NULL, 4, '2025-08-05 13:59:08.23724', NULL);
INSERT INTO public.point_transactions VALUES (86, 41, 'debit', 125, -15125, -15250, NULL, 4, '2025-08-05 14:13:34.571976', NULL);
INSERT INTO public.point_transactions VALUES (87, 47, 'debit', 50, -3808, -3858, NULL, 4, '2025-08-05 14:38:59.190664', NULL);
INSERT INTO public.point_transactions VALUES (88, 32, 'debit', 30, -30, -60, NULL, 4, '2025-08-05 14:46:16.264583', NULL);
INSERT INTO public.point_transactions VALUES (89, 36, 'debit', 120, -480, -600, NULL, 4, '2025-08-05 15:35:07.655787', NULL);
INSERT INTO public.point_transactions VALUES (90, 37, 'debit', 90, -3565, -3655, NULL, 4, '2025-08-05 15:47:48.182546', NULL);
INSERT INTO public.point_transactions VALUES (92, 51, 'debit', 60, -13497, -13557, NULL, 4, '2025-08-05 16:38:10.425477', NULL);
INSERT INTO public.point_transactions VALUES (94, 40, 'debit', 40, -2510, -2550, NULL, 4, '2025-08-06 01:29:44.600509', NULL);
INSERT INTO public.point_transactions VALUES (95, 39, 'debit', 60, -490, -550, NULL, 4, '2025-08-06 01:49:50.324246', NULL);
INSERT INTO public.point_transactions VALUES (96, 49, 'debit', 30, -150, -180, NULL, 4, '2025-08-06 01:50:59.502401', NULL);
INSERT INTO public.point_transactions VALUES (97, 44, 'debit', 35, -1535, -1570, NULL, 4, '2025-08-06 03:02:35.031854', NULL);
INSERT INTO public.point_transactions VALUES (98, 50, 'debit', 100, -6140, -6240, NULL, 4, '2025-08-06 12:34:05.090652', NULL);
INSERT INTO public.point_transactions VALUES (99, 38, 'debit', 20, -560, -580, NULL, 4, '2025-08-06 12:56:07.292574', NULL);
INSERT INTO public.point_transactions VALUES (100, 48, 'debit', 60, -6948, -7008, NULL, 4, '2025-08-06 13:17:35.733105', NULL);
INSERT INTO public.point_transactions VALUES (101, 41, 'debit', 125, -15250, -15375, NULL, 4, '2025-08-06 14:38:23.83051', 'Invalid date');
INSERT INTO public.point_transactions VALUES (102, 33, 'debit', 150, -695, -845, NULL, 4, '2025-08-06 15:18:11.639289', 'Invalid date');
INSERT INTO public.point_transactions VALUES (103, 36, 'debit', 120, -600, -720, NULL, 4, '2025-08-06 15:23:51.992154', 'Invalid date');
INSERT INTO public.point_transactions VALUES (104, 51, 'debit', 60, -13557, -13617, NULL, 4, '2025-08-06 16:13:12.812543', 'Invalid date');
INSERT INTO public.point_transactions VALUES (105, 49, 'debit', 30, -180, -210, NULL, 4, '2025-08-07 01:41:41.899744', 'Invalid date');
INSERT INTO public.point_transactions VALUES (106, 39, 'debit', 60, -550, -610, NULL, 4, '2025-08-07 01:55:16.687792', 'Invalid date');
INSERT INTO public.point_transactions VALUES (107, 40, 'debit', 40, -2550, -2590, NULL, 4, '2025-08-07 02:16:36.228593', 'Invalid date');
INSERT INTO public.point_transactions VALUES (108, 38, 'debit', 20, -580, -600, NULL, 4, '2025-08-07 13:00:24.617306', 'Invalid date');
INSERT INTO public.point_transactions VALUES (109, 48, 'debit', 250, -7008, -7258, NULL, 4, '2025-08-07 13:13:23.738636', 'Invalid date');
INSERT INTO public.point_transactions VALUES (110, 33, 'debit', 125, -845, -970, NULL, 4, '2025-08-07 14:22:22.372233', 'Invalid date');
INSERT INTO public.point_transactions VALUES (111, 50, 'debit', 100, -6240, -6340, NULL, 4, '2025-08-07 14:30:57.672234', 'Invalid date');
INSERT INTO public.point_transactions VALUES (112, 32, 'debit', 30, -60, -90, NULL, 4, '2025-08-07 14:38:19.899389', 'Invalid date');
INSERT INTO public.point_transactions VALUES (113, 41, 'debit', 125, -15375, -15500, NULL, 4, '2025-08-07 15:01:33.970781', 'Invalid date');
INSERT INTO public.point_transactions VALUES (114, 36, 'debit', 120, -720, -840, NULL, 4, '2025-08-07 15:35:32.506626', 'Invalid date');
INSERT INTO public.point_transactions VALUES (115, 51, 'debit', 60, -13617, -13677, NULL, 4, '2025-08-07 16:24:33.116059', 'Invalid date');
INSERT INTO public.point_transactions VALUES (116, 39, 'debit', 60, -610, -670, NULL, 4, '2025-08-08 02:09:52.321069', 'Invalid date');
INSERT INTO public.point_transactions VALUES (117, 47, 'debit', 50, -3858, -3908, NULL, 4, '2025-08-08 03:04:02.012437', 'Invalid date');
INSERT INTO public.point_transactions VALUES (118, 49, 'debit', 30, -210, -240, NULL, 4, '2025-08-08 03:42:21.065425', 'Invalid date');
INSERT INTO public.point_transactions VALUES (119, 54, 'debit', 50, 0, -50, NULL, 4, '2025-08-08 03:59:51.817841', 'Invalid date');
INSERT INTO public.point_transactions VALUES (120, 54, 'debit', 50, -50, -100, NULL, 4, '2025-08-08 04:00:05.184252', 'Invalid date');
INSERT INTO public.point_transactions VALUES (121, 54, 'debit', 475, -100, -575, NULL, 4, '2025-08-08 04:00:28.072854', 'Invalid date');
INSERT INTO public.point_transactions VALUES (122, 54, 'debit', 50, -575, -625, NULL, 4, '2025-08-08 04:00:42.489812', 'Invalid date');
INSERT INTO public.point_transactions VALUES (91, 51, 'debit', -13497, 0, -13497, NULL, 4, '2025-08-05 16:37:39.707599', NULL);
INSERT INTO public.point_transactions VALUES (83, 50, 'debit', -6050, 0, -6050, NULL, 4, '2025-08-05 13:43:15.088853', NULL);
INSERT INTO public.point_transactions VALUES (52, 48, 'debit', -6893, 0, -6893, NULL, 4, '2025-08-02 12:47:27.323253', NULL);
INSERT INTO public.point_transactions VALUES (49, 47, 'debit', -3633, 0, -3633, NULL, 4, '2025-08-02 12:42:37.438561', NULL);
INSERT INTO public.point_transactions VALUES (39, 46, 'debit', -2500, 0, -2500, NULL, 4, '2025-08-02 04:20:09.551505', NULL);
INSERT INTO public.point_transactions VALUES (37, 45, 'debit', -2810, 0, -2810, NULL, 4, '2025-08-02 03:30:38.552262', NULL);
INSERT INTO public.point_transactions VALUES (36, 44, 'debit', -1480, 0, -1480, NULL, 4, '2025-08-02 03:29:04.645239', NULL);
INSERT INTO public.point_transactions VALUES (35, 43, 'debit', -12550, 0, -12550, NULL, 4, '2025-08-02 03:27:33.2174', NULL);
INSERT INTO public.point_transactions VALUES (34, 42, 'debit', -5432, 0, -5432, NULL, 4, '2025-08-02 03:25:01.752893', NULL);
INSERT INTO public.point_transactions VALUES (33, 41, 'debit', -14750, 0, -14750, NULL, 4, '2025-08-02 03:22:20.936216', NULL);
INSERT INTO public.point_transactions VALUES (32, 40, 'debit', -2320, 0, -2320, NULL, 4, '2025-08-01 18:37:49.398751', NULL);
INSERT INTO public.point_transactions VALUES (31, 39, 'debit', -4780, 0, -4780, NULL, 4, '2025-08-01 18:36:08.768084', NULL);
INSERT INTO public.point_transactions VALUES (29, 37, 'debit', -2980, 0, -2980, NULL, 4, '2025-08-01 18:29:25.020172', NULL);
INSERT INTO public.point_transactions VALUES (26, 35, 'debit', -2595, 0, -2595, NULL, 4, '2025-08-01 14:34:12.119546', NULL);
INSERT INTO public.point_transactions VALUES (23, 32, 'debit', -80, 0, -80, NULL, 4, '2025-08-01 13:24:41.059142', NULL);
INSERT INTO public.point_transactions VALUES (21, 30, 'debit', -5800, 0, -5800, NULL, 4, '2025-07-31 14:12:12.95123', NULL);
INSERT INTO public.point_transactions VALUES (123, 54, 'debit', 50, -625, -675, NULL, 4, '2025-08-08 04:00:55.027573', 'Invalid date');
INSERT INTO public.point_transactions VALUES (124, 54, 'debit', 50, -675, -725, NULL, 4, '2025-08-08 04:01:06.659862', 'Invalid date');
INSERT INTO public.point_transactions VALUES (125, 54, 'debit', 135, -725, -860, NULL, 4, '2025-08-08 04:03:05.021771', 'Invalid date');
INSERT INTO public.point_transactions VALUES (126, 54, 'debit', 50, -860, -910, NULL, 4, '2025-08-08 04:03:19.348047', 'Invalid date');
INSERT INTO public.point_transactions VALUES (127, 38, 'debit', 20, -600, -620, NULL, 4, '2025-08-08 11:40:08.489056', 'Invalid date');
INSERT INTO public.point_transactions VALUES (128, 48, 'debit', 50, -7258, -7308, NULL, 4, '2025-08-08 12:44:35.726448', 'Invalid date');
INSERT INTO public.point_transactions VALUES (129, 54, 'debit', 20, -910, -930, NULL, 4, '2025-08-08 13:57:39.687464', 'Invalid date');
INSERT INTO public.point_transactions VALUES (130, 50, 'debit', 100, -6340, -6440, NULL, 4, '2025-08-08 14:08:07.406737', 'Invalid date');
INSERT INTO public.point_transactions VALUES (131, 41, 'debit', 125, -15500, -15625, NULL, 4, '2025-08-08 14:36:15.807191', 'Invalid date');
INSERT INTO public.point_transactions VALUES (132, 37, 'debit', 540, -1155, -1695, NULL, 4, '2025-08-08 14:36:41.02821', 'Invalid date');
INSERT INTO public.point_transactions VALUES (133, 33, 'debit', 100, -970, -1070, NULL, 4, '2025-08-08 14:40:00.90653', 'Invalid date');
INSERT INTO public.point_transactions VALUES (134, 51, 'debit', 40, -13677, -13717, NULL, 4, '2025-08-08 15:07:59.477136', 'Invalid date');
INSERT INTO public.point_transactions VALUES (135, 36, 'debit', 120, -840, -960, NULL, 4, '2025-08-08 16:03:25.775278', 'Invalid date');
INSERT INTO public.point_transactions VALUES (136, 40, 'debit', 30, -2590, -2620, NULL, 4, '2025-08-09 01:33:48.494055', 'Invalid date');
INSERT INTO public.point_transactions VALUES (137, 47, 'debit', 70, -3908, -3978, NULL, 4, '2025-08-09 01:58:47.542577', 'Invalid date');
INSERT INTO public.point_transactions VALUES (138, 54, 'debit', 75, -930, -1005, NULL, 4, '2025-08-09 04:03:29.327373', 'Invalid date');
INSERT INTO public.point_transactions VALUES (139, 54, 'debit', 20, -1005, -1025, NULL, 4, '2025-08-09 04:04:46.367894', 'Invalid date');
INSERT INTO public.point_transactions VALUES (140, 49, 'debit', 30, -240, -270, NULL, 4, '2025-08-09 04:14:04.26512', 'Invalid date');
INSERT INTO public.point_transactions VALUES (141, 40, 'debit', 120, -2620, -2740, NULL, 4, '2025-08-09 06:05:28.476629', 'Invalid date');
INSERT INTO public.point_transactions VALUES (142, 44, 'debit', 30, -1570, -1600, NULL, 4, '2025-08-09 10:22:29.22886', 'Invalid date');
INSERT INTO public.point_transactions VALUES (143, 38, 'debit', 20, -620, -640, NULL, 4, '2025-08-09 12:44:10.291953', 'Invalid date');
INSERT INTO public.point_transactions VALUES (144, 33, 'debit', 125, -1070, -1195, NULL, 4, '2025-08-09 14:34:12.929301', 'Invalid date');
INSERT INTO public.point_transactions VALUES (145, 41, 'debit', 125, -15625, -15750, NULL, 4, '2025-08-09 15:08:39.421516', 'Invalid date');
INSERT INTO public.point_transactions VALUES (146, 32, 'debit', 30, -90, -120, NULL, 4, '2025-08-09 15:47:55.901875', 'Invalid date');
INSERT INTO public.point_transactions VALUES (147, 39, 'debit', 60, -670, -730, NULL, 4, '2025-08-09 16:05:05.131309', 'Invalid date');
INSERT INTO public.point_transactions VALUES (148, 51, 'debit', 60, -13717, -13777, NULL, 4, '2025-08-09 16:54:05.749382', 'Invalid date');
INSERT INTO public.point_transactions VALUES (149, 48, 'debit', 40, -7308, -7348, NULL, 4, '2025-08-09 16:59:35.824753', 'Invalid date');
INSERT INTO public.point_transactions VALUES (150, 54, 'debit', 50, -1025, -1075, NULL, 4, '2025-08-10 02:10:30.231788', 'Invalid date');
INSERT INTO public.point_transactions VALUES (151, 50, 'debit', 30, -6440, -6470, NULL, 4, '2025-08-10 03:26:03.918032', 'Invalid date');
INSERT INTO public.point_transactions VALUES (152, 44, 'debit', 135, -1600, -1735, NULL, 4, '2025-08-10 04:33:42.711832', 'Invalid date');
INSERT INTO public.point_transactions VALUES (153, 49, 'debit', 30, -270, -300, NULL, 4, '2025-08-10 04:57:20.783357', 'Invalid date');
INSERT INTO public.point_transactions VALUES (155, 55, 'debit', 14, 1000, 986, NULL, 4, '2025-08-10 06:32:56.789494', 'Invalid date');
INSERT INTO public.point_transactions VALUES (156, 52, 'debit', 80, -1360, -1440, NULL, 4, '2025-08-10 07:02:53.880905', 'Invalid date');
INSERT INTO public.point_transactions VALUES (157, 44, 'debit', 45, -1735, -1780, NULL, 4, '2025-08-10 09:06:44.043513', 'Invalid date');
INSERT INTO public.point_transactions VALUES (158, 40, 'debit', 30, -2740, -2770, NULL, 4, '2025-08-10 10:23:40.090966', 'Invalid date');
INSERT INTO public.point_transactions VALUES (159, 45, 'debit', 30, -1740, -1770, NULL, 4, '2025-08-10 10:46:33.821992', 'Invalid date');
INSERT INTO public.point_transactions VALUES (160, 45, 'debit', 10, -1770, -1780, NULL, 4, '2025-08-10 10:46:41.339116', 'Invalid date');
INSERT INTO public.point_transactions VALUES (161, 38, 'debit', 20, -640, -660, NULL, 4, '2025-08-10 11:50:21.141536', 'Invalid date');
INSERT INTO public.point_transactions VALUES (162, 33, 'debit', 125, -1195, -1320, NULL, 4, '2025-08-10 12:12:07.739031', 'Invalid date');
INSERT INTO public.point_transactions VALUES (163, 55, 'debit', 34, 986, 952, NULL, 4, '2025-08-10 12:12:29.54475', 'Invalid date');
INSERT INTO public.point_transactions VALUES (164, 48, 'debit', 70, -7348, -7418, NULL, 4, '2025-08-10 13:44:47.499701', 'Invalid date');
INSERT INTO public.point_transactions VALUES (165, 41, 'debit', 150, -15750, -15900, NULL, 4, '2025-08-10 14:47:03.009568', 'Invalid date');
INSERT INTO public.point_transactions VALUES (166, 51, 'debit', 80, -13777, -13857, NULL, 4, '2025-08-10 15:33:31.843959', 'Invalid date');
INSERT INTO public.point_transactions VALUES (167, 50, 'debit', 60, -6470, -6530, NULL, 4, '2025-08-10 16:06:05.687899', 'Invalid date');
INSERT INTO public.point_transactions VALUES (168, 45, 'debit', 50, -1780, -1830, NULL, 4, '2025-08-11 01:51:19.977755', 'Invalid date');
INSERT INTO public.point_transactions VALUES (169, 49, 'debit', 30, -300, -330, NULL, 4, '2025-08-11 01:54:22.188473', 'Invalid date');
INSERT INTO public.point_transactions VALUES (170, 54, 'debit', 50, -1075, -1125, NULL, 4, '2025-08-11 02:33:43.810974', 'Invalid date');
INSERT INTO public.point_transactions VALUES (171, 47, 'debit', 50, -3978, -4028, NULL, 4, '2025-08-11 03:02:19.895294', 'Invalid date');
INSERT INTO public.point_transactions VALUES (172, 55, 'debit', 50, 952, 902, NULL, 4, '2025-08-11 06:13:02.717468', 'Invalid date');
INSERT INTO public.point_transactions VALUES (173, 48, 'debit', 40, -7418, -7458, NULL, 4, '2025-08-11 12:48:21.953671', 'Invalid date');
INSERT INTO public.point_transactions VALUES (174, 38, 'debit', 20, -660, -680, NULL, 4, '2025-08-11 13:05:12.199483', 'Invalid date');
INSERT INTO public.point_transactions VALUES (175, 41, 'debit', 125, -15900, -16025, NULL, 4, '2025-08-11 13:36:47.146254', 'Invalid date');
INSERT INTO public.point_transactions VALUES (176, 33, 'debit', 125, -1320, -1445, NULL, 4, '2025-08-11 13:55:23.997407', 'Invalid date');
INSERT INTO public.point_transactions VALUES (177, 50, 'debit', 70, -6530, -6600, NULL, 4, '2025-08-11 14:13:32.939383', 'Invalid date');
INSERT INTO public.point_transactions VALUES (178, 32, 'debit', 30, -120, -150, NULL, 4, '2025-08-11 14:29:03.613506', 'Invalid date');
INSERT INTO public.point_transactions VALUES (179, 45, 'debit', 30, -1830, -1860, NULL, 4, '2025-08-11 14:30:12.331349', 'Invalid date');
INSERT INTO public.point_transactions VALUES (180, 51, 'debit', 60, -13857, -13917, NULL, 4, '2025-08-11 16:36:48.965749', 'Invalid date');
INSERT INTO public.point_transactions VALUES (181, 49, 'debit', 30, -330, -360, NULL, 4, '2025-08-12 01:55:10.058204', 'Invalid date');
INSERT INTO public.point_transactions VALUES (182, 39, 'debit', 60, -730, -790, NULL, 4, '2025-08-12 02:02:59.27197', 'Invalid date');
INSERT INTO public.point_transactions VALUES (183, 40, 'debit', 30, -2770, -2800, NULL, 4, '2025-08-12 02:19:27.767095', 'Invalid date');
INSERT INTO public.point_transactions VALUES (184, 54, 'debit', 50, -1125, -1175, NULL, 4, '2025-08-12 02:29:02.452016', 'Invalid date');
INSERT INTO public.point_transactions VALUES (185, 52, 'debit', 50, -1440, -1490, NULL, 4, '2025-08-12 04:16:14.338975', 'Invalid date');
INSERT INTO public.point_transactions VALUES (186, 50, 'debit', 110, -6600, -6710, NULL, 4, '2025-08-12 09:46:10.718616', 'Invalid date');
INSERT INTO public.point_transactions VALUES (187, 48, 'debit', 50, -7458, -7508, NULL, 4, '2025-08-12 12:45:53.191808', 'Invalid date');
INSERT INTO public.point_transactions VALUES (188, 38, 'debit', 20, -680, -700, NULL, 4, '2025-08-12 12:57:51.376472', 'Invalid date');
INSERT INTO public.point_transactions VALUES (189, 37, 'debit', 445, -1695, -2140, NULL, 4, '2025-08-12 13:01:08.985428', 'Invalid date');
INSERT INTO public.point_transactions VALUES (190, 33, 'debit', 125, -1445, -1570, NULL, 4, '2025-08-12 13:51:59.428919', 'Invalid date');
INSERT INTO public.point_transactions VALUES (191, 41, 'debit', 125, -16025, -16150, NULL, 4, '2025-08-12 14:32:26.49565', 'Invalid date');
INSERT INTO public.point_transactions VALUES (192, 45, 'debit', 3, -1860, -1863, NULL, 4, '2025-08-12 16:37:39.743487', 'Invalid date');
INSERT INTO public.point_transactions VALUES (193, 45, 'debit', 27, -1863, -1890, NULL, 4, '2025-08-12 16:38:01.591314', 'Invalid date');
INSERT INTO public.point_transactions VALUES (194, 51, 'debit', 60, -13917, -13977, NULL, 4, '2025-08-12 16:55:11.881641', 'Invalid date');
INSERT INTO public.point_transactions VALUES (195, 49, 'debit', 30, -360, -390, NULL, 4, '2025-08-13 01:56:32.722009', 'Invalid date');
INSERT INTO public.point_transactions VALUES (196, 40, 'debit', 30, -2800, -2830, NULL, 4, '2025-08-13 02:07:12.559917', 'Invalid date');
INSERT INTO public.point_transactions VALUES (197, 39, 'debit', 60, -790, -850, NULL, 4, '2025-08-13 02:07:20.225348', 'Invalid date');
INSERT INTO public.point_transactions VALUES (198, 54, 'debit', 50, -1175, -1225, NULL, 4, '2025-08-13 02:35:14.381499', 'Invalid date');
INSERT INTO public.point_transactions VALUES (199, 52, 'debit', 95, -1490, -1585, NULL, 4, '2025-08-13 06:48:23.290501', 'Invalid date');
INSERT INTO public.point_transactions VALUES (200, 48, 'debit', 40, -7508, -7548, NULL, 4, '2025-08-13 12:52:44.916021', 'Invalid date');
INSERT INTO public.point_transactions VALUES (201, 38, 'debit', 20, -700, -720, NULL, 4, '2025-08-13 13:00:21.944032', 'Invalid date');
INSERT INTO public.point_transactions VALUES (202, 32, 'debit', 30, -150, -180, NULL, 4, '2025-08-13 13:36:33.542565', 'Invalid date');
INSERT INTO public.point_transactions VALUES (203, 41, 'debit', 125, -16150, -16275, NULL, 4, '2025-08-13 14:14:16.634961', 'Invalid date');
INSERT INTO public.point_transactions VALUES (204, 33, 'debit', 125, -1570, -1695, NULL, 4, '2025-08-13 14:14:31.912127', 'Invalid date');
INSERT INTO public.point_transactions VALUES (205, 50, 'debit', 80, -6710, -6790, NULL, 4, '2025-08-13 14:24:21.590723', 'Invalid date');
INSERT INTO public.point_transactions VALUES (206, 51, 'debit', 60, -13977, -14037, NULL, 4, '2025-08-13 17:20:30.204502', 'Invalid date');
INSERT INTO public.point_transactions VALUES (207, 47, 'debit', 50, -4028, -4078, NULL, 4, '2025-08-14 01:52:43.041803', 'Invalid date');
INSERT INTO public.point_transactions VALUES (208, 49, 'debit', 30, -390, -420, NULL, 4, '2025-08-14 02:25:32.609999', 'Invalid date');
INSERT INTO public.point_transactions VALUES (209, 39, 'debit', 60, -850, -910, NULL, 4, '2025-08-14 02:26:02.90714', 'Invalid date');
INSERT INTO public.point_transactions VALUES (210, 45, 'debit', 40, -1890, -1930, NULL, 4, '2025-08-14 02:28:39.408592', 'Invalid date');
INSERT INTO public.point_transactions VALUES (154, 55, 'debit', -1000, 0, -1000, NULL, 4, '2025-08-10 06:30:38.463841', NULL);
INSERT INTO public.point_transactions VALUES (211, 54, 'debit', 50, -1225, -1275, NULL, 4, '2025-08-14 02:34:02.363901', 'Invalid date');
INSERT INTO public.point_transactions VALUES (212, 48, 'debit', 40, -7548, -7588, NULL, 4, '2025-08-14 12:46:11.27657', 'Invalid date');
INSERT INTO public.point_transactions VALUES (213, 38, 'debit', 20, -720, -740, NULL, 4, '2025-08-14 13:14:21.941906', 'Invalid date');
INSERT INTO public.point_transactions VALUES (214, 57, 'debit', 30, 0, -30, NULL, 4, '2025-08-14 13:58:40.273805', 'Invalid date');
INSERT INTO public.point_transactions VALUES (215, 41, 'debit', 125, -16275, -16400, NULL, 4, '2025-08-14 14:34:57.696959', 'Invalid date');
INSERT INTO public.point_transactions VALUES (216, 33, 'debit', 125, -1695, -1820, NULL, 4, '2025-08-14 15:06:32.322777', 'Invalid date');
INSERT INTO public.point_transactions VALUES (217, 39, 'debit', 120, -910, -1030, NULL, 4, '2025-08-15 02:17:23.52692', 'Invalid date');
INSERT INTO public.point_transactions VALUES (218, 40, 'debit', 30, -2830, -2860, NULL, 4, '2025-08-15 02:29:27.470108', 'Invalid date');
INSERT INTO public.point_transactions VALUES (219, 47, 'debit', 50, -3578, -3628, NULL, 4, '2025-08-15 03:46:51.962193', 'Invalid date');
INSERT INTO public.point_transactions VALUES (220, 51, 'debit', 447, -14037, -14484, NULL, 4, '2025-08-15 04:43:13.488451', 'Invalid date');
INSERT INTO public.point_transactions VALUES (221, 55, 'debit', 50, 902, 852, NULL, 4, '2025-08-15 05:27:59.418363', 'Invalid date');
INSERT INTO public.point_transactions VALUES (222, 38, 'debit', 20, -740, -760, NULL, 4, '2025-08-15 12:57:22.214025', 'Invalid date');
INSERT INTO public.point_transactions VALUES (223, 33, 'debit', 125, -1820, -1945, NULL, 4, '2025-08-15 13:35:25.841575', 'Invalid date');
INSERT INTO public.point_transactions VALUES (224, 41, 'debit', 125, -16400, -16525, NULL, 4, '2025-08-15 14:13:14.708001', 'Invalid date');
INSERT INTO public.point_transactions VALUES (225, 37, 'debit', 170, -2140, -2310, NULL, 4, '2025-08-15 15:38:03.197233', 'Invalid date');
INSERT INTO public.point_transactions VALUES (226, 32, 'debit', 30, -180, -210, NULL, 4, '2025-08-15 15:43:09.06114', 'Invalid date');
INSERT INTO public.point_transactions VALUES (227, 39, 'debit', 60, -1030, -1090, NULL, 4, '2025-08-16 01:56:18.010154', 'Invalid date');
INSERT INTO public.point_transactions VALUES (228, 50, 'debit', 80, -6790, -6870, NULL, 4, '2025-08-16 02:36:00.7595', 'Invalid date');
INSERT INTO public.point_transactions VALUES (229, 39, 'debit', 280, -1090, -1370, NULL, 4, '2025-08-16 02:54:57.462727', 'Invalid date');
INSERT INTO public.point_transactions VALUES (230, 40, 'debit', 30, -2860, -2890, NULL, 4, '2025-08-16 03:07:42.715121', 'Invalid date');
INSERT INTO public.point_transactions VALUES (231, 49, 'debit', 30, -420, -450, NULL, 4, '2025-08-16 03:55:24.679939', 'Invalid date');
INSERT INTO public.point_transactions VALUES (232, 55, 'debit', 75, 852, 777, NULL, 4, '2025-08-16 08:12:38.941423', 'Invalid date');
INSERT INTO public.point_transactions VALUES (233, 48, 'debit', 40, -7588, -7628, NULL, 4, '2025-08-16 12:45:49.103899', 'Invalid date');
INSERT INTO public.point_transactions VALUES (234, 38, 'debit', 20, -760, -780, NULL, 4, '2025-08-16 13:01:35.21835', 'Invalid date');
INSERT INTO public.point_transactions VALUES (235, 33, 'debit', 75, -1945, -2020, NULL, 4, '2025-08-16 13:37:03.034831', 'Invalid date');
INSERT INTO public.point_transactions VALUES (236, 41, 'debit', 125, -16525, -16650, NULL, 4, '2025-08-16 14:43:29.197804', 'Invalid date');
INSERT INTO public.point_transactions VALUES (237, 57, 'debit', 30, -30, -60, NULL, 4, '2025-08-16 16:12:23.752645', 'Invalid date');
INSERT INTO public.point_transactions VALUES (238, 51, 'debit', 60, -8484, -8544, NULL, 4, '2025-08-16 17:17:58.156912', 'Invalid date');
INSERT INTO public.point_transactions VALUES (239, 39, 'debit', 50, -1370, -1420, NULL, 4, '2025-08-17 02:30:00.72701', 'Invalid date');
INSERT INTO public.point_transactions VALUES (240, 50, 'debit', 80, -6870, -6950, NULL, 4, '2025-08-17 03:12:46.145207', 'Invalid date');
INSERT INTO public.point_transactions VALUES (241, 49, 'debit', 30, -450, -480, NULL, 4, '2025-08-17 03:56:35.540769', 'Invalid date');
INSERT INTO public.point_transactions VALUES (242, 55, 'debit', 50, 777, 727, NULL, 4, '2025-08-17 08:49:16.359023', 'Invalid date');
INSERT INTO public.point_transactions VALUES (243, 37, 'debit', 190, -2310, -2500, NULL, 4, '2025-08-17 10:34:38.837131', 'Invalid date');
INSERT INTO public.point_transactions VALUES (244, 38, 'debit', 20, -780, -800, NULL, 4, '2025-08-17 12:11:51.895922', 'Invalid date');
INSERT INTO public.point_transactions VALUES (245, 57, 'debit', 60, -60, -120, NULL, 4, '2025-08-17 12:30:11.489667', 'Invalid date');
INSERT INTO public.point_transactions VALUES (246, 33, 'debit', 125, -2020, -2145, NULL, 4, '2025-08-17 13:41:51.076794', 'Invalid date');
INSERT INTO public.point_transactions VALUES (247, 50, 'debit', 70, -6950, -7020, NULL, 4, '2025-08-17 14:16:22.519585', 'Invalid date');
INSERT INTO public.point_transactions VALUES (248, 54, 'debit', 75, -1275, -1350, NULL, 4, '2025-08-17 15:07:10.861937', NULL);
INSERT INTO public.point_transactions VALUES (249, 32, 'debit', 30, -210, -240, NULL, 4, '2025-08-17 15:11:19.472074', 'Invalid date');
INSERT INTO public.point_transactions VALUES (250, 41, 'debit', 125, -12675, -12800, NULL, 4, '2025-08-17 15:23:12.757266', 'Invalid date');
INSERT INTO public.point_transactions VALUES (251, 51, 'debit', 60, -8544, -8604, NULL, 4, '2025-08-17 16:15:36.70449', 'Invalid date');
INSERT INTO public.point_transactions VALUES (252, 45, 'debit', 30, -1930, -1960, NULL, 4, '2025-08-17 17:17:49.319339', 'Invalid date');
INSERT INTO public.point_transactions VALUES (253, 49, 'debit', 30, -480, -510, NULL, 4, '2025-08-18 01:58:42.794583', 'Invalid date');
INSERT INTO public.point_transactions VALUES (254, 39, 'debit', 60, -1420, -1480, NULL, 4, '2025-08-18 02:11:58.959378', 'Invalid date');
INSERT INTO public.point_transactions VALUES (255, 40, 'debit', 30, -2890, -2920, NULL, 4, '2025-08-18 02:30:01.194597', 'Invalid date');
INSERT INTO public.point_transactions VALUES (256, 55, 'debit', 50, 727, 677, NULL, 4, '2025-08-18 09:55:47.376567', 'Invalid date');
INSERT INTO public.point_transactions VALUES (257, 48, 'debit', 40, -7628, -7668, NULL, 4, '2025-08-18 12:44:12.666012', 'Invalid date');
INSERT INTO public.point_transactions VALUES (258, 38, 'debit', 20, -800, -820, NULL, 4, '2025-08-18 13:01:24.113686', 'Invalid date');
INSERT INTO public.point_transactions VALUES (259, 33, 'debit', 100, -2145, -2245, NULL, 4, '2025-08-18 13:23:51.987733', 'Invalid date');
INSERT INTO public.point_transactions VALUES (260, 50, 'debit', 70, -7020, -7090, NULL, 4, '2025-08-18 14:31:52.97623', 'Invalid date');
INSERT INTO public.point_transactions VALUES (261, 41, 'debit', 125, -12800, -12925, NULL, 4, '2025-08-18 14:31:59.891007', 'Invalid date');
INSERT INTO public.point_transactions VALUES (262, 51, 'debit', 60, -8604, -8664, NULL, 4, '2025-08-18 14:38:18.342814', 'Invalid date');
INSERT INTO public.point_transactions VALUES (263, 44, 'debit', 100, -1780, -1880, NULL, 4, '2025-08-18 14:44:03.265427', 'Invalid date');
INSERT INTO public.point_transactions VALUES (264, 57, 'debit', 30, -120, -150, NULL, 4, '2025-08-18 15:52:04.895798', 'Invalid date');
INSERT INTO public.point_transactions VALUES (265, 40, 'debit', 30, -2920, -2950, NULL, 4, '2025-08-19 01:44:51.643597', 'Invalid date');
INSERT INTO public.point_transactions VALUES (266, 39, 'debit', 85, -1480, -1565, NULL, 4, '2025-08-19 02:18:23.975105', 'Invalid date');
INSERT INTO public.point_transactions VALUES (267, 54, 'debit', 75, -1350, -1425, NULL, 4, '2025-08-19 02:30:57.909574', 'Invalid date');
INSERT INTO public.point_transactions VALUES (268, 47, 'debit', 70, -3628, -3698, NULL, 4, '2025-08-19 02:57:51.551214', 'Invalid date');
INSERT INTO public.point_transactions VALUES (269, 50, 'debit', 60, -7090, -7150, NULL, 4, '2025-08-19 09:51:34.58808', 'Invalid date');
INSERT INTO public.point_transactions VALUES (270, 57, 'debit', 50, -150, -200, NULL, 4, '2025-08-19 12:57:39.916626', 'Invalid date');
INSERT INTO public.point_transactions VALUES (271, 38, 'debit', 20, -820, -840, NULL, 4, '2025-08-19 13:16:16.690798', 'Invalid date');
INSERT INTO public.point_transactions VALUES (272, 54, 'debit', 150, -1425, -1575, NULL, 4, '2025-08-19 13:45:54.793972', 'Invalid date');
INSERT INTO public.point_transactions VALUES (273, 33, 'debit', 150, -2245, -2395, NULL, 4, '2025-08-19 13:49:34.305512', 'Invalid date');
INSERT INTO public.point_transactions VALUES (274, 41, 'debit', 125, -12925, -13050, NULL, 4, '2025-08-19 14:25:51.679629', 'Invalid date');
INSERT INTO public.point_transactions VALUES (275, 32, 'debit', 30, -240, -270, NULL, 4, '2025-08-19 14:30:17.740369', 'Invalid date');
INSERT INTO public.point_transactions VALUES (276, 45, 'debit', 50, -1960, -2010, NULL, 4, '2025-08-19 14:49:03.806991', 'Invalid date');
INSERT INTO public.point_transactions VALUES (277, 48, 'debit', 80, -7668, -7748, NULL, 4, '2025-08-19 17:22:05.194072', 'Invalid date');
INSERT INTO public.point_transactions VALUES (278, 51, 'debit', 60, -8664, -8724, NULL, 4, '2025-08-20 01:30:37.040165', 'Invalid date');
INSERT INTO public.point_transactions VALUES (279, 47, 'debit', 50, -3698, -3748, NULL, 4, '2025-08-20 01:50:42.713881', 'Invalid date');
INSERT INTO public.point_transactions VALUES (280, 49, 'debit', 30, -510, -540, NULL, 4, '2025-08-20 02:03:30.532242', 'Invalid date');
INSERT INTO public.point_transactions VALUES (281, 49, 'debit', 30, -540, -570, NULL, 4, '2025-08-20 02:03:53.857942', 'Invalid date');
INSERT INTO public.point_transactions VALUES (282, 39, 'debit', 60, -1565, -1625, NULL, 4, '2025-08-20 02:32:50.520498', 'Invalid date');
INSERT INTO public.point_transactions VALUES (283, 54, 'debit', 50, -1575, -1625, NULL, 4, '2025-08-20 02:34:44.901609', 'Invalid date');
INSERT INTO public.point_transactions VALUES (284, 40, 'debit', 30, -2950, -2980, NULL, 4, '2025-08-20 02:42:07.93585', 'Invalid date');
INSERT INTO public.point_transactions VALUES (285, 50, 'debit', 100, -7150, -7250, NULL, 4, '2025-08-20 12:38:58.903749', 'Invalid date');
INSERT INTO public.point_transactions VALUES (286, 57, 'debit', 30, -200, -230, NULL, 4, '2025-08-20 12:47:15.330818', 'Invalid date');
INSERT INTO public.point_transactions VALUES (287, 37, 'debit', 335, -2500, -2835, NULL, 4, '2025-08-20 12:53:48.729261', 'Invalid date');
INSERT INTO public.point_transactions VALUES (288, 33, 'debit', 125, -2395, -2520, NULL, 4, '2025-08-20 14:11:03.518124', 'Invalid date');
INSERT INTO public.point_transactions VALUES (289, 48, 'debit', 40, -5748, -5788, NULL, 4, '2025-08-20 14:46:33.716095', 'Invalid date');
INSERT INTO public.point_transactions VALUES (290, 48, 'debit', 15, -5788, -5803, NULL, 4, '2025-08-20 14:46:39.156201', 'Invalid date');
INSERT INTO public.point_transactions VALUES (291, 57, 'debit', 30, -230, -260, NULL, 4, '2025-08-20 15:48:15.079131', 'Invalid date');
INSERT INTO public.point_transactions VALUES (292, 41, 'debit', 125, -13050, -13175, NULL, 4, '2025-08-20 15:57:50.006357', 'Invalid date');
INSERT INTO public.point_transactions VALUES (293, 51, 'debit', 60, -8724, -8784, NULL, 4, '2025-08-20 16:18:48.702174', 'Invalid date');
INSERT INTO public.point_transactions VALUES (294, 49, 'debit', 30, -570, -600, NULL, 4, '2025-08-21 01:59:59.368478', 'Invalid date');
INSERT INTO public.point_transactions VALUES (295, 39, 'debit', 60, -1625, -1685, NULL, 4, '2025-08-21 02:23:24.975345', 'Invalid date');
INSERT INTO public.point_transactions VALUES (296, 40, 'debit', 30, -2980, -3010, NULL, 4, '2025-08-21 02:32:54.471776', 'Invalid date');
INSERT INTO public.point_transactions VALUES (297, 54, 'debit', 50, -1625, -1675, NULL, 4, '2025-08-21 02:33:04.651361', 'Invalid date');
INSERT INTO public.point_transactions VALUES (298, 55, 'debit', 46, 677, 631, NULL, 4, '2025-08-21 07:22:28.996877', 'Invalid date');
INSERT INTO public.point_transactions VALUES (299, 50, 'debit', 160, -7250, -7410, NULL, 4, '2025-08-21 12:50:32.09495', 'Invalid date');
INSERT INTO public.point_transactions VALUES (300, 38, 'debit', 20, -840, -860, NULL, 4, '2025-08-21 13:04:03.971505', 'Invalid date');
INSERT INTO public.point_transactions VALUES (301, 57, 'debit', 30, -260, -290, NULL, 4, '2025-08-21 13:35:15.506206', 'Invalid date');
INSERT INTO public.point_transactions VALUES (302, 41, 'debit', 125, -13175, -13300, NULL, 4, '2025-08-21 14:09:36.715575', 'Invalid date');
INSERT INTO public.point_transactions VALUES (303, 33, 'debit', 100, -2520, -2620, NULL, 4, '2025-08-21 14:24:48.266619', 'Invalid date');
INSERT INTO public.point_transactions VALUES (304, 48, 'debit', 60, -5803, -5863, NULL, 4, '2025-08-21 14:28:12.229167', 'Invalid date');
INSERT INTO public.point_transactions VALUES (305, 32, 'debit', 30, -270, -300, NULL, 4, '2025-08-21 16:01:02.352587', 'Invalid date');
INSERT INTO public.point_transactions VALUES (306, 57, 'debit', 60, -290, -350, NULL, 4, '2025-08-21 16:04:32.314578', 'Invalid date');
INSERT INTO public.point_transactions VALUES (307, 51, 'debit', 60, -8784, -8844, NULL, 4, '2025-08-21 17:15:24.247296', 'Invalid date');
INSERT INTO public.point_transactions VALUES (308, 54, 'debit', 50, -1675, -1725, NULL, 4, '2025-08-22 02:35:33.296807', 'Invalid date');
INSERT INTO public.point_transactions VALUES (309, 39, 'debit', 60, -1685, -1745, NULL, 4, '2025-08-22 02:38:10.891378', 'Invalid date');
INSERT INTO public.point_transactions VALUES (310, 40, 'debit', 30, -3010, -3040, NULL, 4, '2025-08-22 02:42:36.890652', 'Invalid date');
INSERT INTO public.point_transactions VALUES (311, 47, 'debit', 50, -3748, -3798, NULL, 4, '2025-08-22 03:29:25.389267', 'Invalid date');
INSERT INTO public.point_transactions VALUES (312, 49, 'debit', 30, -600, -630, NULL, 4, '2025-08-22 03:33:57.558322', 'Invalid date');
INSERT INTO public.point_transactions VALUES (313, 55, 'debit', 100, 631, 531, NULL, 4, '2025-08-22 07:42:34.330174', 'Invalid date');
INSERT INTO public.point_transactions VALUES (314, 38, 'debit', 20, -860, -880, NULL, 4, '2025-08-22 12:58:51.123327', 'Invalid date');
INSERT INTO public.point_transactions VALUES (315, 48, 'debit', 30, -5863, -5893, NULL, 4, '2025-08-22 13:18:57.767029', 'Invalid date');
INSERT INTO public.point_transactions VALUES (316, 33, 'debit', 100, -2620, -2720, NULL, 4, '2025-08-22 13:40:14.99391', 'Invalid date');
INSERT INTO public.point_transactions VALUES (317, 50, 'debit', 70, -7410, -7480, NULL, 4, '2025-08-22 13:45:06.19015', 'Invalid date');
INSERT INTO public.point_transactions VALUES (318, 41, 'debit', 125, -13300, -13425, NULL, 4, '2025-08-22 14:13:48.576525', 'Invalid date');
INSERT INTO public.point_transactions VALUES (319, 57, 'debit', 30, -350, -380, NULL, 4, '2025-08-22 15:48:03.132641', 'Invalid date');
INSERT INTO public.point_transactions VALUES (320, 51, 'debit', 60, -8844, -8904, NULL, 4, '2025-08-23 01:38:48.402702', 'Invalid date');
INSERT INTO public.point_transactions VALUES (321, 40, 'debit', 40, -3040, -3080, NULL, 4, '2025-08-23 01:52:10.458141', 'Invalid date');
INSERT INTO public.point_transactions VALUES (322, 39, 'debit', 60, -1745, -1805, NULL, 4, '2025-08-23 03:27:41.124437', 'Invalid date');
INSERT INTO public.point_transactions VALUES (323, 54, 'debit', 50, -1725, -1775, NULL, 4, '2025-08-23 03:30:19.482442', 'Invalid date');
INSERT INTO public.point_transactions VALUES (324, 49, 'debit', 30, -630, -660, NULL, 4, '2025-08-23 04:54:25.258684', 'Invalid date');
INSERT INTO public.point_transactions VALUES (325, 38, 'debit', 20, -880, -900, NULL, 4, '2025-08-23 10:19:52.438152', 'Invalid date');
INSERT INTO public.point_transactions VALUES (326, 48, 'debit', 70, -5893, -5963, NULL, 4, '2025-08-23 12:57:23.826724', 'Invalid date');
INSERT INTO public.point_transactions VALUES (327, 57, 'debit', 30, -380, -410, NULL, 4, '2025-08-23 13:58:05.636478', 'Invalid date');
INSERT INTO public.point_transactions VALUES (328, 41, 'debit', 225, -13425, -13650, NULL, 4, '2025-08-23 14:18:37.734277', 'Invalid date');
INSERT INTO public.point_transactions VALUES (329, 32, 'debit', 30, -300, -330, NULL, 4, '2025-08-23 14:19:21.254992', 'Invalid date');
INSERT INTO public.point_transactions VALUES (330, 51, 'debit', 80, -8904, -8984, NULL, 4, '2025-08-23 14:28:58.628185', 'Invalid date');
INSERT INTO public.point_transactions VALUES (331, 33, 'debit', 125, -2720, -2845, NULL, 4, '2025-08-23 15:57:36.097643', 'Invalid date');
INSERT INTO public.point_transactions VALUES (332, 45, 'debit', 80, -2010, -2090, NULL, 4, '2025-08-23 16:49:15.0863', 'Invalid date');
INSERT INTO public.point_transactions VALUES (333, 40, 'debit', 30, -3080, -3110, NULL, 4, '2025-08-24 02:03:22.830582', 'Invalid date');
INSERT INTO public.point_transactions VALUES (334, 39, 'debit', 60, -1805, -1865, NULL, 4, '2025-08-24 02:08:19.607526', 'Invalid date');
INSERT INTO public.point_transactions VALUES (335, 47, 'debit', 60, -3798, -3858, NULL, 4, '2025-08-24 02:16:42.31069', 'Invalid date');
INSERT INTO public.point_transactions VALUES (336, 50, 'debit', 60, -7480, -7540, NULL, 4, '2025-08-24 04:21:25.048772', 'Invalid date');
INSERT INTO public.point_transactions VALUES (337, 49, 'debit', 50, -660, -710, NULL, 4, '2025-08-24 04:35:51.564675', 'Invalid date');
INSERT INTO public.point_transactions VALUES (338, 55, 'debit', 50, 531, 481, NULL, 4, '2025-08-24 07:05:36.803701', 'Invalid date');
INSERT INTO public.point_transactions VALUES (339, 38, 'debit', 20, -900, -920, NULL, 4, '2025-08-24 12:14:13.316828', 'Invalid date');
INSERT INTO public.point_transactions VALUES (340, 37, 'debit', 335, -2835, -3170, NULL, 4, '2025-08-24 13:19:27.413089', 'Invalid date');
INSERT INTO public.point_transactions VALUES (341, 33, 'debit', 125, -2845, -2970, NULL, 4, '2025-08-24 13:29:57.559308', 'Invalid date');
INSERT INTO public.point_transactions VALUES (342, 32, 'debit', 30, -330, -360, NULL, 4, '2025-08-24 14:46:00.252284', 'Invalid date');
INSERT INTO public.point_transactions VALUES (343, 45, 'debit', 30, -2090, -2120, NULL, 4, '2025-08-24 15:08:06.156639', 'Invalid date');
INSERT INTO public.point_transactions VALUES (344, 41, 'debit', 125, -13650, -13775, NULL, 4, '2025-08-24 15:10:49.780677', 'Invalid date');
INSERT INTO public.point_transactions VALUES (345, 57, 'debit', 30, -410, -440, NULL, 4, '2025-08-24 15:52:45.463711', 'Invalid date');
INSERT INTO public.point_transactions VALUES (346, 50, 'debit', 60, -7540, -7600, NULL, 4, '2025-08-24 16:15:07.433029', 'Invalid date');
INSERT INTO public.point_transactions VALUES (347, 54, 'debit', 75, -1775, -1850, NULL, 4, '2025-08-25 02:44:36.018611', 'Invalid date');
INSERT INTO public.point_transactions VALUES (348, 39, 'debit', 60, -1865, -1925, NULL, 4, '2025-08-25 03:01:37.064685', 'Invalid date');
INSERT INTO public.point_transactions VALUES (349, 40, 'debit', 30, -3110, -3140, NULL, 4, '2025-08-25 03:29:08.019575', 'Invalid date');
INSERT INTO public.point_transactions VALUES (350, 49, 'debit', 30, -710, -740, NULL, 4, '2025-08-25 04:58:11.455607', 'Invalid date');
INSERT INTO public.point_transactions VALUES (351, 51, 'debit', 100, -8984, -9084, NULL, 4, '2025-08-25 05:51:57.561091', 'Invalid date');
INSERT INTO public.point_transactions VALUES (352, 55, 'debit', 50, 481, 431, NULL, 4, '2025-08-25 08:16:27.225634', 'Invalid date');
INSERT INTO public.point_transactions VALUES (353, 57, 'debit', 80, -440, -520, NULL, 4, '2025-08-25 12:19:04.054097', 'Invalid date');
INSERT INTO public.point_transactions VALUES (354, 47, 'debit', 200, -3858, -4058, NULL, 4, '2025-08-25 12:57:33.94988', 'Invalid date');
INSERT INTO public.point_transactions VALUES (355, 38, 'debit', 20, -920, -940, NULL, 4, '2025-08-25 13:01:23.241374', 'Invalid date');
INSERT INTO public.point_transactions VALUES (356, 50, 'debit', 90, -7600, -7690, NULL, 4, '2025-08-25 13:42:02.032096', 'Invalid date');
INSERT INTO public.point_transactions VALUES (357, 33, 'debit', 125, -2970, -3095, NULL, 4, '2025-08-25 13:49:09.052778', 'Invalid date');
INSERT INTO public.point_transactions VALUES (358, 48, 'debit', 50, -5963, -6013, NULL, 4, '2025-08-25 14:12:17.484787', 'Invalid date');
INSERT INTO public.point_transactions VALUES (359, 48, 'debit', 10, -6013, -6023, NULL, 4, '2025-08-25 14:12:38.317971', 'Invalid date');
INSERT INTO public.point_transactions VALUES (361, 58, 'debit', 120, -120, -240, NULL, 4, '2025-08-25 15:34:50.01101', 'Invalid date');
INSERT INTO public.point_transactions VALUES (362, 45, 'debit', 40, -2120, -2160, NULL, 4, '2025-08-25 16:01:13.542759', 'Invalid date');
INSERT INTO public.point_transactions VALUES (363, 41, 'debit', 125, -13775, -13900, NULL, 4, '2025-08-25 16:07:06.141232', 'Invalid date');
INSERT INTO public.point_transactions VALUES (364, 51, 'debit', 80, -9084, -9164, NULL, 4, '2025-08-25 17:33:18.611037', 'Invalid date');
INSERT INTO public.point_transactions VALUES (365, 47, 'debit', 50, -3558, -3608, NULL, 4, '2025-08-26 01:43:06.18656', 'Invalid date');
INSERT INTO public.point_transactions VALUES (366, 39, 'debit', 60, -1925, -1985, NULL, 4, '2025-08-26 02:11:07.769687', 'Invalid date');
INSERT INTO public.point_transactions VALUES (367, 54, 'debit', 75, -1850, -1925, NULL, 4, '2025-08-26 02:38:29.799422', 'Invalid date');
INSERT INTO public.point_transactions VALUES (368, 59, 'debit', 30, 0, -30, NULL, 4, '2025-08-26 05:40:48.98318', 'Invalid date');
INSERT INTO public.point_transactions VALUES (369, 55, 'debit', 50, 431, 381, NULL, 4, '2025-08-26 08:38:25.773247', 'Invalid date');
INSERT INTO public.point_transactions VALUES (370, 38, 'debit', 20, -940, -960, NULL, 4, '2025-08-26 12:56:49.084187', 'Invalid date');
INSERT INTO public.point_transactions VALUES (371, 48, 'debit', 60, -6023, -6083, NULL, 4, '2025-08-26 13:03:39.957307', 'Invalid date');
INSERT INTO public.point_transactions VALUES (372, 57, 'debit', 30, -520, -550, NULL, 4, '2025-08-26 13:11:56.269022', 'Invalid date');
INSERT INTO public.point_transactions VALUES (373, 50, 'debit', 90, -7690, -7780, NULL, 4, '2025-08-26 14:03:47.768052', 'Invalid date');
INSERT INTO public.point_transactions VALUES (374, 33, 'debit', 150, -3095, -3245, NULL, 4, '2025-08-26 14:26:01.748814', 'Invalid date');
INSERT INTO public.point_transactions VALUES (375, 41, 'debit', 125, -13900, -14025, NULL, 4, '2025-08-26 14:33:23.762474', 'Invalid date');
INSERT INTO public.point_transactions VALUES (376, 52, 'debit', 95, -1585, -1680, NULL, 4, '2025-08-26 14:40:39.647832', 'Invalid date');
INSERT INTO public.point_transactions VALUES (377, 45, 'debit', 30, -2160, -2190, NULL, 4, '2025-08-26 16:07:17.031277', 'Invalid date');
INSERT INTO public.point_transactions VALUES (378, 51, 'debit', 60, -9164, -9224, NULL, 4, '2025-08-26 16:45:19.16658', 'Invalid date');
INSERT INTO public.point_transactions VALUES (379, 40, 'debit', 38, -3140, -3178, NULL, 4, '2025-08-27 02:09:56.549385', 'Invalid date');
INSERT INTO public.point_transactions VALUES (380, 39, 'debit', 60, -1985, -2045, NULL, 4, '2025-08-27 02:20:13.98935', 'Invalid date');
INSERT INTO public.point_transactions VALUES (381, 54, 'debit', 95, -1925, -2020, NULL, 4, '2025-08-27 02:37:35.253152', 'Invalid date');
INSERT INTO public.point_transactions VALUES (382, 37, 'debit', 190, -3170, -3360, NULL, 4, '2025-08-27 02:42:56.546597', 'Invalid date');
INSERT INTO public.point_transactions VALUES (383, 32, 'debit', 30, -360, -390, NULL, 4, '2025-08-27 09:28:43.120709', 'Invalid date');
INSERT INTO public.point_transactions VALUES (384, 55, 'debit', 60, 381, 321, NULL, 4, '2025-08-27 12:38:48.375492', 'Invalid date');
INSERT INTO public.point_transactions VALUES (385, 38, 'debit', 20, -960, -980, NULL, 4, '2025-08-27 12:44:23.142236', 'Invalid date');
INSERT INTO public.point_transactions VALUES (386, 48, 'debit', 60, -6083, -6143, NULL, 4, '2025-08-27 13:10:58.383256', 'Invalid date');
INSERT INTO public.point_transactions VALUES (360, 58, 'debit', -120, 0, -120, NULL, 4, '2025-08-25 15:34:23.290866', NULL);
INSERT INTO public.point_transactions VALUES (387, 41, 'debit', 125, -14025, -14150, NULL, 4, '2025-08-27 13:24:43.816621', 'Invalid date');
INSERT INTO public.point_transactions VALUES (388, 52, 'debit', 130, -1680, -1810, NULL, 4, '2025-08-27 13:58:41.146897', 'Invalid date');
INSERT INTO public.point_transactions VALUES (389, 33, 'debit', 125, -3245, -3370, NULL, 4, '2025-08-27 14:11:06.945418', 'Invalid date');
INSERT INTO public.point_transactions VALUES (390, 45, 'debit', 40, -2190, -2230, NULL, 4, '2025-08-27 15:30:31.647415', 'Invalid date');
INSERT INTO public.point_transactions VALUES (391, 59, 'debit', 50, -30, -80, NULL, 4, '2025-08-27 15:56:28.611759', 'Invalid date');
INSERT INTO public.point_transactions VALUES (392, 51, 'debit', 70, -9224, -9294, NULL, 4, '2025-08-27 16:20:52.147178', 'Invalid date');
INSERT INTO public.point_transactions VALUES (393, 60, 'debit', 405, 0, -405, NULL, 4, '2025-08-27 16:33:53.314654', 'Invalid date');
INSERT INTO public.point_transactions VALUES (394, 57, 'debit', 100, -550, -650, NULL, 4, '2025-08-27 16:43:55.051083', 'Invalid date');
INSERT INTO public.point_transactions VALUES (395, 39, 'debit', 260, -2045, -2305, NULL, 4, '2025-08-28 02:07:10.960294', 'Invalid date');
INSERT INTO public.point_transactions VALUES (396, 54, 'debit', 50, -2020, -2070, NULL, 4, '2025-08-28 02:32:49.175072', 'Invalid date');
INSERT INTO public.point_transactions VALUES (397, 40, 'debit', 30, -3178, -3208, NULL, 4, '2025-08-28 02:39:05.400892', 'Invalid date');
INSERT INTO public.point_transactions VALUES (398, 49, 'debit', 30, -740, -770, NULL, 4, '2025-08-28 04:02:42.13372', 'Invalid date');
INSERT INTO public.point_transactions VALUES (399, 52, 'debit', 60, -1810, -1870, NULL, 4, '2025-08-28 04:15:47.360136', 'Invalid date');
INSERT INTO public.point_transactions VALUES (400, 55, 'debit', 60, 321, 261, NULL, 4, '2025-08-28 07:42:19.5627', 'Invalid date');
INSERT INTO public.point_transactions VALUES (401, 40, 'debit', 475, -3208, -3683, NULL, 4, '2025-08-28 10:56:54.313312', 'Invalid date');
INSERT INTO public.point_transactions VALUES (402, 48, 'debit', 50, -6143, -6193, NULL, 4, '2025-08-28 12:46:34.716347', 'Invalid date');
INSERT INTO public.point_transactions VALUES (403, 41, 'debit', 125, -14150, -14275, NULL, 4, '2025-08-28 13:18:47.648074', 'Invalid date');
INSERT INTO public.point_transactions VALUES (404, 38, 'debit', 20, -980, -1000, NULL, 4, '2025-08-28 13:18:57.129053', 'Invalid date');
INSERT INTO public.point_transactions VALUES (405, 33, 'debit', 350, -3370, -3720, NULL, 4, '2025-08-28 14:01:47.206828', 'Invalid date');
INSERT INTO public.point_transactions VALUES (406, 45, 'debit', 40, -2230, -2270, NULL, 4, '2025-08-28 14:56:07.034778', 'Invalid date');
INSERT INTO public.point_transactions VALUES (407, 59, 'debit', 120, -80, -200, NULL, 4, '2025-08-28 15:07:37.51056', 'Invalid date');
INSERT INTO public.point_transactions VALUES (408, 51, 'debit', 95, -9294, -9389, NULL, 4, '2025-08-28 15:09:34.610039', 'Invalid date');
INSERT INTO public.point_transactions VALUES (409, 57, 'debit', 90, -650, -740, NULL, 4, '2025-08-28 16:09:24.119425', 'Invalid date');
INSERT INTO public.point_transactions VALUES (410, 60, 'debit', 300, -405, -705, NULL, 4, '2025-08-28 16:50:24.871064', 'Invalid date');
INSERT INTO public.point_transactions VALUES (411, 50, 'debit', 90, -7780, -7870, NULL, 4, '2025-08-28 17:12:14.143267', 'Invalid date');
INSERT INTO public.point_transactions VALUES (415, 40, 'debit', 30, -3683, -3713, NULL, 4, '2025-08-29 01:52:28.759594', 'Invalid date');
INSERT INTO public.point_transactions VALUES (416, 49, 'debit', 30, -770, -800, NULL, 4, '2025-08-29 02:14:02.626361', 'Invalid date');
INSERT INTO public.point_transactions VALUES (417, 39, 'debit', 60, -2305, -2365, NULL, 4, '2025-08-29 02:27:29.602841', 'Invalid date');
INSERT INTO public.point_transactions VALUES (418, 44, 'debit', 100, -1880, -1980, NULL, 4, '2025-08-29 07:30:31.702114', 'Invalid date');
INSERT INTO public.point_transactions VALUES (419, 55, 'debit', 50, 261, 211, NULL, 4, '2025-08-29 08:18:21.670345', 'Invalid date');
INSERT INTO public.point_transactions VALUES (420, 57, 'debit', 30, -740, -770, NULL, 4, '2025-08-29 12:18:08.830179', 'Invalid date');
INSERT INTO public.point_transactions VALUES (421, 41, 'debit', 125, -14275, -14400, NULL, 4, '2025-08-29 12:57:29.711858', 'Invalid date');
INSERT INTO public.point_transactions VALUES (422, 38, 'debit', 2, -510, -512, NULL, 4, '2025-08-29 13:01:02.12787', 'Invalid date');
INSERT INTO public.point_transactions VALUES (423, 38, 'debit', 18, -512, -530, NULL, 4, '2025-08-29 13:02:50.450423', 'Invalid date');
INSERT INTO public.point_transactions VALUES (424, 32, 'debit', 30, 0, -30, NULL, 4, '2025-08-29 13:37:32.904262', 'Invalid date');
INSERT INTO public.point_transactions VALUES (425, 33, 'debit', 125, -3720, -3845, NULL, 4, '2025-08-29 13:53:09.414817', 'Invalid date');
INSERT INTO public.point_transactions VALUES (426, 50, 'debit', 100, -7870, -7970, NULL, 4, '2025-08-29 16:15:18.257736', 'Invalid date');
INSERT INTO public.point_transactions VALUES (427, 48, 'debit', 50, -6193, -6243, NULL, 4, '2025-08-29 17:04:40.953168', 'Invalid date');
INSERT INTO public.point_transactions VALUES (428, 60, 'debit', 360, -705, -1065, NULL, 4, '2025-08-29 17:25:13.111434', 'Invalid date');
INSERT INTO public.point_transactions VALUES (429, 40, 'debit', 30, -3713, -3743, NULL, 4, '2025-08-30 01:39:55.075301', 'Invalid date');
INSERT INTO public.point_transactions VALUES (430, 39, 'debit', 60, -2365, -2425, NULL, 4, '2025-08-30 02:33:03.208104', 'Invalid date');
INSERT INTO public.point_transactions VALUES (431, 51, 'debit', 100, -9389, -9489, NULL, 4, '2025-08-30 04:52:10.143089', 'Invalid date');
INSERT INTO public.point_transactions VALUES (432, 54, 'debit', 75, -2070, -2145, NULL, 4, '2025-08-30 04:55:54.170752', 'Invalid date');
INSERT INTO public.point_transactions VALUES (433, 40, 'debit', 120, -3743, -3863, NULL, 4, '2025-08-30 09:36:44.773131', 'Invalid date');
INSERT INTO public.point_transactions VALUES (434, 55, 'debit', 300, 211, -89, NULL, 4, '2025-08-30 12:08:20.360982', 'Invalid date');
INSERT INTO public.point_transactions VALUES (435, 55, 'debit', 100, -89, -189, NULL, 4, '2025-08-30 12:08:47.544043', 'Invalid date');
INSERT INTO public.point_transactions VALUES (436, 48, 'debit', 70, -6243, -6313, NULL, 4, '2025-08-30 12:45:43.061531', 'Invalid date');
INSERT INTO public.point_transactions VALUES (437, 38, 'debit', 20, -530, -550, NULL, 4, '2025-08-30 13:01:58.435052', 'Invalid date');
INSERT INTO public.point_transactions VALUES (438, 59, 'debit', 80, -200, -280, NULL, 4, '2025-08-30 14:49:26.977217', 'Invalid date');
INSERT INTO public.point_transactions VALUES (439, 41, 'debit', 150, -14400, -14550, NULL, 4, '2025-08-30 15:51:44.555465', 'Invalid date');
INSERT INTO public.point_transactions VALUES (440, 60, 'debit', 300, -1065, -1365, NULL, 4, '2025-08-30 16:08:14.696763', 'Invalid date');
INSERT INTO public.point_transactions VALUES (441, 33, 'debit', 125, -3845, -3970, NULL, 4, '2025-08-30 16:10:05.057002', 'Invalid date');
INSERT INTO public.point_transactions VALUES (442, 60, 'debit', 60, -1365, -1425, NULL, 4, '2025-08-30 16:14:02.201204', 'Invalid date');
INSERT INTO public.point_transactions VALUES (443, 58, 'debit', 220, -240, -460, NULL, 4, '2025-08-30 17:24:45.120834', 'Invalid date');
INSERT INTO public.point_transactions VALUES (444, 58, 'debit', 80, -460, -540, NULL, 4, '2025-08-30 17:25:25.214367', 'Invalid date');
INSERT INTO public.point_transactions VALUES (445, 58, 'debit', 20, -540, -560, NULL, 4, '2025-08-30 17:26:45.380421', 'Invalid date');
INSERT INTO public.point_transactions VALUES (446, 40, 'debit', 30, -3863, -3893, NULL, 4, '2025-08-31 01:43:06.449573', 'Invalid date');
INSERT INTO public.point_transactions VALUES (447, 39, 'debit', 60, -2425, -2485, NULL, 4, '2025-08-31 02:13:47.865401', 'Invalid date');
INSERT INTO public.point_transactions VALUES (448, 54, 'debit', 90, -2145, -2235, NULL, 4, '2025-08-31 03:48:01.344973', 'Invalid date');
INSERT INTO public.point_transactions VALUES (449, 49, 'debit', 30, -800, -830, NULL, 4, '2025-08-31 03:51:29.57478', 'Invalid date');
INSERT INTO public.point_transactions VALUES (450, 51, 'debit', 60, -9489, -9549, NULL, 4, '2025-08-31 04:35:02.752996', 'Invalid date');
INSERT INTO public.point_transactions VALUES (451, 51, 'debit', 10, -9549, -9559, NULL, 4, '2025-08-31 04:35:52.969878', 'Invalid date');
INSERT INTO public.point_transactions VALUES (452, 45, 'debit', 50, -2270, -2320, NULL, 4, '2025-08-31 06:13:25.631027', 'Invalid date');
INSERT INTO public.point_transactions VALUES (453, 44, 'debit', 43, -1980, -2023, NULL, 4, '2025-08-31 11:41:46.448576', 'Invalid date');
INSERT INTO public.point_transactions VALUES (454, 38, 'debit', 20, -550, -570, NULL, 4, '2025-08-31 11:54:43.732652', 'Invalid date');
INSERT INTO public.point_transactions VALUES (455, 50, 'debit', 60, -7970, -8030, NULL, 4, '2025-08-31 12:45:20.201171', 'Invalid date');
INSERT INTO public.point_transactions VALUES (456, 41, 'debit', 150, -14550, -14700, NULL, 4, '2025-08-31 12:46:00.097827', 'Invalid date');
INSERT INTO public.point_transactions VALUES (457, 48, 'debit', 55, -6313, -6368, NULL, 4, '2025-08-31 12:57:08.445643', 'Invalid date');
INSERT INTO public.point_transactions VALUES (458, 33, 'debit', 125, -3970, -4095, NULL, 4, '2025-08-31 14:20:14.782745', 'Invalid date');
INSERT INTO public.point_transactions VALUES (459, 57, 'debit', 60, -770, -830, NULL, 4, '2025-08-31 14:56:24.683422', NULL);
INSERT INTO public.point_transactions VALUES (460, 60, 'debit', 300, -1425, -1725, NULL, 4, '2025-08-31 15:27:41.491372', 'Invalid date');
INSERT INTO public.point_transactions VALUES (461, 60, 'debit', 120, -1725, -1845, NULL, 4, '2025-08-31 15:28:37.077177', 'Invalid date');
INSERT INTO public.point_transactions VALUES (462, 58, 'debit', 130, -560, -690, NULL, 4, '2025-08-31 15:39:50.993685', 'Invalid date');
INSERT INTO public.point_transactions VALUES (463, 45, 'debit', 50, -2320, -2370, NULL, 4, '2025-08-31 15:56:51.742674', 'Invalid date');
INSERT INTO public.point_transactions VALUES (464, 60, 'debit', 60, -1845, -1905, NULL, 4, '2025-08-31 16:25:26.871039', 'Invalid date');
INSERT INTO public.point_transactions VALUES (465, 51, 'debit', 60, -9559, -9619, NULL, 4, '2025-08-31 17:15:09.125987', 'Invalid date');
INSERT INTO public.point_transactions VALUES (466, 40, 'debit', 30, -3893, -3923, NULL, 4, '2025-09-01 01:42:17.403575', 'Invalid date');
INSERT INTO public.point_transactions VALUES (467, 37, 'debit', 365, -3360, -3725, NULL, 4, '2025-09-01 02:32:04.956312', 'Invalid date');
INSERT INTO public.point_transactions VALUES (468, 39, 'debit', 50, -2485, -2535, NULL, 4, '2025-09-01 02:32:16.323887', 'Invalid date');
INSERT INTO public.point_transactions VALUES (469, 54, 'debit', 75, -2235, -2310, NULL, 4, '2025-09-01 02:42:33.794078', 'Invalid date');
INSERT INTO public.point_transactions VALUES (470, 41, 'debit', 125, -14700, -14825, NULL, 4, '2025-09-01 12:52:21.9087', 'Invalid date');
INSERT INTO public.point_transactions VALUES (471, 38, 'debit', 20, -570, -590, NULL, 4, '2025-09-01 12:52:32.068707', 'Invalid date');
INSERT INTO public.point_transactions VALUES (472, 41, 'debit', 25, -14825, -14850, NULL, 4, '2025-09-01 12:58:48.19433', 'Invalid date');
INSERT INTO public.point_transactions VALUES (473, 59, 'debit', 50, -280, -330, NULL, 4, '2025-09-01 13:37:22.730079', 'Invalid date');
INSERT INTO public.point_transactions VALUES (474, 33, 'debit', 12, -4095, -4107, NULL, 4, '2025-09-01 13:54:10.261253', 'Invalid date');
INSERT INTO public.point_transactions VALUES (475, 33, 'debit', 113, -4107, -4220, NULL, 4, '2025-09-01 13:54:33.934799', 'Invalid date');
INSERT INTO public.point_transactions VALUES (476, 48, 'debit', 55, -6368, -6423, NULL, 4, '2025-09-01 14:34:19.157553', 'Invalid date');
INSERT INTO public.point_transactions VALUES (412, 61, 'debit', -100, 0, -100, NULL, 4, '2025-08-28 20:16:00.859338', NULL);
INSERT INTO public.point_transactions VALUES (477, 32, 'debit', 30, -30, -60, NULL, 4, '2025-09-01 14:34:25.17781', 'Invalid date');
INSERT INTO public.point_transactions VALUES (478, 36, 'debit', 2760, -960, -3720, NULL, 4, '2025-09-01 14:59:52.534027', 'Invalid date');
INSERT INTO public.point_transactions VALUES (479, 65, 'debit', 95, 0, -95, NULL, 4, '2025-09-01 15:03:47.887765', 'Invalid date');
INSERT INTO public.point_transactions VALUES (480, 57, 'debit', 30, -830, -860, NULL, 4, '2025-09-01 15:44:48.626631', 'Invalid date');
INSERT INTO public.point_transactions VALUES (481, 60, 'debit', 480, -1905, -2385, NULL, 4, '2025-09-01 16:23:41.229324', 'Invalid date');
INSERT INTO public.point_transactions VALUES (482, 52, 'debit', 50, -1870, -1920, NULL, 4, '2025-09-01 17:25:58.458039', 'Invalid date');
INSERT INTO public.point_transactions VALUES (413, 62, 'debit', -100, 0, -100, NULL, 4, '2025-08-28 20:18:58.378193', NULL);
INSERT INTO public.point_transactions VALUES (93, 52, 'debit', -1360, 0, -1360, NULL, 4, '2025-08-05 16:58:53.286533', NULL);
INSERT INTO public.point_transactions VALUES (30, 38, 'debit', -480, 0, -480, NULL, 4, '2025-08-01 18:32:25.124176', NULL);
INSERT INTO public.point_transactions VALUES (488, 73, 'debit', 11000, 0, -11000, NULL, 4, '2025-09-01 19:31:53.848138', NULL);
INSERT INTO public.point_transactions VALUES (489, 73, 'debit', 155, -11000, -11155, NULL, 4, '2025-09-01 19:32:06.321757', 'Invalid date');


--
-- TOC entry 3469 (class 0 OID 16449)
-- Dependencies: 223
-- Data for Name: qr_codes; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.qr_codes VALUES (284, 'd6d81549-7c30-4f02-9d2d-861a190a5358', NULL, 'inactive', NULL, '2025-07-30 13:25:09.500864', '2025-07-30 13:25:09.500864');
INSERT INTO public.qr_codes VALUES (285, '7fd40dd9-57bd-4eec-9dc6-2043f5186676', NULL, 'inactive', NULL, '2025-07-31 13:13:24.313176', '2025-07-31 13:13:24.313176');
INSERT INTO public.qr_codes VALUES (286, '68a45b38-3d04-44ec-b86d-f46f81dcf1ce', NULL, 'inactive', NULL, '2025-07-31 13:13:24.34247', '2025-07-31 13:13:24.34247');
INSERT INTO public.qr_codes VALUES (287, '2d374b3e-0cb7-4b40-bbac-1c01b2f4dbbd', NULL, 'inactive', NULL, '2025-07-31 13:13:24.34662', '2025-07-31 13:13:24.34662');
INSERT INTO public.qr_codes VALUES (288, '0e7d8d4c-e735-4d24-9177-b9303b8d470f', NULL, 'inactive', NULL, '2025-07-31 13:13:24.348663', '2025-07-31 13:13:24.348663');
INSERT INTO public.qr_codes VALUES (289, 'b488f005-f42d-4841-a7fe-1bf3822cd22c', NULL, 'inactive', NULL, '2025-07-31 13:13:24.350176', '2025-07-31 13:13:24.350176');
INSERT INTO public.qr_codes VALUES (290, '4bbd35ba-2b48-49cc-adc2-4beae0aecbfe', NULL, 'inactive', NULL, '2025-07-31 13:13:24.352458', '2025-07-31 13:13:24.352458');
INSERT INTO public.qr_codes VALUES (291, '627382b9-3ce2-4cca-b5d9-4717b1b43115', NULL, 'inactive', NULL, '2025-07-31 13:13:24.354004', '2025-07-31 13:13:24.354004');
INSERT INTO public.qr_codes VALUES (292, '305d8a70-aff4-45e7-8da3-66d1e808c26f', NULL, 'inactive', NULL, '2025-07-31 13:13:24.355495', '2025-07-31 13:13:24.355495');
INSERT INTO public.qr_codes VALUES (293, '7258de49-d599-45ef-98b6-c347cf99cb5b', NULL, 'inactive', NULL, '2025-07-31 13:13:24.356858', '2025-07-31 13:13:24.356858');
INSERT INTO public.qr_codes VALUES (294, '7013ec4e-2cbc-40e8-a683-e1cc41578cd8', NULL, 'inactive', NULL, '2025-07-31 13:13:24.358259', '2025-07-31 13:13:24.358259');
INSERT INTO public.qr_codes VALUES (295, 'e15efab8-522c-4843-93ed-f212c6a57d86', NULL, 'inactive', NULL, '2025-07-31 13:13:24.359639', '2025-07-31 13:13:24.359639');
INSERT INTO public.qr_codes VALUES (296, 'a2b3ad98-5412-47da-8049-8709de355563', NULL, 'inactive', NULL, '2025-07-31 13:13:24.361654', '2025-07-31 13:13:24.361654');
INSERT INTO public.qr_codes VALUES (297, 'cab2b539-e7b9-4933-8862-4238dbd5631c', NULL, 'inactive', NULL, '2025-07-31 13:13:24.363153', '2025-07-31 13:13:24.363153');
INSERT INTO public.qr_codes VALUES (298, 'e4b1caf4-77e6-40a6-bbc8-08d6bb3f6a42', NULL, 'inactive', NULL, '2025-07-31 13:13:24.364618', '2025-07-31 13:13:24.364618');
INSERT INTO public.qr_codes VALUES (299, '54f368c4-5446-4bbb-99d6-025b66a6c706', NULL, 'inactive', NULL, '2025-07-31 13:13:24.366153', '2025-07-31 13:13:24.366153');
INSERT INTO public.qr_codes VALUES (300, 'afeaae66-2629-4406-a507-ce93789b4293', NULL, 'inactive', NULL, '2025-07-31 13:13:24.367659', '2025-07-31 13:13:24.367659');
INSERT INTO public.qr_codes VALUES (301, '226c7ce6-8123-458e-98d8-facd798e1375', NULL, 'inactive', NULL, '2025-07-31 13:13:24.369094', '2025-07-31 13:13:24.369094');
INSERT INTO public.qr_codes VALUES (302, 'f0c8fbf5-1e90-4e01-8da4-c4957440783f', NULL, 'inactive', NULL, '2025-07-31 13:13:24.370453', '2025-07-31 13:13:24.370453');
INSERT INTO public.qr_codes VALUES (303, 'cc8c67d0-87c8-4492-955b-05cb27430b2c', NULL, 'inactive', NULL, '2025-07-31 13:13:24.372506', '2025-07-31 13:13:24.372506');
INSERT INTO public.qr_codes VALUES (304, 'a33c067f-dcdc-4fc6-b2a1-a3695d20689c', NULL, 'inactive', NULL, '2025-07-31 13:13:24.373902', '2025-07-31 13:13:24.373902');
INSERT INTO public.qr_codes VALUES (305, '94ece1c5-cef3-4419-bc5b-0cf4b209e533', NULL, 'inactive', NULL, '2025-07-31 13:13:24.375294', '2025-07-31 13:13:24.375294');
INSERT INTO public.qr_codes VALUES (306, '1350055c-8884-456f-b207-3084a1a265e0', NULL, 'inactive', NULL, '2025-07-31 13:13:24.376641', '2025-07-31 13:13:24.376641');
INSERT INTO public.qr_codes VALUES (307, '9de9153e-818e-4e37-a7ab-5027e19699e5', NULL, 'inactive', NULL, '2025-07-31 13:13:24.378082', '2025-07-31 13:13:24.378082');
INSERT INTO public.qr_codes VALUES (308, '43af88a3-b2ea-4e1d-8020-96f6a57b61f4', NULL, 'inactive', NULL, '2025-07-31 13:13:24.379386', '2025-07-31 13:13:24.379386');
INSERT INTO public.qr_codes VALUES (309, 'dffc881d-9051-4cc2-8c21-49018a7c466f', NULL, 'inactive', NULL, '2025-07-31 13:13:24.380752', '2025-07-31 13:13:24.380752');
INSERT INTO public.qr_codes VALUES (310, 'aac7e005-f8d0-483a-b0e2-10f1511df903', NULL, 'inactive', NULL, '2025-07-31 13:13:24.382079', '2025-07-31 13:13:24.382079');
INSERT INTO public.qr_codes VALUES (311, 'f2f8cbc4-24d0-402e-b1b8-c917aca4cecb', NULL, 'inactive', NULL, '2025-07-31 13:13:24.387006', '2025-07-31 13:13:24.387006');
INSERT INTO public.qr_codes VALUES (312, 'a9925ee7-227a-4c13-a16b-1faddcb4ce90', NULL, 'inactive', NULL, '2025-07-31 13:13:24.389121', '2025-07-31 13:13:24.389121');
INSERT INTO public.qr_codes VALUES (313, '14c28950-bb60-4463-ae5e-51d766d69d23', NULL, 'inactive', NULL, '2025-07-31 13:13:24.391899', '2025-07-31 13:13:24.391899');
INSERT INTO public.qr_codes VALUES (314, '3eae156b-d8b6-4810-b550-007da43aa3e3', NULL, 'inactive', NULL, '2025-07-31 13:13:24.393447', '2025-07-31 13:13:24.393447');
INSERT INTO public.qr_codes VALUES (315, '1489b7ce-cfc0-41fe-bb1a-a88ac5b80e6c', NULL, 'inactive', NULL, '2025-07-31 13:13:24.395073', '2025-07-31 13:13:24.395073');
INSERT INTO public.qr_codes VALUES (316, '1e1f2b14-17c3-4fb3-b48b-00184b8f3edd', NULL, 'inactive', NULL, '2025-07-31 13:13:24.398384', '2025-07-31 13:13:24.398384');
INSERT INTO public.qr_codes VALUES (317, 'd5bae849-8f99-4aa8-9117-9e3d75ca36d8', NULL, 'inactive', NULL, '2025-07-31 13:13:24.399943', '2025-07-31 13:13:24.399943');
INSERT INTO public.qr_codes VALUES (318, '2bfad1e2-fa2f-4027-a36d-deb999f6c984', NULL, 'inactive', NULL, '2025-07-31 13:13:24.401635', '2025-07-31 13:13:24.401635');
INSERT INTO public.qr_codes VALUES (319, '186ec211-56b0-4d06-a6b1-c6285b54a6b4', NULL, 'inactive', NULL, '2025-07-31 13:13:24.403202', '2025-07-31 13:13:24.403202');
INSERT INTO public.qr_codes VALUES (320, 'fddc5075-1a76-4830-acfb-29b92a3f0664', NULL, 'inactive', NULL, '2025-07-31 13:13:24.404632', '2025-07-31 13:13:24.404632');
INSERT INTO public.qr_codes VALUES (321, 'cbc18610-7ace-44a7-8fd4-d0d05876487c', NULL, 'inactive', NULL, '2025-07-31 13:13:24.406942', '2025-07-31 13:13:24.406942');
INSERT INTO public.qr_codes VALUES (322, '5249dd3d-4987-4fbf-9fb8-0380817ec08a', NULL, 'inactive', NULL, '2025-07-31 13:13:24.408258', '2025-07-31 13:13:24.408258');
INSERT INTO public.qr_codes VALUES (323, '21781aea-a454-4296-9a98-feeef95b797f', NULL, 'inactive', NULL, '2025-07-31 13:13:24.409635', '2025-07-31 13:13:24.409635');
INSERT INTO public.qr_codes VALUES (324, '3f79c26e-02c4-4573-afb4-7191d2ee3f91', NULL, 'inactive', NULL, '2025-07-31 13:13:24.411124', '2025-07-31 13:13:24.411124');
INSERT INTO public.qr_codes VALUES (325, '5a96f2d4-6adc-46ef-ac20-ab8dd4214ef2', NULL, 'inactive', NULL, '2025-07-31 13:13:24.413612', '2025-07-31 13:13:24.413612');
INSERT INTO public.qr_codes VALUES (326, '95e0f9af-b2c9-4fd0-80e4-945cb96129ad', NULL, 'inactive', NULL, '2025-07-31 13:13:24.41503', '2025-07-31 13:13:24.41503');
INSERT INTO public.qr_codes VALUES (327, '3023fe8c-0a7d-4250-832a-d49462a1e4f8', NULL, 'inactive', NULL, '2025-07-31 13:13:24.416432', '2025-07-31 13:13:24.416432');
INSERT INTO public.qr_codes VALUES (328, '28687adf-8447-415e-b3a7-71e860e36df1', NULL, 'inactive', NULL, '2025-07-31 13:13:24.41816', '2025-07-31 13:13:24.41816');
INSERT INTO public.qr_codes VALUES (329, '249d08dd-0d1a-4ebc-85cb-b3db373939c0', NULL, 'inactive', NULL, '2025-07-31 13:13:24.41956', '2025-07-31 13:13:24.41956');
INSERT INTO public.qr_codes VALUES (330, '04ce034f-5dcd-452a-8fc3-a77ebd5f1e11', NULL, 'inactive', NULL, '2025-07-31 13:13:24.420887', '2025-07-31 13:13:24.420887');
INSERT INTO public.qr_codes VALUES (331, '1ad46386-8996-4e42-8153-32198324e7cd', NULL, 'inactive', NULL, '2025-07-31 13:13:24.422298', '2025-07-31 13:13:24.422298');
INSERT INTO public.qr_codes VALUES (332, '012e26c6-a962-49e5-89bd-98fd98aef8b0', NULL, 'inactive', NULL, '2025-07-31 13:13:24.424913', '2025-07-31 13:13:24.424913');
INSERT INTO public.qr_codes VALUES (333, '3f2f4d69-1434-49a9-8470-505c9cca93fd', NULL, 'inactive', NULL, '2025-07-31 13:13:24.426461', '2025-07-31 13:13:24.426461');
INSERT INTO public.qr_codes VALUES (334, 'acf6935b-a891-4d20-bfe7-8f87eba1f478', NULL, 'inactive', NULL, '2025-07-31 13:13:24.428487', '2025-07-31 13:13:24.428487');
INSERT INTO public.qr_codes VALUES (335, '5476a12a-f07b-419b-af55-68ff965b5a3d', NULL, 'inactive', NULL, '2025-07-31 13:14:31.998656', '2025-07-31 13:14:31.998656');
INSERT INTO public.qr_codes VALUES (336, 'e5c9edff-8540-4108-a1c8-6849e3b04605', NULL, 'inactive', NULL, '2025-07-31 13:14:32.001228', '2025-07-31 13:14:32.001228');
INSERT INTO public.qr_codes VALUES (337, '252a6acb-64cc-4a45-a6fb-b1368a5b7539', NULL, 'inactive', NULL, '2025-07-31 13:14:32.00275', '2025-07-31 13:14:32.00275');
INSERT INTO public.qr_codes VALUES (338, '5c1d20e2-daea-452b-bc81-4f2558b175b2', NULL, 'inactive', NULL, '2025-07-31 13:14:32.004321', '2025-07-31 13:14:32.004321');
INSERT INTO public.qr_codes VALUES (339, '0bf54687-f4df-4880-a1ab-1b47cd7bfb26', NULL, 'inactive', NULL, '2025-07-31 13:14:32.00568', '2025-07-31 13:14:32.00568');
INSERT INTO public.qr_codes VALUES (340, '3d089647-677d-4466-ad3b-8d6171f6bae7', NULL, 'inactive', NULL, '2025-07-31 13:14:32.007177', '2025-07-31 13:14:32.007177');
INSERT INTO public.qr_codes VALUES (341, '49936ca3-e717-433a-b6db-8e9340a188f0', NULL, 'inactive', NULL, '2025-07-31 13:14:32.008517', '2025-07-31 13:14:32.008517');
INSERT INTO public.qr_codes VALUES (342, 'c80b4ddd-2b4a-4249-af5c-7d48c1dc66a7', NULL, 'inactive', NULL, '2025-07-31 13:14:32.009811', '2025-07-31 13:14:32.009811');
INSERT INTO public.qr_codes VALUES (343, 'e6b2bd0a-1d14-49cf-a92d-94774b4bee31', NULL, 'inactive', NULL, '2025-07-31 13:14:32.011328', '2025-07-31 13:14:32.011328');
INSERT INTO public.qr_codes VALUES (344, '496d165f-fa37-4c48-877b-2795a7c4b0d9', NULL, 'inactive', NULL, '2025-07-31 13:14:32.012635', '2025-07-31 13:14:32.012635');
INSERT INTO public.qr_codes VALUES (345, 'ffecf327-2f76-4d6d-a009-ca89c89b6b69', NULL, 'inactive', NULL, '2025-07-31 13:14:32.01398', '2025-07-31 13:14:32.01398');
INSERT INTO public.qr_codes VALUES (346, 'a49dc88c-31c7-43ec-8765-5a59df3c3cbe', NULL, 'inactive', NULL, '2025-07-31 13:14:32.015332', '2025-07-31 13:14:32.015332');
INSERT INTO public.qr_codes VALUES (347, 'dfe957b5-b36a-4bb6-8a2e-8662e07402da', NULL, 'inactive', NULL, '2025-07-31 13:14:32.016635', '2025-07-31 13:14:32.016635');
INSERT INTO public.qr_codes VALUES (348, '784fde28-fc9a-4541-90f7-411ac8a6e17b', NULL, 'inactive', NULL, '2025-07-31 13:14:32.017859', '2025-07-31 13:14:32.017859');
INSERT INTO public.qr_codes VALUES (349, '5235a377-456d-4e22-8ee4-a9629c0375f8', NULL, 'inactive', NULL, '2025-07-31 13:14:32.019266', '2025-07-31 13:14:32.019266');
INSERT INTO public.qr_codes VALUES (350, 'a3bad85c-1638-490e-9606-34c8bebb1232', NULL, 'inactive', NULL, '2025-07-31 13:14:32.020702', '2025-07-31 13:14:32.020702');
INSERT INTO public.qr_codes VALUES (351, '6217f56e-d279-4376-bed3-4af8542a3050', NULL, 'inactive', NULL, '2025-07-31 13:14:32.021985', '2025-07-31 13:14:32.021985');
INSERT INTO public.qr_codes VALUES (352, '6a24e2cb-d75d-4747-9c51-8278d5703bd1', NULL, 'inactive', NULL, '2025-07-31 13:14:32.023315', '2025-07-31 13:14:32.023315');
INSERT INTO public.qr_codes VALUES (353, 'f899305b-ad25-4df7-b834-ddfed2ee6151', NULL, 'inactive', NULL, '2025-07-31 13:14:32.024714', '2025-07-31 13:14:32.024714');
INSERT INTO public.qr_codes VALUES (354, '860d534c-6ab0-4833-98f5-df8bdcf7860c', NULL, 'inactive', NULL, '2025-07-31 13:14:32.026192', '2025-07-31 13:14:32.026192');
INSERT INTO public.qr_codes VALUES (355, '71322936-0767-425c-9e90-ff308f35966f', NULL, 'inactive', NULL, '2025-07-31 13:14:32.032204', '2025-07-31 13:14:32.032204');
INSERT INTO public.qr_codes VALUES (356, 'e014f96e-69f5-4a34-b0a6-478e1bf73d1a', NULL, 'inactive', NULL, '2025-07-31 13:14:32.033942', '2025-07-31 13:14:32.033942');
INSERT INTO public.qr_codes VALUES (357, '6e07efc7-c135-4ae1-bd1a-6707e69ccd95', NULL, 'inactive', NULL, '2025-07-31 13:14:32.035429', '2025-07-31 13:14:32.035429');
INSERT INTO public.qr_codes VALUES (358, 'c5868b3d-6cba-44b1-a7a4-c21b2ae36ca0', NULL, 'inactive', NULL, '2025-07-31 13:14:32.036943', '2025-07-31 13:14:32.036943');
INSERT INTO public.qr_codes VALUES (359, 'a34a8439-50a3-479b-a266-165aab5978c6', NULL, 'inactive', NULL, '2025-07-31 13:14:32.038381', '2025-07-31 13:14:32.038381');
INSERT INTO public.qr_codes VALUES (360, 'e4b6fc9e-f99f-4e6b-89a9-6efa04b06a9d', NULL, 'inactive', NULL, '2025-07-31 13:14:32.040805', '2025-07-31 13:14:32.040805');
INSERT INTO public.qr_codes VALUES (361, '3997dd56-cae8-4c95-b052-12f251afe63b', NULL, 'inactive', NULL, '2025-07-31 13:14:32.042242', '2025-07-31 13:14:32.042242');
INSERT INTO public.qr_codes VALUES (362, '648426bb-55f6-46c3-839d-7c1dea8c277c', NULL, 'inactive', NULL, '2025-07-31 13:14:32.043531', '2025-07-31 13:14:32.043531');
INSERT INTO public.qr_codes VALUES (363, '1463af56-344d-4e4e-899a-0d3862538d2a', NULL, 'inactive', NULL, '2025-07-31 13:14:32.044847', '2025-07-31 13:14:32.044847');
INSERT INTO public.qr_codes VALUES (364, '9b3acfc3-ed1d-43f1-9fb9-3f2ebe389c87', NULL, 'inactive', NULL, '2025-07-31 13:14:32.046269', '2025-07-31 13:14:32.046269');
INSERT INTO public.qr_codes VALUES (365, '818f07dc-8eee-426c-bce3-d5eb50eb5a8c', NULL, 'inactive', NULL, '2025-07-31 13:14:32.047696', '2025-07-31 13:14:32.047696');
INSERT INTO public.qr_codes VALUES (366, 'bda89a7d-0749-4f00-9d15-05d0747df275', NULL, 'inactive', NULL, '2025-07-31 13:14:32.053421', '2025-07-31 13:14:32.053421');
INSERT INTO public.qr_codes VALUES (367, '12752a07-b221-4a72-b4c5-09dfc5833d4c', NULL, 'inactive', NULL, '2025-07-31 13:14:32.055172', '2025-07-31 13:14:32.055172');
INSERT INTO public.qr_codes VALUES (368, '4a2dd52a-a976-40ae-99de-69d3609d9056', NULL, 'inactive', NULL, '2025-07-31 13:14:32.056711', '2025-07-31 13:14:32.056711');
INSERT INTO public.qr_codes VALUES (369, 'adc11ce0-a12d-4a13-aa85-afcd94a69c44', NULL, 'inactive', NULL, '2025-07-31 13:14:32.058157', '2025-07-31 13:14:32.058157');
INSERT INTO public.qr_codes VALUES (370, '7ae6a1a4-6c9b-4e98-bb53-2e602eb85137', NULL, 'inactive', NULL, '2025-07-31 13:14:32.059536', '2025-07-31 13:14:32.059536');
INSERT INTO public.qr_codes VALUES (371, '12a762b6-9c75-4be1-8ec4-2073315843cd', NULL, 'inactive', NULL, '2025-07-31 13:14:32.060997', '2025-07-31 13:14:32.060997');
INSERT INTO public.qr_codes VALUES (372, '33363108-428c-42f2-b7d5-4e9ee1a3af03', NULL, 'inactive', NULL, '2025-07-31 13:14:32.062345', '2025-07-31 13:14:32.062345');
INSERT INTO public.qr_codes VALUES (373, '4f3b7036-7cc0-4b70-b971-4beaf1a0c786', NULL, 'inactive', NULL, '2025-07-31 13:14:32.063764', '2025-07-31 13:14:32.063764');
INSERT INTO public.qr_codes VALUES (374, '1be7357b-ea59-4762-a772-deff0915dc24', NULL, 'inactive', NULL, '2025-07-31 13:14:32.065202', '2025-07-31 13:14:32.065202');
INSERT INTO public.qr_codes VALUES (375, 'd2685086-abc3-4559-93e3-d1c5f57d4439', NULL, 'inactive', NULL, '2025-07-31 13:14:32.066464', '2025-07-31 13:14:32.066464');
INSERT INTO public.qr_codes VALUES (376, '9dc6c0f7-99af-43e6-9ca6-1ed5743bcf85', NULL, 'inactive', NULL, '2025-07-31 13:14:32.067706', '2025-07-31 13:14:32.067706');
INSERT INTO public.qr_codes VALUES (377, '01249d4b-6837-43dd-810e-91ca301d171e', NULL, 'inactive', NULL, '2025-07-31 13:14:32.068949', '2025-07-31 13:14:32.068949');
INSERT INTO public.qr_codes VALUES (378, '861903b5-78b9-4a6a-a3c2-9f3388109f2f', NULL, 'inactive', NULL, '2025-07-31 13:14:32.070304', '2025-07-31 13:14:32.070304');
INSERT INTO public.qr_codes VALUES (379, 'e9f32ed7-a97c-4bc8-8a10-c3fac3a7c631', NULL, 'inactive', NULL, '2025-07-31 13:14:32.071635', '2025-07-31 13:14:32.071635');
INSERT INTO public.qr_codes VALUES (380, 'f5c16f5f-a2ed-454f-b2f7-15eca929e6cb', NULL, 'inactive', NULL, '2025-07-31 13:14:32.072953', '2025-07-31 13:14:32.072953');
INSERT INTO public.qr_codes VALUES (381, '75e40107-d4e9-4960-bf3f-d518c27c5b32', NULL, 'inactive', NULL, '2025-07-31 13:14:32.07424', '2025-07-31 13:14:32.07424');
INSERT INTO public.qr_codes VALUES (382, '446b289c-edca-417c-89aa-21d1c5d03b57', NULL, 'inactive', NULL, '2025-07-31 13:14:32.07557', '2025-07-31 13:14:32.07557');
INSERT INTO public.qr_codes VALUES (383, 'aba64412-9c59-4481-9b2a-81fb787616b3', NULL, 'inactive', NULL, '2025-07-31 13:14:32.07685', '2025-07-31 13:14:32.07685');
INSERT INTO public.qr_codes VALUES (384, 'e55d11eb-1a3d-44ea-befb-ff4f4a73778e', NULL, 'inactive', NULL, '2025-07-31 13:14:32.078153', '2025-07-31 13:14:32.078153');
INSERT INTO public.qr_codes VALUES (385, '852644ad-e5b7-4ffc-90e1-1920a53cb1ba', NULL, 'inactive', NULL, '2025-07-31 13:16:36.626235', '2025-07-31 13:16:36.626235');
INSERT INTO public.qr_codes VALUES (386, 'e0d9588d-403e-4bd4-aa5c-b16de60efdd3', NULL, 'inactive', NULL, '2025-07-31 13:16:36.628756', '2025-07-31 13:16:36.628756');
INSERT INTO public.qr_codes VALUES (387, 'ba52b421-8f2e-4098-83df-e50847cbb24a', NULL, 'inactive', NULL, '2025-07-31 13:16:36.63038', '2025-07-31 13:16:36.63038');
INSERT INTO public.qr_codes VALUES (388, 'd5126ccd-cd90-4aed-8ddc-a9525e271f9a', NULL, 'inactive', NULL, '2025-07-31 13:16:36.631951', '2025-07-31 13:16:36.631951');
INSERT INTO public.qr_codes VALUES (389, '5fa8901f-5851-4d80-a863-92f03ac85bcd', NULL, 'inactive', NULL, '2025-07-31 13:16:36.63349', '2025-07-31 13:16:36.63349');
INSERT INTO public.qr_codes VALUES (390, '918760c3-486f-454d-8ecf-c341b316af01', NULL, 'inactive', NULL, '2025-07-31 13:16:36.635181', '2025-07-31 13:16:36.635181');
INSERT INTO public.qr_codes VALUES (391, 'a952fa32-38e0-44f7-bbdb-ba7b58f210ce', NULL, 'inactive', NULL, '2025-07-31 13:16:36.636592', '2025-07-31 13:16:36.636592');
INSERT INTO public.qr_codes VALUES (392, 'ac9b4fc3-14d8-4db1-be60-d1a192573a5a', NULL, 'inactive', NULL, '2025-07-31 13:16:36.638076', '2025-07-31 13:16:36.638076');
INSERT INTO public.qr_codes VALUES (393, '9c3d67b9-070b-4f7a-9e01-0cf8db010362', NULL, 'inactive', NULL, '2025-07-31 13:16:36.63949', '2025-07-31 13:16:36.63949');
INSERT INTO public.qr_codes VALUES (394, '82f139f3-3c0f-4e47-b339-5d51e73d8875', NULL, 'inactive', NULL, '2025-07-31 13:16:36.640857', '2025-07-31 13:16:36.640857');
INSERT INTO public.qr_codes VALUES (395, '21cf876e-f62c-4413-83ad-75ce8ae9852b', NULL, 'inactive', NULL, '2025-07-31 13:16:36.642226', '2025-07-31 13:16:36.642226');
INSERT INTO public.qr_codes VALUES (396, '3ed633ff-9302-4aa1-b11d-810dfe044f07', NULL, 'inactive', NULL, '2025-07-31 13:16:36.643613', '2025-07-31 13:16:36.643613');
INSERT INTO public.qr_codes VALUES (397, '442fa88e-48f5-4af9-919b-6f1609bcf109', NULL, 'inactive', NULL, '2025-07-31 13:16:36.645069', '2025-07-31 13:16:36.645069');
INSERT INTO public.qr_codes VALUES (398, '41bd2809-4485-4674-9886-73243308ffc0', NULL, 'inactive', NULL, '2025-07-31 13:16:36.64634', '2025-07-31 13:16:36.64634');
INSERT INTO public.qr_codes VALUES (399, '0243faf9-f10d-4fc9-ab20-bc2ce10ba4c8', NULL, 'inactive', NULL, '2025-07-31 13:16:36.64767', '2025-07-31 13:16:36.64767');
INSERT INTO public.qr_codes VALUES (400, 'ef227a6e-8a09-4e38-a92b-4a80844384ce', NULL, 'inactive', NULL, '2025-07-31 13:16:36.649129', '2025-07-31 13:16:36.649129');
INSERT INTO public.qr_codes VALUES (401, '046903c5-132d-4379-a20c-4b4a8135b734', NULL, 'inactive', NULL, '2025-07-31 13:16:36.650558', '2025-07-31 13:16:36.650558');
INSERT INTO public.qr_codes VALUES (402, '4db2541d-ca98-47cc-a8d2-f2bd0f837340', NULL, 'inactive', NULL, '2025-07-31 13:16:36.656615', '2025-07-31 13:16:36.656615');
INSERT INTO public.qr_codes VALUES (403, 'da6d1c3a-70af-4318-b22b-69e3e0b5c42a', NULL, 'inactive', NULL, '2025-07-31 13:16:36.658112', '2025-07-31 13:16:36.658112');
INSERT INTO public.qr_codes VALUES (404, '29452bdc-3eb8-4639-8bdc-3a040db2830d', NULL, 'inactive', NULL, '2025-07-31 13:16:36.659696', '2025-07-31 13:16:36.659696');
INSERT INTO public.qr_codes VALUES (405, '12d1255f-0ef8-41d8-b9df-bf9729b76e76', NULL, 'inactive', NULL, '2025-07-31 13:16:36.661228', '2025-07-31 13:16:36.661228');
INSERT INTO public.qr_codes VALUES (406, '870a4193-6c97-4a8f-b8f1-46a04e0b155f', NULL, 'inactive', NULL, '2025-07-31 13:16:36.662886', '2025-07-31 13:16:36.662886');
INSERT INTO public.qr_codes VALUES (407, '2431640e-215b-4153-9eba-d827d00975bb', NULL, 'inactive', NULL, '2025-07-31 13:16:36.66446', '2025-07-31 13:16:36.66446');
INSERT INTO public.qr_codes VALUES (408, 'c0aa02b3-2653-456a-a064-41819a372326', NULL, 'inactive', NULL, '2025-07-31 13:16:36.666752', '2025-07-31 13:16:36.666752');
INSERT INTO public.qr_codes VALUES (409, '0e45770c-6c34-484b-bd9d-1f6897a5bc5e', NULL, 'inactive', NULL, '2025-07-31 13:16:36.668373', '2025-07-31 13:16:36.668373');
INSERT INTO public.qr_codes VALUES (410, '76e3392e-3ed1-4a7a-b783-acaa3278e8dc', NULL, 'inactive', NULL, '2025-07-31 13:16:36.669821', '2025-07-31 13:16:36.669821');
INSERT INTO public.qr_codes VALUES (411, 'b7ecc60c-10a3-4afc-98ec-4295264f8fa4', NULL, 'inactive', NULL, '2025-07-31 13:16:36.671331', '2025-07-31 13:16:36.671331');
INSERT INTO public.qr_codes VALUES (412, '6ea6e16d-b4e0-48e1-b188-61b377250ebc', NULL, 'inactive', NULL, '2025-07-31 13:16:36.673109', '2025-07-31 13:16:36.673109');
INSERT INTO public.qr_codes VALUES (413, '2bbf72f7-c168-4966-9047-a5181e745635', NULL, 'inactive', NULL, '2025-07-31 13:16:36.674667', '2025-07-31 13:16:36.674667');
INSERT INTO public.qr_codes VALUES (414, '97096f7a-ed3a-4284-9630-38f05abd1d44', NULL, 'inactive', NULL, '2025-07-31 13:16:36.676415', '2025-07-31 13:16:36.676415');
INSERT INTO public.qr_codes VALUES (415, '7a01a5d0-9928-4b14-9a32-c01bfc8e3e71', NULL, 'inactive', NULL, '2025-07-31 13:16:36.677856', '2025-07-31 13:16:36.677856');
INSERT INTO public.qr_codes VALUES (416, '1c859f1a-be7b-4ac8-8122-41df957d8743', NULL, 'inactive', NULL, '2025-07-31 13:16:36.679812', '2025-07-31 13:16:36.679812');
INSERT INTO public.qr_codes VALUES (417, '39456bfe-1821-4bb0-a4f8-2431fc62b358', NULL, 'inactive', NULL, '2025-07-31 13:16:36.681281', '2025-07-31 13:16:36.681281');
INSERT INTO public.qr_codes VALUES (418, 'df090bea-fe63-4f78-8957-e51fe02e9e5e', NULL, 'inactive', NULL, '2025-07-31 13:16:36.682683', '2025-07-31 13:16:36.682683');
INSERT INTO public.qr_codes VALUES (419, '7db06fbb-6850-43c1-b744-74fd2cc334cf', NULL, 'inactive', NULL, '2025-07-31 13:16:36.684193', '2025-07-31 13:16:36.684193');
INSERT INTO public.qr_codes VALUES (420, '477e2f02-b344-43c4-975d-e0b89b2c5c08', NULL, 'inactive', NULL, '2025-07-31 13:16:36.685638', '2025-07-31 13:16:36.685638');
INSERT INTO public.qr_codes VALUES (421, '171644b6-3ff7-41d5-8290-fa326cab52d4', NULL, 'inactive', NULL, '2025-07-31 13:16:36.687106', '2025-07-31 13:16:36.687106');
INSERT INTO public.qr_codes VALUES (422, 'f0993b07-942c-486c-9939-663cd3e80c28', NULL, 'inactive', NULL, '2025-07-31 13:16:36.688566', '2025-07-31 13:16:36.688566');
INSERT INTO public.qr_codes VALUES (423, '3a6163a7-5a57-4260-84cd-2040444a6339', NULL, 'inactive', NULL, '2025-07-31 13:16:36.689971', '2025-07-31 13:16:36.689971');
INSERT INTO public.qr_codes VALUES (424, '31a3176b-ed74-4f20-bce9-3625b6dca34d', NULL, 'inactive', NULL, '2025-07-31 13:16:36.692699', '2025-07-31 13:16:36.692699');
INSERT INTO public.qr_codes VALUES (425, '9acff168-2888-4eb3-8480-9f852c7af9e3', NULL, 'inactive', NULL, '2025-07-31 13:16:36.694249', '2025-07-31 13:16:36.694249');
INSERT INTO public.qr_codes VALUES (426, '9fc74ee7-16c7-429f-91fe-13325404985a', NULL, 'inactive', NULL, '2025-07-31 13:16:36.695737', '2025-07-31 13:16:36.695737');
INSERT INTO public.qr_codes VALUES (427, 'a5479229-3748-4d85-8c42-8ea8f4491a04', NULL, 'inactive', NULL, '2025-07-31 13:16:36.697248', '2025-07-31 13:16:36.697248');
INSERT INTO public.qr_codes VALUES (428, '773d95ae-153f-4368-ae19-1434b63f3e73', NULL, 'inactive', NULL, '2025-07-31 13:16:36.698695', '2025-07-31 13:16:36.698695');
INSERT INTO public.qr_codes VALUES (429, 'c2029019-978e-4cda-8adf-55c71b223d41', NULL, 'inactive', NULL, '2025-07-31 13:16:36.700192', '2025-07-31 13:16:36.700192');
INSERT INTO public.qr_codes VALUES (430, '7927c000-166d-47ca-bb21-818932d204ea', NULL, 'inactive', NULL, '2025-07-31 13:16:36.701584', '2025-07-31 13:16:36.701584');
INSERT INTO public.qr_codes VALUES (431, '243b9b08-c9c6-4994-af8d-3c1272238434', NULL, 'inactive', NULL, '2025-07-31 13:16:36.703085', '2025-07-31 13:16:36.703085');
INSERT INTO public.qr_codes VALUES (432, 'dbd13361-85cf-4487-bb62-e83f6c7130b2', NULL, 'inactive', NULL, '2025-07-31 13:16:36.704473', '2025-07-31 13:16:36.704473');
INSERT INTO public.qr_codes VALUES (433, '2c673d7f-1b9c-4e66-848c-76f330a2b336', NULL, 'inactive', NULL, '2025-07-31 13:16:36.706555', '2025-07-31 13:16:36.706555');
INSERT INTO public.qr_codes VALUES (434, '0a2ffb26-4ebf-4b45-9eb3-15851599f8ef', NULL, 'inactive', NULL, '2025-07-31 13:16:36.707884', '2025-07-31 13:16:36.707884');
INSERT INTO public.qr_codes VALUES (435, '93259598-ac6e-4789-8c41-24b9d5802d4b', NULL, 'inactive', NULL, '2025-07-31 13:17:54.824192', '2025-07-31 13:17:54.824192');
INSERT INTO public.qr_codes VALUES (436, 'f7e741b1-a369-4903-821f-bd1e17b77cd0', NULL, 'inactive', NULL, '2025-07-31 13:17:54.827346', '2025-07-31 13:17:54.827346');
INSERT INTO public.qr_codes VALUES (437, 'd8a06ca3-ad3f-4bb2-994d-631c97536608', NULL, 'inactive', NULL, '2025-07-31 13:19:04.342553', '2025-07-31 13:19:04.342553');
INSERT INTO public.qr_codes VALUES (438, '6ac7b2d4-1e2b-4c10-986b-db31d0d940a7', NULL, 'inactive', NULL, '2025-07-31 13:19:04.345082', '2025-07-31 13:19:04.345082');
INSERT INTO public.qr_codes VALUES (439, '0794386d-b383-47da-bf24-2448b8c92b6a', NULL, 'inactive', NULL, '2025-07-31 13:19:04.346574', '2025-07-31 13:19:04.346574');
INSERT INTO public.qr_codes VALUES (440, '106da002-ae65-4d78-a0b4-dbfed138d2c5', NULL, 'inactive', NULL, '2025-07-31 13:19:04.348005', '2025-07-31 13:19:04.348005');
INSERT INTO public.qr_codes VALUES (441, '7486cfa6-f281-4c45-968e-f20ba6327e2d', NULL, 'inactive', NULL, '2025-07-31 13:19:04.352124', '2025-07-31 13:19:04.352124');
INSERT INTO public.qr_codes VALUES (442, '41dcee0f-486d-4e22-a2c8-da97f8f2c3f1', NULL, 'inactive', NULL, '2025-07-31 13:19:04.353463', '2025-07-31 13:19:04.353463');
INSERT INTO public.qr_codes VALUES (443, 'fb4dcbd6-c509-4ffc-9384-fdb296c61c62', NULL, 'inactive', NULL, '2025-07-31 13:19:04.354937', '2025-07-31 13:19:04.354937');
INSERT INTO public.qr_codes VALUES (444, '3022821a-6685-4677-b3be-3f2e49330f11', NULL, 'inactive', NULL, '2025-07-31 13:19:04.356261', '2025-07-31 13:19:04.356261');
INSERT INTO public.qr_codes VALUES (445, 'd29f5d40-2176-4116-a267-17397f072175', NULL, 'inactive', NULL, '2025-07-31 13:19:04.35757', '2025-07-31 13:19:04.35757');
INSERT INTO public.qr_codes VALUES (446, '9d2a6727-e2a8-46da-a48f-b5b2bec2d4a2', NULL, 'inactive', NULL, '2025-07-31 13:19:04.359078', '2025-07-31 13:19:04.359078');
INSERT INTO public.qr_codes VALUES (447, '1800eb59-c0b7-4b77-9121-4cae1cec34f1', NULL, 'inactive', NULL, '2025-07-31 13:19:04.361086', '2025-07-31 13:19:04.361086');
INSERT INTO public.qr_codes VALUES (448, '95404b57-f215-4315-9894-3f5b1bc596b9', NULL, 'inactive', NULL, '2025-07-31 13:19:04.363251', '2025-07-31 13:19:04.363251');
INSERT INTO public.qr_codes VALUES (449, 'd6dbef91-9e54-45a4-9d50-1be3658988ec', NULL, 'inactive', NULL, '2025-07-31 13:19:04.364579', '2025-07-31 13:19:04.364579');
INSERT INTO public.qr_codes VALUES (450, 'cf546ba6-a307-408c-af82-f9ba57b0b567', NULL, 'inactive', NULL, '2025-07-31 13:19:04.366021', '2025-07-31 13:19:04.366021');
INSERT INTO public.qr_codes VALUES (451, '39e72191-3c74-430d-af88-a752bec29ba5', NULL, 'inactive', NULL, '2025-07-31 13:19:04.367386', '2025-07-31 13:19:04.367386');
INSERT INTO public.qr_codes VALUES (452, '74e6cdc2-b41f-4224-a177-073dbd6dc34e', NULL, 'inactive', NULL, '2025-07-31 13:19:04.368703', '2025-07-31 13:19:04.368703');
INSERT INTO public.qr_codes VALUES (453, 'a873c0a9-6315-44a2-8412-3189778c5e10', NULL, 'inactive', NULL, '2025-07-31 13:19:04.37014', '2025-07-31 13:19:04.37014');
INSERT INTO public.qr_codes VALUES (454, '71a86f40-0255-4fcf-92c0-ecdd7b06c74b', NULL, 'inactive', NULL, '2025-07-31 13:19:04.371432', '2025-07-31 13:19:04.371432');
INSERT INTO public.qr_codes VALUES (455, 'ce63def2-e7d7-4706-86d3-7e8866e2f55f', NULL, 'inactive', NULL, '2025-07-31 13:19:04.372704', '2025-07-31 13:19:04.372704');
INSERT INTO public.qr_codes VALUES (456, 'c37f7e81-99fa-4e55-9599-6a1d52234c15', NULL, 'inactive', NULL, '2025-07-31 13:19:04.374087', '2025-07-31 13:19:04.374087');
INSERT INTO public.qr_codes VALUES (457, 'b82ecea4-02ca-4811-a262-a6c236bac43c', NULL, 'inactive', NULL, '2025-07-31 13:19:04.375445', '2025-07-31 13:19:04.375445');
INSERT INTO public.qr_codes VALUES (458, '87262fec-f6e5-4f42-bf88-af57754eabd4', NULL, 'inactive', NULL, '2025-07-31 13:19:04.378096', '2025-07-31 13:19:04.378096');
INSERT INTO public.qr_codes VALUES (459, '99c6f808-f2cc-46ee-9fff-d9adf091cf65', NULL, 'inactive', NULL, '2025-07-31 13:19:04.379461', '2025-07-31 13:19:04.379461');
INSERT INTO public.qr_codes VALUES (460, 'c4375e65-3f1a-4e21-a73c-cd1a9084910d', NULL, 'inactive', NULL, '2025-07-31 13:19:04.380783', '2025-07-31 13:19:04.380783');
INSERT INTO public.qr_codes VALUES (461, '3b7e8720-81a1-4f16-be9a-f7be35875642', NULL, 'inactive', NULL, '2025-07-31 13:19:04.382964', '2025-07-31 13:19:04.382964');
INSERT INTO public.qr_codes VALUES (462, 'bd817b74-249f-41c3-bc83-4c1001b1b5f0', NULL, 'inactive', NULL, '2025-07-31 13:19:04.384341', '2025-07-31 13:19:04.384341');
INSERT INTO public.qr_codes VALUES (463, 'bea61f5f-d004-49ea-bf9a-5a60e935ab78', NULL, 'inactive', NULL, '2025-07-31 13:19:04.385712', '2025-07-31 13:19:04.385712');
INSERT INTO public.qr_codes VALUES (464, 'e0d9c85a-6060-4e38-81f5-018be652462c', NULL, 'inactive', NULL, '2025-07-31 13:19:04.38725', '2025-07-31 13:19:04.38725');
INSERT INTO public.qr_codes VALUES (465, '6aa7015f-2189-4965-8232-86359fcbe9c9', NULL, 'inactive', NULL, '2025-07-31 13:19:04.388586', '2025-07-31 13:19:04.388586');
INSERT INTO public.qr_codes VALUES (466, '446ca033-9df3-4da9-a810-7a7b966fd5d2', NULL, 'inactive', NULL, '2025-07-31 13:19:04.389944', '2025-07-31 13:19:04.389944');
INSERT INTO public.qr_codes VALUES (467, 'b5ec8846-f88a-4284-b10e-ffd849e9010d', NULL, 'inactive', NULL, '2025-07-31 13:19:04.391231', '2025-07-31 13:19:04.391231');
INSERT INTO public.qr_codes VALUES (468, 'e8926adc-15bd-497a-a488-808bb2e3fb16', NULL, 'inactive', NULL, '2025-07-31 13:19:04.392546', '2025-07-31 13:19:04.392546');
INSERT INTO public.qr_codes VALUES (469, '078b5b9d-99eb-4299-9b95-4121f3d23646', NULL, 'inactive', NULL, '2025-07-31 13:19:04.39381', '2025-07-31 13:19:04.39381');
INSERT INTO public.qr_codes VALUES (470, '96926990-048b-4a33-8b82-5638300a1c1c', NULL, 'inactive', NULL, '2025-07-31 13:19:04.39521', '2025-07-31 13:19:04.39521');
INSERT INTO public.qr_codes VALUES (471, 'e044dc29-91ee-4546-9a61-42e641734968', NULL, 'inactive', NULL, '2025-07-31 13:19:04.39652', '2025-07-31 13:19:04.39652');
INSERT INTO public.qr_codes VALUES (472, 'ba8799c5-8b6f-4360-873a-21bc8a5002e7', NULL, 'inactive', NULL, '2025-07-31 13:19:04.397767', '2025-07-31 13:19:04.397767');
INSERT INTO public.qr_codes VALUES (473, 'badcb504-35c0-48dc-bb6e-17462c97b505', NULL, 'inactive', NULL, '2025-07-31 13:19:04.399177', '2025-07-31 13:19:04.399177');
INSERT INTO public.qr_codes VALUES (474, 'a8e564be-74d0-4575-969f-b85f5495aea6', NULL, 'inactive', NULL, '2025-07-31 13:19:04.400456', '2025-07-31 13:19:04.400456');
INSERT INTO public.qr_codes VALUES (475, '073a896d-ab8b-4267-b25b-5791d2261483', NULL, 'inactive', NULL, '2025-07-31 13:19:04.401715', '2025-07-31 13:19:04.401715');
INSERT INTO public.qr_codes VALUES (476, 'fe20caaa-3947-48a6-b6f2-0925a542e57f', NULL, 'inactive', NULL, '2025-07-31 13:19:04.403692', '2025-07-31 13:19:04.403692');
INSERT INTO public.qr_codes VALUES (477, 'd420754a-67e5-4fbe-9eb7-c852975d177e', NULL, 'inactive', NULL, '2025-07-31 13:19:04.405065', '2025-07-31 13:19:04.405065');
INSERT INTO public.qr_codes VALUES (478, '6d5d893c-f9b3-4985-b440-9588c1c91610', NULL, 'inactive', NULL, '2025-07-31 13:19:04.40634', '2025-07-31 13:19:04.40634');
INSERT INTO public.qr_codes VALUES (479, '67489a51-74d6-45d9-8b70-4b3d5ea29a9f', NULL, 'inactive', NULL, '2025-07-31 13:19:04.407685', '2025-07-31 13:19:04.407685');
INSERT INTO public.qr_codes VALUES (480, 'f3369b5c-78d0-4154-af4a-bcafafe5182b', NULL, 'inactive', NULL, '2025-07-31 13:19:04.409098', '2025-07-31 13:19:04.409098');
INSERT INTO public.qr_codes VALUES (481, '24da8828-c004-4b31-a454-6af91db52a78', NULL, 'inactive', NULL, '2025-07-31 13:19:04.41039', '2025-07-31 13:19:04.41039');
INSERT INTO public.qr_codes VALUES (482, 'ef9c788c-e903-4bda-b446-498691cfa708', NULL, 'inactive', NULL, '2025-07-31 13:19:04.411694', '2025-07-31 13:19:04.411694');
INSERT INTO public.qr_codes VALUES (483, 'ffa8276d-a58d-4ccb-8e08-b7da0bacd253', NULL, 'inactive', NULL, '2025-07-31 13:19:04.413057', '2025-07-31 13:19:04.413057');
INSERT INTO public.qr_codes VALUES (484, 'e3971ab9-1802-4f6e-a5cd-ef1a67fdbced', NULL, 'inactive', NULL, '2025-07-31 13:19:04.414427', '2025-07-31 13:19:04.414427');
INSERT INTO public.qr_codes VALUES (485, '174252f9-3820-4cb9-a345-d9f509c02297', NULL, 'inactive', NULL, '2025-07-31 13:19:04.415824', '2025-07-31 13:19:04.415824');
INSERT INTO public.qr_codes VALUES (486, 'facc524c-6134-4051-a6ab-ddb3326742d9', NULL, 'inactive', NULL, '2025-07-31 13:19:04.417182', '2025-07-31 13:19:04.417182');
INSERT INTO public.qr_codes VALUES (487, 'b278ba0d-0a4e-432e-a123-593d41065299', NULL, 'inactive', NULL, '2025-07-31 13:19:23.675731', '2025-07-31 13:19:23.675731');
INSERT INTO public.qr_codes VALUES (488, 'f01a0fba-c192-4255-8cb5-207b4d115b44', NULL, 'inactive', NULL, '2025-07-31 13:19:23.678261', '2025-07-31 13:19:23.678261');
INSERT INTO public.qr_codes VALUES (489, '724e21a0-bc41-40e8-9eeb-67fda3f671cf', NULL, 'inactive', NULL, '2025-07-31 13:19:23.679843', '2025-07-31 13:19:23.679843');
INSERT INTO public.qr_codes VALUES (490, 'bf0f4c2d-253a-461a-b426-b2129bcf9d93', NULL, 'inactive', NULL, '2025-07-31 13:19:23.682036', '2025-07-31 13:19:23.682036');
INSERT INTO public.qr_codes VALUES (491, '7c4cb5d9-8bec-48d2-a534-a0a2268d0ae9', NULL, 'inactive', NULL, '2025-07-31 13:19:23.683712', '2025-07-31 13:19:23.683712');
INSERT INTO public.qr_codes VALUES (492, '86efe7e1-67e3-45ca-9933-9f2bff67ac91', NULL, 'inactive', NULL, '2025-07-31 13:19:23.685283', '2025-07-31 13:19:23.685283');
INSERT INTO public.qr_codes VALUES (493, '575cc71f-8253-423e-a71c-4dfc5378ab75', NULL, 'inactive', NULL, '2025-07-31 13:19:23.686775', '2025-07-31 13:19:23.686775');
INSERT INTO public.qr_codes VALUES (494, '72697ef4-dc38-4177-b2db-4ceef3f28b41', NULL, 'inactive', NULL, '2025-07-31 13:19:23.688439', '2025-07-31 13:19:23.688439');
INSERT INTO public.qr_codes VALUES (495, '4d4a1c4a-3d81-45e3-a8a1-51ca3a5b82fd', NULL, 'inactive', NULL, '2025-07-31 13:19:23.689909', '2025-07-31 13:19:23.689909');
INSERT INTO public.qr_codes VALUES (496, 'b1b1fc2d-2fd1-452f-98b0-8f9dba632fef', NULL, 'inactive', NULL, '2025-07-31 13:19:23.691396', '2025-07-31 13:19:23.691396');
INSERT INTO public.qr_codes VALUES (497, '310a4052-35d5-4647-9f97-bef24efb563f', NULL, 'inactive', NULL, '2025-07-31 13:19:23.692851', '2025-07-31 13:19:23.692851');
INSERT INTO public.qr_codes VALUES (498, '6554f2c8-9f32-458b-9bc6-244bb35393fe', NULL, 'inactive', NULL, '2025-07-31 13:19:23.694226', '2025-07-31 13:19:23.694226');
INSERT INTO public.qr_codes VALUES (499, '05fc1aa6-7ced-4165-b446-3984692bf8ca', NULL, 'inactive', NULL, '2025-07-31 13:19:23.695535', '2025-07-31 13:19:23.695535');
INSERT INTO public.qr_codes VALUES (500, '842a2202-97b2-4489-95b1-59f11d357bd9', NULL, 'inactive', NULL, '2025-07-31 13:19:23.696911', '2025-07-31 13:19:23.696911');
INSERT INTO public.qr_codes VALUES (501, '8e085b52-6ba5-48ff-9fd5-fe9fb95c3b0f', NULL, 'inactive', NULL, '2025-07-31 13:19:23.698341', '2025-07-31 13:19:23.698341');
INSERT INTO public.qr_codes VALUES (502, '3a1fc183-19c9-449c-bb76-450b9c934e95', NULL, 'inactive', NULL, '2025-07-31 13:19:23.699775', '2025-07-31 13:19:23.699775');
INSERT INTO public.qr_codes VALUES (503, '47de6095-91d7-4f4e-b3d7-5ad0d8fa0b76', NULL, 'inactive', NULL, '2025-07-31 13:19:23.701172', '2025-07-31 13:19:23.701172');
INSERT INTO public.qr_codes VALUES (504, '1bcfd8d1-b2a7-4d36-9d72-275a96c1fb90', NULL, 'inactive', NULL, '2025-07-31 13:19:23.702502', '2025-07-31 13:19:23.702502');
INSERT INTO public.qr_codes VALUES (505, '843e7906-94a4-4c8f-a62d-07f9c495b22d', NULL, 'inactive', NULL, '2025-07-31 13:19:23.703854', '2025-07-31 13:19:23.703854');
INSERT INTO public.qr_codes VALUES (506, '218b6513-3ceb-40cc-94ea-5c8b7ec63be5', NULL, 'inactive', NULL, '2025-07-31 13:19:23.705234', '2025-07-31 13:19:23.705234');
INSERT INTO public.qr_codes VALUES (507, '90839ac6-f524-4f45-9a67-1b4bf4b9f42a', NULL, 'inactive', NULL, '2025-07-31 13:19:23.706607', '2025-07-31 13:19:23.706607');
INSERT INTO public.qr_codes VALUES (508, 'cca3f6c4-7aef-491d-8c7e-423a2f1045f7', NULL, 'inactive', NULL, '2025-07-31 13:19:23.707943', '2025-07-31 13:19:23.707943');
INSERT INTO public.qr_codes VALUES (509, '3e47401c-1ffa-4f48-bc93-75368f100009', NULL, 'inactive', NULL, '2025-07-31 13:19:23.709319', '2025-07-31 13:19:23.709319');
INSERT INTO public.qr_codes VALUES (510, 'a532a50b-ca7d-4db1-9d6d-7a5f5177ed67', NULL, 'inactive', NULL, '2025-07-31 13:19:23.711531', '2025-07-31 13:19:23.711531');
INSERT INTO public.qr_codes VALUES (511, 'ec01e4d4-d5be-4c4f-a910-227e09041e25', NULL, 'inactive', NULL, '2025-07-31 13:19:23.71303', '2025-07-31 13:19:23.71303');
INSERT INTO public.qr_codes VALUES (512, '5c0e479e-0b09-4215-b495-0181d85dc95f', NULL, 'inactive', NULL, '2025-07-31 13:19:23.714423', '2025-07-31 13:19:23.714423');
INSERT INTO public.qr_codes VALUES (513, 'a6abcf54-7b7f-4a9a-b4f1-92a786b137c7', NULL, 'inactive', NULL, '2025-07-31 13:19:23.715828', '2025-07-31 13:19:23.715828');
INSERT INTO public.qr_codes VALUES (514, '93850688-a7d5-4aca-8393-56130b844b98', NULL, 'inactive', NULL, '2025-07-31 13:19:23.717306', '2025-07-31 13:19:23.717306');
INSERT INTO public.qr_codes VALUES (515, 'fd4122bc-a848-4785-8f9c-7c6dc380e64d', NULL, 'inactive', NULL, '2025-07-31 13:19:23.71894', '2025-07-31 13:19:23.71894');
INSERT INTO public.qr_codes VALUES (516, '5206128c-737b-49d2-ae3c-b8cea5d2b50f', NULL, 'inactive', NULL, '2025-07-31 13:19:23.720382', '2025-07-31 13:19:23.720382');
INSERT INTO public.qr_codes VALUES (517, '905a30fc-03fc-4849-96c1-3f29f1cbe2f2', NULL, 'inactive', NULL, '2025-07-31 13:19:23.721786', '2025-07-31 13:19:23.721786');
INSERT INTO public.qr_codes VALUES (518, '5e7baa73-39d4-4754-a2d7-f736dc13c3e3', NULL, 'inactive', NULL, '2025-07-31 13:19:23.723305', '2025-07-31 13:19:23.723305');
INSERT INTO public.qr_codes VALUES (519, 'f8ac9f4f-6530-4574-a265-b541b4b8036f', NULL, 'inactive', NULL, '2025-07-31 13:19:23.724591', '2025-07-31 13:19:23.724591');
INSERT INTO public.qr_codes VALUES (520, '9ab002d5-a127-44b6-9637-3d7149b9ca74', NULL, 'inactive', NULL, '2025-07-31 13:19:23.725953', '2025-07-31 13:19:23.725953');
INSERT INTO public.qr_codes VALUES (521, '757bf4de-168b-43b9-8941-7aa79a787665', NULL, 'inactive', NULL, '2025-07-31 13:19:23.72772', '2025-07-31 13:19:23.72772');
INSERT INTO public.qr_codes VALUES (522, 'bdf67b35-0f5c-44a3-b007-e8d90aa4d571', NULL, 'inactive', NULL, '2025-07-31 13:19:23.729104', '2025-07-31 13:19:23.729104');
INSERT INTO public.qr_codes VALUES (523, 'd1d189de-afc2-44b3-82d5-0551d41557a2', NULL, 'inactive', NULL, '2025-07-31 13:19:23.730486', '2025-07-31 13:19:23.730486');
INSERT INTO public.qr_codes VALUES (524, 'ed0b8650-fed9-446d-9063-23c44f8ab886', NULL, 'inactive', NULL, '2025-07-31 13:19:23.731831', '2025-07-31 13:19:23.731831');
INSERT INTO public.qr_codes VALUES (525, '28b7f302-0ee7-4302-a45a-1f8451317424', NULL, 'inactive', NULL, '2025-07-31 13:19:23.733189', '2025-07-31 13:19:23.733189');
INSERT INTO public.qr_codes VALUES (526, 'a600ee3d-21d2-4d74-928e-d5d7b7260da4', NULL, 'inactive', NULL, '2025-07-31 13:19:23.734556', '2025-07-31 13:19:23.734556');
INSERT INTO public.qr_codes VALUES (527, '8b995cf2-f3db-42a1-878f-0872474aa2bf', NULL, 'inactive', NULL, '2025-07-31 13:19:23.735914', '2025-07-31 13:19:23.735914');
INSERT INTO public.qr_codes VALUES (528, '8f3f83c1-e20e-4131-9af1-4dc26e5cdbc9', NULL, 'inactive', NULL, '2025-07-31 13:19:23.738389', '2025-07-31 13:19:23.738389');
INSERT INTO public.qr_codes VALUES (529, '03055c6b-0094-4c7e-9f9e-2d3ba029776b', NULL, 'inactive', NULL, '2025-07-31 13:19:23.740747', '2025-07-31 13:19:23.740747');
INSERT INTO public.qr_codes VALUES (530, '5db08874-1728-452e-bd52-59db259fb719', NULL, 'inactive', NULL, '2025-07-31 13:19:23.742196', '2025-07-31 13:19:23.742196');
INSERT INTO public.qr_codes VALUES (531, '322a5729-37ad-46ab-b557-5a58b7358191', NULL, 'inactive', NULL, '2025-07-31 13:19:23.743554', '2025-07-31 13:19:23.743554');
INSERT INTO public.qr_codes VALUES (532, '51c90669-9a09-4d53-9942-c682fc1546dc', NULL, 'inactive', NULL, '2025-07-31 13:19:23.744885', '2025-07-31 13:19:23.744885');
INSERT INTO public.qr_codes VALUES (533, 'e36d4753-815c-4605-80b3-7418d732ce8f', NULL, 'inactive', NULL, '2025-07-31 13:19:23.746315', '2025-07-31 13:19:23.746315');
INSERT INTO public.qr_codes VALUES (534, '4f048523-faed-499e-9065-9908690a2cb2', NULL, 'inactive', NULL, '2025-07-31 13:19:23.74771', '2025-07-31 13:19:23.74771');
INSERT INTO public.qr_codes VALUES (535, 'fd21c860-1060-4946-b0c0-f35c809ad8d3', NULL, 'inactive', NULL, '2025-07-31 13:19:23.749259', '2025-07-31 13:19:23.749259');
INSERT INTO public.qr_codes VALUES (536, '584f25bd-44d0-4504-9c4c-81d91960c87f', NULL, 'inactive', NULL, '2025-07-31 13:19:23.750604', '2025-07-31 13:19:23.750604');
INSERT INTO public.qr_codes VALUES (537, '3e8c98f7-385d-43f9-8648-5cf9dafcbd96', NULL, 'inactive', NULL, '2025-07-31 13:19:59.338646', '2025-07-31 13:19:59.338646');
INSERT INTO public.qr_codes VALUES (538, '9ec37899-47f9-483f-8443-f4f83343f44f', NULL, 'inactive', NULL, '2025-07-31 13:19:59.341275', '2025-07-31 13:19:59.341275');
INSERT INTO public.qr_codes VALUES (539, '5b741aaa-9cc9-4614-93b8-6922907db5e5', NULL, 'inactive', NULL, '2025-07-31 13:19:59.343388', '2025-07-31 13:19:59.343388');
INSERT INTO public.qr_codes VALUES (540, 'c45df7cf-ce2d-43f0-94b1-801da22c09cc', NULL, 'inactive', NULL, '2025-07-31 13:19:59.345373', '2025-07-31 13:19:59.345373');
INSERT INTO public.qr_codes VALUES (541, '4ead5935-b298-4bad-99fe-375812f61adf', NULL, 'inactive', NULL, '2025-07-31 13:19:59.346945', '2025-07-31 13:19:59.346945');
INSERT INTO public.qr_codes VALUES (542, '91c4652d-b5bd-4368-bdfa-6ceba3bb3d09', NULL, 'inactive', NULL, '2025-07-31 13:19:59.348308', '2025-07-31 13:19:59.348308');
INSERT INTO public.qr_codes VALUES (543, 'b224cd61-a75d-422c-9770-5c9223ac1949', NULL, 'inactive', NULL, '2025-07-31 13:19:59.349612', '2025-07-31 13:19:59.349612');
INSERT INTO public.qr_codes VALUES (544, '7bdc73a0-2bd1-4fb7-a783-88bada9c137a', NULL, 'inactive', NULL, '2025-07-31 13:19:59.351058', '2025-07-31 13:19:59.351058');
INSERT INTO public.qr_codes VALUES (545, '2c3a4ec1-e44f-4185-b0c5-47c58f26918f', NULL, 'inactive', NULL, '2025-07-31 13:19:59.352312', '2025-07-31 13:19:59.352312');
INSERT INTO public.qr_codes VALUES (546, 'd4285df4-32e7-4261-811a-2bbd1e96d874', NULL, 'inactive', NULL, '2025-07-31 13:19:59.353616', '2025-07-31 13:19:59.353616');
INSERT INTO public.qr_codes VALUES (547, '01c4fcf0-24d5-45a7-936c-633b33f3e5c1', NULL, 'inactive', NULL, '2025-07-31 13:19:59.35509', '2025-07-31 13:19:59.35509');
INSERT INTO public.qr_codes VALUES (548, '016810da-3da9-4449-9802-5c21d071fe1c', NULL, 'inactive', NULL, '2025-07-31 13:19:59.35644', '2025-07-31 13:19:59.35644');
INSERT INTO public.qr_codes VALUES (549, '1766bcc0-da37-4d82-bae8-3a8d32fadbe4', NULL, 'inactive', NULL, '2025-07-31 13:19:59.357819', '2025-07-31 13:19:59.357819');
INSERT INTO public.qr_codes VALUES (550, 'd0b9ccfe-3da3-4641-9f54-3b725bdf95de', NULL, 'inactive', NULL, '2025-07-31 13:19:59.359173', '2025-07-31 13:19:59.359173');
INSERT INTO public.qr_codes VALUES (551, '5a392db5-5c30-4a1a-8dff-1a757b7bde30', NULL, 'inactive', NULL, '2025-07-31 13:19:59.360483', '2025-07-31 13:19:59.360483');
INSERT INTO public.qr_codes VALUES (552, '4133a0ba-245e-4d9f-be1f-25e280c150b5', NULL, 'inactive', NULL, '2025-07-31 13:19:59.361796', '2025-07-31 13:19:59.361796');
INSERT INTO public.qr_codes VALUES (553, '30a8d16a-6bfe-4383-bf6a-a1f732e05f6f', NULL, 'inactive', NULL, '2025-07-31 13:19:59.363125', '2025-07-31 13:19:59.363125');
INSERT INTO public.qr_codes VALUES (554, 'f09efb60-6cd7-4262-af44-cbe479b244ea', NULL, 'inactive', NULL, '2025-07-31 13:19:59.36451', '2025-07-31 13:19:59.36451');
INSERT INTO public.qr_codes VALUES (555, '9c49ec28-d2f9-4b7e-ab14-29308e18a4c1', NULL, 'inactive', NULL, '2025-07-31 13:19:59.365852', '2025-07-31 13:19:59.365852');
INSERT INTO public.qr_codes VALUES (556, '9eed72dd-c1d2-4b63-9b0e-42a146aee559', NULL, 'inactive', NULL, '2025-07-31 13:19:59.36722', '2025-07-31 13:19:59.36722');
INSERT INTO public.qr_codes VALUES (557, '779d1372-bb53-4608-b17b-2fd4316b9046', NULL, 'inactive', NULL, '2025-07-31 13:19:59.368578', '2025-07-31 13:19:59.368578');
INSERT INTO public.qr_codes VALUES (558, '6a729450-9780-45e9-99e4-b98ae6218ad2', NULL, 'inactive', NULL, '2025-07-31 13:19:59.369887', '2025-07-31 13:19:59.369887');
INSERT INTO public.qr_codes VALUES (559, '7dd978af-6921-48b9-bb11-4c90c7698fff', NULL, 'inactive', NULL, '2025-07-31 13:19:59.371291', '2025-07-31 13:19:59.371291');
INSERT INTO public.qr_codes VALUES (560, '9bd5b5f5-62cd-49aa-8b2d-5f0c982d01a8', NULL, 'inactive', NULL, '2025-07-31 13:19:59.372545', '2025-07-31 13:19:59.372545');
INSERT INTO public.qr_codes VALUES (561, '15681d0c-c4e7-484d-b2f3-4bba553b727e', NULL, 'inactive', NULL, '2025-07-31 13:19:59.375239', '2025-07-31 13:19:59.375239');
INSERT INTO public.qr_codes VALUES (562, '51c78f8f-3505-480f-9a91-ccdd1bcae615', NULL, 'inactive', NULL, '2025-07-31 13:19:59.376597', '2025-07-31 13:19:59.376597');
INSERT INTO public.qr_codes VALUES (563, '60f72933-3b64-476f-81e2-32609a9c50c0', NULL, 'inactive', NULL, '2025-07-31 13:19:59.377903', '2025-07-31 13:19:59.377903');
INSERT INTO public.qr_codes VALUES (564, 'ded89838-22ec-405a-a36d-6909c79d8dbd', NULL, 'inactive', NULL, '2025-07-31 13:19:59.379169', '2025-07-31 13:19:59.379169');
INSERT INTO public.qr_codes VALUES (565, '5efeab97-c145-442e-888c-0ee76166bb10', NULL, 'inactive', NULL, '2025-07-31 13:19:59.380458', '2025-07-31 13:19:59.380458');
INSERT INTO public.qr_codes VALUES (566, '6716dd49-ed4c-41ff-83b2-16b6ac9cd842', NULL, 'inactive', NULL, '2025-07-31 13:19:59.381763', '2025-07-31 13:19:59.381763');
INSERT INTO public.qr_codes VALUES (567, '54a8dcc1-9ab5-4c0f-9395-d24904abaaf0', NULL, 'inactive', NULL, '2025-07-31 13:19:59.383161', '2025-07-31 13:19:59.383161');
INSERT INTO public.qr_codes VALUES (568, '08e1803e-f857-4084-bfcb-346c71220523', NULL, 'inactive', NULL, '2025-07-31 13:19:59.384513', '2025-07-31 13:19:59.384513');
INSERT INTO public.qr_codes VALUES (569, 'a509fc3f-52d5-4ef9-bc62-a9d794a195d0', NULL, 'inactive', NULL, '2025-07-31 13:19:59.385758', '2025-07-31 13:19:59.385758');
INSERT INTO public.qr_codes VALUES (570, '9b9baae9-306b-4641-aadf-852a373d0be4', NULL, 'inactive', NULL, '2025-07-31 13:19:59.387142', '2025-07-31 13:19:59.387142');
INSERT INTO public.qr_codes VALUES (571, '66910c9b-2cf0-4410-968a-32033754df1f', NULL, 'inactive', NULL, '2025-07-31 13:19:59.388493', '2025-07-31 13:19:59.388493');
INSERT INTO public.qr_codes VALUES (572, '9e906efb-3a1f-477f-a78b-3d254b2f1fb9', NULL, 'inactive', NULL, '2025-07-31 13:19:59.389831', '2025-07-31 13:19:59.389831');
INSERT INTO public.qr_codes VALUES (573, '8320a0c1-06b4-44e6-95eb-db81f9112fa8', NULL, 'inactive', NULL, '2025-07-31 13:19:59.391214', '2025-07-31 13:19:59.391214');
INSERT INTO public.qr_codes VALUES (574, '52996dc6-a61f-4526-bf0f-575f4904b7d2', NULL, 'inactive', NULL, '2025-07-31 13:19:59.392542', '2025-07-31 13:19:59.392542');
INSERT INTO public.qr_codes VALUES (575, '2b82f4f6-4d22-4c43-ac44-ff3975749a92', NULL, 'inactive', NULL, '2025-07-31 13:19:59.393897', '2025-07-31 13:19:59.393897');
INSERT INTO public.qr_codes VALUES (576, '12c52aa6-df85-41f0-a01a-fef41406f74c', NULL, 'inactive', NULL, '2025-07-31 13:19:59.3953', '2025-07-31 13:19:59.3953');
INSERT INTO public.qr_codes VALUES (577, '15b0ea92-af03-4031-8773-e54ccb4fdaae', NULL, 'inactive', NULL, '2025-07-31 13:19:59.396662', '2025-07-31 13:19:59.396662');
INSERT INTO public.qr_codes VALUES (578, '9e0566cb-19d1-4686-bee0-65823c79d0c9', NULL, 'inactive', NULL, '2025-07-31 13:19:59.398064', '2025-07-31 13:19:59.398064');
INSERT INTO public.qr_codes VALUES (579, '486f130e-1de8-4094-9018-011c5c04113b', NULL, 'inactive', NULL, '2025-07-31 13:19:59.399405', '2025-07-31 13:19:59.399405');
INSERT INTO public.qr_codes VALUES (580, '83806cce-32cd-4118-a04f-fb774c28596c', NULL, 'inactive', NULL, '2025-07-31 13:19:59.400735', '2025-07-31 13:19:59.400735');
INSERT INTO public.qr_codes VALUES (581, 'fe0fa8a6-a3ec-45ff-8943-275600ace341', NULL, 'inactive', NULL, '2025-07-31 13:19:59.402109', '2025-07-31 13:19:59.402109');
INSERT INTO public.qr_codes VALUES (582, '0111901c-aadd-455d-9a11-494c4966d93e', NULL, 'inactive', NULL, '2025-07-31 13:19:59.403517', '2025-07-31 13:19:59.403517');
INSERT INTO public.qr_codes VALUES (583, 'bc71dfae-898c-41bd-83b1-b4d2a53476c3', NULL, 'inactive', NULL, '2025-07-31 13:19:59.404893', '2025-07-31 13:19:59.404893');
INSERT INTO public.qr_codes VALUES (584, '34e91e13-3024-4857-9cc6-f341954dc912', NULL, 'inactive', NULL, '2025-07-31 13:19:59.406421', '2025-07-31 13:19:59.406421');
INSERT INTO public.qr_codes VALUES (585, '70d77c7d-93c4-45e9-80fa-1e4b0b558d47', NULL, 'inactive', NULL, '2025-07-31 13:19:59.407689', '2025-07-31 13:19:59.407689');
INSERT INTO public.qr_codes VALUES (586, '3f641737-1246-4687-9567-966041c2367e', NULL, 'inactive', NULL, '2025-07-31 13:19:59.409059', '2025-07-31 13:19:59.409059');
INSERT INTO public.qr_codes VALUES (587, '10ad1650-7532-4542-bef3-d91cf7462782', NULL, 'inactive', NULL, '2025-07-31 13:20:57.627302', '2025-07-31 13:20:57.627302');
INSERT INTO public.qr_codes VALUES (588, '8f351ed8-650b-4bf0-871a-31eab968f7ee', NULL, 'inactive', NULL, '2025-07-31 13:20:57.629745', '2025-07-31 13:20:57.629745');
INSERT INTO public.qr_codes VALUES (589, '758250ce-8058-41e2-b9e1-03e9354fe714', NULL, 'inactive', NULL, '2025-07-31 13:20:57.631302', '2025-07-31 13:20:57.631302');
INSERT INTO public.qr_codes VALUES (590, '67673684-e3cc-47f8-8f58-08a1e5195e62', NULL, 'inactive', NULL, '2025-07-31 13:20:57.632788', '2025-07-31 13:20:57.632788');
INSERT INTO public.qr_codes VALUES (591, '6cf9e9bd-a5c4-4b2c-92da-ae1d65643a0d', NULL, 'inactive', NULL, '2025-07-31 13:20:57.63432', '2025-07-31 13:20:57.63432');
INSERT INTO public.qr_codes VALUES (592, '09adf518-c900-4710-b87a-ff13ca72c0df', NULL, 'inactive', NULL, '2025-07-31 13:20:57.63582', '2025-07-31 13:20:57.63582');
INSERT INTO public.qr_codes VALUES (593, 'd662178c-4f59-40e7-ba84-8e66144f5be4', NULL, 'inactive', NULL, '2025-07-31 13:20:57.63726', '2025-07-31 13:20:57.63726');
INSERT INTO public.qr_codes VALUES (594, '993c31d0-0c7a-4f92-ae01-52250e8a00cf', NULL, 'inactive', NULL, '2025-07-31 13:20:57.638704', '2025-07-31 13:20:57.638704');
INSERT INTO public.qr_codes VALUES (595, 'c11ebcaa-5dee-44c4-808b-48449bd48c2d', NULL, 'inactive', NULL, '2025-07-31 13:20:57.640337', '2025-07-31 13:20:57.640337');
INSERT INTO public.qr_codes VALUES (596, 'ab05e141-742a-459f-9f71-3d8ac7c56ccd', NULL, 'inactive', NULL, '2025-07-31 13:20:57.642106', '2025-07-31 13:20:57.642106');
INSERT INTO public.qr_codes VALUES (597, '7c2a379b-b678-4016-ad49-c7f1ada87763', NULL, 'inactive', NULL, '2025-07-31 13:20:57.643496', '2025-07-31 13:20:57.643496');
INSERT INTO public.qr_codes VALUES (598, 'ad424d53-a0a8-4826-8130-5a39282d3cad', NULL, 'inactive', NULL, '2025-07-31 13:20:57.644901', '2025-07-31 13:20:57.644901');
INSERT INTO public.qr_codes VALUES (599, '53f6c12d-0c79-4337-afce-e66310853b9c', NULL, 'inactive', NULL, '2025-07-31 13:20:57.646253', '2025-07-31 13:20:57.646253');
INSERT INTO public.qr_codes VALUES (600, '078edb24-16f7-4082-8073-df971d74be12', NULL, 'inactive', NULL, '2025-07-31 13:20:57.647697', '2025-07-31 13:20:57.647697');
INSERT INTO public.qr_codes VALUES (601, '053f7e75-9665-4a66-b623-769f6171bb05', NULL, 'inactive', NULL, '2025-07-31 13:20:57.649092', '2025-07-31 13:20:57.649092');
INSERT INTO public.qr_codes VALUES (602, '84832891-5fcc-4c92-addd-aa0491b27c03', NULL, 'inactive', NULL, '2025-07-31 13:20:57.650474', '2025-07-31 13:20:57.650474');
INSERT INTO public.qr_codes VALUES (603, 'a1075cd5-a0b8-4805-8d53-02af51fe49f8', NULL, 'inactive', NULL, '2025-07-31 13:20:57.651785', '2025-07-31 13:20:57.651785');
INSERT INTO public.qr_codes VALUES (604, '6404270e-e4f5-4f65-8561-2714d2412c29', NULL, 'inactive', NULL, '2025-07-31 13:20:57.65321', '2025-07-31 13:20:57.65321');
INSERT INTO public.qr_codes VALUES (605, 'abf62fcd-8c9b-4e28-a7ae-1e4810f26b70', NULL, 'inactive', NULL, '2025-07-31 13:20:57.654582', '2025-07-31 13:20:57.654582');
INSERT INTO public.qr_codes VALUES (606, '7352a82e-a55f-4d46-bfd2-a427ac394bd7', NULL, 'inactive', NULL, '2025-07-31 13:20:57.655901', '2025-07-31 13:20:57.655901');
INSERT INTO public.qr_codes VALUES (607, 'f82094a2-0d0f-4b53-a73c-e77109af1b52', NULL, 'inactive', NULL, '2025-07-31 13:20:57.65743', '2025-07-31 13:20:57.65743');
INSERT INTO public.qr_codes VALUES (608, '466df631-d49c-4644-8b9e-32730e5ab8c5', NULL, 'inactive', NULL, '2025-07-31 13:20:57.658877', '2025-07-31 13:20:57.658877');
INSERT INTO public.qr_codes VALUES (609, 'd6f0fe15-ba58-40bf-9da7-92bdc5aa934d', NULL, 'inactive', NULL, '2025-07-31 13:20:57.662365', '2025-07-31 13:20:57.662365');
INSERT INTO public.qr_codes VALUES (610, 'c9d5b808-41be-4068-8218-bcb44eadcdcc', NULL, 'inactive', NULL, '2025-07-31 13:20:57.66386', '2025-07-31 13:20:57.66386');
INSERT INTO public.qr_codes VALUES (611, '9080e4dc-83ad-4211-a869-e77abf7d2530', NULL, 'inactive', NULL, '2025-07-31 13:20:57.665303', '2025-07-31 13:20:57.665303');
INSERT INTO public.qr_codes VALUES (612, '4df86ff9-3fe5-4ee0-b555-619db14d629e', NULL, 'inactive', NULL, '2025-07-31 13:20:57.666712', '2025-07-31 13:20:57.666712');
INSERT INTO public.qr_codes VALUES (613, '086c5a4c-0911-4df9-adcd-a79282fe6346', NULL, 'inactive', NULL, '2025-07-31 13:20:57.668267', '2025-07-31 13:20:57.668267');
INSERT INTO public.qr_codes VALUES (614, '508a2cc1-855d-4e3d-84d7-7b6bbee3bc83', NULL, 'inactive', NULL, '2025-07-31 13:20:57.670482', '2025-07-31 13:20:57.670482');
INSERT INTO public.qr_codes VALUES (615, '9bab67e4-9eee-4a16-a981-08bb48f18b96', NULL, 'inactive', NULL, '2025-07-31 13:20:57.671909', '2025-07-31 13:20:57.671909');
INSERT INTO public.qr_codes VALUES (616, 'b440fe57-cd4e-4b7f-95bf-0c2936dd6abb', NULL, 'inactive', NULL, '2025-07-31 13:20:57.673248', '2025-07-31 13:20:57.673248');
INSERT INTO public.qr_codes VALUES (617, 'ed1f5a27-287f-461a-a875-2121633e153d', NULL, 'inactive', NULL, '2025-07-31 13:20:57.674605', '2025-07-31 13:20:57.674605');
INSERT INTO public.qr_codes VALUES (618, '560a619d-bdfd-4b57-a43a-05c12ac94a6b', NULL, 'inactive', NULL, '2025-07-31 13:20:57.675995', '2025-07-31 13:20:57.675995');
INSERT INTO public.qr_codes VALUES (619, 'f8a3e3c8-de3e-4021-9882-a28e7b843c63', NULL, 'inactive', NULL, '2025-07-31 13:20:57.677308', '2025-07-31 13:20:57.677308');
INSERT INTO public.qr_codes VALUES (620, '7873bd09-d082-4bad-9e9c-7e90bbebf179', NULL, 'inactive', NULL, '2025-07-31 13:20:57.678596', '2025-07-31 13:20:57.678596');
INSERT INTO public.qr_codes VALUES (621, 'bfc800f6-687b-4b71-a023-b34ae5f6224a', NULL, 'inactive', NULL, '2025-07-31 13:20:57.679898', '2025-07-31 13:20:57.679898');
INSERT INTO public.qr_codes VALUES (622, '8fc92e10-367a-47fd-9a29-3bff0ce22ccc', NULL, 'inactive', NULL, '2025-07-31 13:20:57.681315', '2025-07-31 13:20:57.681315');
INSERT INTO public.qr_codes VALUES (623, 'e77e3892-c07d-43a3-9e3f-2d4742079d6f', NULL, 'inactive', NULL, '2025-07-31 13:20:57.682634', '2025-07-31 13:20:57.682634');
INSERT INTO public.qr_codes VALUES (624, 'f39315ad-d1d9-49da-b9be-2bd56e259f6f', NULL, 'inactive', NULL, '2025-07-31 13:20:57.684133', '2025-07-31 13:20:57.684133');
INSERT INTO public.qr_codes VALUES (625, 'a3bc9ae8-d41c-465c-a737-bf19d5b004b7', NULL, 'inactive', NULL, '2025-07-31 13:20:57.685561', '2025-07-31 13:20:57.685561');
INSERT INTO public.qr_codes VALUES (626, '71d76f3a-ff78-4eb0-94b2-008676ad51fc', NULL, 'inactive', NULL, '2025-07-31 13:20:57.687113', '2025-07-31 13:20:57.687113');
INSERT INTO public.qr_codes VALUES (627, '273b7e9b-5bbb-46a6-9541-5eb7a5beee23', NULL, 'inactive', NULL, '2025-07-31 13:20:57.691364', '2025-07-31 13:20:57.691364');
INSERT INTO public.qr_codes VALUES (628, '77c3fe68-5aa7-42a1-baad-e59d98dff793', NULL, 'inactive', NULL, '2025-07-31 13:20:57.692862', '2025-07-31 13:20:57.692862');
INSERT INTO public.qr_codes VALUES (629, '3d366f4f-8e4a-4c2f-9c34-2e6f6bc2aee0', NULL, 'inactive', NULL, '2025-07-31 13:20:57.694748', '2025-07-31 13:20:57.694748');
INSERT INTO public.qr_codes VALUES (630, 'a42facbf-aa20-4ec1-9634-f0a8ad2d291a', NULL, 'inactive', NULL, '2025-07-31 13:20:57.696419', '2025-07-31 13:20:57.696419');
INSERT INTO public.qr_codes VALUES (631, '45a37f27-74ad-4bf7-a80e-fd62a66d2924', NULL, 'inactive', NULL, '2025-07-31 13:20:57.697916', '2025-07-31 13:20:57.697916');
INSERT INTO public.qr_codes VALUES (632, '52b6b68b-6ffd-4b21-a438-4a25326c4d1b', NULL, 'inactive', NULL, '2025-07-31 13:20:57.699363', '2025-07-31 13:20:57.699363');
INSERT INTO public.qr_codes VALUES (633, 'e95667fd-1280-40f8-9193-d50e2635946b', NULL, 'inactive', NULL, '2025-07-31 13:20:57.700827', '2025-07-31 13:20:57.700827');
INSERT INTO public.qr_codes VALUES (634, '8b95be33-d517-49b3-9b58-f99010aa5242', NULL, 'inactive', NULL, '2025-07-31 13:20:57.702324', '2025-07-31 13:20:57.702324');
INSERT INTO public.qr_codes VALUES (635, 'a5d8e42d-6745-4d79-a61c-f9ef3e5ebff0', NULL, 'inactive', NULL, '2025-07-31 13:20:57.703745', '2025-07-31 13:20:57.703745');
INSERT INTO public.qr_codes VALUES (636, 'f2c95745-99de-469b-9b1e-e16069aeafe6', NULL, 'inactive', NULL, '2025-07-31 13:20:57.705216', '2025-07-31 13:20:57.705216');
INSERT INTO public.qr_codes VALUES (637, 'ce06aa80-3d01-4217-a3bc-6879563de651', NULL, 'inactive', NULL, '2025-07-31 13:21:54.223742', '2025-07-31 13:21:54.223742');
INSERT INTO public.qr_codes VALUES (638, 'c08cdd7d-1c6b-4b93-91d7-a3650b179000', NULL, 'inactive', NULL, '2025-07-31 13:21:54.226134', '2025-07-31 13:21:54.226134');
INSERT INTO public.qr_codes VALUES (639, '67f2409a-e012-417a-9748-5ed7fefbcbde', NULL, 'inactive', NULL, '2025-07-31 13:21:54.227578', '2025-07-31 13:21:54.227578');
INSERT INTO public.qr_codes VALUES (640, 'b8c9faca-1076-4439-a18d-da8c160dd59c', NULL, 'inactive', NULL, '2025-07-31 13:21:54.228992', '2025-07-31 13:21:54.228992');
INSERT INTO public.qr_codes VALUES (641, 'ad611cea-f39e-4547-826c-453989da1493', NULL, 'inactive', NULL, '2025-07-31 13:21:54.230312', '2025-07-31 13:21:54.230312');
INSERT INTO public.qr_codes VALUES (642, '3c7efe00-9528-467e-902b-5fdc510bc0e3', NULL, 'inactive', NULL, '2025-07-31 13:21:54.231679', '2025-07-31 13:21:54.231679');
INSERT INTO public.qr_codes VALUES (643, '1a19b80b-31c1-4944-8e00-78dd70067c75', NULL, 'inactive', NULL, '2025-07-31 13:21:54.232959', '2025-07-31 13:21:54.232959');
INSERT INTO public.qr_codes VALUES (644, 'bd1da102-9aaf-4948-8664-07cfd9183d43', NULL, 'inactive', NULL, '2025-07-31 13:21:54.234363', '2025-07-31 13:21:54.234363');
INSERT INTO public.qr_codes VALUES (645, '57400119-b397-4f9a-a703-c9dffbd62821', NULL, 'inactive', NULL, '2025-07-31 13:21:54.235669', '2025-07-31 13:21:54.235669');
INSERT INTO public.qr_codes VALUES (646, '4b4a4881-4e08-4e51-adc8-5c8ecb89e619', NULL, 'inactive', NULL, '2025-07-31 13:21:54.237091', '2025-07-31 13:21:54.237091');
INSERT INTO public.qr_codes VALUES (647, '009318cc-976c-47fa-8ac8-696316b46499', NULL, 'inactive', NULL, '2025-07-31 13:21:54.239329', '2025-07-31 13:21:54.239329');
INSERT INTO public.qr_codes VALUES (648, 'e1ea6ea4-80ef-4d2b-b6b9-72cd4895a5d1', NULL, 'inactive', NULL, '2025-07-31 13:21:54.240707', '2025-07-31 13:21:54.240707');
INSERT INTO public.qr_codes VALUES (649, '401003f1-2a64-4674-9376-3cf0beaf64bd', NULL, 'inactive', NULL, '2025-07-31 13:21:54.242092', '2025-07-31 13:21:54.242092');
INSERT INTO public.qr_codes VALUES (650, '9c35c259-e1c3-4b6d-8558-a13f1169bd66', NULL, 'inactive', NULL, '2025-07-31 13:21:54.243557', '2025-07-31 13:21:54.243557');
INSERT INTO public.qr_codes VALUES (651, '23e49182-9680-48d6-a558-e94ec25e00a5', NULL, 'inactive', NULL, '2025-07-31 13:21:54.244878', '2025-07-31 13:21:54.244878');
INSERT INTO public.qr_codes VALUES (652, 'a41fefa4-9e3c-489d-abe6-df42a48d98df', NULL, 'inactive', NULL, '2025-07-31 13:21:54.246152', '2025-07-31 13:21:54.246152');
INSERT INTO public.qr_codes VALUES (653, '61ef4927-338e-4f2e-aac1-8fa640f5ad62', NULL, 'inactive', NULL, '2025-07-31 13:21:54.247439', '2025-07-31 13:21:54.247439');
INSERT INTO public.qr_codes VALUES (654, '6ec79c77-15d3-47e6-b638-ce0d07a60e6f', NULL, 'inactive', NULL, '2025-07-31 13:21:54.248779', '2025-07-31 13:21:54.248779');
INSERT INTO public.qr_codes VALUES (655, 'e7d18ef0-a4b6-4883-9deb-450fd97c31bd', NULL, 'inactive', NULL, '2025-07-31 13:21:54.250111', '2025-07-31 13:21:54.250111');
INSERT INTO public.qr_codes VALUES (656, '231bae34-b920-4a17-9695-9d5fe015d541', NULL, 'inactive', NULL, '2025-07-31 13:21:54.251422', '2025-07-31 13:21:54.251422');
INSERT INTO public.qr_codes VALUES (657, '4bf63f64-b08a-499f-9910-cbc842221717', NULL, 'inactive', NULL, '2025-07-31 13:21:54.252725', '2025-07-31 13:21:54.252725');
INSERT INTO public.qr_codes VALUES (658, '7baed89b-f01d-4737-a11b-ce31edc60040', NULL, 'inactive', NULL, '2025-07-31 13:21:54.253961', '2025-07-31 13:21:54.253961');
INSERT INTO public.qr_codes VALUES (659, 'febf2b6a-600f-4f98-9163-4f5726446944', NULL, 'inactive', NULL, '2025-07-31 13:21:54.255221', '2025-07-31 13:21:54.255221');
INSERT INTO public.qr_codes VALUES (660, '466c03c2-d0eb-435a-9fab-e9b0a8ebfbbd', NULL, 'inactive', NULL, '2025-07-31 13:21:54.256485', '2025-07-31 13:21:54.256485');
INSERT INTO public.qr_codes VALUES (661, '3363a0f0-cf0c-4e0d-95cc-d201bb019d2e', NULL, 'inactive', NULL, '2025-07-31 13:21:54.257811', '2025-07-31 13:21:54.257811');
INSERT INTO public.qr_codes VALUES (662, '43fffb76-ed40-419d-be13-e85ad21bdb1d', NULL, 'inactive', NULL, '2025-07-31 13:22:37.22865', '2025-07-31 13:22:37.22865');
INSERT INTO public.qr_codes VALUES (667, '4bf16f5b-7b10-4a26-bf01-0bfa54449cb3', NULL, 'inactive', NULL, '2025-07-31 13:22:37.238081', '2025-07-31 13:22:37.238081');
INSERT INTO public.qr_codes VALUES (672, '75162943-b38f-4e49-b546-7d82c130f3b7', NULL, 'inactive', NULL, '2025-07-31 13:25:49.013669', '2025-07-31 13:25:49.013669');
INSERT INTO public.qr_codes VALUES (673, 'ad3c06ae-7a72-4708-a6d0-6a8c1ba4b3e8', NULL, 'inactive', NULL, '2025-07-31 13:25:49.018355', '2025-07-31 13:25:49.018355');
INSERT INTO public.qr_codes VALUES (674, '713c7492-7197-485e-81d6-8afb5b13bfdc', NULL, 'inactive', NULL, '2025-07-31 13:25:49.019875', '2025-07-31 13:25:49.019875');
INSERT INTO public.qr_codes VALUES (675, '58656116-b1e0-49e2-8dd9-4d31c87b9b64', NULL, 'inactive', NULL, '2025-07-31 13:25:49.021393', '2025-07-31 13:25:49.021393');
INSERT INTO public.qr_codes VALUES (676, '6e565e7d-6f66-4b25-8cdf-75705108073b', NULL, 'inactive', NULL, '2025-07-31 13:25:49.023592', '2025-07-31 13:25:49.023592');
INSERT INTO public.qr_codes VALUES (677, 'bc9b1a92-cb29-4873-b78c-849d4b4bc834', NULL, 'inactive', NULL, '2025-07-31 13:25:49.02505', '2025-07-31 13:25:49.02505');
INSERT INTO public.qr_codes VALUES (678, '1b986bab-3c38-4929-9002-699aa0c14696', NULL, 'inactive', NULL, '2025-07-31 13:25:49.026469', '2025-07-31 13:25:49.026469');
INSERT INTO public.qr_codes VALUES (679, '190e1110-2cc3-448b-a306-35bd0884423d', NULL, 'inactive', NULL, '2025-07-31 13:25:49.028698', '2025-07-31 13:25:49.028698');
INSERT INTO public.qr_codes VALUES (680, '41afc47e-9412-4805-b803-07d0756f2458', NULL, 'inactive', NULL, '2025-07-31 13:25:49.030063', '2025-07-31 13:25:49.030063');
INSERT INTO public.qr_codes VALUES (681, '11ff8304-ee15-443c-b9c4-5a05d0e8348b', NULL, 'inactive', NULL, '2025-07-31 13:25:49.031545', '2025-07-31 13:25:49.031545');
INSERT INTO public.qr_codes VALUES (682, '37e2846f-224d-4ec3-b61c-f6176fdf270e', NULL, 'inactive', NULL, '2025-07-31 13:25:49.032917', '2025-07-31 13:25:49.032917');
INSERT INTO public.qr_codes VALUES (683, '64cfc3bf-1019-40af-b504-c4c0eea91077', NULL, 'inactive', NULL, '2025-07-31 13:25:49.034286', '2025-07-31 13:25:49.034286');
INSERT INTO public.qr_codes VALUES (684, 'c2483b42-ef78-4b22-837c-ab09a3b66976', NULL, 'inactive', NULL, '2025-07-31 13:25:49.035682', '2025-07-31 13:25:49.035682');
INSERT INTO public.qr_codes VALUES (685, 'a2ec6553-8212-4d0b-b55b-bef61c83478f', NULL, 'inactive', NULL, '2025-07-31 13:25:49.037051', '2025-07-31 13:25:49.037051');
INSERT INTO public.qr_codes VALUES (686, '2b92c2c2-a772-43fe-ae42-52758e6d803e', NULL, 'inactive', NULL, '2025-07-31 13:25:49.038365', '2025-07-31 13:25:49.038365');
INSERT INTO public.qr_codes VALUES (687, 'b3b254c1-8dab-4ba9-81d8-e1a52d32c5b4', NULL, 'inactive', NULL, '2025-07-31 13:25:49.039695', '2025-07-31 13:25:49.039695');
INSERT INTO public.qr_codes VALUES (688, '28ac44ca-7fe5-43f7-951f-7198b60807e0', NULL, 'inactive', NULL, '2025-07-31 13:25:49.040967', '2025-07-31 13:25:49.040967');
INSERT INTO public.qr_codes VALUES (671, 'd8473ce8-caf7-4469-85f3-99813e2e239d', 56, 'active', '2025-08-10 11:51:33.190609', '2025-07-31 13:22:37.243736', '2025-08-10 11:51:33.190609');
INSERT INTO public.qr_codes VALUES (669, '2a75dede-34e8-4790-8b37-50ffa1dbdff1', 57, 'active', '2025-08-14 13:58:19.100634', '2025-07-31 13:22:37.240878', '2025-08-14 13:58:19.100634');
INSERT INTO public.qr_codes VALUES (668, '08e4bba5-1506-4b04-93b3-37620367e70c', 58, 'active', '2025-08-25 15:34:33.443227', '2025-07-31 13:22:37.239496', '2025-08-25 15:34:33.443227');
INSERT INTO public.qr_codes VALUES (665, '0cea3800-5c09-4a72-8c7e-1a2123cab414', 59, 'active', '2025-08-26 05:40:33.420417', '2025-07-31 13:22:37.235167', '2025-08-26 05:40:33.420417');
INSERT INTO public.qr_codes VALUES (663, '5053b73e-d099-405c-8cc5-d713b9c7b1ce', 60, 'active', '2025-08-27 16:33:14.278471', '2025-07-31 13:22:37.231202', '2025-08-27 16:33:14.278471');
INSERT INTO public.qr_codes VALUES (666, 'ee74592f-94b7-418d-8039-91b380009124', 65, 'active', '2025-09-01 15:03:33.937539', '2025-07-31 13:22:37.236686', '2025-09-01 15:03:33.937539');
INSERT INTO public.qr_codes VALUES (689, '70fd31ee-b243-4d56-b679-12d74523301d', NULL, 'inactive', NULL, '2025-07-31 13:25:49.04222', '2025-07-31 13:25:49.04222');
INSERT INTO public.qr_codes VALUES (690, 'a0c2795f-4b70-41c3-ad4d-91a75091bd9b', NULL, 'inactive', NULL, '2025-07-31 13:25:49.044629', '2025-07-31 13:25:49.044629');
INSERT INTO public.qr_codes VALUES (691, 'da2f9569-3c66-4b92-955a-69003eb802f3', NULL, 'inactive', NULL, '2025-07-31 13:25:49.045981', '2025-07-31 13:25:49.045981');
INSERT INTO public.qr_codes VALUES (692, '874d54cc-75ae-4862-b161-7fb2aca942f6', NULL, 'inactive', NULL, '2025-07-31 13:25:49.047418', '2025-07-31 13:25:49.047418');
INSERT INTO public.qr_codes VALUES (693, 'b6f6c599-048c-4e88-8761-069757050f68', NULL, 'inactive', NULL, '2025-07-31 13:25:49.048765', '2025-07-31 13:25:49.048765');
INSERT INTO public.qr_codes VALUES (694, 'bd92ae4f-e3bf-4019-9837-c37565d24bfd', NULL, 'inactive', NULL, '2025-07-31 13:25:49.050043', '2025-07-31 13:25:49.050043');
INSERT INTO public.qr_codes VALUES (695, 'c5d80682-5c6b-424b-bfe1-288482b2fc8c', NULL, 'inactive', NULL, '2025-07-31 13:25:49.051388', '2025-07-31 13:25:49.051388');
INSERT INTO public.qr_codes VALUES (696, 'eb953842-2abb-4072-bb4e-e35b0000d35f', NULL, 'inactive', NULL, '2025-07-31 13:25:49.052713', '2025-07-31 13:25:49.052713');
INSERT INTO public.qr_codes VALUES (697, '6a6816a6-c404-458d-8b29-a54b3af5d0de', NULL, 'inactive', NULL, '2025-07-31 13:25:49.054135', '2025-07-31 13:25:49.054135');
INSERT INTO public.qr_codes VALUES (698, '3bb0adea-d008-4447-bc70-d791e22bd34e', NULL, 'inactive', NULL, '2025-07-31 13:25:49.055389', '2025-07-31 13:25:49.055389');
INSERT INTO public.qr_codes VALUES (699, '4c0be979-21b0-42e6-afc5-dd45862febcd', NULL, 'inactive', NULL, '2025-07-31 13:25:49.056737', '2025-07-31 13:25:49.056737');
INSERT INTO public.qr_codes VALUES (700, '9ff34dc7-4f7b-4386-9968-aab867a97aa3', NULL, 'inactive', NULL, '2025-07-31 13:25:49.058142', '2025-07-31 13:25:49.058142');
INSERT INTO public.qr_codes VALUES (701, '7d82af3c-ea0d-4fef-8d22-4ad1263dc3a8', NULL, 'inactive', NULL, '2025-07-31 13:25:49.059586', '2025-07-31 13:25:49.059586');
INSERT INTO public.qr_codes VALUES (702, 'df12ba6c-ee71-4045-b097-35240b6ecadc', NULL, 'inactive', NULL, '2025-07-31 13:25:49.060905', '2025-07-31 13:25:49.060905');
INSERT INTO public.qr_codes VALUES (703, 'be38667f-b7e8-4c01-bb3a-ad2da5ef0261', NULL, 'inactive', NULL, '2025-07-31 13:25:49.062218', '2025-07-31 13:25:49.062218');
INSERT INTO public.qr_codes VALUES (704, '685f09f8-9475-4cd7-b6cd-2026ca3d4ae4', NULL, 'inactive', NULL, '2025-07-31 13:25:49.063516', '2025-07-31 13:25:49.063516');
INSERT INTO public.qr_codes VALUES (705, '1855ab25-5465-4a54-b0f2-864078e274df', NULL, 'inactive', NULL, '2025-07-31 13:25:49.064852', '2025-07-31 13:25:49.064852');
INSERT INTO public.qr_codes VALUES (706, '4d7fc88d-0a7d-46ed-b690-1875586a0ff3', NULL, 'inactive', NULL, '2025-07-31 13:25:49.066187', '2025-07-31 13:25:49.066187');
INSERT INTO public.qr_codes VALUES (707, '623b2dc1-5ab6-4e86-97fd-e48b0ca88c5e', NULL, 'inactive', NULL, '2025-07-31 13:25:49.067492', '2025-07-31 13:25:49.067492');
INSERT INTO public.qr_codes VALUES (708, 'b7f8d8d9-2dfa-44c9-8801-03aef3131a02', NULL, 'inactive', NULL, '2025-07-31 13:25:49.068762', '2025-07-31 13:25:49.068762');
INSERT INTO public.qr_codes VALUES (709, '2217dd7b-ef88-4cd5-aada-5ec819e35ef0', NULL, 'inactive', NULL, '2025-07-31 13:25:49.070114', '2025-07-31 13:25:49.070114');
INSERT INTO public.qr_codes VALUES (710, '620ba6e9-b57f-4618-9247-83757004fd0c', NULL, 'inactive', NULL, '2025-07-31 13:25:49.071363', '2025-07-31 13:25:49.071363');
INSERT INTO public.qr_codes VALUES (711, '20a93cc9-de36-4866-aa27-9787c5983f7b', NULL, 'inactive', NULL, '2025-07-31 13:25:49.072788', '2025-07-31 13:25:49.072788');
INSERT INTO public.qr_codes VALUES (712, '5203aabe-e1af-4b06-8121-5462ffb2b044', NULL, 'inactive', NULL, '2025-07-31 13:25:49.074231', '2025-07-31 13:25:49.074231');
INSERT INTO public.qr_codes VALUES (713, 'b0c0bae5-43d3-4062-b2c6-dee738d64fca', NULL, 'inactive', NULL, '2025-07-31 13:25:49.07555', '2025-07-31 13:25:49.07555');
INSERT INTO public.qr_codes VALUES (714, '67575587-a5e9-4890-9b97-92fd2b47772b', NULL, 'inactive', NULL, '2025-07-31 13:25:49.076995', '2025-07-31 13:25:49.076995');
INSERT INTO public.qr_codes VALUES (715, '64859565-82ec-42d7-ac3b-2e7235c3e9ac', NULL, 'inactive', NULL, '2025-07-31 13:25:49.080645', '2025-07-31 13:25:49.080645');
INSERT INTO public.qr_codes VALUES (716, '64673b16-b6b2-4e05-b40d-dd48468e4551', NULL, 'inactive', NULL, '2025-07-31 13:25:49.082137', '2025-07-31 13:25:49.082137');
INSERT INTO public.qr_codes VALUES (717, 'ef31a044-8fe0-4ad2-b155-8d6d814b8955', NULL, 'inactive', NULL, '2025-07-31 13:25:49.083585', '2025-07-31 13:25:49.083585');
INSERT INTO public.qr_codes VALUES (718, '68c21102-4aa1-475d-8ffe-9cc4838ddfa9', NULL, 'inactive', NULL, '2025-07-31 13:25:49.087333', '2025-07-31 13:25:49.087333');
INSERT INTO public.qr_codes VALUES (719, '8ba452f9-2989-48e3-8de9-f7b032189ef7', NULL, 'inactive', NULL, '2025-07-31 13:25:49.088812', '2025-07-31 13:25:49.088812');
INSERT INTO public.qr_codes VALUES (720, 'f747a238-3e8e-4702-b8ac-f34771022a0a', NULL, 'inactive', NULL, '2025-07-31 13:25:49.090213', '2025-07-31 13:25:49.090213');
INSERT INTO public.qr_codes VALUES (721, 'c59d8a85-7be1-42b0-beea-48fec48dd2f7', NULL, 'inactive', NULL, '2025-07-31 13:25:49.091553', '2025-07-31 13:25:49.091553');
INSERT INTO public.qr_codes VALUES (722, 'fa30a9f9-8a59-4ad1-a686-3b57ae6e32cf', NULL, 'inactive', NULL, '2025-07-31 13:26:07.913949', '2025-07-31 13:26:07.913949');
INSERT INTO public.qr_codes VALUES (723, '73ec92e4-dd6b-41c1-9f89-d3882638be6a', NULL, 'inactive', NULL, '2025-07-31 13:26:07.916412', '2025-07-31 13:26:07.916412');
INSERT INTO public.qr_codes VALUES (724, '02a13130-9d35-4d52-88c2-855500434387', NULL, 'inactive', NULL, '2025-07-31 13:26:07.917908', '2025-07-31 13:26:07.917908');
INSERT INTO public.qr_codes VALUES (725, '42f191c2-8be9-4e3b-b71c-8b0d85fb5880', NULL, 'inactive', NULL, '2025-07-31 13:26:07.91928', '2025-07-31 13:26:07.91928');
INSERT INTO public.qr_codes VALUES (728, '3aa03806-ba83-4881-9512-c86d39059365', NULL, 'inactive', NULL, '2025-07-31 13:26:07.923267', '2025-07-31 13:26:07.923267');
INSERT INTO public.qr_codes VALUES (729, 'fd0f0d26-4f85-4c65-8680-6dd9d2685644', NULL, 'inactive', NULL, '2025-07-31 13:26:07.924597', '2025-07-31 13:26:07.924597');
INSERT INTO public.qr_codes VALUES (731, 'c95abb1b-1b43-49d7-aeb7-5a341eff5053', NULL, 'inactive', NULL, '2025-07-31 13:26:07.927383', '2025-07-31 13:26:07.927383');
INSERT INTO public.qr_codes VALUES (753, '8505e25c-6a72-43c9-890d-64afe7f882b6', NULL, 'inactive', NULL, '2025-07-31 13:27:32.55813', '2025-07-31 13:27:32.55813');
INSERT INTO public.qr_codes VALUES (754, '1ef7fa0c-9011-411c-93c1-1cf285d9f678', NULL, 'inactive', NULL, '2025-07-31 13:27:32.559465', '2025-07-31 13:27:32.559465');
INSERT INTO public.qr_codes VALUES (755, '937e4dd1-539b-4dcf-9957-c6159479d4fc', NULL, 'inactive', NULL, '2025-07-31 13:27:32.560736', '2025-07-31 13:27:32.560736');
INSERT INTO public.qr_codes VALUES (756, '36a7175e-64da-416e-b267-4d7670de9826', NULL, 'inactive', NULL, '2025-07-31 13:27:32.562078', '2025-07-31 13:27:32.562078');
INSERT INTO public.qr_codes VALUES (757, '2e596444-357d-485f-8d14-efe26adb8313', NULL, 'inactive', NULL, '2025-07-31 13:27:32.563402', '2025-07-31 13:27:32.563402');
INSERT INTO public.qr_codes VALUES (758, 'c8c4bb50-21e5-4ccb-9c80-9ae03496f021', NULL, 'inactive', NULL, '2025-07-31 13:27:32.564699', '2025-07-31 13:27:32.564699');
INSERT INTO public.qr_codes VALUES (759, 'ec71bc02-a700-493d-9528-22876be7e3a8', NULL, 'inactive', NULL, '2025-07-31 13:27:32.565939', '2025-07-31 13:27:32.565939');
INSERT INTO public.qr_codes VALUES (760, '6bd5e436-50df-4747-b99c-96f65d63832e', NULL, 'inactive', NULL, '2025-07-31 13:27:32.56729', '2025-07-31 13:27:32.56729');
INSERT INTO public.qr_codes VALUES (761, 'db05c1c0-200f-4031-b330-26841d6feabd', NULL, 'inactive', NULL, '2025-07-31 13:27:32.568652', '2025-07-31 13:27:32.568652');
INSERT INTO public.qr_codes VALUES (747, '35e08e01-39da-4acf-8a07-24931394801e', 30, 'active', '2025-07-31 14:12:21.709673', '2025-07-31 13:27:32.548236', '2025-07-31 14:12:21.709673');
INSERT INTO public.qr_codes VALUES (751, '8f4899aa-e118-4fa2-bc24-952641ee7abe', 31, 'active', '2025-07-31 15:01:12.664691', '2025-07-31 13:27:32.555023', '2025-07-31 15:01:12.664691');
INSERT INTO public.qr_codes VALUES (762, 'cc7f8eb9-c22f-4d87-84d6-af8c86ce37bc', NULL, 'inactive', NULL, '2025-07-31 16:36:23.98059', '2025-07-31 16:36:23.98059');
INSERT INTO public.qr_codes VALUES (763, '08f96af5-d2fe-4018-86d1-5ac7d7b41fa7', NULL, 'inactive', NULL, '2025-07-31 16:36:23.983854', '2025-07-31 16:36:23.983854');
INSERT INTO public.qr_codes VALUES (764, '8c161b2e-1e5e-4530-9210-2ec418e706cf', NULL, 'inactive', NULL, '2025-07-31 16:36:23.985407', '2025-07-31 16:36:23.985407');
INSERT INTO public.qr_codes VALUES (765, '2ca7bc11-9f0b-4c10-8fd9-e1a7f75f718f', NULL, 'inactive', NULL, '2025-07-31 16:36:23.986773', '2025-07-31 16:36:23.986773');
INSERT INTO public.qr_codes VALUES (766, '38ddebd8-6af9-4714-9b02-3ce29fabcb6f', NULL, 'inactive', NULL, '2025-07-31 16:36:23.988207', '2025-07-31 16:36:23.988207');
INSERT INTO public.qr_codes VALUES (767, 'a8dd9350-a60e-464c-ae73-6b0fc12b098f', NULL, 'inactive', NULL, '2025-07-31 16:36:23.98955', '2025-07-31 16:36:23.98955');
INSERT INTO public.qr_codes VALUES (768, 'a105a50a-aa11-4ea5-bc34-025f0155ddb8', NULL, 'inactive', NULL, '2025-07-31 16:36:23.991618', '2025-07-31 16:36:23.991618');
INSERT INTO public.qr_codes VALUES (769, '12fc7f02-2a09-4af4-8210-a48b3474474f', NULL, 'inactive', NULL, '2025-07-31 16:36:23.99288', '2025-07-31 16:36:23.99288');
INSERT INTO public.qr_codes VALUES (741, 'a2c40ab8-df73-4d96-ad9b-a640177938e2', 33, 'active', '2025-08-01 13:34:08.157292', '2025-07-31 13:26:57.511327', '2025-08-01 13:34:08.157292');
INSERT INTO public.qr_codes VALUES (736, '08747d93-a41f-4543-ba0f-59d5e70e41bd', 34, 'active', '2025-08-01 13:45:16.344583', '2025-07-31 13:26:57.503896', '2025-08-01 13:45:16.344583');
INSERT INTO public.qr_codes VALUES (737, '1b2c9cca-4eea-4abc-8cd9-03d84db4b13f', 35, 'active', '2025-08-01 14:34:17.504008', '2025-07-31 13:26:57.505355', '2025-08-01 14:34:17.504008');
INSERT INTO public.qr_codes VALUES (735, '6e484c51-6ab8-48e2-9b7d-c8d7c03df2f8', 37, 'active', '2025-08-01 18:29:54.503715', '2025-07-31 13:26:57.502447', '2025-08-01 18:29:54.503715');
INSERT INTO public.qr_codes VALUES (743, '417c8117-3b4a-4f81-a260-f595238429c4', 38, 'active', '2025-08-01 18:32:43.269239', '2025-07-31 13:26:57.514105', '2025-08-01 18:32:43.269239');
INSERT INTO public.qr_codes VALUES (740, '0e54196a-97f8-4e2b-b04f-fa008e52fb1c', 39, 'active', '2025-08-01 18:36:16.453201', '2025-07-31 13:26:57.509897', '2025-08-01 18:36:16.453201');
INSERT INTO public.qr_codes VALUES (734, 'b76e1e18-ae9e-4c6a-9da7-701c91f979f5', 40, 'active', '2025-08-01 18:38:00.127156', '2025-07-31 13:26:57.500825', '2025-08-01 18:38:00.127156');
INSERT INTO public.qr_codes VALUES (739, 'b9054872-40d8-4419-817d-c6df478df981', 41, 'active', '2025-08-02 03:22:36.986947', '2025-07-31 13:26:57.508544', '2025-08-02 03:22:36.986947');
INSERT INTO public.qr_codes VALUES (738, 'a36f2317-a384-493a-add7-a1e613257270', 42, 'active', '2025-08-02 03:25:19.476356', '2025-07-31 13:26:57.506788', '2025-08-02 03:25:19.476356');
INSERT INTO public.qr_codes VALUES (732, '89852814-ad35-4efd-876e-ddf83646473b', 43, 'active', '2025-08-02 03:27:38.561873', '2025-07-31 13:26:57.496887', '2025-08-02 03:27:38.561873');
INSERT INTO public.qr_codes VALUES (750, 'e81f35ed-2afb-4aa0-b992-71458bf0a2ab', 44, 'active', '2025-08-02 03:29:12.589469', '2025-07-31 13:27:32.553595', '2025-08-02 03:29:12.589469');
INSERT INTO public.qr_codes VALUES (752, '1ffbba55-fc11-4a4d-afc8-86f566299d6f', 47, 'active', '2025-08-02 12:42:42.286752', '2025-07-31 13:27:32.556632', '2025-08-02 12:42:42.286752');
INSERT INTO public.qr_codes VALUES (746, '614573a0-dc83-4a23-be70-44c113150c9f', 49, 'active', '2025-08-02 13:26:40.830109', '2025-07-31 13:26:57.518003', '2025-08-02 13:26:40.830109');
INSERT INTO public.qr_codes VALUES (749, '0ac26d37-fb97-4965-9c45-7529d6350c86', 48, 'active', '2025-08-05 12:59:04.301769', '2025-07-31 13:27:32.552247', '2025-08-05 12:59:04.301769');
INSERT INTO public.qr_codes VALUES (730, '5865ea64-3696-41d3-ab49-bed1745627b5', 50, 'active', '2025-08-05 13:43:26.028193', '2025-07-31 13:26:07.92602', '2025-08-05 13:43:26.028193');
INSERT INTO public.qr_codes VALUES (727, 'ca6f0164-2882-4e09-bc1c-7cab4989c359', 51, 'active', '2025-08-05 16:37:46.529273', '2025-07-31 13:26:07.921871', '2025-08-05 16:37:46.529273');
INSERT INTO public.qr_codes VALUES (726, 'fed0a1d4-8caf-4f44-978c-aa977e7ba714', 52, 'active', '2025-08-05 16:59:04.885609', '2025-07-31 13:26:07.920565', '2025-08-05 16:59:04.885609');
INSERT INTO public.qr_codes VALUES (744, '7cecd37d-1418-4101-8797-7e2eb13c0161', 53, 'active', '2025-08-06 12:24:36.245336', '2025-07-31 13:26:57.515375', '2025-08-06 12:24:36.245336');
INSERT INTO public.qr_codes VALUES (745, '7cafe796-389e-49df-ae76-617a0782b802', 55, 'active', '2025-08-10 06:30:57.656262', '2025-07-31 13:26:57.516687', '2025-08-10 06:30:57.656262');
INSERT INTO public.qr_codes VALUES (770, 'b04b35ff-b29b-4c5e-9939-4d065eef201b', NULL, 'inactive', NULL, '2025-07-31 16:36:23.994249', '2025-07-31 16:36:23.994249');
INSERT INTO public.qr_codes VALUES (771, '129f4f1b-fdc7-4232-af7b-3616462cc15c', NULL, 'inactive', NULL, '2025-07-31 16:36:23.996508', '2025-07-31 16:36:23.996508');
INSERT INTO public.qr_codes VALUES (772, '2a26daf8-1886-489a-85b6-07e865aeb2aa', NULL, 'inactive', NULL, '2025-07-31 16:36:23.997825', '2025-07-31 16:36:23.997825');
INSERT INTO public.qr_codes VALUES (773, 'a80e3873-de19-4117-8bd7-688561a05bb2', NULL, 'inactive', NULL, '2025-07-31 16:36:23.999208', '2025-07-31 16:36:23.999208');
INSERT INTO public.qr_codes VALUES (774, '8d09ce7c-c812-470b-9114-5151b7a9bd29', NULL, 'inactive', NULL, '2025-07-31 16:36:24.000583', '2025-07-31 16:36:24.000583');
INSERT INTO public.qr_codes VALUES (775, 'a62c1954-32cd-4012-9834-e08e0ac40ba1', NULL, 'inactive', NULL, '2025-07-31 16:36:24.003348', '2025-07-31 16:36:24.003348');
INSERT INTO public.qr_codes VALUES (776, 'fce0eb65-66d5-48ed-a5c4-57f4963e3b78', NULL, 'inactive', NULL, '2025-07-31 16:36:24.004834', '2025-07-31 16:36:24.004834');
INSERT INTO public.qr_codes VALUES (777, '60fc6005-d5ce-4d81-bafb-fc2a9eab774b', NULL, 'inactive', NULL, '2025-07-31 16:36:24.006334', '2025-07-31 16:36:24.006334');
INSERT INTO public.qr_codes VALUES (778, 'ee5140c4-8db7-4a31-8d43-7cfbfb739683', NULL, 'inactive', NULL, '2025-07-31 16:36:24.009306', '2025-07-31 16:36:24.009306');
INSERT INTO public.qr_codes VALUES (779, 'c6d0afb6-a8c6-4120-846d-1f04ca7b5b53', NULL, 'inactive', NULL, '2025-07-31 16:36:24.010645', '2025-07-31 16:36:24.010645');
INSERT INTO public.qr_codes VALUES (780, 'd2ccf758-f639-45db-a917-11b160029502', NULL, 'inactive', NULL, '2025-07-31 16:36:24.01207', '2025-07-31 16:36:24.01207');
INSERT INTO public.qr_codes VALUES (781, '0862d0ec-4cae-467c-b977-d439920e2655', NULL, 'inactive', NULL, '2025-07-31 16:36:24.013473', '2025-07-31 16:36:24.013473');
INSERT INTO public.qr_codes VALUES (782, '8c269ce5-48aa-4f89-8673-009cab5bd185', NULL, 'inactive', NULL, '2025-07-31 16:36:24.014944', '2025-07-31 16:36:24.014944');
INSERT INTO public.qr_codes VALUES (783, '5a7a4f6b-0857-4fe8-9d74-ec4df1b583ce', NULL, 'inactive', NULL, '2025-07-31 16:36:24.01633', '2025-07-31 16:36:24.01633');
INSERT INTO public.qr_codes VALUES (784, 'fdad5c3c-d583-4600-a64f-5da95646cef4', NULL, 'inactive', NULL, '2025-07-31 16:36:24.017738', '2025-07-31 16:36:24.017738');
INSERT INTO public.qr_codes VALUES (785, 'eb54d8d4-e26e-4664-ac53-0d86c2fd5e67', NULL, 'inactive', NULL, '2025-07-31 16:36:24.019328', '2025-07-31 16:36:24.019328');
INSERT INTO public.qr_codes VALUES (786, 'c1c933d4-444c-4c2e-a447-f8aa3c8e70f7', NULL, 'inactive', NULL, '2025-07-31 16:36:24.02069', '2025-07-31 16:36:24.02069');
INSERT INTO public.qr_codes VALUES (742, 'b5f68751-5eb0-4f0b-9cd0-5f7a2d62d520', 32, 'active', '2025-08-01 13:24:47.475211', '2025-07-31 13:26:57.512727', '2025-08-01 13:24:47.475211');
INSERT INTO public.qr_codes VALUES (733, 'fdb43e55-31fc-4a0a-8de2-e6c879247ae3', 36, 'active', '2025-08-01 15:30:32.999456', '2025-07-31 13:26:57.499339', '2025-08-01 15:30:32.999456');
INSERT INTO public.qr_codes VALUES (748, 'dfb1fae2-b116-440d-8a3b-06083b07f4b6', 45, 'active', '2025-08-02 03:31:16.28487', '2025-07-31 13:27:32.550705', '2025-08-02 03:31:16.28487');
INSERT INTO public.qr_codes VALUES (787, '9f914600-71c5-4cb4-8e1f-5ead42cfb113', NULL, 'inactive', NULL, '2025-08-04 20:14:04.87224', '2025-08-04 20:14:04.87224');
INSERT INTO public.qr_codes VALUES (788, 'cc650db0-0f65-40fa-a8fe-d5c4e6bb2e83', NULL, 'inactive', NULL, '2025-08-04 20:14:04.879775', '2025-08-04 20:14:04.879775');
INSERT INTO public.qr_codes VALUES (789, 'e63afd2d-0d07-40fa-96d7-58099ca48469', NULL, 'inactive', NULL, '2025-08-04 20:14:29.456838', '2025-08-04 20:14:29.456838');
INSERT INTO public.qr_codes VALUES (790, 'a5e78d37-9c4c-4f33-93c1-a007b8394f1d', NULL, 'inactive', NULL, '2025-08-04 20:14:29.459997', '2025-08-04 20:14:29.459997');
INSERT INTO public.qr_codes VALUES (791, 'e2a27b2d-09d2-4b4f-8296-b9b75b30bc99', NULL, 'inactive', NULL, '2025-08-05 05:52:57.912147', '2025-08-05 05:52:57.912147');
INSERT INTO public.qr_codes VALUES (792, '0be021ee-90dd-4a28-9ed9-ac2363521d88', NULL, 'inactive', NULL, '2025-08-05 05:52:57.914341', '2025-08-05 05:52:57.914341');
INSERT INTO public.qr_codes VALUES (793, 'e9f93e08-17a7-4018-9cdc-b32eb15f75fe', NULL, 'inactive', NULL, '2025-08-05 05:52:57.917181', '2025-08-05 05:52:57.917181');
INSERT INTO public.qr_codes VALUES (794, '89815987-fca5-4142-8d98-8d016ac1a8df', NULL, 'inactive', NULL, '2025-08-05 05:52:57.918692', '2025-08-05 05:52:57.918692');
INSERT INTO public.qr_codes VALUES (795, 'c93cb9fa-1df4-4435-9d65-55fc95b4f5b7', NULL, 'inactive', NULL, '2025-08-05 05:52:57.920947', '2025-08-05 05:52:57.920947');
INSERT INTO public.qr_codes VALUES (796, '5e58cd45-d432-4977-807f-77265522c42b', NULL, 'inactive', NULL, '2025-08-05 05:52:57.923283', '2025-08-05 05:52:57.923283');
INSERT INTO public.qr_codes VALUES (797, '74c27e96-d764-4778-8e7b-25af178dc825', NULL, 'inactive', NULL, '2025-08-05 05:52:57.924835', '2025-08-05 05:52:57.924835');
INSERT INTO public.qr_codes VALUES (798, 'f2aa50b0-06a5-4582-bad3-34a55e974a12', NULL, 'inactive', NULL, '2025-08-05 05:52:57.927025', '2025-08-05 05:52:57.927025');
INSERT INTO public.qr_codes VALUES (799, '126a8c88-8574-4140-b239-7d21fe5074a8', NULL, 'inactive', NULL, '2025-08-05 05:52:57.929699', '2025-08-05 05:52:57.929699');
INSERT INTO public.qr_codes VALUES (800, 'c71d460a-9060-495a-b301-012b0f5d8472', NULL, 'inactive', NULL, '2025-08-05 05:52:57.931281', '2025-08-05 05:52:57.931281');
INSERT INTO public.qr_codes VALUES (801, '11ad448c-4ae5-4ed2-b88a-c3462c4c6bc5', NULL, 'inactive', NULL, '2025-08-05 05:52:57.932861', '2025-08-05 05:52:57.932861');
INSERT INTO public.qr_codes VALUES (802, 'd4d02b94-2e49-4b0e-b368-b752038844a5', NULL, 'inactive', NULL, '2025-08-05 05:52:57.934524', '2025-08-05 05:52:57.934524');
INSERT INTO public.qr_codes VALUES (803, 'd4002a77-d365-4ced-8e41-e870fbeb2db4', NULL, 'inactive', NULL, '2025-08-05 05:52:57.936837', '2025-08-05 05:52:57.936837');
INSERT INTO public.qr_codes VALUES (804, '3b4d0b62-339c-4efd-8e8e-79221a90a647', NULL, 'inactive', NULL, '2025-08-05 05:52:57.938338', '2025-08-05 05:52:57.938338');
INSERT INTO public.qr_codes VALUES (805, 'ae6e3f4b-fe6a-408c-a4d8-71e2d8b41cd6', NULL, 'inactive', NULL, '2025-08-05 05:52:57.939881', '2025-08-05 05:52:57.939881');
INSERT INTO public.qr_codes VALUES (806, 'e1619f0b-806f-4419-975f-2fa6f4845543', NULL, 'inactive', NULL, '2025-08-06 14:29:37.815737', '2025-08-06 14:29:37.815737');
INSERT INTO public.qr_codes VALUES (807, 'f5e27ebe-3ac8-4db6-b62e-d1dee4c8c271', NULL, 'inactive', NULL, '2025-08-06 14:29:37.827234', '2025-08-06 14:29:37.827234');
INSERT INTO public.qr_codes VALUES (808, 'ff0d3b33-c2ad-4b90-bc31-f4c5be4d2ff3', NULL, 'inactive', NULL, '2025-08-06 14:29:37.828852', '2025-08-06 14:29:37.828852');
INSERT INTO public.qr_codes VALUES (809, 'd510edcc-0bdd-4bd5-89b2-98e72d959105', NULL, 'inactive', NULL, '2025-08-06 14:29:37.831193', '2025-08-06 14:29:37.831193');
INSERT INTO public.qr_codes VALUES (810, '4a7cf6c3-a477-4dd6-804a-9a7efe6faa34', NULL, 'inactive', NULL, '2025-08-06 14:29:37.833447', '2025-08-06 14:29:37.833447');
INSERT INTO public.qr_codes VALUES (811, '149c5739-c62c-4ecc-92f4-be815daa31d2', NULL, 'inactive', NULL, '2025-08-06 14:29:37.837996', '2025-08-06 14:29:37.837996');
INSERT INTO public.qr_codes VALUES (812, '620e5bc3-7466-40e8-b8de-6d164ebf87c9', NULL, 'inactive', NULL, '2025-08-06 14:29:37.840554', '2025-08-06 14:29:37.840554');
INSERT INTO public.qr_codes VALUES (813, 'aad4f9c8-2fa2-4276-807d-7e769563c47d', NULL, 'inactive', NULL, '2025-08-06 14:29:37.842075', '2025-08-06 14:29:37.842075');
INSERT INTO public.qr_codes VALUES (814, '072e4b11-d137-47cd-a4f8-737b69ce8874', NULL, 'inactive', NULL, '2025-08-06 14:29:37.843581', '2025-08-06 14:29:37.843581');
INSERT INTO public.qr_codes VALUES (815, '5657019c-9d0a-4ed3-93e1-a051a2d153d3', NULL, 'inactive', NULL, '2025-08-06 14:29:37.846493', '2025-08-06 14:29:37.846493');
INSERT INTO public.qr_codes VALUES (816, 'f20763ea-2aa6-4881-9c63-d0da2a210468', NULL, 'inactive', NULL, '2025-08-06 14:29:45.474642', '2025-08-06 14:29:45.474642');
INSERT INTO public.qr_codes VALUES (670, 'b3c7a3b5-b87c-4925-9399-df31f9041fdd', 54, 'active', '2025-08-08 03:58:47.521701', '2025-07-31 13:22:37.242312', '2025-08-08 03:58:47.521701');
INSERT INTO public.qr_codes VALUES (817, 'cfec5911-1427-47b6-87f5-fc344612606c', NULL, 'inactive', NULL, '2025-08-27 14:06:02.717452', '2025-08-27 14:06:02.717452');
INSERT INTO public.qr_codes VALUES (818, '0e146111-0790-4c2e-8ed7-02a6db1b7164', NULL, 'inactive', NULL, '2025-08-27 14:06:02.723942', '2025-08-27 14:06:02.723942');
INSERT INTO public.qr_codes VALUES (819, '42164f9c-bb19-46d6-a31c-9a184e24cade', NULL, 'inactive', NULL, '2025-08-28 20:32:53.701883', '2025-08-28 20:32:53.701883');
INSERT INTO public.qr_codes VALUES (820, '2e91c6b9-2507-46f6-8141-752dd5a906e1', NULL, 'inactive', NULL, '2025-08-28 20:33:18.667231', '2025-08-28 20:33:18.667231');
INSERT INTO public.qr_codes VALUES (821, '2239b6aa-27a4-47ee-99e2-c1da3c129573', NULL, 'inactive', NULL, '2025-08-28 20:33:18.671858', '2025-08-28 20:33:18.671858');
INSERT INTO public.qr_codes VALUES (822, '955ea67e-f2da-44f6-826e-4c0ed275c7e5', NULL, 'inactive', NULL, '2025-08-28 20:33:18.673726', '2025-08-28 20:33:18.673726');
INSERT INTO public.qr_codes VALUES (823, '4706b170-894f-4a9c-bb21-b27b3a1fd9dd', NULL, 'inactive', NULL, '2025-08-28 20:33:18.675366', '2025-08-28 20:33:18.675366');
INSERT INTO public.qr_codes VALUES (824, '4f0d7710-ec0e-4f39-823c-f24fde5c0e9a', NULL, 'inactive', NULL, '2025-08-28 20:33:18.67696', '2025-08-28 20:33:18.67696');
INSERT INTO public.qr_codes VALUES (825, '85b3a760-c7c5-47b6-8b37-dfcf10b48780', NULL, 'inactive', NULL, '2025-08-28 20:36:43.882217', '2025-08-28 20:36:43.882217');
INSERT INTO public.qr_codes VALUES (826, '12843f79-0ce4-41d6-b005-5280c6351682', NULL, 'inactive', NULL, '2025-08-28 20:36:43.884967', '2025-08-28 20:36:43.884967');
INSERT INTO public.qr_codes VALUES (827, '10444da4-d6dd-4dd7-bdca-94e9ab40e0ff', NULL, 'inactive', NULL, '2025-08-30 07:41:43.748543', '2025-08-30 07:41:43.748543');
INSERT INTO public.qr_codes VALUES (828, '03904d1d-db8b-46be-895f-e96a16f81518', NULL, 'inactive', NULL, '2025-08-30 07:41:43.756831', '2025-08-30 07:41:43.756831');
INSERT INTO public.qr_codes VALUES (829, 'a0274e2c-8f9f-4a80-8e00-f097fc94bd7b', NULL, 'inactive', NULL, '2025-08-30 07:41:43.75865', '2025-08-30 07:41:43.75865');
INSERT INTO public.qr_codes VALUES (830, 'd87916a1-2d8a-419b-82c1-4fe41ff66ac9', NULL, 'inactive', NULL, '2025-08-30 07:41:43.76371', '2025-08-30 07:41:43.76371');
INSERT INTO public.qr_codes VALUES (831, '69dadb35-ba68-4572-9635-b808e2ad9d09', NULL, 'inactive', NULL, '2025-08-30 07:41:43.769046', '2025-08-30 07:41:43.769046');
INSERT INTO public.qr_codes VALUES (832, 'd8ca9b87-6566-4dde-8759-7eff126bd098', NULL, 'inactive', NULL, '2025-08-30 07:41:43.774072', '2025-08-30 07:41:43.774072');
INSERT INTO public.qr_codes VALUES (833, '15beab2b-c21b-46da-b478-303ba1eb45e5', NULL, 'inactive', NULL, '2025-08-30 07:41:43.775773', '2025-08-30 07:41:43.775773');
INSERT INTO public.qr_codes VALUES (834, '3f536897-0232-4f3e-8d2f-131abf1040ad', NULL, 'inactive', NULL, '2025-08-30 07:41:43.777552', '2025-08-30 07:41:43.777552');
INSERT INTO public.qr_codes VALUES (835, '19f2ddfd-a923-4db6-8eca-783f8e42c87a', NULL, 'inactive', NULL, '2025-08-30 07:41:43.781072', '2025-08-30 07:41:43.781072');
INSERT INTO public.qr_codes VALUES (836, '5b366307-2297-4a2f-a115-51040a306eab', NULL, 'inactive', NULL, '2025-08-30 07:41:43.782714', '2025-08-30 07:41:43.782714');
INSERT INTO public.qr_codes VALUES (837, '6ba82c0b-0b9d-4521-a647-444489dd26c2', NULL, 'inactive', NULL, '2025-08-30 13:11:23.789307', '2025-08-30 13:11:23.789307');
INSERT INTO public.qr_codes VALUES (838, '74b495fb-c3be-4809-a2a2-6af87cce2a4b', NULL, 'inactive', NULL, '2025-08-30 14:08:46.479639', '2025-08-30 14:08:46.479639');
INSERT INTO public.qr_codes VALUES (839, '3e14c167-1925-44a9-b74e-3ccdaa6426f5', NULL, 'inactive', NULL, '2025-08-30 14:08:46.484974', '2025-08-30 14:08:46.484974');
INSERT INTO public.qr_codes VALUES (840, 'ac16b55f-a3a3-4d0e-8c8d-d80421bf3ccb', NULL, 'inactive', NULL, '2025-08-30 14:23:43.370173', '2025-08-30 14:23:43.370173');
INSERT INTO public.qr_codes VALUES (841, 'd2412159-d543-4a07-823f-11b4e4aaea1c', NULL, 'inactive', NULL, '2025-08-30 14:23:43.378413', '2025-08-30 14:23:43.378413');
INSERT INTO public.qr_codes VALUES (842, '731fdc74-6da3-494c-b2d6-c18bac5590f3', NULL, 'inactive', NULL, '2025-08-30 14:24:19.449411', '2025-08-30 14:24:19.449411');
INSERT INTO public.qr_codes VALUES (843, '891b3736-5f8c-4762-9fa9-ccdcde070961', NULL, 'inactive', NULL, '2025-08-30 14:24:19.453349', '2025-08-30 14:24:19.453349');
INSERT INTO public.qr_codes VALUES (844, '11c03b86-c311-4a4d-8fa3-bd4e9f54e263', NULL, 'inactive', NULL, '2025-08-30 16:41:50.774474', '2025-08-30 16:41:50.774474');
INSERT INTO public.qr_codes VALUES (845, 'f9cc7b0f-48cb-454f-8083-af06363c9369', NULL, 'inactive', NULL, '2025-08-30 16:41:50.781059', '2025-08-30 16:41:50.781059');
INSERT INTO public.qr_codes VALUES (846, 'ab219a6f-f102-41a9-9a89-2158f679ac00', NULL, 'inactive', NULL, '2025-08-31 06:23:45.785648', '2025-08-31 06:23:45.785648');
INSERT INTO public.qr_codes VALUES (664, 'df62c090-47cb-4761-ad9a-e21868d3fff8', 64, 'active', '2025-08-31 12:10:55.20105', '2025-07-31 13:22:37.23353', '2025-08-31 12:10:55.20105');
INSERT INTO public.qr_codes VALUES (847, 'bbc1a8af-5f76-49dc-b5bb-8f07e418a1bf', NULL, 'inactive', NULL, '2025-08-31 14:04:31.944911', '2025-08-31 14:04:31.944911');


--
-- TOC entry 3471 (class 0 OID 16456)
-- Dependencies: 225
-- Data for Name: route_customers; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3472 (class 0 OID 16459)
-- Dependencies: 226
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: admin
--



--
-- TOC entry 3474 (class 0 OID 16467)
-- Dependencies: 228
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.users VALUES (4, NULL, 1, '7615876735', '$2b$10$jzdgfUJpFUUqo6NNOg.I6efS3HANkYHR2ZZAUTvjhP5ipLzUjA98C', 'admin', '2025-06-14 08:29:31.584754', '2025-06-14 08:29:31.584754');
INSERT INTO public.users VALUES (5, 4, 1, '9461180798', '$2b$10$Ld0hubQSrUFbOkOEKajsuepCLFr9FwDBlJ5DyIa02AUu7bafr7EC6', 'delivery_guy', '2025-06-19 13:28:10.904517', '2025-06-19 13:28:10.904517');
INSERT INTO public.users VALUES (6, 5, 1, '9999999999', '$2b$10$4pKmqwaRpN9OliauMzOcc.kEB2vVjAXEKkNsBvWyHhdk0DfUB5Szi', 'delivery_guy', '2025-06-25 07:46:40.227177', '2025-06-25 07:46:40.227177');
INSERT INTO public.users VALUES (7, 6, 1, '7732867338', '$2b$10$nSbaDrfjO7GcYY6QIK7creCm3oEaSrugIW4K8rodFZ9VDTZ4XJIF6', 'delivery_guy', '2025-07-11 09:07:30.883096', '2025-07-11 09:07:30.883096');


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 210
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.customers_customer_id_seq', 73, true);


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 212
-- Name: delivery_guys_delivery_guy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.delivery_guys_delivery_guy_id_seq', 6, true);


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 214
-- Name: drive_customers_sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.drive_customers_sales_id_seq', 1, false);


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 216
-- Name: drive_locations_log_drive_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.drive_locations_log_drive_location_id_seq', 32, true);


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 218
-- Name: drives_drive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.drives_drive_id_seq', 32, true);


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 220
-- Name: outlets_outlet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.outlets_outlet_id_seq', 1, true);


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 222
-- Name: payment_logs_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.payment_logs_payment_id_seq', 28, true);


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 230
-- Name: point_transactions_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.point_transactions_transaction_id_seq', 489, true);


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 224
-- Name: qr_codes_qr_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.qr_codes_qr_id_seq', 847, true);


--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 227
-- Name: routes_route_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.routes_route_id_seq', 16, true);


--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 229
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.users_user_id_seq', 7, true);


--
-- TOC entry 3271 (class 2606 OID 16485)
-- Name: customers customers_phone_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_phone_key UNIQUE (phone);


--
-- TOC entry 3273 (class 2606 OID 16487)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 3275 (class 2606 OID 16489)
-- Name: delivery_guys delivery_guys_phone_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.delivery_guys
    ADD CONSTRAINT delivery_guys_phone_key UNIQUE (phone);


--
-- TOC entry 3277 (class 2606 OID 16491)
-- Name: delivery_guys delivery_guys_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.delivery_guys
    ADD CONSTRAINT delivery_guys_pkey PRIMARY KEY (delivery_guy_id);


--
-- TOC entry 3279 (class 2606 OID 16493)
-- Name: drive_customers_sales drive_customers_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drive_customers_sales
    ADD CONSTRAINT drive_customers_sales_pkey PRIMARY KEY (id);


--
-- TOC entry 3281 (class 2606 OID 16495)
-- Name: drive_locations_log drive_locations_log_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drive_locations_log
    ADD CONSTRAINT drive_locations_log_pkey PRIMARY KEY (drive_location_id);


--
-- TOC entry 3283 (class 2606 OID 16497)
-- Name: drives drives_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT drives_pkey PRIMARY KEY (drive_id);


--
-- TOC entry 3285 (class 2606 OID 16499)
-- Name: outlets outlets_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.outlets
    ADD CONSTRAINT outlets_pkey PRIMARY KEY (outlet_id);


--
-- TOC entry 3287 (class 2606 OID 16501)
-- Name: payment_logs payment_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payment_logs
    ADD CONSTRAINT payment_logs_pkey PRIMARY KEY (payment_id);


--
-- TOC entry 3301 (class 2606 OID 16703)
-- Name: point_transactions point_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.point_transactions
    ADD CONSTRAINT point_transactions_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 3289 (class 2606 OID 16503)
-- Name: qr_codes qr_codes_code_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.qr_codes
    ADD CONSTRAINT qr_codes_code_key UNIQUE (code);


--
-- TOC entry 3291 (class 2606 OID 16505)
-- Name: qr_codes qr_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.qr_codes
    ADD CONSTRAINT qr_codes_pkey PRIMARY KEY (qr_id);


--
-- TOC entry 3293 (class 2606 OID 16507)
-- Name: route_customers route_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.route_customers
    ADD CONSTRAINT route_customers_pkey PRIMARY KEY (route_id, customer_id);


--
-- TOC entry 3295 (class 2606 OID 16509)
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (route_id);


--
-- TOC entry 3297 (class 2606 OID 16511)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 3299 (class 2606 OID 16513)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3302 (class 2606 OID 16514)
-- Name: drive_customers_sales drive_customers_sales_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drive_customers_sales
    ADD CONSTRAINT drive_customers_sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- TOC entry 3303 (class 2606 OID 16519)
-- Name: drive_customers_sales drive_customers_sales_drive_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drive_customers_sales
    ADD CONSTRAINT drive_customers_sales_drive_id_fkey FOREIGN KEY (drive_id) REFERENCES public.drives(drive_id);


--
-- TOC entry 3304 (class 2606 OID 16524)
-- Name: drive_customers_sales drive_customers_sales_qr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drive_customers_sales
    ADD CONSTRAINT drive_customers_sales_qr_id_fkey FOREIGN KEY (qr_id) REFERENCES public.qr_codes(qr_id);


--
-- TOC entry 3305 (class 2606 OID 16529)
-- Name: drive_locations_log drive_locations_log_drive_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drive_locations_log
    ADD CONSTRAINT drive_locations_log_drive_id_fkey FOREIGN KEY (drive_id) REFERENCES public.drives(drive_id);


--
-- TOC entry 3306 (class 2606 OID 16534)
-- Name: drives drives_delivery_guy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT drives_delivery_guy_id_fkey FOREIGN KEY (delivery_guy_id) REFERENCES public.delivery_guys(delivery_guy_id);


--
-- TOC entry 3307 (class 2606 OID 16539)
-- Name: drives drives_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.drives
    ADD CONSTRAINT drives_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(route_id);


--
-- TOC entry 3308 (class 2606 OID 16544)
-- Name: payment_logs payment_logs_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payment_logs
    ADD CONSTRAINT payment_logs_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- TOC entry 3314 (class 2606 OID 16704)
-- Name: point_transactions point_transactions_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.point_transactions
    ADD CONSTRAINT point_transactions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- TOC entry 3315 (class 2606 OID 16709)
-- Name: point_transactions point_transactions_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.point_transactions
    ADD CONSTRAINT point_transactions_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.users(user_id);


--
-- TOC entry 3309 (class 2606 OID 16549)
-- Name: qr_codes qr_codes_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.qr_codes
    ADD CONSTRAINT qr_codes_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- TOC entry 3310 (class 2606 OID 16554)
-- Name: route_customers route_customers_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.route_customers
    ADD CONSTRAINT route_customers_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3311 (class 2606 OID 16559)
-- Name: route_customers route_customers_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.route_customers
    ADD CONSTRAINT route_customers_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(route_id) ON DELETE CASCADE;


--
-- TOC entry 3312 (class 2606 OID 16564)
-- Name: users users_delivery_guy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_delivery_guy_id_fkey FOREIGN KEY (delivery_guy_id) REFERENCES public.delivery_guys(delivery_guy_id) ON DELETE SET NULL;


--
-- TOC entry 3313 (class 2606 OID 16569)
-- Name: users users_outlet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_outlet_id_fkey FOREIGN KEY (outlet_id) REFERENCES public.outlets(outlet_id) ON DELETE SET NULL;


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2025-09-02 01:50:20

--
-- PostgreSQL database dump complete
--

