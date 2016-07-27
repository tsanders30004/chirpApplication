create view v_follows as
select chirper_id, follower_id, chirpers.handle as chirper_handle, chirpers.fname as chirper_fname, chirpers.lname as chirper_lname, followers.handle as follower_handle, followers.fname as follower_fname, followers.lname as follower_lname
from follows
left join users as chirpers on follows.chirper_id = chirpers.id
left join users as followers on follows.follower_id = followers.id
