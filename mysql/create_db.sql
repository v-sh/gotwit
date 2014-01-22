
drop database if exists gotwit;

create database gotwit;

use gotwit;

-- create taibles

create table users(
       id int not null auto_increment,
       email varchar(100) not null,
       password_sha varchar(50) not null,
       nick_name varchar(50) not null,
       first_name varchar(20),
       second_name varchar(30),
       birthday date,
       gender ENUM('','F','M'),
       description varchar(300),
       avatar_id int,
       primary key ( id )
);

create table subscriptions(
       first_user int not null,
       second_user int not null,
       primary key (first_user, second_user)
);

create table post_contents(
       id int not null auto_increment,
       text varchar(500),
       author_id int not null,
       primary key (id)
);

create table posts(
       id int not null auto_increment,
       author_id int not null,
       is_repost bool,
       content_id int not null,
       creation_time datetime not null,
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
       creation_time datetime not null,
       text varchar(100) not null,
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


