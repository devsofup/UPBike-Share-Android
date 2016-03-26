-- Database: bikeshare

-- DROP DATABASE bikeshare;

       
CREATE TABLE articles (
id SERIAL PRIMARY KEY,
name VARCHAR(50),
content TEXT,
created_at TIMESTAMP,
updated_at TIMESTAMP
);

CREATE TABLE users(
id SERIAL PRIMARY KEY,
email VARCHAR(20),
encrypted_password VARCHAR(32),
reset_password_token VARCHAR(32),
reset_password_sent_at TIMESTAMP,
remember_created_at TIMESTAMP,
sign_in_count INT,
current_sign_in_at TIMESTAMP,
last_sign_in_at TIMESTAMP,
current_sign_in_ip VARCHAR(20),
last_sign_in_ip VARCHAR(20),
created_at TIMESTAMP,
updated_at TIMESTAMP,
role INT,
first_name VARCHAR(30),
middle_name VARCHAR(20),
last_name VARCHAR(20),
user_name VARCHAR(20)
);

CREATE TABLE bikes (
id SERIAL PRIMARY KEY,
state VARCHAR(10),
location VARCHAR(20),
created_at TIMESTAMP,
updated_at TIMESTAMP
);

CREATE TABLE location_records(
id SERIAL PRIMARY KEY,
location VARCHAR(20),
from_loc TIMESTAMP,
to_loc TIMESTAMP,
average_bikes INT
);

CREATE TABLE ongoing_share(
id SERIAL PRIMARY KEY,
user_id INT references users(id),
bike_id INT references bikes(id),
departure_time TIMESTAMP,
departure_loc VARCHAR(20),
route VARCHAR(20)
);

CREATE TABLE reports(
id SERIAL PRIMARY KEY,
user_id INT references users(id),
bike_id INT references bikes(id),
reportinfo TEXT,
created_at TIMESTAMP,
updated_at TIMESTAMP
);

CREATE TABLE share_history(
id SERIAL PRIMARY KEY,
user_id INT references users(id),
bike_id INT references bikes(id),
departure_time TIMESTAMP,
departure_loc VARCHAR(20),
arrival_time TIMESTAMP,
arrival_loc VARCHAR(20),
route VARCHAR(20)
);

CREATE FUNCTION bike_state_update_reserve()
RETURNS TRIGGER AS $value$
	BEGIN
		UPDATE bikes
		SET state="RESERVED", updated_at=CURRENT_TIMESTAMP
		WHERE id=NEW.bike_id;
		RETURN value;
	END;
$value$ LANGUAGE plpgsql;

CREATE FUNCTION bike_state_update_report()
RETURNS TRIGGER AS $value$
	BEGIN
		UPDATE bikes
		SET state="Under Investigation", updated_at=CURRENT_TIMESTAMP
		WHERE id=NEW.bike_id;
		RETURN value;
	END;
$value$ LANGUAGE plpgsql;

CREATE TRIGGER after_ongoing_share_insert_update_bikes AFTER INSERT
ON ongoing_share
FOR EACH ROW EXECUTE PROCEDURE bike_state_update_reserve();

CREATE TRIGGER after_reports_insert_update_bikes AFTER INSERT
ON reports
FOR EACH ROW EXECUTE PROCEDURE bike_state_update_report();