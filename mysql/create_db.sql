
drop database if exists gotwit;

create database gotwit;

use gotwit;

-- create taibles

create table users(
       id int not null auto_increment,
       email varchar(100) not null,
       password_sha varchar(40) not null,
       nick_name varchar(20) not null,
       first_name varchar(20) default '',
       second_name varchar(20) default '',
       birthday date,
       gender ENUM('','F','M') not null default '',
       description varchar(300) not null default '',
       avatar_id int,
       verified bool not null default 0,
       drop_pass_token varchar(30),
       drop_pass_time timestamp not null default '1971-01-01 00:00:00',
       primary key ( id )
);

create table subscriptions(
       first_user int not null,
       second_user int not null,
       primary key (first_user, second_user)
);

create table post_contents(
       id int not null auto_increment,
       text varchar(1000),
       author_id int not null,
       image_id int,
       primary key (id)
);

create table posts(
       id int not null auto_increment,
       author_id int not null,
       content_id int not null,
       creation_time timestamp not null default current_timestamp,
       primary key ( id )
);

create table images(
       id int not null auto_increment,
       file_id int not null,
       primary key ( id )
);

create table storage_files(
       id int not null auto_increment,
       uploader_id int not null,
       s3_id varchar(100) not null,
       primary key ( id )
);

create table comments(
       id int not null auto_increment,
       creation_time timestamp not null default current_timestamp,
       text varchar(500) not null,
       post_id int not null,
       author_id int not null,
       primary key ( id )
);

create table likes(
       author_id int not null,
       post_id int not null,
       like_type enum('','+','-'),
       primary key (author_id, post_id)
);


-- add foreign keys

alter table users
      add foreign key ( avatar_id )
      references images ( id )
      on delete set null
      on update cascade;

alter table subscriptions
       add foreign key ( first_user )
       references users(id)
       on delete cascade
       on update cascade;

alter table subscriptions
       add foreign key ( second_user )
       references users(id)
       on delete cascade
       on update cascade;

alter table post_contents
      add foreign key ( author_id )
      references users(id)
      on delete cascade
      on update cascade;

alter table post_contents
      add foreign key ( image_id )
      references images ( id )
      on delete cascade
      on update cascade;

alter table posts
      add foreign key ( author_id )
      references users(id)
      on delete cascade
      on update cascade;

alter table posts
      add foreign key ( content_id )
      references post_contents ( id )
      on delete cascade
      on update cascade;

alter table storage_files
      add foreign key ( uploader_id )
      references users ( id )
      on delete cascade
      on update cascade;

alter table images
      add foreign key ( file_id )
      references storage_files ( id )
      on delete cascade
      on update cascade;

alter table comments
      add foreign key ( post_id )
      references posts ( id )
      on delete cascade
      on update cascade;

alter table comments
      add foreign key ( author_id )
      references users ( id )
      on delete cascade
      on update cascade;

alter table likes
      add foreign key ( author_id )
      references users ( id )
      on delete cascade
      on update cascade;

alter table likes
      add foreign key ( post_id )
      references posts ( id )
      on delete cascade
      on update cascade;


-- create indexes

create unique index users_nick_name_index
       on users ( nick_name ) using hash;

create index subscriptions_first_user_index
       on subscriptions ( first_user ) using hash;

create index subscriptions_second_user_index
       on subscriptions ( second_user ) using hash;

create index posts_author_index
       on posts ( author_id ) using hash;

create index posts_creation_time_index
       on posts ( creation_time ) using btree;

create index comments_creation_time_index
       on comments ( creation_time ) using btree;

create index likes_post_id_index
       on likes ( post_id ) using hash;


-- check constraints, yes f... mysql, use triggers and functions!!!
-- SET GLOBAL log_bin_trust_function_creators = 1;

delimiter //

create function test_user_email (email varchar(100))
       returns bool
       deterministic
begin
	return email regexp '^[^@]+@[^@]+\.[^@]{2,}$';
end//

create function test_user_nick (nick_name varchar(20))
       returns bool
       deterministic
begin
	return nick_name regexp '^[a-zA-Z0-9]+$';
end//

create function test_user_birthday (birthday datetime)
       returns bool
       deterministic
begin
	return birthday >= '1900-01-01' and birthday <= curdate();
end//

create trigger test_users_before_insert before insert on users
for each row begin
    if not test_user_email(new.email) or 
       not test_user_nick(new.nick_name) or 
       not test_user_birthday(new.birthday) then
       signal sqlstate '45001' set message_text = 'icorrect user data';
    end if;
end//

create trigger test_users_before_update before update on users
for each row begin
    if not test_user_email(new.email) or not test_user_nick(new.nick_name) then
       signal sqlstate '45001' set message_text = 'icorrect user data';
    end if;
end//

create trigger test_post_content_before_insert before insert on post_contents
for each row begin
    if new.text is null and new.image_id is null then
       signal sqlstate '45001' set message_text = 'epmty post content';
    end if;
end//

create trigger test_post_content_before_update before update on post_contents
for each row begin
    if new.text is null and new.image_id is null then
       signal sqlstate '45001' set message_text = 'epmty post content';
    end if;
end//

create function test_user_pass (user_pass varchar(50))
       returns bool
       deterministic
begin
	return user_pass regexp '^[a-zA-Z0-9]{6,}$';
end//

create function test_user_pass_sha (user_nick varchar(20), pass varchar(100))
       returns bool
       deterministic
begin
	if not test_user_pass(pass) then
	   return 0;
	end if;
	return (select password_sha from users where nick = user_nick) = sha1(pass);
end//

create procedure create_user (email varchar(100), nick_name varchar(20), pass varchar(100), first_name varchar(20),
       		 	      second_name varchar(20), birthday date, gender ENUM('', 'F', 'M'),
			      description varchar(300), avatar_id int)
begin
	if not test_user_pass(pass) then
       	   signal sqlstate '45001' set message_text = 'incorrect pass';	   
	end if;
	if (select count(*) from users as us where us.nick_name = nick_name and us.verified <> 0) > 0 then
       	   signal sqlstate '45001' set message_text = 'account exists';
	end if;
	set @pass_sha = sha1(pass);
	delete from users
	where users.nick_name = nick_name;
	insert into users
	(email, password_sha, nick_name, first_name, second_name, birthday, gender, description, avatar_id, verified)
	value
	(email, @pass_sha, nick_name, first_name, second_name, birthday, gender, description, avatar_id, 0);
end//

create procedure change_pass(nick varchar(20), current_pass varchar(100), new_pass varchar(100))
begin
	if not test_user_pass_sha(current_pass) then
	   signal sqlstate '45001' set message_text = 'wrong current pass';
	end if;
	if not test_user_pass(new_pass) then
	   signal sqlstate '45001' set message_text = 'incorrect pass';
	end if;
	update users
	set password_sha=sha1(new_pass)
	where users.nick = nick;
end//

create procedure create_drop_token(user_nick varchar(20))
begin
	update users
	set drop_pass_token = substring(md5(rand()),-30),
	drop_pass_time = current_timestamp
	where timestampdiff(day, drop_pass_time, CURRENT_TIMESTAMP) > 1 and
	nick = user_nick;
end//


create procedure try_drop_pass (drop_pass_token varchar(30), new_pass varchar(100))
begin
	set @nick = (select nick_name from users
	    	    where users.drop_pass_token = drop_pass_token and 
		    timestampdiff(day, drop_pass_time, CURRENT_TIMESTAMP) < 1);
	if count(@nick) = 0 then
	   signal sqlstate '45001' set message_text = 'incorrect or old drop link';
	end if;
	update users
	set password_sha=sha1(new_pass)
	where users.nick = nick;
end//

delimiter ;
