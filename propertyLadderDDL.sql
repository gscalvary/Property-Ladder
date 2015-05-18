-- Christopher Oliver
-- Class Project Deliverable 4: Generate Database
-- CS5200 Database Management Systems
-- Professor Dan Ries
-- Summer 2013

-- Table Row Counts:
-- architectural_styles		   16 rows
-- comments				    2 rows
-- images				68214 rows
-- messages				    2 rows
-- properties				35940 rows
-- property_agents			  500 rows
-- property_owners			 1000 rows
-- property_subscriptions		 3300 rows
-- searches				    1 row
-- search_architectural_styles             2 rows
-- search_locales			    8 rows
-- subscription_reasons		    3 rows
-- surveys				    1 row
-- survey_selections			    3 rows
-- users				 5000 rows

-- Database: property_ladder
CREATE DATABASE property_ladder
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'C'
       LC_CTYPE = 'C'
       CONNECTION LIMIT = -1;

-- Table: architectural_styles
-- DROP TABLE architectural_styles;
CREATE TABLE architectural_styles
(
  architectural_style_id serial NOT NULL,
  architectural_style character varying(45) NOT NULL,
  CONSTRAINT architectural_styles_pkey PRIMARY KEY (architectural_style_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE architectural_styles
  OWNER TO postgres;
-- populate architectural_styles using manually generated data
copy architectural_styles (architectural_style)
from '/Users/Christopher/Public/architectural_styles_data.csv'
delimiter ',' CSV;
-- check architectural_styles
select * from architectural_styles;

-- Table: comments
-- DROP TABLE comments;
CREATE TABLE comments
(
  comment_id serial NOT NULL,
  user_id integer NOT NULL,
  property_id integer NOT NULL,
  associated_comment_id integer,
  comment_body character varying(400),
  CONSTRAINT comments_pkey PRIMARY KEY (comment_id, user_id, property_id),
  CONSTRAINT comments_associated_comment_id_fkey FOREIGN KEY (associated_comment_id)
      REFERENCES comments (comment_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT comments_property_id_fkey FOREIGN KEY (property_id)
      REFERENCES properties (property_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id)
      REFERENCES users (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT comments_comment_id_key UNIQUE (comment_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE comments
  OWNER TO postgres;
-- populate comments using manually generated data.
insert into comments
(user_id
,property_id
,comment_body)
values
((select user_id from users limit 1)
,(select property_id from properties limit 1)
,'My first comment!');

insert into comments
(user_id
,property_id
,associated_comment_id
,comment_body)
values
((select user_id from users limit 1)
,4
,1
,'My first comment response!');
-- check comments
select * from comments;

-- Table: images
-- DROP TABLE images;
CREATE TABLE images
(
  property_id integer NOT NULL,
  primary_image_ind boolean NOT NULL,
  image_file_path character varying(100) NOT NULL,
  image_id serial NOT NULL,
  CONSTRAINT images_property_id_fkey FOREIGN KEY (property_id)
      REFERENCES properties (property_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE images
  OWNER TO postgres;
-- populate images using manually generated data.
insert into images
(select p.property_id
       ,true
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_1'
   from properties p
  where p.for_sale_ind is false);

insert into images
(select p.property_id
       ,true
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_1'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_2'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_3'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_4'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_5'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_6'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_7'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_8'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_9'
   from properties p
  where p.for_sale_ind is true
 union
 select p.property_id
       ,false
       ,'/image_server/image_folder/' || p.property_id::character(8) || '/image_10'
   from properties p
  where p.for_sale_ind is true);
-- check images
select * from images;

-- Table: messages
-- DROP TABLE messages;
CREATE TABLE messages
(
  message_id serial NOT NULL,
  sending_user_id integer NOT NULL,
  receiving_user_id integer NOT NULL,
  associated_message_id integer,
  sent_ind boolean NOT NULL,
  read_ind boolean NOT NULL,
  message_body character varying(400),
  message_topic character varying(45),
  CONSTRAINT messages_pkey PRIMARY KEY (message_id, sending_user_id, receiving_user_id),
  CONSTRAINT messages_associated_message_id_fkey FOREIGN KEY (associated_message_id)
      REFERENCES messages (message_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT messages_receiving_user_id_fkey FOREIGN KEY (receiving_user_id)
      REFERENCES users (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT messages_sending_user_id_fkey FOREIGN KEY (sending_user_id)
      REFERENCES users (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT messages_message_id_key UNIQUE (message_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE messages
  OWNER TO postgres;
-- populate messages using manually generated data.
insert into messages
(sending_user_id
,receiving_user_id
,sent_ind
,read_ind
,message_body
,message_topic)
values
(8683
,9554
,true
,true
,'My first message!'
,'test');

insert into messages
(sending_user_id
,receiving_user_id
,associated_message_id
,sent_ind
,read_ind
,message_body
,message_topic)
values
(9554
,8683
,1
,true
,false
,'My first message response!'
,'test');
-- check messages
select * from messages;

-- Table: properties
-- DROP TABLE properties;
CREATE TABLE properties
(
  property_id serial NOT NULL,
  street character varying(45) NOT NULL,
  city character varying(45) NOT NULL,
  zipcode character varying(9) NOT NULL,
  lot_size integer NOT NULL,
  for_sale_ind boolean NOT NULL,
  sale_price integer,
  market_value integer,
  locked_ind boolean NOT NULL,
  bedroom_count integer NOT NULL,
  bathroom_count real NOT NULL,
  house_size integer NOT NULL,
  year_built integer NOT NULL,
  architectural_style_id integer NOT NULL,
  garage_car_count integer,
  garage_attached_ind boolean,
  state character varying(2) NOT NULL,
  modified_ind boolean NOT NULL DEFAULT false,
  CONSTRAINT properties_pkey PRIMARY KEY (property_id),
  CONSTRAINT properties_architectural_style_id_fkey FOREIGN KEY (architectural_style_id)
      REFERENCES architectural_styles (architectural_style_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE properties
  OWNER TO postgres;
-- populate properties using data gathered from the US Government: http://www.census.gov/geo/maps-data/data/tiger-line.html
-- and recent market data gathered from www.trulia.com.  The data was joined in an Excel spreadsheet and certain values
-- were randomized and or calculated.  For example, house size was generated randomly but many other numeric values were
-- calculated from it such as market value, bedroom count, bathroom count and lot size.  Furthermore constants assigned
-- at the zipcode level provided some level of additional realism, for example more rural communities had a constant that
-- gave them larger lot sizes.
copy properties
 (street
 ,city
 ,state
 ,zipcode
 ,lot_size
 ,for_sale_ind
 ,sale_price
 ,market_value
 ,locked_ind
 ,bedroom_count
 ,bathroom_count
 ,house_size
 ,year_built
 ,architectural_style_id
 ,garage_car_count
 ,garage_attached_ind)
from '/Users/Christopher/Public/properties_data.csv'
delimiter ',' CSV;
-- check properties
select * from properties;

-- Table: property_agents
-- DROP TABLE property_agents;
CREATE TABLE property_agents
(
  user_id integer NOT NULL,
  property_id integer NOT NULL,
  CONSTRAINT property_agents_pkey PRIMARY KEY (user_id, property_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE property_agents
  OWNER TO postgres;
-- populate property_agents by generating a .csv file on the fly.
copy
(
with agents as
 (select u.user_id from users u order by random() limit 500),
     indexed_agents as
 (select row_number() over (order by a.user_id) as id, a.user_id from agents a),
     houses as
 (select p.property_id from properties p where p.for_sale_ind is true order by random() limit 500),
     indexed_houses as
 (select row_number() over (order by h.property_id) as id, h.property_id from houses h)
select ia.user_id, ih.property_id
  from indexed_agents ia
  join indexed_houses ih
    on ia.id = ih.id
) to '/Users/Christopher/Public/property_agents_data.csv' with csv;

copy property_agents
(user_id
,property_id)
from '/Users/Christopher/Public/property_agents_data.csv'
delimiter ',' CSV;
-- check property_agents
select * from property_agents;

-- Table: property_owners
-- DROP TABLE property_owners;
CREATE TABLE property_owners
(
  property_owner_id serial NOT NULL,
  user_id integer NOT NULL,
  property_id integer NOT NULL,
  CONSTRAINT property_owners_pkey PRIMARY KEY (property_owner_id),
  CONSTRAINT property_owners_property_id_fkey FOREIGN KEY (property_id)
      REFERENCES properties (property_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT property_owners_user_id_fkey FOREIGN KEY (user_id)
      REFERENCES users (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE property_owners
  OWNER TO postgres;
-- populate property_owners by generating a .csv file on the fly.
copy
(
with owners as
 (select u.user_id from users u order by random() limit 1000),
     indexed_owners as
 (select row_number() over (order by o.user_id) as id, o.user_id from owners o),
     houses as
 (select p.property_id from properties p order by random() limit 1000),
     indexed_houses as
 (select row_number() over (order by h.property_id) as id, h.property_id from houses h)
select io.user_id, ih.property_id
  from indexed_owners io
  join indexed_houses ih
    on io.id = ih.id
) to '/Users/Christopher/Public/property_owners_data.csv' with csv;

copy property_owners
(user_id
,property_id)
from '/Users/Christopher/Public/property_owners_data.csv'
delimiter ',' CSV;

-- check property_owners
select * from property_owners;

-- Table: property_subscriptions
-- DROP TABLE property_subscriptions;
CREATE TABLE property_subscriptions
(
  property_subscription_id serial NOT NULL,
  user_id integer NOT NULL,
  property_id integer NOT NULL,
  active_date date NOT NULL,
  cancel_date date,
  subscription_reason_id integer NOT NULL,
  CONSTRAINT property_subscriptions_pkey PRIMARY KEY (property_subscription_id, user_id, property_id),
  CONSTRAINT property_subscriptions_subscription_reason_id_fkey FOREIGN KEY (subscription_reason_id)
      REFERENCES subscription_reasons (subscription_reason_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE property_subscriptions
  OWNER TO postgres;
-- populate property_subscriptions by generating a .csv file on the fly - potential buyers.
copy
(
with subscribers as
 (select u.user_id from users u order by random() limit 300),
     indexed_subscribers as
 (select row_number() over (order by s.user_id) as id, s.user_id from subscribers s),
     houses as
 (select p.property_id from properties p order by random() limit 300),
     indexed_houses as
 (select row_number() over (order by h.property_id) as id, h.property_id from houses h)
select isu.user_id, ih.property_id, current_date, 1
  from indexed_subscribers isu
  join indexed_houses ih
    on isu.id = ih.id
) to '/Users/Christopher/Public/property_subscriptions_data.csv' with csv;
-- populate property_subscriptions by generating a .csv file on the fly - potential agents.
copy
(
with potential_agents as
 (select pa.user_id from property_agents pa order by random()),
     indexed_agents as
 (select row_number() over (order by poa.user_id) as id, poa.user_id from potential_agents poa),
     houses as
 (select p.property_id from properties p order by random() limit 500),
     indexed_houses as
 (select row_number() over (order by h.property_id) as id, h.property_id from houses h)
select ia.user_id, ih.property_id, current_date, 2
  from indexed_agents ia
  join indexed_houses ih
    on ia.id = ih.id
) to '/Users/Christopher/Public/property_subscriptions_data.csv' with csv;
-- populate property_subscriptions by generating a .csv file on the fly - admirers.
copy
(
with admirers as
 (select u.user_id from users u order by random() limit 2500),
     indexed_admirers as
 (select row_number() over (order by a.user_id) as id, a.user_id from admirers a),
     houses as
 (select p.property_id from properties p order by random() limit 2500),
     indexed_houses as
 (select row_number() over (order by h.property_id) as id, h.property_id from houses h)
select ia.user_id, ih.property_id, current_date, 3
  from indexed_admirers ia
  join indexed_houses ih
    on ia.id = ih.id
) to '/Users/Christopher/Public/property_subscriptions_data.csv' with csv;

copy property_subscriptions
(user_id
,property_id
,active_date
,subscription_reason_id)
from '/Users/Christopher/Public/property_subscriptions_data.csv'
delimiter ',' CSV;
-- check property_subscriptions
select * from property_subscriptions;

-- Table: searches
-- DROP TABLE searches;
CREATE TABLE searches
(
  search_id serial NOT NULL,
  user_id integer NOT NULL,
  minimum_garage_car_count integer,
  for_sale_ind boolean,
  minimum_lot_size integer,
  maximum_lot_size integer,
  minimum_bedroom_count integer,
  minimum_bathroom_count real,
  minimum_year_built integer,
  maximum_year_built integer,
  minimum_spend integer,
  maximum_spend integer,
  CONSTRAINT searches_pkey PRIMARY KEY (search_id, user_id),
  CONSTRAINT searches_user_id_fkey FOREIGN KEY (user_id)
      REFERENCES users (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT searches_search_id_key UNIQUE (search_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE searches
  OWNER TO postgres;
-- populate searches using manually generated data.
insert into searches
(user_id
,minimum_garage_car_count
,minimum_bedroom_count
,minimum_bathroom_count
,minimum_spend
,maximum_spend)
values
((select user_id from users limit 1)
,2
,4
,2.5
,500000
,900000);
-- check searches
select * from searches;

-- Table: search_architectural_styles
-- DROP TABLE search_architectural_styles;
CREATE TABLE search_architectural_styles
(
  search_id integer NOT NULL,
  architectural_style_id integer NOT NULL,
  CONSTRAINT search_architectural_styles_pkey PRIMARY KEY (search_id, architectural_style_id),
  CONSTRAINT search_architectural_styles_architectural_style_id_fkey FOREIGN KEY (architectural_style_id)
      REFERENCES architectural_styles (architectural_style_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT search_architectural_styles_search_id_fkey FOREIGN KEY (search_id)
      REFERENCES searches (search_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE search_architectural_styles
  OWNER TO postgres;
-- populate search_architectural_styles using manually generated data.
insert into search_architectural_styles
(search_id
,architectural_style_id)
values
(1
,9),
(1
,10)
;
-- check search_locales
select * from search_locales;

-- Table: search_locales
-- DROP TABLE search_locales;
CREATE TABLE search_locales
(
  search_locale_id serial NOT NULL,
  search_id integer NOT NULL,
  zipcode character varying(9),
  city character varying(45),
  CONSTRAINT search_locales_pkey PRIMARY KEY (search_locale_id, search_id),
  CONSTRAINT search_locales_search_id_fkey FOREIGN KEY (search_id)
      REFERENCES searches (search_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE search_locales
  OWNER TO postgres;
-- populate search_locales using manually generated data.
insert into search_locales
(search_id
,zipcode
,city)
values
(1
,'02906'
,NULL),
(1
,'02837'
,NULL),
(1
,NULL
,'Tiverton'),
(1
,NULL
,'Bristol'),
(1
,NULL
,'Warren'),
(1
,NULL
,'Barrington'),
(1
,'02852'
,NULL),
(1
,'02818'
,NULL);
-- check search_locales
select * from search_locales;

-- Table: subscription_reasons
-- DROP TABLE subscription_reasons;
CREATE TABLE subscription_reasons
(
  subscription_reason_id serial NOT NULL,
  subscription_reason character varying(25) NOT NULL,
  CONSTRAINT subscription_reasons_pkey PRIMARY KEY (subscription_reason_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE subscription_reasons
  OWNER TO postgres;
-- populate subscription_reasons
insert into subscription_reasons
 (subscription_reason)
values
 ('prospective buyer')
,('prospective agent')
,('admirer');
-- check subscription_reasons
select * from subscription_reasons;

-- Table: surveys
-- DROP TABLE surveys;
CREATE TABLE surveys
(
  survey_id serial NOT NULL,
  property_owner_id integer NOT NULL,
  survey_body character varying(200) NOT NULL,
  survey_open_date date,
  survey_close_date date,
  CONSTRAINT surveys_pkey PRIMARY KEY (survey_id),
  CONSTRAINT surveys_property_owner_id_fkey FOREIGN KEY (property_owner_id)
      REFERENCES property_owners (property_owner_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE surveys
  OWNER TO postgres;
-- populate surveys using manually generated data.
insert into surveys
 (property_owner_id
 ,survey_body
 ,survey_open_date
 ,survey_close_date)
values
 ((select property_owner_id from property_owners limit 1)
 ,'What color should I paint my house?'
 ,'2013-07-07'
 ,'2013-08-01');
-- check surveys
select * from surveys;

-- Table: survey_selections
-- DROP TABLE survey_selections;
CREATE TABLE survey_selections
(
  survey_selection_id serial NOT NULL,
  survey_id integer NOT NULL,
  selection_body character varying(45) NOT NULL,
  selection_count integer NOT NULL,
  CONSTRAINT survey_selections_pkey PRIMARY KEY (survey_selection_id, survey_id),
  CONSTRAINT survey_selections_survey_id_fkey FOREIGN KEY (survey_id)
      REFERENCES surveys (survey_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE survey_selections
  OWNER TO postgres;
-- populate survey_selections using manually generated data
insert into survey_selections
 (survey_id
 ,selection_body
 ,selection_count)
values
 ((select survey_id from surveys limit 1)
 ,'pale green'
 ,40),
 ((select survey_id from surveys limit 1)
 ,'light blue'
 ,64),
 ((select survey_id from surveys limit 1)
 ,'light purple'
 ,2);
-- check surveys
select * from survey_selections;

-- Table: users
-- DROP TABLE users;
CREATE TABLE users
(
  user_id serial NOT NULL,
  user_screen_nm character varying(20) NOT NULL,
  user_password character varying(20) NOT NULL,
  user_first_nm character varying(45),
  user_last_nm character varying(45),
  user_email_address character varying(100) NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (user_id),
  CONSTRAINT users_user_screen_nm_key UNIQUE (user_screen_nm)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE users
  OWNER TO postgres;
-- populate users using randomly generated data from www.identitygenerator.com
copy users (user_screen_nm, user_password, user_first_nm, user_last_nm, user_email_address)
from '/Users/Christopher/Public/users_data.csv'
delimiter ',' CSV;
-- change the user_screen_nm
update users
   set user_screen_nm = user_first_nm || '_' || user_screen_nm;
-- check users
select * from users;
