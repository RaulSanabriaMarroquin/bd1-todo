create database if not exists todopii;
USE todopii;


CREATE TABLE IF NOT EXISTS `clients` (
  `client-id` VARCHAR(50) NOT NULL,
  `client-secret` VARCHAR(50) NULL,
  
  PRIMARY KEY (`client-id`),
  KEY `client-secret` (`client-secret`));
  
  
  CREATE TABLE IF NOT EXISTS `sessions` (
  `session-id` VARCHAR(50) NOT NULL,
  `client-id` VARCHAR(50) NULL,
  `createdat` timestamp NOT NULL,

  PRIMARY KEY (`session-id`),
  KEY `createdat` (`createdat`),
  FOREIGN KEY (`client-id`) REFERENCES `clients` (`client-id`));

  
  -- Procedimiento almaecenado Tarea 3
  drop procedure if exists create_session;
  delimiter $$
  create procedure create_session(in client_id_param varchar(50), in session_ttl_param int)
  begin
	declare client_id_exists bool;
    declare session_exists bool;
    declare session_diff int;
    
    select if(count(*) = 1, true,false) into client_id_exists from clients where `client-id` = client_id_param;
    
    if client_id_exists = true then
		-- select 'existe';
        select if(count(*) = 1, true, false) into session_exists from sessions where `client-id` = client_id_param;
        if session_exists then
			select minute(timediff(utc_timestamp(), `createdat`)) into session_diff from sessions where `client-id` = client_id_param; 
			if session_diff <= session_ttl_param then
				select `client-id`, `session-id`, `createdat`, if(minute(timediff(utc_timestamp(), `createdat`)) <= session_ttl_param, "ACTIVE", "INACTIVE") as sessionStatus from sessions where `client-id` = client_id_param; 
			else
				start transaction;
					update sessions set `createdat` = utc_timestamp() where `client-id` = client_id_param;
                commit;
				select `client-id`, `session-id`, createdat, if(minute(timediff(utc_timestamp(), `createdat`)) <= session_ttl_param, "ACTIVE", "INACTIVE") as sessionStatus from sessions where `client-id` = client_id_param; 
			end if;
		else
			start transaction;
				insert into sessions(clientid,sessionid,createdat) values(client_id_param,uuid(),utc_timestamp());
				select `client-id`, `session-id`, `createdat`, if(minute(timediff(utc_timestamp(), `createdat`)) <= session_ttl_param, "ACTIVE", "INACTIVE") as sessionStatus from sessions where `client-id` = client_id_param; 
			commit;
		end if;
	else
		select `client-id`, `session-id`, `createdat`, if(minute(timediff(utc_timestamp(), `createdat`)) <= session_ttl_param, "ACTIVE", "INACTIVE") as sessionStatus from sessions where `client-id` = client_id_param; 
	end if;
    
    end
    $$

    call create_session('cliente-1',30);
    call create_session('cliente-13',30);
    call create_session('cliente-5',30);
    

