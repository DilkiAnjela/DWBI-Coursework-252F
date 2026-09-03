CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE dw.dim_student (
    student_key BIGSERIAL PRIMARY KEY,

    student_id VARCHAR(50) UNIQUE NOT NULL,

    date_of_birth DATE,

    gender VARCHAR(20)
);

CREATE TABLE dw.dim_school (
    school_key BIGSERIAL PRIMARY KEY,

    school_id VARCHAR(50) UNIQUE NOT NULL,

    school_name VARCHAR(255),

    school_type VARCHAR(100)
);

CREATE TABLE dw.dim_stream (
    stream_key BIGSERIAL PRIMARY KEY,

    stream_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE dw.dim_medium (
    medium_key BIGSERIAL PRIMARY KEY,

    medium_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE dw.dim_subject (
    subject_key BIGSERIAL PRIMARY KEY,

    subject_code VARCHAR(20),

    subject_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE dw.dim_exam (
    exam_key BIGSERIAL PRIMARY KEY,

    exam_name VARCHAR(100),

    exam_year INTEGER,

    exam_type VARCHAR(50)
);

ALTER TABLE dw.dim_exam
ADD CONSTRAINT chk_exam_year
CHECK (exam_year >= 1900 AND exam_year <= 2100);

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'dw'
ORDER BY table_name;

DROP TABLE IF EXISTS dw.fact_student_performance CASCADE;

DROP TABLE IF EXISTS dw.dim_student CASCADE;
DROP TABLE IF EXISTS dw.dim_school CASCADE;
DROP TABLE IF EXISTS dw.dim_district CASCADE;
DROP TABLE IF EXISTS dw.dim_stream CASCADE;
DROP TABLE IF EXISTS dw.dim_medium CASCADE;
DROP TABLE IF EXISTS dw.dim_subject CASCADE;
DROP TABLE IF EXISTS dw.dim_exam CASCADE;

-- =========================================
-- DIMENSION 1: STUDENT
-- =========================================

CREATE TABLE dw.dim_student (
    student_key BIGSERIAL PRIMARY KEY,
    student_id VARCHAR(50) UNIQUE NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20)
);


-- =========================================
-- DIMENSION 2: SCHOOL
-- =========================================

CREATE TABLE dw.dim_school (
    school_key BIGSERIAL PRIMARY KEY,
    school_id VARCHAR(50) UNIQUE NOT NULL,
    school_name VARCHAR(255),
    school_type VARCHAR(100)
);


-- =========================================
-- DIMENSION 3: DISTRICT
-- =========================================

CREATE TABLE dw.dim_district (
    district_key BIGSERIAL PRIMARY KEY,
    district_name VARCHAR(100) UNIQUE NOT NULL,
    province_name VARCHAR(100)
);


-- =========================================
-- DIMENSION 4: STREAM
-- =========================================

CREATE TABLE dw.dim_stream (
    stream_key BIGSERIAL PRIMARY KEY,
    stream_name VARCHAR(100) UNIQUE NOT NULL
);


-- =========================================
-- DIMENSION 5: MEDIUM
-- =========================================

CREATE TABLE dw.dim_medium (
    medium_key BIGSERIAL PRIMARY KEY,
    medium_name VARCHAR(50) UNIQUE NOT NULL
);


-- =========================================
-- DIMENSION 6: SUBJECT
-- =========================================

CREATE TABLE dw.dim_subject (
    subject_key BIGSERIAL PRIMARY KEY,
    subject_code VARCHAR(20),
    subject_name VARCHAR(100) UNIQUE NOT NULL
);


-- =========================================
-- DIMENSION 7: EXAM
-- =========================================

CREATE TABLE dw.dim_exam (
    exam_key BIGSERIAL PRIMARY KEY,
    exam_name VARCHAR(100),
    exam_year INTEGER,
    exam_type VARCHAR(50)
);

-- =========================================
-- FACT TABLE: STUDENT PERFORMANCE
-- =========================================

CREATE TABLE dw.fact_student_performance (
    
    performance_key BIGSERIAL PRIMARY KEY,

    -- Foreign Keys
    student_key BIGINT NOT NULL,
    school_key BIGINT NOT NULL,
    district_key BIGINT NOT NULL,
    stream_key BIGINT NOT NULL,
    medium_key BIGINT NOT NULL,
    subject_key BIGINT NOT NULL,
    exam_key BIGINT NOT NULL,

    -- Measures / Performance Information
    marks NUMERIC(5,2),
    grade VARCHAR(5),
    z_score NUMERIC(8,4),

    -- Derived indicators
    pass_flag BOOLEAN,
    university_eligible_flag BOOLEAN,

    -- Audit field
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraints
    CONSTRAINT fk_fact_student
        FOREIGN KEY (student_key)
        REFERENCES dw.dim_student(student_key),

    CONSTRAINT fk_fact_school
        FOREIGN KEY (school_key)
        REFERENCES dw.dim_school(school_key),

    CONSTRAINT fk_fact_district
        FOREIGN KEY (district_key)
        REFERENCES dw.dim_district(district_key),

    CONSTRAINT fk_fact_stream
        FOREIGN KEY (stream_key)
        REFERENCES dw.dim_stream(stream_key),

    CONSTRAINT fk_fact_medium
        FOREIGN KEY (medium_key)
        REFERENCES dw.dim_medium(medium_key),

    CONSTRAINT fk_fact_subject
        FOREIGN KEY (subject_key)
        REFERENCES dw.dim_subject(subject_key),

    CONSTRAINT fk_fact_exam
        FOREIGN KEY (exam_key)
        REFERENCES dw.dim_exam(exam_key),

    -- Prevent duplicate student-subject-exam records
    CONSTRAINT uq_student_subject_exam
        UNIQUE (student_key, subject_key, exam_key),

    -- Marks validation
    CONSTRAINT chk_marks
        CHECK (marks IS NULL OR (marks >= 0 AND marks <= 100)),

    -- Exam result grade validation
    CONSTRAINT chk_grade
        CHECK (
            grade IS NULL
            OR grade IN ('A', 'B', 'C', 'S', 'W', 'F')
        )
);

CREATE INDEX idx_fact_student
ON dw.fact_student_performance(student_key);

CREATE INDEX idx_fact_school
ON dw.fact_student_performance(school_key);

CREATE INDEX idx_fact_district
ON dw.fact_student_performance(district_key);

CREATE INDEX idx_fact_stream
ON dw.fact_student_performance(stream_key);

CREATE INDEX idx_fact_medium
ON dw.fact_student_performance(medium_key);

CREATE INDEX idx_fact_subject
ON dw.fact_student_performance(subject_key);

CREATE INDEX idx_fact_exam
ON dw.fact_student_performance(exam_key);

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'dw'
ORDER BY table_name;

INSERT INTO dw.dim_exam (
    exam_name,
    exam_year,
    exam_type
)
VALUES (
    'GCE Advanced Level Examination',
    2020,
    'GCE A/L'
);



