-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: personal_timetable
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course` (
  `timetable_id` int NOT NULL COMMENT '引用课表',
  `course_no` int NOT NULL COMMENT '正整数；在同一课表内唯一',
  `course_name` varchar(100) NOT NULL COMMENT '去除首尾空格后非空，最长100字符',
  `course_remark` varchar(200) DEFAULT NULL COMMENT '可空，最长200字符',
  PRIMARY KEY (`timetable_id`,`course_no`),
  UNIQUE KEY `course_PK` (`timetable_id`,`course_no`),
  KEY `ix_c_name` (`timetable_id`,`course_name`),
  CONSTRAINT `fk_c_tt` FOREIGN KEY (`timetable_id`) REFERENCES `timetable` (`timetable_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `course_chk_1` CHECK (((`course_no` > 0) and (char_length(trim(`course_name`)) between 1 and 100)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='保存某课表内的课程基本信息，允许同名课程';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course`
--

LOCK TABLES `course` WRITE;
/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES (1,1,'数据库原理及应用','理论与实验分时安排'),(1,2,'高等数学',NULL),(1,3,'大学英语',NULL),(1,4,'体育',NULL),(1,5,'程序设计实践','用于演示冲突提示'),(1,6,'学术写作','不连续周次'),(2,1,'数据库原理及应用','用于验证同编号跨课表隔离'),(2,2,'离散数学',NULL);
/*!40000 ALTER TABLE `course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_meeting`
--

DROP TABLE IF EXISTS `course_meeting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_meeting` (
  `timetable_id` int NOT NULL COMMENT '随课程标识引用；与节次属于同一课表',
  `course_no` int NOT NULL COMMENT '与课表编号共同引用课程',
  `meeting_no` int NOT NULL COMMENT '正整数；在同一门课程内唯一',
  `day_of_week` smallint NOT NULL COMMENT '1～7，依次代表星期一至星期日',
  `start_period` smallint NOT NULL COMMENT '引用本课表的节次，不大于结束节次',
  `end_period` smallint NOT NULL COMMENT '引用本课表的节次，不小于开始节次',
  `teacher_name` varchar(100) DEFAULT NULL COMMENT '可空，最长100字符',
  `location` varchar(100) DEFAULT NULL COMMENT '可空，最长100字符',
  `meeting_remark` varchar(200) DEFAULT NULL COMMENT '可空，最长200字符',
  PRIMARY KEY (`timetable_id`,`course_no`,`meeting_no`),
  UNIQUE KEY `course_meeting_PK` (`timetable_id`,`course_no`,`meeting_no`),
  KEY `ix_cm_day` (`timetable_id`,`day_of_week`,`start_period`,`end_period`),
  KEY `fk_cm_end` (`timetable_id`,`end_period`),
  KEY `fk_cm_start` (`timetable_id`,`start_period`),
  CONSTRAINT `fk_cm_c` FOREIGN KEY (`timetable_id`, `course_no`) REFERENCES `course` (`timetable_id`, `course_no`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_cm_end` FOREIGN KEY (`timetable_id`, `end_period`) REFERENCES `period_time` (`timetable_id`, `period_no`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_cm_start` FOREIGN KEY (`timetable_id`, `start_period`) REFERENCES `period_time` (`timetable_id`, `period_no`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `course_meeting_chk_1` CHECK (((`meeting_no` > 0) and (`day_of_week` between 1 and 7) and (`start_period` <= `end_period`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='保存课程的星期、节次、教师与地点';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_meeting`
--

LOCK TABLES `course_meeting` WRITE;
/*!40000 ALTER TABLE `course_meeting` DISABLE KEYS */;
INSERT INTO `course_meeting` VALUES (1,1,1,1,1,2,'陈老师','教学楼A101','理论课'),(1,1,2,3,5,6,'陈老师','实验楼B201','实验课'),(1,2,1,2,1,2,'李老师','教学楼A102',NULL),(1,3,1,1,3,4,'周老师','教学楼A103',NULL),(1,4,1,5,7,8,'王老师','运动场',NULL),(1,5,1,1,2,3,'赵老师','实验楼B202','第3周与数据库课重叠'),(1,6,1,4,5,6,'孙老师','教学楼A104',NULL),(2,1,1,1,1,2,'陈老师','教学楼A101',NULL),(2,2,1,2,3,4,'刘老师','教学楼A105',NULL);
/*!40000 ALTER TABLE `course_meeting` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_cm_i` BEFORE INSERT ON `course_meeting` FOR EACH ROW BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=NEW.timetable_id FOR SHARE;
  IF NEW.start_period<=NEW.end_period AND
    (SELECT COUNT(*) FROM period_time WHERE timetable_id=NEW.timetable_id
      AND period_no BETWEEN NEW.start_period AND NEW.end_period) <> NEW.end_period-NEW.start_period+1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='上课安排的起止及中间节次必须全部存在';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_cm_u` BEFORE UPDATE ON `course_meeting` FOR EACH ROW BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=NEW.timetable_id FOR SHARE;
  IF NEW.start_period<=NEW.end_period AND
    (SELECT COUNT(*) FROM period_time WHERE timetable_id=NEW.timetable_id
      AND period_no BETWEEN NEW.start_period AND NEW.end_period) <> NEW.end_period-NEW.start_period+1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='上课安排的起止及中间节次必须全部存在';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `meeting_week`
--

DROP TABLE IF EXISTS `meeting_week`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_week` (
  `timetable_id` int NOT NULL COMMENT '与课程、安排编号共同引用上课安排',
  `course_no` int NOT NULL COMMENT '随安排标识引用',
  `meeting_no` int NOT NULL COMMENT '随安排标识引用',
  `week_no` smallint NOT NULL COMMENT '1～53，且在所属课表的起止周内',
  `week_note` varchar(200) DEFAULT NULL COMMENT '可空，记录该周安排说明，最长200字符',
  PRIMARY KEY (`timetable_id`,`course_no`,`meeting_no`,`week_no`),
  UNIQUE KEY `meeting_week_PK` (`timetable_id`,`course_no`,`meeting_no`,`week_no`),
  KEY `ix_mw_week` (`timetable_id`,`week_no`,`course_no`,`meeting_no`),
  CONSTRAINT `fk_mw_cm` FOREIGN KEY (`timetable_id`, `course_no`, `meeting_no`) REFERENCES `course_meeting` (`timetable_id`, `course_no`, `meeting_no`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `meeting_week_chk_1` CHECK ((`week_no` between 1 and 53))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='每条记录表示一个上课安排在一个具体周次生效';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_week`
--

LOCK TABLES `meeting_week` WRITE;
/*!40000 ALTER TABLE `meeting_week` DISABLE KEYS */;
INSERT INTO `meeting_week` VALUES (1,1,1,1,NULL),(1,1,1,2,NULL),(1,1,1,3,NULL),(1,1,1,4,NULL),(1,1,1,5,NULL),(1,1,1,6,NULL),(1,1,1,7,NULL),(1,1,1,8,NULL),(1,1,1,9,NULL),(1,1,1,10,NULL),(1,1,1,11,NULL),(1,1,1,12,NULL),(1,1,1,13,NULL),(1,1,1,14,NULL),(1,1,1,15,NULL),(1,1,1,16,NULL),(1,1,1,17,NULL),(1,1,1,18,NULL),(1,1,1,19,NULL),(1,1,1,20,NULL),(1,1,2,2,NULL),(1,1,2,4,NULL),(1,1,2,6,NULL),(1,1,2,8,NULL),(1,1,2,10,NULL),(1,1,2,12,NULL),(1,1,2,14,NULL),(1,1,2,16,NULL),(1,1,2,18,NULL),(1,1,2,20,NULL),(1,2,1,1,NULL),(1,2,1,2,NULL),(1,2,1,3,NULL),(1,2,1,4,NULL),(1,2,1,5,NULL),(1,2,1,6,NULL),(1,2,1,7,NULL),(1,2,1,8,NULL),(1,2,1,9,NULL),(1,2,1,10,NULL),(1,2,1,11,NULL),(1,2,1,12,NULL),(1,2,1,13,NULL),(1,2,1,14,NULL),(1,2,1,15,NULL),(1,2,1,16,NULL),(1,2,1,17,NULL),(1,2,1,18,NULL),(1,2,1,19,NULL),(1,2,1,20,NULL),(1,3,1,1,NULL),(1,3,1,3,NULL),(1,3,1,5,NULL),(1,3,1,7,NULL),(1,3,1,9,NULL),(1,3,1,11,NULL),(1,3,1,13,NULL),(1,3,1,15,NULL),(1,3,1,17,NULL),(1,3,1,19,NULL),(1,4,1,1,NULL),(1,4,1,2,NULL),(1,4,1,3,NULL),(1,4,1,4,NULL),(1,4,1,5,NULL),(1,4,1,6,NULL),(1,4,1,7,NULL),(1,4,1,8,NULL),(1,4,1,9,NULL),(1,4,1,10,NULL),(1,4,1,11,NULL),(1,4,1,12,NULL),(1,4,1,13,NULL),(1,4,1,14,NULL),(1,4,1,15,NULL),(1,4,1,16,NULL),(1,4,1,17,NULL),(1,4,1,18,NULL),(1,4,1,19,NULL),(1,4,1,20,NULL),(1,5,1,3,'冲突演示'),(1,6,1,2,NULL),(1,6,1,5,NULL),(1,6,1,9,NULL),(1,6,1,14,NULL),(2,1,1,1,NULL),(2,1,1,2,NULL),(2,1,1,3,NULL),(2,1,1,4,NULL),(2,1,1,5,NULL),(2,1,1,6,NULL),(2,1,1,7,NULL),(2,1,1,8,NULL),(2,1,1,9,NULL),(2,1,1,10,NULL),(2,1,1,11,NULL),(2,1,1,12,NULL),(2,1,1,13,NULL),(2,1,1,14,NULL),(2,1,1,15,NULL),(2,1,1,16,NULL),(2,1,1,17,NULL),(2,1,1,18,NULL),(2,2,1,1,NULL),(2,2,1,2,NULL),(2,2,1,3,NULL),(2,2,1,4,NULL),(2,2,1,5,NULL),(2,2,1,6,NULL),(2,2,1,7,NULL),(2,2,1,8,NULL),(2,2,1,9,NULL),(2,2,1,10,NULL),(2,2,1,11,NULL),(2,2,1,12,NULL),(2,2,1,13,NULL),(2,2,1,14,NULL),(2,2,1,15,NULL),(2,2,1,16,NULL),(2,2,1,17,NULL),(2,2,1,18,NULL);
/*!40000 ALTER TABLE `meeting_week` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_mw_i` BEFORE INSERT ON `meeting_week` FOR EACH ROW BEGIN
  DECLARE v_start SMALLINT;
  DECLARE v_end SMALLINT;
  SELECT start_week,end_week INTO v_start,v_end FROM timetable
    WHERE timetable_id=NEW.timetable_id FOR SHARE;
  IF NEW.week_no < v_start OR NEW.week_no > v_end THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='生效周次不在课表的学期范围内';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_mw_u` BEFORE UPDATE ON `meeting_week` FOR EACH ROW BEGIN
  DECLARE v_start SMALLINT;
  DECLARE v_end SMALLINT;
  SELECT start_week,end_week INTO v_start,v_end FROM timetable
    WHERE timetable_id=NEW.timetable_id FOR SHARE;
  IF NEW.week_no < v_start OR NEW.week_no > v_end THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='生效周次不在课表的学期范围内';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `period_time`
--

DROP TABLE IF EXISTS `period_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `period_time` (
  `timetable_id` int NOT NULL COMMENT '引用课表',
  `period_no` smallint NOT NULL COMMENT '1～24，在同一课表内唯一',
  `start_time` time NOT NULL COMMENT '00:00:00～23:59:59，早于结束时间',
  `end_time` time NOT NULL COMMENT '00:00:00～23:59:59，晚于开始时间',
  PRIMARY KEY (`timetable_id`,`period_no`),
  UNIQUE KEY `period_time_PK` (`timetable_id`,`period_no`),
  CONSTRAINT `fk_pt_tt` FOREIGN KEY (`timetable_id`) REFERENCES `timetable` (`timetable_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `period_time_chk_1` CHECK (((`period_no` between 1 and 24) and (`start_time` >= '00:00:00') and (`end_time` <= '23:59:59') and (`start_time` < `end_time`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='保存每张课表的日内节次时间';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `period_time`
--

LOCK TABLES `period_time` WRITE;
/*!40000 ALTER TABLE `period_time` DISABLE KEYS */;
INSERT INTO `period_time` VALUES (1,1,'08:00:00','08:45:00'),(1,2,'08:55:00','09:40:00'),(1,3,'10:00:00','10:45:00'),(1,4,'10:55:00','11:40:00'),(1,5,'14:00:00','14:45:00'),(1,6,'14:55:00','15:40:00'),(1,7,'16:00:00','16:45:00'),(1,8,'16:55:00','17:40:00'),(2,1,'08:00:00','08:45:00'),(2,2,'08:55:00','09:40:00'),(2,3,'10:00:00','10:45:00'),(2,4,'10:55:00','11:40:00'),(2,5,'14:00:00','14:45:00'),(2,6,'14:55:00','15:40:00'),(2,7,'16:00:00','16:45:00'),(2,8,'16:55:00','17:40:00');
/*!40000 ALTER TABLE `period_time` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_pt_i` BEFORE INSERT ON `period_time` FOR EACH ROW BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=NEW.timetable_id FOR UPDATE;
  IF EXISTS(SELECT 1 FROM period_time WHERE timetable_id=NEW.timetable_id
     AND ((period_no<NEW.period_no AND end_time>NEW.start_time)
       OR (period_no>NEW.period_no AND start_time<NEW.end_time))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='节次时间须按编号先后排列且不能重叠';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_pt_u` BEFORE UPDATE ON `period_time` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_pt_d` BEFORE DELETE ON `period_time` FOR EACH ROW BEGIN
  DECLARE v_lock INT;
  SELECT timetable_id INTO v_lock FROM timetable WHERE timetable_id=OLD.timetable_id FOR UPDATE;
  IF EXISTS(SELECT 1 FROM course_meeting WHERE timetable_id=OLD.timetable_id
       AND OLD.period_no BETWEEN start_period AND end_period) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='被上课安排使用的节次不可直接删除';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `timetable`
--

DROP TABLE IF EXISTS `timetable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timetable` (
  `timetable_id` int NOT NULL COMMENT '正整数；由调用方分配',
  `timetable_name` varchar(50) NOT NULL COMMENT '去除首尾空格后非空，最长50字符',
  `term_start_date` date NOT NULL COMMENT '第一周星期一的日期',
  `start_week` smallint NOT NULL DEFAULT '1' COMMENT '1～53，且不大于结束周',
  `end_week` smallint NOT NULL DEFAULT '20' COMMENT '1～53，且不小于起始周',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '不晚于修改时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '不早于创建时间',
  PRIMARY KEY (`timetable_id`),
  UNIQUE KEY `timetable_PK` (`timetable_id`),
  KEY `ix_tt_updated` (`updated_at`),
  CONSTRAINT `timetable_chk_1` CHECK (((`timetable_id` > 0) and (char_length(trim(`timetable_name`)) between 1 and 50) and (`start_week` >= 1) and (`end_week` <= 53) and (`start_week` <= `end_week`) and (weekday(`term_start_date`) = 0) and (`created_at` <= `updated_at`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='保存个人课表及学期周次范围';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timetable`
--

LOCK TABLES `timetable` WRITE;
/*!40000 ALTER TABLE `timetable` DISABLE KEYS */;
INSERT INTO `timetable` VALUES (1,'2026秋季学期','2026-09-07',1,20,'2026-11-07 19:54:57','2026-11-07 19:54:57'),(2,'2027春季学期','2027-03-01',1,18,'2026-11-07 19:54:57','2026-11-07 19:54:57');
/*!40000 ALTER TABLE `timetable` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_tt_u` BEFORE UPDATE ON `timetable` FOR EACH ROW BEGIN
  DECLARE v_bad SMALLINT DEFAULT NULL;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_bad=NULL;
  IF NEW.start_week<>OLD.start_week OR NEW.end_week<>OLD.end_week THEN
    SELECT week_no INTO v_bad FROM meeting_week WHERE timetable_id=OLD.timetable_id
      AND (week_no<NEW.start_week OR week_no>NEW.end_week) LIMIT 1 FOR SHARE;
    IF v_bad IS NOT NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='修改学期范围前须先调整越界的已有周次';
    END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping routines for database 'personal_timetable'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_timetable` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_timetable`(IN p_timetable_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-07 20:01:33
