-- ТОП-10 самых популярных курсов
-- (по количеству записавшихся студентов)

SELECT
    c.title,
    COUNT(e.id) AS total_students
FROM courses c
JOIN enrollments e ON c.id = e.course_id
WHERE e.status IN ('active','completed')
GROUP BY c.title
ORDER BY total_students DESC
LIMIT 10;



-- Средний балл студентов по каждому курсу

SELECT
    c.title,
    ROUND(AVG(s.score), 2) AS avg_score
FROM courses c
JOIN modules m ON c.id = m.course_id
JOIN lessons l ON m.id = l.module_id
JOIN assignments a ON l.id = a.lesson_id
JOIN submissions s ON a.id = s.assignment_id
GROUP BY c.title
ORDER BY avg_score DESC;



-- Количество завершённых курсов по категориям

SELECT
    cat.name AS category,
    COUNT(e.id) AS completed_courses
FROM categories cat
JOIN courses c ON cat.id = c.category_id
JOIN enrollments e ON c.id = e.course_id
WHERE e.status = 'completed'
GROUP BY cat.name
ORDER BY completed_courses DESC;



-- Общая выручка по каждому курсу

SELECT
    c.title,
    SUM(p.amount) AS total_revenue
FROM courses c
JOIN payments p ON c.id = p.course_id
WHERE p.status = 'completed'
GROUP BY c.title
ORDER BY total_revenue DESC;



-- Количество курсов у каждого преподавателя

SELECT
    u.full_name,
    COUNT(c.id) AS total_courses
FROM users u
JOIN courses c ON u.id = c.instructor_id
WHERE u.role = 'instructor'
GROUP BY u.full_name
ORDER BY total_courses DESC;



-- Студенты, прошедшие более 3 курсов

SELECT
    u.full_name,
    COUNT(e.course_id) AS completed_count
FROM users u
JOIN enrollments e ON u.id = e.student_id
WHERE e.status = 'completed'
GROUP BY u.full_name
HAVING COUNT(e.course_id) > 3
ORDER BY completed_count DESC;



-- Средняя длительность уроков по курсам

SELECT
    c.title,
    ROUND(AVG(l.duration_minutes), 1) AS avg_duration
FROM courses c
JOIN modules m ON c.id = m.course_id
JOIN lessons l ON m.id = l.module_id
WHERE l.duration_minutes IS NOT NULL
GROUP BY c.title
ORDER BY avg_duration DESC;



-- Количество активных студентов по курсам

SELECT
    c.title,
    COUNT(DISTINCT e.student_id) AS active_students
FROM courses c
JOIN enrollments e ON c.id = e.course_id
WHERE e.status = 'active'
GROUP BY c.title
ORDER BY active_students DESC;
