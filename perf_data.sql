--ТЕСТ ПРОИЗВОДИТЕЛЬНОСТИ

-- пользователи
INSERT INTO users (email, password_hash, full_name, role)
SELECT
    'user' || gs || '@mail.com',
    md5(random()::text),
    'User ' || gs,
    CASE
        WHEN gs % 10 = 0 THEN 'instructor'
        ELSE 'student'
    END
FROM generate_series(1, 10000) AS gs;


-- категории
INSERT INTO categories (name)
SELECT 'Category ' || gs
FROM generate_series(1, 50) AS gs;


-- курсы
INSERT INTO courses (title, description, price, instructor_id, category_id)
SELECT
    'Course ' || gs,
    'Description for course ' || gs,
    (random() * 200)::numeric(10,2),
    (SELECT id FROM users WHERE role = 'instructor' ORDER BY random() LIMIT 1),
    (SELECT id FROM categories ORDER BY random() LIMIT 1)
FROM generate_series(1, 500) AS gs;


-- модули
INSERT INTO modules (course_id, title, position)
SELECT
    (SELECT id FROM courses ORDER BY random() LIMIT 1),
    'Module ' || gs,
    (random()*10)::int + 1
FROM generate_series(1, 5000) AS gs;


-- занятия
INSERT INTO lessons (module_id, title, content, duration_minutes)
SELECT
    (SELECT id FROM modules ORDER BY random() LIMIT 1),
    'Lesson ' || gs,
    'Content for lesson ' || gs,
    (random()*60)::int + 5
FROM generate_series(1, 20000) AS gs;


-- регистрации
INSERT INTO enrollments (student_id, course_id, status)
SELECT
    (SELECT id FROM users WHERE role='student' ORDER BY random() LIMIT 1),
    (SELECT id FROM courses ORDER BY random() LIMIT 1),
    CASE
        WHEN random() < 0.2 THEN 'completed'
        ELSE 'active'
    END
FROM generate_series(1, 100000)
ON CONFLICT (student_id, course_id) DO NOTHING;


-- задания
INSERT INTO assignments (lesson_id, title, max_score)
SELECT
    (SELECT id FROM lessons ORDER BY random() LIMIT 1),
    'Assignment ' || gs,
    100
FROM generate_series(1, 10000) AS gs;


-- материалы
INSERT INTO submissions (assignment_id, student_id, score)
SELECT
    (SELECT id FROM assignments ORDER BY random() LIMIT 1),
    (SELECT id FROM users WHERE role='student' ORDER BY random() LIMIT 1),
    (random()*100)::int
FROM generate_series(1, 5000)   
ON CONFLICT (assignment_id, student_id) DO NOTHING;   

-- платежи
INSERT INTO payments (student_id, course_id, amount, status, paid_at)
SELECT
    (SELECT id FROM users WHERE role='student' ORDER BY random() LIMIT 1),
    (SELECT id FROM courses ORDER BY random() LIMIT 1),
    (random()*200)::numeric(10,2),
    'completed',
    CURRENT_TIMESTAMP
FROM generate_series(1, 50000);