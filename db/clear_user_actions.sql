DELETE FROM authentications;
DELETE FROM cache_rankings;
DELETE FROM call_to_actions WHERE user_id != null;
DELETE FROM events;
DELETE FROM notices;
DELETE FROM user_comment_interactions;
DELETE FROM user_counters;
DELETE FROM user_interactions;
DELETE FROM user_rewards;
DELETE FROM user_upload_interactions;