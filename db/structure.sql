--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: inbound_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_logs (
    id integer NOT NULL,
    inbound_order_id integer NOT NULL,
    product_id integer NOT NULL,
    shelf_id integer NOT NULL,
    properties jsonb DEFAULT '{}'::jsonb NOT NULL,
    quantity integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE inbound_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE inbound_logs IS 'Details about what and how many stuff got stored into which shelf';


--
-- Name: COLUMN inbound_logs.inbound_order_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_logs.inbound_order_id IS 'The inbound process that stored the incoming stuff';


--
-- Name: COLUMN inbound_logs.product_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_logs.product_id IS 'The kind of stuff that got stored';


--
-- Name: COLUMN inbound_logs.shelf_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_logs.shelf_id IS 'The shelf in which the stuff got stored';


--
-- Name: COLUMN inbound_logs.properties; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_logs.properties IS 'Attributes of the stuff that got stored';


--
-- Name: COLUMN inbound_logs.quantity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_logs.quantity IS 'The quantity of stuff that got stored';


--
-- Name: inbound_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_logs_id_seq OWNED BY inbound_logs.id;


--
-- Name: inbound_order_transitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_order_transitions (
    id integer NOT NULL,
    inbound_order_id integer NOT NULL,
    to_state character varying NOT NULL,
    most_recent boolean NOT NULL,
    sort_key integer NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE inbound_order_transitions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE inbound_order_transitions IS 'Inbound order state changes during the process';


--
-- Name: COLUMN inbound_order_transitions.inbound_order_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_order_transitions.inbound_order_id IS 'The inbound process that changed state';


--
-- Name: COLUMN inbound_order_transitions.to_state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_order_transitions.to_state IS 'The state into which the inbound process changed';


--
-- Name: COLUMN inbound_order_transitions.most_recent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_order_transitions.most_recent IS 'Whether this state change was the latest or not';


--
-- Name: COLUMN inbound_order_transitions.sort_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_order_transitions.sort_key IS 'A key that indicates the order of state changes';


--
-- Name: COLUMN inbound_order_transitions.metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_order_transitions.metadata IS 'Additional data about the state change';


--
-- Name: COLUMN inbound_order_transitions.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_order_transitions.created_at IS 'Timestamp of the state change';


--
-- Name: inbound_order_transitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_order_transitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_order_transitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_order_transitions_id_seq OWNED BY inbound_order_transitions.id;


--
-- Name: inbound_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inbound_orders (
    id integer NOT NULL,
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE inbound_orders; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE inbound_orders IS 'Registers any time stuff gets shipped into the store';


--
-- Name: COLUMN inbound_orders.notes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN inbound_orders.notes IS 'Notes about the incoming order';


--
-- Name: inbound_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbound_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbound_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbound_orders_id_seq OWNED BY inbound_orders.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE items (
    id integer NOT NULL,
    inbound_log_id integer NOT NULL,
    product_id integer NOT NULL,
    shelf_id integer,
    shelf_rank integer,
    properties jsonb DEFAULT '{}'::jsonb NOT NULL,
    currently_available boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE items; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE items IS 'All items that are or have been on inventory';


--
-- Name: COLUMN items.inbound_log_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN items.inbound_log_id IS 'Reference to the inbound log that entered this item into inventory';


--
-- Name: COLUMN items.product_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN items.product_id IS 'Reference to the product this item belongs to';


--
-- Name: COLUMN items.shelf_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN items.shelf_id IS 'Reference to the shelf this item is currently placed into';


--
-- Name: COLUMN items.shelf_rank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN items.shelf_rank IS 'Order in which this item is currently placed inside the shelf';


--
-- Name: COLUMN items.properties; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN items.properties IS 'The current attributes for this item';


--
-- Name: COLUMN items.currently_available; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN items.currently_available IS 'Whether the item is currently present in our inventory or not';


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY items.id;


--
-- Name: product_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE product_stats (
    product_id integer NOT NULL,
    rating integer DEFAULT 0 NOT NULL,
    sell_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE products (
    id integer NOT NULL,
    category_id integer NOT NULL,
    name character varying NOT NULL,
    brand character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shelves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE shelves (
    id integer NOT NULL,
    name character varying NOT NULL,
    warehouse boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE shelves; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE shelves IS 'Where stuff is placed into';


--
-- Name: COLUMN shelves.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN shelves.name IS 'A name used to physically identify the shelf';


--
-- Name: COLUMN shelves.warehouse; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN shelves.warehouse IS 'Whether the shelf is in the warehouse or not';


--
-- Name: shelves_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shelves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shelves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE shelves_id_seq OWNED BY shelves.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: inbound_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_logs ALTER COLUMN id SET DEFAULT nextval('inbound_logs_id_seq'::regclass);


--
-- Name: inbound_order_transitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_order_transitions ALTER COLUMN id SET DEFAULT nextval('inbound_order_transitions_id_seq'::regclass);


--
-- Name: inbound_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_orders ALTER COLUMN id SET DEFAULT nextval('inbound_orders_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY items ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: shelves id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY shelves ALTER COLUMN id SET DEFAULT nextval('shelves_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: inbound_logs inbound_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_logs
    ADD CONSTRAINT inbound_logs_pkey PRIMARY KEY (id);


--
-- Name: inbound_order_transitions inbound_order_transitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_order_transitions
    ADD CONSTRAINT inbound_order_transitions_pkey PRIMARY KEY (id);


--
-- Name: inbound_orders inbound_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_orders
    ADD CONSTRAINT inbound_orders_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shelves shelves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shelves
    ADD CONSTRAINT shelves_pkey PRIMARY KEY (id);


--
-- Name: IX_available_item; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_available_item" ON items USING btree (currently_available) WHERE (currently_available = true);


--
-- Name: IX_counter_shelf; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_counter_shelf" ON shelves USING btree (warehouse) WHERE (warehouse = false);


--
-- Name: IX_inbound_log_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_inbound_log_order" ON inbound_logs USING btree (inbound_order_id);


--
-- Name: IX_inbound_log_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_inbound_log_product" ON inbound_logs USING btree (product_id);


--
-- Name: IX_inbound_log_shelf; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_inbound_log_shelf" ON inbound_logs USING btree (shelf_id);


--
-- Name: IX_inbound_order_most_recent_transition; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_inbound_order_most_recent_transition" ON inbound_order_transitions USING btree (inbound_order_id, most_recent) WHERE most_recent;


--
-- Name: INDEX "IX_inbound_order_most_recent_transition"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX "IX_inbound_order_most_recent_transition" IS 'A partial index holding only references to the most recent records of each inbound process';


--
-- Name: IX_inbound_order_transition_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_inbound_order_transition_sort" ON inbound_order_transitions USING btree (inbound_order_id, sort_key);


--
-- Name: INDEX "IX_inbound_order_transition_sort"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX "IX_inbound_order_transition_sort" IS 'An index holding the order of transitions';


--
-- Name: IX_item_inbound_log; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_item_inbound_log" ON items USING btree (inbound_log_id);


--
-- Name: IX_item_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_item_product" ON items USING btree (product_id);


--
-- Name: IX_item_shelf; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_item_shelf" ON items USING btree (shelf_id);


--
-- Name: IX_product_brand; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_product_brand" ON products USING btree (brand);


--
-- Name: IX_product_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_product_category" ON products USING btree (category_id);


--
-- Name: IX_product_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_product_name" ON products USING btree (name);


--
-- Name: IX_product_rating; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_product_rating" ON product_stats USING btree (rating);


--
-- Name: IX_product_sell_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_product_sell_count" ON product_stats USING btree (sell_count);


--
-- Name: IX_product_stat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_product_stat" ON product_stats USING btree (product_id);


--
-- Name: IX_sold_item; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_sold_item" ON items USING btree (currently_available) WHERE (currently_available = false);


--
-- Name: IX_transition_inbound_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_transition_inbound_order" ON inbound_order_transitions USING btree (inbound_order_id);


--
-- Name: IX_warehouse_shelf; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_warehouse_shelf" ON shelves USING btree (warehouse) WHERE (warehouse = true);


--
-- Name: UK_brand_product_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UK_brand_product_name" ON products USING btree (name, brand);


--
-- Name: UK_category_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UK_category_name" ON categories USING btree (name);


--
-- Name: UK_shelf_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UK_shelf_name" ON shelves USING btree (name);


--
-- Name: inbound_logs FK_inbound_log_order; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_logs
    ADD CONSTRAINT "FK_inbound_log_order" FOREIGN KEY (inbound_order_id) REFERENCES inbound_orders(id);


--
-- Name: inbound_logs FK_inbound_log_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_logs
    ADD CONSTRAINT "FK_inbound_log_product" FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: inbound_logs FK_inbound_log_shelf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_logs
    ADD CONSTRAINT "FK_inbound_log_shelf" FOREIGN KEY (shelf_id) REFERENCES shelves(id);


--
-- Name: items FK_item_inbound_log; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT "FK_item_inbound_log" FOREIGN KEY (inbound_log_id) REFERENCES inbound_logs(id);


--
-- Name: items FK_item_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT "FK_item_product" FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: items FK_item_shelf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT "FK_item_shelf" FOREIGN KEY (shelf_id) REFERENCES shelves(id);


--
-- Name: products FK_product_category; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT "FK_product_category" FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: product_stats FK_product_stat; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_stats
    ADD CONSTRAINT "FK_product_stat" FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: inbound_order_transitions FK_transition_inbound_order; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbound_order_transitions
    ADD CONSTRAINT "FK_transition_inbound_order" FOREIGN KEY (inbound_order_id) REFERENCES inbound_orders(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO partitioning,public;

INSERT INTO schema_migrations (version) VALUES
('20170131173652'),
('20170131173739'),
('20170204222535');


