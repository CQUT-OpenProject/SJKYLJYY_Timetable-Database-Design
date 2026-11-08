-- 仅在样例数据的独立恢复库中验收。使用mysql --force执行，预期出现16次拒绝错误。
-- 预期拒绝不表示建库失败；也可按用例逐条执行。
SET NAMES utf8mb4;

-- 五张核心表；预期：5
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE';

-- 六条外键；预期：6
SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_type='FOREIGN KEY';

-- 五项表级CHECK；预期：5
SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_type='CHECK';

-- 多课表隔离；预期：1:数据库原理及应用|2:数据库原理及应用
SELECT GROUP_CONCAT(CONCAT(timetable_id,':',course_name) ORDER BY timetable_id SEPARATOR '|') FROM course WHERE course_no=1;

-- 同课程多安排；预期：2
SELECT COUNT(*) FROM course_meeting WHERE timetable_id=1 AND course_no=1;

-- 双周安排；预期：2,4,6,8,10,12,14,16,18,20
SELECT GROUP_CONCAT(week_no ORDER BY week_no) FROM meeting_week WHERE timetable_id=1 AND course_no=1 AND meeting_no=2;

-- 单周安排；预期：1,3,5,7,9,11,13,15,17,19
SELECT GROUP_CONCAT(week_no ORDER BY week_no) FROM meeting_week WHERE timetable_id=1 AND course_no=3;

-- 不连续周次；预期：2,5,9,14
SELECT GROUP_CONCAT(week_no ORDER BY week_no) FROM meeting_week WHERE timetable_id=1 AND course_no=6;

-- 全学期周次展开；预期：20
SELECT COUNT(*) FROM meeting_week WHERE timetable_id=1 AND course_no=1 AND meeting_no=1;

-- 冲突精确定位；预期：1	1	1	5	1	1	3
-- 1	3	1	5	1	1	3
SELECT a.timetable_id,a.course_no AS course_a,a.meeting_no AS meeting_a,
 b.course_no AS course_b,b.meeting_no AS meeting_b,a.day_of_week,
 GROUP_CONCAT(wa.week_no ORDER BY wa.week_no) AS common_weeks
FROM course_meeting a JOIN course_meeting b
 ON a.timetable_id=b.timetable_id
 AND (a.course_no<b.course_no OR (a.course_no=b.course_no AND a.meeting_no<b.meeting_no))
 AND a.day_of_week=b.day_of_week
 AND a.start_period<=b.end_period AND b.start_period<=a.end_period
JOIN meeting_week wa ON wa.timetable_id=a.timetable_id AND wa.course_no=a.course_no AND wa.meeting_no=a.meeting_no
JOIN meeting_week wb ON wb.timetable_id=b.timetable_id AND wb.course_no=b.course_no AND wb.meeting_no=b.meeting_no AND wb.week_no=wa.week_no
GROUP BY a.timetable_id,a.course_no,a.meeting_no,b.course_no,b.meeting_no,a.day_of_week
ORDER BY a.timetable_id,a.course_no,b.course_no;

-- 第3周课程数；预期：5
SELECT COUNT(*) FROM meeting_week WHERE timetable_id=1 AND week_no=3;

-- 重复主键；预期拒绝，错误码 1062
INSERT INTO course(timetable_id,course_no,course_name) VALUES(1,1,'重复');

-- 不存在的课表外键；预期拒绝，错误码 1452
INSERT INTO course(timetable_id,course_no,course_name) VALUES(999,1,'外键测试');

-- 不存在的课程外键；预期拒绝，错误码 1452
INSERT INTO course_meeting(timetable_id,course_no,meeting_no,day_of_week,start_period,end_period) VALUES(1,999,1,1,1,2);

-- 非法星期；预期拒绝，错误码 3819
INSERT INTO course_meeting(timetable_id,course_no,meeting_no,day_of_week,start_period,end_period) VALUES(1,1,99,8,1,2);

-- 倒置节次；预期拒绝，错误码 3819
INSERT INTO course_meeting(timetable_id,course_no,meeting_no,day_of_week,start_period,end_period) VALUES(1,1,99,1,4,2);

-- 不存在的节次；预期拒绝，错误码 1644
INSERT INTO course_meeting(timetable_id,course_no,meeting_no,day_of_week,start_period,end_period) VALUES(1,1,99,1,8,9);

-- 新增越界周次；预期拒绝，错误码 1644
INSERT INTO meeting_week VALUES(1,1,1,21,NULL);

-- 修改越界周次；预期拒绝，错误码 1644
UPDATE meeting_week SET week_no=21 WHERE timetable_id=1 AND course_no=1 AND meeting_no=1 AND week_no=20;

-- 缩小学期范围；预期拒绝，错误码 1644
UPDATE timetable SET end_week=10 WHERE timetable_id=1;

-- 删除使用中的节次；预期拒绝，错误码 1644
DELETE FROM period_time WHERE timetable_id=1 AND period_no=2;

-- 时间倒置；预期拒绝，错误码 3819
UPDATE period_time SET end_time='07:00' WHERE timetable_id=1 AND period_no=1;

-- 节次时间交叠；预期拒绝，错误码 1644
UPDATE period_time SET start_time='08:40' WHERE timetable_id=1 AND period_no=2;

-- 非周一的第一周日期；预期拒绝，错误码 3819
UPDATE timetable SET term_start_date='2026-09-08' WHERE timetable_id=1;

-- 空课程名称；预期拒绝，错误码 3819
INSERT INTO course VALUES(1,99,'   ',NULL);

-- 事务主动回滚；预期：0
START TRANSACTION; INSERT INTO course VALUES(1,99,'回滚测试',NULL); ROLLBACK; SELECT COUNT(*) FROM course WHERE timetable_id=1 AND course_no=99;

-- 导入批次遇到重复主键失败；预期拒绝，错误码 1062
START TRANSACTION; INSERT INTO course VALUES(1,99,'失败回滚测试',NULL); INSERT INTO course VALUES(1,1,'主键重复',NULL);
ROLLBACK; -- 批次失败后显式回滚，随后检查没有部分记录
ROLLBACK; -- 批次失败后显式回滚，随后检查没有部分记录
ROLLBACK; -- 批次失败后显式回滚，随后检查没有部分记录

-- 失败批次未留下部分数据；预期：0
SELECT COUNT(*) FROM course WHERE timetable_id=1 AND course_no=99;

-- 按依赖删除整张课表；预期：0
INSERT INTO timetable(timetable_id,timetable_name,term_start_date) VALUES(99,'删除测试','2026-09-07'); INSERT INTO period_time VALUES(99,1,'08:00','08:45'); INSERT INTO course VALUES(99,1,'删除测试',NULL); INSERT INTO course_meeting VALUES(99,1,1,1,1,1,NULL,NULL,NULL); INSERT INTO meeting_week VALUES(99,1,1,1,NULL); CALL sp_delete_timetable(99); SELECT (SELECT COUNT(*) FROM timetable WHERE timetable_id=99)+(SELECT COUNT(*) FROM period_time WHERE timetable_id=99)+(SELECT COUNT(*) FROM course WHERE timetable_id=99)+(SELECT COUNT(*) FROM course_meeting WHERE timetable_id=99)+(SELECT COUNT(*) FROM meeting_week WHERE timetable_id=99);

-- 创建专用删除回滚测试数据及临时故障注入触发器
INSERT INTO timetable(timetable_id,timetable_name,term_start_date) VALUES(98,'异常回滚测试','2026-09-07');
INSERT INTO period_time VALUES(98,1,'08:00','08:45');
INSERT INTO course VALUES(98,1,'异常回滚测试',NULL);
INSERT INTO course_meeting VALUES(98,1,1,1,1,1,NULL,NULL,NULL);
INSERT INTO meeting_week VALUES(98,1,1,1,NULL);
CREATE TRIGGER tr_test_delete_guard BEFORE DELETE ON course FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='test rollback';

-- 删除中途异常触发回滚；预期拒绝，错误码 1644
CALL sp_delete_timetable(98);

-- 删除回滚恢复所有依赖记录；预期：5
SELECT (SELECT COUNT(*) FROM timetable WHERE timetable_id=98)+(SELECT COUNT(*) FROM period_time WHERE timetable_id=98)+(SELECT COUNT(*) FROM course WHERE timetable_id=98)+(SELECT COUNT(*) FROM course_meeting WHERE timetable_id=98)+(SELECT COUNT(*) FROM meeting_week WHERE timetable_id=98);

-- 移除故障注入并清理测试课表
DROP TRIGGER tr_test_delete_guard;
CALL sp_delete_timetable(98);

-- 相同时间但周次不相交；预期：0
START TRANSACTION; INSERT INTO course_meeting VALUES(1,3,99,1,1,2,NULL,NULL,NULL); INSERT INTO meeting_week VALUES(1,3,99,2,NULL); SELECT COUNT(*) FROM meeting_week a JOIN meeting_week b ON a.timetable_id=b.timetable_id AND a.week_no=b.week_no WHERE a.timetable_id=1 AND a.course_no=3 AND a.meeting_no=99 AND b.course_no=5 AND b.meeting_no=1; ROLLBACK;