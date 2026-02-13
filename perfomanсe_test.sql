-- Запускать вручную через psql или pgAdmin, не выполнять при инициализации бд

-- Популярные курсы (с индексом)

EXPLAIN ANALYZE
SELECT
    c.title,
    COUNT(e.id) AS total_students
FROM courses c
JOIN enrollments e ON c.id = e.course_id
WHERE e.status IN ('active','completed')
GROUP BY c.title
ORDER BY total_students DESC;



-- Поиск всех записей студента (использует индекс idx_enrollments_student)

EXPLAIN ANALYZE
SELECT *
FROM enrollments
WHERE student_id = (
    SELECT id FROM users
    WHERE role = 'student'
    LIMIT 1
);



-- Фильтрация платежей по статусу (использует индекс idx_payments_status)


EXPLAIN ANALYZE
SELECT *
FROM payments
WHERE status = 'completed';



-- Средний балл по курсам

EXPLAIN ANALYZE
SELECT
    c.title,
    ROUND(AVG(s.score),2)
FROM courses c
JOIN modules m ON c.id = m.course_id
JOIN lessons l ON m.id = l.module_id
JOIN assignments a ON l.id = a.lesson_id
JOIN submissions s ON a.id = s.assignment_id
GROUP BY c.title;



-- ТЕСТ БЕЗ ИНДЕКСА чтобы сравнить

-- Временно удаляем индекс
DROP INDEX IF EXISTS idx_enrollments_student;

EXPLAIN ANALYZE
SELECT *
FROM enrollments
WHERE student_id = (
    SELECT id FROM users
    WHERE role = 'student'
    LIMIT 1
);

-- Возвращаем индекс обратно
CREATE INDEX idx_enrollments_student
ON enrollments(student_id);
