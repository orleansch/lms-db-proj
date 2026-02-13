-- генерация уникальных Id
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- пользаки
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('student','instructor','admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- категории
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- курсы
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    instructor_id UUID NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_course_instructor
        FOREIGN KEY (instructor_id) REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_course_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- модули
CREATE TABLE modules (
    id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    position INT NOT NULL CHECK (position > 0),

    CONSTRAINT fk_module_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
        ON DELETE CASCADE
);

-- занятия
CREATE TABLE lessons (
    id SERIAL PRIMARY KEY,
    module_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    duration_minutes INT CHECK (duration_minutes > 0),

    CONSTRAINT fk_lesson_module
        FOREIGN KEY (module_id) REFERENCES modules(id)
        ON DELETE CASCADE
);

-- регистрация
CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    student_id UUID NOT NULL,
    course_id INT NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active'
        CHECK (status IN ('active','completed','cancelled')),

    UNIQUE(student_id, course_id),

    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- задания
CREATE TABLE assignments (
    id SERIAL PRIMARY KEY,
    lesson_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    max_score INT NOT NULL CHECK (max_score > 0),

    FOREIGN KEY (lesson_id) REFERENCES lessons(id)
    ON DELETE CASCADE
);

-- заявки
CREATE TABLE submissions (
    id SERIAL PRIMARY KEY,
    assignment_id INT NOT NULL,
    student_id UUID NOT NULL,
    score INT CHECK (score >= 0),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (assignment_id, student_id),

    FOREIGN KEY (assignment_id) REFERENCES assignments(id)
        ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id)
        ON DELETE CASCADE
);

-- платежи
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    student_id UUID NOT NULL,
    course_id INT NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    status VARCHAR(20) DEFAULT 'pending'
        CHECK (status IN ('pending','completed','failed')),
    paid_at TIMESTAMP,

    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- серты
CREATE TABLE certificates (
    id SERIAL PRIMARY KEY,
    student_id UUID NOT NULL,
    course_id INT NOT NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(student_id, course_id),

    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- индексы
CREATE INDEX idx_courses_instructor ON courses(instructor_id);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_submissions_student ON submissions(student_id);
CREATE INDEX idx_payments_status ON payments(status);


-- ТРИГГЕРЫ!!!!!!!

-- автовыдача серта
CREATE OR REPLACE FUNCTION issue_certificate()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' THEN
        INSERT INTO certificates(student_id, course_id)
        VALUES (NEW.student_id, NEW.course_id)
        ON CONFLICT DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_issue_certificate
AFTER UPDATE ON enrollments
FOR EACH ROW
EXECUTE FUNCTION issue_certificate();

-- поверка, что оценка меньше или равна максимальной
CREATE OR REPLACE FUNCTION check_submission_score()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.score > (SELECT max_score FROM assignments WHERE id = NEW.assignment_id) THEN
        RAISE EXCEPTION 'Score cannot exceed max_score for this assignment!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_score
BEFORE INSERT OR UPDATE ON submissions
FOR EACH ROW
EXECUTE FUNCTION check_submission_score();
