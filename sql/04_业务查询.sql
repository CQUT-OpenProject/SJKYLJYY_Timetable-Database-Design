-- 第3周课程查询
SELECT c.course_name,m.day_of_week,m.start_period,m.end_period,
 p1.start_time,p2.end_time,m.teacher_name,m.location
FROM meeting_week w
JOIN course_meeting m USING(timetable_id,course_no,meeting_no)
JOIN course c USING(timetable_id,course_no)
JOIN period_time p1 ON p1.timetable_id=m.timetable_id AND p1.period_no=m.start_period
JOIN period_time p2 ON p2.timetable_id=m.timetable_id AND p2.period_no=m.end_period
WHERE w.timetable_id=1 AND w.week_no=3
ORDER BY m.day_of_week,m.start_period,c.course_no;

-- 时间冲突查询（跨周次和节次区间）
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

-- 每张课表的课程数量
SELECT t.timetable_id,t.timetable_name,COUNT(c.course_no) AS course_count FROM timetable t LEFT JOIN course c USING(timetable_id) GROUP BY t.timetable_id,t.timetable_name;

-- 不连续周次
SELECT week_no FROM meeting_week WHERE timetable_id=1 AND course_no=6 ORDER BY week_no;

-- 被课表引用的节次应先通过业务调整解除引用
-- 删除整张课表请在独立调用中执行 CALL sp_delete_timetable(课表编号);
