-- MySQL 8.0: 跨表完整性与课表删除事务
SET NAMES utf8mb4;
DELIMITER $$

CREATE TRIGGER tr_mw_i BEFORE INSERT ON meeting_week FOR EACH ROW
BEGIN
  DECLARE v_start SMALLINT;
  DECLARE v_end SMALLINT;
  SELECT start_week,end_week INTO v_start,v_end FROM timetable
    WHERE timetable_id=NEW.timetable_id FOR SHARE;
  IF NEW.week_no < v_start OR NEW.week_no > v_end THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='生效周次不在课表的学期范围内';
  END IF;
END$$

CREATE TRIGGER tr_mw_u BEFORE UPDATE ON meeting_week FOR EACH ROW
BEGIN
  DECLARE v_start SMALLINT;
  DECLARE v_end SMALLINT;
  SELECT start_week,end_week INTO v_start,v_end FROM timetable
    WHERE timetable_id=NEW.timetable_id FOR SHARE;
  IF NEW.week_no < v_start OR NEW.week_no > v_end THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='生效周次不在课表的学期范围内';
  END IF;
END$$

CREATE TRIGGER tr_tt_u BEFORE UPDATE ON timetable FOR EACH ROW
BEGIN
  DECLARE v_bad SMALLINT DEFAULT NULL;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_bad=NULL;
  IF NEW.start_week<>OLD.start_week OR NEW.end_week<>OLD.end_week THEN
    SELECT week_no INTO v_bad FROM meeting_week WHERE timetable_id=OLD.timetable_id
      AND (week_no<NEW.start_week OR week_no>NEW.end_week) LIMIT 1 FOR SHARE;
    IF v_bad IS NOT NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='修改学期范围前须先调整越界的已有周次';
    END IF;
  END IF;
END$$

CREATE TRIGGER tr_pt_i BEFORE INSERT ON period_time FOR EACH ROW
BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=NEW.timetable_id FOR UPDATE;
  IF EXISTS(SELECT 1 FROM period_time WHERE timetable_id=NEW.timetable_id
     AND ((period_no<NEW.period_no AND end_time>NEW.start_time)
       OR (period_no>NEW.period_no AND start_time<NEW.end_time))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='节次时间须按编号先后排列且不能重叠';
  END IF;
END$$

CREATE TRIGGER tr_pt_u BEFORE UPDATE ON period_time FOR EACH ROW
BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=NEW.timetable_id FOR UPDATE;
  IF (NEW.timetable_id<>OLD.timetable_id OR NEW.period_no<>OLD.period_no)
    AND EXISTS(SELECT 1 FROM course_meeting WHERE timetable_id=OLD.timetable_id
      AND OLD.period_no BETWEEN start_period AND end_period) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='被上课安排使用的节次编号不可直接修改';
  END IF;
  IF EXISTS(SELECT 1 FROM period_time WHERE timetable_id=NEW.timetable_id AND period_no<>OLD.period_no
     AND ((period_no<NEW.period_no AND end_time>NEW.start_time)
       OR (period_no>NEW.period_no AND start_time<NEW.end_time))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='节次时间须按编号先后排列且不能重叠';
  END IF;
END$$

CREATE TRIGGER tr_pt_d BEFORE DELETE ON period_time FOR EACH ROW
BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=OLD.timetable_id FOR UPDATE;
  IF EXISTS(SELECT 1 FROM course_meeting WHERE timetable_id=OLD.timetable_id
       AND OLD.period_no BETWEEN start_period AND end_period) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='被上课安排使用的节次不可直接删除';
  END IF;
END$$

CREATE TRIGGER tr_cm_i BEFORE INSERT ON course_meeting FOR EACH ROW
BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=NEW.timetable_id FOR SHARE;
  IF NEW.start_period<=NEW.end_period AND
    (SELECT COUNT(*) FROM period_time WHERE timetable_id=NEW.timetable_id
      AND period_no BETWEEN NEW.start_period AND NEW.end_period) <> NEW.end_period-NEW.start_period+1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='上课安排的起止及中间节次必须全部存在';
  END IF;
END$$

CREATE TRIGGER tr_cm_u BEFORE UPDATE ON course_meeting FOR EACH ROW
BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=NEW.timetable_id FOR SHARE;
  IF NEW.start_period<=NEW.end_period AND
    (SELECT COUNT(*) FROM period_time WHERE timetable_id=NEW.timetable_id
      AND period_no BETWEEN NEW.start_period AND NEW.end_period) <> NEW.end_period-NEW.start_period+1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='上课安排的起止及中间节次必须全部存在';
  END IF;
END$$

CREATE PROCEDURE sp_delete_timetable(IN p_timetable_id INT)
BEGIN
  DECLARE v_lock INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=p_timetable_id FOR UPDATE;
  DELETE FROM meeting_week WHERE timetable_id=p_timetable_id;
  DELETE FROM course_meeting WHERE timetable_id=p_timetable_id;
  DELETE FROM course WHERE timetable_id=p_timetable_id;
  DELETE FROM period_time WHERE timetable_id=p_timetable_id;
  DELETE FROM timetable WHERE timetable_id=p_timetable_id;
  COMMIT;
END$$
DELIMITER ;
