/*==============================================================*/
/* DBMS name:      MySQL 8.0                                    */
/* Created on:     2026/11/7 19:52:12                           */
/*==============================================================*/

/*==============================================================*/
/* Table: course                                                */
/*==============================================================*/
create table course
(
   timetable_id         int not null comment '引用课表',
   course_no            int not null comment '正整数；在同一课表内唯一',
   course_name          varchar(100) not null comment '去除首尾空格后非空，最长100字符',
   course_remark        varchar(200) comment '可空，最长200字符',
   primary key (timetable_id, course_no),
   check ((course_no > 0) AND (CHAR_LENGTH(TRIM(course_name)) BETWEEN 1 AND 100))
)
ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

alter table course comment '保存某课表内的课程基本信息，允许同名课程';

/*==============================================================*/
/* Index: course_PK                                             */
/*==============================================================*/
create unique index course_PK on course
(
   timetable_id,
   course_no
);

/*==============================================================*/
/* Index: ix_c_name                                             */
/*==============================================================*/
create index ix_c_name on course
(
   timetable_id,
   course_name
);

/*==============================================================*/
/* Table: course_meeting                                        */
/*==============================================================*/
create table course_meeting
(
   timetable_id         int not null comment '随课程标识引用；与节次属于同一课表',
   course_no            int not null comment '与课表编号共同引用课程',
   meeting_no           int not null comment '正整数；在同一门课程内唯一',
   day_of_week          smallint not null comment '1～7，依次代表星期一至星期日',
   start_period         smallint not null comment '引用本课表的节次，不大于结束节次',
   end_period           smallint not null comment '引用本课表的节次，不小于开始节次',
   teacher_name         varchar(100) comment '可空，最长100字符',
   location             varchar(100) comment '可空，最长100字符',
   meeting_remark       varchar(200) comment '可空，最长200字符',
   primary key (timetable_id, course_no, meeting_no),
   check ((meeting_no > 0) AND (day_of_week BETWEEN 1 AND 7) AND (start_period <= end_period))
)
ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

alter table course_meeting comment '保存课程的星期、节次、教师与地点';

/*==============================================================*/
/* Index: course_meeting_PK                                     */
/*==============================================================*/
create unique index course_meeting_PK on course_meeting
(
   timetable_id,
   course_no,
   meeting_no
);

/*==============================================================*/
/* Index: ix_cm_day                                             */
/*==============================================================*/
create index ix_cm_day on course_meeting
(
   timetable_id,
   day_of_week,
   start_period,
   end_period
);

/*==============================================================*/
/* Table: meeting_week                                          */
/*==============================================================*/
create table meeting_week
(
   timetable_id         int not null comment '与课程、安排编号共同引用上课安排',
   course_no            int not null comment '随安排标识引用',
   meeting_no           int not null comment '随安排标识引用',
   week_no              smallint not null comment '1～53，且在所属课表的起止周内',
   week_note            varchar(200) comment '可空，记录该周安排说明，最长200字符',
   primary key (timetable_id, course_no, meeting_no, week_no),
   check ((week_no BETWEEN 1 AND 53))
)
ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

alter table meeting_week comment '每条记录表示一个上课安排在一个具体周次生效';

/*==============================================================*/
/* Index: meeting_week_PK                                       */
/*==============================================================*/
create unique index meeting_week_PK on meeting_week
(
   timetable_id,
   course_no,
   meeting_no,
   week_no
);

/*==============================================================*/
/* Index: ix_mw_week                                            */
/*==============================================================*/
create index ix_mw_week on meeting_week
(
   timetable_id,
   week_no,
   course_no,
   meeting_no
);

/*==============================================================*/
/* Table: period_time                                           */
/*==============================================================*/
create table period_time
(
   timetable_id         int not null comment '引用课表',
   period_no            smallint not null comment '1～24，在同一课表内唯一',
   start_time           time not null comment '00:00:00～23:59:59，早于结束时间',
   end_time             time not null comment '00:00:00～23:59:59，晚于开始时间',
   primary key (timetable_id, period_no),
   check ((period_no BETWEEN 1 AND 24) AND (start_time >= '00:00:00' AND end_time <= '23:59:59' AND start_time < end_time))
)
ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

alter table period_time comment '保存每张课表的日内节次时间';

/*==============================================================*/
/* Index: period_time_PK                                        */
/*==============================================================*/
create unique index period_time_PK on period_time
(
   timetable_id,
   period_no
);

/*==============================================================*/
/* Table: timetable                                             */
/*==============================================================*/
create table timetable
(
   timetable_id         int not null comment '正整数；由调用方分配',
   timetable_name       varchar(50) not null comment '去除首尾空格后非空，最长50字符',
   term_start_date      date not null comment '第一周星期一的日期',
   start_week           smallint not null default 1 comment '1～53，且不大于结束周',
   end_week             smallint not null default 20 comment '1～53，且不小于起始周',
   created_at           datetime not null default CURRENT_TIMESTAMP comment '不晚于修改时间',
   updated_at           datetime not null default CURRENT_TIMESTAMP comment '不早于创建时间',
   primary key (timetable_id),
   check ((timetable_id > 0) AND (CHAR_LENGTH(TRIM(timetable_name)) BETWEEN 1 AND 50) AND (start_week >= 1 AND end_week <= 53 AND start_week <= end_week) AND (WEEKDAY(term_start_date) = 0) AND (created_at <= updated_at))
)
ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

alter table timetable comment '保存个人课表及学期周次范围';

/*==============================================================*/
/* Index: timetable_PK                                          */
/*==============================================================*/
create unique index timetable_PK on timetable
(
   timetable_id
);

/*==============================================================*/
/* Index: ix_tt_updated                                         */
/*==============================================================*/
create index ix_tt_updated on timetable
(
   updated_at
);

alter table course add constraint fk_c_tt foreign key (timetable_id)
      references timetable (timetable_id) on delete restrict on update restrict;

alter table course_meeting add constraint fk_cm_c foreign key (timetable_id, course_no)
      references course (timetable_id, course_no) on delete restrict on update restrict;

alter table course_meeting add constraint fk_cm_end foreign key (timetable_id, end_period)
      references period_time (timetable_id, period_no) on delete restrict on update restrict;

alter table course_meeting add constraint fk_cm_start foreign key (timetable_id, start_period)
      references period_time (timetable_id, period_no) on delete restrict on update restrict;

alter table meeting_week add constraint fk_mw_cm foreign key (timetable_id, course_no, meeting_no)
      references course_meeting (timetable_id, course_no, meeting_no) on delete restrict on update restrict;

alter table period_time add constraint fk_pt_tt foreign key (timetable_id)
      references timetable (timetable_id) on delete restrict on update restrict;

