-- Christopher Oliver
-- Class Project Deliverable 5: Application Queries
-- CS5200 Database Management Systems
-- Professor Dan Ries
-- Summer 2013

-- NOTES
-- variables are represented as column names with dashes rather than underscores
-- between the terms, example: user-id

-- UPDATE AUTHORIZATION
-- Much of the functionality described below is only available if a user is assigned as
-- either an owner or an agent of a property.  The following select statement would be run
-- each time a user attempted to perform an update to the database for a given property.
-- A 0 SQLCODE would translate to authorized, a 100 SQLCODE to un-authorized.
-- Authorization lies at the owner level, the agent level or either level.

with either_property_authorization as
(select p.property_id
   from properties p
   join property_owners po on p.property_id = po.property_id
  where po.user_id = user-id
 union
 select p.property_id
   from properties p
   join property_agents pa on p.property_id = pa.property_id
  where pa.user_id = user-id),
     owner_property_authorization as
(select p.property_id
   from properties p
   join property_owners po on p.property_id = po.property_id
  where po.user_id = user-id),
     agent_property_authorization as
(select p.property_id
   from properties p
   join property_agents pa on p.property_id = pa.property_id
  where pa.user_id = user-id)

 select null
   from either_property_authorization
  where property_id = property-id
;
 select null
   from owner_property_authorization
  where property_id = property-id
;
 select null
   from agent_property_authorization
  where property_id = property-id
;

-- SEARCH FOR PROPERTIES
-- Property Ladder users must be able to search for properties of interest to them.
-- The application will dynamically generate SQL using the constraints chosen by the user.
-- A list of basic information about each property that meets the search criteria will be
-- presented.
-- What follows is a preparation of a user search where all possible constraints
-- have a value.

prepare user_search as
select p.property_id
      ,p.street
      ,p.city
      ,p.state
      ,p.zipcode
      ,p.lot_size
      ,p.for_sale_ind
      ,p.sale_price
      ,p.bedroom_count
      ,p.bathroom_count
      ,p.house_size
      ,p.garage_car_count
      ,i.image_file_path
 from properties p
 left outer join images i on p.property_id = i.property_id
where i.primary_image_ind is true
  and p.garage_car_count >= garage-car-count
  and p.for_sale_ind is for-sale-ind
  and p.lot_size between minimum-lot-size
                     and maximum-lot-size
  and p.bedroom_count >= minimum-bedroom-count
  and p.bathroom_count >= minimum-bathroom-count
  and p.architectural_style_id in
     (select ast.architectural_style_id
        from architectural_styles ast
       where ast.architectural_style
          in ('architectural-style-1',
              'architectural-style-2'))
  and p.year_built between minimum-year-built
                       and maximum-year-built
  and p.sale_price between minimum-sale-price
                       and maximum-sale-price
  and (p.city in ('city-1', 'city-2')
   or  p.zipcode in ('zipcode-1', 'zipcode-2'))
;
execute user_search;

-- REGISTER AS A USER
-- Users must be able to register themselves to the application.

insert into users
(user_screen_nm
,user_password
,user_first_nm
,user_last_nm
,user_email_address)
values
('user-screen-nm'
,'user-password'
,'user-first-nm'
,'user-last-nm'
,'user-email-address')
;

-- Users must also be able to assign themselves as owners or agents of properties.
-- Note users would have to be signed into the application with a property selected
-- in order to claim ownership, therefore the user_id and property_id of the house
-- would be available to the application at the time of ownership assignment.
-- Verification of ownership is not covered.

insert into property_owners
(user_id
,property_id)
values
(user-id
,property-id)
;

insert into property_agents
(user_id
,property_id)
values
(user-id
,property-id)
;

-- SAVE SEARCHES
-- Users must be able to save their searches.
-- The application will dynamically generate SQL using the constraints chosen by the user.
-- What follows is a preparation of a user search save where all possible constraints
-- have a value.

prepare save_user_search as
insert into searches
(user_id
,minimum_garage_car_count
,for_sale_ind
,minimum_lot_size
,maximum_lot_size
,minimum_bedroom_count
,minimum_bathroom_count
,minimum_year_built
,maximum_year_built
,minimum_spend
,maximum_spend)
values
(user-id
,minimum-garage-car-count
,for-sale-ind
,minimum-lot-size
,maximum-lot-size
,minimum-bedroom-count
,minimum-bathroom-count
,minimum-year-built
,maximum-year-built
,minimum-spend
,maximum-spend)
;
prepare save_user_search_locales as
insert into search_locales
(search_id
,zipcode
,city)
values
((select currval('searches_search_id_seq'))
 ,NULL
 ,'city-1'),
((select currval('searches_search_id_seq'))
 ,NULL
 ,'city-2'),
((select currval('searches_search_id_seq'))
 ,'zipcode-1'
 ,NULL),
((select currval('searches_search_id_seq'))
 ,'zipcode-2'
 ,NULL)
;
prepare save_user_search_architectural_styles as
insert into search_architectural_styles
(search_id
,architectural_style_id)
values
((select currval('searches_search_id_seq'))
 ,architectural-style-id-1),
((select currval('searches_search_id_seq'))
 ,architectural-style-id-2)
;
execute save_user_search;
execute save_user_search_locales;
execute save_user_search_architectural_styles;

-- VIEW AND POST COMMENTS
-- Users must be able to post comments about properties and respond to comments posted by others.
-- The option to post or view a comment would only be available in the application if the property
-- were unlocked.

-- check if locked
select p.locked_ind
  from properties p
 where property_id = property-id
;

-- retrieve comments for screen presentation.  Note the property_id variable would be bound
-- at cursor open.
declare comments_cursor cursor for
 select u.user_screen_nm
       ,c.associated_comment_id
       ,c.comment_body
   from comments c
   join users u on c.user_id = u.user_id
  where c.property_id = property-id;

open comments_cursor;

-- iterate for the property
fetch comments_cursor into u-user-screen-nm, c-associated-comment-id, c-comment-body;

close comments_cursor;

-- new comment, note owners and agents of the property will be notified in real-time
-- via email of a comment on a property.  The same SQL in the SUBSCRIBE TO PROPERTIES
-- section would be executed to generate the email.
insert into comments
(user_id
,property_id
,associated_comment_id
,comment_body)
values
(user-id
,property-id
,NULL
,'comment-body')
;

-- comment response
insert into comments
(user_id
,property_id
,associated_comment_id
,comment_body)
values
(user-id
,property-id
,associated-comment-id
,'comment-body')
;

-- the user who wrote the comment to which this comment responds would be notified of the
-- response immediately via email.
select u.user_screen_nm
      ,u.user_email_address
  from users u
  join comments c on u.user_id = c.user_id
 where c.comment_id = associated-comment-id
;

-- SEND AND RECEIVE PRIVATE MESSAGES
-- Users must be able to send and receive private messages to and from other users.

insert into messages
(sending_user_id
,receiving_user_id
,sent_ind
,read_ind
,message_body
,message_topic)
values
(sending-user-id
,receiving-user-id
,true
,false
,'message-body'
,'message-topic');

insert into messages
(sending_user_id
,receiving_user_id
,associated_message_id
,sent_ind
,read_ind
,message_body
,message_topic)
values
(sending-user-id
,receiving-user-id
,associated-message-id
,true
,false
,'message-body'
,'message-topic');

-- the receiver of the message would be notified of the message immediately via email.
select u.user_screen_nm
      ,u.user_email_address
  from users u
 where u.user_id = m-receiving-user-id
;

-- CREATE AND RESPOND TO SURVEYS
-- Owners must be able to create surveys about their properties.
-- Users must be able to respond to surveys.
-- Note that the owner UPDATE AUTHORIZATION SQL would be run before presenting the
-- creation functionality to the user.

-- Only three open surveys per property would be allowed at any one time.  The application
-- would test the results of this select before allowing a new survey to be created.
select count(*)
  from surveys s
  join property_owners po on po.property_owner_id = s.property_owner_id
 where s.survey_close_date <= current_date
   and po.property_id = property-id
;
-- create a survey
insert into surveys
 (property_owner_id
 ,survey_body
 ,survey_open_date
 ,survey_close_date)
values
 (property-owner-id
 ,'survey-body'
 ,'survey-open-date'
 ,'survey-close-date');

-- create survey selections
-- Because the number of survey selections is determined by the user at the time of survey
-- creation this SQL will be generated dynamically.  The execute of this statement would
-- occur during the same transaction as the insert into surveys to ensure the correct
-- survey_id is assigned to the selections.
prepare survey_choices as
insert into survey_selections
 (survey_id
 ,selection_body
 ,selection_count)
values
 (select currval('surveys_survey_id_seq')
 ,'selection-body-1'
 ,0),
 (select currval('surveys_survey_id_seq')
 ,'selection-body-2'
 ,0),
 (select currval('surveys_survey_id_seq')
 ,'selection-body-3'
 ,0);

execute survey_choices;

-- Surveys would be presented on the property page using two cursors.  The first cursor
-- will bring back the ten latest surveys while the second cursor will bring back the
-- survey choices for each survey.  Note the property_id variable and the survey_id
-- variable would be bound at cursor open.

declare survey_cursor cursor for
 select su.survey_id
       ,su.survey_body
       ,su.survey_open_date
       ,su.survey_close_date
   from surveys su
   join property_owners po
     on su.property_owner_id = po.property_owner_id
  where po.property_id = property-id
order by su.survey_open_date desc
  limit 10;

declare survey_selection_cursor cursor for
 select ss.selection_body
       ,ss.selection_count
   from survey_selections ss
  where ss.survey_id = survey-id;

open survey_cursor;

-- iterate for the property
fetch survey_cursor
 into su-survey-id
     ,su-survey-body
     ,su-survey-open-date
     ,su-survey-close-date;

open survey_selection_cursor;

-- iterate for each survey for the property
fetch survey_selection_cursor
 into ss-selection-body
     ,ss-selection-count;

close survey_selection_cursor;
close survey_cursor;

-- respond to a survey
update survey_selections
   set selection_count = selection_count + 1
 where survey_selection_id = survey-selection-id
   and survey_id = survey-id;

-- UPDATE PROPERTIES
-- Owners, or their authorized agents, must be able to update their property details
-- including uploading images.  Note that UPDATE AUTHORIZATION would be checked first
-- at EITHER level.  SQL will be dynamically generated as it is unknown how many property
-- columns or images will be updated.  The modification of certain columns prompt the
-- setting of the modified_ind to true.  For example, setting the for_sale_ind to true
-- would cause the application to set the modified_ind to true as well.  The modified_ind
-- is used by a batch process to periodically alert interested users certain changes.
-- All subscribers of the property will be notified via email in real-time.

prepare update_property as
update properties
   set for_sale_ind = for-sale-ind
      ,sale_price = sale-price
      ,modified_ind = modified-ind
 where property_id = property-id;
execute update_property;

prepare change_images as
delete from images where image_id = image-id;
execute change_images;

-- a cursor will select subscriber details for the property just modified.
declare subscribers_cursor cursor for
select u.user_screen_nm
      ,u.user_email_address
 from users u
 join property_subscriptions s on u.user_id = s.user_id
where s.property_id = p-property-id
;
open subscribers_cursor;

-- iterate
fetch subscribers_cursor into ...;
-- generate an email
close subscribers_cursor;

-- SUBSCRIBE TO PROPERTIES
-- Users must be able to subscribe to and unsubscribe from properties.
-- Subscriptions should be categorized based on user interest in the property.

-- users will be presented with their active property subscriptions
select ps.property_subscription_id
      ,p.property_id
      ,p.street
      ,p.city
      ,p.state
      ,p.zipcode
      ,p.lot_size
      ,p.for_sale_ind
      ,p.sale_price
      ,p.bedroom_count
      ,p.bathroom_count
      ,p.house_size
      ,p.garage_car_count
      ,i.image_file_path
      ,sr.subscription_reason
  from property_subscriptions ps
  join subscription_reasons sr on ps.subscription_reason_id = sr.subscription_reason_id
  join properties p on ps.property_id = p.property_id
  left outer join images i on p.property_id = i.property_id
                          and i.primary_image_ind is true
 where ps.user_id = user-id
   and cancel_date is null;

-- the application will allow a user to cancel a subscription
update property_subscriptions
   set cancel_date = current_date
 where property_subscription_id = property-subscription-id
;

-- on a property page a logged in user will be allowed to subscribe to a property, the
-- subscription reason will be chosen via a dynamically generated drop-down menu feature
-- which is translated by the application into a subscription_reason_id.

insert into property_subscriptions
(user_id
,property_id
,active_date
,cancel_date
,subscription_reason_id)
values
(user-id
,property-id
,current_date
,NULL
,subscription-reason-id)
;

-- the application will notify property owners or agents of the subscription,
-- a cursor will select owner/agent details for the subscribed property.
declare alert_cursor cursor for
select u.user_screen_nm
      ,u.user_email_address
 from users u
 join property_owners po
   on u.user_id = po.user_id
where po.property_id = p-property-id
union
select u.user_screen_nm
      ,u.user_email_address
 from users u
 join property_agents pa
   on u.user_id = pa.user_id
where pa.property_id = p-property-id
;
open alert_cursor;

-- iterate
fetch alert_cursor into ...;
-- generate an email
close alert_cursor;

-- PREDICT PROPERTY MARKET POSITION
-- Owners, or their authorized agents, must be able to update their property details,
-- in a temporary way, to gain insight into how a property change might position their
-- property differently in the market.  A worksheet will be presented to the user by selecting
-- all their property attributes.

select p.property_id
      ,p.street
      ,p.city
      ,p.state
      ,p.zipcode
      ,p.lot_size
      ,p.sale_price
      ,p.bedroom_count
      ,p.bathroom_count
      ,p.house_size
      ,p.garage_car_count
      ,ast.architectural_style
 from properties p
 left outer join architectural_styles ast on p.architectural_style_id = ast.architectural_style_id
where p.property_id = property-id
;

-- the user is also given a count of all user searches that return his/her home with its
-- current attributes

select count(*)
  from searches s
 where s.minimum_garage_car_count <= p-garage-car-count
   and s.for_sale_ind = p-for-sale-ind
   and s.minimum_lot_size <= p-lot-size
   and s.maximum_lot_size >= p-lot-size
   and s.minimum_bedroom_count <= p-bedroom-count
   and s.maximum_bedroom_count >= p-bedroom-count
   and s.minimum_spend <= p-sale-price
   and s.maximum_spend >= p-sale-price
;

-- the user can then modify some of the attributes of their house via the application to see
-- how many user searches would return their home.  The above SQL is again executed.

-- LOCK OR UNLOCK MY PROPERTY
-- Owners, or their authorized agents, must be able to lock or unlock their properties
-- to toggle the disabling and enabling of the Property Ladder community from systematically
-- including the property in their discussions.  A user would be signed into the system
-- to do this, would be presented with houses for which they are owners or agents and would
-- choose a single or all properties to update.

-- present choices
select p.property_id
      ,p.street
      ,p.city
      ,p.state
      ,p.zipcode
      ,p.locked_ind
      ,i.image_file_path
      ,'owner' as relationship
  from properties p
  left outer join images i on p.property_id = i.property_id
                          and i.primary_image_ind is true
  join property_owners po on po.property_id = p.property_id
 where po.user_id = user-id
union
select p.property_id
      ,p.street
      ,p.city
      ,p.state
      ,p.zipcode
      ,p.locked_ind
      ,i.image_file_path
      ,'agent' as relationship
  from properties p
  left outer join images i on p.property_id = i.property_id
                          and i.primary_image_ind is true
  join property_agents pa on pa.property_id = p.property_id
 where pa.user_id = user-id
;

-- update a single property
update properties
   set locked_ind = true
 where property_id = property-id
;

-- update all properties
update properties
   set locked_ind = false
 where property_id in
(select p.property_id
   from properties p
   join property_owners po on p.property_id = po.property_id
                          and po.user_id = property-id
 union
 select p.property_id
   from properties p
   join property_agents pa on p.property_id = pa.property_id
                          and pa.user_id = property-id)
   and locked_ind is true
;

-- NOTIFY USERS
-- The system must be able to periodically notify users about changes in saved search results,
-- subscribed properties (see the UPDATE PROPERTIES section), subscriptions to their
-- properties (see the SUBSCRIBE TO PROPERTIES section), comments originally posted by them
-- (see the VIEW AND POST COMMENTS SECTION) or the receipt of private messages (see the
-- SEND AND RECEIVE PRIVATE MESSAGES section).

-- a cursor will select property details about each property for which the modified_ind is
-- set to true.  With hold is coded to allow for commits, see below.
declare properties_cursor cursor with hold for
select p.property_id
      ,p.street
      ,p.city
      ,p.state
      ,p.zipcode
      ,p.lot_size
      ,p.sale_price
      ,p.bedroom_count
      ,p.bathroom_count
      ,p.house_size
      ,p.garage_car_count
      ,ast.architectural_style
 from properties p
 left outer join architectural_styles ast on p.architectural_style_id = ast.architectural_style_id
where p.modified_ind is true
  and p.for_sale_ind is true
;

-- a cursor will be declared to pull the contact details of all users who have searches
-- for which a new home coming on the market meets the criteria.
declare searches_cursor cursor with hold for
select u.user_screen_nm
      ,u.user_email_address
  from searches s
  join users u on s.user_id = u.user_id
 where s.minimum_garage_car_count <= p-garage-car-count
   and s.for_sale_ind is true
   and s.minimum_lot_size <= p-lot-size
   and s.maximum_lot_size >= p-lot-size
   and s.minimum_bedroom_count <= p-bedroom-count
   and s.maximum_bedroom_count >= p-bedroom-count
   and s.minimum_spend <= p-sale-price
   and s.maximum_spend >= p-sale-price
;

open properties_cursor;

-- iterate
fetch properties_cursor into ...;
-- open a cursor against the searches table to retrieve the search characteristics of all
-- searches searching for houses for sale, their users will want to know a new house that
-- meets their search criteria is for sale.
open searches_cursor;
-- iterate
fetch searches_cursor into ...;
-- generate email
close searches_cursor;

-- set the modified_ind back to false
update properties
   set modified_ind = false
 where current of properties_cursor;

-- periodically commit to release x-locks
commit;

close properties_cursor;


-- MODIFY PROPERTY VALUES
-- The system must be able to periodically update the estimated value of properties,
-- based on changes in the market, to pro-actively provide users market insight.
-- This will be done using a batch process that presumably receives a single change in
-- market value percentage at the zipcode level.  Data of recent sales will also be used
-- to update market value, that data would contain a property address with a recent sales
-- price.  The application will handle deciding whether sale prices should be applied to
-- market value, for example a sale between relatives for $1 would not set the new market
-- price of the property to $1.

-- update based on region data
update properties
   set market_value = market_value * market-change-value
 where zipcode = 'zipcode'
;

-- update based on recent sale
update properties
   set market_value = market-value
 where zipcode = 'zipcode'
   and street ilike 'street'
;

-- owners and agents would be notified of the value change
declare alert_cursor cursor for
select u.user_screen_nm
      ,u.user_email_address
 from users u
 join property_owners po on u.user_id = po.user_id
where po.property_id = p-property-id
union
select u.user_screen_nm
      ,u.user_email_address
 from users u
 join property_agents pa on u.user_id = pa.user_id
where pa.property_id = p-property-id
;
open alert_cursor;

-- iterate
fetch alert_cursor into ...;
-- generate an email
close alert_cursor;

-- subscribers would be notified of the value change
declare subscribers_cursor cursor for
select u.user_screen_nm
      ,u.user_email_address
 from users u
 join property_subscriptions s on u.user_id = s.user_id
where s.property_id = p-property-id
;
open subscribers_cursor;

-- iterate
fetch subscribers_cursor into ...;
-- generate an email
close subscribers_cursor;
